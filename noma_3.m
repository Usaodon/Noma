function [ber1,ber2] = noma_3(user)

clear ;
%******************************初始化部分**********************************%
user=2;
symbol_rate = 256000;                              %符号速率
symbol_num=10000;                                   %每种信噪比下发送的符号数
M=4;                                              %QAM调制
bit_rate = symbol_rate* log2(M);                   %比特速率
EbNo=0:1:10;                                     %Eb/No变化范围
graycode=[0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10];  %格雷码顺序



%***************************脉冲成形滤波器参数******************************%
delay=10;                                          %升余弦滤波器时延
Fs=8;                                              %滤波器过采样数
b= 0.5;                                            %升余弦滤波器滚降因子
filter1 = rcosine(1,Fs,'fir/sqrt',b,delay);        %设计根升余弦滤波器


%   [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY) specifies the filter
%	delay in DELAY, which must be a positive integer. DELAY/Fd is the
%	filter delay in seconds.



%*******************************衰落信道参数*******************************%
ts =1/Fs/symbol_rate;                  %信道采样时间间隔
t=(0:symbol_num*Fs+2*delay*Fs-1)*ts;   %每种信噪比下的符号传输时间,且时间序列为1*8160，必须严格和rcosflt输出的结果保持一致
fd= 160;                                           %多普勒频移
%h_close=go_LTEchannel(ts,'EPA',50);
%h_far=go_LTEchannel(ts,'EVA',50);
%h_close=0.6*rayleigh(fd,t);                                  %生成衰落信道
%h_far=0.4*rayleigh(320,t);
h_close=LTEMultipathSig(1/8/256000,80160,'EPA');
h_far=LTEMultipathSig(1/8/256000,80160,'EVA');


%********************************仿真开始**********************************%
for indx= 1:length(EbNo)

    
%********************************发射端************************************%
data= randsrc(2,symbol_num,[0:1]);             %产生各个用户的发射数据2*1000
data1=graycode(data+1);                            %格雷码映射


%data1 = qammod(data1,M);                           %16-QAM调制
                                                   %data1是1*1000矩阵
data1 = pskmod(data1,M);                                                   
data2=data1(1,:);
data3=data1(2,:);
out=data1;                                                   
out1=rcosflt(out.',symbol_rate,Fs*symbol_rate,'filter',filter1);
%out1=out1.';                                       %转置顺序可改变，方便下面求能量.out1为8160*2
%'filter' Means the filter is provided by the user.  When using the 'filter'
%            TYPE_FLAG, the input parameters are:
%
%            Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, NUM) - filters with a user-
%            supplied FIR filter.  When the TYPE_FLAG contains 'filter' and
%            the 'fir' type substrings, the FIR filter indicated by NUM is
%            used to filter X.Y的长度：Fs/Fd * (length(X) + 2 * DELAY)



%signal_power=sum(abs(out1).^2)/symbol_num;         %每个符号的能量
out1=out1.';
x1=out1(1,:)*0.6;
x2=out1(2,:)*0.4;
out_1=zeros(1,80160);
if user>1
    out_1=x1+x2;                              %每个用户混叠，送入信道，out为1*8160
    signal_power=sum(abs(out_1).^2)/symbol_num;         %每个符号的能量
end
%********************************通过瑞利信道******************************%
%out_close=filter(h_close,out_1);
%out_far=filter(h_far,out_1);
%out_close=h_close.*out_1;
%out_far=h_far.*out_1;
%out_close=0.8*out_1;
%out_far=0.6*out_1;
output_close=zeros(7,80160);
output_far=zeros(7,80160);
for i=1:7
    output_close(i,:)=out_1.*h_close(i,:);
    output_far(i,:)=out_1.*h_far(i,:);
end

%********************************远处接收端*********************************%
sigma=sqrt(0.5*signal_power*symbol_rate/bit_rate*10^(-EbNo(indx)/10));
                                                   %计算双边功率谱密度1*8160
                                                
y_far=zeros(7,80160);                               %初始化输出序列
                                                   %分路输出
for i=1:7                                                   
    output_far(i,:)=output_far(i,:)./h_far(i,:);
    y_far(i,:)=output_far(i,:)+sigma*(randn(1,length(output_far(i,:)))+1i*randn(1,length(output_far(i,:)))); 
end
                                                   %加入噪声
    %y_far=y_far./h_far;                           %理想信道估计                                          
    %h_ls_far=1/7*(h_far(1,:)+h_far(2,:)+h_far(3,:)+h_far(4,:)+h_far(5,:)+h_far(6,:)+h_far(7,:));
    y_far_2=zeros(1,80160);
    y_far_2=1/7*(y_far(1,:)+y_far(2,:)+y_far(3,:)+y_far(4,:)+y_far(5,:)+y_far(6,:)+y_far(7,:));
    %y_far_2=y_far_2.*(((h_ls_far'*h_ls_far+sigma^2*eye(8160,8160))\h_ls_far').');
y_far_0=rcosflt(y_far_2.',symbol_rate,Fs*symbol_rate,'Fs/filter',filter1);

%   'Fs'     X is input with sample frequency Fs (i.e., the input signal has
%            Fs/Fd samples per symbol). In this case the input signal is not
%            upsampled from Fd to Fs but is simply filtered by the raised
%            cosine filter.  This is useful for filtering an oversampled data
%            stream at the receiver.  When using the 'Fs' substring, the length
%            of vector, Y is
%               length(X) + Fs/Fd * 2 * DELAY.     %y为8320*1

y_far_1=downsample(y_far_0,Fs);                            %y为1040*1
    y1_far(:,1)=y_far_1(2*delay+1:end-2*delay,1);          %去掉前后延时
yd_far=y1_far.';                                           %yd为1*1000
%yd_far= equalize(lineareq(5, lms(0.01),qammod([0,1],16)),yd_far, data2);
yd_far(1)=3-1i;
demodata_far=pskdemod(yd_far,M);                           %解调
demodata_far=graycode(demodata_far+1);                     %解码



%*********************************近处接收端*******************************%
%sigma=sqrt(0.5*signal_power*symbol_rate/bit_rate*10^(-EbNo(indx)/10));
                                                   %计算双边功率谱密度
y_close=zeros(7,80160);                             %初始化输出序列
                                                   %分路输出
for i=1:7
    output_close(i,:)=output_close(i,:)./h_close(i,:);
    y_close(i,:)=output_close(i,:)+sigma*(randn(1,length(output_close(i,:)))+1i*randn(1,length(output_close(i,:))));  
end                                    
                                                   %加入噪声
    %y_close=y_close./h_close;                     %理想信道估计
    re_data=graycode(demodata_far+1);              %信号重构
    re_data = pskmod(re_data,M);
    re_data=rcosflt(re_data,symbol_rate,Fs*symbol_rate,'filter',filter1);
    re_data=re_data.';
for i=1:7
    y_close(i,:)=(y_close(i,:)-re_data*0.6)/0.4;
end
    
    
    
    %y_close=y_close-y_far;
    y_close_2=zeros(1,80160);
    y_close_2=1/7*(y_close(1,:)+y_close(2,:)+y_close(3,:)+y_close(4,:)+y_close(5,:)+y_close(6,:)+y_close(7,:));
y_close=rcosflt(y_close_2.',symbol_rate,Fs*symbol_rate,'Fs/filter',filter1);

%   'Fs'     X is input with sample frequency Fs (i.e., the input signal has
%            Fs/Fd samples per symbol). In this case the input signal is not
%            upsampled from Fd to Fs but is simply filtered by the raised
%            cosine filter.  This is useful for filtering an oversampled data
%            stream at the receiver.  When using the 'Fs' substring, the length
%            of vector, Y is
%               length(X) + Fs/Fd * 2 * DELAY.     %y为8320*1

y_close=downsample(y_close,Fs);                              %y为1040*1
y1_close(:,1)=y_close(2*delay+1:end-2*delay,1);              %去掉前后延时

yd_close=y1_close.';      %yd为1*1000
%yd_close= equalize(lineareq(5, lms(0.01),qammod([0,1],16)),yd_close, data3);

demodata_close=pskdemod(yd_close,M);                         %解调
demodata_close=graycode(demodata_close+1);

[error,ber1(indx)]=biterr(data(1,:),demodata_far,log2(M)); 
[error,ber2(indx)]=biterr(data(2,:),demodata_close,log2(M)); 
                                                   %计算误比特率
end