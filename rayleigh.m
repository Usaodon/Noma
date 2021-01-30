function [h]=rayleigh(fd,t)

% Zheng Y R , Xiao C . Improved models for the generation of multiple 
%uncorrelated Rayleigh fading waveforms[J]. 
%IEEE Communications Letters, 2002, 6(6):256-258.
%���䲨N��Ϊ�ĸ����ޣ�N=4M��ÿ�����޾���pi/2
%wmΪ������Ƶ�ƵĽ�Ƶ
%real��ʾ�ź�ʵ����imag��ʾ�ź��鲿��PΪϵ��
%theta,f_real,f_imag������[-pi,pi)�Ͼ��ȷֲ����໥�������������
N=40;
M=N/4;
real=zeros(1,length(t));
imag=zeros(1,length(t));
A=sqrt(2/M);
theta=2*pi*rand(1,1)-pi;
for ii=1:M
    alfa(ii)=(2*pi*ii-pi+theta)/N;
    f_real=2*pi*rand(1,1)-pi;
    f_imag=2*pi*rand(1,1)-pi;
    real=real+cos(cos(alfa(ii))*2*pi*fd*t+f_real);           %���ݹ�ʽд���ʽ
    imag=imag+cos(sin(alfa(ii))*2*pi*fd*t+f_imag);
end
h=A*(real+1i*imag);