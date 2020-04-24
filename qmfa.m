% Quadrature Mirror Filter Analysis with classic structure
% Aironi Carlo 2019
% ----------------------------------------
% prototype: [v0,v1] = qmfa(x,h0,h1)
% 
% x = input signal
% h0 = lowpass analysis filter
% h1 = highpass analysis filter
% v0 = lowpass output
% v1 = highpass output

function [v0,v1] = qmfa(x,h0,h1)

% Analysis
x0 = filter(h0,1,x);
v0 = downsample(x0,2); % Lowpass signal component
x1 = filter(h1,1,x);
v1 = downsample(x1,2); % Highpass signal component

end