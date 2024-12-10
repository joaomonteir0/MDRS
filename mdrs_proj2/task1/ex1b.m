%% Exercise 1.b.

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

worstUnicastDelay = max(roundTripDelays(unicastFlows));
averageUnicastDelay = mean(roundTripDelays(unicastFlows));

worstAnycastDelay = max(roundTripDelays(anycastFlows));
averageAnycastDelay = mean(roundTripDelays(anycastFlows));

fprintf('Anycast nodes = %d %d\n', anycastNodes);

sol = ones(1, nFlows);
[Loads, linkEnergy] = calculateLinkLoadEnergy(nNodes, Links, T, sP, sol, L, 100);

worstLinkLoad = max(max(Loads(:, 3:4)));

fprintf('Worst link load = %.2f Gbps\n', worstLinkLoad);

for i = 1:size(Loads, 1)
    fprintf('{%d-%d}: %.2f %.2f\n', Loads(i, 1), Loads(i, 2), Loads(i, 3), Loads(i, 4));
end
