clc; clear; close all;

% Set dataset path
datasetPath = fullfile(pwd, 'dataset_folder');  % Point to your folder

% Create image datastore
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Display class count
disp('Class distribution:');
countEachLabel(imds)

% Resize all images and split data
imds.ReadFcn = @(filename) imresize(imread(filename), [227 227]);
[imdsTrain, imdsValidation] = splitEachLabel(imds, 0.8, 'randomized');

% Dynamically get number of classes:
numClasses = numel(categories(imdsTrain.Labels));

% Define CNN layers
layers = [
    imageInputLayer([227 227 3])

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

    fullyConnectedLayer(numClasses)   % <-- Dynamic output layer
    softmaxLayer
    classificationLayer
];

% Training options
options = trainingOptions('adam', ...
    'MaxEpochs', 10, ...
    'InitialLearnRate', 0.001, ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 30, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

% Train the network
disp('Training started...');
net = trainNetwork(imdsTrain, layers, options);

% Save trained model
save('TrainedLungCancerCNN.mat', 'net');
disp('✅ Training complete! Model saved as TrainedLungCancerCNN.mat');
