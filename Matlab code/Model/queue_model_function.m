%%% *********************************************************************
%%% * E2E Latency Analysis of Decentralized Blockchain                  *
%%% * By: F. Wilhelmi (fwilhelmi@cttc.cat), S. Barrachina & P. Dini     *
%%% * Copyright (C) 2022-2027, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/blockchain_optimization    *
%%% *********************************************************************
 
function [queue_delay, queue_length, drop_prob] = queue_model_function(lambda_array, mu, ...
    queue_size, block_size, timer, n_fork, logs_enabled)
% queue_model_function returns the expected delay and occupancy of a
% batch-service queue, according to the input parameters
% INPUT:
%   * lambda: total system arrivals [pkt/s]
%   * mu: service rate [batch per second]
%   * queue_size: maximum size of the queue [# of packets]
%   * block_size: minimum block size to serve batches [# of packets]
%   * timer: maximum waiting time before serving a batch [seconds]
%   * n_fork: proportion of forks that occur when serving a batch
% OUTPUT:
%   * queue_delay: expected queue delay suffered by packets [seconds]
%   * queue_length: expected queue occupancy [# of packets]
 
queue_length = zeros(length(lambda_array),length(block_size));
queue_delay = zeros(length(lambda_array),length(block_size));
 
K = queue_size;
 
% M/M/1/K model with timers and forks
for l = 1 : length(lambda_array)  % Iterate for lambda inputs
 
    lambda = lambda_array(l);
    steady_state_prob = zeros(length(block_size),K+1);
    p_fork = 1 - 1./n_fork;
 
    for s = 1 : length(block_size)  % Iterate for block size inputs
 
        S = block_size(s);
        
        if(logs_enabled)
            disp(' ')
            disp('---------------------')
            disp('Model parameters')
            disp('---------------------')
            disp([' * lambda (arrivals) = ' num2str(lambda)])        
            disp([' * mu (mining rate) = ' num2str(mu)]) 
            disp([' * block size = ' num2str(S)])      
            disp([' * timer = ' num2str(timer)])   
            disp([' * queue size = ' num2str(K)])   
            disp(' ')
        end
        
        % - P matrix (without forks)
        P = zeros(K+1,K+1);
        for i = 0 : K
            s_i = min(i,S);
            for j = 0 : K
                if j >= i-s_i && j < K-s_i
                    P(i+1,j+1) = ((mu)/(lambda+mu))*(lambda/(mu+lambda))^(j-(i-s_i));
                elseif j == K-s_i
                    P(i+1,j+1) = 1-sum(P(i+1,1:K-s_i));
                else
                    P(i+1,j+1) = 0;
                end
            end
        end
        
        % - P matrix (with forks)
        P_fork = zeros(K+1,K+1);
        for i = 0 : K
            s_i = 0;
            for j = 0 : K
                if j >= i-s_i && j < K-s_i
                    P_fork(i+1,j+1) = ((mu)/(lambda+mu))*(lambda/(mu+lambda))^(j-(i-s_i));
                elseif j == K-s_i
                    P_fork(i+1,j+1) = 1-sum(P_fork(i+1,1:K-s_i));
                else
                    P_fork(i+1,j+1) = 0;
                end
            end
        end
                       
        % - Compute the P matrix including the effect of forks
        P_total = zeros(K+1,K+1);
        for k1 = 1 : K+1
            for k2 = 1 : K+1
                P_total(k1,k2) = (1-p_fork(k1))*P(k1,k2) + p_fork(k1).*P_fork(k1,k2);
            end
        end
        
        %P_total = (1-p_fork(s))*P + p_fork(s).*P_fork;
 
        % - Departure distribution obtained from the transition matrix
        pi_d = DTMC_prob(P_total);       
         
        % - Timeout probability  
        p_timeout = zeros(1,K+1);          % Prob. that the timer expires from each state
        for i = 0 : K
            if i < S
                for j = 0 : S-i-1 % Check cases where timeout expires
                    p_timeout(i+1) = p_timeout(i+1) + ...
                        exp(-lambda*timer)*(lambda*timer).^(j)/factorial(j);
                end
            end
        end      
                        
        % - Inter-departure time
        % CDF (bounded by timer): (-1/lambda)*exp(-lambda*timer)+(1/lambda)
        time_to_mine = zeros(1,K+1);       % Total time (fill block + mine block)
        time_before_mining = zeros(1,K+1); % Time before mining (fill block or timer)      
             
        % Empirical way to find the average inter-departure time (TODO: check this analytically)
        for i = 0 : K
            if i < S                
                a = []; 
                for ii = 1 : 100000
                    aux = 0;
                    for iii = 1 : S-i
                        aux = aux + exprnd(1/lambda);
                    end                    
                    if aux < timer
                        a = [a aux];
                    end
                end
                if isempty(a), a = timer; end
                time_before_mining(i+1) = p_timeout(i+1)*timer + (1-p_timeout(i+1))*mean(a);
            end
            time_to_mine(i+1) = time_before_mining(i+1) + 1/mu;
        end 
        inter_departure_time = sum(pi_d.*time_to_mine);
                
        % - Steady-state distribution based on PASTA property: 
        %   the prob. to be in state "i" (pi_s) at any arbitrary time 
        %   is equal to the prob. that a new arrival finds the queue at "i"
        pi_s = zeros(1,K+1);
        for k = 0 : K           % Iterate for each possible number of elements in the queue          
            if k < K            % Leave the special "k = K" case aside     
                total_sum = 0;  % Sum of probabilities of observing "k" packets from each possible state
                for i = 0 : k   % Iterate from each possible initial state   
                    % - Case 1: the timer expires
                    if i < S                        
                        expected_arrivals_timeout = 0;              % Keep track of the expected number of arrivals during the filling period
                        expected_arrivals_mining = lambda*(1/mu);   % Expected number of arrivals during mining
                        p1 = 0;
                        for j = i : S-1 % Check all the cases where the timer can expire
                            s_i = j;            % Num. of packets to be mined based on the arrivals observed during the filling period
                            n_arrivals = j-i;   % Num. of arrivals during the filling period                           
                            p_j = exp(-lambda*timer) * ...
                                (lambda*timer)^(n_arrivals)/factorial(n_arrivals);    % Prob. of observing exactly n_arrivals before the timer expires
                            p_j = p_j/p_timeout(i+1);                                 % Obtain p_j assuming that it is conditioned on the timer expiration prob.
                            p0 = sum(P(j+1, max(0,k-s_i+1)+1:(K-s_i)+1));             % Prob. of observing enough arrivals during the mining period
                            p1 = p1 + (p_j*p0);                                       % Prob. that an arrival observes "k" packets, starting from state "j" before mining
                            expected_arrivals_timeout = ...
                                expected_arrivals_timeout + p_j*n_arrivals/p_timeout(i+1);  % Expected arrivals during the epoch at which the timer expires
                        end
                        expected_arrivals = expected_arrivals_timeout + expected_arrivals_mining;     % Total expected number of arrivals when the timer expires                        
                        p_t = p1 * (1/(lambda*inter_departure_time));   % Total probability of state "k", starting from state "i" (when the timer expires)
                    else
                        p_t = 0;
                    end
                    % - Case 2: the timer does not expire
                    p_nt = sum(P(i+1, max(0,k-S+1)+1:(K-S)+1)) * (1/(lambda*inter_departure_time));
                    % + Aggregate cases 1 and 2 based on the timeout prob.
                    total_sum = total_sum + pi_d(i+1)*(p_timeout(i+1)*p_t + (1-p_timeout(i+1))*p_nt);                    
                end   
                % Total prob. of observing "k" packets from any state
                pi_s(k+1) = total_sum;
            elseif k == K   
                pi_s(k+1) = max(0,1 - sum(pi_s(1:K)));
            end
        end
        steady_state_prob(s,:) = pi_s;
        
        % - Compute blocking prob. (= drop packets)
        pb = pi_s(end);
        drop_prob(l,s) = pb;
 
        % - Compute occupancy and delay from steady state probabilities
        queue_length(l,s) = sum(steady_state_prob(s,:).*(0:K));
        queue_delay(l,s) = queue_length(l,s)/(lambda*(1-pb));
               
        % Compute the number of packets mined from each state
        n_mined = zeros(1,K+1);
        for k = 0 : K
            n_mined(k+1) = min(k,S)*p_timeout(k+1) + S*(1-p_timeout(k+1)); 
        end 
        %n_mined
        
        total_timeout_prob = sum(pi_s.*p_timeout);
               
        if(logs_enabled)
            disp(' ')
            disp('---------------------')
            disp('Results')
            disp('---------------------')
            disp([' - Total timeout probability = ' num2str(total_timeout_prob)])
            disp(['       + Timeout prob. from each state: ' num2str(p_timeout)])
            disp([' - Fork probability distribution = ' num2str(sum(pi_s .* p_fork))])
            disp([' - Expected inter-departure time = ' num2str(inter_departure_time)])
            disp([' - Expected mined block size = ' num2str(sum(pi_s .* n_mined))])
            disp(' - Departure distribution: ');
            disp(['    ' num2str(pi_d)]);
            disp(' - Steady-state probabilities: ')
            disp(['    ' num2str(pi_s)])
        end
 
    end
 
end
        
end

