clear ; close all; clc

%% Load Data
X = [];
y = [];
% Set simulation parameters
T_WAIT = 100;         % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
queue_length = 10;    % number of transactions that fit the queue
mu = [.1 5];         % arrivals rate (UE requests)
lambda = [.1 .25];
load('queue_delay')
for i = 1 : length(mu)
    for j = 1 : length(lambda)
        for s = 1 : length(block_size)
            X = [X; [mu(i) lambda(j) block_size(s)]];
            y = [y queue_delay{i}(j,s)];
        end
    end
end

m = length(y);

% Scale features and set them to zero mean
fprintf('Normalizing Features ...\n');

[X mu sigma] = featureNormalize(X);

% Add intercept term to X
X = [ones(m, 1) X];

% Choose some alpha value
alpha = 0.01;
num_iters = 500;

% Init Theta and Run Gradient Descent 
theta = zeros(4, 1);
[theta, J_history] = gradientDescentMulti(X, y', theta, alpha, num_iters);

% Plot the convergence graph
figure;
plot(1:numel(J_history), J_history, '-b', 'LineWidth', 2);
xlabel('Number of iterations');
ylabel('Cost J');

% Display gradient descent's result
fprintf('Theta computed from gradient descent: \n');
fprintf(' %f \n', theta);
fprintf('\n');

%% Compare regression with actual data points
for l = 1 : length(lambda)
    figure
    features_matrix = [0.1*ones(10,1) lambda(l)*ones(10,1) (1:10)' ones(10,1) ];
    estimated_queue_delay2 = sum((theta' .* features_matrix)'); 
    plot(queue_delay{1}(l,:), '--', 'linewidth', 2.0)
    hold on
    plot(estimated_queue_delay2, '--x', 'linewidth', 1.5, 'markersize', 8.0)
    legend({'Model','Regression'})
    set(gca, 'fontsize', 14)
    xlabel('Block size')
    ylabel('Queuing delay (s)')
    title(['\lambda = ' num2str(lambda(l))])
end

% %% ================ Normal Equations ================
% 
% fprintf('Solving with normal equations...\n');
% 
% % ====================== YOUR CODE HERE ======================
% % Instructions: The following code computes the closed form 
% %               solution for linear regression using the normal
% %               equations. You should complete the code in 
% %               normalEqn.m
% %
% %               After doing so, you should complete this code 
% %               to predict the price of a 1650 sq-ft, 3 br house.
% %
% 
% X = [];
% y = [];
% for i = 1 : length(mu)
%     for j = 1 : length(lambda)
%         for s = 1 : length(block_size)
%             X = [X; [mu(i) lambda(j) block_size(s)]];
%             y = [y queue_delay{i}(j,s)];
%         end
%     end
% end
% m = length(y);
% 
% % Add intercept term to X
% X = [ones(m, 1) X];
% 
% % Calculate the parameters from the normal equation
% theta = normalEqn(X, y');
% 
% % Display normal equation's result
% fprintf('Theta computed from the normal equations: \n');
% fprintf(' %f \n', theta);
% fprintf('\n');
% 
% %% Compare regression with actual data points
% for l = 1 : length(lambda)
%     figure
%     features_matrix = [0.1*ones(10,1) lambda(l)*ones(10,1) (1:10)' ones(10,1) ];
%     estimated_queue_delay2 = sum((theta' .* features_matrix)'); 
%     plot(queue_delay{1}(l,:), '--', 'linewidth', 2.0)
%     hold on
%     plot(estimated_queue_delay2, '--x', 'linewidth', 1.5, 'markersize', 8.0)
%     legend({'Model','Regression'})
%     set(gca, 'fontsize', 14)
%     xlabel('Block size')
%     ylabel('Queuing delay (s)')
%     title(['\lambda = ' num2str(lambda(l))])
% end
