%% Brood-Pile Location
% note in which structure the brood-pile located  and the size of that structure

%load t0day
% load('Data\CM_pixel_F.mat')
% UseNests2 = [3:8 11:13 15:18 20 22 25:29];
%% 

for k=UseNests2(UseNests2>=11)
    tag = ['F',num2str(k)];
    load(['Data\',tag,'_Data.mat'],'A','AClassData','AData','Aset','TFORMS','tag')
    load(['MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'],'Brood')
    CMpx2 = (CM_pixel(k).*4).^2;
    idx = matchDates(A.datenum,Brood);%find brood indexes in A again! 
    Brood.idx = idx;
    Brood = Brood(~isnan(Brood.idx),:);     % remove NAN rows
    ZS = struct('Z',[]);
    for i=1:height(Brood)
        filename = char(A.filename(Brood.idx(i)));
        ZS(i) = load(['Data\Graphics\',tag,'\',filename,'.mat'],'Z');
    end
    
    SType = zeros(height(Brood),1);
    SArea = zeros(height(Brood),1);
    
    parfor m=1:height(Brood)
        filename = char(A.filename(Brood.idx(m)));
        x = round(Brood.x(m)*0.25);
        y = round(Brood.y(m)*0.25);
        if x<1 || y<1 || y>size(ZS(m).Z,1) || x>size(ZS(m).Z,2)
            continue
        end
        SType(m) = ZS(m).Z(y,x);
        if SType(m)==0
            continue
        else
            % find area of brood containing blub 
            CC = bwconncomp(ZS(m).Z==SType(m));
            L = labelmatrix(CC);
            blub = L(y,x);
            props = regionprops('table',CC,'Area');
            SArea(m) = props.Area(blub).*CMpx2;
        end
    end
    
    Brood.SType = SType;
    Brood.SArea = SArea;
    save(['Data\',tag,'_Data.mat'],'A','AClassData','AData','Aset','TFORMS',...
    'tag','Brood')
    
   clearvars -except k CM_pixel UseNests2
end

%% create LONG table of Brood locs (only after pop>1 day)
load('Data\AverageData_aligned.mat','t0day')
% t0day notes in Rundays (floor(runtime)) day where begins to pop grows
BroodLocs = table([],[],[]);
BroodLocs.Properties.VariableNames = {'tag','SType','SArea'};
for k=UseNests2
    tag = ['F',num2str(k)];
    load(['Data\',tag,'_Data.mat'],'A','Brood')
    Rundays = A.runtime(Brood.idx);
    Brood = Brood(Rundays>t0day(k),:);
    T = table;
    T.tag = repmat(k,height(Brood),1);
    T.SType = Brood.SType;
    T.SArea = Brood.SArea;
    
    BroodLocs = [BroodLocs;T];
end

BroodLocs = BroodLocs(BroodLocs.SType>0,:);
save('Data\BroodLocs.mat','BroodLocs')
%% analyze
PercentType2 = zeros(29,1);
for k=UseNests2
    PercentType2(k) = sum(BroodLocs.tag==k & BroodLocs.SType==2)./sum(BroodLocs.tag==k);
end

MeanPercentByNest = mean(PercentType2(UseNests2));
PercentType = zeros(3,1);
for i=1:3
    PercentType(i) = sum(BroodLocs.SType==i)./height(BroodLocs);
end

%% Create dataset of mean brood chamber area size
% first create mean pop and fA for UseNests2
load('Data\MeanData\MeanBinnedData.mat','S','M','t','varNames')
fAmean2 = mean(M(1).BinMat(:,UseNests2),2,'omitnan');
fAsd2 = std(M(1).BinMat(:,UseNests2),0,2,'omitnan');
fA_N2 = sum(~isnan(M(1).BinMat(:,UseNests2)),2);
fAsem2 = fAsd2./sqrt(fA_N2);

Popmean2 = mean(M(13).BinMat(:,UseNests2),2,'omitnan');
Popsd2 = std(M(13).BinMat(:,UseNests2),0,2,'omitnan');
Pop_N2 = sum(~isnan(M(13).BinMat(:,UseNests2)),2);
Popsem2 = Popsd2./sqrt(Pop_N2);
%%
BroodChamberNestData = struct('B',[],'SumArea',[],'Largest',[]);
BroodChamberAreaSum = nan(399/3,29);
BroodChamberAreaLargest = nan(399/3,29);

for k=UseNests2
    tag = ['F',num2str(k)];
    load(['Data\',tag,'_Data.mat'],'A','Brood')
    % create array for Brood chamber area, summing up the brood chamber
    % area if more than pile was annotated
    Brood = Brood(Brood.SType==2,:); % optional: only use small chambers (class 2) and not tunnels (class 1) or large chambers (class 3)
    [idx,TableIdx,~] = unique(Brood.idx);
    B = table(idx);
    for i=1:numel(idx)
        B.n(i) = sum(Brood.idx==idx(i)); % no. of chambers
        B.SumArea(i) = sum(Brood.SArea(Brood.idx==idx(i))); % sum
        B.Largest(i) = max(Brood.SArea(Brood.idx==idx(i))); % area of largest chamber
    end
    B.runtime = A.runtime(idx);
    B.Pop = A.SmoothPop(idx);
    B.fArea = A.fArea(idx);
    
    % remove 0 values
    B = B(B.SumArea>0,:);
    % find RunDays
    [RunDays,ia,~] = unique(floor(B.runtime));
    RunDays = RunDays + ones(length(RunDays),1);
    NumOfRunDays = max(RunDays);
    % mat
    B2 = B(ia,3:4); % analyze for both SumArea(3) and Largest(4)
    B2 = table2array(B2);
    % distribute data points to array entries
    B3 = nan(400,size(B2,2));
    B3(RunDays,:) = B2;
    % realign data to t0day
    B4 = nan(399,size(B2,2));
    B4(199-t0day(k)+1:199+(NumOfRunDays-t0day(k)),:) = B3(1:NumOfRunDays,:);
    
    % Bin Data to 3 day intervals
    n = 399/3;
    B5 = nan(n,size(B4,2));
    BinEdges = ones(n+1,1);
    for i=1:n
        B5(i,:) = mean(B4(1+(i-1)*3:i*3,:),1,'omitnan');
        BinEdges(i+1) = i.*3;
    end
    t = BinEdges(1:end-1)-repmat(199,n,1)+ones(n,1);
    
    % interpolate data
    for j=1:size(B5,2)
        x = find(~isnan(B5(:,j)));
        if isempty(x)
            continue
        end
        V = interp1(x,B5(x,j),x(1):x(end));
        B5(x(1):x(end),j) = V;
    end
    % save
    BroodChamberNestData(k).B = B;
    BroodChamberNestData(k).SumArea = B5(:,1);
    BroodChamberNestData(k).Largest = B5(:,2);

    BroodChamberAreaSum(:,k) = B5(:,1);
    BroodChamberAreaLargest(:,k) = B5(:,2);
    
end

%save('Data\BroodChamber.mat','BroodChamberNestData','BroodChamberAreaSum',...
%    'BroodChamberAreaLargest')
%% plot all UseNests2
figure
for k=UseNests2
    hold on
    plot(t,BroodChamberAreaSum(:,k))
    xlim([0 135])

end
%% median
medBCs = median(BCs,2,'omitnan');
figure; plot(t,medBCs)
xlim([0 135])

density = Popmean2./medBCs;
figure; plot(t,density)
xlim([0 135])

%% calc Means
BCs = BroodChamberAreaSum;
BCsMean = mean(BCs,2,'omitnan');
BCsSD = std(BCs,0,2,'omitnan');
BCsN = sum(~isnan(BCs),2);
BCsSEM = BCsSD./sqrt(BCsN);

BCl = BroodChamberAreaLargest;
BClMean = mean(BCl,2,'omitnan');
BClSD = std(BCl,0,2,'omitnan');
BClN = sum(~isnan(BCl),2);
BClSEM = BClSD./sqrt(BClN);

% save('Data\BroodChamber.mat','BroodChamberNestData','BroodChamberAreaSum',...
%     'BroodChamberAreaLargest','BCs','BCsMean','BCsSD','BCsN','BCsSEM',...
%     'BCl','BClMean','BClSD','BClN','BClSEM','t')
save('Data\BroodChamber2.mat')
%% plot
figure;
plot(t,BCsMean,t,BClMean)
