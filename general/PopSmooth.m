function Pop_smooth = PopSmooth(Pop,n)
% function that smooths the population data (in vector Pop) using moving median with window
% size n. replacing endpoints and NaNs with the real values if exist, and if not
% with median values calculated using smaller window size.

Pop_fill = movmedian(Pop,n,'EndPoints','fill');
Pop_shrink = movmedian(Pop,n,'omitnan','EndPoints','shrink');

Pop_smooth = Pop_fill;
nans1 = find(isnan(Pop_fill));
Pop_smooth(nans1) = Pop(nans1);
nans2 = find(isnan(Pop_smooth));
Pop_smooth(nans2) = Pop_shrink(nans2);

end

