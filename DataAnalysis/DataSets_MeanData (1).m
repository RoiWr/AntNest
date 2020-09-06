%% Mean data for all nests
% create time binned and aligned data sets of all nests for the following parameters
% 1) pop
% 2) fArea
% 3) tArea
% 4) Length
% 5) Depth
% 6) Tunnels (Area and Length)
% 7) Chambers - area of both classes


NumOfRunDays = zeros(29,1);
t0day = nan(29,1); % vector of days of t0 (day when population grows)
S = struct('A',[],'B',[]);
UseNests = [2:8 10:13 15:18 20:29]; % ** don't use nests F14 and F19 as the exp divided to few parts and F1 and F9 as no workers
for k = UseNests
%     tag = ['F',num2str(k)];
%     load(['Data\',tag,'_Data.mat'],'A','AClassData')
%     % add relevent class data from 'AClassData' to 'A'
%     for i=1:length(AClassData)
%         A.TunnelLength(i) = double(AClassData(i).Data(1).SkelLength);
%         A.TunnelArea(i) = double(AClassData(i).Data(1).TotalArea);
%         A.TunnelNumber(i) = double(AClassData(i).Data(1).NumOfBlubs);
%         
%         A.Class2Length(i) = double(AClassData(i).Data(2).SkelLength);
%         A.Class2Area(i) = double(AClassData(i).Data(2).TotalArea);
%         A.Class2Number(i) = double(AClassData(i).Data(2).NumOfBlubs);
%         
%         A.Class3Length(i) = double(AClassData(i).Data(3).SkelLength);
%         A.Class3Area(i) = double(AClassData(i).Data(3).TotalArea);
%         A.Class3Number(i) = double(AClassData(i).Data(3).NumOfBlubs);
%     end
%     
    A = S(k).A;
    % find RunDays
    [RunDays,ia,~] = unique(floor(A.runtime));
    RunDays = RunDays + ones(length(RunDays),1);
    % mat
    A2 = A(ia,6:end);
    varNames = A2.Properties.VariableNames;
    A2 = table2array(A2);
    A2(A2==Inf | A2==-Inf) = NaN;
    A2(isempty(A(:,14:22)))=0;
    % pop
    Pop = A.SmoothPop(ia);
    NumOfRunDays(k) = max(RunDays);
    % find days where population begins to grow, note them as 't0'
    idx = find(Pop>1,1);
    if isempty(idx) % if pop doesn't grow, omit from this calculation
        t0day(k)=NaN;
    else
        t0day(k) = idx;
    end
    
    % distribute data points to array entries
    A3 = nan(400,size(A2,2));
    A3(RunDays,:) = A2;
    % realign data to t0day
    A4 = nan(399,size(A2,2));
    A4(199-t0day(k)+1:199+(NumOfRunDays(k)-t0day(k)),:) = A3(1:NumOfRunDays(k),:);
    
    % Bin Data to 3 day intervals
    n = 399/3;
    A5 = nan(n,size(A4,2));
    BinEdges = ones(n+1,1);
    for i=1:n
        A5(i,:) = mean(A4(1+(i-1)*3:i*3,:),1,'omitnan');
        BinEdges(i+1) = i*ni;
    end
    t = BinEdges(1:end-1)-repmat(199,n,1)+ones(n,1);
    
    % interpolate data
    for j=1:size(A5,2)
        x = find(~isnan(A5(:,j)));
        if isempty(x)
            continue
        end
        V = interp1(x,A5(x,j),x(1):x(end));
        A5(x(1):x(end),j) = V;
    end
    S(k).A = A;
    S(k).B = array2table(A5,'VariableNames',varNames);
end

%% Create matrices for each variable
% skip population data since already made (used median and not mean)
varNames = S(2).B.Properties.VariableNames;
VarOrderProblem = zeros(29,1);
% varNames = varNames([1 4 5 7 11:end]);
M = struct('BinMat',[]);
for j=1:width(S(2).B)
    BinMat = nan(length(A5),29);
    for k=UseNests
        if strcmp(S(2).B.Properties.VariableNames{j},S(k).B.Properties.VariableNames{j})
            BinMat(:,k) = [S(k).B{:,j}];
        else
            VarOrderProblem(k)=1;
        end
    end
    M(j).BinMat = BinMat;
end
%% calc Means
for j=1:length(M)
    M(j).Mean = mean(M(j).BinMat,2,'omitnan');
    M(j).SD = std(M(j).BinMat,0,2,'omitnan');
    M(j).N = sum(~isnan(M(j).BinMat),2);
    M(j).SEM = M(j).SD./sqrt(M(j).N);
end
%% save 
save('Data\MeanData\MeanBinnedData.mat','S','M','t','varNames')