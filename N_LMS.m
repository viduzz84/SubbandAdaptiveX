%   LMS-NLMS example
%
%   Aironi Carlo 2019
% ----------------------------------------

close all; 
clearvars

% fix random generator seed for repeatability
rng(1,'twister');
s = rng;
rng(s);

fs = 48000;             
t = 2;                  % signal duration
L = t * fs;             % signal length
tv = 0:1/fs:t-1/fs;
N = 64;                 % unknown filter length
mu = 0.1;               % step size  0 < mu < 2
beta = 0.5;             % smoothing factor

x = 0.1*randn(1,L);     % input signal

b = fir1(N-1,0.1);          % unknown system

d = filter(b,1,x);          % desired signal

y = zeros(1,L);
h1 = zeros(1,N);
h2 = zeros(1,N);
e1 = zeros(1,L);
e2 = zeros(1,L);
p = x(N:-1:1)*x(N:-1:1)';   % initial normalization power
c = 0.001;                  % power bias

% LMS
for k = N:L
    x1 = x(k:-1:k-N+1);
    y(k) = h1*x1';
    e1(k) = d(k) - y(k);
    h1 = h1 + mu*e1(k)*x1;
end

% NLMS
for k = N:L
    x1 = x(k:-1:k-N+1);
    y(k) = h2*x1';
    e2(k) = d(k) - y(k);
    p = (1 - beta)*p + beta*(p + x(k)^2 - x(k-N+1)^2);
    h2 = h2 + (mu*e2(k)/(c+p))*x1;
end

% plot
subplot(3,1,1);
stem(b);
hold on;
plot(h1,'r');
ylabel('Amplitude');
title('Unknown system');
legend('actual','estimated with LMS');

subplot(3,1,2);
stem(b);
hold on;
plot(h2,'r');
ylabel('Amplitude');
title('Unknown system');
legend('actual','estimated with NLMS');

subplot(3,1,3);
plot(tv,10*log10(e1.^2));
hold on;
plot(tv,10*log10(e2.^2),'r');
ylabel('Magnitude (dB)');
xlabel('time (s)')
title('Error');
legend('LMS error','NLMS error');

