function [out]=spread(data,code)
%扩频函数

[m1,n1]=size(data);
[m2,n2]=size(code);

if m1>m2
    error('???');
end

out=zeros(m1,n1*n2);                            %初始化

for ii=1:m1
    out(ii,:)=reshape(code(ii,:).'*data(ii,:),1,n1*n2);
                                               %重塑矩阵
    
end