%% This code train and test semantic segmentation of Capsule endoscopy images
% required MATLAB 2018
% Developer: Tonmoy Ghosh (tghosh@crimson.ua.edu)

% Load Images
% Use |imageDatastore| to load images. The |imageDatastore| enables you 
% to efficiently load a large collection of images on disk.
%%
clear; clc; close all;
%imgDir = fullfile('bleeding images')
imgDir = '/Users/tonmoyghosh/OneDrive - The University of Alabama/Paper with Code/Semantic Segmentation Based Bleeding Zone Detection/Dataset/bleeding';
imds = imageDatastore(imgDir);
%% 
% Display one of the images.

I = readimage(imds, 1);
I = histeq(I);
figure
imshow(I)
%% Load Pixel-Labeled Images
classes = [
    "Bleeding"
    "Non_Bleeding"
    "Background"
    ];
labelIDs = PixelLabelIDs();
%% 
% Use the classes and label IDs to create the |pixelLabelDatastore|:

%labelDir = fullfile('labels');
labelDir = '/Users/tonmoyghosh/OneDrive - The University of Alabama/Paper with Code/Semantic Segmentation Based Bleeding Zone Detection/Dataset/labels';
pxds = pixelLabelDatastore(labelDir,classes,labelIDs);
% Read and display one of the pixel-labeled images by overlaying it on top 
% of an image.

C = readimage(pxds, 1);


cmap = CEColorMap;
B = labeloverlay(I,C,'ColorMap',cmap);

figure
imshow(B)
pixelLabelColorbar(cmap,classes);

%%
%analize the data statistics
tbl = countEachLabel(pxds)


%Visualize the pixel counts by class.

frequency = tbl.PixelCount/sum(tbl.PixelCount);

figure
bar(1:numel(classes),frequency)
xticks(1:numel(classes))
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')

%%
%Resize CamVid Data
imageFolder = fullfile('imagesReszed',filesep);
imds = resizeCEImages(imds,imageFolder);

labelFolder = fullfile('labelsResized',filesep);
pxds = resizeCEPixelLabels(pxds,labelFolder);



%%
%Prepare Training and Test Sets
[imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionCEData(imds,pxds);

numTrainingImages = numel(imdsTrain.Files)
numTestingImages = numel(imdsTest.Files)

%Create the network
imageSize = [256 256 3];
numClasses = numel(classes);
%lgraph = segnetLayers(imageSize,numClasses,'vgg16');


%%

%Balance Classes Using Class Weighting
% imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
% classWeights = median(imageFreq) ./ imageFreq
% 
% pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tbl.Name, 'ClassWeights', classWeights)
% 
% 
% lgraph = removeLayers(lgraph, 'pixelLabels');
% lgraph = addLayers(lgraph, pxLayer);
% lgraph = connectLayers(lgraph, 'softmax' ,'labels');

% load saved network architecture
load lgraph

%Select Training Options
options = trainingOptions('sgdm', ...
    'Momentum', 0.9, ...
    'InitialLearnRate', 1e-3, ...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 3, ...
    'Shuffle', 'every-epoch', ...
    'VerboseFrequency', 2);



%%

%Data Augmentation
augmenter = imageDataAugmenter('RandXReflection',true,...
    'RandXTranslation', [-10 10], 'RandYTranslation',[-10 10]);


%Start Training
datasource = pixelLabelImageSource(imdsTrain,pxdsTrain, ...
                    'DataAugmentation',augmenter);

doTraining = false;
if doTraining
    [net, info] = trainNetwork(datasource,lgraph,options);
else
    data = load('CEtrainedSegNet.mat');
    net = data.net;
end

%%
%Test Network on One Image
tic
I = read(imdsTest);
C = semanticseg(I, net);

%Display the results.
B = labeloverlay(I, C, 'Colormap', cmap, 'Transparency',0.4);
figure
imshow(B)
pixelLabelColorbar(cmap, classes);

expectedResult = read(pxdsTest);
actual = uint8(C);
expected = uint8(expectedResult{1});
imshowpair(actual, expected)

iou = jaccard(C, expectedResult{1});
table(classes,iou)

%Evaluate Trained Network
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

toc
