% Nest image registration function
function [movingReg,tform] = NestRegister(fixed,moving,fixed_mode,moving_mode)
% function outputs a registered nest image and its spatial transformation object based on fixed and moving images
% mode pertains to 'Detect' or 'Arch' exposures
f = preNestRegister(fixed,fixed_mode); % preprocessing to leave only support block circles
m = preNestRegister(moving,moving_mode);

fixedRefObj = imref2d(size(fixed)); % Default spatial referencing objects
movingRefObj = imref2d(size(moving));

% diff method using fitgeotrans based on blocks centroids
 % for fixed
        S = struct2cell(regionprops(f,'Centroid')); % detect support blocks
        if strcmp(fixed_mode,'Arch') || strcmp(fixed_mode,'Detect')
            if length(S) < 6
                error('6 control points not recognized in Fixed image')
            end
            C1 = cell2mat(S(1:6)');
        else
            if length(S)<4
                error('4 control points not recognized in Fixed image')
            end
            C1 = cell2mat(S(1:4)');
        end
           
        
 % for moving
         S = struct2cell(regionprops(m,'Centroid')); % detect support blocks
         if strcmp(moving_mode,'Arch') || strcmp(moving_mode,'Detect')
            if length(S) >= 6
                C2 = cell2mat(S(1:6)');
            elseif length(S) >=4
                C2 = cell2mat(S');
            elseif length(S) < 4
                error('Not enough circles detected in MOVING for registration')
            end
        else
            if length(S)<4
                error('Not enough squares detected in MOVING for registration')
            end
            C2 = cell2mat(S(1:4)');
        end

         

% match centroid arrays
if size(C2,1) < size(C1,1)
    diff = size(C1,1)-size(C2,1);
    for j=1:diff
        D = pdist2(C2,C1);
        M = min(D);
        [~,maxIDX] = max(M);
        C1(maxIDX,:)=[];
    end
end
% should be size(C2,1) == size(C1,1)
    D = pdist2(C2,C1);
    [~,Midx] = min(D);
    C2 = C2(Midx,:);


% check which image has less control points and match the number to the
% lower one
%     if length(C1)~=length(C2)
%         if length(C1)>length(C2)
%             C1 = C1(1:length(C2));
%         else
%             C2 = C2(1:length(C1));
%         end
%     end
%  
method = 'projective'; %other options: 'Nonreflectivesimilarity','similarity','affine'
tform = fitgeotrans(C2,C1,method);

% spatial transformation evaluation
Det = abs(det(tform.T)); % absolute value of the spatial transformation matrix determinant
if Det < 0.6 || Det > 1.4 % range of good transformation, more or less than that is too much
    error('Spatial transformation is too large')
end

movingReg = imwarp(moving, movingRefObj, tform, 'OutputView', fixedRefObj);
disp('Nest Register completed successfully')
%imshow(movingReg)
end