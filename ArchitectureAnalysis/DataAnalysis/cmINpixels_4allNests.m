% cmINpixels: run for all the nests and save data to table
% generate nest list
for jj=1:10
    nests{jj} = ['N',num2str(jj)];
end
%% 
CM_pixel = zeros(length(nests),1);

parfor i=2:length(nests)
    tag = nests{i};
    set = imageSet(['D:\Ants\2Dnests\Images\RGB\',tag]);
    RGB = imread(set.ImageLocation{1});
    CM_pixel(i) = cmINpixels(RGB);
end
