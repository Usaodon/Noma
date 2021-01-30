% *******************FUNCTION*************************
% FUNCTION:
% out=LTEMultipathSig(channel_type)
% ****************************************************
% INPUT:
% channel_type: the channel type, the choices of this paremeter are:...
% 'EPA','EVA','ETU'(LTE).
% OUTPUT
% output: the multipath fading signals
% Author:Shao Daojiong
% *****************************************************

function [out,M,tap_delay]=LTEMultipathSig(Tsample,Ns,channel_type)
%Ns is the number of the slot in a subframe
% choose the channel model

[tap_gain,tap_delay_org,v]=LTEChannelModel(channel_type);
tap_delay=floor(tap_delay_org/Tsample);
% the number of taps
M=length(tap_gain);
% the max. tap_delay
max_delay=max(tap_delay);

%generate the max. Doppler frequency shift
fc=2e9;
fd=v*fc/3.6/3e8; 
Wm = 2*pi*fd;   

% generate the n-th arrival angle for the k-th fader
N0 = 40;
N = 4*N0;       %generate one fader need N incident waves with random phases and equally spaced arrival angles
for n=1:N0
    for k=1:M
        alpha(n,k)= 2*pi*n/N+2*pi*k/(M*N)+pi/(2*M*N);
    end % for  k=1:M
end % for n=1:N0

init = 1e5;  %something big as the start point for the random rayleigh fading processing
%Ns=100;
alpha;
alphasize=size(alpha);
tap_phase = 2*pi*rand(N0,M);%generate random phase
sizephase=size(tap_phase);
t=[1+1e5:Ns+1e5];%form Ns sample points
p=ones(1,Ns);
%generate the normalised Rayleigh signal and form the Tapped Delay Line Model
for k=1:M
        T=sqrt(1/N0)*sum(cos(Wm*cos(alpha(:,k))*t*Tsample*2+ tap_phase(:,k)*p) + ...
        sqrt(-1)*sin(Wm*sin(alpha(:,k))*t*Tsample*2+ pi+tap_phase(:,k)*p)); 
    
       if Ns > 1  %continuouse in time; otherwise (if Nchannel==1) --> random point
          T= T/sqrt(sum(abs(T).^2)/Ns);   % total power of all the path has been normalised into 1
       end
       
      output(k,:)=tap_gain(1,k)*T;% different tapped coefficients
      channel(k,:)=[zeros(1,tap_delay(k)), output(k,1:end-tap_delay(k))]; %Tapped Delay Line Model from M users
      
end % k=1:M
%generate the multipath fading signals,it is a M*Ns matrix

out=channel;


%plot the PDF of magnitude of T and show its Rayleigh distribution
t1=abs(T);
[f,xi] = ksdensity(t1); %generate the PDF of t1
% plot(xi,f);
% xlabel('r'),ylabel('p(r)');
% 
% i=1:Ns;
% plot(i,out(1,1:Ns));
