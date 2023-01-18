for k=1:5000
    disp(num2str(k))
    rand_ind = randperm(n1+n2);    
    ADHD_12 = Group_12(:,:,rand_ind(1:n1));    
    Con_12 = Group_12(:,:,rand_ind(n1+1:n1+n2));   
    for i=1:116
        for j=1:116
            CI = [ ]; STATS = [ ];
            [H(i,j),P(i,j),CI,STATS] = ttest2(ADHD_12(i,j,:), Con_12(i,j,:));
            tstat_null(i,j,k) = STATS.tstat;
        end
    end
end
