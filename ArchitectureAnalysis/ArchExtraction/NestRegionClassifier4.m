function Z = NestRegionClassifier4(BW,tag)
%function that segments the excavated nest area into 3 classes:
% 1) tunnels
% 2) small chambers / wide tunnels
% 3) large chambers
% input: binary image (BW), and image tag (F#)
% output Z: matrix the size of the nest BW image where pixels are assigned values 1,2,3 based on the structural class or 0 if not part of the nest

%% get image
%BW = selectIMG;
ID = str2double(tag(2:end));
load('D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\CM_pixel.mat') %load the cm to pixel ratios for each image (can be bypassed)
    
%% set thresholds
T1 = 0.65/(4*CM_pixel(ID)); % if CM_pixel does not exist can use a fixed value here instead
%T2 = 0.65/(4*CM_pixel(ID));
%Tc3 = 25;
%%
[SKEL,MAT] = SKELnMAT(BW);
DT = bwdist(~BW,'quasi-euclidean');
B=DT>T1;
GDT = bwdistgeodesic(BW,B,'quasi-euclidean');
GDT(~BW)=-1;
C2=GDT<=T1 & GDT>-1; % C2 = class 2, for chambers
dilatedPeri = imdilate(bwperim(BW),strel('disk',2)) & BW;
C2d = imdilate(C2,strel('disk',3)) & dilatedPeri;
C2 = C2 | C2d;
C1blubsInC2 = imclearborder(~C2) & BW;
C2(C1blubsInC2)=1;
C1 = BW & ~C2; % C1 = class 1, for tunnels

%%
Z=zeros(size(BW));
Z(C1)=1;
Z(C2)=2;

% filter
Z = BW.*imfilter(Z,fspecial('average',3));
Z = ceil(round(Z,3));
Z(bwareafilt(Z==1,[0 1]))=2;

%% Classify class 2 blubs as class 1 , 2, or 3 (large chambers) based on thresholds
Tw1 = 0.8/(4*CM_pixel(ID));
Tw2 = 0.5*3.15/(4*CM_pixel(ID));
Ta = 30;
Td = 0.3;

C1 = Z==1;
C2 = Z==2;

C2cc = bwconncomp(C2);
C2_props = regionprops('table',C2cc,'Orientation');

C3 = false(size(BW)); % C3 = class 3, for large chambers
for i=1:C2cc.NumObjects
    PixelVals = MAT(C2cc.PixelIdxList{i});
    PixelVals = PixelVals(PixelVals>0);
    maxVal = max(PixelVals);
    devVal = std(PixelVals)/mean(PixelVals);
    Angle = abs(C2_props.Orientation(i));
    if maxVal<Tw1 & Angle>Ta & devVal<Td
        C1(C2cc.PixelIdxList{i})=1;
    elseif maxVal>Tw2
        C3(C2cc.PixelIdxList{i})=1;
    end
end
C2 = C2 & ~C1 & ~C3;

%% final
Z=zeros(size(BW));
Z(C1)=1;
Z(C2)=2;
Z(C3)=3;

%% figure
% imshow(label2rgb(Z)) % a way to view the structural segmentation
% title(tag)

end
