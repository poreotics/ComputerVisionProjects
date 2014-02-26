function pb = detect_sketch_tokens(img, forest, feature_params,grid_dim)

% 'img' is a test image.
% 'forest' is the structure returned by 'forestTrain'.

% 'pb' is the probability of boundary for every pixel.

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', which you probably don't need here (unless you've
%decided to use the DAISY descriptor as an image feature, which might be a
%decent idea).

[height, width, cc] = size(img);
num_sketch_tokens = max(forest(1).hs) - 1; %-1 for background class
im=imPad(img,feature_params.CR,'symmetric');
dim=feature_params.CR*2+1;
channels=get_channels(im);
pb=zeros(height,width);
self_sim_dim=0;%nchoosek(grid_dim^2,2)*size(channels,3);   **This was commented out because it corresponds to self similarity
size(img)
for row=1+feature_params.CR:width+feature_params.CR 
    chan_mat=zeros(height,dim^2*14+self_sim_dim);
    for i=1:14,
        chan_mat(:,((i-1)*dim^2+1):(i*dim^2))=im2col(channels(:,row-feature_params.CR:row+feature_params.CR,i),[dim dim],'sliding')';
    end
    
    %This is for self similarity features. It's a somewhat hacky way to do
    %it and so it's very slow. I wouldn't reccommend running this with self
    %similarity
    %for i=1:height,
        %size(chan_mat(i,(dim^2*14+1):end))
        %size(self_similarity(reshape(chan_mat(i,1:dim^2*14),dim,dim,14),grid_dim))
        %chan_mat(i,(dim^2*14+1):end)=self_similarity(reshape(chan_mat(i,1:dim^2*14),dim,dim,14),grid_dim);
    %end

    [~, prob] = forestApply(single(chan_mat),forest);
    pb(:,(row-feature_params.CR))=1-prob(:,1)';
end

pb=imfilter(pb,fspecial('gaussian',[3 3],.5));

