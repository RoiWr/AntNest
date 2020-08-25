function Table = TransformPointInTable(Table,A,box,TFORMS,k)
% function that transforms a point in a data Table produced by
% BroodLocator by the spatial transform matrix (tform) saved in A.tform (A
% being the ArchAnalysis produced structure) and the bounding box used for the cropping of the images.
% tform produced by image registration using NestRegister.m
% box =[x y w h], dimensions of the cropping produced by imrect or imcrop
% in ArchAnalysis.m
% TFORMS = structure of 2d projective image registrations
% k = nest tag ID in 'F' series

    idx = matchDates([A.datenum],Table);
    Table.idx = idx;

    x = Table.x;
    y = Table.y;
    x1 = x;
    y1 = y;
    
    %*** ADD LOW CAM END DATE CONDITION
    if height(A)~=length(TFORMS)
        load('D:\Ants\2Dnests\Data\LowerCamEndDate.mat','LowerCamEndDate')
        if ~isempty(LowerCamEndDate{k})
            D = find([A.datenum]>LowerCamEndDate{k},1);
            if D~= height(A)-length(TFORMS)
                %error('Problem with matching TFORMS to A entries based on LowerCamEndDate')
                D = height(A)-length(TFORMS);
            end
        elseif length(TFORMS)-height(A)==1
            TFORMS0 = TFORMS;
            TFORMS = TFORMS(2:end);
            D = 0;
        else
            error('Problem with matching TFORMS to A entries based on LowerCamEndDate')
        end
    else
        D = 0;
    end

    
    for i=1:length(x)
        ii = idx(i)-D;
        if isnan(ii)==1
            continue
        elseif height(A)<ii
            continue
        end

        if ii<0 && i>0
            T = ones(3);
        elseif isempty(TFORMS(ii))
            T = ones(3);
        else
            try
                T = TFORMS(ii).T; % transform for the image registration
            catch
                T = TFORMS(ii).tform.T; % transform for the image registration
            end
        end
        
        vec1 = [x(i) y(i) 1]*T;
        vec1 = vec1+[-box(1) -box(2) 0]; % translation transform for the cropping
        
        x1(i)=vec1(1);
        y1(i)=vec1(2);
    end

    Table.x = x1;
    Table.y = y1;
end