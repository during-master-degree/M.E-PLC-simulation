function [Yf,f]=freqspec(yt,Fs)
%This function calculates the frequency spectrum of yt
%Fs：采样频率，单位时间（1s）内采样点数

% Ns=512;
% F=abs(fft(x,Ns));
% fr=(1/y)*(0:Ns/2-1)/Ns;

L = length(yt);

% 加Hanning窗
w = hann(L);
yt = yt(:).*w(:);

NFFT = 2^nextpow2(L);
Yf = fft(yt,NFFT)/L;

Yf = 2*abs(Yf(1:NFFT/2+1));
f = Fs/2 * linspace(0,1,NFFT/2+1);
end