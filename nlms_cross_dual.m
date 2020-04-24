% Normalized LMS Algorithm with smoothing factor and cross-terms 2-channel
% ref. Gilloire/Vetterli
% Aironi Carlo 2019
% ----------------------------------------
% prototype:        [c00,c01,c10,c11,e0,e1] = nlms_cross_dual(x0,x1,d0,d1,mu,beta,N)
% 
% c00, c01, c10, c11 = adapted FIR filters and crossfilters
% e0, e1 = error in subbands
% x0, x1 = input signal in subbands
% d0, d1 = desired signal in subbands
% mu = step size (fixed)
% N = length of the FIR filter
% beta = smoothing factor


function [c00,c01,c10,c11,e0,e1] = nlms_cross_dual(x0,x1,d0,d1,mu,beta,N)

L = length(x0);
yh0 = zeros(1,L);                       % y hat 0
yh1 = zeros(1,L);                       % y hat 1
c00 = zeros(1,N);                   
c11 = zeros(1,N);
c10 = zeros(1,N);                       
c01 = zeros(1,N); 
e0 = zeros(1,L);
e1 = zeros(1,L);

p0 = x0(N:-1:1)*x0(N:-1:1)';            % start power
p1 = x1(N:-1:1)*x1(N:-1:1)';            

for k = N:L
    xr0 = x0(k:-1:k-N+1);               % x0 reversed
    xr1 = x1(k:-1:k-N+1);               % x1 reversed
    
    yh0(k) = c00*xr0' + c01*xr1';       % f0*xr1' + f1*xr1';
    yh1(k) = c11*xr1' + c10*xr0';       % f0*xr0' + f1*xr0';
    
    e0(k) = d0(k) - yh0(k);             % error
    e1(k) = d1(k) - yh1(k);             % error
    
    p0 = (1 - beta)*p0 + beta*(p0 + x0(k)^2 - x0(k-N+1)^2);      % power update
    p1 = (1 - beta)*p1 + beta*(p1 + x1(k)^2 - x1(k-N+1)^2);
    
	% directed and cross- adaptation
    c00 = c00 + (mu*e0(k)/p0)*x0(k:-1:k-N+1);
    c11 = c11 + (mu*e1(k)/p1)*x1(k:-1:k-N+1);
    c10 = c10 + (mu*e1(k)/p0)*x0(k:-1:k-N+1);
    c01 = c01 + (mu*e0(k)/p1)*x1(k:-1:k-N+1);
    
end














