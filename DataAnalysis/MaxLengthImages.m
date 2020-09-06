%% Choose Max Area Images for all UseNests
UseNests = [2:8 10:13 15:18 20:29]; % ** don't use nests F14 and F19 as the exp divided to few parts and F1 and F9 as no workers
mkdir('Images\DevNests')
idxMax = nan(29,1);
PopMax = nan(29,1);
%filenames = nan(29,1);

for k=UseNests
    tag = ['F',num2str(k)];
    load(['Data\',tag,'_Data.mat'],'A')
    [~,idxMax(k)] = max(A.fArea);
    PopMax(k) = A.SmoothPop(idxMax(k));
   % filenames{k}= {A.filename{idxMax(k)}};
    FileJPG = [A.filename{idxMax(k)},'.jpg'];
    copyfile(['Images\RGB\',tag,'\',FileJPG],'Images\DevNests')
end

%% 
PopMax1 = nan(29,1);
for k=UseNests
    tag = ['F',num2str(k)];
    load(['Data\',tag,'_Data.mat'],'A')
    PopMax1(k) = max(A.SmoothPop);
end

UseNests2 = find(PopMax1>5);
%%
S = struct;
Arows = table;

for i=1:numel(UseNests2)
    k = UseNests2(i);
    tag = ['F',num2str(k)];
    load(['Data\',tag,'_Data.mat'],'A','AClassData')
    Arows(i,:) = A(idxMax(k),:);
    S(i).Data = AClassData(idxMax(k)).Data;
end
%%
save('Data\DevNests')