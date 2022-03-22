%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: Francesc Wilhelmi (fwilhelmi@cttc.cat) & Paolo Dini           *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used to test the batch service queue model. 
% Customizable inputs can be provided for specific cases.

clear all
clc

constants
conf_environment

% Set simulation parameters
queue_length = 10;              % Total queue size
T_WAIT = [0.1 1 5 10 100];               % Timeout in seconds for generating a block
block_size = 1:10;              % Block size in number of transactions
mu = [0.1 0.25 0.5 1 2.5 5 10];                % Arrivals rate (transactions per second)
lambda = [0.1 0.25 0.5 1 2.5 5 10];               % Mining capacity (Hz)
C = 5e6;

%% Plots

FORKS_ENABLED = 0; % Enable/disable Forks
% - Load model results (generated with file "2_validation_generate_results")
load('delay_optimal_01_1_5_10_100')
% - Load sim. output
optimization_process_simulator_output
M=1;

figure
% subplot(1,2,1)
for t = 1 : length(T_WAIT)
    l = cell(length(mu)*length(lambda),1) ;
    block_size_bits = (block_size*TRANSACTION_LENGTH + HEADER_LENGTH);
    val = [];
    ix = [];
    for i = 1 : length(mu)
        for j = 1 : length(lambda)
            % E2E delay (model) to find the estimated b*
            T_BC = ( queue_delay{t,i}(j,:) + 1/(M*lambda(j)) + block_size_bits/C );
            % Compute the best theoretical block size val.
            p = polyfit(block_size,queue_delay{t,i}(j,:)',9); % Equivalent to Lagrangian interpolation    
            estimated_queue_delay = sum((p.*[block_size.^9' block_size.^8' ...
                block_size.^7' block_size.^6' block_size.^5' ...
                block_size.^4' block_size.^3' block_size.^2' block_size' ones(10,1)])');
            T_BC_estimated = ( estimated_queue_delay + 1/(M*lambda(j)) + block_size_bits/C ) ;
            [val, ix] = min(T_BC_estimated);
            % E2E delay (simulations)
            T_sim = ( mean_delay{t,i}(j,:) + 1/(M*lambda(j)) + block_size_bits/C ) ;
            T_sim_2 = sort(T_sim);
            first_min = T_sim_2(1);
            diff{t}(i,j) = (T_sim(ix)-first_min) / T_sim(ix);
%             diff2{t}(i,j) = T_sim(ix)-second_min;
%             disp([' - optimal delay (model) = ' num2str(T_sim(ix))])
%             disp([' - optimal delay (sim) = ' num2str(first_min)])
%             disp(['    ---> difference = ' num2str(diff(i,j))])  
%             disp(['    ---> difference with second best = ' num2str(diff2(i,j))])  
        end
    end

    % b = bar(diff);
    % hold on
    % b2 = bar(diff2,'facealpha',0.1,'linestyle','--');
end

subplot(1,2,1)
boxplot([diff{1}(:) diff{2}(:) diff{3}(:) diff{4}(:) diff{5}(:)])
ylabel('E2E latency (s)')
xlabel('T_w')
xticks(1:length(T_WAIT))
xticklabels(T_WAIT)
set(gca,'fontsize',12)
grid on 
grid minor

results_no_forks = [mean(diff{1}(:)) mean(diff{2}(:)) mean(diff{3}(:)) mean(diff{4}(:)) mean(diff{5}(:))];
% bar([mean(diff{1}(:)) mean(diff{2}(:)) mean(diff{3}(:)) mean(diff{4}(:)) mean(diff{5}(:))])
% ylabel('E2E latency (s)')
% xlabel('T_w')
% xticks(1:length(T_WAIT))
% xticklabels(T_WAIT)
% set(gca,'fontsize',12)
% grid on 
% grid minor

% for t = 1 : length(T_WAIT)
%     cdfplot(diff{t}(:))
%     hold on
% end
% ylabel('E2E latency (s)')
% xlabel('T_w')
% set(gca,'fontsize',12)
% title('Without forks')
% grid on 
% grid minor


% - Load model results (generated with file "2_validation_generate_results")
load('delay_optimal_forks_01_1_5_10_100')
FORKS_ENABLED = 1; % Enable/disable Forks
M=10;
% - Load sim. output
optimization_process_simulator_output
% subplot(1,2,2)
for t = 1 : length(T_WAIT)
    l = cell(length(mu)*length(lambda),1) ;
    block_size_bits = (block_size*TRANSACTION_LENGTH + HEADER_LENGTH);
    val = [];
    ix = [];
    for i = 1 : length(mu)
        for j = 1 : length(lambda)
            % E2E delay (model) to find the estimated b*
            p_fork = 1 - exp(-lambda(j)*(M-1).*(block_size_bits/C));
            T_BC = ( queue_delay{t,i}(j,:) + 1/(M*lambda(j)) + block_size_bits/C ) ./ (1 - p_fork) ;
            % Compute the best theoretical block size val.
            p = polyfit(block_size,queue_delay{t,i}(j,:)',9); % Equivalent to Lagrangian interpolation    
            estimated_queue_delay = sum((p.*[block_size.^9' block_size.^8' ...
                block_size.^7' block_size.^6' block_size.^5' ...
                block_size.^4' block_size.^3' block_size.^2' block_size' ones(10,1)])');
            T_BC_estimated = ( estimated_queue_delay + 1/(M*lambda(j)) + block_size_bits/C ) ./ ...
                (1 - p_fork) ;
            [val, ix] = min(T_BC_estimated);
            % E2E delay (simulations)
            T_sim = ( mean_delay{t,i}(j,:) + 1/(M*lambda(j)) + block_size_bits/C ) ./ (1 - p_fork) ;
            T_sim_2 = sort(T_sim);
            first_min = T_sim_2(1);
            diff{t}(i,j) = (T_sim(ix)-first_min) / T_sim(ix);  
%             second_min = T_sim_2(2);
%             diff2 = abs(T_sim(ix)-second_min);   
%             relDiff2 = diff2 / T_sim(ix);
%             diff2{t}(i,j) = relDiff2;
        end
    end
    % b = bar(diff);
    % hold on
    % b2 = bar(diff2,'facealpha',0.1,'linestyle','--');
end

% boxplot([diff{1}(:) diff{2}(:) diff{3}(:) diff{4}(:) diff{5}(:)])
% ylabel('E2E latency (s)')
% xlabel('T_w')
% xticks(1:length(T_WAIT))
% xticklabels(T_WAIT)
% set(gca,'fontsize',12)
% grid on 
% grid minor

results_forks = [mean(diff{1}(:)) mean(diff{2}(:)) mean(diff{3}(:)) mean(diff{4}(:)) mean(diff{5}(:))];

subplot(1,2,2)
boxplot([diff{1}(:) diff{2}(:) diff{3}(:) diff{4}(:) diff{5}(:)])
ylabel('E2E latency (s)')
xlabel('T_w')
xticks(1:length(T_WAIT))
xticklabels(T_WAIT)
set(gca,'fontsize',12)
grid on 
grid minor

% for t = 1 : length(T_WAIT)
%     cdfplot(diff{t}(:))
%     hold on
% end
% ylabel('E2E latency (s)')
% xlabel('T_w')
% set(gca,'fontsize',12)
% title('Without forks')
% grid on 
% grid minor
