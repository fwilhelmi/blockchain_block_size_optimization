%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: Francesc Wilhelmi (fwilhelmi@cttc.cat) & Paolo Dini           *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: This file computes the queue latency with the model

close all
clear all
clc

%% Load variables/parameters
constants
conf_environment
% Enable/disable plots and logs
PLOTS_ENABLED = 0;
LOGS_ENABLED = 0;
% Enable/disable Forks
FORKS_ENABLED = 0;
% Set simulation parameters
T_WAIT = 100;          % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
queue_length = 10;     % number of transactions that fit the queue
mu = 5;%[.1 1 2.5 5];  % arrivals rate (UE requests)
lambda = [0.1 0.15 0.2 0.25];

%% Load results from the queuing model
load('queue_delay')

%% Plots

C = 5e6; % P2P nodes capacity in bps
M = 100; % Number of P2P nodes (miners)

% Plot the queue delay obtained from the model
figure
l = cell(1*length(lambda),1); % legend object (to be filled)
n = 1; % aux variable for the legend
subplot(1,2,1)
for j = 1 : length(lambda)
    T_Q = queue_delay{1}(j,:);
    plot(1:10,T_Q)
    hold on
    % Legend
    l{n} = ['\mu=' num2str(mu(1)) ', \lambda=' num2str(lambda(j))];
    n = n + 1;
end
axis([1 10 0 1600])
xlabel('Block size (# trans.)')
ylabel('Queue delay (s)')
grid on
grid minor
legend(l)
set(gca,'fontsize',14)
hold off

% Plot the total E2E latency, including the theoretical block size
subplot(1,2,2)
block_size_bits = (block_size*TRANSACTION_LENGTH + HEADER_LENGTH);
% Approximate the model function (equivalent to Lagrange interpolation)
p = polyfit(block_size, T_Q', 9); 
% Estimate the queuing delay using "p"
estimated_queue_delay = sum((p.*[block_size.^9' block_size.^8' ...
    block_size.^7' block_size.^6' block_size.^5' ...
    block_size.^4' block_size.^3' block_size.^2' block_size' ones(10,1)])');
% Compute and plot the total latency
for j = 1 : length(lambda)
    p_fork = 1 - exp(-lambda(j)*(M-1).*(block_size_bits/C));
    % Model
    T_BC = ( queue_delay{1}(j,:) + 1/(M*lambda(j)) + block_size_bits/C ) ./ ...
        (1 - p_fork) ;
    % Estimated
    T_BC_estimated = ( estimated_queue_delay + 1/(M*lambda(j)) + block_size_bits/C ) ./ ...
        (1 - p_fork) ;
    [val, ix] = min(T_BC_estimated);
    yyaxis left
    plot(1:10,T_BC)
    plot(ix, val,'x','markersize', 10)
    hold on
    yyaxis right
    plot(1:10,p_fork,'r');
end
yyaxis left
axis([1 10 0 1600])
xlabel('Block size (# trans.)')
ylabel('E2E delay (s)')
yyaxis right
ylabel('p_{fork}')
grid on
grid minor
legend(l)
set(gca,'fontsize',14)
hold off