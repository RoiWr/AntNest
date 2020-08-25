function update_AA(tag)
%% Architecture Analysis - UPDATE the analysis
% analyze new pics aquired since last analysis
% load WORKSPACE
load(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'],'A','Fixed','files','box')
load('D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\BOXES.mat','BOXES')
% tagNo = str2num(tag(2:end));
% box = BOXES{tagNo,2};
% clearvars BOXES

folder_path = ['Z:\Roi\NestConstructionExp\NestConstructionExp\',tag];
NewFiles = struct2cell(dir(strcat(folder_path,'\*.jpg')))';
    idx = contains(NewFiles(:,1),'Arch.jpg');
    NewFiles = sortrows(NewFiles(idx,:),6); % sort by date
files = NewFiles;%cat(1,files,NewFiles);
[~,idx,~] = unique(files(:,1));
files = files(idx,:);
clearvars NewFiles
% sort out problematic 'vacation time', 24-Aug to 8-Sep
idx = find(cell2mat(files(:,6))<datenum('24-Aug-2018','dd-mmm-yyyy') | cell2mat(files(:,6))>=datenum('8-Sep-2018','dd-mmm-yyyy'));
files = files(idx,:);
%endDate = datenum(input('Type the date for the last valid measurement in format yyyy-mm-dd\n','s'),'yyyy-mm-dd'); % last date until to use, if left empty then till end
oldA = length(A);

% resave 
saveFolderReg = strcat('D:\Ants\2Dnests\Images\RGBreg\',tag);
    mkdir(saveFolderReg)
saveFolderCrop = strcat('D:\Ants\2Dnests\Images\RGB\',tag);
    mkdir(saveFolderCrop)

%% create fixed image based on last image in A
if ~exist('Fixed','var')
    k = find(~(cellfun(@isempty,strfind(files(:,3),A(end).Date))));
    if length(k)>1
        % 1st check how many images with that date are in A
        kA = find(~(cellfun(@isempty,strfind({A.Date},A(end).Date))));
        if length(k)==length(kA)
            k=k(end);
        else
            error([datestr(now),': Too many last images in A and files with same date in nest ',tag])
        end
    end

    t0 = imread([files{1,2},'\',files{1,1}]);
        if size(t0,2) > size(t0,1) % need to rotate the image
            t0=imrotate(t0,-90);
        end
    Fixed = imread([files{k,2},'\',files{k,1}]);
        if size(Fixed,2) > size(Fixed,1) % need to rotate the image
            Fixed=imrotate(Fixed,-90);
        end
    fixedRefObj = imref2d(size(t0)); % Default spatial referencing objects
    movingRefObj = imref2d(size(Fixed)); 
    Fixed = imwarp(Fixed, movingRefObj, A(end).tform, 'OutputView', fixedRefObj);
end

%% get only new files
idx = find([files{:,6}]>floor(A(end).datenum+1)); % last file + 1 day to compensate on diff btwn camera time and file mod time
j=oldA;
%% 
for i=47%idx
    %j=j+1;
    j=44;
    disp([datestr(now),': Processing file ',files{i,1}])
    
        path = strcat(files{i,2},'\',files{i,1});
        info = imfinfo(path);
        
        F = info.DigitalCamera.FNumber;
        if F~=4 % validate the chosen pic is really an "Arch" using aperture value of 4.0
            warning(['Skip file ',files{i,1},' not a real Arch image'])
            continue
        end
            
    % read image and process
    RGB = imread(path);
            if info.Width > info.Height % need to rotate the image
                RGB=imrotate(RGB,-90);
            end
    
   
%     % OCR
%     try
%         tag_t = OCR_nest_tag(RGB,200);
%     catch
%         warning('no tag detected in OCR')
% %             UnidentifiedTag(k1) = j;
% %             k1=k1+1;
%         imshow(RGB)
%         tag_t = input('Insert nest tag\n','s');
%             %continue
%     end
%          % change tag of F series to no dot and define nestID
%          if length(tag_t)==4 && tag_t(1)=='F'
%              tag_t = strcat('F',tag_t(4));
%          end
%     
%          
%     if strcmp(tag,tag_t)==0
%         continue
%     end

    try
        [RGBr,A(j).tform] = NestRegister(Fixed,RGB,'SquareDetect','SquareDetect'); % register to 1st new pic of upperCam
    catch
        warning(['NestRegister failed for file ',files{i,1}])
        continue
    end
%    end
    
    % Crop

    RGBc = imcrop(RGBr,box);
    
    % Date
    A(j).datenum = datenum(info.DigitalCamera.DateTimeOriginal,'yyyy:mm:dd HH:MM:SS');
    A(j).Date = datestr(A(j).datenum,1);
    % filename
    strings = strsplit(files{i,1},'.');
    filename = strjoin(strings(1:end-1),'.');
    A(j).filename = filename;
    
    imwrite(RGBr,[saveFolderReg,'\',files{i,1}],'jpg','comment',[files{i,3},': Reg'],'quality',100);
    imwrite(RGBc,[saveFolderCrop,'\',files{i,1}],'jpg','comment',[files{i,3},': Reg and Cropped'],'quality',100);

end

%% add filename field to struct A if does not exist
saveFolderCrop = strcat('D:\Ants\2Dnests\Images\RGB\',tag);
set = imageSet(saveFolderCrop);
for i=1:set.Count
    strings = strsplit(set.ImageLocation{i},'\');
    filename0 = strings{end};
    strings = strsplit(filename0,'.');
    filename = strjoin(strings(1:end-1),'.');
    A(i).filename = filename;
end
%% save important workspace variables
A = A(~cellfun(@isempty,{A.Date})); % remove empty rows
save(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])
end