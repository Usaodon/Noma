function [h]=rayleigh(fd,t)

% Zheng Y R , Xiao C . Improved models for the generation of multiple 
%uncorrelated Rayleigh fading waveforms[J]. 
%IEEE Communications Letters, 2002, 6(6):256-258.
%入射波N分为四个象限，N=4M，每个象限距离pi/2
%wm为多普勒频移的角频
%real表示信号实部，imag表示信号虚部，P为系数
%theta,f_real,f_imag都是在[-pi,pi)上均匀分布且相互独立的随机变量
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
    real=real+cos(cos(alfa(ii))*2*pi*fd*t+f_real);           %根据公式写表达式
    imag=imag+cos(sin(alfa(ii))*2*pi*fd*t+f_imag);
end
h=A*(real+1i*imag);