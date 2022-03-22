%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

%%% File description: method to compute the fork probability based on the
%%% propagation delay (T_prop), the arrivals rate (lambda) and the number
%%% of concurrent miners (N)

function p_fork = compute_fork_probability(T_prop, lambda, M)

    % Fork probability
    p_fork = 1-exp(-lambda.*T_prop.*(M-1));

end