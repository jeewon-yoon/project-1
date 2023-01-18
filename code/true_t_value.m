load ADHD_7;
load Con_7;
for i=1:1:116
    for j=1:1:116
        X_tmp = []; Y_tmp = []; CI = []; STATS = [];
        X_tmp = squeeze(ADHD_7(i,j,:));
        Y_tmp = squeeze(Con_7(i,j,:));
        [H(i,j),P(i,j),CI,STATS] = ttest2(X_tmp,Y_tmp);
        real_T(i,j) = STATS.tstat;
    end
end