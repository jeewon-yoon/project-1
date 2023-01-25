
% test matrix(3D M*M*N matrix and observed score matrix) as an input
test_mats = ARS_matrix_Z;
observed_score = ARS_impulse_score;
no_sub = size(test_mats,3);

% load positive and negative binary matrix from "every_edges_model" that includes edges from every
% iteration or edges that appear in every iteration from "consistent_edges_model" 
% or significant p-value edges from "brain_behavior_corr_model"  
  
load('matrice_model.mat','pos_mask_mat','neg_mask_mat');

test_sumpos = zeros(no_sub,1);
test_sumneg = zeros(no_sub,1);

for ss = 1:size(test_sumpos)
    display(ss);
    test_sumpos(ss) = sum(sum(test_mats(:,:,ss).*pos_mask_mat))/2;
    test_sumneg(ss) = sum(sum(test_mats(:,:,ss).*neg_mask_mat))/2;
end

% load the linear model('corr_fit_pos''corr_fit_neg' or 'fit_pos''fit_neg' or 'every_fit_pos''every_fit_neg') 
load('matrice_model.mat','fit_pos','fit_neg');

behav_pred_pos = zeros(no_sub,1);
behav_pred_neg = zeros(no_sub,1);

for tt = 1:size(test_sumpos)
    display(tt);
    behav_pred_pos(tt) = fit_pos(1)*test_sumpos(tt) + fit_pos(2);
    behav_pred_neg(tt) = fit_neg(1)*test_sumneg(tt) + fit_neg(2);
end

% external validation by comparing model's prediction scores and observed scores
[R_pos, P_pos] = corr(behav_pred_pos,observed_score)
[R_neg, P_neg] = corr(behav_pred_neg,observed_score) 

observed_score1 = observed_score(1:81,1);
observed_score2 = observed_score(82:299,1);
behav_pred_pos1 = behav_pred_pos(1:81,1);
behav_pred_pos2 = behav_pred_pos(82:299,1);
behav_pred_neg1 = behav_pred_neg(1:81,1);
behav_pred_neg2 = behav_pred_neg(82:299,1);


figure(1); scatter(observed_score,behav_pred_pos,'ro','MarkerEdgeColor','none'); lsline; hold on
set(gcf,'Position',[500 300 550 450])
xlabel('Observed Inattentive Score','FontSize',12)
ylabel('Predicted Hyperactive Score','FontSize',12)
figure(1); scatter(observed_score1,behav_pred_pos1,'ko','MarkerFaceColor',[.65 .65 .65]);
figure(1); scatter(observed_score2,behav_pred_pos2,'ro','MarkerFaceColor',[1 .6 .6]);


figure(2); plot(observed_score,behav_pred_neg,'bo','MarkerEdgeColor','none'); lsline; hold on;
set(gcf,'Position',[500 300 550 450])
xlabel('Observed Inattentive Score','FontSize',12)
ylabel('Predicted Hyperactive Score','FontSize',12)
figure(2); scatter(observed_score1,behav_pred_neg1,'ko','MarkerFaceColor',[.65 .65 .65]);
figure(2); scatter(observed_score2,behav_pred_neg2,'bo','MarkerFaceColor',[0 0.56 1]);

