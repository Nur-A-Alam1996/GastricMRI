function [psd, freq] = tools_psd(x, fs)
%{

##tools_psd:
Compute power density distribution (PSD) for each column time series

##Environment requirement:
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
[psd, freq] = tools_psd(x, fs)

##Inputs:
%x: vector or matrix, each column is a time series
%fs: the sample rate

##Output:
%psd: the power spectrum
%freq: frequencies.

##History:
% 1.00 - 04/10/2014 - HGWEN - original file

##Version:
1.00

%}

if isvector(x)
    x = x(:);
end
Nfft = 2^ceil(log2(size(x,1)));
tapper = gettaper(size(x));
f = abs(fft(x.*tapper,Nfft))/min(Nfft,size(x,1));
f(2:end,:) = f(2:end,:)*2;
psd = f(1:Nfft/2,:).^2;
freq = (0:Nfft)*fs/Nfft;
freq = freq(1:Nfft/2);
freq = freq(:);

end

function taper = gettaper(S)
% get a tapering function for power spectrum density calculation
if license('test','signal_toolbox')
    taper = hann(S(1),'periodic');    
else
    taper = 0.5*(1-cos(2*pi*(1:S(1))/(S(1)-1)));   
end
    taper = taper(:);
    taper = repmat(taper,1,S(2));
end
