for i = 1:1:116
    for j = 1:1:116
        kval=[]; kind=[];
        [kval,kind] = sort(squeeze(Value(i,j,:)),'ascend');
        pval(i,j) = find(kind==5001)/5001;
    end
end
