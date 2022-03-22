function [pi_vec,amat] = dtmc_stationary_probs_p(trans_mat)
% Using GTH algorithm, calculate the stationary probability row vector 
% of the DTMC (discrete-time Markov chain) specified by trans_mat.
% According to Grassmann, Taksar, Heyman "Regenerative Analysis
% and Steady State Distributions for Markov Chain", 1985, 
% Operations Research, Vol.33, No.5.1107-1116.
% function [pi_vec,amat] = dtmc_stationary_probs_p(trans_mat)

% Author: Rui Kang, June,2003, IE Dept. Lehigh University.

amat = trans_mat;
N = size(amat,1);                              % state number
r = zeros(1,N);
S = 0;

% Get the amat(i,j) values after Gaussian Elimination.
% To avoid subtraction, using the property that the sum of every row is zero, then get the diagonal element
for n = N:-1:2
    S = sum(amat(n,1:n-1));
    for i = 1:n-1
        amat(i,n) = amat(i,n)/S;
    end
    for i = 1 : n-1
        for j = 1:n-1
            if i~=j 
                amat(i,j) = amat(i,j) + amat(i,n) * amat(n,j);
            end
        end
    end
end

TOT = 1;
r(1) = 1;

% Get the stationary probability pi_vec, 1/TOT is p0.
for j = 2:N
    mysum = 0;    
    for k = 2: j-1
        mysum = mysum + r(k) * amat(k,j);
    end
    r(j) = amat(1,j)+ mysum;
    TOT = TOT + r(j);
end

pi_vec = r/TOT;

return;