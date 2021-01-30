function [ber1,ber2] = noma_3(user)

clear ;
%******************************��ʼ������**********************************%
user=2;
symbol_rate = 256000;                              %��������
symbol_num=10000;                                   %ÿ��������·��͵ķ�����
M=4;                                              %QAM����
bit_rate = symbol_rate* log2(M);                   %��������
EbNo=0:1:10;                                     %Eb/No�仯��Χ
graycode=[0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10];  %������˳��



%***************************��������˲�������******************************%
delay=10;                                          %�������˲���ʱ��
Fs=8;                                              %�˲�����������
b= 0.5;                                            %�������˲�����������
filter1 = rcosine(1,Fs,'fir/sqrt',b,delay);        %��Ƹ��������˲���


%   [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY) specifies the filter
%	delay in DELAY, which must be a positive integer. DELAY/Fd is the
%	filter delay in seconds.



%*******************************˥���ŵ�����*******************************%
ts =1/Fs/symbol_rate;                  %�ŵ�����ʱ����
t=(0:symbol_num*Fs+2*delay*Fs-1)*ts;   %ÿ��������µķ��Ŵ���ʱ��,��ʱ������Ϊ1*8160�������ϸ��rcosflt����Ľ������һ��
fd= 160;                                           %������Ƶ��
%h_close=go_LTEchannel(ts,'EPA',50);
%h_far=go_LTEchannel(ts,'EVA',50);
%h_close=0.6*rayleigh(fd,t);                                  %����˥���ŵ�
%h_far=0.4*rayleigh(320,t);
h_close=LTEMultipathSig(1/8/256000,80160,'EPA');
h_far=LTEMultipathSig(1/8/256000,80160,'EVA');


%********************************���濪ʼ**********************************%
for indx= 1:length(EbNo)

    
%********************************�����************************************%
data= randsrc(2,symbol_num,[0:1]);             %���������û��ķ�������2*1000
data1=graycode(data+1);                            %������ӳ��


%data1 = qammod(data1,M);                           %16-QAM����
                                                   %data1��1*1000����
data1 = pskmod(data1,M);                                                   
data2=data1(1,:);
data3=data1(2,:);
out=data1;                                                   
out1=rcosflt(out.',symbol_rate,Fs*symbol_rate,'filter',filter1);
%out1=out1.';                                       %ת��˳��ɸı䣬��������������.out1Ϊ8160*2
%'filter' Means the filter is provided by the user.  When using the 'filter'
%            TYPE_FLAG, the input parameters are:
%
%            Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, NUM) - filters with a user-
%            supplied FIR filter.  When the TYPE_FLAG contains 'filter' and
%            the 'fir' type substrings, the FIR filter indicated by NUM is
%            used to filter X.Y�ĳ��ȣ�Fs/Fd * (length(X) + 2 * DELAY)



%signal_power=sum(abs(out1).^2)/symbol_num;         %ÿ�����ŵ�����
out1=out1.';
x1=out1(1,:)*0.6;
x2=out1(2,:)*0.4;
out_1=zeros(1,80160);
if user>1
    out_1=x1+x2;                              %ÿ���û�����������ŵ���outΪ1*8160
    signal_power=sum(abs(out_1).^2)/symbol_num;         %ÿ�����ŵ�����
end
%********************************ͨ�������ŵ�******************************%
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

%********************************Զ�����ն�*********************************%
sigma=sqrt(0.5*signal_power*symbol_rate/bit_rate*10^(-EbNo(indx)/10));
                                                   %����˫�߹������ܶ�1*8160
                                                
y_far=zeros(7,80160);                               %��ʼ���������
                                                   %��·���
for i=1:7                                                   
    output_far(i,:)=output_far(i,:)./h_far(i,:);
    y_far(i,:)=output_far(i,:)+sigma*(randn(1,length(output_far(i,:)))+1i*randn(1,length(output_far(i,:)))); 
end
                                                   %��������
    %y_far=y_far./h_far;                           %�����ŵ�����                                          
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
%               length(X) + Fs/Fd * 2 * DELAY.     %yΪ8320*1

y_far_1=downsample(y_far_0,Fs);                            %yΪ1040*1
    y1_far(:,1)=y_far_1(2*delay+1:end-2*delay,1);          %ȥ��ǰ����ʱ
yd_far=y1_far.';                                           %ydΪ1*1000
%yd_far= equalize(lineareq(5, lms(0.01),qammod([0,1],16)),yd_far, data2);
yd_far(1)=3-1i;
demodata_far=pskdemod(yd_far,M);                           %���
demodata_far=graycode(demodata_far+1);                     %����



%*********************************�������ն�*******************************%
%sigma=sqrt(0.5*signal_power*symbol_rate/bit_rate*10^(-EbNo(indx)/10));
                                                   %����˫�߹������ܶ�
y_close=zeros(7,80160);                             %��ʼ���������
                                                   %��·���
for i=1:7
    output_close(i,:)=output_close(i,:)./h_close(i,:);
    y_close(i,:)=output_close(i,:)+sigma*(randn(1,length(output_close(i,:)))+1i*randn(1,length(output_close(i,:))));  
end                                    
                                                   %��������
    %y_close=y_close./h_close;                     %�����ŵ�����
    re_data=graycode(demodata_far+1);              %�ź��ع�
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
%               length(X) + Fs/Fd * 2 * DELAY.     %yΪ8320*1

y_close=downsample(y_close,Fs);                              %yΪ1040*1
y1_close(:,1)=y_close(2*delay+1:end-2*delay,1);              %ȥ��ǰ����ʱ

yd_close=y1_close.';      %ydΪ1*1000
%yd_close= equalize(lineareq(5, lms(0.01),qammod([0,1],16)),yd_close, data3);

demodata_close=pskdemod(yd_close,M);                         %���
demodata_close=graycode(demodata_close+1);

[error,ber1(indx)]=biterr(data(1,:),demodata_far,log2(M)); 
[error,ber2(indx)]=biterr(data(2,:),demodata_close,log2(M)); 
                                                   %�����������
end