function resizeImageSet(tag, ratio, A, sourceFolder, saveFolder)
	% function that resaves a given image set in a lower resolution for faster processing

	%% set up parallel pool
ispool=gcp('nocreate');
 if isempty(ispool)
     parpool(4); % the argument is the number of workers in the pool (the number % of cores you'd use in parallel)
 end

NumOfPics = length(A);
set = imageSet(sourceFolder);
mkdir(saveFolder)

parfor i=1:NumOfPics % run parfor loop
    BW = imread(set.ImageLocation{i});
    BW = imresize(BW ratio);
    imwrite(BW,[saveFolder,'\',A(i).filename,'.bmp'])
end

disp([datestr(now),' :Finished resizing nest ',tag])
