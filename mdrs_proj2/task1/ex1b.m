%% 1.b.

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

% Definir os nós anycast
anycastNodes = [3 10];

% Inicializar variáveis
Taux = zeros(nFlows, 4);
delays = zeros(nFlows, 1);
sP = cell(nFlows, 1);
nSP = cell(nFlows, 1);

% Calcular as rotas mais curtas e os atrasos
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(n, 2), T(n, 3), 1);
        sP{n} = shortestPath;
        nSP{n} = length(shortestPath);
        delays(n) = totalCost;
        Taux(n, :) = T(n, 2:5);
    elseif T(n, 1) == 3
        cost = inf;
        Taux(n, :) = T(n, 2:5);
        for i = anycastNodes
            [shortestPath, totalCost] = kShortestPath(D, T(n, 2), i, 1);
            if totalCost < cost
                sP{n} = shortestPath;
                nSP{n} = 1;
                cost = totalCost;
                delays(n) = totalCost;
                Taux(n, 3) = i;
            end
        end
    end
end

% Calcular as cargas dos links
Loads = calculateLinkLoads(nNodes, Links, Taux, sP, ones(nFlows, 1));

% Encontrar a pior carga de link
worstLinkLoad = max(max(Loads(:, 3:4)));

% Exibir os resultados
fprintf('Anycast nodes: %d  %d\n', anycastNodes(1), anycastNodes(2));
fprintf('Worst link load: %.2f Gbps\n', worstLinkLoad);
for i = 1:nLinks
    fprintf('{ %d - %d}: %.2f %.2f\n', Loads(i, 1), Loads(i, 2), Loads(i, 3), Loads(i, 4));
end
