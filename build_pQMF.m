% Matlab function to generate a pseudo-QMF cosine modulated filterbank
% Parameters
%   nbands = n of subbands
%   f_len = filter length (must be a power of 2)
%   
% Aironi Carlo 2019
% --------------------------------------------------------------------

function [a_bank,s_bank] = build_pQMF(nbands,f_len)


% Lowpass prototype definition

stopedge = 1/nbands;
passedge = 1/(4*nbands);        % omegapass start value

tol = 0.00001;
step = 0.1 * passedge;
tcost = 0;
way = -1;
pcost = 10;
exit_flag = 0;
res_all = 4096;

while exit_flag == 0
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
    passedge = passedge + way*step;
end

% cosine modulation

a_bank = zeros(nbands,f_len);       % analysis bank
s_bank = zeros(nbands,f_len);       % synthesis bank

for m = 1:nbands
    for n = 1:f_len
        arg_i = (pi/(nbands))*((m-1)+0.5)*((n-1)-((f_len-1)/2));
        theta_i = ((-1)^(m-1))*(pi/4);
        a_bank(m,n) = 2*hopt(n)*cos(arg_i + theta_i);
        s_bank(m,n) = 2*hopt(n)*cos(arg_i - theta_i);
    end
end


end