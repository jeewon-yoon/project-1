% Plot true age vs. predicted age 
clear all; 

% Load true age and predicted age 
load('CCTT1_data.mat','behav_pred_pos','behav_pred_neg','CCTT1_Behav');
behav_pred_pos_ADHD = behav_pred_pos; 
behav_pred_neg_ADHD = behav_pred_neg; 

load('TDC_age_data.mat','behav_pred_pos','behav_pred_neg','Age_TDC_81');
behav_pred_pos_TDC = behav_pred_pos; 
behav_pred_neg_TDC = behav_pred_neg; 

% Plot true age v.s. predicted age. 
% xaxis: true age % yaxis: predicted age
figure; 
subplot(2,1,1), 
boxplot(behav_pred_pos_ADHD,ARS_inatten); ylim([0 27]); 
xlabel('True score'); ylabel('Predicted score'); title('Positive correlation in ARS_inatten'); 
subplot(2,1,2), boxplot(behav_pred_neg_ADHD,Age_ADHD_81);ylim([6 19]);
xlabel('True score'); ylabel('Predicted score'); title('Negative correlation in CCTT'); 
subplot(2,2,3), boxplot(behav_pred_pos_TDC,Age_TDC_81); ylim([6 19]);
xlabel('True age'); ylabel('Predicted age'); title('Positive correlation in TDC');
subplot(2,2,4), boxplot(behav_pred_neg_TDC,Age_TDC_81); ylim([6 19]);
xlabel('True age'); ylabel('Predicted age'); title('Negative correlation in TDC');

% Histogram of number of subjects with respect to age 
figure; 
subplot(1,2,1), hist(Age_ADHD_81,[6:19]); ylim([0 20]); 
xlabel('Age'), ylabel('Number of subjects'); 
subplot(1,2,2), hist(Age_TDC_81,[6:19]); ylim([0 20])
xlabel('Age'), ylabel('Number of subjects'); 


% Plot significant edges 
% Load the connectivity matrix of ADHD and TDC 
load('ADHD_age_data.mat','all_mats'); 
xADHD = all_mats; 

load('TDC_age_data.mat','all_mats'); 
xTDC = all_mats; 

% Number of nodes 
p = size(xADHD,1);
% Connectivity matrix is symmetric. 
% So, we select the upper triangular part of connectivity matrix.  
% 'ind_triu' represents the index of the upper triangular part of connectivity
% matrix 
ind_triu = find(triu(ones(p,p),1));

% Vectorize p-by-p connectivity matrix to p*(p-1)/2-by-1 vector 
% for ADHD 
xtmp = []; 
for i = 1:size(xADHD,3);
    tmp = xADHD(:,:,i);  
    xtmp(:,i) = tmp(ind_triu); 
end 
xADHD = xtmp; 

% for TDC
xtmp = []; 
for i = 1:size(xTDC,3);
    tmp = xTDC(:,:,i);  
    xtmp(:,i) = tmp(ind_triu); 
end 
xTDC = xtmp; 

% Estimate the correlation between edge weights in connectivity matrix and
% age 
% rADHD or rTDC is a (p*(p-1)/2)-by-(number of subjects in a group) matrix. 
% Each entry represents the correlation between the corresponding edge
% weights and age. 
% pADHD and pTDC are the p-vaue of rADHD and rTDC, respectively. 
[rADHD,pADHD] = corr(xADHD',Age_ADHD_81,); 
[rTDC,pTDC] = corr(xTDC',Age_TDC_81); 

% Transform the vectorized correlation and p pvaules in rADHD, rTDC, pADHD, and pTDC 
% to the p-by-p matrix. 
% For rADHD 
tmp = zeros(p,p); 
tmp(ind_triu) = rADHD; 
tmp = tmp + tmp'; 
rADHD = tmp; 
% rADHD is a p-by-p matrix of which entry is the correlation between the
% corresponding edge and age. 

% For rTDC
tmp = zeros(p,p); 
tmp(ind_triu) = rTDC; 
tmp = tmp + tmp';    %symmetric matrix (diagonal = 0), rTDC
rTDC = tmp;          

% For pADHD 
tmp = zeros(p,p); 
tmp(ind_triu) = pADHD; 
tmp = tmp + tmp'; 
pADHD = tmp; 

% For pTDC
tmp = zeros(p,p); 
tmp(ind_triu) = pTDC; 
tmp = tmp + tmp'; 
pTDC = tmp; 


% Plot the significant correlation with p < .01 
figure; 
tmp = rADHD.*(pADHD<0.01 & pADHD > 0); 
subplot(1,2,1), imagesc(tmp); colorbar;  
xlabel('Nodes'); ylabel('Nodes'); 
title('Correlation between edge weights and age in ADHD'); 

% tmp is a matrice with selected significant edges(threshold = 0.01) of correlation coefficient 
tmp = rTDC.*(pTDC<0.01 & pTDC > 0);  
subplot(1,2,2), imagesc(tmp); colorbar;  
xlabel('Nodes'); ylabel('Nodes'); 
title('Correlation between edge weights and age in TDC'); 
colormap(jet); 
