function RGB = selectIMG()
% function to select image file and read it into workspace
    [filename,filepath] = uigetfile('*.*');
    RGB = imread(strcat([filepath,filename]));
end