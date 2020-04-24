% Multi-Channel NLMS Algorithm with smoothing factor and cross-terms
% ref. Gilloire/Vetterli
% Aironi Carlo 2019
% ----------------------------------------
% prototype:        [c_out,e_out] = nlms_cross_multi(x,d,mu,beta,C,N,cross)
% 
% c = adaptive main- and cross-filters coefficients
% e = errors
% x = input signals
% d = desired signals
% mu = NLMS step size
% beta = smoothing factor
% C = n. of channels
% N = adaptive filters length
% cross: 0 = do not use crossfilters only main, 1 = use crossfilters + main

function [c_out,e_out] = nlms_cross_multi(x,d,mu,beta,C,N,cross)

% pre-allocation
L = max(size(x));                       % signal length
yh = zeros(C+2,L);                      % y_hat
c = zeros(C*3,N);                       % adaptive filters and cross-filters
e = zeros(C+2,L);                       % errors
xr = zeros(C+2,N);
p = zeros(C+2,1);
pb = 0.001;                             % power bias to avoid division by zero

x = [zeros(1,length(x)); x; zeros(1,length(x))];
d = [zeros(1,length(d)); d; zeros(1,length(d))];

p = diag(x(:,1:N)*x(:,1:N)');           % initial power

for k1 = N:L
    
    xr = x(1:C+2,k1:-1:k1-N+1);         % x reversed
    
    for k2 = 2:C+1
        
        % filter index
        k3 = 3*k2-5;
        
        % y_hat
        yh(k2,k1)= cross*(c(k3,:)*xr(k2-1,:)') + (c(k3+1,:)*xr(k2,:)') + cross*(c(k3+2,:)*xr(k2+1,:)');
        
        % error
        e(k2,k1) = d(k2,k1) - yh(k2,k1);
        
        % power updates
        p(k2) = (1 - beta)*p(k2) + beta*(p(k2) + x(k2,k1)^2 - x(k2,k1-N+1)^2);
        
        % adaptation
        c(k3,:) = c(k3,:) + (mu*e(k2,k1)/(pb + p(k2-1)))*xr(k2-1,:);
        c(k3+1,:) = c(k3+1,:) + (mu*e(k2,k1)/(pb + p(k2)))*xr(k2,:);
        c(k3+2,:) = c(k3+2,:) + (mu*e(k2,k1)/(pb + p(k2+1)))*xr(k2+1,:);
        
    end
end

c_out = c(1:C*3,:);
e_out = e(2:C+1,:);