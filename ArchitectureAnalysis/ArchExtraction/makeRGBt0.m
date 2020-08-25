function t0 = makeRGBt0(RGB)
% function to make a t0 RGB image used for subtraction in ArchBW.m,
% takes the t0 RGB and fills in with 0 values (black) the initial hole

% Create empty mask.
BW = false(size(RGB,1),size(RGB,2));

% find initial hole blub
H = size(RGB,1);
W = size(RGB,2);
mask = poly2mask([W/3 W/3 2*W/3 2*W/3],[1 H/4 H/4 1],H,W); % create mask for central upper 12th of image

G = imbinarize(uint8(mask).*RGB(:,:,2),165/255);
G = bwareafilt(G,1,'largest');
props = regionprops(G,'Centroid');
row = ceil(props.Centroid(2));
column = ceil(props.Centroid(1));

% Flood fill
X = rgb2lab(RGB); % Convert RGB image into L*a*b* color space.
tolerance = 2.000000e-01;
normX = sum((X - X(row,column,:)).^2,3);
normX = mat2gray(normX);
addedRegion = grayconnected(normX, row, column, tolerance);
BW = BW | addedRegion;

% Create masked image.
t0 = RGB;
for i=1:3
    I = RGB(:,:,i);
    med = median(median(I)); % find median pixel value
    I(BW) = med;
    t0(:,:,i)=I;
end

% % Create masked image.
% t0 = RGB;
% t0(repmat(BW,[1 1 3])) = repmat(med,[size(BW,1),size(BW,2),1]);

end