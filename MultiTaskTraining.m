clc;
clear;
datasetPath = fullfile(pwd, 'dataset_folder');
imdsTrain = imageDatastore(fullfile(datasetPath, 'train'), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
imdsVal = imageDatastore(fullfile(datasetPath, 'valid'), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
disp('Training class distribution:');
countEachLabel(imdsTrain)
disp('Validation class distribution:');
countEachLabel(imdsVal)
inputSize = [227 227 3];
imdsTrain.ReadFcn = @(filename) preprocessImage(filename, inputSize);
imdsVal.ReadFcn = @(filename) preprocessImage(filename, inputSize);

function imgOut = preprocessImage(filename, inputSize)
    img = imread(filename);
    if size(img, 3) == 1
        img = cat(3, img, img, img);
    end
    imgOut = imresize(img, inputSize(1:2));
end

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
    fullyConnectedLayer(4)
    softmaxLayer
    classificationLayer
];
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