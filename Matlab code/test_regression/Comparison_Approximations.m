clear ; close all; clc

% Set simulation parameters
T_WAIT = 100;         % timeout in seconds for generating a block
block_size = 1:10;     % block size in number of transactions
queue_length = 10;    % number of transactions that fit the queue
mu = [.1 .5];         % arrivals rate (UE requests)
lambda = [.1 .2 .25];

% Load Data
X = [];
y = [];

load('queue_delay')

figure 
n = 1;
for m = 1 : 1%length(mu)
    for l = 1 : 1%length(lambda) 
        y = [];
        for s = 1 : length(block_size)
            y = [y queue_delay{m}(l,s)];
        end
        % 1
        p1 = polyfit(block_size,y',1);    
        estimated_queue_delay1 = sum((p1.*[block_size' ones(10,1)])');
        % 2
        p2 = polyfit(block_size,y',2);    
        estimated_queue_delay2 = sum((p2.*[block_size.^2' block_size' ones(10,1)])');
    %     % 3
    %     p3 = polyfit(X(:,3),y',3);    
    %     estimated_queue_delay3 = sum((p3.*[block_size.^3' block_size.^2' block_size' ones(10,1)])');
        % Lagrange
        xx = linspace(1,10);
        yy = lagrange(xx,block_size,y);
        % Plots
        %subplot(length(mu),length(lambda),n)    
        plot(queue_delay{m}(l,:), 'linewidth', 2.0)
        hold on
        plot(estimated_queue_delay1, 'o--', 'linewidth', 1.5, 'markersize', 8.0)
        plot(estimated_queue_delay2, 's--', 'linewidth', 1.5, 'markersize', 8.0)     
        plot(xx,yy,'-.','linewidth', 2, 'markersize', 8.0)
        set(gca, 'fontsize', 14)
        xlabel('Block size')
        ylabel('Delay (s)')
        title(['\mu = ' num2str(mu(m)) ', \lambda = ' num2str(lambda(l))])      
        grid on
        grid minor
        n = n+1;
    end
end
legend({'Model','Linear','Quadratic','Lagrange'})





