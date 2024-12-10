%% Exercise 1.a.

clear all
close all
clc

load('InputDataProject2.mat');

v = 2e5;
anycastNodes = [3, 10];

D = L / v;

nNodes = size(Nodes, 1);
nFlows = size(T, 1);
roundTripDelays = zeros(nFlows, 1);

unicastFlows = find(T(:, 1) == 1 | T(:, 1) == 2);
for f = unicastFlows'
    [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), 1);
    roundTripDelays(f) = 2 * totalCost; % Round-trip delay
end

anycastFlows = find(T(:, 1) == 3);
for f = anycastFlows'
    bestDelay = inf;
    for anycastNode = anycastNodes
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), anycastNode, 1);
        if totalCost < bestDelay
            bestDelay = totalCost;
        end
    end
    roundTripDelays(f) = 2 * bestDelay; % Round-trip delay
end

worstUnicastDelay = max(roundTripDelays(unicastFlows));
averageUnicastDelay = mean(roundTripDelays(unicastFlows));

worstAnycastDelay = max(roundTripDelays(anycastFlows));
averageAnycastDelay = mean(roundTripDelays(anycastFlows));

fprintf('Anycast nodes = %d %d\n', anycastNodes);
fprintf('Worst round-trip delay (unicast service) = %.2f ms\n', worstUnicastDelay * 1e3);
fprintf('Average round-trip delay (unicast service) = %.2f ms\n', averageUnicastDelay * 1e3);
fprintf('Worst round-trip delay (anycast service) = %.2f ms\n', worstAnycastDelay * 1e3);
fprintf('Average round-trip delay (anycast service) = %.2f ms\n', averageAnycastDelay * 1e3);
