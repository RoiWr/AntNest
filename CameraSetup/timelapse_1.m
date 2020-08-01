% Ant nest Photography & arduino backlight control
    % make sure (1) CameraController.m add-on is installed for control of
    % digicamcontrol and (2) arduino hardware support package installed
% check arduino connection (for variable 'a')
global a C
if char(class(a))~="arduino"
    a=arduino()
end

% set  pin number to top and bottom parts of backlight
Top = 'D13';
Bot = 'D12';

writeDigitalPin(a,Bot,0);    % turn OFF bottom part of backlight
disp([datestr(clock),': backlight bottom OFF'])
%% top part of backlight: 12 on/off hr cycle
% connect TOP part of backlight to 'D13', B in relay box
% setup
[Y,M,D,hr,min,~]=datevec(datetime); % gets today's in vector form

Day_start_time = 8; % select hour in which to turn ON light
Night_start_time = 20; % select hour in which to turn OFF light
DayNight_times=[Day_start_time,Night_start_time];
time = clock;    
H = time(4); % time now in hour
    if H>=Day_start_time && H<Night_start_time
        writeDigitalPin(a,Top,1); % turn light ON
        ON=1;
        disp([datestr(clock),': Day time: turn light ON'])
    else
         writeDigitalPin(a,Top,0); % turn light OFF
         ON=0;
         disp([datestr(clock),': Night time: turn light OFF'])
    end
    
%% timer for ON
tON = timer;
tON.TimerFcn = {@DayNight,a,Top,1};
tON.ExecutionMode = 'fixedRate';
tON.Period  = 24*3600; % 24 hrs

%% timer for OFF
tOFF = timer;
tOFF.TimerFcn = {@DayNight,a,Top,0};
tOFF.ExecutionMode = 'fixedRate';
tOFF.Period = 24*3600; % 24 hrs
%% scheduled start
daynight_timers= [tON,tOFF];
for i=1:2
    if H>=DayNight_times(i)
        startat(daynight_timers(i),Y,M,D+1,DayNight_times(i),0,0)
    else
        startat(daynight_timers(i),Y,M,D,DayNight_times(i),0,0)
    end
end
%% time-lapse photography
C = CameraController;
C.Cameras(1), C.property.devicename = 'lowerCam'; %set camera name

timelapse = timer;
timelapse.StartFcn = {@timelapseFcn,a,Top,Bot,C,DayNight_times};
timelapse.TimerFcn = {@timelapseFcn,a,Top,Bot,C,DayNight_times};
timelapse.ExecutionMode = 'fixedRate';
timelapse.Period = 3*60*60; % 3 hrs 

%% start timelapse
disp([datestr(clock),': timelapse START'])
[Y,M,D,hr,min,~]=datevec(datetime); % gets current time in vector form

% for timelapse interval of 30 min
%     if min<30
%         startat(timelapse,Y,M,D,hr,30,0)
%     elseif hr>=23
%         startat(timelapse,Y,M,D+1,0,0,0)
%     else
%         startat(timelapse,Y,M,D,hr+1,0,0)
%     end

    if hr>=23
        startat(timelapse,Y,M,D+1,0,0,0)
    else
        startat(timelapse,Y,M,D,hr+1,0,0)
    end

%% stop timelapse
stop(timelapse)
disp([datestr(clock),': timelapse STOP'])
%% stop DayNight timers
stop(daynight_timers)
disp([datestr(clock),': DayNight timers STOP'])
