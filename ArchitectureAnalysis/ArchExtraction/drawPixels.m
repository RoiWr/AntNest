function [BW1,modeStr,mask] = drawPixels(RGB,BW0,mode,mask)
% function that allows the user to interactively paint pixels white or black (depending on mode) to 'open'
% or 'close' areas in a Arch BW image.
% inputs are the BW0, the original BW image.
% mode can be integer or string. 1 or 'Open' to paint pixels white, open
% passages, and 2 or 'Close' to paint pixels black.
% optional mask input to apply preselected mask as white or black pixels in
% BW0.
% outputs are BW1, the corrected BW image, modeStr - the mode of operation
% as 'Open' or 'Close', and mask - the BW image of the area painted.

switch nargin
    case 0
        error('Not enough input arguments')
    case 1
        error('Not enough input arguments')
    case 2
        mode = input('Open (paint white) [1] or Close (paint black) [2]?\n');
        CreateMask=1;
    case 3
        CreateMask=1;
        if ischar(mode)
            if strcmp(mode,'Open')
                mode=1;
            elseif strcmp(mode,'Close')
                mode=2;
            else
                error('mode not one of accepted arguments: Open/Close')
            end
        end
    case 4
        CreateMask=0;
       if ischar(mode)
            if strcmp(mode,'Open')
                mode=1;
            elseif strcmp(mode,'Close')
                mode=2;
            else
                error('mode not one of accepted arguments: Open/Close')
            end
        end
end

if CreateMask==1
    figure('Name','drawPixels')
    imshow(RGB);
    title('Mark the critical area')
    % overlay
    RED = cat(3,ones(size(BW0)),zeros(size(BW0)), zeros(size(BW0)));
    hold on
    im = imshow(RED);
    alpha(im,0.4.*BW0)

    h = imfreehand;
    %h=imrect;
    accepted_pos = wait(h);
    mask = createMask(h,im);
end

BW1 = BW0;

if mode==1 % open: remove seperating pixels between blubs by setting them to 1
    BW1 = BW1 | mask;
    modeStr = 'Open';
elseif mode==2 % close: create seperating pixels between blubs by setting them to 0
    BW1(mask(:))=0;
    modeStr = 'Close';
end

imshow(BW1)
end