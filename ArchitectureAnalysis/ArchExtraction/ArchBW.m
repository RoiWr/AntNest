function BW = ArchBW(RGB,s,t0)
% function that creates a binary BW image from an RGB image using adaptive
% thresholding with sensitivity s. Pre processing step is to subtract by
% RGB t0 image created by makeRGBt0.m function.

switch nargin
    case 0
        error('Not enough input arguments')
    case 1
        error('No sensitivity value in inputs')
    case 2
        t0 = uint8(zeros(size(RGB)));
    case 3
        % good
end

Sub = max((RGB(:,:,2:3)-t0(:,:,2:3)),[],3); % use only G and B channels as R channel varies between warm and cold images
I = imadjust(Sub,[0.2 1],[]); imshow(I)%,0.6);

% % consider adding a spatial averaging filter as a preprocessing step
% f = fspecial('disk',10);
% I = imfilter(I,f);

% Threshold image - adaptive threshold
BW = imbinarize(I,'adaptive', 'Sensitivity', s, 'ForegroundPolarity', 'bright');

% verify completely white areas remain white
W = rgb2gray(RGB)>250;
BW(W) = 1;
%% Filter out areas along edges using region props based on area, eccentricity and orientation
props = regionprops('table',BW,'Area','MajorAxisLength','MinorAxisLength','Eccentricity','Orientation','Extent','PixelIdxList');
props.absOrient = abs(props.Orientation);
idx = props.Area >= 100 & ((props.absOrient > 1 & props.absOrient < 89) | props.Eccentricity < 0.996 | props.Extent < 0.75);
pixels = props.PixelIdxList(idx);
pixels = vertcat(pixels{:});
BW = false(size(BW));
BW(pixels) = 1; % create mask

%  figure; imshow(BW)