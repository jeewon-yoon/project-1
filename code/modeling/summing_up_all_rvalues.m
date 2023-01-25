clear;
clc;

% ------------ INPUTS -------------------
all_mats = ARS_matrix_Z;
all_behav = ARS_impulse_score;
all_age = ARS_age;

% threshold for feature selection
thresh = 0.001;
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
    
    pos_edges = find(r_mat > 0 & p_mat > thresh);
    neg_edges = find(r_mat < 0 & p_mat > thresh);
    positive_edges = find(r_mat > 0 & p_mat < thresh);
    negative_edges = find(r_mat < 0 & p_mat < thresh);
    
    % significant r-value matrix (pos & neg)   
    pos_r_mat = r_mat;
    pos_r_mat(pos_edges) = 0;
    pos_r_mat(neg_edges) = 0;
    pos_r_mat(negative_edges)=0;
    
    neg_r_mat = r_mat;
    neg_r_mat(pos_edges) = 0;
    neg_r_mat(neg_edges) = 0;
    neg_r_mat(positive_edges) = 0;
     
    % collect train_subs' pos & neg r-value matrix   
    pp(:,:,leftout) = ones(no_node,no_node); 
    
    train_pos_value(:,:,leftout) = pp(:,:,leftout).*pos_r_mat;
    train_neg_value(:,:,leftout) = pp(:,:,leftout).*neg_r_mat;
     
end

% sum all the r-value matrix (pos & neg) and divide by number of subjects 
sum_pos_value = sum(train_pos_value,3)/no_sub;
sum_pos_value(isnan(sum_pos_value))=0;

sum_neg_value = sum(train_neg_value,3)/no_sub;
sum_neg_value = abs(sum_neg_value);
sum_neg_value(isnan(sum_neg_value))=0;

imagesc(sum_pos_value);
hold on;
set(gcf,'Position',[200 100 700 700])
xticks([0 4.5 11.5 13.5 14.5 17.5 24.5 31.5 34.5 41.5 45.5 54.5 62.5 71.5 75.5 82.5 85.5 92.5 99.5 102.5 103.5 105.5 112.5]);
yticks([0 4.5 11.5 13.5 14.5 17.5 24.5 31.5 34.5 41.5 45.5 54.5 62.5 71.5 75.5 82.5 85.5 92.5 99.5 102.5 103.5 105.5 112.5]);
grid on;
pax = gca;
pax.GridAlpha = 1
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
set(gca,'xgrid','on','ygrid','on','gridlinestyle','-','xcolor','k','ycolor','k');
color_list = colormap(hot(8));
color_list = color_list(end:-1:1,:);

imagesc(sum_neg_value);
hold on;
set(gcf,'Position',[200 100 700 700])
xticks([0 4.5 11.5 13.5 14.5 17.5 24.5 31.5 34.5 41.5 45.5 54.5 62.5 71.5 75.5 82.5 85.5 92.5 99.5 102.5 103.5 105.5 112.5]);
yticks([0 4.5 11.5 13.5 14.5 17.5 24.5 31.5 34.5 41.5 45.5 54.5 62.5 71.5 75.5 82.5 85.5 92.5 99.5 102.5 103.5 105.5 112.5]);
grid on;
pax = gca;
pax.GridAlpha = 1
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
set(gca,'xgrid','on','ygrid','on','gridlinestyle','-','xcolor','k','ycolor','k');
color_list = colormap(hot(8));
color_list = color_list(end:-1:1,:);
