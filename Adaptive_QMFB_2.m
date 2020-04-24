% Adaptive Quadrature Mirror Filterbanks
% Adaptation in time domain, using NLMS algorithm
% 
% Aironi Carlo 2019
%---------------------------------------

clearvars
close all

% Johnston filter coeff.
BJ = [-0.006443977, 0.02745539, -0.00758164, -0.0913825, 0.09808522, 0.4807962];

h0 = [BJ,fliplr(BJ)];           % lowpass analysis filter H0(z)
h1 = zeros(1,12);               % highpass analysis filter H1(z)
for k = 1:length(h0)
  h1(k) = ((-1)^k)*h0(k);       
end
g0 = 2*h0;                      % lowpass synthesis filter G0(z)
g1 = -2*h1;                     % highpass synthesis filter G1(z)

x = 1*randn(1,10000);           % random signal as input

LH = 2*length(BJ);              % length of analysis/synthesis filters
N = 64;                         % Unknown filter length (must be odd)
step = 0.6;                     % 0 < mu < 2
L = length(x);                  % Signal length
beta = 0.5;                     % smoothing factor
LS = N;

BU = fir1(N-1,0.99);             % Unknown lowpass N-1 order FIR filter, set cutoff freq to 0.99 to check 
                                 % the presence of aliasing in whole band
                                 
xf = filter(BU,1,x);            % desired signal fullband

tic                             % timer

[v0_d,v1_d] = qmfa(xf,h0,h1);     % Analysis desired

[v0_f,v1_f] = qmfa(x,h0,h1);      % Analysis filtered

[b0_a,e0_a,y0_a] = nlms(v0_f,v0_d,step,beta,LS);               % NLMS_3
[b1_a,e1_a,y1_a] = nlms(v1_f,v1_d,step,beta,LS);               % NLMS_3

toc                                 % timer

etot = qmfs(e0_a,e1_a,g0,g1);        % Synthesis

%% Plot
subplot(2,1,1);
plot(etot);
title('Total output error (linear)');
xlabel('samples');
ylabel('Amplitude');
axis([1 10000 -1.5 1.5]);

subplot(2,1,2);
plot(10*log10(etot.^2));
title('Total output error (logarithmic)');
xlabel('samples');
ylabel('Magnitude (dB)');
axis([1 10000 -120 0]);

figure
spectrogram(etot, hamming(128) ,64, 256, 8000, 'yaxis');
caxis([-140 -30]);               % color axis range
title('Output error without crossterms');
