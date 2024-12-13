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

% Inicializar variáveis para armazenar os atrasos
roundTripDelays = zeros(nFlows, 1);

% Calcular os caminhos mais curtos e os atrasos de ida e volta
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(n, 2), T(n, 3), 1);
        roundTripDelays(n) = 2 * totalCost; % ida e volta
    elseif T(n, 1) == 3
        anycastNodes = [3 10];
        cost = inf;
        for i = anycastNodes
            [shortestPath, totalCost] = kShortestPath(D, T(n, 2), i, 1);
            if totalCost < cost
                cost = totalCost;
            end
        end
        roundTripDelays(n) = 2 * cost; % ida e volta
    end
end

% Calcular os atrasos de ida e volta para cada serviço
worstRoundTripDelay = zeros(3, 1);
averageRoundTripDelay = zeros(3, 1);

for s = 1:3
    serviceDelays = roundTripDelays(T(:, 1) == s);
    worstRoundTripDelay(s) = max(serviceDelays);
    averageRoundTripDelay(s) = mean(serviceDelays);
end

% Exibir os resultados
fprintf('Worst round-trip delay (ms):\n');
fprintf('Unicast Service 1: %.2f ms\n', worstRoundTripDelay(1) * 1000);
fprintf('Unicast Service 2: %.2f ms\n', worstRoundTripDelay(2) * 1000);
fprintf('Anycast Service 3: %.2f ms\n', worstRoundTripDelay(3) * 1000);

fprintf('\nAverage round-trip delay (ms):\n');
fprintf('Unicast Service 1: %.2f ms\n', averageRoundTripDelay(1) * 1000);
fprintf('Unicast Service 2: %.2f ms\n', averageRoundTripDelay(2) * 1000);
fprintf('Anycast Service 3: %.2f ms\n', averageRoundTripDelay(3) * 1000);
