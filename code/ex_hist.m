figure;
KK = [];
KK = squeeze(Value(1,4,:));
hist(KK,500);
hold on;
plot(KK(end),0,'rx','Markersize',10,'LineWidth',3);