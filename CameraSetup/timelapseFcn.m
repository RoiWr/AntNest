function timelapseFcn(obj,event,a,Top,Bot,C,DayNight_times)
%callback function of timelapse shooting for timer. controls backlight
%flash thru arduino and camera.
% Program outline: 1) turn on both parts of backlight, 2) n photos for ant
% detection, regular exposure, 3) 1 photo with high exposure for
% architecture
%% Connection to right camera ('lowerCam')
C.Cameras(1); 
if C.property.devicename == 'lowerCam'
    % use this camera
else
    C.Cameras(2) % use other camera
end

C.property.devicename % connect ro right camara and print out camera name

%% Turn on light
event_time = datestr(event.Data.time);

writeDigitalPin(a,Top,1);    % turn ON top part of backlight
disp([event_time,': START: backlight top ON'])
writeDigitalPin(a,Bot,1);    % turn ON bottom part of backlight
disp([event_time,': START: backlight bottom ON'])

pause(0.5)% pause no. of sec takes for both parts of backlight to turn on

% %% setup camera parameters for n ant detection shots ('Detect')
% C.camera.isonumber          = 100;
% C.camera.fnumber            = 5.6;
% C.camera.shutterspeed       = 1/80;
% n= 1; % no. of shots
% for i=1:n
%     C.Capture(['[Session Name]_[Date yyyy-MM-dd]_[Time hh-mm]','_Detect-',num2str(i)])
%     disp([char(datetime),' - ',C.property.devicename,': Capture Detect-',num2str(i)])
%     pause(4)
% end
% %% setup camera parameters for architecture shot ('Arch')
% C.camera.isonumber          = 200;
% C.camera.fnumber            = 4;
% C.camera.shutterspeed       = '1/30';
% 
% C.Capture(['[Session Name]_[Date yyyy-MM-dd]_[Time hh-mm]','_Arch'])
% disp([char(datetime),' - ',C.property.devicename,': Capture Arch'])
%% Use PhotoProgram.m function
        Detect = {200,5.0,'1/200'};
        Arch = {800,5.0,'1/125'};
        PhotoProgram(C,3,Detect,Arch)

%% turn OFF backlight
writeDigitalPin(a,Bot,0);    % turn OFF bottom part of backlight
disp([char(datetime),': END: backlight bottom OFF'])
%% turn ON/OFF top part of backlight depending on time of day
time = clock;    
H = time(4); % time now in hour
    if H>=DayNight_times(1) && H<DayNight_times(2)
        writeDigitalPin(a,Top,1); % turn light ON
        disp([char(datetime),': END: backlight top ON'])
    else
         writeDigitalPin(a,Top,0); % turn light OFF
         disp([char(datetime),': END: backlight top OFF'])
    end
end  
    