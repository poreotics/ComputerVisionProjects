function image_feats = spatial_matching( image_paths )
%This function produces a histogram for each cluster center of features
%falling in image-space grids at different resolutions. image_feats is a
%IxN matrix where I is the number of images and N=M(1/3)(4^(L+1)-1) with M
%cluster centers and L resolutions. 

%Use vocab to cluster image SIFT features and return 2d image space vectors for each
%cluster. 

%Next, create histograms at each resolution. Try L=2 because this gets
%optimal results in Lazebnik paper. 

%Concatenate histograms for each image and return resulting matrix. This
%will be the features fed to my SVM. 

load('vocab.mat')
voc=vocab;
image_feats=[];
M=size(voc,1);
L=2; 
dim_fine=2^L;


image_tiles=cell(size(image_paths,1),1);


%process images in parallel to speed up computation. This gives image
%divided into tiles of the finest level. For L=2 it should return a 4x4
%cell for each image
'top level grid'
parfor i=1:size(image_paths,1),
    image=single(imread(image_paths{i}));
    image=imcrop(image,[0,0,size(image,2)-mod(size(image,2),dim_fine),size(image,1)-mod(size(image,1),dim_fine)]);
    clust_image=zeros(size(image));
    [locations, SIFT_features] = vl_dsift(image,'step',5,'fast');
    locations=(locations-.5)';
    [inds,distances]=knnsearch(voc,single(SIFT_features'),'K',1);
    inds_new=horzcat(inds,[1:size(inds,1)]');
    clust_image(sub2ind(size(image),locations(:,2),locations(:,1)))=inds_new(:,1);
    tiles={mat2tiles(clust_image,size(clust_image,1)/dim_fine,size(clust_image,2)/dim_fine)};
    image_tiles{i}=tiles;
end    

%for each image, there is a matrix that is the same as the patches passed
%in but each patch contains an M dimensional histogram with one bin for
%each channel
top_level_histograms=cell(size(image_paths,1),1);

'top level histogram'
parfor i=1:size(image_tiles,1),
    temp_image_tiles=image_tiles{i};
    tiles=reshape(temp_image_tiles{:,:},1,[]);
    hist=cell(length(tiles),1);
    for j=1:length(tiles),
        patch=reshape(tiles{j},1,[]);
        hist{j}=histc(patch,[1:M]);
    end
    reshape(hist,dim_fine,dim_fine);
    top_level_histograms{i}={reshape(hist,dim_fine,dim_fine)};
end

'lower level histograms'
parfor i=1:size(image_paths,1),
    l=L;
    level_histograms=cell(l+1,1);
    base=top_level_histograms{i,:};
    level_histograms{l+1}=base;
    while l>0,
        base=level_reduce(base);
        l=l-1;
        level_histograms{l+1}=base;
    end
    image_feats=vertcat(image_feats,concatenate_hists(level_histograms));   
end

function lower_level=level_reduce(patch0)
    patch_array=[patch0{:,:}];
    lower_res={};
    for y=1:log2(size(patch_array,2)),
        for x=1:log2(size(patch_array,1)),
            new_patch=sum(vertcat(patch_array{(2^x)-1:(2^x),(2^y)-1:(2^y)}),1);
            lower_res{end+1}=[new_patch];
        end
    end
    lower_level={reshape(lower_res,log2(size(patch_array,1)),log2(size(patch_array,2)))};


function concatenated=concatenate_hists(hist)
    concatenated=[];
    for i=1:size(hist,1),
        cel=hist{i,:};
        cel=cel{:,:};
        array=horzcat(cel{:,:});
        weight=1/(2^(size(hist,1)-i+1));
        array=array.*weight;
        concatenated=horzcat(concatenated,array);
    end
    concatenated=concatenated/norm(concatenated);




