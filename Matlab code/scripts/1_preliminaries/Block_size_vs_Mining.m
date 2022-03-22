%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: F. Wilhelmi (fwilhelmi@cttc.cat), S. Barrachina & P. Dini     *
%%% * Copyright (C) 2022-2027, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/blockchain_optimization    *
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

% Enable/disable Forks
FORKS_ENABLED = 0;

% Set simulation parameters
T_WAIT = 1;         % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
queue_length = 10;    % number of transactions that fit the queue
lambda = 2.5;         % arrivals rate (UE requests)
mu = [0.1 0.15 0.2 0.25];

% Execute the model for each input parameter
for i = 1 : length(mu)
    [queue_delay(i,:), queue_length_model(i,:)] = queue_model_function(lambda, mu(i), ...
        queue_length, block_size, T_WAIT, ones(1, queue_length+1), LOGS_ENABLED);
end

% Plot a figure with the results
figure 
plot(queue_delay','linewidth',1.5)
xlabel('Block size (# trans.)')
ylabel('Queue delay (s)')
grid on
grid minor
legend({'\lambda = 0.1','\lambda = 0.15','\lambda = 0.2','\lambda = 0.25'})
set(gca,'fontsize',14)

% %%
% fontSize = 16;
% for i = 1 : 1%length(mu)
% % Generate the sample data.
% X=block_size;
% Y=queue_delay(i,:);
% % Find the coefficients.
% coeffs = polyfit(X, Y, 2)
% plot(X, Y, 'ro', 'MarkerSize', 10);
% % Make a finer sampling so we can see what it
% % does in between the training points.
% interpolatedX = linspace(min(X), max(X), 500);
% interpolatedY = polyval(coeffs, interpolatedX);
% % Plot the interpolated points.
% hold on;
% plot(interpolatedX, interpolatedY, 'LineWidth', 2);
% end
% grid on;
% title('Interpolating Polynomial', 'FontSize', fontSize);
% xlabel('X', 'FontSize', fontSize);
% ylabel('Y', 'FontSize', fontSize);
% % Enlarge figure to full screen.
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% Get the min queue delay
[val, ix] = min(queue_delay');