clc;
clear;

% Set your dataset folder path
datasetPath = fullfile(pwd, 'dataset_folder');

% Create datastores for training and validation sets
imdsTrain = imageDatastore(fullfile(datasetPath, 'train'), ...
    'IncludeSubfolders', true, 'LabelSource', 'foldernames');

imdsVal = imageDatastore(fullfile(datasetPath, 'valid'), ...
    'IncludeSubfolders', true, 'LabelSource', 'foldernames');

disp('Training class distribution:');
countEachLabel(imdsTrain)
disp('Validation class distribution:');
countEachLabel(imdsVal)

inputSize = [227 227 3];

% ✅ Fix by forcing grayscale images into RGB:
resizeAndConvert = @(filename) cat(3, imresize(imread(filename), inputSize(1:2)), ...
                                      imresize(imread(filename), inputSize(1:2)), ...
                                      imresize(imread(filename), inputSize(1:2)));

readAndPreprocess = @(filename) imresize(im2uint8(im2double(repmat(imread(filename), [1 1 3]))), inputSize(1:2));

% Better solution (auto-check image channels):
imdsTrain.ReadFcn = @(filename) preprocessImage(filename, inputSize);
imdsVal.ReadFcn = @(filename) preprocessImage(filename, inputSize);

function imgOut = preprocessImage(filename, inputSize)
    img = imread(filename);
    if size(img, 3) == 1
        img = cat(3, img, img, img);  % convert grayscale to RGB
    end
    imgOut = imresize(img, inputSize(1:2));
end

% Define CNN layers:
layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(3, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    convolution2dLayer(3, 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    fullyConnectedLayer(numel(categories(imdsTrain.Labels)))
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.0001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', imdsVal, ...
    'ValidationFrequency', 30, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

disp('Training started...');
net = trainNetwork(imdsTrain, layers, options);
save('TrainedLungCancerCNN.mat', 'net');
disp('✅ Training complete! TrainedLungCancerCNN.mat saved.');

