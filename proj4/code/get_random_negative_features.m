% Starter code prepared by James Hays for CS 143, Brown University
% This function should return negative training examples (non-faces) from
% any images in 'non_face_scn_path'. Images should be converted to
% grayscale, because the positive training data is only available in
% grayscale. For best performance, you should sample random negative
% examples at multiple scales.

function features_neg = get_random_negative_features(non_face_scn_path, feature_params, num_samples)
% 'non_face_scn_path' is a string. This directory contains many images
%   which have no faces in them.
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.
% 'num_samples' is the number of random negatives to be mined, it's not
%   important for the function to find exactly 'num_samples' non-face
%   features, e.g. you might try to sample some number from each image, but
%   some images might be too small to find enough.

% 'features_neg' is N by D matrix where N is the number of non-faces and D
% is the template dimensionality, which would be
%   (feature_params.template_size / feature_params.hog_cell_size)^2 * 31
% if you're using the default vl_hog parameters

% Useful functions:
% vl_hog, HOG = VL_HOG(IM, CELLSIZE)
%  http://www.vlfeat.org/matlab/vl_hog.html  (API)
%  http://www.vlfeat.org/overview/hog.html   (Tutorial)
% rgb2gray

%%{
image_files = dir( fullfile( non_face_scn_path, '*.jpg' ));
num_images = length(image_files);

num_extract = round(num_samples/num_images);

features_neg=[];
hog_dim=feature_params.template_size/feature_params.hog_cell_size;
'negative'
for i=1:num_images,
   im1=im2single(rgb2gray(imread(horzcat(non_face_scn_path,'/',image_files(i).name))));
   im2=vl_hog(imresize(im1,2),feature_params.hog_cell_size);
   im3=vl_hog(imresize(im1,0.5),feature_params.hog_cell_size);
   im4=vl_hog(imresize(im1,.7),feature_params.hog_cell_size);
   im5=vl_hog(imresize(im1,.3),feature_params.hog_cell_size);
   im6=vl_hog(imresize(im1,4),feature_params.hog_cell_size);
   im1=vl_hog(im1,feature_params.hog_cell_size);
   ims=[{im1},{im2},{im3},{im4},{im5},{im6}];
   
   cropped=0;
   for j=1:num_extract*2,
       ims=ims(randperm(length(ims)));
       image=ims{1};
       if (size(image,1)-hog_dim)>0 && (size(image,2)-hog_dim)>0 && cropped<num_extract,
           x=randi([1 size(image,1)-hog_dim]);
           y=randi([1 size(image,2)-hog_dim]);
           hog=image(x:x+hog_dim-1,y:y+hog_dim-1,:);
           features_neg(end+1,:)=reshape(hog,1,[]);
           cropped=cropped+1;
       end
       if cropped==num_extract,
          break; 
       end
   end
end

