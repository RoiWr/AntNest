%% RESIZE images to 0.25 of quality using a parfor loop
%% set up parallel pool
ispool=gcp('nocreate');
 if isempty(ispool)
     parpool(4); % the argument is the number of workers in the pool (the number % of cores you'd use in parallel)
 end
 
% load('D:\Ants\2Dnests\Data\RunTimeF.mat','EndDates')

%%
for k=2
    tag = ['N',num2str(k)];
    load(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'],'A')

 %   EndDate = EndDates(k);
  %  A = A([A.datenum]<EndDate+1);
    NumOfPics = length(A);
    set = imageSet(['D:\Ants\2Dnests\Images\funcArea\',tag,'\BW']);
    saveFolder = ['D:\Ants\2Dnests\Images\fA_resizeQuarter\',tag];
    mkdir(saveFolder)

    parfor i=1:NumOfPics % run parfor loop
        BW = imread(set.ImageLocation{i});
        BW = imresize(BW,0.25);
        imwrite(BW,[saveFolder,'\',A(i).filename,'.bmp'])
    end
    disp([datestr(now),' :Finished resizing nest ',tag])
end