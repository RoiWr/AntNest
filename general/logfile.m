function logfile(text,tag,topic)
% function that writes to a tag and topic specific log file text with a timestamp about processing
% topic can be {'BW','skeleton','Detect','DataExtract'}
mkdir(['D:\Ants\2Dnests\logfiles\',topic])
filename = ['D:\Ants\2Dnests\logfiles\',topic,'\',tag,'_',topic,'_log.txt'];
disp([datestr(now),': ',text])
fid = fopen(filename,'a+'); 
fprintf(fid, '%s: %s\n', datestr(now), text);
fclose(fid);
end