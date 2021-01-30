
    [ber1,ber2]=noma_1(2);
    [ber3,ber4]=noma_2(2);
    [ber5,ber6]=noma_3(2);
    [ber7,ber8]=noma_4(2);

EbNo=0:1:10;
figure(1)
semilogy(EbNo,ber2,'r',EbNo,ber4,'y',EbNo,ber6,'b');
%plot(EbNo,ber1,'r');
legend('a=0.4','a=0.3','a=0.2');
title('noma的误码率比较');
xlabel('信噪比EbNo(dB)');
ylabel('误比特率');

figure(2)
semilogy(EbNo,ber8,'r');
%plot(EbNo,ber2,'r');
legend('noma远处用户');
title('noma的误码率比较');
xlabel('信噪比EbNo(dB)');
ylabel('误比特率');