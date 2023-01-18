clear;
clc;

% ------------ INPUTS -------------------
all_mats = ARS_matrix_Z;
all_behav = ARS_inatten_score;
all_age = ARS_age;

% threshold for feature selection
thresh = 0.01;

% ---------------------------------------   

no_sub = size(all_mats,3);
no_node = size(all_mats,1);

behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);


for leftout = 1:no_sub;
    fprintf('\n Leaving out subj # %6.3f',leftout);
    
    % leave out subject from matrices and behavior
    
    train_mats = all_mats;
    train_mats(:,:,leftout) = [];
    train_vcts = reshape(train_mats,[],size(train_mats,3));
    
    train_behav = all_behav;
    train_behav(leftout) = [];
    
    train_age = all_age;
    train_age(leftout) = [];
    
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
     
    % collect train_subs' pos & neg mask   
    pp(:,:,leftout) = ones(no_node,no_node); 
    
    train_pos_mask(:,:,leftout) = pp(:,:,leftout).*pos_mask;
    train_neg_mask(:,:,leftout) = pp(:,:,leftout).*neg_mask;
     
end

sum_pos_mask = sum(train_pos_mask,3);
sum_neg_mask = sum(train_neg_mask,3);

percent_pos_mask = sum_pos_mask/no_sub;
percent_neg_mask = sum_neg_mask/no_sub;

% select edges that are greater than or equal to 0.9
pos_bin_edges = find(percent_pos_mask >= 0.9);
neg_bin_edges = find(percent_neg_mask >= 0.9);

pos_mask_mat = zeros(no_node,no_node);
neg_mask_mat = zeros(no_node,no_node);

pos_mask_mat(pos_bin_edges) = 1;
neg_mask_mat(neg_bin_edges) = 1;

% construct a linear model that shows the relationship between behavior score 
% and selected edges'(>=90%) weight summation

brain_sumpos = zeros(no_sub,1);
brain_sumneg = zeros(no_sub,1);

for ss = 1:size(brain_sumpos);
    brain_sumpos(ss) = sum(sum(all_mats(:,:,ss).*pos_mask_mat))/2;
    brain_sumneg(ss) = sum(sum(all_mats(:,:,ss).*neg_mask_mat))/2;
end

% building a linear model
percent_fit_pos = polyfit(brain_sumpos, all_behav,1);
percent_fit_neg = polyfit(brain_sumneg, all_behav,1);


