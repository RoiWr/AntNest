CritD = table;
Lags = table;
for k=UseNests
    tend = find(~isnan(S(k).B.fArea),1,'last');
    t1 = t(t0:tend);
    fA = S(k).B.fArea(t0:tend);
    N = S(k).B.SmoothPop(t0:tend);
    density = N./fA;
    densityS = movmean(density,3); % smooth
    [H_pks,H_locs] = findpeaks(densityS);
    [L_pks,L_locs] = findpeaks(-densityS);
    T = table;
    T.tag = repmat(k,numel([H_locs;L_locs]),1);
    T.locs = [H_locs;L_locs];
    T.time = 3.*T.locs;
    T.density = density(T.locs);
    T.type = [ones(numel(H_locs),1);2.*ones(numel(L_locs),1)];
    % find lag between consecutive high -> low densities
    LagsNest = table;
    [timeline,I] = sort([H_locs;L_locs]);
    PKS = [H_pks;L_pks];
    PKS = PKS(I);
    TIMEdiff=[];
    RT = [];
    j=0;
    for i=2:numel(timeline)
        if i>1 && PKS(i)<0 && PKS(i-1)>0
            j=j+1;
            TIMEdiff(j)= 3.*(timeline(i)-timeline(i-1));
             % calc response time = time it takes to reach half of critical density low
            densityRT = densityS(timeline(i-1):timeline(i));
            densityRT = densityRT-repmat(densityRT(end),numel(densityRT),1);
            tRT = t1(timeline(i-1):timeline(i));
            RT(j) = tRT(find(densityRT<=0.5.*densityRT(1),1))-tRT(1);
        end
    end
    
    if isempty(TIMEdiff)
        continue
    end
    LagsNest.tag = repmat(k,j,1);
    LagsNest.lag = TIMEdiff';
    LagsNest.RT = RT';
% save  
    Lags = [Lags; LagsNest];
    CritD = [CritD; T];
end