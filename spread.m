function [out]=spread(data,code)
%��Ƶ����

[m1,n1]=size(data);
[m2,n2]=size(code);

if m1>m2
    error('???');
end

out=zeros(m1,n1*n2);                            %��ʼ��

for ii=1:m1
    out(ii,:)=reshape(code(ii,:).'*data(ii,:),1,n1*n2);
                                               %���ܾ���
    
end