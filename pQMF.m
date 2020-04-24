% Cosine-modulated pseudoQMF filterbanks
%
% Aironi Carlo 2019
% --------------------------------

clearvars;
clc;
close all;

nbands = 8;
f_len = 128;                    % low-pass prototype filter length

% for better performance choose f_len/nbands = 16

nf = linspace(0,1,1024);
 
%% Lowpass prototype definition

stopedge = 1/nbands;
passedge = 1/(4*nbands);        % omegapass start value

tol = 0.0001;
step = 0.1 * passedge;
tcost = 0;
way = -1;
pcost = 10;
exit_flag = 0;
res_all = 4096;
niter = 0;

while exit_flag == 0
    niter = niter + 1;
    hopt = firpm(f_len-1,[0,passedge,stopedge,1],[1,1,0,0],[3,1]);
    
    H_all = fft(hopt,res_all);
    res_1b = floor(res_all/(2*nbands));         % n. of samples each band
    H_1b = zeros(res_1b,1);
    for k = 1:res_1b
        H_1b(k) = abs(H_all(res_1b-k+2))^2 + abs(H_all(k))^2; 
    end
    tcost = max(abs(H_1b - ones(max(size(H_1b)),1)));
    if tcost > pcost
        step = step/2;
        way = -way;
    end
    if abs(pcost - tcost) < tol
      exit_flag = 1;
    end
    pcost = tcost;
    passedge_seq(niter) = passedge;     % to trace iterations
    passedge = passedge + way*step;
end

%% Cosine modulation + synthesis

a_bank = zeros(nbands,f_len);       % analysis
s_bank = zeros(nbands,f_len);       % synthesis

dtf = zeros(1024,1);               % distortion transfer function

for m = 1:nbands
    for n = 1:f_len
        arg_i = (pi/(nbands))*((m-1)+0.5)*((n-1)-((f_len-1)/2));
        theta_i = ((-1)^(m-1))*(pi/4);
        a_bank(m,n) = 2*hopt(n)*cos(arg_i + theta_i);
        s_bank(m,n) = 2*hopt(n)*cos(arg_i - theta_i);
    end
    % plot bank
    hb = freqz(a_bank(m,:),1,1024);
    plot(nf, 20*log(abs(hb)),'LineWidth',1);
    dtf = dtf + hb;
    hold on
end
axis([0 1 min(20*log(abs(hb)))-50 max(20*log(abs(hb)))+50])
title('Filter Bank');
grid on
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');

% plot distortion transfer function
figure;
plot(nf', 20*log(abs(dtf)),'LineWidth',1)
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');
axis([0 1 min(20*log(abs(dtf)))-0.2 max(20*log(abs(dtf)))+0.2])
title('Distortion Transfer Function');
grid on

%% Test

% Generating the test signal
x = [zeros(size(1:100)),ones(size(101:250)),zeros(size(251:511))];

xl = length(x);

% Analysis part
for m = 1:nbands
    xf(m,:) = filter(a_bank(m,:),1,x);
    xfd(m,:) = downsample(xf(m,:),nbands);
end

% Synthesis part
for m = 1:nbands
    yfu(m,:) = upsample(xfd(m,:),nbands);
    yf(m,:) = filter(s_bank(m,:),1,yfu(m,:));
end

% Sum
y = zeros(1,512);
for m = 1:nbands
    y = y + yf(m,:);
end

% plot input and output signals
figure
plot(x,'LineWidth',1);
hold on
plot(nbands*y,'r','LineWidth',1);
legend('input','output');
axis([0 512 min(x)-0.5 max(x)+0.5])
title('Input / Output signals');
grid on
xlabel('Samples');
ylabel('Amplitude');


%% Plot all in one window
figure
subplot(2,2,1);
stem(hopt);
axis([0 f_len min(hopt)-0.02 max(hopt)+0.02])
title('Prototype filter response');
xlabel('Taps');
ylabel('Amplitude');
grid on

subplot(2,2,3);
plot(nf', 20*log(abs(freqz(hopt,1,1024))),'LineWidth',1)
title('Prototype filter transfer function');
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');
grid on

subplot(2,2,2);
for m = 1:nbands
    hb = freqz(a_bank(m,:),1,1024);
    plot(nf, 20*log(abs(hb)),'LineWidth',1);
    %h_all = h_all + hb;
    hold on
end
axis([0 1 min(20*log(abs(hb)))-50 max(20*log(abs(hb)))+50])
title('Filter Bank');
grid on
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');

subplot(2,2,4);
plot(nf', 20*log(abs(dtf)),'LineWidth',1)
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');
axis([0 1 min(20*log(abs(dtf)))-0.2 max(20*log(abs(dtf)))+0.2])
title('Distortion Transfer Function');
grid on

