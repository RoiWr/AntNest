function L = BranchingSkel2Graph(SKEL)
% find longest path in network and find its included nodes (pixels)
% need to run this for each diff blub and its resulting graph

L = double(false(size(SKEL)));
skel = SKEL;
DIST = zeros(1,3); % distance matrix of branches col 1 and col 2 are the endpoints of its branch and col 3 is the weighted geodesic distance
i=0;

lbp = length(find(bwmorph(skel,'branchpoints')));
if lbp==0
    L = double(SKEL);
    return
end

while lbp>0
    i=i+1;
    
    G = binaryImageGraph(skel);
    kep = find(bwmorph(skel,'endpoints'));
    if isempty(kep)
        break
    end
    
    [~,~,ep_nodes] = intersect(kep,G.Nodes{:,3});
    D = distances(G,ep_nodes,ep_nodes);
    D(D==Inf)=NaN;
    [~,indx1]=max(D(:));
    [r,c]=ind2sub(size(D),indx1);
    
    [TR,DIST(i,3)] = shortestpathtree(G,ep_nodes(r),ep_nodes(c),'OutputForm','vector');
    DIST(i,1:2)=[G.Nodes{ep_nodes(r),3},G.Nodes{ep_nodes(c),3}];
    PxIdxList = G.Nodes{~isnan(TR),3};
    L(PxIdxList)=i; % label a new skel image

    skel(PxIdxList)=0; % remove pixels from iterative analysis image skel

    lbp = length(find(bwmorph(skel,'branchpoints')));
    
   % imshow(label2rgb(L,'jet','k','shuffle'))
end
 % set up label matrix
    CC = bwconncomp(skel);
    Lt = labelmatrix(CC);
    Lt = double(Lt) + i.*double(Lt>0);
    L = L + Lt;

%  % complete DIST vector
% for j=1+1:max(max(L))
%     GL = binaryImageGraph(L==j);
%     DIST(j,1:2)=[G.Nodes{1,3},G.Nodes{2,3}];
%     DIST(j,3)=max(max(distances(GL)));
% end
 
% figure('Name','Longest Paths')
% imshow(label2rgb(L,'jet','k','shuffle'))
% title('Skeleton divided to remaining longest (shortest) paths using graph theory')

end

