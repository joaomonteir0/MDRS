%% 2.a.

clear
clc

% Carregar os dados de entrada
load('InputDataProject2.mat');

% Definir os parâmetros
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);
k = 6; % número de caminhos candidatos
maxTime = 30; % tempo máximo de execução em segundos
anycastNodes = [3 10];

v = 2 * 10^5; % velocidade da luz em km/s
D = L / v; % matriz de atrasos de propagação

% Inicializar variáveis para armazenar os melhores resultados
bestSolution = [];
minWorstLinkLoad = inf;
bestDelays = [];
bestTaux = [];
bestSP = [];
totalCycles = 0;
bestTime = 0;
bestCycle = 0;

% Gerar caminhos candidatos para cada fluxo unicast
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2
        [shortestPaths, totalCosts] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{f} = shortestPaths;
        nSP(f) = length(totalCosts);
    end
end

% Multi start hill climbing with greedy randomized
t = tic;
bestLoad = inf;
contador = 0;
somador = 0;
while toc(t) < maxTime
    % greedy randomized start
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);

    [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);

    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoads = calculateLinkLoads(nNodes, Links, T, sP, sol);
        bestLoadTime = toc(t);
        bestCycle = contador;
    end
    contador = contador + 1;
    somador = somador + load;
end

% Calcular os atrasos de ida e volta para a melhor solução
bestDelays = zeros(nFlows, 1);
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        bestDelays(n) = sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end))));
    elseif T(n, 1) == 3
        bestDelays(n) = min(sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end)))));
    end
end

% Calcular os atrasos de ida e volta
unicastFlows = find(T(:, 1) == 1 | T(:, 1) == 2);
anycastFlows = find(T(:, 1) == 3);

worstRoundTripDelayUnicast = max(bestDelays(unicastFlows)) * 2 * 1000;
averageRoundTripDelayUnicast = mean(bestDelays(unicastFlows)) * 2 * 1000;

worstRoundTripDelayAnycast = max(bestDelays(anycastFlows)) * 2 * 1000;
averageRoundTripDelayAnycast = mean(bestDelays(anycastFlows)) * 2 * 1000;

% Exibir os resultados
fprintf('Worst round-trip delay (unicast service): %.2f ms\n', worstRoundTripDelayUnicast);
fprintf('Average round-trip delay (unicast service): %.2f ms\n', averageRoundTripDelayUnicast);
fprintf('Worst round-trip delay (anycast service): %.2f ms\n', worstRoundTripDelayAnycast);
fprintf('Average round-trip delay (anycast service): %.2f ms\n', averageRoundTripDelayAnycast);
fprintf('Worst link load: %.2f Gbps\n', bestLoad);
fprintf('Total number of cycles run: %d\n', contador);
fprintf('Running time at which the best solution was obtained: %.2f seconds\n', bestLoadTime);
fprintf('Number of cycles at which the best solution was obtained: %d\n', bestCycle);
