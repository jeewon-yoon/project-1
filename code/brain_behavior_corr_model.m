
clear;
clc;

% ------------ INPUTS -------------------
all_mats = ADHD_Z;
all_behav = inattentive;

% threshold for feature selection
thresh = 0.01;

% ---------------------------------------  

no_sub = size(all_mats,3);
no_node = size(all_mats,1);

behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);

brain_vcts = reshape(all_mats,[],size(all_mats,3));

[r_mat,p_mat] = corr(brain_vcts', all_behav);
    
r_mat = reshape(r_mat,no_node,no_node);
p_mat = reshape(p_mat,no_node,no_node);

% set threshold and define masks
    
pos_mask = zeros(no_node,no_node);
neg_mask = zeros(no_node,no_node);
    
pos_edges = find(r_mat > 0 & p_mat < thresh);
neg_edges = find(r_mat < 0 & p_mat < thresh);
    
pos_mask(pos_edges) = 1;
neg_mask(neg_edges) = 1;

brain_sumpos = zeros(no_sub,1);
brain_sumneg = zeros(no_sub,1);

for ss = 1:size(brain_sumpos);
    brain_sumpos(ss) = sum(sum(all_mats(:,:,ss).*pos_mask))/2;
    brain_sumneg(ss) = sum(sum(all_mats(:,:,ss).*neg_mask))/2;
end

% build model 

corr_fit_pos = polyfit(brain_sumpos, all_behav,1);
corr_fit_neg = polyfit(brain_sumneg, all_behav,1);

