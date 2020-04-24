% Quadrature Mirror Filter Synthesis with classic structure
% Aironi Carlo 2019
% ----------------------------------------
% prototype: [y] = qmfs(v0,v1,g0,g1)
% 
% y = output total signal
% g0 = lowpass synthesis filter
% g1 = highpass synthesis filter
% v0 = lowpass input
% v1 = highpass input

function y = qmfs(v0,v1,g0,g1)

% Synthesis
u0 = upsample(v0,2);
y0 = filter(g0,1,u0);   % Lowpass signal component
u1 = upsample(v1,2);
y1 = filter(g1,1,u1);   % Highpass signal component
y = y0 + y1;            % Rebuilt signal

end