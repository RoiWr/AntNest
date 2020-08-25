function [BWout,QueenArea] = QueenRemove(i,BWset)
% function that removes the Queen from Arch images by using a moving
% mode with window of 5 images to assess whether a pixel is black because
% it is the sand/soil or just the queen for this image.
% inputs are i, the idx of the image in image set BWset created by ArchBW.m
% function in ArchAnalysis.m
% outputs are the corrected BW image with the queen removed and QueenArea,
% the pixel area cleared, assumed to be the queen, but highly likely to be
% other noise.

BW = logical(imread(BWset.ImageLocation{i}));
M = bwareafilt(imdilate(BW,strel('disk',60)),5);
        blackPixels = M&~BW;
        PixelList = find(blackPixels(:));
        stack = zeros(length(PixelList),5);

        for j=1:5
            k=-2:2;
            bwt = imread(BWset.ImageLocation{i+k(j)});
            stack(:,j) = bwt(PixelList);
        end

        % calculate mode value for each pixel in PixelList
        values = mode(stack,2);
        BW(PixelList)=values;
        % QC
        QueenArea = sum(values>0);
  
    % fill holes under 1000 pxs
    holes = bwareafilt(imclearborder(~BW),[0 1000]);
    BWout = BW | holes;
 end