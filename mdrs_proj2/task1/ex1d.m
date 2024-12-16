%% 1.d.

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
minWorstRoundTripDelay = inf;
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
                if ismember(T(n, 2), anycastNodes)
                    sP{n} = {T(n, 2)};
                    nSP{n} = 1;
                    Taux(n, :) = T(n, 2:5);
                    Taux(n, 3) = T(n, 2);
                else
                    cost = inf;
                    Taux(n, :) = T(n, 2:5);
                    for k = anycastNodes
                        [shortestPath, totalCost] = kShortestPath(D, T(n, 2), k, 1);
                        if totalCost < cost
                            sP{n} = shortestPath;
                            nSP{n} = 1;
                            cost = totalCost;
                            delays(n) = totalCost;
                            Taux(n, 3) = k;
                        end
                    end
                end
            end
        end
        
        % Calcular os atrasos de ida e volta
        maxDelayUnicast1 = max(delays(find(T(:, 1) == 1))) * 2 * 1000;
        avgDelayUnicast1 = mean(delays(find(T(:, 1) == 1))) * 2 * 1000;
        maxDelayUnicast2 = max(delays(find(T(:, 1) == 2))) * 2 * 1000;
        avgDelayUnicast2 = mean(delays(find(T(:, 1) == 2))) * 2 * 1000;
        maxDelayAnycast = max(delays(find(T(:, 1) == 3))) * 2 * 1000;
        avgDelayAnycast = mean(delays(find(T(:, 1) == 3))) * 2 * 1000;
        
        % Atualizar os melhores resultados se o atraso de ida e volta for menor
        if maxDelayAnycast < minWorstRoundTripDelay
            minWorstRoundTripDelay = maxDelayAnycast;
            bestAnycastNodes = anycastNodes;
            bestDelays = delays;
            bestTaux = Taux;
            bestSP = sP;
        end
    end
end

% Calcular as cargas dos links para a melhor combinação
Loads = calculateLinkLoads(nNodes, Links, bestTaux, bestSP, ones(nFlows, 1));

% Encontrar a pior carga de link
worstLinkLoad = max(max(Loads(:, 3:4)));

% Calcular os atrasos de ida e volta
maxDelayUnicast1 = max(bestDelays(find(T(:, 1) == 1))) * 2 * 1000;
avgDelayUnicast1 = mean(bestDelays(find(T(:, 1) == 1))) * 2 * 1000;
maxDelayUnicast2 = max(bestDelays(find(T(:, 1) == 2))) * 2 * 1000;
avgDelayUnicast2 = mean(bestDelays(find(T(:, 1) == 2))) * 2 * 1000;
maxDelayAnycast = max(bestDelays(find(T(:, 1) == 3))) * 2 * 1000;
avgDelayAnycast = mean(bestDelays(find(T(:, 1) == 3))) * 2 * 1000;

% Exibir os resultados
fprintf('Best anycast nodes = %d  %d\n', bestAnycastNodes(1), bestAnycastNodes(2));
fprintf('Worst link load = %.2f Gbps\n', worstLinkLoad);
fprintf('Worst round-trip delay (unicast service 1) = %.2f ms\n', maxDelayUnicast1);
fprintf('Average round-trip delay (unicast service 1) = %.2f ms\n', avgDelayUnicast1);
fprintf('Worst round-trip delay (unicast service 2) = %.2f ms\n', maxDelayUnicast2);
fprintf('Average round-trip delay (unicast service 2) = %.2f ms\n', avgDelayUnicast2);
fprintf('Worst round-trip delay (anycast service) = %.2f ms\n', maxDelayAnycast);
fprintf('Average round-trip delay (anycast service) = %.2f ms\n', avgDelayAnycast);
