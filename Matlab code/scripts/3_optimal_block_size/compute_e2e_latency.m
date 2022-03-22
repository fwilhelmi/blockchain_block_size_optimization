%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: Francesc Wilhelmi (fwilhelmi@cttc.cat) & Paolo Dini           *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used to test the batch service queue model. 
% Customizable inputs can be provided for specific cases.

clc

constants
conf_environment

% Enable/disable plots and logs
PLOTS_ENABLED = 0;
LOGS_ENABLED = 0;

% Enable/disable Forks
FORKS_ENABLED = 0;

% Set simulation parameters
T_WAIT = 1;         % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
queue_length = 10;    % number of transactions that fit the queue
%mu = [.1 5];         % arrivals rate (UE requests)
%lambda = [0.1 0.2 0.25];
mu = [0.1 0.25];         % arrivals rate (UE requests)
lambda = [0.25 5];

%% Plots

C = 5e6; %bps
M = 10;

figure

% CASE 1: NO TIMER 
load('queue_delay_timer_1')
subplot(1,2,1)
l = cell(length(mu)*length(lambda),1) ;
n = 1;
block_size_bits = (block_size*TRANSACTION_LENGTH + HEADER_LENGTH);
val = [];
ix = [];
for i = 1 : length(mu)
    for j = 1 : length(lambda)
        % Compute T_BC
        p_fork = 1 - exp(-lambda(j)*(M-1).*(block_size_bits/C));
        T_BC = ( queue_delay{i}(j,:) + 1/(M*lambda(j)) + block_size_bits/C ) ./ (1 - p_fork) ;
        % Compute the best theoretical block size val.
        p = polyfit(block_size,queue_delay{i}(j,:)',9); % Equivalent to Lagrangian interpolation    
        estimated_queue_delay = sum((p.*[block_size.^9' block_size.^8' ...
            block_size.^7' block_size.^6' block_size.^5' ...
            block_size.^4' block_size.^3' block_size.^2' block_size' ones(10,1)])');
        T_BC_estimated = ( estimated_queue_delay + 1/(M*lambda(j)) + block_size_bits/C ) ./ ...
            (1 - p_fork) ;
        [val(n), ix(n)] = min(T_BC_estimated);
        % Plots
        %yyaxis left
        if i == 1
            plot(1:10, T_BC, '--', 'linewidth', 1.0)
        else 
           plot(1:10, T_BC, 'linewidth', 1.0)
        end
        hold on
        %plot(ix, val,'x','markersize', 10)
        l{n} = ['\mu=' num2str(mu(i)) ', \lambda=' num2str(lambda(j))];
        n = n + 1;
    %     yyaxis right
    %     plot(1:10,p_fork,'r');
    end
end
plot(ix, val, 'o', 'markersize', 10, 'linewidth', 1.0)
title('T_w = 1')
%yyaxis left
%axis([1 10 0 1600])
xlabel('Block size (# trans.)')
ylabel('E2E delay (s)')
%yyaxis right
%ylabel('p_{fork}')
grid on
grid minor
legend(l)
set(gca,'fontsize',14)
hold off

% CASE 2: TIMER = 1 s
load('queue_delay_timer_100')
subplot(1,2,2)
l = cell(length(mu)*length(lambda),1) ;
n = 1;
block_size_bits = (block_size*TRANSACTION_LENGTH + HEADER_LENGTH);
for i = 1 : length(mu)
    for j = 1 : length(lambda)
        % Compute T_BC
        p_fork = 1 - exp(-lambda(j)*(M-1).*(block_size_bits*log(M)/(C)));
        T_BC = ( queue_delay{i}(j,:) + 1/(M*lambda(j)) + block_size_bits*log(M)/(C) ) ./ ...
            (1 - p_fork) ;      
        % Plots
        %yyaxis left
        if i == 1
            plot(1:10, T_BC, '--', 'linewidth', 1.0)
        else 
           plot(1:10, T_BC, 'linewidth', 1.0)
        end
        val(n) = T_BC(ix(n));
        hold on
        %plot(ix, val,'x','markersize', 10)
        l{n} = ['\mu=' num2str(mu(i)) ', \lambda=' num2str(lambda(j))];
        n = n + 1;
    %     yyaxis right
    %     plot(1:10,p_fork,'r');
    end
end
plot(ix, val, 'o', 'markersize', 10, 'linewidth', 1.0)
title('T_w = 100')
%yyaxis left
%axis([1 10 0 1600])
xlabel('Block size (# trans.)')
ylabel('E2E delay (s)')
%yyaxis right
%ylabel('p_{fork}')
grid on
grid minor
legend(l)
set(gca,'fontsize',14)
hold off