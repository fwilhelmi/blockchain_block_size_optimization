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
T_WAIT = 100;         % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
queue_length = 10;    % number of transactions that fit the queue
mu = [.1 1 2.5 5];         % arrivals rate (UE requests)
lambda = [0.1 0.15 0.2 0.25];

%% Model
for i = 1 : length(mu)
    for j = 1 : length(lambda)
        [queue_delay{i}(j,:), queue_length_model{i}(j,:)] = queue_model_function(mu(i), lambda(j), ...
            queue_length, block_size, T_WAIT, ones(1,length(block_size)), LOGS_ENABLED);
    end
end
save('queue_delay','queue_delay')