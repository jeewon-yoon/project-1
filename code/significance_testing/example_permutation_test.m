% Load the data set 

load('Xroi.mat'); 

A = x{1}; 
B = x{2}; 

% p is the number of nodes. Each column is a subject. 

[p,na] = size(A);   
[p,nb] = size(B); 

n = na + nb; 

We set the data matrix X and its label vector y as follows: 

% Data matrix of all data and its label  

X = [A B]; 
y = [ones(1,na) 2*ones(1,nb)]; 

The permutation method randomly permute the label vector by 

% Permute the label

tind = randperm(n); 
y_perm = y(tind);

The randomly permuted data of two groups are obtained by 

% Permuted data matrix 
A_perm = X(:,find(y_perm == 1)); 
B_perm = X(:,find(y_perm == 2)); 

Since perm_A and perm_B contain the data both of two groups A and B, 
f(perm_A) and f(perm_B) are probably similar to each other. 

Here we choose a global efficiency as a network invariant (efficiency_wei.m).  


% Estimate the connectivity matrix of permuted data 

C_perm = corr(A_perm');
C_perm(:,:,2) = corr(B_perm'); 

% Only positive correlation 
C_perm = C_perm.*(C_perm>0); 


% Estimate the global efficiency 
Eglob = []; 

for g = 1:2
    Eglob(1,g) = efficiency_wei(C_perm(:,:,g),0);
end 

diff_Eglob = Eglob(1,1) - Eglob(1,2); 


The random permutation should be performed at least 5000 times.

diff_Eglob = []; 
Eglob = [];

for cv = 1:5000 

    tind = randperm(n); 
    y_perm = y(tind);

    % Permuted data matrix 

    A_perm = X(:,find(y_perm == 1)); 
    B_perm = X(:,find(y_perm == 2)); 

    % Estimate the connectivity matrix of permuted data 
    C_perm = corr(A_perm');
    C_perm(:,:,2) = corr(B_perm'); 

    % Only positive correlation 
    C_perm = C_perm.*(C_perm>0); 

    % Estimate the global efficiency 
     for g = 1:2 
       Eglob(cv,g) = efficiency_wei(C_perm(:,:,g),0);
     end 

    diff_Eglob(cv,1) = Eglob(cv,1) - Eglob(cv,2);
    display(num2str(cv)); 

end  


Then, we can obtain 5000 differences of the chosen invariants and their histogram. 
This histogram becomes a null distribution and a critical value for the significance level 
is chosen by the 95 percentile points of this distribution. 





[tval,tind] = sort(diff_Eglob,'ascend'); %오름차순
crit_val = tval(round(0.95*5000));  

To find the location of true difference in the histogram, we do the same procedure for the true data. 

% Estimate the connectivity matrix of true data 

 C_true = corr(A');
 C_true(:,:,2) = corr(B'); 

 % Only positive correlation 
 C_true = C_true.*(C_true>0); 

 % Estimate the global efficiency
 for g = 1:2 
    Eglob(5001,g) = efficiency_wei(C_true(:,:,g),0);
 end 

 diff_Eglob(5001,1) = Eglob(5001,1) - Eglob(5001,2);


If diff_true is larger than crit_val, the null hypothesis is rejected. 
We can say that the global efficiency of two groups is significantly different with the level .05 (permutation method). 


% Histogram of diff_Eglob 

figure; 
hist(diff_Eglob,500); 
hold on; 
plot(diff_Eglob(end),0,'rx','MarkerSize',10,'LineWidth',3); 

 
[tval,tind] = sort(diff_Eglob,'ascend'); 
pval = find(tind == 5001)/5001; 