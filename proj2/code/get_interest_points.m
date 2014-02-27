










%Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.



gradFilt=fspecial('sobel');
gradFiltX=gradFilt';
filt=fspecial('gaussian',11); 

dy=imfilter(image,gradFilt);
dx=imfilter(image,gradFiltX);

dxdy=dx.*dy;
dx2=dx.^2;
dy2=dy.^2;

dxdy=imfilter(dxdy,filt);
dx2=imfilter(dx2,filt);
dy2=imfilter(dy2,filt);

har=(dx2.*dy2 - dxdy.^2) - .01*(dx2 + dy2).^2; 

%threshold--I just tuned this to get the best match accuracy. 
har(har<.1)=0;

%nonmax suppression
har=blkproc(har,[5 5],@minSuppress);

%suppress edges. This was also a quick way to deal with edge cases in the
%creation of my feature descriptor.
har(1:feature_width,1:end)=-1;
har(end-feature_width:end,1:end)=-1;
har(1:end,end-feature_width:end)=-1;
har(1:end,1:feature_width)=-1;

[y,x]=find(har>0);

end

%my own function for non-max suppression
function vec = minSuppress(A)
    
    [maxA,ind] = max(A(:));
    [m,n] = ind2sub(size(A),ind);
    vec=zeros(size(A));
    vec(m,n)=maxA;


end
