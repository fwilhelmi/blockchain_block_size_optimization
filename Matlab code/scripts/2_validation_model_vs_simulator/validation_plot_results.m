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

% Set simulation parameters
queue_length = 10;    % number of transactions that fit the queue
T_WAIT = [1 5 100];         % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
lambda = [0.25 5.0];         % arrivals rate (UE requests)
mu = [0.1 0.25];

% Enable/disable plots and logs
PLOTS_ENABLED = 0;
LOGS_ENABLED = 0;

%%
disp('No Forks')
FORKS_ENABLED = 0; % Enable/disable Forks

% - Load model results (generated with file "optimal_generate_model_results")
load('queue_delay')

% - Load sim. output
validation_process_simulator_output

% - Plots
figure
leg = {};
n = 1;
c = 1;
colors = {'b','r','g','k'};
subplot(1,3,1)
for t = 1 : 1%length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)
            plot(mean_delay{t,m}(l, :), [colors{c} '--'], 'linewidth', 1.0)            
            hold on
            plot(queue_delay{t,m}(l, :), [colors{c} 's'], 'linewidth', 1.0, 'markersize', 10)
            leg{n} = ['SIM: \mu = ' num2str(mu(m)) ', \lambda = ' num2str(lambda(l))];
            leg{n+1} = ['MODEL: \mu = ' num2str(mu(m)) ', \lambda = ' num2str(lambda(l))];
            n = n + 2;
            c = c + 1;
        end
    end
    xlabel('b (# of transactions)')
    ylabel('Queue delay (s)')
end
grid on 
grid minor
set(gca, 'fontsize', 14)
title(['T_{w} = ' num2str(T_WAIT(t))])
subplot(1,3,2)
c = 1;
for t = 2 : 2%length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)
            plot(mean_delay{t,m}(l, :), [colors{c} '--'], 'linewidth', 1.0)
            hold on
            plot(queue_delay{t,m}(l, :), [colors{c} 's'], 'linewidth', 1.0, 'markersize', 10)
            c = c + 1;
        end
    end
    xlabel('b (# of transactions)')
    ylabel('Queue delay (s)')
end
grid on 
grid minor
title(['T_{w} = ' num2str(T_WAIT(t))])
set(gca, 'fontsize', 14)
subplot(1,3,3)
c = 1;
for t = 3 : 3%length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)
            plot(mean_delay{t,m}(l, :), [colors{c} '--'], 'linewidth', 1.0)
            hold on
            plot(queue_delay{t,m}(l, :), [colors{c} 's'], 'linewidth', 1.0, 'markersize', 10)
            c = c + 1;
        end
    end
end
xlabel('b (# of transactions)')
ylabel('Queue delay (s)')
grid on 
grid minor
title(['T_{w} = ' num2str(T_WAIT(t))])
set(gca, 'fontsize', 14)
legend(leg)


%% SAME WITH FORKS!

disp('Forks')
FORKS_ENABLED = 1; % Enable/disable Forks
M = 10;

% - Load model results (generated with file "2_validation_generate_results")
load('queue_delay_forks')

% - Load sim. output
validation_process_simulator_output

% - Plots
figure
leg = {};
n = 1;
c = 1;
colors = {'b','r','g','k'};
subplot(1,3,1)
for t = 1 : 1%length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)
            plot(mean_delay{t,m}(l, :), [colors{c} '--'], 'linewidth', 1.0)            
            hold on
            plot(queue_delay{t,m}(l, :), [colors{c} 's'], 'linewidth', 1.0, 'markersize', 10)
            leg{n} = ['SIM: \mu = ' num2str(mu(m)) ', \lambda = ' num2str(lambda(l))];
            leg{n+1} = ['MODEL: \mu = ' num2str(mu(m)) ', \lambda = ' num2str(lambda(l))];
            n = n + 2;
            c = c + 1;
        end
    end
end
xlabel('b (# of transactions)')
    ylabel('Queue delay (s)')
grid on 
grid minor
set(gca, 'fontsize', 14)
title(['T_{w} = ' num2str(T_WAIT(t))])
subplot(1,3,2)
c = 1;
for t = 2 : 2%length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)
            plot(mean_delay{t,m}(l, :), [colors{c} '--'], 'linewidth', 1.0)
            hold on
            plot(queue_delay{t,m}(l, :), [colors{c} 's'], 'linewidth', 1.0, 'markersize', 10)
            c = c + 1;
        end
    end
end
xlabel('b (# of transactions)')
ylabel('Queue delay (s)')
grid on 
grid minor
title(['T_{w} = ' num2str(T_WAIT(t))])
set(gca, 'fontsize', 14)
subplot(1,3,3)
c = 1;
for t = 3 : 3%length(T_WAIT)
    for m = 1 : length(mu)
        for l = 1 : length(lambda)
            plot(mean_delay{t,m}(l, :), [colors{c} '--'], 'linewidth', 1.0)
            hold on
            plot(queue_delay{t,m}(l, :), [colors{c} 's'], 'linewidth', 1.0, 'markersize', 10)
            c = c + 1;
        end
    end
end
xlabel('b (# of transactions)')
    ylabel('Queue delay (s)')
grid on 
grid minor
title(['T_{w} = ' num2str(T_WAIT(t))])
set(gca, 'fontsize', 14)
legend(leg)



% ...