% Adaptive Echo Cancellation
% Cosine-modulated multi-channel filterbanks
% Adaptation in time domain, using NLMS algorithm with crossterms
% 
% Aironi Carlo 2019
%---------------------------------------

clearvars;
clc
close all

sig_len = 10;
fs = 48000;

x = 1*randn(1,sig_len*fs);          % input signal

T = 1/fs;
f = 2500;
t =(0:T:sig_len-T);
u = 0.1*sin(2*pi*f*t);              % signal from far-end

%% Load room response
fp_r = fopen('Ir_room_1.dat', 'r'); 
HR = fread(fp_r, 'float64');
fclose(fp_r);


%% Parameters

nbands = 8;                     % bands
f_len = 128;                    % analysis/synthesis filters length
N = 4096;                       % unknown filter length (must be odd eg. 2^n+1)
step = 0.4;                     % 0 < mu < 2
L = length(x);                  % input signal length
beta = 0.5;                     % smoothing factor
LS = (2*f_len + N)/nbands;      % length of subband adapted filters (according to Gilloire/Vetterli formula)

BU = HR(1:N);                   % unknown system

%xf = filter(BU,1,x);                            % desired signal fullband
xf = u + filter(BU,1,x);                        % desired signal fullband + far-end signal

[a_bank,s_bank] = build_pQMF(nbands,f_len);      % Build filterbank


v0_d = pqmfa(nbands,xf,a_bank);                % Analysis of desired signal
v0_f = pqmfa(nbands,x,a_bank);                 % Analysis of direct signal


tic
[HS,ES] = nlms_cross_multi(v0_f,v0_d,step,beta,nbands,LS,1);      % Adaptation with crossterms    
toc

etot = pqmfs(nbands,s_bank,ES);                 % Synthesis


tic
[HS2,ES2] = nlms_cross_multi(v0_f,v0_d,step,beta,nbands,LS,0);    % Adaptation without crossterms
toc

etot2 = pqmfs(nbands,s_bank,ES2);               % Synthesis


%% Error signal spectrogram with crossterms
[s, f, t] = spectrogram(etot, hamming(128) ,64, 256, fs);
figure
surf(t, f, 20*log10(abs(s)), 'EdgeColor', 'none');
axis xy; 
axis tight; 
colormap(jet);
caxis([-70 0]);               % color axis range
xlabel('Time (secs)');
colorbar;
ylabel('Frequency(HZ)');
title('Error with crossterms');
axis([0.14 8 0 fs/2 -70 0]);
view(135,45);

%% Error signal spectrogram without crossterms
[s, f, t] = spectrogram(etot2, hamming(128) ,64, 256, fs);
figure
surf(t, f, 20*log10(abs(s)), 'EdgeColor', 'none');
axis xy; 
axis tight; 
colormap(jet);
caxis([-70 0]);
xlabel('Time (secs)');
colorbar;
ylabel('Frequency(HZ)');
title('Error without crossterms');
axis([0.14 8 0 fs/2 -70 0]);
view(135,45);


%% Play results
% sound(etot,fs);
% sound(etot2,fs);