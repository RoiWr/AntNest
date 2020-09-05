function BW_Data_Extract_Nest_Set(tag)
% BW Data Extraction from all image set of a nest
% population data aquisition and matching
% saving of data and graphics

% paths
image_path = 'D:\Ants\2Dnests\Images\';
metadata_path = 'D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\';

% load metadata
load([metadata_path,tag,'.mat'],'A')

%% run resize of images
% Total Area images
resizeImageSet(tag, 0.25, A, [image_path, 'Area', tag], [image_path, 'Area_resize', tag])

% funcArea images
resizeImageSet(tag, 0.25, A, [image_path, 'funcArea', tag], [image_path, 'fArea_resize', tag])


Aset = imageSet([image_path, 'Area_resize', tag]);
fAset = imageSet([image_path, 'fArea_resize', tag]);
logfile('Begin BW_Data_Extraction_Area for BW images',tag,'DataExtract')

%% create TFORMS data structure for all tforms
% create tform for t0 image w/ Identity matrix
A(1).tform = projective2d(eye(3));
TFORMS = [A.tform]';
% convert A structure into table and add more variables (from AllData)
A = struct2table(rmfield(A,{'tform','avgArea'}));
A = A(:,[5 1:4]);
AClassData = struct('Data',[]);
% change empty A.Wetting cells to 0
if iscell(A.Wetting)
    for i=1:height(A)
        if isempty(A.Wetting{i})
            A.Wetting{i}=0;
        end
    end
    A.Wetting = logical(cell2mat(A.Wetting));
end

%% Architecture - Functional Area
mkdir(['Data\Graphics\',tag])

parfor i=1:fAset.Count
    BW = imread(fAset.ImageLocation{i});
    [AllData,ClassData,Z,Zf,SKEL,MAT] = BW_Data_Extract(BW,tag);
    %save(['Data\Graphics\',tag,'\',A.filename{i},'.mat'],'Z','Zf','SKEL','MAT')
    AData(i,:) = AllData;
    AClassData(i).Data = ClassData;
%     % disp fig
%         imshow(label2rgb(Z,colormap(prism),'k'))
%         title([tag,':  ',A.Date{i}])
   logfile(['Processed image: ',A.filename{i}],tag,'DataExtract')
   %pause()
end
try
    A = [A AData];
catch
    warning('Duplicate variable name: datenum.')
end

%% Architecture - TotalArea
TotalArea = nan(Aset.Count,1);
TotalLength = nan(Aset.Count,1);
parfor i=1:Aset.Count
    BW = imread(Aset.ImageLocation{i});
    [TotalArea(i),TotalLength(i)] = BW_Area_Length(BW,tag);
   logfile(['Processed image: ',A.filename{i}],tag,'DataExtract')
end
A.TotalArea = TotalArea; A.TotalLength = TotalLength;

%% Population
% get population data
Pop = csvread(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Population.csv'],1,0);
Pop = Pop(:,1:2);
% Replace NaNs with last value
N = find(isnan(Pop(:,2)));
first = find(~isnan(Pop(:,2)), 1 );
if isempty(first)
    Pop(:,2) = zeros(length(N),1);
else
    for j=1:length(N)
        if N(j) < first
            Pop(N(j),2)=0;
        else
            Pop(N(j),2)=Pop(N(j)-1,2);
        end
    end
end
Pop(:,2) = Pop(:,2)+ones(length(Pop),1); % Add 1 to all Population values for the queen
% match dates w/ images in set and data 
DateD = pdist2(A.datenum,Pop(:,1));
DateD(DateD>1)=NaN;
[~,PopIdx] = min(DateD,[],2,'omitnan');
PopIdx(PopIdx==1)=NaN;
[~,First] = min(PopIdx);
for j=1:height(A)
    if isnan(PopIdx(j)) && j<First
        A.Pop(j) = 1;   % fill in value of 1 for all values before 1st pop entry
    elseif isnan(PopIdx(j))
        continue
    else
        A.Pop(j) = Pop(PopIdx(j),2);
    end
end
logfile('Aquired and matched population data to images',tag,'DataExtract')
% Smooth pop
A.SmoothPop = PopSmooth(A.Pop,9);
%% add runtime
A.runtime = A.datenum-repmat(A.datenum(1),height(A),1);
%% save DATA
save(['Data\',tag,'_Data.mat'])
logfile('saved Area and Length data ',tag,'DataExtract')

end
