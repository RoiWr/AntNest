function BWout = funcArea(k,BWset,Queen,x,y)
global A
% function that filters out the 'functional area' from the nest BW image.
% functional area defined as the area accessible to the ants and the queen
% in the nest

% algorithem: the function takes the queen location from BroodLocationData,
% and find the geodesic distance to all TRUE pixels in the BW image. 
% All pixels which are Inf (infinitely) distant from the queen are filtered
% out.
% Also keeps any blubsw that are connected to the surface if the
% queen-accessible area is also connected
% the function can also work just on x and y input for the queen's
% location, in this case  Queen argument should be left as [].


BW = logical(imread(BWset.ImageLocation{k}));
Queen(isnan(Queen.idx),:) = [];
switch nargin
    case 1
        error('Not enough input arguments.')
    case 2
        error('Not enough input arguments.')
    case 3
        while ~exist('x','var')
            q = find(Queen.idx==k);
            
            if isempty(q)
                % if it is a Wetting image AND the time diff to the previous image is less than one hour
                if A(k).Wetting==1 & (A(k).datenum-A(k-1).datenum)<(1/24)
                      k = k-1;
                      continue
                elseif k < Queen.idx(1) % if this image is before queen locations wee recorded
                    % then use all connected to surface blubs
                    useD2=1;
                    break
                else
                    figure('Name','markQ')
                    imshow(BW)
                    title([A(k).filename,' - ',num2str(k),': mark the queen location'])
                    [x,y] = ginput(1);
                    x = round(x);
                    y = round(y);
                    close('markQ')
                end
            else
                x = round(Queen.x(q));
                y = round(Queen.y(q));
                % check if provided Queen loc is valid (inside the nest)
                try
                    ind = sub2ind(size(BW),y,x);
                catch
                    clear x y
                    Queen.idx(q)=NaN;
                    warning(['In image no. ',num2str(k),' problem with queen location'])
                    continue
                end
                if ~ismember(ind,find(BW(:)))
                        % display
                        hold off
                        imshow(BW)
                        hold on
                        scatter(x,y,[],'+c')
                        pause
                    clear x y
                    Queen.idx(q)=NaN;
                    warning(['In image no. ',num2str(k),' problem with queen location'])
                    continue
                end
            end
        end
    case 4
        error('missing y value input')
    case 5
        x = round(x);
        y = round(y);
end

%%
if exist('useD2','var')
    D = false(size(BW));
else
    D = bwdistgeodesic(BW,x,y,'quasi-euclidean');
    D(D==Inf)=NaN;
    % display
%     figure
%     imshow(D,colormap('jet'),'DisplayRange',[0 max(max(D))])

    D(~isnan(D))=1;
    D(isnan(D))=0;
    D = logical(D);
    % imshow(D)  
end
%% check surface connected areas
if any(D(1,:)) || exist('useD2','var') % if queen-accessible area is connected to surface OR useD2 is directed
    xvec = 1:size(BW,2);
    yvec = ones(size(BW,2),1)';
    D2 = bwdistgeodesic(BW,xvec,yvec,'quasi-euclidean');
    
    D2(D2==Inf)=NaN;
    D2(~isnan(D2))=1;
    D2(isnan(D2))=0;
    D2 = logical(D2);
%    imshow(D2)
end

%% combine both
if exist('D2','var')
    BWout = D | D2;
else
    BWout = D;
end
imshow(BWout)

%% QC
if bwarea(BWout)<1 % if no func Area detected probably due to faulty queen location
    
    
end
