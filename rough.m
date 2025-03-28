function varargout = rough(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rough_OpeningFcn, ...
                   'gui_OutputFcn',  @rough_OutputFcn, ...
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

function rough_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
ah = axes('unit', 'normalized', 'position', [0 0 1 1]); 
set(ah,'handlevisibility','off','visible','off')
uistack(ah, 'bottom');

function varargout = rough_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton2_Callback(hObject, eventdata, handles)
a = get(handles.edit1,'String');
b = get(handles.edit2,'String');
c = 'murali';
d = '9885';
e = strcmp(a,c);
f = strcmp(b,d);
if e==1 && f==1
    f = msgbox('Login Successful','Success');
    set(f, 'position', [463 471 180 70]);
    pause(3);
    run records.m;
elseif e==1 && f==0
    msgbox('Incorrect password','Error','Error');
elseif e==0 && f==1
    msgbox('Incorrect Username','Error','Error');
else
    msgbox('Both Username and Password are Incorrect','Error','Error');
end

function pushbutton3_Callback(hObject, eventdata, handles)
msgbox('Hint : Project Team','Hint');
