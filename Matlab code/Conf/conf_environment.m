%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

%%% File description: script for storing the configuration of the deployment

% Deployment characteristics
nRings = 2;     % Number of rings in the deployment (max=2)
R = 10;         % Cell radius

% Planning mode for allocating resources to BSs
%   * WIFI_SINGLE_CHANNEL_RANDOM = 1;
%   * WIFI_SINGLE_CHANNEL_ALL_SAME = 2;
PLANNING_MODE = 1; 

% Generic PHY modeling constants
PATH_LOSS_MODEL = 1;                % Path loss model index
NUM_CHANNELS_SYSTEM = 1;            % Maximum allowed number of channels for a single transmission
INTERFERENCE_MODE = 1;              % 0-Real, 1-Worst-case

% Blockchain
TRANSACTION_LENGTH = 5000;  % Length of a transaction in bits
HEADER_LENGTH = 20000;          % Length of a transaction in bits
%MINING_RATE = 0.2;

save('./tmp/conf_environment.mat');              % Save constants into the current folder