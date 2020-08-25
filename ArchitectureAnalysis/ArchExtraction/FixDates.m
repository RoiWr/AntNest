function FixDates(tag)
load(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])
direc = 'Z:\Roi\NestConstructionExp\NestConstructionExp\';

for i=1:length(A)
    FILENAME = A(i).filename;
    strings = strsplit(FILENAME,'_');
    TAG = strings{1};
    path = [direc,'\',TAG,'\',FILENAME,'.jpg'];
    info = imfinfo(path);
    A(i).datenum = datenum(info.DateTime,'yyyy:mm:dd HH:MM:SS');
    A(i).Date = datestr(A(i).datenum,1);
end
save(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])
end