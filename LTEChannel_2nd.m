function [output]=LTEChannel_2nd(totalframe,channel_impulse,delay_number,tap_delay)
Tsample=3.255*1e-8;
Ns=length(totalframe);
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