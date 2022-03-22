%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

function [total_delay, T_tr, T_p2p, T_queue, T_mine, T_prop, p_fork] = compute_model_delays(deployment, ...
    lambda, mu, block_size_fw, transaction_length, header_length, queue_length, T_wait, forks_enabled)

INTERFERENCE_MODE = 1;
[C_access,~] = ComputeThroughput(deployment, 1, INTERFERENCE_MODE);
[~,C_p2p] = ComputeThroughput(deployment, 2, INTERFERENCE_MODE);
n_hops = deployment.nAps / mean(sum(deployment.signalApAp>deployment.ccaThreshold));

% Compute delays BC operation
% - Delay STA-Miner
T_tr = (header_length + transaction_length) / mean(C_access);
% - Delay P2P
T_p2p = (header_length + transaction_length) / mean(C_p2p)*n_hops;
% - Propagation delay
T_prop = (header_length + block_size_fw*transaction_length)/mean(C_p2p) * n_hops;

if forks_enabled
    % Model Fork probability
    p_fork = compute_fork_probability(T_prop, mu, deployment.nAps);
    n_fork = 1./(1-p_fork);
    % - Mining delay
    T_mine = 1/(mu*deployment.nAps);
    % - Queue delay
    [T_queue, ~] = queue_model_function(lambda, mu*deployment.nAps,...
        queue_length, block_size_fw, T_wait, n_fork);
    % Total delay (with forks)
    total_delay = T_tr + T_p2p + (T_queue + T_mine + T_prop);
else
    % Model Fork probability
    p_fork = 0;
    n_fork = 1./(1-p_fork);
    % - Mining delay
    T_mine = 1/mu;
    % - Queue delay
    [T_queue, ~] = queue_model_function(lambda, mu, queue_length, ...
        block_size_fw, T_wait, n_fork);
    % Total delay (without forks)
    total_delay = T_tr + T_p2p + T_queue + T_mine + T_prop;
end