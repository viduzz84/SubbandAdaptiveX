% Quadrature Mirror filterbank 
% perfect reconstruction with polyphase structure
%
% Aironi Carlo 2019
% --------------------------------

% Johnston filter
B1 = [-0.006443977, 0.02745539, -0.00758164, -0.0913825, 0.09808522, 0.4807962];
h0 = [B1,fliplr(B1)];           % Generating the lowpass filter H0(z)
h1 = zeros(1,12);
for k = 1:length(h0)
  h1(k) = ((-1)^k)*h0(k);        % Generating the highpass filter H1(z)
end

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
axis([0 1 -200 30])
title('QMF')

legend('Low-Pass response', 'High-Pass response');
subplot(2,1,2);
plot(nf',20*log(abs(hlp+hhp)))
axis([0 1 -0.1 0.1])
title('Distortion transfer function')

% Polyphase decomposition
e0 = h0(1:2:length(h0));        % Polyphase component E_0(z)
e1 = h0(2:2:length(h0));        % Polyphase component E_1(z)

x = [zeros(size(1:100)),ones(size(101:250)),zeros(size(251:511))]; % Generating the test signal

tic  % Timer

% Analysis part
x0 = x(1:2:length(x))/2;        % Down-sampling, branch E_0
x1 = [0,x(2:2:length(x)-1)]/2;  % Down-sampling, branch E_1
v00 = filter(e0,1,x0);          % Filtering with E_0(z)
v11 = filter(e1,1,x1);          % Filtering with E_1(z)
v0 = v00 + v11;                 % Output of the lowpass filter
v1 = v00 - v11;                 % Output of the highpass filter


% Synthesis part
w00 = v0 + v1;                  % Input to polyphase component E_1(z), synthesis part
w11 = v0 - v1;                  % Input to polyphase component E_0(z), synthesis part
u00 = 2*filter(e1,1,w00);       % Filtering with E_1(z)
u11 = 2*filter(e0,1,w11);       % Filtering with E_0(z)
y0 = zeros(size(1:512 ));
y0(1:2:512 ) = u00;             % Upsampling, branch E_0
y1 = zeros(size(1:512 ));
y1(1:2:512 ) = u11 ;            % Upsampling, branch E_1
y0 = [0,y0(1:511 )];            % Inserting the delay z^(-1)
y = 2*(y0 + y1);                % Rebuilt signal

toc % Timer

figure
subplot(2,1,1);
plot(x);
hold on
plot(y,'r');
title('Test Signal');
axis([0 512 -0.1 1.1])
legend('input','output');
subplot(2,1,2);
plot(x(1:length(x)-11)-y(12:length(x)));
axis([0 512 -5e-3 1e-3])
title('Amplitude difference');