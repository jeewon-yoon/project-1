function [D] = single_linkage_distance(C)
% D : Single Linkage Distance
% C : Distance Positive correlation

ind_triu = find(triu(ones(size(C)),1) > 0);
threshold = sort(C(ind_triu),'ascend');
threshold = threshold(find(~isinf(threshold)));

ind_diag = find(eye(size(C)) > 0);
D = inf*ones(size(C));
D(ind_diag) = 0;

for i = 1:length(threshold)
    A = C <= (threshold(i)+10^(-4));
    [S, ind_group] = graphconncomp(sparse(A));
    
    for j = 1:S
        ind_sel = find(ind_group == j);
        D(ind_sel,ind_sel) = min(D(ind_sel,ind_sel),threshold(i)*ones(length(ind_sel),length(ind_sel)));
        
    end
    if sum(sum(isinf(D))) == 0
        break;
    end      
end

