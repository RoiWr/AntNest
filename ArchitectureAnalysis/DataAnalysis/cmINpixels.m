function CM_pixel = cmINpixels(RGB)
% function that outputs a cm/pixel ratio of an image based on the distance
% between the 2 lower support blocks.
%input = RGB image of type 'Arch'
BW = preNestRegister(RGB,'Arch');
S = struct2cell(regionprops(BW,'Centroid')); % detect circles
S = cell2mat(S');
PxDist = min(pdist2(S(1,:),S(2:end,:)));
cmDist = 17.6; % average value of 17.6 cm for this distance for all the nests
CM_pixel = cmDist/PxDist;
end

