function [Npinp,F,Pxx,fr]=noise_asynchronous(custom,npc,ntv) %与工频异步的噪声
%调用默认参数方式：noise_asynchronous(0)

%输入参数：
%custom=0,采用系统默认参数；custom非零时，采用用户自定义参数；
%npc：用户设置的PC机的个数，npc在1到23之间；
%ntv：用户设置的TV机的个数，ntv在1到23之间；

%输出参数：
%Npinp:窄带噪声
%F:输出的频谱
%Pxx:输出的功率谱
%fr:频域上采样频率
%clc;
%clf;

if custom==0
    Npc=1+round(10*rand);
    Ntv=1+round(10*rand);
else
    Npc=npc;
    Ntv=ntv;
end

Fpc=[30 120];
Fpc=Fpc*10^3;%PC显示器行扫描频率,转换后单位Hz
Ftv1=[15.75 15.625];
Ftv1=Ftv1*10^3;%TV行扫描频率,转换后单位Hz
Ftv2=[28 33 45 120];
Ftv2=Ftv2.*10^3;%单位kHz
Tw=[5 20];
Tw=Tw*10^-6;%脉冲宽度,转换后单位s
Aback=[-65 -85];%背景噪声的db数
Apinp=(10.^(([Aback(1)+40 Aback(2)+10]+48.75)/20)).*10^-3;%需要再考虑，Npinp的噪声幅值，不过好象有点不对,单位为V
Fsin=[0.5 30];%脉冲内正弦波的频率，单位MHz。
Fsin=Fsin*10^6;%脉冲内正弦波频率，取给定频率范围内的均匀分布

ts=1/(6*10^7);%1.67*10^-8;
fs=6*10^7;
t=0:ts:0.02;
l=length(t);%仿真长度0.02s,采样间隔按1/60M，产生的噪声长度就相当于对是及噪声的采样了
if ((Npc>=2)&&(Ntv>=2))
%产生Noisepc，电脑显示器产生的噪声
    a=Apinp(2)+rand(1,Npc)*(Apinp(1)-Apinp(2)); %幅值
    tw=Tw(1)+rand(1,Npc)*(Tw(2)-Tw(1)); %脉宽
    fsin=Fsin(1)+(Fsin(2)-Fsin(1))*rand(1,Npc);
    PHY=2*pi*rand(1,Npc);
    
    f=Fpc(1)+rand(1,Npc)*(Fpc(2)-Fpc(1));
    T=1./f;
    x=find(T(:)<tw(:));
    T(x)=T(x)+abs(max(Tw)-1/max(Fpc));
    y=find(T(:)<tw(:));
    td=rand*(T(:)-tw(:));  %脉冲出现时间

    tdc=fix(td/ts);
    for i=1:Npc
    %产生一个T(i)内的数据，然后重复就可以了
    tcw=tw/5;%时间常数
    N=a(i)*exp(-t/tcw(i)).*sin(2*pi*fsin(i)*t+PHY(i));%所有的第一个脉冲都在同一时间出现，没有加上一个随机的开始时间。
    Noisepc(i,tdc(i):l)=N(1:length(tdc(i):l));
    k=find(abs(T(i)-t(:))<ts/2);
    lNpc(i)=k;
        for m=k+1:l
            Noisepc(i,m)=Noisepc(i,m-k);
        end
    end
   Npinppc=sum(Noisepc(:,:));
 


%产生Noisetv，电视显示器产生的噪声
    a=Apinp(1)+rand(1,Ntv)*(Apinp(2)-Apinp(1)); %幅值
    tw=Tw(1)+rand(1,Ntv)*(Tw(2)-Tw(1)); %脉宽
    fsin=Fsin(1)+(Fsin(2)-Fsin(1))*rand(1,Ntv);
    PHY=2*pi*rand(1,Ntv);
    f=Ftv2(1)+rand(1,Ntv)*(Ftv2(4)-Ftv2(1));
    f(1)=Ftv1(1+fix(rand*2));
    T=1./f;
    x=find(T(:)<tw(:));
    T(x)=T(x)+abs(max(Tw)-1/max(Ftv2));
    y=find(T(:)<tw(:));
    td=rand*(T(:)-tw(:));

    tdc=fix(td/ts);
    for i=1:Ntv
    %产生一个T(i)内的数据，然后重复就可以了
    tcw=tw/5;
    N=a(i)*exp(-t/tcw(i)).*sin(2*pi*fsin(i)*t+PHY(i));%所有的第一个脉冲都在同一时间出现，没有加上一个随机的开始时间。
    Noisetv(i,tdc(i):l)=N(1:length(tdc(i):l));
    k=find(abs(T(i)-t(:))<ts/2);
    lNtv(i)=k;
        for m=k+1:l
            Noisetv(i,m)=Noisetv(i,m-k);
        end
    end
    Npinptv=sum(Noisetv(:,:));
   
    Npinp=Npinppc+Npinptv;
else
    Npinp=zeros(1,l);
end

figure(1)
plot(t,Npinp)
%title('异步于工频的周期脉冲噪声');
xlabel('时间 (s)');
ylabel('幅度 (V)');

%求频谱密度
[F,fr]=freqspec(Npinp,fs);
figure(2);
plot(fr,F);
%title('异步于工频的周期脉冲噪声频谱');
xlabel('频率 (Hz)');
ylabel('幅度 ');

%求功率谱密度 
Pxx = 1/l * F.*conj(F);
figure(3);
plot(fr,Pxx);
%title('异步于工频的周期脉冲噪声功率谱密度');
xlabel('频率 (Hz)');
ylabel('功率 (W)');
