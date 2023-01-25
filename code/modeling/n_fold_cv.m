% ------------ INPUTS -------------------
mats = ARS_matrix_Z;  
behav = ARS_impulse_score;  
age = ARS_age; 
thresh = 0.01;
no_node = 116;

% N-fold cross-validation

% Before dividing the sets into n folds randomize subjects
A = randperm(299);
mats = mats(:,:,A);
behav = behav(A,1);
age = age(A,1);

% Next, make 3 cells(1xN) for each variable(brain_conn_matrix, behavior_score, age)

cell_mat = cell(1,5);
for i = 1:4
    cell_mat{1,i} = mats(:,:,60*(i-1)+1:60*i);
end
cell_mat{1,5} = mats(:,:,241:299);

cell_behav = cell(1,5);
for i = 1:4
    cell_behav{1,i} = behav(60*(i-1)+1:60*i,:);
end
cell_behav{1,5} = behav(241:299,:);

cell_age = cell(1,5);
for i = 1:4
    cell_age{1,i} = age(60*(i-1)+1:60*i,:);
end
cell_age{1,5} = age(241:299,:);
    

% test each fold (iteration n times)
    n = 5;
        
for testfold = 1:5;
    
    fprintf('\n Leaving out each fold # %6.3f',testfold);
     
    % leave out testfold from matrices and behavior (and age) and collect
    % the leftout set which becomes the training set
    
    mat_cell = cell_mat;
    test_mat = mat_cell(:,testfold);
    mat_cell{1,testfold} = [];
    train_mats = cat(3,mat_cell{1,1:5}); % n = 5
    train_vcts = reshape(train_mats,[],size(train_mats,3)); % 299-onefold ¸í¼öÀÇ columns
    
    behav_cell = cell_behav;
    test_behav = behav_cell(:,testfold);
    behav_cell{1,testfold} = [];
    train_behav = cat(1,behav_cell{1,1:5}); % 2Â÷¿øÀ¸·Î combine
    
    age_cell = cell_age;
    test_age = age_cell{:,testfold};
    age_cell{1,testfold} = [];
    train_age = cat(1,age_cell{1,1:5});
    
    % correlate all edges with behavior
    [r_mat,p_mat] = partialcorr(train_vcts', train_behav, train_age);
    
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);
    
    % set threshold and define masks
    
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);
    
    pos_edges = find(r_mat > 0 & p_mat < thresh);
    neg_edges = find(r_mat < 0 & p_mat < thresh);
    
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    
    % get sum of all edges in TRAIN subs (divide by 2 to control for the
    % fact that matrices are symmetric)
    
    train_sumpos = zeros(length(train_behav),1);
    train_sumneg = zeros(length(train_behav),1);
    
    for ss = 1:length(train_sumpos);
        train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
        train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
    end
    
    % build model on TRAIN sets
    fit_pos = polyfit(train_sumpos, train_behav,1);
    fit_neg = polyfit(train_sumneg, train_behav,1);
        
    % run model on TEST sets
    % convert cell(test_mat) to double(3-D)
    test_mats = cell2mat(test_mat); 
    test_behavs = cell2mat(test_behav);
    
    test_sumpos = zeros(size(test_mats,3),1);
    test_sumneg = zeros(size(test_mats,3),1);
    
    for kk = 1:size(test_mats,3);
        test_sumpos(kk) = sum(sum(test_mats(:,:,kk).*pos_mask))/2;
        test_sumneg(kk) = sum(sum(test_mats(:,:,kk).*neg_mask))/2;
    end
    
    behav_pred_pos = zeros(size(test_mats,3),1);
    behav_pred_neg = zeros(size(test_mats,3),1);
    
    for tt = 1:length(behav_pred_pos);
        behav_pred_pos(tt) = fit_pos(1)*test_sumpos(tt) + fit_pos(2);
        behav_pred_neg(tt) = fit_neg(1)*test_sumneg(tt) + fit_neg(2);
    end
    
    % compare predicted and observed scores
    
    [R_pos(testfold), P_pos(testfold)] = corr(behav_pred_pos,test_behavs);
    [R_neg(testfold), P_neg(testfold)] = corr(behav_pred_neg,test_behavs);
    
    MSE_pos(testfold) = sum((behav_pred_pos-test_behavs).^2)/(length(test_behavs)-length(fit_pos)-1);
    MSE_neg(testfold) = sum((behav_pred_neg-test_behavs).^2)/(length(test_behavs)-length(fit_neg)-1);
    
    figure(testfold); 
    subplot(2,1,1); scatter(test_behavs,behav_pred_pos,'ro','fill'); lsline; hold on;
    xlabel('Observed Hyperactive Score','FontSize',12)
    ylabel('Positive Predicted Hyperactive Score','FontSize',11)
    axis([0 30 0 30])
    set(gcf,'Position',[0.5 0.5 0.5 4])
    subplot(2,1,2); scatter(test_behavs,behav_pred_neg,'bo','fill'); lsline; hold on;
    xlabel('Observed Hyperactive Score','FontSize',12)
    ylabel('Negative Predicted Hyperactive Score','FontSize',11)
    axis([0 30 0 30])
    set(gcf,'Position',[500 300 500 450])
end