function idx = matchDates(Adatenum,Table)
% dates matching function between annotation data (BroodLocationData) and Arch images
% Adatenum = [A.datenum] of A structure created by ArchAnalysis.m
% matching the timestamps: the timestamp in the data is based on the 1st
% Detect image, hence the Arch photo and its datenum is the 1st pic after
dist = pdist2(Adatenum,Table{:,1});
dist(dist>1/12 | dist<0)=NaN;
[minima,idx] = min(dist);
idx(isnan(minima))=NaN;
idx = idx';
end