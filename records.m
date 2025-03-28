function varargout = records(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @records_OpeningFcn, ...
                   'gui_OutputFcn',  @records_OutputFcn, ...
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

function records_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
try
    ah = axes('unit', 'normalized', 'position', [0 0 1 1]); 
    bg = imread('background1.jpg');
    imagesc(bg);
    set(ah,'handlevisibility','off','visible','off')
    uistack(ah, 'bottom');
catch
    warning('background1.jpg not found. Proceeding without background.');
end

function varargout = records_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)
for idx = 1:12
    if isfield(handles, ['edit' num2str(idx)])
        set(handles.(['edit' num2str(idx)]), 'String', '');
    end
end
msgbox('All fields cleared.', 'Info', 'modal');

function pushbutton2_Callback(hObject, eventdata, handles)
inputs = zeros(1,12);
for idx = 1:12
    if isfield(handles, ['edit' num2str(idx)])
        val = str2double(get(handles.(['edit' num2str(idx)]), 'String'));
        
        if idx == 9
            patientName = get(handles.edit9, 'String');
            if isempty(patientName)
                errordlg('Patient name in Edit9 cannot be empty.', 'Error', 'modal');
                return;
            end
            inputs(idx) = 0; % Placeholder for non-numeric field
        else
            inputs(idx) = val;
        end
    end
end
if exist('records.mat', 'file')
    load('records.mat', 'all_records');
    all_records(end+1, :) = inputs;
else
    all_records = inputs;
end
save('records.mat', 'all_records');
if exist('success.jpg', 'file')
    myicon = imread('success.jpg');
    msgbox('Record saved successfully. Launching cancer detection...', 'Success', 'custom', myicon);
else
    msgbox('Record saved successfully. Launching cancer detection...', 'Success');
end



function pushbutton3_Callback(hObject, eventdata, handles)
if exist('records.mat', 'file')
    load('records.mat', 'all_records');
    f = figure('Name', 'Saved Records', 'Color', [0.95 0.97 1]);
    uitable('Data', all_records, 'ColumnName', {'A','B','C','D','E','F','G','H','I','J','K','L'}, 'Position', [20 20 600 300]);
else
    msgbox('No saved records found.', 'Info', 'modal');
end

function pushbutton4_Callback(hObject, eventdata, handles)
msgbox('Launching cancer detection...', 'Please wait', 'modal');
pause(1);
if exist('cancer.m', 'file')
    run('cancer.m');
else
    msgbox('cancer.m not found in current path.', 'Error', 'error');
end

function checkbox1_Callback(hObject, eventdata, handles)

function checkbox2_Callback(hObject, eventdata, handles)



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
