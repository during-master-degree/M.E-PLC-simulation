function [gss,F,Pxx,fr]=noise_colored(usedefault,Wps)%高斯有色白噪声
%调用默认参数方式：noise_colored(0)

%输入参数：
%usedefault=0表示使用默认参数，usedefault=1表示使用自定义参数Wps，表示滤波器的通带截止频率和阻带截止频率的中间值;
%Wps取值范围是0.2~2.8

%输出参数：
%F:输出的频谱；
%Pxx:输出的功率谱；
%fr:频域上采样频率；
%Ns:频率抽样点
%clc;
%clf;

fs=6*10^7;%被采样信号：0~30Mhz，故采样速率60MHz
t_s=1/(6*10^7);%1.67*10^-8;
t_sim=0:t_s:0.02;
L=length(t_sim);%仿真长度0.001s,采样间隔按1/60M，产生的噪声长度就相当于对是及噪声的采样了

A=[-65 -85];%幅度范围-65db~-85db
A=(10.^((A+48.75)/20))*10^-3;
%batterworth滤波器参数，采样率fs=1000Hz与L噪声点数相同，是将噪声的产生即看做采样结果，W：信号带宽500hz；低通滤波器通频带有少于3dB的波形,如从0到170赫兹；至少60 dB的衰减在阻带,如定义从210赫兹到奈奎斯特频率(1000赫兹)
if usedefault==0
Wp=0.5*L/3;
Ws=1*L/3;
else
Wp=(Wps-0.2+0.000001)*L/3;%0.000001是保证输入Wps=0.2时，Wp>0
Ws=(Wps+0.2-0.000001)*L/3;%0.000001是保证输入Wps=0.2.8时，Ws<3
end    
W=L;
%%%%%%%%%%%%%%%%%%%%%%% S 高斯白噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xi=A(2)+wgn(1,L,0)*(A(1)-A(2));%randn(L,1);  %产生均值为0，方差为1的高斯白噪声序列

%y_mean=mean(xi);%均值
%y_var=var(xi);%方差
%y_square=y_var+y_mean.*y_mean;%均方值
%[y_self_correlation,lag]=xcorr(xi,'unbiased');%自相关函数
%[f_g,y_probability_density] = ksdensity(xi);%概率密度
%[y_frequency_spectrum,f1_gss] = Spectrum_Calc(xi,fs);
%y_power_spectrum = 1/L * y_frequency_spectrum.*conj(y_frequency_spectrum);

%figure(1);
%subplot(2,4,1);plot(t,xi);
%title('高斯白噪声');%axis([0 L -5 5]);
%subplot(2,4,2);plot(t,y_mean);
%title('高斯白噪声均值');%axis([0 L -2 2]);
%subplot(2,4,3);plot(t,y_var);
%title('高斯白噪声方差');%axis([0 L -2 2]);
%subplot(2,4,4);plot(t,y_square);
%title('高斯白噪声均方值');%axis([0 L -2 2]);
%subplot(2,4,5);plot(lag,y_self_correlation);
%title('高斯白噪声自相关函数');%axis([-L L -1 1]);
%subplot(2,4,6);plot(y_probability_density,f_g);
%title('概率密度');
%subplot(2,4,7);plot(f1,y_frequency_spectrum);
%title('高斯白噪声频谱');
%subplot(2,4,8);plot(f1,y_power_spectrum);
%title('高斯白噪声功率谱密度');
%%%%%%%%%%%%%%%%%%%%%%% E 高斯白噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%% S 低通滤波器%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n,Wn] = buttord(Wp/W,Ws/W,3,60);
[b,a] = butter(n,Wn);
[h1,f1]=freqz(b,a,512,fs);
%figure(4);
%plot(f1,abs(h1)); xlabel('f/Hz');ylabel('|H(jf)|');
%grid on;
%title('低通滤波器幅频响应');
%%%%%%%%%%%%%%%%%%%%%%% E 低通滤波器%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% S 高斯有色噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gss=filter(b,a,xi);%滤波产生高斯色噪声
%gss1=mean(gss);%均值
%gss2=var(gss);%方差
%gss3=gss2+gss1.*gss1;%均方值
%[gss4,lag]=xcorr(gss,'unbiased');%自相关函数
%[f_g,gss5]=ksdensity(gss);%概率密度
%[y2,f2] = Spectrum_Calc(gss,fs);%频谱
%p2 = 1/L * y2.*conj(y2);%功率谱


figure(1);
plot(t_sim,gss);
%title('高斯有色背景噪声');
xlabel('时间 (s)');
ylabel('幅度 (V)');

%求频谱密度
[F,fr]=freqspec(gss,fs);
for j=1:4
   F(j)=F(j+5); 
end
figure(2);
plot(fr,F);
%title('高斯有色背景噪声频谱');ylim([0 10^-6]);
xlabel('频率 (Hz)');
ylabel('幅度 (V/Hz)')

%求功率谱密度 
Pxx = 1/L * F.*conj(F);
figure(3);
plot(fr,Pxx);
%title('高斯有色背景噪声功率谱密度');ylim([0 10^-18]);
xlabel('频率 (Hz)');
ylabel('功率 (W)')


%{
figure(21);
%subplot(2,4,1);plot(t,gss);
%title('高斯色噪声');%axis([0 L -5 5]);
%subplot(2,4,2);plot(t,gss1);
%title('高斯色噪声均值');%axis([0 L -1 1]);
%subplot(2,4,3);plot(t,gss2);
%title('高斯色噪声方差');%axis([0 L -0.5 1.5]);
%subplot(2,4,4);plot(t,gss3);
%title('高斯色噪声均方值');%axis([0 L -0.5 1.5]);
%subplot(2,4,5);plot(lag,gss4);
%title('高斯色噪声自相关函数');%axis([-L L -0.5 1]);
%subplot(2,4,6);plot(gss5,f_g);
%title('高斯色噪声概率密度');
% subplot(2,1,1);
% plot(f1_gss,y_frequency_spectrum);
% title('高斯白噪声频谱');xlabel('f/Hz');ylabel('W/Hz');ylim([0 10^-6]);
% subplot(2,1,2);
plot(f2,y2);
title('高斯有色噪声频谱');xlabel('f/Hz');ylabel('W/Hz');ylim([0 10^-6]);

figure(31);
plot(f2,p2);
title('高斯有色噪声功率谱密度');xlabel('f/Hz');ylabel('W');ylim([0 10^-18]);

figure(4);
subplot(2,1,1);
plot(t_sim,xi,'b');xlabel('s');ylabel('V');
subplot(2,1,2);
plot(t_sim,gss,'r');xlabel('s');ylabel('V');
title('高斯白噪声方及有色噪声时域波形对比');
%}
%%%%%%%%%%%%%%%%%%%%%%% E 高斯有色噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end