function [AllData,ClassData,Z,Zf,SKEL,MAT] = BW_Data_Extract(BW,tag)
% Data Extraction code from Arch images
ID = str2double(tag(2:end));
load('D:\Ants\2Dnests\Data\CM_pixel_N.mat')
AllData = struct('fArea',[]);
%% Basics
[SKEL,MAT] = SKELnMAT(BW);
CMpx = 4.*CM_pixel(ID);
pxCM = round(1/CMpx);
MAT = CMpx.*2.*MAT;
[Y,X] = find(BW);

AllData.fArea = CMpx^2.*bwarea(BW);
AllData.MaxDepth = CMpx.*max(Y);

%% longest path measured from a surface point
EP = find(bwmorph(SKEL,'endpoints'));
CC = bwconncomp(SKEL);
top = zeros(CC.NumObjects,1);
for i=1:CC.NumObjects
    skel = false(size(SKEL));
    skel(CC.PixelIdxList{i})=1;
    ep = find(bwmorph(skel,'endpoints'));
    % find highest point
    [I,~] = ind2sub(size(skel),ep);
    [~,idx] = min(I);
    top(i) = ep(idx);
end

% use geodesic distance to get distance to endpoints from top points
GD = bwdistgeodesic(SKEL,top,'quasi-euclidean');
GDep = GD(EP);

AllData.LongestPath = CMpx.*max(GDep);
%% Structure segmentation
Z = NestRegionClassifier4(BW,tag);
    
% figure;
%     imshow(label2rgb(Zf,colormap(prism),'k'))
%     hold on
%     White = ones(size(BW,1),size(BW,2),3);
%     im = imshow(White);
%     alpha(im,255.*SKEL)
%     hold off
    
 %% Filter the classes to keep only significant blubs
 Zf = zeros(size(Z));
 for i=1:3
     Zf(bwareafilt(Z==i,[100 inf]))=i;
 end
 %% Divide skeleton to segements based on classes
 SKELz = SKEL.*Z;
 %%
ClassData = struct('TotalArea',[]);
for i=1:3
    % Area
    ClassData(i).TotalArea = (CMpx^2).*bwarea(Z==i);

    % Skeleton Analysis (mostly relevent to class 1 and 2)
    L = BranchingSkel2Graph(SKELz==i);
    SkelLength = 0;
    WidthSeg = 0;
    AngleSeg = 0;
    k=1;
    
    for j=1:max(max(L))
        branch = false(size(SKEL));
        branch(L==j) = 1;
        branch = bwareafilt(branch,1);
        EPb = bwmorph(branch,'endpoints');
        idx = find(EPb==1,1);
        D = bwdistgeodesic(branch,idx,'quasi-euclidean');
        DIST = max(max(D));
        SkelLength = SkelLength + DIST;
        % check if this skeleton branch is NOT part of the blubs filtered out due to
        % small size. If not then ignore it for angle calc
        OnePix = find(branch,1);
         if ismember(OnePix,find(Zf==i))
            % Mean Angle  - based on 1 cm segments
                % Break branch up to 1 cm long segments 
            branchPixels = OrderedPixelVec(branch,8);
            NumOfSegments = ceil(length(branchPixels)/pxCM);
                for l=1:NumOfSegments
                    seg = false(size(SKEL));
                    if l*pxCM>length(branchPixels)
                        seg(branchPixels(1+pxCM*(l-1):length(branchPixels)))=1;
                    else
                        seg(branchPixels(1+pxCM*(l-1):l*pxCM))=1;
                    end
                    seg = bwareafilt(seg,1);
                    WidthSeg(k) = mean(MAT(seg));
                    props = regionprops('table',seg,'Orientation');
                    AngleSeg(k) = abs(props.Orientation);
                    k=k+1;
                end
         end
    end
    % Length
    ClassData(i).SkelLength = CMpx.*SkelLength;

    % Width
    ClassData(i).NumOf1cmSeg = k;
    ClassData(i).MeanWidth = mean(WidthSeg);
    ClassData(i).STDWidth = std(WidthSeg);
    ClassData(i).SEMWidth = ClassData(i).STDWidth/sqrt(k);
    % Angle
    ClassData(i).Orientation = mean(AngleSeg);
    ClassData(i).STDOrient = std(AngleSeg);
    ClassData(i).SEMWidth = ClassData(i).STDOrient/sqrt(k);

    
    % blub analysis (mostly relevent to classes 3 and 2)
    ClassProps = regionprops('table',Zf==i,'Area','MajorAxisLength','MinorAxisLength','Orientation','Centroid');
    ClassData(i).NumOfBlubs = height(ClassProps);
    if height(ClassProps)==0
    ClassData(i).MeanArea = zeros(0);
    ClassData(i).STDArea = zeros(0);
    ClassData(i).MeanMajorAxisLength =zeros(0);
    ClassData(i).STDMajorAxisLength = zeros(0);
    ClassData(i).MeanMinorAxisLength = zeros(0);
    ClassData(i).STDMinorAxisLength =zeros(0);
    ClassProps.WeightedOrientByArea =zeros(0);
    ClassData(i).MeanBlubOrientation =zeros(0);
    ClassData(i).STDBlubOrientation =zeros(0);
    ClassData(i).SEMBlubOrientation =zeros(0);
    ClassData(i).MeanDepth = zeros(0);
    ClassData(i).STDDepth = zeros(0);
    ClassData(i).SEMDepth =zeros(0);
        continue
    end
    ClassData(i).MeanArea = (CMpx^2).*mean(ClassProps.Area);
    ClassData(i).STDArea = (CMpx^2).*std(ClassProps.Area);
    ClassData(i).MeanMajorAxisLength = CMpx.*mean(ClassProps.MajorAxisLength);
    ClassData(i).STDMajorAxisLength = CMpx.*std(ClassProps.MajorAxisLength);
    ClassData(i).MeanMinorAxisLength = CMpx.*mean(ClassProps.MinorAxisLength);
    ClassData(i).STDMinorAxisLength = CMpx.*std(ClassProps.MinorAxisLength);
    ClassProps.WeightedOrientByArea = abs(ClassProps.Orientation).*ClassProps.Area;
    ClassData(i).MeanBlubOrientation = sum(ClassProps.WeightedOrientByArea)/sum(ClassProps.Area);
    ClassData(i).STDBlubOrientation = std(abs(ClassProps.Orientation),ClassProps.Area./sum(ClassProps.Area));
    ClassData(i).SEMBlubOrientation = ClassData(i).STDBlubOrientation/sqrt(ClassData(i).NumOfBlubs);
    ClassData(i).MeanDepth = CMpx.*sum(ClassProps.Centroid(:,2).*ClassProps.Area)/sum(ClassProps.Area);
    ClassData(i).STDDepth = CMpx.*std(ClassProps.Centroid(:,2),ClassProps.Area./sum(ClassProps.Area));
    ClassData(i).SEMDepth = ClassData(i).STDDepth/sqrt(ClassData(i).NumOfBlubs);

end
%% func Length, mean width and angle
k=zeros(3,1);
WeightedMeanWidth = zeros(3,1);
WeightedSTDWidth = zeros(3,1);
WeightedMeanAngle = zeros(3,1);
WeightedSTDAngle = zeros(3,1);
for i=1:3
    k(i) = ClassData(i).NumOf1cmSeg;
    WeightedMeanWidth(i) = ClassData(i).MeanWidth.*k(i);
    WeightedSTDWidth(i) = ClassData(i).STDWidth.*k(i);
    WeightedMeanAngle(i) = ClassData(i).Orientation.*k(i);
    WeightedSTDAngle(i) = ClassData(i).STDOrient.*k(i);
end
K = sum(k);
AllData.NumOf1cmSeg = K;
AllData.fSkelLength = sum([ClassData.SkelLength]);
% Width
AllData.MeanWidth = sum(WeightedMeanWidth)/K;
AllData.STDWidth = sum(WeightedSTDWidth)/K;
AllData.SEMWidth = AllData.STDWidth/sqrt(K);
%Angle
AllData.Orientation = sum(WeightedMeanAngle)/K;
AllData.STDOrient = sum(WeightedSTDAngle)/K;
AllData.SEMOrient = AllData.STDOrient/sqrt(K);
%% Branch points analysis
bp = bwmorph(SKEL,'branchpoints');
AllData.NumOfBP = sum(sum(bp)); % total number of branch points
AllData.NumOfBPc12 = sum(sum(bp & (Zf==1 | Zf==2))); % number of branch points only in classes 1 and 2
%%
AllData = struct2table(AllData);

end