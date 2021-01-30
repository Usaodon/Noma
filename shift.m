function [out]=shift(in,shiftr)
%完成m序列的循环移位

l=length(in);
out=in;
shiftr=rem(shiftr,l);                         %取移动位数关于码长的余数

out(:,1:shiftr)=in(:,l-shiftr+1:l);           %输出的最后shiftr位移到前shiftr位上
out(:,1+shiftr:l)=in(:,1:l-shiftr);           %其余位数依次移位
end 