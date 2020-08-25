function BWout = WettingFilter(k,RGBset,BWset)
% function that corrects for problems in ArchBW.m produced BWset imageSet images
% specifically in After Wetting images caused by the higher pixel
% intensity. This is done by checking which blubs in the after wetting
% image are connected to the previous (before wetting) image. The
% disconnected blubs are removed and for the connected ones, the area is
% cropped from the original RGB image and a simple fixed thresholding is
% done based only on the BLUE channel.
% outputs a BW image
% k is the idx of the wetting image in the imageSets RGBset and BWset

% Wetting images
RGB1 = imread(RGBset.ImageLocation{k});
BW1 = imread(BWset.ImageLocation{k});
BW0 = imread(BWset.ImageLocation{k-1});

%%
D = bwareafilt((BW1-BW0)>0,[1000 inf]);

C0 = bwconncomp(BW0);
L0 = labelmatrix(C0);

C1 = bwconncomp(BW1);
L1 = labelmatrix(C1);

CD = bwconncomp(D);

BWout = BW1;

for i=1:CD.NumObjects
    % find blub label number in BW1 (C1)
    PixelList = CD.PixelIdxList{i};
    blub1 = L1(PixelList(1));
    % find if connected to blub in BW0
    blub0 = mode(L0(C1.PixelIdxList{blub1}));
    
    if blub0==0 % if blub in BW1 is disconnected from blubs in BW0 then remove it
        BWout(CD.PixelIdxList{i})=0;
    else % create a new BW threshold only for the relevent blub
        blubBW = L1==blub1;
        props = regionprops(blubBW,'BoundingBox');
        bbox = round(props.BoundingBox);
            if bbox(3)>= size(BWout,2)
                bbox(3) = size(BWout,2)-1;
            end
            if bbox(4)>= size(BWout,1)
                bbox(4) = size(BWout,1)-1;
            end
            
        crop = imcrop(RGB1(:,:,3),bbox);
        bw = bwareafilt(crop > 200,1);
        BWout(bbox(2):(bbox(2)+bbox(4)),bbox(1):(bbox(1)+bbox(3)))=bw;
    end
end

% verify completely white areas remain white
W = rgb2gray(RGB1)>250;
WandBW1 = W & BW1;
BWout(WandBW1) = 1;
end