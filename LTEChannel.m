% *******************FUNCTION*************************
% FUNCTION:
% output=LTEChannel(K,totalframe,oversampl,channel_type)
% DESCRIPTION:
% This function is to generate the multipath channel
% INPUT:
% K: number of user;
% totalframe: total frames in simulation
% oversampl: the oversample points in one chip
% channel_type: the channel type, the choices of this paremeter are:...
% 'EPA','EVA','ETU'(LTE).
% OUTPUT:
% output: the output multipath fading signal.
% VERSION:  1.1 
% *****************************************************

function [output,channel_impulse,delay_number,tap_delay]=LTEChannel(totalframe,channel_type)

% K=128;
% totalframe=128;
% chipsPerFrame=12096;
% FilterDelay=8;
% Ns=totalframe*chipsPerFrame+2*FilterDelay;
% channel_type
%Tsample=.78125e-6;
Tsample=3.255*1e-8;
Ns=length(totalframe);

%---------------------multipath channel impulse-----------------%
% channel_impulse=multipath_sig(V,Tsample,Ns,'1'),a Ntap*Ns matrix
[channel_impulse,delay_number,tap_delay]=LTEMultipathSig(Tsample,Ns,channel_type);


% %---------------------with multipath singals--------------------%
% 
%  output=zeros(1,Ns);
%  output1=zeros(2,Ns);
% %compute every path of a OFDM symbol,then sum the paths into one singnal
%   for k=1:delay_number
%     output1(2,:)=totalframe(1,:).*channel_impulse(k,:);    
%     output1(1,:)=output(1,:)+output1(2,:);
%   end
% output(1,:)=output1(1,:);
% %------------without multipath singals--------------------------%
% output(1,:)=totalframe(1,:).*channel_impulse(1,:)

%------------unuseful code--------------------------------------%
% output1=zeros(Ns,Ns);  
% output2=zeros(Ns,Ns);
% output2(i,:)=output1(1,:);
% for j=2:Ns
%    output2(i,:)=[zeros(1,i-1), output1(i,1:Ns-i+1)];
% end
% for i=1:Ns
%     output(1,i)=sum(output2(:,i));
% end
out=zeros(delay_number,Ns);
framein=zeros(delay_number,Ns);
% channel_impulse;
% out(1,:)=channel_impulse(1,:);
for i=1:delay_number
    k=tap_delay(i);
    if k>=1
      framein(i,:)=[zeros(1,k),totalframe(1,1:Ns-k)];
    else
        framein(i,:)=totalframe;
    end
    out(i,:)=channel_impulse(i,:).*framein(i,:);
end

for i=1:Ns
    output(1,i)=sum(out(:,i));
end

% for i=1:delay_number
%     K=tap_delay(i);
%     if k>=1
%         frame(i,:)=[zeros(1,k),channel_impulse(1,1:Ns-k)];
%     else
%         frame(i,:)=frame;
%     end
% end





% %----------with nomultipath signals--------------% 
% framein(1,:)=totalframe(1,:);
% %output1=zeros(1,2Ns-1+320);
% output=zeros(1,Ns);
% output(1,:)=channel_impulse(1,:).*framein(1,:);
% %output=output(1:Ns+160);

 



% ************************* END ****************************
