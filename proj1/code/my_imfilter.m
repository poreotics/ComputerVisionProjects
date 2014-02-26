function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% % output = imfilter(image, filter);


%%%%%%%%%%%%%%%%
% Your code here
%%%%%%%%%%%%%%%%

%Padding the image
width = size(filter,1);
height = size(filter,2);
padDim1 = double(int32(fix(width/2)));
padDim2 = double(int32(fix(height/2)));
im = padarray(image,[padDim1 padDim2],'symmetric');

%Separating color channels if necessary
if size(im,3)==3
    r=im(:,:,1);
    g=im(:,:,2);
    b=im(:,:,3);
end


finalImage = zeros(size(image));
filt=reshape(filter,1,[]);

%convolution
for i=1:size(image,2),
    for j=1:size(image,1),

        %Computing color channels individually for color image
        if size(image,3)==3

            redChannel = reshape(r(j:(j+size(filter,1)-1),i:(i+size(filter,2)-1)),1,[]);
            greenChannel = reshape(g(j:(j+size(filter,1)-1),i:(i+size(filter,2)-1)),1,[]);
            blueChannel = reshape(b(j:(j+size(filter,1)-1),i:(i+size(filter,2)-1)),1,[]);

            finalImage(j,i,1)=dot(redChannel,filt);
            finalImage(j,i,2)=dot(greenChannel,filt);
            finalImage(j,i,3)=dot(blueChannel,filt);

        %For grayscale image
        else
            im2 = reshape(im(j:(j+height-1),i:(i+height-1)),1,[]);
            finalImage(j,i)=dot(im2,filt);
        end
    end
end

output=finalImage;




