% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

% Placeholder that you can delete. Empty features.

%getting gradient magnitude and orientation for each pixel in original


features = [];
patchSize=feature_width/4;


gradFilt=fspecial('sobel');
gradFiltX=gradFilt';
falloff=fspecial('gaussian',[16 16], feature_width/2); 

dx=imfilter(image,gradFiltX);
dy=imfilter(image,gradFilt);

orientation=radtodeg(atan2(dy,dx));
magnitude=sqrt(dx.^2+dy.^2);

bins=[-180,-135,-90,-45,0,45,90,135,180];


%for each keypoint
for i=1:size(x,1),
    
    or=orientation(y(i)-(feature_width/2-1):y(i)+(feature_width/2),x(i)-(feature_width/2-1):x(i)+(feature_width/2));
    mg=magnitude(y(i)-(feature_width/2-1):y(i)+(feature_width/2),x(i)-(feature_width/2-1):x(i)+(feature_width/2));
    mg=mg.*falloff;
   
    descriptor=[];
    for j=1:4,
        for k=1:4,
            patch=or(j*patchSize-(patchSize-1):j*patchSize,k*patchSize-(patchSize-1):k*patchSize);
            mags=mg(j*patchSize-(patchSize-1):j*patchSize,k*patchSize-(patchSize-1):k*patchSize);

            histTemp=[];
            
            for b=1:size(bins,2)-1,
                inds=find(patch>=bins(b)&patch<bins(b+1));
                value=sum(mags(inds));
                histTemp(end+1)=value;
            end
            descriptor=cat(2,descriptor,histTemp);
        end      
    end

    %normalize, threshold, renormalize
    descriptor=descriptor./norm(descriptor);
    descriptor=min(descriptor,0.07);
    descriptor=descriptor./norm(descriptor);
    descriptor=descriptor.^(.5);
    
    %concatenate
    features=cat(1,features,descriptor);
    

    
end


end








