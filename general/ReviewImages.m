function status = ReviewImages(source,dest)
global tag saveFolder

% function that enables saving of editted images created by the various ArchAnalysis manual corrections in folder source.
% After reviewing with the entire image set with an external program, the
% user decided if to copy them to the main folder (dest) from source or to
% discard (delete them)
% the outputs status can be 1 or 0, depending on the Review choice
%path = [saveFolder,'\',source];
path = source;
What2Do = input('Review the edited images using a different program\nto apply changes (copy images to subfolder) press [1]\nto discard press [0]\n');
switch What2Do
    case 0
        rmdir(path)
        status = 0;
    case 1
        copyfile(path,[saveFolder,'\',dest]);
        pause(1)
        rmdir(path,'s')
        status = 1;
end
end