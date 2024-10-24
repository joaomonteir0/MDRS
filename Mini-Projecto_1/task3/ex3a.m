% Parameters
lambda = 1500;  % pps (packets/sec)
C = 10;        % Link bandwidth (Mbps)
f = 10000;     % Queue size (Bytes)
P = 100000;    % Stop criterium (number of packets)
nVoIPs = [10, 20, 30, 40];  % VoIP flows
N = 20;        % numero de simulações
alpha = 0.1;   % for 90% confidence interval

% Results arrays
PLdata_results = zeros(N, length(nVoIPs));
PLVoIP_results = zeros(N, length(nVoIPs));
APDdata_results = zeros(N, length(nVoIPs));
APDVoIP_results = zeros(N, length(nVoIPs));

% Simulation
for i = 1:length(nVoIPs)
    for j = 1:N
        % Run Sim3 for each VoIP flow
        [PLdata_results(j,i), PLVoIP_results(j,i), APDdata_results(j,i), APDVoIP_results(j,i)] = ...
            Sim3(lambda, C, f, P, nVoIPs(i));
    end
end

% Calculate mean and confidence intervals
mean_PLdata = mean(PLdata_results);
mean_PLVoIP = mean(PLVoIP_results);
mean_APDdata = mean(APDdata_results);
mean_APDVoIP = mean(APDVoIP_results);

ci_PLdata = norminv(1-alpha/2) * sqrt(var(PLdata_results) / N);
ci_PLVoIP = norminv(1-alpha/2) * sqrt(var(PLVoIP_results) / N);
ci_APDdata = norminv(1-alpha/2) * sqrt(var(APDdata_results) / N);
ci_APDVoIP = norminv(1-alpha/2) * sqrt(var(APDVoIP_results) / N);

% Plot Average Packet Delay
figure;
hold on; grid on;
bar(nVoIPs, [mean_APDdata; mean_APDVoIP]');
errorbar(nVoIPs, mean_APDdata, ci_APDdata, 'k.', 'linestyle', 'none');
errorbar(nVoIPs, mean_APDVoIP, ci_APDVoIP, 'k.', 'linestyle', 'none');
xlabel('Number of VoIP Flows');
ylabel('Average Packet Delay (ms)');
title('Average Packet Delay for Data and VoIP');
legend('Data', 'VoIP');
hold off;

% Plot Packet Loss
figure;
hold on; grid on;
bar(nVoIPs, [mean_PLdata; mean_PLVoIP]');
errorbar(nVoIPs, mean_PLdata, ci_PLdata, 'k.', 'linestyle', 'none');
errorbar(nVoIPs, mean_PLVoIP, ci_PLVoIP, 'k.', 'linestyle', 'none');
xlabel('Number of VoIP Flows');
ylabel('Packet Loss (%)');
title('Packet Loss for Data and VoIP');
legend('Data', 'VoIP');
hold off;
