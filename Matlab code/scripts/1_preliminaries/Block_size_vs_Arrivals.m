%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: F. Wilhelmi (fwilhelmi@cttc.cat), S. Barrachina & P. Dini     *
%%% * Copyright (C) 2022-2027, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/blockchain_optimization    *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used to test the batch service queue model. 
% Customizable inputs can be provided for specific cases.

close all
clear all
clc

% Load constants and simulation variables
constants
conf_environment

% Enable/disable plots and logs
PLOTS_ENABLED = 0;
LOGS_ENABLED = 0;

% Set simulation parameters
FORKS_ENABLED = 0;              % Enable/disable Forks
T_WAIT = 100;                   % Timeout for generating a block (seconds)
block_size = 1:10;              % block size in number of transactions
queue_length = 10;              % Total queue size (# of packets)
mu = [.1 1 2.5 5];              % Arrivals rate (transactions per second)
lambda = [0.1 0.15 0.2 0.25];   % Mining capacity (Hz)

% Execute the model for each input parameter
for i = 1 : length(mu)
    for j = 1 : length(lambda)
        [queue_delay{i}(j,:), queue_length_model{i}(j,:)] = queue_model_function(mu(i), lambda(j), ...
            queue_length, block_size, T_WAIT, ones(1, queue_length+1), LOGS_ENABLED);
    end
end

% Plot a figure with the results
figure 
hold on
l = cell(1*length(lambda),1) ;
n = 1;
for i = 2 : 2%length(mu)
    for j = 1 : length(lambda)
        plot(queue_delay{i}(j,:)','linewidth',1.5)
        hold on
        X=block_size;
        Y=queue_delay{i}(j,:)';
        p=polyfit(X,Y,2);
        % Find the coefficients.
        interpolatedX = linspace(min(X), max(X), 500);
        interpolatedY = polyval(p, interpolatedX);
        % Plot the interpolated points.
        plot(interpolatedX, interpolatedY, '--', 'LineWidth', 2);
        % Legend
        l{n} = ['\mu=' num2str(mu(i)) ', \lambda=' num2str(lambda(j))];
        n = n + 1;
    end
end
xlabel('Block size (# trans.)')
ylabel('Queue delay (s)')
grid on
grid minor
legend(l)
set(gca,'fontsize',14)