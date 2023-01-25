
% threshold for feature selection and number of iteration
thresh = 0.01;
numberofIter = 500;
no_node = size(ARS_matrix_Z,1);

% Training data(70%) == 1 & Test data(30%) == 0
numberofElements = 299;
percentageofOnes = 20;
numberofOnes = round(numberofElements*percentageofOnes/100);
signal = [ones(1,numberofOnes), zeros(1,numberofElements - numberofOnes)];

% create a randperm iteration(1000 times) binary index 
a = zeros(numberofIter,299);

R_pos = zeros(numberofIter,1);
P_pos = zeros(numberofIter,1);
R_neg = zeros(numberofIter,1);
P_neg = zeros(numberofIter,1);


for i = 1:numberofIter;
    display(i);
    
    % create a randperm iteration(1000 times) binary index 
    a(i,:) = signal(randperm(length(signal)));
    
    % Train & Test index
    test_idx = find(a(i,:) == 0);
    train_idx = find(a(i,:) == 1);

    % Labeling index to Brain-connectivity matrix and Behavior score
    train_mats = ARS_matrix_Z(:,:,train_idx);
    test_mats = ARS_matrix_Z(:,:,test_idx);
    
    train_behav = ARS_inatten_score(train_idx,1);
    test_behav = ARS_inatten_score(test_idx,1);
    
    train_age = ARS_age(train_idx,1);
    
    % reshape the 3-D train matrix into 2-D train matrix (1 column/person)
    train_vcts = reshape(train_mats,[],size(train_mats,3));
    
    % correlate all edges with behavior
    [r_mat,p_mat] = partialcorr(train_vcts',train_behav,train_age);
    
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
    train_sumpos = zeros(numberofOnes,1);
    train_sumneg = zeros(numberofOnes,1);
    
    for ss = 1:size(train_sumpos);
        train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
        train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
    end
    
    % build model on TRAIN subs
    fit_pos = polyfit(train_sumpos, train_behav,1);
    fit_neg = polyfit(train_sumneg, train_behav,1);
    
    % run model on TEST subs
    test_sumpos = zeros(299-numberofOnes,1);
    test_sumneg = zeros(299-numberofOnes,1);
    
    for kk = 1:size(test_sumpos);
        test_sumpos(kk) = sum(sum(test_mats(:,:,kk).*pos_mask))/2;
        test_sumneg(kk) = sum(sum(test_mats(:,:,kk).*neg_mask))/2;
    end
    
    behav_pred_pos = zeros(299-numberofOnes,1);
    behav_pred_neg = zeros(299-numberofOnes,1);
    
    for tt = 1:size(behav_pred_pos);
        behav_pred_pos(tt) = fit_pos(1)*test_sumpos(tt) + fit_pos(2);
        behav_pred_neg(tt) = fit_neg(1)*test_sumneg(tt) + fit_neg(2);
    end
    
    % compare predicted and observed scores
      
    [R_pos(i), P_pos(i)] = corr(behav_pred_pos,test_behav);
    [R_neg(i), P_neg(i)] = corr(behav_pred_neg,test_behav);
    
    MSE_pos(i) = sum((behav_pred_pos-test_behav).^2)/(length(test_idx)-length(fit_pos)-1);
    MSE_neg(i) = sum((behav_pred_neg-test_behav).^2)/(length(test_idx)-length(fit_neg)-1);
    
    
    
end    


