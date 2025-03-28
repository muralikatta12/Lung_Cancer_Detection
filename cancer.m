function varargout = cancer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cancer_OpeningFcn, ...
                   'gui_OutputFcn',  @cancer_OutputFcn, ...
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

function cancer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);
bg = imread('project_image1.jpg');
imagesc(bg);
set(ah, 'handlevisibility', 'off', 'visible', 'off');
uistack(ah, 'bottom');
if nargin > 3 && ~isempty(varargin{1})
    global I entropyVal patientName
    imagePath = varargin{1};
    I = imread(imagePath);
    [~, patientName, ~] = fileparts(imagePath);
    axes(handles.axes1);
    imshow(I);
    title('Original Lung Image');
    set(handles.edit9, 'String', patientName);
    grayImage = rgb2gray(I);
    histEqImage = histeq(grayImage);
    binImage = imbinarize(histEqImage, graythresh(histEqImage));
    sobelFilter = fspecial('sobel');
    filteredImage = imfilter(double(binImage), sobelFilter, 'replicate');
    se = strel('line', 11, 90);
    dilatedImage = imdilate(filteredImage, se);
    filledImage = imfill(dilatedImage, 'holes');
    entropyVal = entropy(filledImage);
    if exist('TrainedLungCancerCNN.mat', 'file')
        load('TrainedLungCancerCNN.mat', 'net');
        resizedImg = imresize(I, [227 227]);
        if size(resizedImg, 3) == 1
            resizedImg = cat(3, resizedImg, resizedImg, resizedImg);
        end
        label = classify(net, resizedImg);
        if strcmp(char(label), 'normal')
            result = 'No Cancer';
            cancerType = 'None';
        else
            if entropyVal < 2
                stage = 'Stage I';
            elseif entropyVal < 4
                stage = 'Stage II';
            elseif entropyVal < 6
                stage = 'Stage III';
            else
                stage = 'Stage IV';
            end
            result = ['Cancer - ' stage];
            if contains(char(label), 'adenocarcinoma')
                cancerType = 'Adenocarcinoma';
            elseif contains(char(label), 'large.cell')
                cancerType = 'Large Cell Carcinoma';
            elseif contains(char(label), 'squamous.cell')
                cancerType = 'Squamous Cell Carcinoma';
            else
                cancerType = 'Unknown';
            end
        end
        set(handles.edit1, 'String', result);
        set(handles.edit5, 'String', cancerType);
        set(handles.edit9, 'String', patientName);
    else
        msgbox('TrainedLungCancerCNN.mat not found.', 'Error', 'error');
    end
end

function varargout = cancer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)
global I patientName
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files'}, 'Select an Image');
if isequal(filename, 0)
    warndlg('No image selected.');
else
    I = imread(fullfile(pathname, filename));
    [~, patientName, ~] = fileparts(filename);
    axes(handles.axes1);
    imshow(I);
    title('Original Lung Image');
    set(handles.edit9, 'String', patientName);
end

function pushbutton2_Callback(hObject, eventdata, handles)
global I
grayImage = rgb2gray(I);
histEqImage = histeq(grayImage);
axes(handles.axes2);
imshow(histEqImage);
title('Histogram Equalization');

function pushbutton3_Callback(hObject, eventdata, handles)
global I
grayImage = rgb2gray(I);
histEqImage = histeq(grayImage);
threshold = graythresh(histEqImage);
binImage = imbinarize(histEqImage, threshold);
axes(handles.axes3);
imshow(binImage);
title('Segmentation');

function pushbutton4_Callback(hObject, eventdata, handles)
global I
grayImage = rgb2gray(I);
histEqImage = histeq(grayImage);
binImage = imbinarize(histEqImage, graythresh(histEqImage));
sobelFilter = fspecial('sobel');
filteredImage = imfilter(double(binImage), sobelFilter, 'replicate');
axes(handles.axes4);
imshow(filteredImage, []);
title('Sobel Filtered');

function pushbutton5_Callback(hObject, eventdata, handles)
global I
grayImage = rgb2gray(I);
histEqImage = histeq(grayImage);
binImage = imbinarize(histEqImage, graythresh(histEqImage));
sobelFilter = fspecial('sobel');
filteredImage = imfilter(double(binImage), sobelFilter, 'replicate');
se = strel('line', 11, 90);
dilatedImage = imdilate(filteredImage, se);
axes(handles.axes5);
imshow(dilatedImage);
title('Dilated Image');

function pushbutton6_Callback(hObject, eventdata, handles)
global I
grayImage = rgb2gray(I);
histEqImage = histeq(grayImage);
binImage = imbinarize(histEqImage, graythresh(histEqImage));
sobelFilter = fspecial('sobel');
filteredImage = imfilter(double(binImage), sobelFilter, 'replicate');
se = strel('line', 11, 90);
dilatedImage = imdilate(filteredImage, se);
filledImage = imfill(dilatedImage, 'holes');
axes(handles.axes6);
imshow(filledImage);
title('Image Filled');

function pushbutton7_Callback(hObject, eventdata, handles)
global I entropyVal contrastVal energyVal
grayImage = rgb2gray(I);
histEqImage = histeq(grayImage);
binImage = imbinarize(histEqImage, graythresh(histEqImage));
sobelFilter = fspecial('sobel');
filteredImage = imfilter(double(binImage), sobelFilter, 'replicate');
se = strel('line', 11, 90);
dilatedImage = imdilate(filteredImage, se);
filledImage = imfill(dilatedImage, 'holes');
entropyVal = entropy(filledImage);
glcm = graycomatrix(filledImage, 'Offset', [2 0]);
contrastVal = graycoprops(glcm, 'Contrast').Contrast;
glcm2 = graycomatrix(filledImage, 'Offset', [2 0; 0 2]);
energyVal = min(graycoprops(glcm2, 'Energy').Energy);
set(handles.edit2, 'String', num2str(energyVal));
set(handles.edit3, 'String', num2str(entropyVal));
set(handles.edit4, 'String', num2str(contrastVal));

function pushbutton8_Callback(hObject, eventdata, handles)
global I entropyVal patientName
if exist('TrainedLungCancerCNN.mat', 'file') && ~isempty(entropyVal)
    load('TrainedLungCancerCNN.mat', 'net');
    resizedImg = imresize(I, [227 227]);
    if size(resizedImg, 3) == 1
        resizedImg = cat(3, resizedImg, resizedImg, resizedImg);
    end
    label = classify(net, resizedImg);
    if strcmp(char(label), 'normal')
        result = 'No Cancer';
        cancerType = 'None';
    else
        if entropyVal < 2
            stage = 'Stage I';
        elseif entropyVal < 4
            stage = 'Stage II';
        elseif entropyVal < 6
            stage = 'Stage III';
        else
            stage = 'Stage IV';
        end
        result = ['Cancer - ' stage];
        if contains(char(label), 'adenocarcinoma')
            cancerType = 'Adenocarcinoma';
        elseif contains(char(label), 'large.cell')
            cancerType = 'Large Cell Carcinoma';
        elseif contains(char(label), 'squamous.cell')
            cancerType = 'Squamous Cell Carcinoma';
        else
            cancerType = 'Unknown';
        end
    end
    set(handles.edit1, 'String', result);
    set(handles.edit5, 'String', cancerType);
    set(handles.edit9, 'String', patientName);
else
    msgbox('Run feature extraction (Pushbutton 7) and ensure TrainedLungCancerCNN.mat exists.', 'Error', 'error');
end

function edit1_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function edit2_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function edit3_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function edit4_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function edit5_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function edit7_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function edit9_CreateFcn(hObject, eventdata, handles)
setWhiteBackground(hObject);

function setWhiteBackground(hObject)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end
