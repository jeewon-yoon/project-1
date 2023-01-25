% set of selected edges in brain connectivity matrix as 3-dimensional form (M*M*N) 

clear;
clc;

% ------------ INPUTS -------------------
all_mats = TDC_Z;
all_behav = Age_TDC;

% threshold for feature selection
thresh = 0.05;

% --------------------------------------- 
no_sub = size(all_mats,3);
no_node = size(all_mats,1);


for leftout = 1:no_sub;
    fprintf('\n Leaving out subj # %6.3f',leftout);
    
    % leave out subject from matrices and behavior
    
    train_mats = all_mats;
    train_mats(:,:,leftout) = [];
    train_vcts = reshape(train_mats,[],size(train_mats,3));
    
    train_behav = all_behav;
    train_behav(leftout) = [];
    
    % correlate all edges with behavior     
    [r_mat,p_mat] = corr(train_vcts', train_behav);
    
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);
    
    % set threshold and define masks
    
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);
    
    pos_edges = find(r_mat > 0 & p_mat < thresh);
    neg_edges = find(r_mat < 0 & p_mat < thresh);
    
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    
end

    % make a 3 dimensional mask(binary) matrix for train_mats
    train_pos_mask = ones(no_node,no_node,no_sub);
    train_neg_mask = ones(no_node,no_node,no_sub);
    
    for mm = 1:size(no_sub);
        train_pos_mask(:,:,mm) = pos_mask;
        train_neg_mask(:,:,mm) = neg_mask;
    end
end