function [SKEL,MAT] = SKELnMAT(BW)
% function that creates a skeleton image and a MAT (medial-axis transform)
% image (in pixel units) from a given BW binary image
    h = fspecial('average',3);
    BW2 = imfilter(BW,h,1); % smooth image
    holes = bwareafilt(imclearborder(~BW2),[0 50]); % filter out small (<50 pxs) holes
    BW2  = BW2 | holes;
   
    SKEL = bwmorph(BW2,'thin',inf); % figure; imshow(SKEL) % skeletonization
    distTrans = bwdist(~BW,'quasi-euclidean');
    MAT = SKEL.*distTrans;
end