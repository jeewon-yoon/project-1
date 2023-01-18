
for i=1:2
    for j=1:2
        X_tmp = []; Y_tmp = []; 
        X_tmp = squeeze(J(i,j,:));
        Y_tmp = squeeze(K(i,j,:));
    end
end