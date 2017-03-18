function [Npisp,F,Pxx,fr]=noise_synchronous(custom,N)%与工频同步的噪声
%调用默认参数方式：noise_synchronous(0)

%输入参数：
%custom=0时，采用系统默认参数；custom非零时，采用用户自定义参数
%N：用户自定义的SCR个数；

%输出参数：
%Npisp:窄带噪声；
%F:输出的频谱；
%Pxx:输出的功率谱；
%fr:频域上采样频率；

%clf;
%clc;
if custom==0
    n=1+round(9*rand);
else
    n=1+round((N-1)*rand);%N;
end
Ton=[1.9 11.2];%SCR导通时间范围us
Toff=[15 150];%SCR关断时间范围us
Ton=Ton*10^-6;
Toff=Toff*10^-6;
Tp=50;%工频周期对应的频率50Hz
Ap=-45;%脉冲幅度db值
a=(10^((Ap+48.75)/20))*10^-3;%脉冲幅度基准值,单位V

Fsin=[0.5:3];
Fsin=Fsin*10^6; %脉冲内的正弦波频率，暂时取500kHz——3MHz范围内%脉冲内正弦波频率，取给定频率范围内的均匀分布

A(:,1)=a*rand(n,1);%Aton，SCR导通时脉冲的幅度
A(:,2)=a*rand(n,1);%Atoff，SCR关断时脉冲的幅度
tw(:,1)=Ton(1)+(Ton(2)-Ton(1))*rand(n,1);%ton，SCR导通时脉冲的宽度 
tw(:,2)=Toff(1)+(Toff(2)-Toff(1))*rand(n,1);%toff，SCR关断时脉冲的宽度
tcw=tw/5;%时间常数
td(:,1)=rand(n,1).*(1/Tp-tw(:,1)-tw(:,2));%SCR导通之前的脉冲间隔（无脉冲时间）
td(:,2)=rand(n,1).*(1/Tp-tw(:,2)-tw(:,1)-td(:,1));%SCR导通后与SCR截止之前的脉冲间隔（无脉冲时间）
fsin=Fsin(1)+(Fsin(2)-Fsin(1))*rand(n,2);
PHY=2*pi*rand(n,2);
    
ts=1/(6*10^7);
fs=6*10^7;
t=0:ts:0.02;
l=length(t);%仿真长度0.02s,采样间隔按1/60M，产生的噪声长度就相当于对是及噪声的采样了

Npisp=zeros(1,l);

tdc=fix(td/ts);
twc=fix(tw/ts);
N1=zeros(1,l);
    
x=find(twc);
for i=1:length(x)
t1=0:ts:twc(x(i))*ts;
N=A(x(i))*exp(-(t1)/tcw(x(i))).*sin(2*pi*fsin(x(i))*t1+PHY(x(i)));
lN=length(N);
N1(tdc(x(i)):tdc(x(i))+lN-2)=N(1:lN-1);
Npisp=Npisp+N1;
N1=zeros(1,l);
end
        
figure(1);
plot(t,Npisp);
%title('同步于工频的周期脉冲噪声');
xlabel('时间 (s)');
ylabel('幅度 (V)');

%求频谱密度
[F,fr]=freqspec(Npisp,fs);
figure(2);
plot(fr,F);
%title('同步于工频的周期脉冲噪声频谱');
xlabel('频率 (Hz)');
ylabel('幅度 ');
    
%求功率谱密度
Pxx = 1/l * F.*conj(F);
figure(3);
plot(fr,Pxx);
%title('同步于工频的周期脉冲噪声功率谱密度');
xlabel('频率 (Hz)');
ylabel('功率 (W)');
end    