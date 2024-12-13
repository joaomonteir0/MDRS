%% 1.c.

clear
clc

% Carregar os dados de entrada
load('InputDataProject2.mat');

% Definir os parâmetros
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);

v = 2 * 10^5; % velocidade da luz em km/s
D = L / v; % matriz de atrasos de propagação

% Inicializar variáveis para armazenar os melhores resultados
bestAnycastNodes = [];
minWorstLinkLoad = inf;
bestDelays = [];
bestTaux = [];
bestSP = [];

% Testar todas as combinações possíveis de dois nós
for i = 1:nNodes
    for j = i+1:nNodes
        anycastNodes = [i j];
        
        % Inicializar variáveis
        Taux = zeros(nFlows, 4);
        delays = zeros(nFlows, 1);
        sP = cell(nFlows, 1);
        
        % Calcular as rotas mais curtas e os atrasos
        for n = 1:nFlows
            if T(n, 1) == 1 || T(n, 1) == 2
                [shortestPath, totalCost] = kShortestPath(D, T(n, 2), T(n, 3), 1);
                sP{n} = shortestPath;
                delays(n) = totalCost;
                Taux(n, :) = T(n, 2:5);
            elseif T(n, 1) == 3
                cost = inf;
                Taux(n, :) = T(n, 2:5);
                for k = anycastNodes
                    [shortestPath, totalCost] = kShortestPath(D, T(n, 2), k, 1);
                    if totalCost < cost
                        sP{n} = shortestPath;
                        cost = totalCost;
                        delays(n) = totalCost;
                        Taux(n, 3) = k;
                    end
                end
            end
        end
        
        % Calcular as cargas dos links
        Loads = calculateLinkLoads(nNodes, Links, Taux, sP, ones(nFlows, 1));
        
        % Encontrar a pior carga de link
        worstLinkLoad = max(max(Loads(:, 3:4)));
        
        % Atualizar os melhores resultados se a carga de link for menor
        if worstLinkLoad < minWorstLinkLoad
            minWorstLinkLoad = worstLinkLoad;
            bestAnycastNodes = anycastNodes;
            bestDelays = delays;
            bestTaux = Taux;
            bestSP = sP;
        end
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
fprintf('Best anycast nodes: %d  %d\n', bestAnycastNodes(1), bestAnycastNodes(2));
fprintf('Worst link load: %.2f Gbps\n', minWorstLinkLoad);
fprintf('Worst round-trip delay (unicast service): %.2f ms\n', worstRoundTripDelayUnicast);
fprintf('Average round-trip delay (unicast service): %.2f ms\n', averageRoundTripDelayUnicast);
fprintf('Worst round-trip delay (anycast service): %.2f ms\n', worstRoundTripDelayAnycast);
fprintf('Average round-trip delay (anycast service): %.2f ms\n', averageRoundTripDelayAnycast);
