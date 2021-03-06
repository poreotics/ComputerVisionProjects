function [img_features, labels] = ... 
    get_sketch_tokens(train_img_dir, train_gt_dir, feature_params, num_sketch_tokens,grid_dim)

% 'img_features' is N x feature dimension. You probably want it to be
% 'single' precision to save memory. 
% 'labels' is N x 1. labels(i) = 1 implies non-boundary, labels(i) = 2
% implies boundary or sketch token 1, labels(i) = 3 implies sketch token 2,
% etc... max(labels) should be num_sketch_tokens + 1;

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', but the starter code simply has the default
%DAISY values (which do work OK).

train_imgs = dir( fullfile( train_img_dir, '*.jpg' ));
% train_gts  = dir( fullfile( train_gt_dir,  '%.mat' )); %don't need to look them up, assume they exist for every image
num_imgs = length(train_imgs); % You don't need to sample them all while debugging.

%preallocate space for img_features and labels to speed up feature mining
num_samples = 30000;
feat_dim=(feature_params.CR*2+1)^2*14;%+nchoosek(grid_dim^2,2)*14;
img_features=zeros(num_samples,feat_dim);
index_placeholder=0;
daisy_index_placeholder=0;
labels=ones(num_samples,1);
num_per_image=num_samples/num_imgs;
pos_ratio   = 0.5; %The desired percentage of positive samples. 
%It's not critical that your function find exactly this many samples.

%14 channels
%3 color
%3 gradient magnitude
%4 + 4 oriented magnitudes

% Don't bother with sampling / clustering the sketch patches initially.
daisy_feature_dims = feature_params.RQ * feature_params.TQ * feature_params.HQ + feature_params.HQ;
sketch_features = zeros(num_samples*pos_ratio, daisy_feature_dims, 'single');
pos_indices=zeros(1,size(sketch_features,1));



for i = 1:num_imgs

    fprintf(' Sampling patches / annotations from %s\n', train_imgs(i).name);
    [cur_pathstr,cur_name,cur_ext] = fileparts(train_imgs(i).name);
    cur_img = imread(fullfile(train_img_dir, train_imgs(i).name));
    cur_img = single(cur_img);
    cur_gt  = zeros(size(cur_img,1), size(cur_img,2));
        
    annotation_struct  = load(fullfile(train_gt_dir, [cur_name '.mat']));
    pos_centers=[];
    neg_centers=[];
    dasies=cell(1,length(annotation_struct.groundTruth));
    for j = 1:length(annotation_struct.groundTruth)

        boundary=annotation_struct.groundTruth{j}.Boundaries;
        dasies{j}=compute_daisy(boundary);

        %mine centers for pos and neg training examples
        annotation=zeros(size(boundary))+2;
        ind_ranges=[feature_params.CR+1,size(boundary,1)-feature_params.CR,...
            feature_params.CR+1,size(boundary,2)-feature_params.CR];

        annotation(ind_ranges(1):ind_ranges(2),ind_ranges(3):...
            ind_ranges(4))=boundary(ind_ranges(1):ind_ranges(2),...
            ind_ranges(3):ind_ranges(4));

        pos_centers=[pos_centers,find(annotation==1)'];
        neg_centers=[neg_centers,find(annotation==0)'];
    end

    %picking centers that most consistently are pos/neg accross all
    %image annotations
    p_unique=unique(pos_centers);
    n_unique=unique(neg_centers);
    [~,p_ind]=sort(hist(pos_centers,p_unique),'descend');
    [~,n_ind]=sort(hist(neg_centers,n_unique),'descend');
    p_unique=p_unique(p_ind);
    n_unique=n_unique(n_ind);
    if length(p_unique)>num_per_image*pos_ratio,
        p_final=p_unique(1:num_per_image*pos_ratio);
    elseif length(p_unique)~=0
        p_final=p_unique;
    end
    
    if length(n_unique)>num_per_image*(1-pos_ratio),
        n_final=n_unique(1:num_per_image*(1-pos_ratio));
    elseif length(n_unique)~=0
        n_final=n_unique;
    end


    channels=single(get_channels(cur_img));
    %do lists neg and pos separately because they might not be the same size
    for p=p_final,

        index_placeholder=index_placeholder+1;
        daisy_index_placeholder=daisy_index_placeholder+1;
        [y,x]=ind2sub(size(cur_gt),p);
        chan_patch=channels(y-feature_params.CR:y+feature_params.CR,...
            x-feature_params.CR:x+feature_params.CR,:);
        
        img_features(index_placeholder,:)=reshape(chan_patch,1,[]);%,self_similarity(chan_patch,grid_dim)];

        sketch_features(daisy_index_placeholder,:)=reshape(get_descriptor(dasies{randi([1 length(dasies)])},y,x),1,[]);


        pos_indices(daisy_index_placeholder)=index_placeholder;

    end

    for n=n_final,
        index_placeholder=index_placeholder+1;
        [y,x]=ind2sub(size(cur_gt),n);
        chan_patch=channels(y-feature_params.CR:y+feature_params.CR,...
            x-feature_params.CR:x+feature_params.CR,:);
        img_features(index_placeholder,:)=reshape(chan_patch,1,[]);%,self_similarity(chan_patch,grid_dim)];
        %labels(index_placeholder)=1;
    end
 


    % Pad the current image and then call 'channels = get_channels(cur_img)'
   
    % Fill in some of the rows of img_features. Don't worry about filling
    % in sketch_features initially.
end


[~, assignments] = vl_kmeans(sketch_features', num_sketch_tokens);


pos_indices(pos_indices==0)=[];
size(pos_indices)
size(assignments)
labels(pos_indices)=assignments+1;



'clip features'
if index_placeholder<num_samples, 
    'clip'
    img_features=single(img_features(1:index_placeholder,:)); 
    labels=labels(1:index_placeholder);
end


%size(img_features)
%size(labels)
% [centers, assignments] = vl_kmeans(X, K)
%  http://www.vlfeat.org/matlab/vl_kmeans.html
%   X is a d x M matrix of sampled SIFT features, where M is the number of
%    features sampled. M should be pretty large! Make sure matrix is of type
%    single to be safe. E.g. single(matrix).
%   'K' is the number of clusters desired (vocab_size)
%   'centers' is a d x K matrix of cluster centers
%   'assignments' is a 1 x M uint32 vector specifying which cluster every
%       feature was assigned to.
%
%   In project 3, we cared about the universal vocabulary specified by
%   'centers'. Here we don't. We care about 'assignments', telling us which
%   sketch tokens (and therefore which image features) correspond to the
%   same mid level boundary structure. We will keep 'centers' only for the
%   sake of visualization.

% Only cluster the Sketch Patches which have center pixel boundaries.




