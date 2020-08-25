function BinarizeROIset(range,RGBset,BWset,subfolder,cropImageIdx)
global tag saveFolder
% function that executes the BinarizeROI thresholding function for a given
% range of images in image sets RGBset and BWset
% range = [1stIdx LastIdx]
% the images are then saved in the appropriate folder based on tag and
% foldername inputs
mkdir([saveFolder,'\temp'])

vec  = range(1):range(2);
if isempty(cropImageIdx)
    cropImageIdx = input('Choose in which image to set ROI rectangle:\nfirst - [1]\nmiddle - [2]\n last - [3]\n'); 
        switch cropImageIdx
            case 1
                j = vec(1);
            case 2
                j = round(median(vec));
            case 3
                j = vec(end);
            otherwise
                j = vec(end);
        end
end

BWin = imread(BWset.ImageLocation{j});
RGB = imread(RGBset.ImageLocation{j});
    
[BWout,bbox] = BinarizeROI(RGB,BWin);
figure; imshow(BWout)
pause

for i=vec
    BWin = imread(BWset.ImageLocation{i});
    RGB = imread(RGBset.ImageLocation{i});
    [BWout,~] = BinarizeROI(RGB,BWin,bbox);
 
    % save
    saveBW(BWout,i,BWset,'temp');

end

status = ReviewImages('temp',subfolder);
if status==1
    logfile(['Applied binarizeROI mask to images in index range ',num2str(range),' - images saved to ',subfolder,' subfolder'],tag,'BW');
    logfile(['Use BinarizeROI w/ bounding box: ',num2str(bbox)],tag,'BW');
end

end
