%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

%%% File description: script to test the forking probability model
%%% (analysis vs simulation)

clear
close all
clc

% Parameters
N = 19;
lambda = 15;
t_prop = 0.001:0.001:0.04;

% Model
p_fork = compute_fork_probability(t_prop, lambda, N); %1 - exp(-lambda.*t_prop.*(N));

% Simulation
n = 10000;
sim_fork = zeros(1, length(t_prop));
for i = 1 : length(t_prop)
    for j = 1 : n
        delay = zeros(1,N);
        for k = 1 : N
            delay(k) = exprnd(1/lambda);
        end
        M=sort(delay);
        if M(2) - M(1) < t_prop(i)
            sim_fork(i) = sim_fork(i) + 1;
        end
    end
end
p_fork_sim = sim_fork./n;

% Plot comparing model vs simulation
plot(p_fork_sim,'x','linewidth',2.0)
hold on
plot(p_fork,'linewidth',2.0)
legend({'Sim','Model'})
xticks(1:10:length(t_prop))
xticklabels(t_prop(1:10:length(t_prop)))
xlabel('T_{prop}')
ylabel('Fork probability')
set(gca, 'fontsize', 16)
grid on
grid minor