clear all;

% Creating .mat file in the designated directory
filename = ['*.mat']; 
current_path = [pwd '/'];
filelist = dir([current_path filename]);
nfile = size(filelist,1);

% make FMRIraw (merging data to single file)
tmpname = [];
tmpstr = [];
tmpcell = [];
FMRI_ADHD = {};

for i = 1:nfile,
    display(i);
    tmpname = filelist(i).name;
    tmpstr = load(tmpname);
    tmpcell = struct2cell(tmpstr);
    FMRI_ADHD{i} = tmpcell{1}
end

% Pearson Correlation Connectivity matrix
for i = 1:size(FMRI_ADHD,2)
    display(i);
    adhd(:,:,i) = corr(FMRI_ADHD{1,i});
end

% Fisher z transformation
for k = 1:size(adhd,3)
    display(k);
    for i = 1:size(adhd,1)
        for j = 1:size(adhd,2)
            r(i,j,k) = adhd(i,j,k);
            adhd_Z(i,j,k) = 0.5*[log(1+r(i,j,k))-log(1-r(i,j,k))];
        end
    end
end

%Replace Inf with 1
adhd_Z(isinf(adhd_Z))=1;