function saveBW(BW,k,BWset,saveSubFolder)
global saveFolder

% function that saves new BW image after correction. need as inputs: the BW
% image, k = the idx of the image in BWset, the image set, the nest tag and
% the saveSubFolder ('BW2','BW3',etc.)

    strings = strsplit(BWset.ImageLocation{k},'\');
    filename = strings{end};
   % imwrite(BW,[saveFolder,'\',saveSubFolder,'\',filename],'bmp')
   imwrite(BW,['Images\',saveSubFolder,'\',filename],'bmp')
    disp([datestr(now),': ',filename,' saved to ',saveSubFolder,' - ',num2str(k)])
end