
% ------------ INPUTS -------------------
all_mats = ARS_matrix_Z;
all_behav = ARS_impulse_score;
all_age = ARS_age;

no_sub = size(all_mats,3);
no_node = size(all_mats,1);

% input the calculated true prediction correlation value
true_prediction_r_pos = 0.3499;
true_prediction_r_neg = 0.3178;

% number of iterations for permutation testing
no_iterations = 1000;
prediction_r = zeros(no_iterations,2);
prediction_r(1,1) = true_prediction_r_pos;
prediction_r(1,2) = true_prediction_r_neg;

% create estimate distribution of the test statistic
% via random shuffles of data labels
for it = 2:no_iterations
    fprintf('/n Performing iteration %d out of %d', it, no_iterations);
    new_behav = all_behav(randperm(no_sub));
    
    behav_pred_pos = zeros(no_sub,1);
    behav_pred_neg = zeros(no_sub,1);
    
for leftout = 1:no_sub;
    fprintf('\n Leaving out subj # %6.3f',leftout);
    
    % leave out subject from matrices and behavior  
    train_mats = all_mats;
    train_mats(:,:,leftout) = [];
    train_vcts = reshape(train_mats,[],size(train_mats,3));
    
    train_behav = new_behav;
    train_behav(leftout) = [];
    
    train_age = all_age;
    train_age(leftout) = [];
    
    % correlate all edges with behavior
    [r_mat,p_mat] = partialcorr(train_vcts', train_behav, train_age);
    
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);
    
    % set threshold and define masks
    thresh = 0.01;
    
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);
    
    pos_edges = find(r_mat > 0 & p_mat < thresh);
    neg_edges = find(r_mat < 0 & p_mat < thresh);
    
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    
    % get sum of all edges in TRAIN subs (divide by 2 to control for the
    % fact that matrices are symmetric)
    
    train_sumpos = zeros(no_sub-1,1);
    train_sumneg = zeros(no_sub-1,1);
    
    for ss = 1:size(train_sumpos);
        train_sumpos(ss) = sum(sum(train_mats(:,:,ss).*pos_mask))/2;
        train_sumneg(ss) = sum(sum(train_mats(:,:,ss).*neg_mask))/2;
    end
    
    % build model on TRAIN subs
    fit_pos = polyfit(train_sumpos, train_behav,1);
    fit_neg = polyfit(train_sumneg, train_behav,1);
        
    % run model on TEST sub
    test_mat = all_mats(:,:,leftout);
    test_sumpos = sum(sum(test_mat.*pos_mask))/2;
    test_sumneg = sum(sum(test_mat.*neg_mask))/2;
    
    behav_pred_pos(leftout) = fit_pos(1)*test_sumpos + fit_pos(2);
    behav_pred_neg(leftout) = fit_neg(1)*test_sumneg + fit_neg(2);
       
end

   % compare predicted and observed scores
   [R_pos, P_pos] = corr(behav_pred_pos,all_behav);
   [R_neg, P_neg] = corr(behav_pred_neg,all_behav);  
 
   prediction_r(it,1) = R_pos;
   prediction_r(it,2) = R_neg;
   
end

sorted_prediction_r_pos = sort(prediction_r(:,1),'descend');
position_pos = find(sorted_prediction_r_pos==true_prediction_r_pos);
pval_pos = position_pos(1)/no_iterations;

sorted_prediction_r_neg = sort(prediction_r(:,2),'descend');
position_neg = find(sorted_prediction_r_neg==true_prediction_r_neg);
pval_neg = position_neg(1)/no_iterations;
