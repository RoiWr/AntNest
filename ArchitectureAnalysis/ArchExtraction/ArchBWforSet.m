%% Arch BW for image set
% use on A data structure with cropped Arch RGB images created by
% ArchAnalysis.m
% step 1: ArchBW - save to BW0 subfolder
% step 2: Queen removal - save to BW1 subfolder
% step 3: Manual corrections - save initially to 'temp' folder and if approved to BW2 subfolder
global tag saveFolder A
tag = input('type nest ID\n','s');
saveFolder = strcat('D:\Ants\2Dnests\Images\BW\',tag);
    mkdir(saveFolder)
load(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])
set = imageSet(['D:\Ants\2Dnests\Images\RGB\',tag]);
logfile('Begin ArchBW processing for RGB images',tag,'BW')
%% add filename field to struct A if does not exist
if ~isfield(A,'filename')
    for i=1:set.Count
        strings = strsplit(set.ImageLocation{i},'\');
        filename0 = strings{end};
        strings = strsplit(filename0,'.');
        filename = strjoin(strings(1:end-1),'.');
        A(i).filename = filename;
    end
end

%%
logfile('Loaded the following RGB images into <set> imageSet',tag,'BW');
for i=1:set.Count
    logfile(set.ImageLocation{i},tag,'BW');
end

%% BW step 1
if exist([saveFolder,'\BW0'],'dir')~=1
    mkdir([saveFolder,'\BW0'])
end

for i=1:set.Count
    RGB = imread(set.ImageLocation{i});
    strings = strsplit(set.ImageLocation{i},'\');
    filename = strsplit(strings{end},'.');
    filename = strjoin(filename(1:end-1),'.');
    
    if i==1
        t0 = makeRGBt0(RGB);
    end
        BW = ArchBW(RGB,0.5,t0); % step 1 BW
        imwrite(BW,[saveFolder,'\BW0\',filename,'.bmp'],'bmp')
end

logfile(['ArchBW step 1 completed for images in set. BW0 images saved in ',saveFolder,'BW0'],tag,'BW');

%% Get annotated data collected by BroodLocator GUI
% Get data and find matching Arch image idx in struct A
Other = importOtherTable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Other.csv']);
Other = TransformPointInTable(Other,A,box); % transform x,y coordinates of Other data to correct registered image

Maintenance = readtable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Maintenance.csv']);
Maint_idxA = matchDates([A.datenum]',Maintenance);

% Wetting events
Wetting_idx = find(~(cellfun(@isempty,strfind(Maintenance{:,2},'WETTING'))));
Wetting_table = Maintenance(Wetting_idx,:);
Wetting_idx = Maint_idxA(Wetting_idx);
Wetting_idx(isnan(Wetting_idx))=0;
Wetting_idx = unique(Wetting_idx');
Wetting_vec = zeros(length(A),1);
Wetting_vec(Wetting_idx)=1;
Wetting_vec_0 = find(~Wetting_vec);
[A(Wetting_idx).Wetting] = deal(1); % create field for wetting_idx in A
[A(Wetting_vec_0).Wetting]=deal(0); % create field for wetting_idx in A

logfile('Extracted Other and Maintenance data',tag,'BW');
logfile(['Wetting events are related to images indexed ',num2str(Wetting_idx)],tag,'BW');
%% BW step 2: Queen removal
BW0set = imageSet([saveFolder,'\BW0']);

if exist([saveFolder,'\BW1'],'dir')~=1
    mkdir([saveFolder,'\BW1'])
end
QueenArea = zeros(length(BW0set.Count),1);

Qff = 0; % queen flood fill failure flag
kqff = 1; % counter

for i=1:BW0set.Count %[1 2 3 BW0set.Count-1 BW0set.Count]
    BW0  = logical(imread(BW0set.ImageLocation{i}));
    BW1 = BW0;
    if (i>1 && i<4) || i>(BW0set.Count-2)
        try
            Q =QueenFloodFill(imread(set.ImageLocation{i}));
            QueenArea(i)=bwarea(Q);
            BW1 = BW0 | Q;
           % fill holes under 1000 pxs
            holes = bwareafilt(imclearborder(~BW1),[0 1000]);
            BW1 = BW1 | holes;
        catch
            warning('QueenFloodFill failed')
            BW1 = BW0;
            Qff(kqff) = i;
            kqff=kqff+1;
        end
        
    
    elseif i>=4 && i<=BW0set.Count-2
        [BW1,QueenArea(i)] = QueenRemove(i,BW0set);
    end
       
    % save
    saveBW(BW1,i,BW0set,'BW1');

    % basic analysis
    props = regionprops(bwareafilt(BW1,[1000 Inf]),'Area');
    A(i).avgArea = mean([props.Area]);
    A(i).NoOfBlubs = length(props);
end

logfile(['ArchBW step 3 (Queen Removal) completed for images in set. BW images saved in ',saveFolder,'\BW2'],tag,'BW');
logfile('All images queen removed by moving mode window except [1 2 3 end-1 end] by QueenFloodFill',tag,'BW');
%% create overlay images
BW1set = imageSet([saveFolder,'\BW1']);
mkdir(['D:\Ants\2Dnests\Images\Overlay\',tag])
figure;
for i=1:BW1set.Count
    % save overlay images for review
    hold off
    RGB = imread(set.ImageLocation{i});
    RGB = imresize(RGB,0.2);
    BW = logical(imread(BW1set.ImageLocation{i}));
    BW = imresize(BW,0.2);
    imshow(RGB)
    if i==1
        RED = cat(3,ones(size(BW)),zeros(size(BW)), zeros(size(BW)));
    end
    hold on
    im = imshow(RED);
    alpha(im,0.4.*BW)
    
    saveas(gcf,['D:\Ants\2Dnests\Images\Overlay\',tag,'\',A(i).filename,'.bmp'])
    disp([datestr(now),': ',A(i).filename,' saved to Overlay - ',num2str(i)])
end

%% BW step 3: fixing semi-manually range of images
copyfile([saveFolder,'\BW1'],[saveFolder,'\BW2']);
BW2set = imageSet([saveFolder,'\BW2']);
mkdir([saveFolder,'\misc'])

%% step 3a: Wetting events
mkdir([saveFolder,'\temp'])
for i=Wetting_idx
    BWout = WettingFilter(i,set,BW2set);
    saveBW(BWout,i,BW2set,'temp');
end

status = ReviewImages('temp','BW2');
%% BW step 3b: fixing passages (tunnels) not detected over a range of images
close all
range=[1 11]; % insert range of images12

TunnelFixSet(range,set,BW2set,'BW2',11);

%% BW step 3c: use BinarizeROI for range of images with problematic adaptive thresholding - >
% use fixed threshold for a given rect ROI for a given range
range=[42 44]; % insert range of images
BinarizeROIset(range,set,BW2set,'BW2',[]);
%% BW step 2d: use masks to add to range of images
mask = selectIMG;
mode = input('Choose mode of mask: [1] - white, [2] - black\n');
for i=42:61
    BWin = imread(BW2set.ImageLocation{i});
    if mode==1
        BWout = BWin | mask;
    elseif mode==2
        BWout = BWin - (BWin & mask);
    end
    saveBW(BWout,i,BW2set,'temp');
end
status = ReviewImages('temp','BW2');

%% step 4: Manual corrections - save to BW2 subfolder after reviewing results

%% QC

for i=1:BW2set.Count
    disp(['processing now image no. ',num2str(i)])
    BW1 = logical(imread(BW2set.ImageLocation{i}));
    % basic analysis
    props = regionprops(bwareafilt(BW1,[1000 Inf]),'Area');
    A(i).avgArea = mean([props.Area]);
    A(i).NoOfBlubs = length(props);
end

figure
subplot(1,2,1)
    plot([A.avgArea])
    title('average area per blub')
subplot(1,2,2)
    plot([A.NoOfBlubs])
    title('number of blubs')

outliersA =  find(isoutlier([A.avgArea],'movmean',5,'ThresholdFactor',1));
outliersB =  find(isoutlier([A.NoOfBlubs],'movmean',5,'ThresholdFactor',1));
flag = union(outliersA,outliersB);
flag = sort(unique([flag,Wetting_idx,(Other.idx)']));

logfile(['Flagged outliers detected for average blub area indexed ',num2str(outliersA)],tag,'BW');
logfile(['Flagged outliers detected for number of blubs indexed ',num2str(outliersA)],tag,'BW');
%% manual correction based on flagged outlier images
mkdir([saveFolder,'\misc'])

for i=flag
    strings = strsplit(BW2set.ImageLocation{i},'\');
    filename = strings{end};
    RGB = imread(set.ImageLocation{i});
    BW1 = logical(imread(BW2set.ImageLocation{i}));
    figure('Name','FlaggedImage')
    subplot(1,2,1)
     imshow(RGB)
%      if ismember(i,Wetting_idx)
%         title([num2str(i),': RGB - After Wetting'])
%      else
%         title([num2str(i),': RGB'])
%      end
%         
%      plotOther(i,Other,RGB)
     
    subplot(1,2,2)
     imshow(BW1)
      title([num2str(i),': BW'])

    
    what2do = input('type\n0 - continue\n1 - open drawPixels\n2 - Image Segmenter app\n3 - BinarizeROI\n4 - QueenFloodFill\n');
    switch what2do
        case 1
            % Manually Fix flagged problems
            while 1
            [BWout,modeStr,mask] = drawPixels(RGB,BW1);
            pause % review edit
            cont = input('Save edit [1] or discard and redo [2] or discard and continue [0]\n');
                switch cont
                    case 0
                        break
                    case 1
                        % save
                        saveBW(BWout,i,BW2set,'BW2');
                        imwrite(mask,[saveFolder,'\misc\drawPixelsMask-',modeStr,'_',filename],'bmp')
                        logfile(['Image ',BW2set.ImageLocation{i},' manually fixed problem using drawPixels in mode ',modeStr],tag,'BW');
                        break
                    case 2
                        continue
                end
            end
        case 2
            imageSegmenter(RGB)
            logfile(['Image ',BW2set.ImageLocation{i},' manually fixed problem using imageSegmenter'],tag,'BW');
        case 3
            while 1
                [BWout,bbox] = BinarizeROI(RGB,BW1);
                cont = input('Save edit [1] or discard and redo [2] or discard and continue [0]\n');
                switch cont
                    case 0
                        break
                    case 1
                        % save
                        saveBW(BWout,i,BW2set,'BW2');
                        disp([datestr(now),': ',filename,' saved to BW2'])
                        logfile(['Image ',BW2set.ImageLocation{i},' manually fixed problem using BinarizeROI w/ bounding box: ',num2str(bbox)],tag,'BW');
                        break
                    case 2
                        continue
                end
            end
        case 4
            try
                Q =QueenFloodFill(RGB);
                QueenArea(i)=bwarea(Q);
                BWout = BW1 | Q;
               % fill holes under 1000 pxs
                holes = bwareafilt(imclearborder(~BWout),[0 1000]);
                BWout = BWout | holes;
                
                cont = input('Save edit [1] or discard and continue [0]\n');
                switch cont
                    case 0
                        continue
                    case 1
                        % save
                        saveBW(BWout,i,BW2set,'BW2');
                        disp([datestr(now),': ',filename,' saved to BW2'])
                        logfile(['Image ',BW2set.ImageLocation{i},' manually fixed problem using QueenFloodFill'],tag,'BW');
                end
            catch
                warning('QueenFloodFill failed')
                Qff(kqff) = i;
                kqff=kqff+1;
            end
        otherwise
            continue
    end
    close 'FlaggedImage'
end



%% Queen and Brood locations for all nests
Queen = readtable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Queen.csv']);
Queen.Properties.VariableNames = {'datetime','x','y'};
Queen = table2struct(Queen);
Queen = Queen(~cellfun(@isnan,{Queen.x})); % remove empty rows
Queen = struct2table(Queen);
Queen = TransformPointInTable(Queen,A,box);

Brood = readtable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Brood.csv']);
Brood.Properties.VariableNames = {'datetime','x','y'};
Brood = table2struct(Brood);
Brood = Brood(~cellfun(@isnan,{Brood.x})); % remove empty rows
Brood = struct2table(Brood);
Brood = TransformPointInTable(Brood,A,box);

% save workspace
save(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])
%% step 5: create functional Area images
% need to run QueenBroodTables.m prior

mkdir(['D:\Ants\2Dnests\Images\funcArea\',tag,'\BW'])
mkdir(['D:\Ants\2Dnests\Images\funcArea\',tag,'\RGB'])
figure;
for i=1:BW2set.Count
    BWout = funcArea(i,BW2set,Queen);
    %BWout = funcArea_noQ(i,BW2set);
   
    imwrite(BWout,['D:\Ants\2Dnests\Images\funcArea\',tag,'\BW\',A(i).filename,'.bmp'],'bmp')
    disp([datestr(now),': ',A(i).filename,' saved to funcArea - ',num2str(i)])
    
    % save overlay images for review
    hold off
    RGB = imread(set.ImageLocation{i});
    imshow(RGB)
    if i==1
        RED = cat(3,ones(size(BWout)),zeros(size(BWout)), zeros(size(BWout)));
    end
    hold on
    im = imshow(RED);
    alpha(im,0.4.*BWout)
    
    saveas(gcf,['D:\Ants\2Dnests\Images\funcArea\',tag,'\RGB\',filename,'.jpg'])

end
logfile('All images processed for functional area and saved at funcArea folder',tag,'BW');

%% Review 
%% save workspace
save(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])
