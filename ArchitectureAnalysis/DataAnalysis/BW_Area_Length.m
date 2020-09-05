function [TotalArea,TotalLength] = BW_Area_Length(BW,tag)
% Data Extraction code from Arch images
ID = str2double(tag(2:end));
load('D:\Ants\2Dnests\Data\CM_pixel_N.mat')
%% Basics
[SKEL,~] = SKELnMAT(BW);
CMpx = 4.*CM_pixel(ID);

TotalArea = CMpx^2.*bwarea(BW);

%% Total Skeletal Length
L = BranchingSkel2Graph(SKEL);
TotalLength = 0;

for i=1:max(max(L))
    branch = false(size(SKEL));
    branch(L==i) = 1;
    branch = bwareafilt(branch,1);
    EPb = bwmorph(branch,'endpoints');
    idx = find(EPb==1,1);
    D = bwdistgeodesic(branch,idx,'quasi-euclidean');
    DIST = max(max(D));
    TotalLength = TotalLength + DIST;
end

TotalLength = CMpx.*TotalLength;
end