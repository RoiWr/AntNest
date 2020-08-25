function [BWout,bbox] = BinarizeROI(RGB,BWin,bbox)
% function that outputs a BW image based on fixed thresholding of the 
% Blue channel of an input RGB imagein a user-selected rectangle ROI in the image.
% If bbox, the dimensions of the ROI in the form of [x y w h], are not
% given they are selected interactively. Also they are are outputed.
% if BWin, a BW image with problematic areas need to be corrected are not
% given an adaptive binarization image will be genereated based on the RGB
% image. (not recommended).
% Can be used for cases of wetting or sand refill (lots of air holes) in
% the nests.

switch nargin
    case 0
        error('Not enough input arguments')
    case 1
        figure; imshow(RGB)
            % overlay
            RED = cat(3,ones(size(BWin)),zeros(size(BWin)), zeros(size(BWin)));
            hold on
            im = imshow(RED);
            alpha(im,0.4.*BWin)
        h = imrect;
        bbox = wait(h);
        BWin = imbinarize(RGB(:,:,3),'adaptive', 'Sensitivity', 0.5, 'ForegroundPolarity', 'bright');
    case 2 % only for testing dont really use
        figure; imshow(RGB)
        h = imrect;
        bbox = wait(h);
    case 3
        % good
end
%% bbox
bbox = round(bbox);
bbox(bbox<0)=1;
if bbox(3)>= size(BWin,2)
    bbox(3) = size(BWin,2)-1;
end
if bbox(4)>= size(BWin,1)
    bbox(4) = size(BWin,1)-1;
end
if bbox(2)+bbox(4)> size(BWin,1)-1
    bbox(4) = size(BWin,1)-1-bbox(2);
end
if bbox(1)+bbox(3)> size(BWin,2)-1
    bbox(3) = size(BWin,2)-1-bbox(1);
end
%%
I = imcrop(RGB(:,:,3),bbox);
% consider adding a spatial averaging filter as a preprocessing step
% f = fspecial('disk',10);
% I = imfilter(I,f);

bw = I > 180; imshow(bw)

BWout = BWin;
BWout(bbox(2):(bbox(2)+bbox(4)),bbox(1):(bbox(1)+bbox(3)))=bw;

figure; imshow(BWout)
end