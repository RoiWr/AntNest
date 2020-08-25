%% Architecture Analysis
folder_path = uigetdir;
files = struct2cell(dir(strcat(folder_path,'\*.jpg')))';
    idx = contains(files(:,1),'Arch.jpg');
    files = sortrows(files(idx,:),6); % sort by date
tag = input('type nest ID\n','s');
%% 
A = struct('tform',[],'Date',[],'datenum',[],'filename',[]); %preallocate structure
% resave 
saveFolderReg = strcat('D:\Ants\2Dnests\Images\RGBreg\',tag);
    mkdir(saveFolderReg)
saveFolderCrop = strcat('D:\Ants\2Dnests\Images\RGB\',tag);
    mkdir(saveFolderCrop)
%% 
for i=2:length(files) % rerun again with i=FailNR after troubleshooting FailNR (or for WrongTag)
    disp([datestr(now),': Processing file ',files{i,1}])
    
        path = strcat(folder_path,'\',files{i,1});
        info = imfinfo(path);
        
        F = info.DigitalCamera.FNumber;
        if F~=4 % validate the chosen pic is really an "Arch" using aperture value of 4.0
            warning(['Skip file ',files{i,1},' not a real Arch image'])
            continue
        end
%            ISO = info.DigitalCamera.ISOSpeedRatings;
%            if ISO~=800
%                warning(['Skip file ',files{i,1},' not a real Arch image'])
%                continue
%            end
    % read image and process
    RGB = imread(path);
            if info.Width > info.Height % need to rotate the image
                RGB=imrotate(RGB,-90);
            end
    
    % OCR
    try
        tag_t = OCR_nest_tag(RGB,200);
    catch
        warning('no tag detected in OCR')
        imshow(RGB)
        tag_t = input('Insert nest tag\n','s');
    end
         % change tag of F series to no dot and define nestID
         if length(tag_t)==4 && tag_t(1)=='F'
             tag_t = strcat('F',tag_t(4));
         end
    
         
    if i==1 % for 1st pic which is t0 
        tag = tag_t;
        Fixed = RGB;
        RGBr = Fixed;
       % manually crop t0 pic for less error, use same rect for all others as box
       figure
       imshow(Fixed)
       disp('Mark the rectangle on the figure where to crop')
        h = imrect;
        box = wait(h);
      
    else % for all others
        if strcmp(tag,tag_t)==0
            continue
        end
        
        try
            % nest register, change mode in function arguments if has
            % sqaure support blocks from 'Arch' to 'SquareArch'
      [RGBr,A(i).tform] = NestRegister(Fixed,RGB,'SquareArch','SquareArch'); % register
%         RGBr = RGB;
%         A(i).tform = [];
        catch
            warning(['NestRegister failed for file ',files{i,1}])
            continue
        end
    end
    
    % Crop
    RGBc = imcrop(RGBr,box);
    % Date
    A(i).datenum = datenum(info.DateTime,'yyyy:mm:dd HH:MM:SS');
    A(i).Date = datestr(A(i).datenum,1);   
        % filename
    strings = strsplit(files{i,1},'.');
    filename = strjoin(strings(1:end-1),'.');
    A(i).filename = filename;
    
    imwrite(RGBr,[saveFolderReg,'\',files{i,1}],'jpg','comment',[files{i,3},': Reg'],'quality',100);
    imwrite(RGBc,[saveFolderCrop,'\',files{i,1}],'jpg','comment',[files{i,3},': Reg and Cropped'],'quality',100);

end
%% Save
A = A(~cellfun(@isempty,{A.Date})); % remove empty rows
save(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'],'A','files','box','Fixed','tag')
disp('Saved Data')

