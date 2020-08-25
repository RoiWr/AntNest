function TunnelFixSet(range,RGBset,BWset,subfolder,markImageIdx)
global tag saveFolder

switch nargin
    case 4
        if length(range)==1
            markImageIdx = range;
        else
            markImageIdx = range(2);
        end
end

%mkdir([saveFolder,'\temp'])
mkdir('Images\temp')
% function that executes the drawPixels function for a given
% range of images in image set BWset
% range = [1stIdx LastIdx]
% the images are then saved in the appropriate folder based on tag and
% foldername inputs
if length(range)==1
    vec = range;
else
    vec  = range(1):range(2);
end
figure('Name','fixTunnels')
if length(vec)==1
    opt = vec(1);
elseif length(vec)==2
    opt = [vec(1) vec(end)];
else
    opt = [vec(1),round(median(vec)),vec(end)];
end

markImageRGB = imread(RGBset.ImageLocation{markImageIdx});
markImageRGB = imresize(markImageRGB,0.25);
markImageBW = imread(BWset.ImageLocation{markImageIdx});
figure('Name',num2str(markImageIdx)); imshow(markImageBW)
[~,modeStr,mask] = drawPixels(markImageRGB,markImageBW);

% apply to example images
B = struct('BW0',[]);
for i=1:length(opt)
    B(i).RGB = imread(RGBset.ImageLocation{opt(i)});
    B(i).BW = imread(BWset.ImageLocation{opt(i)});
    [BW,~,~] = drawPixels(B(i).RGB,B(i).BW,modeStr,mask);
    figure; imshow(BW)
end

% review results and if good run next section to apply correction
What2Do = input('Apply changes to all images in range [1] or discard edit [0]?\n');
if What2Do ~=1
    return
end
%% Apply the mask to all images in range
kk = input('Type the number of this mask\n');
disp([datestr(now),': manually marked passage for the following images in range ',num2str(range),' using mask',num2str(kk),' in misc in mode ',modeStr])
imwrite(mask,[saveFolder,'\misc\','mask',num2str(kk),'.bmp'],'bmp');

for i=vec
    RGB = imread(RGBset.ImageLocation{i});
    BW0 = imread(BWset.ImageLocation{i});
    [BW1,~,~] = drawPixels(RGB,BW0,modeStr,mask);

    % save
    saveBW(BW1,i,BWset,'temp');
end

status = ReviewImages('Images\temp',[]);%subfolder);
if status==1
    % save to log file
    logfile([datestr(now),': manually marked passage for the following images in range ',num2str(range),' using mask',num2str(kk),' in misc in mode ',modeStr],tag,'BW');
    logfile(['Applied passage mask to images in index range ',num2str(range),' - images saved to ',subfolder,' subfolder'],tag,'BW');
end
end