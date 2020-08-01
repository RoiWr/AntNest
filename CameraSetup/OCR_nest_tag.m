% OCR for nest tags function
function tag = OCR_nest_tag(D,threshold) % D = input image
%tic
E = 0; % error marker
 %imshow(D)
 C = rgb2gray(imcrop(D,[0 0 size(D,2)./2 size(D,1)./5]));  % crop image to upper 5th left half corner
 %imshow(C)

 BW = C > threshold;  % threshold image for text detection and binarize: 100 for Detect ( 80 for new 800D camera Detect) and 200 for Arch
% imshow(BW)
 S = regionprops(BW,'BoundingBox','Area','Eccentricity'); % detect rectangles
 % now need based on these properties to define the right nest tag
 % use 'struct2cell', invert cell, create cell vector for specific property
 % then use 'cell2mat'.
 S=struct2cell(S)';
 Area = cell2mat(S(:,1));
 % use 'find' to get index depending on evaluative criteria
 % use Area 1st : 40000 - 80000 pxs. if get more than 1 option can use,
 % 'Eccentricity', for this rectangle need ~ 0.8 
 %then use the BoundingBox as ROI for OCR
 k = find(Area>40000 & Area<100000);
 if length(k)==1
     roi = S{k,2}; % use BoundingBox attribute
 elseif length(k)>1
     Eccent = cell2mat(S(k,3));
     [~,q]=min(pdist2(Eccent,0.8));
     roi = S{k(q),2};
 else
     E = 1;
 end

 if E == 1 % 2nd method if 1st failed 
     if threshold == 100 % only works for Detect images
         BWa = C < 180;  % threshold image for rectrangle detect
         S = regionprops(BWa,'BoundingBox','Area','Eccentricity'); % detect rectangles
         S=struct2cell(S)';
         Area = cell2mat(S(:,1));
         k = find(Area>40000 & Area<80000);
         if length(k)==1
            roi = S{k,2}; % use BoundingBox attribute
         elseif length(k)>1
            Eccent = cell2mat(S(k,3));
            [~,q]=min(pdist2(Eccent,0.8));
            roi = S{k(q),2};
         else
             error('no tag rectangle detected')
         end
     else
         error('no tag rectangle detected')
     end
 end
 
 BW = imclearborder(imcomplement(imcrop(BW,roi)));
 se = strel('disk',6);
 BW = imopen(BW,se); % open the image to remove spots
 %imshow(BW)
 txt = ocr(BW,'CharacterSet','ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.','TextLayout','Line'); % CAPS only and numbers
 tag = regexprep(txt.Text,'\s',''); % to remove spaces
 %% fix common errors
 tag = strrep(tag,'Z','2'); % replace all Z with 2, make sure not to use 'Z' series
 
 if tag(1)=='5'
     tag(1)='S';
 elseif tag(1)=='3'
     tag(1)='F';
 end
 
 if tag(end)=='.'
     tag=tag(1:end-1);
 end

 % show BW image and detected text (uncomment for debugging use)
%     figure(2)
%      imshow(BW)
%      text(10,10,tag,'FontSize',20,'Color','y')
%      disp('finish OCR_nest_tag.m')
 %% Annotate original image
%  D2=insertObjectAnnotation(BW.*255,'rectangle',roi2,tag,'LineWidth',10,'FontSize',72);
%  figure(2)
%  imshow(D2)
%toc
end
