function [out]=shift(in,shiftr)
%���m���е�ѭ����λ

l=length(in);
out=in;
shiftr=rem(shiftr,l);                         %ȡ�ƶ�λ�������볤������

out(:,1:shiftr)=in(:,l-shiftr+1:l);           %��������shiftrλ�Ƶ�ǰshiftrλ��
out(:,1+shiftr:l)=in(:,1:l-shiftr);           %����λ��������λ
end 