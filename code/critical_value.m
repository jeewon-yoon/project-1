for i = 1:1:116
    for j = 1:1:116
        tval=[]; tind=[];
        [tval,tind] = sort(squeeze(Value(i,j,:)),'ascend');
        crit_value(i,j) = tval(round(0.95*5000));
    end
end