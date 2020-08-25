function plotOther(idxA,Other,RGB)
% plot 'Other' data comments function using the idxA = the index in
% structure A and 'Other' data in the form of a table
hold on
idxO = find(Other.idx==idxA);
if isempty(idxO)
    return
end

for j=1:length(idxO)
    x = Other.x(idxO(j));
    y = Other.y(idxO(j));
    if x>size(RGB,2) || x<0 || y>size(RGB,1) || y<0 % if point is out of bounds, show at middle
        x = size(RGB,2)/2;
        y = size(RGB,1)/2+(j-1)*150;
    else
        plot(x,y,'oc')
    end
    line = char(Other.Comment(idxO(j)));
    text(x,y,line,'Color','c','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
end
end