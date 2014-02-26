function channels = get_channels(img)
%'img' is height x width x 3 (RGB)
%'channels' is height x width x 14, with the 14 channels specified in
%sketch tokens Section 2.2.1

% helpful functions: I = rgbConvert(I,'luv') and imfilter

img=im2single(img/255);

filt0=[-1 0 1;-2 0 2;-1 0 1];
filt45=[0 1 2;-1 0 1;-2 -1 0];
filt90=filt0';
filt135=flipud(filt45');
filts=[{filt0},{filt45},{filt90},{filt135}];
sig=[0,1.5,5];
channels=rgbConvert(img,'luv');
img=rgb2gray(img);

for s=sig,
    if s~=0,im=imfilter(img,fspecial('gaussian',3,s),'symmetric');
    else im=img; end
    channels=cat(3,channels,sqrt(imfilter(im,filt0,'symmetric').^2+imfilter(im,filt90,'symmetric').^2));
    if s==sig(1)||s==sig(2),
        for f=1:length(filts),
            filter=filts{f};
            channels=cat(3,channels,abs(imfilter(im,filter,'symmetric')));
        end
    end 
end

