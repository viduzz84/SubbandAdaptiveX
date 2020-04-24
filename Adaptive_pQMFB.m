% Adaptive Pseudo Quadrature Mirror Filter
% Cosine-modulated multi-channel filterbanks
% Adaptation in time domain, using NLMS algorithm with crossterms
% 
% Aironi Carlo 2019
%---------------------------------------

%clearvars;
clc
close all;

x = 1*randn(1,100000);          % input signal

nbands = 8;                     % bands
f_len = 128;                    % analysis/synthesis filters length
N = 128;                        % unknown filter length
step = 0.3;                     % 0 < mu < 2
L = length(x);                  % input signal length
beta = 0.5;                     % smoothing factor
LS = (2*f_len + N)/nbands;      % length of subband adapted filters (according to Gilloire/Vetterli formula)

BU = fir1(N-1,0.3);             % Unknown lowpass N-1 order FIR filter with normalized cutoff freq = 0.3

xf = filter(BU,1,x);                            % desired signal fullband

[a_bank,s_bank] = build_pQMF(nbands,f_len);     % Build filterbank

v0_d = pqmfa(nbands,xf,a_bank);                % Analysis of desired signal
v0_f = pqmfa(nbands,x,a_bank);                 % Analysis of direct signal

tic
[HS,ES] = nlms_cross_multi(v0_f,v0_d,step,beta,nbands,LS,1);       % NLMS-cross
toc

etot = pqmfs(nbands,s_bank,ES);                 % Synthesis

tic
[HS2,ES2] = nlms_cross_multi(v0_f,v0_d,step,beta,nbands,LS,0);       % NLMS-non cross
toc
etot2 = pqmfs(nbands,s_bank,ES2);                 % Synthesis

etot = nbands * etot;
etot2 = nbands * etot2;

% Plots
figure
subplot(1,2,1);
plot(10*log10(etot.^2));
legend('etot w cross');
grid on
axis([0 L -80 0]);
%hold on
subplot(1,2,2);
plot(10*log10(etot2.^2),'r');
legend('etot wo cross');
grid on
axis([0 L -80 0]);


%% Plot
subplot(2,1,1);
plot(etot2);
title('Total output error without crossterms');
xlabel('samples');
ylabel('Amplitude');
axis([1 100000 -2 2]);

subplot(2,1,2);
plot(10*log10(etot2.^2));
title('Total output error without crossterms');
xlabel('samples');
ylabel('Magnitude (dB)');
axis([1 100000 -130 10]);

figure
subplot(2,1,1);
plot(etot);
title('Total output error with crossterms');
xlabel('samples');
ylabel('Amplitude');
axis([1 100000 -2 2]);

subplot(2,1,2);
plot(10*log10(etot.^2));
title('Total output error with crossterms');
xlabel('samples');
ylabel('Magnitude (dB)');
axis([1 100000 -130 10]);
