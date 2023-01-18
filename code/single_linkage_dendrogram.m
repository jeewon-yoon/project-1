function single_linkage_dendrogram(D,disp_option,nc)
% [max_dist] = dendrogram(MST)
%
% The function displays the single linkage dendrogram. 
% The dendrogram is colorized according to the distance from the giant component. 
% 
% D: p-by-p distance matrix (p: number of nodes)  
% disp_option  : display option 
%  1) 'distance' the color of bar changes according to the threshold when 
%                        the bar disappears 
%  2) 'cluster' the color of bar is determined by clusters 
% nc       : the number of cluster that the color of bar is determined,
%            this input is necessary when disp_option is 'cluster'
% max_dist : the maximum distance from the giant component in [1]. 
%
%
% EXAMPLE: 
% MST = [1 2 0.5; 2 3 0.2];
% dendrogram(MST)
% [max_dist] = dendrogram(MST);
%
%
% The code is downloaed from https://sites.google.com/site/hkleebrain/home/persistent-homology-2
%
% (C) Hyekyoung Lee, hklee.brain@gmail.com
%  Department of Nuclear Medicine
%  Seoul National University, South Korea
%
% 
% If you use this code, please reference one of the following papers. The details on
% the mathematical basis of of the algorithm can be found in these papers.
%
% [1] Lee, H., Kang, H.K., Chung, M.K., Kim, B.-N., Lee, D.S. 2012. 
%     Persistent brain network homology from the perspective of dendrogram, 
%     IEEE Transactions on Medical Imaging. in press. 
%     https://docs.google.com/file/d/0BzqCeYxcOj3bOFRXT3lZY0YwQUU/preview
%
% [2] Lee, H., Kang, H.K., Chung, M.K., Kim, B.-N., Lee, D.S. 2011. 
%     Computing the shape of brain network using graph filtration and Gromov-Haudorff metric,
%     MICCAI2011.
%     https://docs.google.com/file/d/0BzqCeYxcOj3bYWU5YzhhYzYtM2Q4NC00YTFmL
%     WE4YWItZjkwZjI5ZThkNjlk/edit?pli=1
%
% Update history: Sep 13, 2017

% Default: disp_option == 'distance' 
if nargin == 1, 
    disp_option = 'distance'; 
end 
    
% the number of nodes
p = size(D,1);

% Estimate the minimum spanning tree 
[Tree,pred] = graphminspantree(sparse(D)); 
[row,col] = find(Tree); 
val = Tree(find(Tree)); 
MST = [row col val]; 
[tval, tind] = sort(val,'ascend'); 
MST = full(MST(tind,:)); 

% 'bar' is a struct, it represents a connected component  
% x1: threshold when the bar starts 
% x2: threshold when the bar ends 
% y1: y position of connected component at x1 before merging 
% y2: y position of connected component at x2 after merging
% from: previous connected components
% to: next connected component 
% cc: nodes in a connected component 
% color: color of bar 

% connected components when the threshold is zero 
cc_count = 1;
bar = [];
for i = 1:p
    bar(cc_count).x1 = 0;
    bar(cc_count).y1 = p-i+1;
    bar(cc_count).cc = i;
    bar(cc_count).from = 0;
    cc_count = cc_count + 1;
end

% Update the bar information when CCs are merged 
for i = 1:size(MST,1)
    m = max(find(arrayfun(@(x)(sum(x.cc == MST(i,1))>0),bar)));
    n = max(find(arrayfun(@(x)(sum(x.cc == MST(i,2))>0),bar)));
    
    if m ~= n % always m < n
        bar(m).x2 = MST(i,3);
        bar(m).to = cc_count;
        bar(n).x2 = MST(i,3);
        bar(n).to = cc_count;
        
        bar(cc_count).x1 = MST(i,3);
        bar(cc_count).cc = [bar(m).cc bar(n).cc];
        bar(cc_count).from = [m n];
        bar(cc_count).y1 = (bar(m).y1 + bar(n).y1)/2;
        
        bar(m).y2 = bar(cc_count).y1;
        bar(n).y2 = bar(cc_count).y1;

        cc_count = cc_count + 1;
    end 
end
bar(cc_count-1).x2 = bar(bar(cc_count-1).from(1)).x2*1.1;
bar(cc_count-1).y2 = bar(cc_count-1).y1;
bar(cc_count-1).to = cc_count;

% Size of dendrogram 
tx = bar(bar(cc_count-1).from(1)).x2*1.1;
ty = p + 0.5; 


% color of bar 
if strcmp(disp_option,'distance'),
    
    % Estimate the distance of a connected component from a giant component (all
    % nodes are in the same connected components)
    bar(end).dist = 0;
    for i = (length(bar)-1):-1:1
        bar(i).dist = bar(bar(i).to).dist + 1;
    end
    max_dist = max(arrayfun(@(x)(x.dist),bar));
    
    % the color of bar 
    color_list = colormap(jet(max_dist+1));
    color_list = color_list(end:-1:1,:);
    
    for i = length(bar):-1:1,
        bar(i).color = color_list(bar(i).dist+1,:);
    end
else % disp_option == 'cluster'
    if nargin < 3, % nc does not exist 
        error('The number of clusters is missed!');
    end
    % Estimate connected components when the number of connected components == nc
    tmp = sparse([MST(1:p-nc,1); MST(1:p-nc,2)],[MST(1:p-nc,2); MST(1:p-nc,1)], ...
        [MST(1:p-nc,3); MST(1:p-nc,3)],p,p);
    [S,C] = graphconncomp(tmp > 0);
    if S ~= nc, % S should be equal to nc 
        error('Something is wrong!');
    end
    
    % color of bar 
    tcolor = colormap(jet(nc+round(nc*0.2)));
    tcolor = tcolor(round(nc*0.2)+1:end,:);
    for i = length(bar):-1:1,
        tC = C(bar(i).cc);
        [nn,xx] = hist(tC,[1:nc]);
        bar(i).color = sum(tcolor.*repmat(nn',[1 3]),1)/length(tC);
    end
end

% Draw the dendrogram 
for i = length(bar):-1:1,
    line([bar(i).x1 bar(i).x2],[bar(i).y1 bar(i).y1],'color',bar(i).color,'LineWidth',2); hold on;
    line([bar(i).x2 bar(i).x2],[bar(i).y1 bar(i).y2],'color',bar(i).color,'LineWidth',2);
end

xlim([0 tx]);
ylim([0 ty]);
