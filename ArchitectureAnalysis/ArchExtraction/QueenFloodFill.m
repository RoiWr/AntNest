function Q = QueenFloodFill(RGB,centroid,tolerance)
% outlines a blub of a queen in the input RGB based on x y corrdinates in centroid or user input
% tolerance - [0 1] range parameter for flood-fill method

% Create empty mask.
Q = false(size(RGB,1),size(RGB,2));

switch nargin
    case 0
        error('Not enough input arguments')
    case 1
        figure
        imshow(RGB)
        title('Mark Queen (press <Enter> to quit when done)')
        [x,y] = ginput(1);
        if isempty(x)==1
            return
        end
        centroid = [x,y];
        tolerance = 0.3;
    case 2
        tolerance = 0.3;
    case 3
        % good
end

% Convert RGB image into L*a*b* color space.
X = rgb2lab(RGB);

% Flood fill
row = floor(centroid(2));
column = floor(centroid(1));
normX = sum((X - X(row,column,:)).^2,3);
normX = mat2gray(normX);
addedRegion = grayconnected(normX, row, column, tolerance);
Q = Q | addedRegion;

% QC
try
    while bwarea(Q)> 4000
        warning('Flood Fill filled too much, trying with lower tolerance')
        tolerance = tolerance - 0.02;
        addedRegion = grayconnected(normX, row, column, tolerance);
        Q = Q | addedRegion;
    end
catch
    error('Flood Fill failed')
end

% display
AlphaMap = uint8((0.5*255).*Q); % create AlphaMap
hold on
% Make a truecolor all-RED image. 
RED = cat(3,ones(size(Q)),zeros(size(Q)), zeros(size(Q)));
Overlay = imshow(RED);
% transperancy
alpha(Overlay,AlphaMap)

end