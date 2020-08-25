%% Queen and Brood locations for all nests
global tag A box
Queen = readtable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Queen.csv']);
Queen.Properties.VariableNames = {'datetime','x','y'};
Queen = table2struct(Queen);
Queen = Queen(~cellfun(@isnan,{Queen.x})); % remove empty rows
Queen = struct2table(Queen);
Queen = TransformPointInTable(Queen,A,box);

Brood = readtable(['Z:\Roi\NestConstructionExp\NestConstructionExp\BroodLocationData\',tag,'_Brood.csv']);
Brood.Properties.VariableNames = {'datetime','x','y'};
Brood = table2struct(Brood);
Brood = Brood(~cellfun(@isnan,{Brood.x})); % remove empty rows
Brood = struct2table(Brood);
Brood = TransformPointInTable(Brood,A,box);

%% save workspace
save(['D:\Ants\2Dnests\MatlabWorkspaces\ArchAnalysisWS\',tag,'.mat'])