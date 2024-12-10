%% Exercise 1.e.

clear all
close all
clc

load('InputDataProject2.mat');

v = 2e5;
D = L / v;

nNodes = size(Nodes, 1);
nFlows = size(T, 1);

bestAverageRoundTripDelay = inf;
bestAnycastNodes = [];
bestRoundTripDelays = [];

for i = 1:nNodes-1
    for j = i+1:nNodes
        anycastNodes = [i, j];
        roundTripDelays = zeros(nFlows, 1);
        sP = cell(1, nFlows);

        unicastFlows = find(T(:, 1) == 1 | T(:, 1) == 2);
        for f = unicastFlows'
            [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), 1);
            sP{f} = shortestPath;
            roundTripDelays(f) = 2 * totalCost;
        end

        anycastFlows = find(T(:, 1) == 3);
        for f = anycastFlows'
            bestDelay = inf;
            bestPath = [];
            for anycastNode = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(f, 2), anycastNode, 1);
                if totalCost < bestDelay
                    bestDelay = totalCost;
                    bestPath = shortestPath;
                end
            end
            sP{f} = bestPath;
            roundTripDelays(f) = 2 * bestDelay;
        end

        averageAnycastDelay = mean(roundTripDelays(anycastFlows));

        if averageAnycastDelay < bestAverageRoundTripDelay
            bestAverageRoundTripDelay = averageAnycastDelay;
            bestAnycastNodes = anycastNodes;
            bestRoundTripDelays = roundTripDelays;
        end
    end
end

unicastFlows = find(T(:, 1) == 1 | T(:, 1) == 2);
worstUnicastDelay = max(bestRoundTripDelays(unicastFlows));
averageUnicastDelay = mean(bestRoundTripDelays(unicastFlows));

anycastFlows = find(T(:, 1) == 3);
worstAnycastDelay = max(bestRoundTripDelays(anycastFlows));
averageAnycastDelay = mean(bestRoundTripDelays(anycastFlows));

fprintf('Best anycast nodes= %d %d\n', bestAnycastNodes);
fprintf('Worst round-trip delay (unicast service) = %.2f ms\n', worstUnicastDelay * 1e3);
fprintf('Average round-trip delay (unicast service) = %.2f ms\n', averageUnicastDelay * 1e3);
fprintf('Worst round-trip delay (anycast service) = %.2f ms\n', worstAnycastDelay * 1e3);
fprintf('Average round-trip delay (anycast service) = %.2f ms\n', averageAnycastDelay * 1e3);
