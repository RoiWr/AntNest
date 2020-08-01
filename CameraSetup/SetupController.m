function varargout = SetupController(varargin)

% SETUPCONTROLLER MATLAB code for SetupController.fig
%      SETUPCONTROLLER, by itself, creates a new SETUPCONTROLLER or raises the existing
%      singleton*.
%
%      H = SETUPCONTROLLER returns the handle to a new SETUPCONTROLLER or the handle to
%      the existing singleton*.
%
%      SETUPCONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETUPCONTROLLER.M with the given input arguments.
%
%      SETUPCONTROLLER('Property','Value',...) creates a new SETUPCONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetupController_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetupController_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetupController

% Last Modified by GUIDE v2.5 20-Aug-2018 13:11:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SetupController_OpeningFcn, ...
                   'gui_OutputFcn',  @SetupController_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SetupController is made visible.
function SetupController_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetupController (see VARARGIN)

% Choose default command line output for SetupController
handles.output = hObject;

movegui(gcf,'northwest')

% load camera parameters data to popup menus
    % camera parameters for Canon EOS 550D
    handles.iso = {100,200,400,800,1600,3200,6400};
    handles.aperture = {4.0,4.5,5.0,5.6,6.3,7.1,8.0,9.0,10,11,13,14,16,18,20,22,25,29};
    handles.shutter = {'30','25','20','15','13','10','8','6','5','4','3.2','2.5','2','1.6','1.3','1','0.8','0.6','0.5','0.4','0.3','1/4','1/5','1/6','1/8','1/10','1/13','1/15','1/20','1/25','1/30','1/40','1/50','1/60','1/80','1/100','1/125','1/160','1/200','1/250','1/320','1/400','1/500','1/640','1/800','1/1000','1/1250','1/1600','1/2000','1/2500','1/3200','1/4000'};
    % load to popupmenus
    handles.iso_uc_popup.String = handles.iso;
    handles.aperture_uc_popup.String = handles.aperture;
    handles.shutter_uc_popup.String = handles.shutter;

    % save to handles the preset parameters
        % Detect
        handles.uc.Detect(1) = 1; % iso = 100
        handles.uc.Detect(2) = 1; % aperture = 4.0
        handles.uc.Detect(3) = 39; % shutter speed = 1/200
        % Arch
        handles.uc.Arch(1) = 3; % 400
        handles.uc.Arch(2) = 1; % 4.0
        handles.uc.Arch(3) = 36; % 1/100

    % display preset selection for Detect on opening
        handles.iso_uc_popup.Value = handles.uc.Detect(1);
        handles.aperture_uc_popup.Value = handles.uc.Detect(2);
        handles.shutter_uc_popup.Value = handles.uc.Detect(3);
    
global C a
if char(class(C))~="CameraController"
    C = CameraController;
end
%check arduino connection, and manually connection to pin 'D4'
if char(class(a))~="arduino"
    a=arduino()
end

configurePin(a,'D4','DigitalInput')

% load complete photo sound
[handles.sound.y,handles.sound.Fs]=audioread('D:\NestConstructionExp\Scripts\sound.mp3');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SetupController wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SetupController_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ArmTrigger.
function ArmTrigger_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of ArmTrigger
global a C

    if hObject.Value == 1  % if button pressed => trigger is armed
        % Connection to right camera ('upperCam')
        C.Cameras(2); 
        if C.property.devicename == 'lowerCam' % check based on lowerCam, as constantly connected and defined
            C.Cameras(1) % use other camera
%        else use this camera
        end
        C.property.devicename % connect to right camara and print out camera name
        %save camera parameters
        % no. of Detect Photos
            if handles.detect_rbg1.SelectedObject.String == ' '
                n = str2num(handles.NoOfDetect_uc.String);
            else
                n = str2num(handles.detect_rbg1.SelectedObject.String);
            end
        Detect = {handles.iso{handles.uc.Detect(1)},handles.aperture{handles.uc.Detect(2)},handles.shutter{handles.uc.Detect(3)}};
        Arch = {handles.iso{handles.uc.Arch(1)},handles.aperture{handles.uc.Arch(2)},handles.shutter{handles.uc.Arch(3)}};
    end
        %% triggerred loop: when triggered by real pushbutton connected to pin 'D4', runs PhotoProgram.m
        % terminates at end of run (adjusted for use with BroodLocator)
        while hObject.Value == 1
            buttonState = readDigitalPin(a,'D4');
            if buttonState == 1
                disp([char(datetime),': Button Pressed'])
                
                try
                    Detect_filename = PhotoProgram(C,n,Detect,Arch); % run PhotoProgram
                    sound(handles.sound.y,handles.sound.Fs) % play completion sound
                    %pause(1)
                    BroodLocator(Detect_filename,n) % send Detect-1 photo to BroodLocator
                catch
                end

                buttonState = readDigitalPin(a,'D4');
               while buttonState == 1
                   buttonState = readDigitalPin(a,'D4');
               end
               hObject.Value = 0; % depress button and exit loop
            end
        end
        

% --- Executes on button press in Capture_uc.
function Capture_uc_Callback(hObject, eventdata, handles)
% create cell arrays for Detect and Arch
global a C
        C.Cameras(2); 
        if C.property.devicename == 'lowerCam' % check based on lowerCam, as constantly connected and defined
            C.Cameras(1) % use other camera
        % else use this camera
        end
        C.property.devicename % connect to right camara and print out camera name
        %save camera parameters
                % no. of Detect Photos
            if handles.detect_rbg1.SelectedObject.String == ' '
                n = str2num(handles.NoOfDetect_uc.String);
            else
                n = str2num(handles.detect_rbg1.SelectedObject.String);
            end
        Detect = {handles.iso{handles.uc.Detect(1)},handles.aperture{handles.uc.Detect(2)},handles.shutter{handles.uc.Detect(3)}};
        Arch = {handles.iso{handles.uc.Arch(1)},handles.aperture{handles.uc.Arch(2)},handles.shutter{handles.uc.Arch(3)}};
    %try
            Detect_filename = PhotoProgram(C,n,Detect,Arch); % run PhotoProgram
            sound(handles.sound.y,handles.sound.Fs) % play completion sound
            %pause(1)
            BroodLocator(Detect_filename,n) % send Detect-1 photo to BroodLocator
    %catch
    %end

function NoOfDetect_uc_Callback(hObject, eventdata, handles)
% hObject    handle to NoOfDetect_uc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoOfDetect_uc as text
%        str2double(get(hObject,'String')) returns contents of NoOfDetect_uc as a double


% --- Executes during object creation, after setting all properties.
function NoOfDetect_uc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoOfDetect_uc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in iso_uc_popup.
function iso_uc_popup_Callback(hObject, eventdata, handles)
% hObject    handle to iso_uc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
select = handles.uc_bg1.SelectedObject.String;
    switch select % iso is 1st cell in parameters array
        case 'Detect'
        handles.uc.Detect(1) = hObject.Value;     
        case 'Arch'
        handles.uc.Arch(1) = hObject.Value;  
    end
guidata(hObject, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns iso_uc_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from iso_uc_popup


% --- Executes during object creation, after setting all properties.
function iso_uc_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iso_uc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in aperture_uc_popup.
function aperture_uc_popup_Callback(hObject, eventdata, handles)
% hObject    handle to aperture_uc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
select = handles.uc_bg1.SelectedObject.String;
    switch select % aperture is 2nd cell in parameters array
        case 'Detect'
        handles.uc.Detect(2) = hObject.Value;     
        case 'Arch'
        handles.uc.Arch(2) = hObject.Value;  
    end
guidata(hObject, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns aperture_uc_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from aperture_uc_popup


% --- Executes during object creation, after setting all properties.
function aperture_uc_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aperture_uc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in shutter_uc_popup.
function shutter_uc_popup_Callback(hObject, eventdata, handles)
% hObject    handle to shutter_uc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
select = handles.uc_bg1.SelectedObject.String;
    switch select % shutter speed is 3rd cell in parameters array
        case 'Detect'
        handles.uc.Detect(3) = hObject.Value;     
        case 'Arch'
        handles.uc.Arch(3) = hObject.Value;  
    end
guidata(hObject, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns shutter_uc_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from shutter_uc_popup


% --- Executes during object creation, after setting all properties.
function shutter_uc_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shutter_uc_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Detect_uc_rb.
function Detect_uc_rb_Callback(hObject, eventdata, handles)
% hObject    handle to Detect_uc_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Detect_uc_rb


% --- Executes on button press in Arch_uc_rb.
function Arch_uc_rb_Callback(hObject, eventdata, handles)
% hObject    handle to Arch_uc_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Arch_uc_rb


% --- Executes when selected object is changed in parameters_uc.
function parameters_uc_SelectionChangedFcn(hObject, eventdata, handles)



% --- Executes on button press in BroodLocator_pb.
function BroodLocator_pb_Callback(hObject, eventdata, handles)
% hObject    handle to BroodLocator_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BroodLocator


% --- Executes when selected object is changed in uc_bg1.
function uc_bg1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uc_bg1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch hObject.String
    
        case 'Detect'
        handles.iso_uc_popup.Value = handles.uc.Detect(1);
        handles.aperture_uc_popup.Value = handles.uc.Detect(2);
        handles.shutter_uc_popup.Value = handles.uc.Detect(3);
        
        case 'Arch'
        handles.iso_uc_popup.Value = handles.uc.Arch(1);
        handles.aperture_uc_popup.Value = handles.uc.Arch(2);
        handles.shutter_uc_popup.Value = handles.uc.Arch(3);
       
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in one_rb.
function one_rb_Callback(hObject, eventdata, handles)
% hObject    handle to one_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of one_rb


% --- Executes on button press in three_rb.
function three_rb_Callback(hObject, eventdata, handles)
% hObject    handle to three_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of three_rb


% --- Executes on button press in other_rb.
function other_rb_Callback(hObject, eventdata, handles)
% hObject    handle to other_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of other_rb


% --- Executes when selected object is changed in detect_rbg1.
function detect_rbg1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in detect_rbg1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if hObject.String == ' ' % enable editable text box only if radio button is selected
    handles.NoOfDetect_uc.Enable = 'On';
else
    handles.NoOfDetect_uc.Enable = 'Off';
end
uicontrol(handles.NoOfDetect_uc) % to focus on editable text box
