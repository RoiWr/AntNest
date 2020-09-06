%% Find LOWER WATER COlumn events
LowerWaterTable = table;
for k=1:29
    tag = ['F',num2str(k)];
    Maintenance = readtable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Maintenance.csv']);
    idx = find(~(cellfun(@isempty,strfind(Maintenance{:,2},'LOWER WATER COLUMN'))));
    if isempty(idx)
        continue
    end
    T = table(repmat(k,numel(idx),1),Maintenance{idx,1},cellstr(datestr(Maintenance{idx,1})));
    LowerWaterTable = [LowerWaterTable;T];
end

LowerWaterTable.Properties.VariableNames = {'tag','datenum','date'};
save('Data\LowerWaterColumnDates.mat','LowerWaterTable')