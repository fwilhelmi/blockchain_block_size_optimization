%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: F. Wilhelmi (fwilhelmi@cttc.cat), S. Barrachina & P. Dini     *
%%% * Copyright (C) 2022-2027, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/blockchain_optimization    *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used as an example to execute the batch service queue model. 
% Customizable inputs can be provided for specific cases.

close all
clear all
clc

% Load constants and simulation variables
constants
conf_environment

% Enable/disable plots and logs
PLOTS_ENABLED = 0;
LOGS_ENABLED = 1;

% Set simulation parameters
FORKS_ENABLED = 1;  % Enable/disable Forks
queue_length = 10;  % Total queue size (# of packets)
T_WAIT = [1];       % Timeout for generating a block (seconds)
block_size = 5;     % Block size (number of transactions)
mu = [0.1];         % Arrivals rate (transactions per second)
lambda = [5];       % Mining capacity (Hz)
C = 5e6;            % Capacity miners' links (bps)

%% Model
p_fork_model = {};
queue_delay_forks = {};
queue_length_model_forks = {};
drop_prob_forks = {};
% Compute the queuing delay with the model
for t = 1 : length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)   
            % Compute fork prob. (if necessary)
            if FORKS_ENABLED
                M = 10;
                p_fork_model{t,m} = zeros(1,queue_length+1);
                for b = 0 : block_size              
                    block_size_bits = (b*TRANSACTION_LENGTH) + HEADER_LENGTH; % STATIC CASE (max block size)
                    T_prop = block_size_bits/C;
                    p_fork_model{t,m}(l,b+1) = compute_fork_probability(T_prop, lambda(l), M);                  
                end
                p_fork_model{t,m}(1,b+1:end) = p_fork_model{t,m}(1,b+1);
                n_forks = 1./(1-p_fork_model{t,m}(l,:));                
            else
                n_forks = ones(1,length(block_size));
                p_fork_model{t,m}(l,:) = zeros(1,length(block_size));
                M = 1;
            end
            % Call model function with input parameters
            [queue_delay_forks{t,m}(l,:), ...
                queue_length_model_forks{t,m}(l,:), ...
                drop_prob_forks{t,m}(l,:)] = ...
                queue_model_function(mu(m), lambda(l)*M, queue_length, ...
                block_size, T_WAIT(t), n_forks, LOGS_ENABLED);
        end
    end
end

% Display the results
disp('---------MODEL RESULTS-----------')
disp(' * Input: ')
disp(['   - T_WAIT = ' num2str(T_WAIT)])
disp(['   - block_size = ' num2str(block_size)])
disp(['   - mu (arrivals) = ' num2str(mu)])
disp(['   - lambda (mining cap.) = ' num2str(lambda)])
disp(['   - FORKS_ENABLED = ' num2str(FORKS_ENABLED)])
disp(' ')
disp(' * Output: ')
disp(['   - Queue delay = ' num2str(queue_delay_forks{1})])
disp(['   - Drop prob. = ' num2str(drop_prob_forks{1})])    
disp(['   - Fork prob. = ' num2str(p_fork_model{1})]) 