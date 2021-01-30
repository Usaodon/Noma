function out=despread(data,code)
%解扩函数

[m1,n1]=size(data);
[m2,n2]=size(code);

out=zeros(m2,n1/n2);                           %初始化4*1000

for ii=1:m2                                    
    xx=reshape(data(ii,:),n2,n1/n2);           %重塑data7*1000
    out(ii,:)=code(ii,:)*xx/n2;              
end