clear all; 
close all; 

% ------------ INPUTS -------------------
% load('adhd_age.mat'); 
% load('adhd_inatten.mat'); 
% load('adhd_Z.mat'); 
% 
% all_mats =;
% all_behav = adhd_inatten;
% all_age = adhd_age;
load('hyperactive_data_200.mat','all_mats','all_behav','all_age'); 
% all_behav: inattentive 
% hyperactive_200: hyperactive 



% number of nodes 
p = size(all_mats,1); 

% number of subjects 
n = size(all_mats,3); 

% vectorize the connectivity matrix after extracting the upper triangular
% part of connectivity matrix 
ind_triu = find(triu(ones(p,p),1)); 
all_vcts = []; 

for i = 1:n, 
    tmp = all_mats(:,:,i); 
    all_vcts(:,i) = tmp(ind_triu); % upper triangle part in column(299)
end 

% threshold for feature selection
thresh = 0.01;

% ---------------------------------------   
% Group label 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%could not debeg due to different n
% nTDC = 76; 
% y = [zeros(nTDC,1); ones(n-nTDC,1)]; 
y = (load('ADHD200_grouplabel.txt') ~= 0); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 2-fold cross validation 10 times 
iter_corr_true = []; iter_err_true = []; 
p_corr = []; p_iter = [];  
max_iter = 50;  % iteration 10 times
for iter = 1:max_iter,
    iter_corr = []; iter_err = []; 

    rand_ind = randperm(n);
    behav_pred_pos = zeros(n,1);
    behav_pred_neg = zeros(n,1);
    
    for cv = 1:5001, 
        for ff = 1:2,
            % divide traning and test data
            if ff == 1,
                ind_train = rand_ind(1:round(n/2));
            ind_test = rand_ind(round(n/2)+1:end);
        else
            ind_test = rand_ind(1:round(n/2));
            ind_train = rand_ind(round(n/2)+1:end);
        end
        
        train_vcts = all_vcts(:,ind_train);  % train_vcts는 all_vcts의 train part
        train_behav = all_behav(ind_train,1);
        train_age = all_age(ind_train,1);
        
        test_vcts = all_vcts(:,ind_test);  % train_vcts는 all_vcts의 test part
        test_behav = all_behav(ind_test,1);
        test_age = all_age(ind_test,1);
        
        % correlate all edges with behavior
        % [r_mat,p_mat] = partialcorr(train_vcts', train_behav, train_age);
        [r_mat,p_mat] = corr(train_vcts', train_behav);
        
        for cv = 1:5001,
            if cv == 1,
                pos_mask = r_mat > 0 & p_mat < thresh;
                neg_mask = r_mat < 0 & p_mat < thresh;
                
                npos = sum(pos_mask); nneg = sum(neg_mask);
            else
                pos_mask = zeros(length(r_mat),1);
                tind = randperm(length(r_mat));
                pos_mask(tind(1:npos)) = 1;
                
                neg_mask = zeros(length(r_mat),1);
                tind = randperm(length(r_mat));
                neg_mask(tind(1:nneg)) = 1;
            end
            
            
            % get sum of all edges in TRAIN subs (divide by 2 to control for the
            % fact that matrices are symmetric)
            train_sumpos = sum(train_vcts.*repmat(pos_mask,[1 size(train_vcts,2)]),1)';
            train_sumneg = sum(train_vcts.*repmat(neg_mask,[1 size(train_vcts,2)]),1)';
            
            % build model on TRAIN subs
            fit_pos = polyfit(train_sumpos, train_behav,1);
            fit_neg = polyfit(train_sumneg, train_behav,1);
            
            % run model on TEST sub
            test_sumpos = sum(test_vcts.*repmat(pos_mask,[1 size(test_vcts,2)]),1)';
            test_sumneg = sum(test_vcts.*repmat(neg_mask,[1 size(test_vcts,2)]),1)';
            
            behav_pred_pos(ind_test) = fit_pos(1)*test_sumpos + fit_pos(2);
            behav_pred_neg(ind_test) = fit_neg(1)*test_sumneg + fit_neg(2);
            
            [r_pos,p_pos] = corr(all_behav,behav_pred_pos,'type','Spearman');
            iter_corr(1,ff,cv) = r_pos;
            iter_err(1,ff,cv) = sum((all_behav-behav_pred_pos).^2);
            [r_neg,p_neg] = corr(all_behav,behav_pred_neg,'type','Spearman');
            iter_corr(2,ff,cv) = r_neg;
            iter_err(2,ff,cv) = sum((all_behav-behav_pred_neg).^2);
            
            display([num2str([iter ff cv]) ' ' num2str([iter_corr(iter,1,ff,cv) iter_corr(iter,2,ff,cv)])]);
        end
        [tval,tind] = sort(squeeze(iter_corr(1,ff,:)),'descend');
        p_corr(iter,1,ff) = find(tind == 1)/5000; 
        [tval,tind] = sort(squeeze(iter_corr(2,ff,:)),'descend');
        p_corr(iter,2,ff) = find(tind == 1)/5000;
        
        [tval,tind] = sort(squeeze(iter_err(1,ff,:)),'descend');
        p_err(iter,1,ff) = find(tind == 1)/5000; 
        [tval,tind] = sort(squeeze(iter_err(2,ff,:)),'descend');
        p_err(iter,2,ff) = find(tind == 1)/5000;
    end
    
    iter_corr_true(:,:,iter) = iter_corr(:,:,1); 
    iter_err_true(:,:,iter) = iter_err(:,:,1); 
    save('result_ADHD200_CPM_2foldcv.mat','p_corr','p_err','iter_corr_true','iter_err_true','iter');
end


figure; 
subplot(1,2,1), 
hist(reshape(iter_corr(:,1,:,2:end),10*2*100,1));
hold on; scatter(reshape(iter_corr(:,1,:,1),10*2,1),zeros(20,1),'r','fill'); 
subplot(1,2,2), 
hist(reshape(iter_corr(:,2,:,2:end),10*2*100,1));
hold on; scatter(reshape(iter_corr(:,2,:,1),10*2,1),zeros(20,1),'r','fill'); 


    % Plot results
    figure;
    subplot(1,2,1), 
    ind1 = find(y == 0); 
    ind2 = find(y == 1); 
    scatter(all_behav(ind1),behav_pred_pos(ind1),'b','fill');
    hold on; 
    scatter(all_behav(ind2),behav_pred_pos(ind2),'r','fill');
    xlim([min(min([all_behav behav_pred_pos])) max(max([all_behav behav_pred_pos]))]); 
    ylim([min(min([all_behav behav_pred_pos])) max(max([all_behav behav_pred_pos]))]); 
    
    title(['iter=' num2str(iter) ',corr=' num2str(iter_corr(iter,1)) ', err=' num2str(iter_err(iter,1))]); 
    
    subplot(1,2,2), 
    scatter(all_behav(ind1),behav_pred_neg(ind1),'b','fill');
    hold on; 
    scatter(all_behav(ind2),behav_pred_neg(ind2),'r','fill');
    xlim([min(min([all_behav behav_pred_neg])) max(max([all_behav behav_pred_neg]))]); 
    ylim([min(min([all_behav behav_pred_neg])) max(max([all_behav behav_pred_neg]))]); 

    title(['iter=' num2str(iter) ',corr=' num2str(iter_corr(iter,2)) ', err=' num2str(iter_err(iter,2))]); 



