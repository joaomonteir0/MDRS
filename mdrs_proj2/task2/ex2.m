%% 2.a.

clear
clc

fprintf('---------------- 2.a. ----------------\n');

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

% Inicializar variáveis para armazenar os melhores resultados
bestLoad = inf;
bestSol = [];
bestLoads = [];
bestLoadTime = 0;
bestCycle = 0;
contador = 0;
somador = 0;

% Calcular os caminhos mais curtos para cada fluxo unicast
k = 6;
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
    elseif T(f, 1) == 3
        sP{f} = {};
        nSP(f) = 0;
    end
end

% Multi Start Hill Climbing com soluções iniciais Greedy Randomized
t = tic;
timeLimit = 30;
while toc(t) < timeLimit
    % Solução inicial Greedy Randomized
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);

    % Hill Climbing
    [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);

    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoads = calculateLinkLoads(nNodes, Links, T, sP, bestSol);
        bestLoadTime = toc(t);
        bestCycle = contador;
    end
    contador = contador + 1;
    somador = somador + load;
end

% Calcular os atrasos de ida e volta
delays = zeros(nFlows, 1);
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        delays(n) = sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end))));
    elseif T(n, 1) == 3
        if ismember(T(n, 2), anycastNodes)
            delays(n) = 0;
        else
            cost = inf;
            for k = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(n, 2), k, 1);
                if totalCost < cost
                    cost = totalCost;
                end
            end
            delays(n) = cost;
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

% Exibir os resultados no formato solicitado
fprintf('Multi start hill climbing with greedy randomized, anycast in nodes %d and %d: \nW = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', anycastNodes(1), anycastNodes(2), bestLoad, contador, somador/contador, bestLoadTime);

%% 2.b.

clear
fprintf('---------------- 2.b. ----------------\n');

% Carregar os dados de entrada
load('InputDataProject2.mat');

% Definir os parâmetros
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);

v = 2 * 10^5; % velocidade da luz em km/s
D = L / v; % matriz de atrasos de propagação

% Definir os nós anycast
anycastNodes = [1 6];

% Inicializar variáveis para armazenar os melhores resultados
bestLoad = inf;
bestSol = [];
bestLoads = [];
bestLoadTime = 0;
bestCycle = 0;
contador = 0;
somador = 0;

% Calcular os caminhos mais curtos para cada fluxo unicast
k = 6;
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
    elseif T(f, 1) == 3
        sP{f} = {};
        nSP(f) = 0;
    end
end

% Multi Start Hill Climbing com soluções iniciais Greedy Randomized
t = tic;
timeLimit = 30;
while toc(t) < timeLimit
    % Solução inicial Greedy Randomized
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);

    % Hill Climbing
    [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);

    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoads = calculateLinkLoads(nNodes, Links, T, sP, bestSol);
        bestLoadTime = toc(t);
        bestCycle = contador;
    end
    contador = contador + 1;
    somador = somador + load;
end

% Calcular os atrasos de ida e volta
delays = zeros(nFlows, 1);
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        delays(n) = sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end))));
    elseif T(n, 1) == 3
        if ismember(T(n, 2), anycastNodes)
            delays(n) = 0;
        else
            cost = inf;
            for k = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(n, 2), k, 1);
                if totalCost < cost
                    cost = totalCost;
                end
            end
            delays(n) = cost;
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

% Exibir os resultados no formato solicitado
fprintf('Multi start hill climbing with greedy randomized, anycast in nodes %d and %d: \nW = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', anycastNodes(1), anycastNodes(2), bestLoad, contador, somador/contador, bestLoadTime);

%% 2.c.

clear
fprintf('---------------- 2.c. ----------------\n');

% Carregar os dados de entrada
load('InputDataProject2.mat');

% Definir os parâmetros
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);

v = 2 * 10^5; % velocidade da luz em km/s
D = L / v; % matriz de atrasos de propagação

% Definir os nós anycast
anycastNodes = [4 12];

% Inicializar variáveis para armazenar os melhores resultados
bestLoad = inf;
bestSol = [];
bestLoads = [];
bestLoadTime = 0;
bestCycle = 0;
contador = 0;
somador = 0;

% Calcular os caminhos mais curtos para cada fluxo unicast
k = 6;
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
    elseif T(f, 1) == 3
        sP{f} = {};
        nSP(f) = 0;
    end
end

% Multi Start Hill Climbing com soluções iniciais Greedy Randomized
t = tic;
timeLimit = 30;
while toc(t) < timeLimit
    % Solução inicial Greedy Randomized
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);

    % Hill Climbing
    [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);

    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoads = calculateLinkLoads(nNodes, Links, T, sP, bestSol);
        bestLoadTime = toc(t);
        bestCycle = contador;
    end
    contador = contador + 1;
    somador = somador + load;
end

% Calcular os atrasos de ida e volta
delays = zeros(nFlows, 1);
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        delays(n) = sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end))));
    elseif T(n, 1) == 3
        if ismember(T(n, 2), anycastNodes)
            delays(n) = 0;
        else
            cost = inf;
            for k = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(n, 2), k, 1);
                if totalCost < cost
                    cost = totalCost;
                end
            end
            delays(n) = cost;
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

% Exibir os resultados no formato solicitado
fprintf('Multi start hill climbing with greedy randomized, anycast in nodes %d and %d: \nW = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', anycastNodes(1), anycastNodes(2), bestLoad, contador, somador/contador, bestLoadTime);

%% 2.d.

clear
fprintf('---------------- 2.d. ----------------\n');

% Carregar os dados de entrada
load('InputDataProject2.mat');

% Definir os parâmetros
nNodes = size(Nodes, 1);
nFlows = size(T, 1);
nLinks = size(Links, 1);

v = 2 * 10^5; % velocidade da luz em km/s
D = L / v; % matriz de atrasos de propagação

% Definir os nós anycast
anycastNodes = [5 14];

% Inicializar variáveis para armazenar os melhores resultados
bestLoad = inf;
bestSol = [];
bestLoads = [];
bestLoadTime = 0;
bestCycle = 0;
contador = 0;
somador = 0;

% Calcular os caminhos mais curtos para cada fluxo unicast
k = 6;
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);
for f = 1:nFlows
    if T(f, 1) == 1 || T(f, 1) == 2
        [shortestPath, totalCost] = kShortestPath(D, T(f, 2), T(f, 3), k);
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
    elseif T(f, 1) == 3
        sP{f} = {};
        nSP(f) = 0;
    end
end

% Multi Start Hill Climbing com soluções iniciais Greedy Randomized
t = tic;
timeLimit = 30;
while toc(t) < timeLimit
    % Solução inicial Greedy Randomized
    [sol, load] = greedyRandomizedStrategy(nNodes, Links, T, sP, nSP);

    % Hill Climbing
    [sol, load] = HillClimbingStrategy(nNodes, Links, T, sP, nSP, sol, load);

    if load < bestLoad
        bestSol = sol;
        bestLoad = load;
        bestLoads = calculateLinkLoads(nNodes, Links, T, sP, bestSol);
        bestLoadTime = toc(t);
        bestCycle = contador;
    end
    contador = contador + 1;
    somador = somador + load;
end

% Calcular os atrasos de ida e volta
delays = zeros(nFlows, 1);
for n = 1:nFlows
    if T(n, 1) == 1 || T(n, 1) == 2
        delays(n) = sum(D(sub2ind(size(D), sP{n}{bestSol(n)}(1:end-1), sP{n}{bestSol(n)}(2:end))));
    elseif T(n, 1) == 3
        if ismember(T(n, 2), anycastNodes)
            delays(n) = 0;
        else
            cost = inf;
            for k = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(n, 2), k, 1);
                if totalCost < cost
                    cost = totalCost;
                end
            end
            delays(n) = cost;
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

% Exibir os resultados no formato solicitado
fprintf('Multi start hill climbing with greedy randomized, anycast in nodes %d and %d: \nW = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', anycastNodes(1), anycastNodes(2), bestLoad, contador, somador/contador, bestLoadTime);
