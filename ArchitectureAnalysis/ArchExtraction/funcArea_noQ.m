function BWout = funcArea_noQ(k,BWset)
% function that filters out the 'functional area' from the nest BW image.
% functional area defined here s there is no queen locations (lowercam), by
% the largest blub and all the surface-connected blubs

BW = logical(imread(BWset.ImageLocation{k}));
D = bwareafilt(BW,1);
%% check surface connected areas
    xvec = 1:size(BW,2);
    yvec = ones(size(BW,2),1)';
    D2 = bwdistgeodesic(BW,xvec,yvec,'quasi-euclidean');
    
    D2(D2==Inf)=NaN;
    D2(~isnan(D2))=1;
    D2(isnan(D2))=0;
    D2 = logical(D2);


%% combine both
    BWout = D | D2;
    
end
