%% Exercise 2.a.

clear all
close all
clc

% carregar dados necessários
load('InputDataProject2.mat');

% parâmetros principais
v = 2e5; % velocidade da luz em fibras óticas
D = L / v; % matriz de atraso de propagação
nNodes = size(Nodes, 1); % número de nós na rede
capacity = 100; % capacidade do link em Gbps
anycastNodes = [3, 10]; % nós anycast
nFlows = size(T, 1); % número de fluxos
kPaths = 6; % número de caminhos candidatos
timeLimit = 30; % tempo limite (em segundos)

% inicializar métricas de desempenho
worstLoads = [];
solutions = [];
bestWorstLoad = inf;
bestSolution = [];
bestTime = 0;
cycles = 0;

% iniciar cronómetro
startTime = tic;

% ciclo principal do Multi-Start Hill Climbing
while toc(startTime) < timeLimit
    % gerar solução inicial aleatória (Greedy Randomized)
    solution = ones(1, nFlows); % inicializa com caminho 1 para todos os fluxos
    sP = cell(1, nFlows); % caminhos candidatos
    for f = 1:nFlows
        if T(f, 1) == 1 || T(f, 1) == 2 % fluxos unicast
            % obter k caminhos mais curtos
            [paths, ~] = kShortestPath(D, T(f, 2), T(f, 3), kPaths);
            sP{f} = paths; % guardar caminhos candidatos
        elseif T(f, 1) == 3 % fluxos anycast
            bestPaths = [];
            for node = anycastNodes
                [paths, ~] = kShortestPath(D, T(f, 2), node, kPaths);
                bestPaths = [bestPaths, paths]; % acumula caminhos para os nós anycast
            end
            sP{f} = bestPaths; % guardar caminhos candidatos
        end
    end

    % busca local (Hill Climbing)
    improved = true;
    while improved
        improved = false;
        [currentLoads, ~] = calculateLinkLoadEnergy(nNodes, Links, T, sP, solution, L, capacity);
        currentWorstLoad = max(max(currentLoads(:, 3:4))); % calcular pior carga de link
        for f = 1:nFlows
            if ~isempty(sP{f}) % garantir que há caminhos disponíveis
                for newChoice = 1:length(sP{f})
                    newSolution = solution;
                    newSolution(f) = newChoice; % tenta alterar a escolha do caminho
                    [newLoads, ~] = calculateLinkLoadEnergy(nNodes, Links, T, sP, newSolution, L, capacity);
                    newWorstLoad = max(max(newLoads(:, 3:4)));
                    if newWorstLoad < currentWorstLoad
                        solution = newSolution;
                        currentWorstLoad = newWorstLoad;
                        improved = true;
                    end
                end
            end
        end
    end

    % atualizar métricas
    cycles = cycles + 1; % contador de ciclos
    worstLoads = [worstLoads, currentWorstLoad]; % guardar pior carga de link
    solutions = [solutions; solution]; % guardar soluções

    % verificar se a nova solução é a melhor até agora
    if currentWorstLoad < bestWorstLoad
        bestWorstLoad = currentWorstLoad;
        bestSolution = solution;
        bestTime = toc(startTime);
    end
end

% calcular métricas finais
executionTime = toc(startTime);
averageWorstLoad = mean(worstLoads); % carga média de pior caso

% apresentar resultados
fprintf('Multi start hill climbing with greedy randomized, anycast in nodes %d and %d:\n', anycastNodes);
fprintf('W = %.2f Gbps, No. sol = %d, Av. W = %.2f, time = %.2f sec\n', bestWorstLoad, cycles, averageWorstLoad, executionTime);
fprintf('Best solution found at %.2f sec\n', bestTime);
