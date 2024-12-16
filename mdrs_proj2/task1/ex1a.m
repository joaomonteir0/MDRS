%% 1.a.

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

% Inicializar variáveis para armazenar os atrasos
Taux = zeros(nFlows, 4);
delays = zeros(nFlows, 1);
sP = cell(nFlows, 1);
nSP = cell(nFlows, 1);

% Calcular os caminhos mais curtos e os atrasos de ida e volta
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(n, 2), T(n, 3), 1);
        sP{n} = shortestPath;
        nSP{n} = length(shortestPath);
        delays(n) = totalCost;
        Taux(n, :) = T(n, 2:5);
    elseif T(n, 1) == 3
        if ismember(T(n, 2), anycastNodes)
            sP{n} = {T(n, 2)};
            nSP{n} = 1;
            Taux(n, :) = T(n, 2:5);
            Taux(n, 3) = T(n, 2);
        else
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
end

% Calcular os atrasos de ida e volta
unicastFlows1 = find(T(:, 1) == 1);
unicastFlows2 = find(T(:, 1) == 2);
anycastFlows = find(T(:, 1) == 3);

maxDelayUnicast1 = max(delays(unicastFlows1)) * 2 * 1000;
avgDelayUnicast1 = mean(delays(unicastFlows1)) * 2 * 1000;

maxDelayUnicast2 = max(delays(unicastFlows2)) * 2 * 1000;
avgDelayUnicast2 = mean(delays(unicastFlows2)) * 2 * 1000;

maxDelayAnycast = max(delays(anycastFlows)) * 2 * 1000;
avgDelayAnycast = mean(delays(anycastFlows)) * 2 * 1000;

% Exibir os resultados
fprintf('Anycast nodes: %d  %d\n', anycastNodes(1), anycastNodes(2));
fprintf('Worst round-trip delay (unicast service 1): %.2f ms\n', maxDelayUnicast1);
fprintf('Average round-trip delay (unicast service 1): %.2f ms\n', avgDelayUnicast1);
fprintf('Worst round-trip delay (unicast service 2): %.2f ms\n', maxDelayUnicast2);
fprintf('Average round-trip delay (unicast service 2): %.2f ms\n', avgDelayUnicast2);
fprintf('Worst round-trip delay (anycast service): %.2f ms\n', maxDelayAnycast);
fprintf('Average round-trip delay (anycast service): %.2f ms\n', avgDelayAnycast);
