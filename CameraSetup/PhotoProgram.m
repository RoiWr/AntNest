function Detect_filename = PhotoProgram(C,n,Detect,Arch)
% Photography function for triggered (not timer automated) ant nest measurement.
% C is digicamcontrol settings and n = no. of shots for ant detection
% Detect and Arch is a 3 element cell array of {iso,aperture,shutter speed}
% for Detect and Arch(itecture) shots respectively.
switch nargin % default setting for n, Detect, and Arch, depending on number of input arguments
    case 4
        % do none
    case 0
        error('Missing C input argument')
    case 1
        n=3;
        Detect = {100,5.6,'1/100'};
        Arch = {400,4.0,'1/100'};
    case 2
        Detect = {100,5.6,'1/100'};
        Arch = {400,4.0,'1/100'};
    case 3
        Arch = {400,4.0,'1/100'};
end
    

%% setup camera parameters for n ant detection shots ('Detect')
C.camera.isonumber          = Detect{1};
C.camera.fnumber            = Detect{2};
C.camera.shutterspeed       = Detect{3};
% n = no. of shots
for i=1:n
    C.Capture(['[Date yyyy-MM-dd]_[Time hh-mm]','_Detect-',num2str(i)])
    disp([char(datetime),' - ',C.property.devicename,': Capture Detect-',num2str(i)])
    pause(2)
    
    if i==1 % for detect-1 image get filename for BroodLocator
        Detect_filename = strcat(C.session.folder,'\',C.lastfile);
    end
    
end
%% setup camera parameters for architecture shot ('Arch')
C.camera.isonumber          = Arch{1};
C.camera.fnumber            = Arch{2};
C.camera.shutterspeed       = Arch{3};

C.Capture(['[Date yyyy-MM-dd]_[Time hh-mm]','_Arch'])
disp([char(datetime),' - ',C.property.devicename,': Capture Arch'])

end