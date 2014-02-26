% Starter code prepared by James Hays for CS 143, Brown University
% This function returns detections on all of the images in a given path.
% You will want to use non-maximum suppression on your detections or your
% performance will be poor (the evaluation counts a duplicate detection as
% wrong). The non-maximum suppression is done on a per-image basis. The
% starter code includes a call to a provided non-max suppression function.
function [bboxes, confidences, image_ids] = .... 
    run_detector(test_scn_path, w, b, feature_params)
% 'test_scn_path' is a string. This directory contains images which may or
%    may not have faces in them. This function should work for the MIT+CMU
%    test set but also for any other images (e.g. class photos)
% 'w' and 'b' are the linear classifier parameters
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.

% 'bboxes' is Nx4. N is the number of detections. bboxes(i,:) is
%   [x_min, y_min, x_max, y_max] for detection i. 
%   Remember 'y' is dimension 1 in Matlab!
% 'confidences' is Nx1. confidences(i) is the real valued confidence of
%   detection i.
% 'image_ids' is an Nx1 cell array. image_ids{i} is the image file name
%   for detection i. (not the full path, just 'albert.jpg')

% The placeholder version of this code will return random bounding boxes in
% each test image. It will even do non-maximum suppression on the random
% bounding boxes to give you an example of how to call the function.

% Your actual code should convert each test image to HoG feature space with
% a _single_ call to vl_hog for each scale. Then step over the HoG cells,
% taking groups of cells that are the same size as your learned template,
% and classifying them. If the classification is above some confidence,
% keep the detection and then pass all the detections for an image to
% non-maximum suppression. For your initial debugging, you can operate only
% at a single scale and you can skip calling non-maximum suppression.
'run_detector'
test_scenes = dir( fullfile( test_scn_path, '*.jpg' ));

%initialize these as empty and incrementally expand them.
bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);
step_size=1;
hog_unit=feature_params.template_size/feature_params.hog_cell_size;

dims=[1.1,1,0.9,0.7,0.5,0.3,0.1];
pyramids=cell(2,1);%cell(length(test_scenes),1);

for i = 1:length(test_scenes)
      
    fprintf('Creating pyramid for %s\n', test_scenes(i).name)
    img = imread( fullfile( test_scn_path, test_scenes(i).name ));
    img = single(img)/255;
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end

    ims=cell(length(dims));
    for d=1:length(dims),
        dim=dims(d);
        im=vl_hog(imresize(img,dim),feature_params.hog_cell_size);
    	ims{d}=im;
    end
    pyramids{i}=ims;

end


for i = 1:length(test_scenes)
      
    fprintf('Detecting faces in %s\n', test_scenes(i).name)
    img = imread( fullfile( test_scn_path, test_scenes(i).name ));

    images=pyramids{i};
    cols=[];
    boxes=zeros(0,4);
    vals=zeros(0,1);

    
    for d=1:length(dims),
        hog=images{d};
        dim=dims(d);
        y_winds=floor((size(hog,1)-hog_unit)/step_size)+1;
        x_winds=floor((size(hog,2)-hog_unit)/step_size)+1;
        
        for j=1:step_size:y_winds*step_size,
            for k=1:step_size:x_winds*step_size,

                col=reshape(hog(j:j+hog_unit-1,k:k+hog_unit-1,:),[],1);

                conf=dot(w,col')+b;

                if conf>-1,
                    boxes=[boxes;[(1/dim)*((k-1)*feature_params.hog_cell_size+1),(1/dim)*((j-1)*feature_params.hog_cell_size+1),(1/dim)*((k-1)*feature_params.hog_cell_size+feature_params.template_size),(1/dim)*((j-1)*feature_params.hog_cell_size+feature_params.template_size)]];
                    vals=[vals;conf];
                end
            end
        end
    end





    cur_image_ids(1:size(boxes,1),1) = {test_scenes(i).name};
    
    %non_max_supr_bbox can actually get somewhat slow with thousands of
    %initial detections. You could pre-filter the detections by confidence,
    %e.g. a detection with confidence -1.1 will probably never be
    %meaningful. You probably _don't_ want to threshold at 0.0, though. You
    %can get higher recall with a lower threshold. You don't need to modify
    %anything in non_max_supr_bbox, but you can.
    %[is_maximum] = non_max_supr_bbox(cur_bboxes, cur_confidences, size(img));
    [is_maximum] = non_max_supr_bbox(boxes, vals, size(img));

    cur_confidences = vals(is_maximum,:);
    cur_bboxes      = boxes(is_maximum,:);
    cur_image_ids   = cur_image_ids(is_maximum,:);
 
    
    bboxes      = [bboxes;      cur_bboxes];
    confidences = [confidences; cur_confidences];
    image_ids   = [image_ids;   cur_image_ids];

end




