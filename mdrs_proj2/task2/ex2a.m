%% 2.a.

clear
clc

% Load input data
load('InputDataProject2.mat');

% Define parameters
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);
k = 6; % Number of candidate paths
maxTime = 30; % Max execution time in seconds
anycastNodes = [3 10];

v = 2 * 10^5; % Speed of light in km/s
D = L / v; % Propagation delay matrix

% Generate candidate paths for each unicast flow
sP = cell(1, nFlows); % Cell array to hold paths
nSP = zeros(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2 % Only for unicast flows
        [shortestPaths, totalCosts] = kShortestPath(D, T(f, 2), T(f, 3), k);
        if ~isempty(shortestPaths)
            sP{f} = shortestPaths; % Assign paths to sP
            nSP(f) = length(totalCosts);
        else
            sP{f} = {{}}; % Assign empty nested cell array
            nSP(f) = 0;
        end
    end
end

% Multi-start hill climbing with greedy randomized strategy
t = tic;
bestLoad = inf;
contador = 0;
bestSol = []; % Initialize bestSol

while toc(t) < maxTime
    try
        % Greedy randomized strategy
        [sol, load, ~] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);
        
        % Hill climbing optimization
        [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);

        if load < bestLoad
            bestSol = sol; % Update best solution
            bestLoad = load;
            bestLoads = calculateLinkLoads(nNodes, Links, T, sP, sol);
            bestLoadTime = toc(t);
            bestCycle = contador;
        end
        contador = contador + 1;

    catch
        % Skip iteration if any error occurs
        continue;
    end
end

% Validate bestSol before proceeding
if isempty(bestSol)
    error('No valid solution found. Check input data or algorithm configurations.');
end

% Calculate round-trip delays
bestDelays = zeros(nFlows, 1);
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2 % Unicast flows
        if ~isempty(sP{n}) && ~isempty(sP{n}{bestSol(n)})
            bestDelays(n) = sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end))));
        end
    end
end

% Compute round-trip delays
unicastFlows = find(T(:, 1) == 1 | T(:, 1) == 2);

worstRoundTripDelayUnicast = max(bestDelays(unicastFlows)) * 2 * 1000;
averageRoundTripDelayUnicast = mean(bestDelays(unicastFlows)) * 2 * 1000;

% Display results
fprintf('Worst round-trip delay (unicast service): %.2f ms\n', worstRoundTripDelayUnicast);
fprintf('Average round-trip delay (unicast service): %.2f ms\n', averageRoundTripDelayUnicast);
fprintf('Worst link load: %.2f Gbps\n', bestLoad);
fprintf('Total number of cycles run: %d\n', contador);
fprintf('Running time at which the best solution was obtained: %.2f seconds\n', bestLoadTime);
fprintf('Number of cycles at which the best solution was obtained: %d\n', bestCycle);
