function [MST, A, Dx, Cx] = shapeofnetwork_cc_pc(X,VAR)

% X : p*n matrix (p: # of ROIs, n: # of samples)
% MST : minimum spanning tree (p-1)*3 matrix (each row contains [i j r]
% where i and j are connected with the distance r. Total (p-1) edges are
% exist in MST. 
% A : p*p adjacency matrix of MST
% Dx : p*p single linkage matrix %(sqrt)HSG
% Cx : p*p distance matrix %(sqrt)HSG 

[n p] = size(X); %[p n]= size(X); Edit hkang 2015.01.02

%C = partialcorr(X,VAR) % C = corrcoef(X);  %C=partialcorr(X',VAR);
C = corr(X,'Type','Pearson');  %C=partialcorr(X',VAR); %C = corr(X, 'Type','Spearman');
% 혜경선생님 원래 코드 C = corrcoef(X');
% C = corrcoef(X');

C = C.*(C>0); % 새로만들었음. positive matrix만 찾아서 distance를 구하라는 코드
Cx = sqrt(1 - C); % sqrt 추가. 2017.9.14 HSG

[row col] = find(Tree);
val = nonzeros(Tree);
MST = [row col val];
[tval tind] = sort(val,'ascend');
MST = MST(tind,:);
A = full(Tree);
% Dx = single_linkage_distance(MST,size(Cx,1));
Dx = single_linkage_distance(Cx); 
% 20120226

