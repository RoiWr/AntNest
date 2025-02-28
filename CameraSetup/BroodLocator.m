function varargout = BroodLocator(varargin)
% BROODLOCATOR MATLAB code for BroodLocator.fig
%      BROODLOCATOR, by itself, creates a new BROODLOCATOR or raises the existing
%      singleton*.
%
%      H = BROODLOCATOR returns the handle to a new BROODLOCATOR or the handle to
%      the existing singleton*.
%
%      BROODLOCATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BROODLOCATOR.M with the given input arguments.
%
%      BROODLOCATOR('Property','Value',...) creates a new BROODLOCATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BroodLocator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BroodLocator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BroodLocator

% Last Modified by GUIDE v2.5 30-Jun-2018 18:21:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BroodLocator_OpeningFcn, ...
                   'gui_OutputFcn',  @BroodLocator_OutputFcn, ...
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

% --- Executes just before BroodLocator is made visible.
function BroodLocator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BroodLocator (see VARARGIN)

% Choose default command line output for BroodLocator
handles.output = hObject;

% default location on screen
movegui(gcf,'east')

% setup and initialize of variables
handles.Brood.c = 1; % counter for brood 
handles.Workers.c = 1; % counter for workers
handles.Other.c = 1; % counter for other 
% DATA
handles.Data.Queen=zeros(0,2); 
handles.Data.Brood=zeros(0,2);
handles.Data.Workers=zeros(0,2);
handles.Data.Other=num2cell(zeros(0,3));
% PLOTS
handles.PlotQueen=[];
handles.PlotBrood=[];
handles.PlotWorkers=[];
handles.PlotOther=[];
% text
handles.TextQueen='';
handles.TextBrood='';
handles.TextWorkers='';
handles.TextOther='';

% find and read data files of previous BroodLocators
    % setup default data directory
    handles.Data.path = 'F:\digging_experiment_trial2\day_1\daily_temp2';
    addpath(handles.Data.path)
    addpath('F:\digging_experiment_trial2\Scripts') % add Scripts folder to path
    %cd(handles.Data.path)
    handles.Data.files = dir(handles.Data.path);
    
% open image directly if uses file path input as varargin
    if isempty(varargin) == 0 % meaning not empty
        handles.path = varargin{1};
        handles.NoOfDetect = varargin{2};
        handles = openImage(handles);
    end
    
% Maintenance popup-menu list
handles.maint_popupmenu.String = {'t0','t1','NEW PROTEIN FOOD','REMOVE PROTEIN FOOD',...
    'AFTER VACCUM AND WETTING','NEW WATER AND SUGAR','NEW WATER','NEW SUGAR','AFTER VACCUM SAND',...
    'AFTER WETTING', 'REMOVE SUGAR','REMOVE WATER','LOWER WATER COLUMN','NEW FLUON'};
handles.maint_listbox.String={};
    
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = BroodLocator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox

% --- Executes during object creation, after setting all properties.
function NestIDinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NestIDinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Other_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Other_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Locate.
function Locate_Callback(hObject, eventdata, handles)
% hObject    handle to Locate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(handles.f)
% openImage(handles)
[x,y]=ginput(1);
select = handles.radiobuttongroup.SelectedObject.String;
list = handles.listbox.String;
hold on
switch select
          
    case 'Queen'
        handles.PlotQueen = plot(x,y,'og');
        line = select(1);
        handles.TextQueen = text(x,y,line,'Color','green','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
    
        handles.Queen_rb.Enable = 'off'; % disable queen button after locating
        handles.Queen_rb.Value = 0; % unchecks queen button
        handles.Brood_rb.Value = 1; % checks brood button
        
        % save coordinates
        handles.Data.Queen = [x,y];
        
    case 'Brood'
        k = handles.Brood.c; % Brood counter
        handles.PlotBrood{k}=plot(x,y,'or');
        line = strcat(select(1),'-',num2str(k));
        handles.TextBrood{k}=text(x,y,line,'Color','red','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
        % save coordinates
        handles.Data.Brood(k,:) = [x,y];
       
        %step-up brood counter no.
        handles.Brood.c = k+1; 
        
%         handles.Brood_rb.Value = 0; % unchecks brood button
%         handles.Workers_rb.Value = 1; % checks Workers button
        
   case 'Workers'
        k = handles.Workers.c; % Worker counter
        handles.PlotWorkers{k}=plot(x,y,'om');
        line = strcat(select(1),'-',num2str(k));
        handles.TextWorkers{k}=text(x,y,line,'Color','magenta','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
        % save coordinates
        handles.Data.Workers(k,:) = [x,y];
       
        %step-up brood counter no.
        handles.Workers.c = k+1; 
        
        % update 'PopSizeEdit' (Population size textbox) based on the
        % number workers located
        handles.PopSizeEdit.String = k;
        
    case ' '
        k = handles.Other.c; % Brood counter
        handles.PlotOther{k}=plot(x,y,'oc');
        line = strcat(handles.Other_text.String);
        handles.TextOther{k}=text(x,y,line,'Color','cyan','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
        % save coordinates
        handles.Data.Other(k,:) = {x,y,handles.Other_text.String};
        
         %step-up other counter no.
        handles.Other.c = k+1; 
end

% add new line to listbox's list
handles.listbox.String = vertcat(list,{line});

guidata(hObject,handles) % save changes to data

function NestIDinput_Callback(hObject, eventdata, handles)
% hObject    handle to NestIDinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NestID = hObject.String;
uicontrol(handles.Locate) % focus to Locate
guidata(hObject,handles) % save changes to data

% Hints: get(hObject,'String') returns contents of NestIDinput as text
%        str2double(get(hObject,'String')) returns contents of NestIDinput as a double


% --- Executes when BroodLocatorGUI is resized.
function BroodLocatorGUI_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to BroodLocatorGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in Save_pb.
function Save_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Save_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% a = 'F:\digging_experiment_trial2\day_1\daily_temp2';
% b = tag;
% c = strcat(a,b);
% cd c
%cd 'F:\digging_experiment_trial2\day_1\daily_temp2'
nestID = handles.NestIDinput.String;
var = {'Queen','Brood','Workers','Other','Maintenance','Population'};
for i=1:length(var)
    filename = char(strcat(nestID,'_',var(i),'.csv'));
    % check if data file exists
    e = exist(filename,'file');
    if e~=2 % if not, create file
        
        cHeader = {'datetime' 'x' 'y' 'Comment'}; % header
        textHeader = strjoin(cHeader, ','); % comma header

        %write header to file
        fid = fopen(filename,'w'); 
        fprintf(fid,'%s\n',textHeader);
        fclose(fid);
        
        msgbox(['No data file exists. creating: ',filename])
    end
    
    switch i
        case 1 %'Queen'
            new_data = [handles.datenum,handles.Data.Queen];
            % write data to file
            dlmwrite(filename,new_data,'-append','precision','%.9f');
        case 2 %'Brood'
            new_data = [repmat(handles.datenum,[size(handles.Data.Brood,1),1]),handles.Data.Brood];
            % write data to file
            dlmwrite(filename,new_data,'-append','precision','%.9f');
        case 3 %'Workers'
            new_data = [repmat(handles.datenum,[size(handles.Data.Workers,1),1]),handles.Data.Workers];
            % write data to file
            dlmwrite(filename,new_data,'-append','precision','%.9f');
        case 4 %'Other'
            % write data to file. This data contains strings so use cell
            % array and fprintf to write data, has to be row by row in
            % order to write cell using fprintf
              fid = fopen(filename,'a');
              for k=1:size(handles.Data.Other,1)
                  new_data = {handles.datenum,handles.Data.Other{k,:}};
                  fprintf(fid,'%.9f,%f,%f,%s\n',new_data{1,:});
              end
              fclose(fid);
        case 5 %'Maintenance'
            % write data to file. This data contains strings so use cell
            % array and fprintf to write data, has to be row by row in
            % order to write cell using fprintf
              fid = fopen(filename,'a');
              for k=1:size(handles.maint_listbox.String,1)
                  new_data = {handles.datenum,handles.maint_listbox.String{k}};
                  fprintf(fid,'%.9f,%s\n',new_data{1,:});
              end
              fclose(fid);
        case 6 % 'Population'
            new_data = [handles.datenum,str2double(handles.PopSizeEdit.String)];
            % write data to file
            dlmwrite(filename,new_data,'-append','precision','%.9f');
    end
end
     
% Save images in new folder under nest name

files = dir('F:\digging_experiment_trial2\day_1\daily_temp2\*.jpg');
% sort files to only have files which are newer than Detect-1
    d1 = dir(handles.path); % find datenum of detect-1
    idx = find([files.datenum]>=d1(1).datenum);
    
Destination = strcat('F:\digging_experiment_trial2\day_1\daily_temp2',nestID);
if exist(Destination,'dir') == 0
    mkdir(Destination)
end

for i=1:length(idx)
    [status,msg]=copyfile(strcat(files(idx(i)).folder,'\',files(idx(i)).name),strcat(Destination,'\',nestID,'_',files(idx(i)).name));
        if status == 0
            msgbox({'Problem copying file',files(idx(i)).name,msg},'Error','error');
        end
end

function Other_text_Callback(hObject, eventdata, handles)
% hObject    handle to Other_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Other_text as text
%        str2double(get(hObject,'String')) returns contents of Other_text as a double

function Other_rb_Callback(hObject, eventdata, handles)
% hObject    handle to Other_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in radiobuttongroup.
function radiobuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in radiobuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if hObject.String == ' ' % enable editable text box only if radio button is selected
    handles.Other_text.Enable = 'On';
else
    handles.Other_text.Enable = 'Off';
end
uicontrol(handles.Other_text) % to focus on editable text box


% --- Executes on button press in remove_pb.
function remove_pb_Callback(hObject, eventdata, handles)
% hObject    handle to remove_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select = handles.listbox.String(handles.listbox.Value); % Obtain selected value from listbox

S=strsplit(Select{1},'-'); % split the string to remove index number. S(1) string and S(2) index number
name=S{1};
    if length(S)>1 % condition to use index number for cases 'Brood' and 'Workers'
        j=str2double(S{2}); 
    end
    
% remove plot, text and data of Select
    switch name
        case 'Q' % Queen
            delete(handles.PlotQueen)
            delete(handles.TextQueen)
            handles.Data.Queen=zeros(0,2);
            handles.Queen_rb.Enable = 'On'; % enables queen radio button
            handles.Queen_rb.Value = 1; % checks the queen radio button
        
        case 'B' % Brood
            delete(handles.PlotBrood{j}) 
            delete(handles.TextBrood{j})
            handles.Data.Brood(j,:)=zeros(1,2);
            handles.Brood_rb.Value = 1; % checks the brood radio button 
            
        case 'W' % Worker
            delete(handles.PlotWorkers{j}) 
            delete(handles.TextWorkers{j})
            handles.Data.Workers(j,:)=zeros(1,2);
            handles.Workers_rb.Value = 1; % checks the Workers radio button
            
        otherwise
            delete(handles.PlotOther{j})
            delete(handles.TextOther{j})
            for m = 1:3 % remove data from each element of data cell array col by col (m) in row k
                handles.Data.Other{j,m}=[];
            end
            
            handles.Other_rb.Value = 1; % checks the Other radio button 
    end
    
    % remove select from listbox
    handles.listbox.String(handles.listbox.Value)=[];
    
    handles.listbox.Value=1; % force value of selection to be =1
    

guidata(hObject,handles) % save changes to data


% --- Executes on button press in data_dir_pb.
function data_dir_pb_Callback(hObject, eventdata, handles)
% hObject    handle to data_dir_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
           
    % find and read data files of previous BroodLocators
    % setup custom data directory
    handles.Data.path = uigetdir;
    addpath(handles.Data.path)
    cd(handles.Data.path)
    handles.Data.files = dir(handles.Data.path);
guidata(hObject,handles) % save changes to data


% --- Executes on button press in SaveReset_pb.
function SaveReset_pb_Callback(hObject, eventdata, handles)
% hObject    handle to SaveReset_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Save_pb_Callback(@Save_pb_Callback, eventdata, handles) % saves
Reset_pb_Callback(@Reset_pb_Callback, eventdata, handles) % Resets

% --- Executes on button press in Select_pb.
function Select_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Select_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [FileName,PathName,~] = uigetfile('F:\digging_experiment_trial2\day_1\daily_temp2\*.jpg','Select Image');
    handles.path = strcat(PathName,FileName);
    handles = openImage(handles);
guidata(hObject,handles) % save changes to data


% --- Executes on button press in Reset_pb.
function Reset_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('Image')
close BroodLocator
BroodLocator


% --- Executes on button press in maint_pb.
function maint_pb_Callback(hObject, eventdata, handles)
% hObject    handle to maint_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list = handles.maint_listbox.String;
line = handles.maint_popupmenu.String{handles.maint_popupmenu.Value};
handles.maint_listbox.String = vertcat(list,{line}); % show on listbox

guidata(hObject,handles) % save changes to data


% --- Executes on selection change in maint_popupmenu.
function maint_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to maint_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns maint_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from maint_popupmenu


% --- Executes during object creation, after setting all properties.
function maint_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maint_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in maint_listbox.
function maint_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to maint_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns maint_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from maint_listbox


% --- Executes during object creation, after setting all properties.
function maint_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maint_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PopSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PopSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PopSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of PopSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function PopSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = openImage(handles)
        handles.files=dir(handles.path);
        % date extraction  and display
        handles.date = handles.files.date;
        handles.datenum = handles.files.datenum;
        set(handles.DateTitle,'String',handles.date);

        handles.RGB = imread(handles.path); % image read
        % rotate image if width > height
        if size(handles.RGB,1) < size(handles.RGB,2)
            handles.RGB = imrotate(handles.RGB,-90);
        end
        
        % image display
        handles.f=figure('Name','Image');
        imshow(handles.RGB)
        
        handles.NestID = OCR_nest_tag(handles.RGB,200);
        handles.NestIDinput.String = handles.NestID;
        
        % OCR
%         try
%             handles.NestID = OCR_nest_tag(handles.RGB,80);
%             handles.NestIDinput.String = handles.NestID;
%         catch
%             warning('no tag detected. Manually insert tag Nest ID')
%             % use waitfor function to force NestIDinput
%             msgbox('Insert nest ID manually')
%             uicontrol(handles.NestIDinput)
%             waitfor(handles.NestIDinput,'String')
%             handles.NestID = handles.NestIDinput.String; 
%             disp('tag inserted manually')
%         end
%         disp(['Nest ID is ',handles.NestID])
        
%         if exist('tag','var')~=1
%             % use waitfor function to force NestIDinput 
%             uicontrol(handles.NestIDinput)
%             waitfor(handles.NestIDinput,'String')
%             disp('tag inserted manually')
%             tag =  handles.NestIDinput.String;
%         end
%         
        % Find Last Population number
        try
            FindLastPopNo(handles)
        catch
            warning('Could not find Population file for this nest')
        end
            


function FindLastPopNo(handles)
    tag = handles.NestID;
    
   % 'D:\NestConstructionExp\BroodLocationData\',tag,'_Population.csv'));
   % Initialize variables.
    filename = ['F:\digging_experiment_trial2\day_1\daily_temp2',tag,'_Population.csv'];
    delimiter = ',';
    startRow = 2;
%% Format for each line of text:
%   column1: double (%f)     column2: double (%f)
formatSpec = '%f%f%*s%*s%[^\n\r]';
fileID = fopen(filename,'r'); % Open the text file.
%% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID); % Close the text file.
% output of array: 1st col. date, 2nd col. PopNo.
P = [dataArray{1:end-1}];
Pop = P(end,2);
date = datestr(P(end,1));
% set up Static Texts
handles.LastPopNo.String = num2str(Pop);
handles.LastPopDate.String = date;


% --- Executes on button press in Analyze. %% Visible=0, because doesnt
% work yet
function Analyze_Callback(hObject, eventdata, handles)
% hObject    handle to Analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(handles.f)
if handles.checkbox1.Value == 1
    
        % Architecture Change image show
        try
            
          ArchChange(handles.RGB,handles.path,handles.NestID);
        catch
            warning('ArchChange problem. show I of RGB instead')
            handles.f=figure('Name','Image');
            imshow(rgb2gray(handles.RGB))
        end
else
 
        imshow(rgb2gray(handles.RGB)) 
end

if handles.checkbox2.Value == 1
        % AntDetectOverlay image show
        if exist('handles.NoOfDetect','var')~=1
            handles.NoOfDetect = input('Type the number of Detect Photos\n');
        end
% handles.NoOfDetect = 0;
        % conditions to make sure the DETECT no is 3
        if handles.NoOfDetect >= 3
             try
                AntDetectOverlay(handles.RGB,handles.path);
            catch
                warning('AntDetectOverlay problem. Show without')
            end
        else
            disp('Detect No. too low for AntDetectOverlay')
        end
end
guidata(hObject,handles) % save changes to data

function checkbox1_Callback(hObject, eventdata, handles)

function checkbox2_Callback(hObject, eventdata, handles)

function BroodLocatorGUI_KeyReleaseFcn(hObject, eventdata, handles)
