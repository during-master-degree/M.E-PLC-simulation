function [Nran,F,Pxx,fr]=noise_rand(custom,nums)%随机脉冲噪声
%调用默认参数方式：noise_rand(0)

%输入参数：
%custom=0，表示使用默认参数；否则使用输入的nums
%nums：随机脉冲噪声个数，可以为0

%输出参数：
%t:输出时间
%Nran:异步随机噪声
%F:输出的频谱
%Pxx:输出的功率谱
%fr:频域上采样频率
%clf;
%clc;

if custom==0
   l1=1+round(15*rand);%l1-合成的信号中随机脉冲的个数
else
    l1=nums;
end 

amp=ranimpulseamp(l1);%产生幅值，单位V
tw=ranimpulsetw(l1);%脉宽，单位us
td=ranimpulsetd(l1);%脉冲间隔，单位ms
tw=tw*10^-6;%转化为秒
td=td*10^-3;%转化为秒
td=td/35;%压缩时域范围
Fsin=[0.5 3];%脉冲内正弦波的频率，单位MHz。
Fsin=Fsin*10^6; %脉冲内的正弦波频率，暂时取500kHz——3MHz范围内，其实>3MHz范围的还有。%脉冲内正弦波频率，取给定频率范围内的均匀分布

tcw=tw/5;%tcw-指数衰减的时间常数
fsin=Fsin(1)+(Fsin(2)-Fsin(1))*rand(1,l1);

ts=1/(6*10^7);%10^-6;
fs=6*10^7;
t=0:ts:0.02;
l=length(t);%l=500001
st=0;
ranimpulse=zeros(1,l);

for i=1:l1
    N1=zeros(1,l);
    tem=st;
    st=st+tw(i)+td(i);
    t1=0:ts:st;
    N=amp(i)*exp(-(t1)/tcw(i)).*sin(2*pi*fsin(i)*t1+2*pi*rand);
    temc=floor(tem/ts)+1;
    stc=floor(st/ts);
    N1(temc:stc)=N(1:length(temc:stc));
    if(length(ranimpulse)>length(N1))
       N1((length(N1)+1):length(ranimpulse))=zeros(1,(length(ranimpulse)-length(N1)));
    end   
    if(length(ranimpulse)<length(N1))
       N1=N1(1:l);
    end 
    ranimpulse=ranimpulse+N1;
end
Nran=ranimpulse;

figure(1);
%title('随机脉冲噪声');
plot(t,Nran);
xlabel('时间 (s)');
ylabel('幅度 (V)');

% plot(t,ranimpulse)
%求频谱密度
[F,fr]=freqspec(Nran,fs);
figure(2)
plot(fr,F);
xlabel('频率 (Hz)');
ylabel('幅度');


%求功率谱密度
Pxx = 1/l * F.*conj(F);
figure(3)
plot(fr,Pxx);
xlabel('频率 (Hz)');
ylabel('功率 (W)');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [amp]=ranimpulseamp(l2) 
%生成100个符合要求的脉冲幅度amp,单位V

% clear;
% clc;
xamp=[0 0.2 1.06 2
     1 0.1 0.01 0];
l1=length(xamp);l=l1-1;
b=zeros(1,l2);
for i=1:l
    as(i)=fix(l2*(xamp(2,i))-fix(l2*xamp(2,i+1))); %计各区间分布的数据个数
    b(i,1:as(i))=xamp(1,i)+(xamp(1,i+1)-xamp(1,i))*rand(1,as(i)); %产生各个区间应该有的数据
end

d=b(find(b))';
for i=1:l
    ca(i)=length(find(b>xamp(1,i)&b<xamp(1,i+1)|b==xamp(1,i+1)));
end

hold on
cac=zeros(1,l1);
for i=1:l
    cac(i)=sum(ca(i:l))/l2;
end

amp=d(randperm(l2));


function td=ranimpulsetd(l2)%l2-产生数据的个数
%生成100个符合要求的脉冲间隔tIAT,程序中写成td均为tIAT
% clear all;
% clc;
xd=[0	0.4	     1.2	2.4	    4	    6	    8.4	     11.2	 14.4	18	    22	    26.4	31.2	36.4	42	    48	    54.4	61.2	 68.4	 76	     84
    1	0.9574	0.90015	0.84546	0.7868	0.72798	0.67383	0.62746	0.59014	0.56163	0.54069	0.52563	0.51479	0.50674	0.50041	0.49506	0.49024	0.4857	0.48129	0.47697	0.47272  ];

xd=[xd,[100;0]];
l1=length(xd);%%l1-xd的长度,l1=22
l=l1-1;%l=21;

b=zeros(1,l2);
for i=1:l
    as(i)=fix(l2*(xd(2,i))-fix(l2*xd(2,i+1))); %计各区间分布的数据个数
    b(i,1:as(i))=xd(1,i)+(xd(1,i+1)-xd(1,i))*rand(1,as(i)); %产生各个区间应该有的数据
end

d=b(find(b))';%find结果为一列，故需转置
% for i=1:l
%     ca(i)=length(find(b>xd(1,i)&b<xd(1,i+1)|b==xd(1,i+1)));
% end
%
% cac=zeros(1,l1);
% for i=1:l
%     cac(i)=sum(ca(i:l))/l2;
% end
% figure(4);
% plot(xd(1,:),cac,'p');

td=d(randperm(l2));%randperm打乱数组顺序
kk=3;


function tw=ranimpulsetw(l2)
%生成100个符合要求的脉冲宽度tw
% clear all;
% clc;
xw=[0	5	15	30	50	75	105	140	180	225	275	330	390	455	525 680 950
1	0.94819	0.85289	0.72853	0.59218	0.4597	0.34287	0.24801	0.17634	0.12541	0.090933	0.068334	0.053697	0.044067	0.037395  0.028175 0.018305
];

%变量说明:
%l1-xw的长度
%l2-产生数据的个数
xw=[xw,[1000;0]];
l1=length(xw);l=l1-1;%l2=100;

b=zeros(1,l2);
for i=1:l
    as(i)=fix(l2*(xw(2,i))-fix(l2*xw(2,i+1))); %计各区间分布的数据个数
    b(i,1:as(i))=xw(1,i)+(xw(1,i+1)-xw(1,i))*rand(1,as(i)); %产生各个区间应该有的数据
end

d=b(find(b))';
for i=1:l
    ca(i)=length(find(b>xw(1,i)&b<xw(1,i+1)|b==xw(1,i+1)));
end

hold on
cac=zeros(1,l1);
for i=1:l
    cac(i)=sum(ca(i:l))/l2;
end

tw=d(randperm(l2));