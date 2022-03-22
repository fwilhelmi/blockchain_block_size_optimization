%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: Francesc Wilhelmi (fwilhelmi@cttc.cat) & Paolo Dini           *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used to test the batch service queue model. 
% Customizable inputs can be provided for specific cases.

close all
clear all
clc

constants
conf_environment

% Enable/disable plots and logs
PLOTS_ENABLED = 0;
LOGS_ENABLED = 0;

% Set simulation parameters
FORKS_ENABLED = 1;                  % Enable/disable Forks
queue_length = 10;                  % Total queue size
T_WAIT = [0.1 1 5 10 100];          % Timeout in seconds for generating a block
block_size = 1:10;                  % Block size in number of transactions
mu = [0.1 0.25 0.5 1 2.5 5 10];     % Arrivals rate (transactions per second)
lambda = [0.1 0.25 0.5 1 2.5 5 10]; % Mining capacity (Hz)
C = 5e6;

%% Model
queue_delay = {};
queue_length_model = {};
drop_prob = {};
% Compute the queuing delay with the model
for t = 1 : length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)  
            for s = 1 : length(block_size)
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
                    n_forks = ones(1,queue_length+1);
                    p_fork_model{t,m}(l,:) = zeros(1,queue_length+1);
                    M = 1;
                end
                % Call model function with input parameters
                [queue_delay{t,m}(l,s), ...
                    queue_length_model{t,m}(l,s), ...
                    drop_prob{t,m}(l,s)] = ...
                    queue_model_function(mu(m), lambda(l)*M, queue_length, ...
                    block_size(s), T_WAIT(t), n_forks, LOGS_ENABLED);
            end
        end
    end
end
%%
if FORKS_ENABLED
    save(['delay_optimal_forks_' num2str(T_WAIT)],'queue_delay')
    save(['queue_optimal_forks_' num2str(T_WAIT)],'queue_length_model')
    save(['drop_optimal_forks_' num2str(T_WAIT)],'drop_prob')
    save(['p_fork_optimal_forks_' num2str(T_WAIT)],'p_fork_model')
else
    save(['delay_optimal_' num2str(T_WAIT)],'queue_delay')
    save(['queue_optimal_' num2str(T_WAIT)],'queue_length_model')
    save(['drop_optimal_' num2str(T_WAIT)],'drop_prob')
    save(['p_fork_optimal_' num2str(T_WAIT)],'p_fork_model')
end
