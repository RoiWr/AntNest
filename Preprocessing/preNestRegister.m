function BW = preNestRegister(RGB,mode)
% preprocess nest image registration function
switch mode
    case 'Detect'
        BW = RGB(:,:,1) < 10; % create BW image based on RED channel,T=10
    case 'Arch'
        BW = RGB(:,:,1) < 60; % create BW image based on RED channel,T=60
    case 'SquareArch' % for nests with square support blocks
        mask = poly2mask([1 1 size(RGB,2) size(RGB,2)],ceil(size(RGB,1).*[0.12 0.88 0.88 0.12]),size(RGB,1),size(RGB,2));
        BW = logical(mask.*(RGB(:,:,1) < 60)); % create BW image based on RED channel,T=60
    case 'SquareDetect' % for nests with square support blocks
        mask = poly2mask([1 1 size(RGB,2) size(RGB,2)],ceil(size(RGB,1).*[0.12 0.88 0.88 0.12]),size(RGB,1),size(RGB,2));
        BW = logical(mask.*(RGB(:,:,1) < 20)); % create BW image based on RED channel,T=10 
end

if size(RGB,1)==6000 % if resolution of new camrea 800D
    se = strel('disk',6);
    BW = imopen(BW,se);
    BW = bwareafilt(BW,[10000 25000]);
else % old resolution, camera 500D
    se = strel('disk',5);
    BW = imopen(BW,se);
    BW = bwareafilt(BW,[8000 18000]);
end



% basic filtering
BW = bwpropfilt(BW,'Eccentricity',[0 0.9]);
BW = imclearborder(BW);

% check that get max 6 objects
[~,numObjects]=bwlabel(BW);
if numObjects > 6
    BW = bwpropfilt(BW,'EulerNumber',6);
end