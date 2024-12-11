%% Task 2a
clear all
close all
clc

% Load project data
load('InputDataProject2.mat');

% Declare global capacity
global capacity;
capacity = 100; % Default link capacity (Gbps)

% Parameters
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
anycastNodes = [3 10]; % Anycast nodes for this task
k = 6; % Number of candidate paths
timeLimit = 30; % Time limit in seconds

% Compute k-shortest paths for unicast flows
sP_uni = cell(1, nFlows); % sP{f}{i} is the i-th path of flow f
nSP = zeros(1, nFlows); % Number of paths for each flow
for f = 1:nFlows
    if T(f, 3) > 0 % Unicast flow
        [shortestPaths, ~] = kShortestPath(L, T(f, 2), T(f, 3), k);
        sP_uni{f} = shortestPaths;
        nSP(f) = length(shortestPaths);
    end
end

% Compute best paths for anycast flows
sP_any = cell(1, nFlows); % Candidate paths for anycast flows
for f = 1:nFlows
    if T(f, 3) == 0 % Anycast flow
        [pathsToNode1, ~] = kShortestPath(L, T(f, 2), anycastNodes(1), k);
        [pathsToNode2, ~] = kShortestPath(L, T(f, 2), anycastNodes(2), k);
        % Select the shortest path to either anycast node
        if ~isempty(pathsToNode1) && ~isempty(pathsToNode2)
            delayNode1 = sum(L(sub2ind(size(L), pathsToNode1{1}(1:end-1), pathsToNode1{1}(2:end))));
            delayNode2 = sum(L(sub2ind(size(L), pathsToNode2{1}(1:end-1), pathsToNode2{1}(2:end))));
            if delayNode1 < delayNode2
                sP_any{f} = pathsToNode1;
            else
                sP_any{f} = pathsToNode2;
            end
        elseif ~isempty(pathsToNode1)
            sP_any{f} = pathsToNode1;
        elseif ~isempty(pathsToNode2)
            sP_any{f} = pathsToNode2;
        else
            sP_any{f} = {}; % No valid paths
        end
        nSP(f) = length(sP_any{f});
    end
end

% Combine paths for unicast and anycast flows
sP = sP_uni; % Copy unicast paths initially
for f = 1:nFlows
    if T(f, 3) == 0 % Replace with anycast paths
        sP{f} = sP_any{f};
    end
end

% Multi Start Hill Climbing
t = tic;
bestLoad = inf;
bestEnergy = inf;
numSolutions = 0;
cycles = 0;

while toc(t) < timeLimit
    % Greedy Randomized Initial Solution
    [sol, startLoads, startMaxLoad, startLinkEnergy] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP, L);

    % Refine solution with Hill Climbing
    [sol, Loads, maxLoad, linkEnergy] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, startLoads, startLinkEnergy, L);

    % Calculate total energy (link + node)
    nodeEnergy = calculateNodeEnergy(T, sP, nNodes, 500, sol); % Node capacity fixed at 500Gbps
    energy = linkEnergy + nodeEnergy;

    % Update best solution
    if energy < bestEnergy
        bestSol = sol;
        bestLoad = maxLoad;
        bestLoads = Loads;
        bestEnergy = energy;
        bestLoadTime = toc(t);
    end

    numSolutions = numSolutions + 1;
    cycles = cycles + 1;
end

% Calculate average max load
averageMaxLoad = mean(bestLoads(:, 4)); % Assuming column 4 holds the max load values

% Print results
fprintf('Multi start hill climbing with greedy randomized, anycast in nodes %d and %d:\n', anycastNodes(1), anycastNodes(2));
fprintf('W = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', bestLoad, numSolutions, averageMaxLoad, toc(t));
fprintf('Best solution found at %.2f sec after %d cycles.\n', bestLoadTime, cycles);
