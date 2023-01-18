clear all; 
close all; 

load('VO_0033_ROI.mat'); 
load('VO_D001_ROI.mat');
x(:,:,1) = VO_0033_ROI; 
x(:,:,2) = VO_D001_ROI; 

C = []; D = []; SLM = []; MST = []; 
for i = 1:2, 
    C(:,:,i) = corr(x(:,:,i)); % Correlation matrix 
    D(:,:,i) = sqrt(1-C(:,:,i)); % Distance  matrix
    [SLM(:,:,i),MST(:,:,i)] = single_linkage_matrix(D(:,:,i)); % Single linkage matrix
    
    display(num2str(i)); 
end 

% Plot
figure; 
for i = 1:2, 
    subplot(2,3,(i-1)*3+1), imagesc(C(:,:,i)); colorbar; 
    subplot(2,3,(i-1)*3+2), imagesc(D(:,:,i)); colorbar; 
    subplot(2,3,(i-1)*3+3), imagesc(SLM(:,:,i)); colorbar; 
end 


% plot beta0-curve** 
p = size(x,2);
group_color = 'rb';
figure; 
for i = 1:2, 
    plot([0; sort(MST(:,3,i),'ascend')],[116:-1:1],[group_color(i) '.-'],'MarkerSize',10);
    hold on; 
end 

% Gromov-Hausdorff distance between SLMs
GHdist = max(max(abs(SLM(:,:,1)-SLM(:,:,2))));


% permutation method 
X = [x(:,:,1); x(:,:,2)];
n = size(X,1);

GHdist_rand = [];

for cv = 1:5000,
    % Permute the labels of data
    tind = randperm(n);
    
    rx = []; C = []; D = []; SLM = [];
    for i = 1:2,
        rx(:,:,i) = X(tind(((i-1)*n/2+1):(n/2*i)),:);
        C(:,:,i) = corr(rx(:,:,i));
        D(:,:,i) = sqrt(1-C(:,:,i));
        [SLM(:,:,i)] = single_linkage_matrix(D(:,:,i));
    end
    GHdist_rand(cv) = max(max(abs(SLM(:,:,1)-SLM(:,:,2))));
    
    
    display(num2str(cv));
    
end

% Estimate pval
[tval,tind] = sort(GHdist_rand,'descend'); 
pval = tval(round(length(tval)*0.05))
GHdist > pval


figure; 
hist(GHdist_rand,30); hold on; 
plot(GHdist,0,'rx','MarkerSize',10); 
