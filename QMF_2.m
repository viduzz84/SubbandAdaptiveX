% QMF filterbank perfect reconstruction
% Aironi Carlo 2019
% ----------------------------

clearvars
close all
clc

% Johnston filter
B1 = [-0.006443977, 0.02745539, -0.00758164, -0.0913825, 0.09808522, 0.4807962];

% Generating the lowpass analysis filter H0(z)
h0 = [B1,fliplr(B1)];          

% Generating the highpass analysis filter H1(z)
h1 = zeros(1,12);
for k = 1:length(h0)
  h1(k) = ((-1)^k)*h0(k);       
end

% Generating the lowpass synthesis filter G0(z)
g0 = 2*h0;

% Generating the highpass synthesis filter G1(z)
g1 = -2*h1;

nf = linspace(0,1,512);         

subplot(2,1,1)
stem(h0);
title('Impulse response of lowpass filter')
subplot(2,1,2)
stem(h1)
title('Impulse response of highpass filter')

[hlp,plp]=freqz(h0,1,512);
[hhp,php]=freqz(h1,1,512);
figure;
subplot(2,1,1);
plot(nf',20*log(abs(hlp)));
hold on;
plot(nf',20*log(abs(hhp)));
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');
axis([0 1 -200 30])
legend('Low-pass','High-pass');
title('QMF Bank');
subplot(2,1,2);
plot(nf',20*log(abs(hlp+hhp)))
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');
axis([0 1 -0.1 0.1])
title('Distortion Transfer Function');

% Generating the test signal
x = [zeros(size(1:100)),ones(size(101:250)),zeros(size(251:511))]; 

tic                     % Timer

% Analysis part
x0 = filter(h0,1,x);
v0 = downsample(x0,2);  % Lowpass signal component
x1 = filter(h1,1,x);
v1 = downsample(x1,2);  % Highpass signal component

% Synthesis part
u0 = upsample(v0,2);
y0 = filter(g0,1,u0);   % Lowpass signal component
u1 = upsample(v1,2);
y1 = filter(g1,1,u1);   % Highpass signal component
y = y0 + y1;            % Rebuilt signal

toc                     % Timer


figure
subplot(2,1,1);
plot(x);
hold on
plot(y,'r');
xlabel('Samples');
ylabel('Amplitude');
legend('input','output');
title('Test Signal');
axis([0 512 -0.1 1.1])
subplot(2,1,2);
plot(x(1:length(x)-11)-y(12:length(x)));
xlabel('Samples');
ylabel('Amplitude');
axis([0 512 -5e-3 1e-3])
title('Amplitude difference');
