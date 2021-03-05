% Testing on New Data (capsule endoscopy images)
% Developer: Tonmoy Ghosh (tghosh@crimson.ua.edu)

clear; close all; clc;
% load trained network
data = load('CEtrainedSegNet.mat');
net = data.net;
labelIDs = PixelLabelIDs();
cmap = CEColorMap;
classes = [
    "Bleeding"
    "Non_Bleeding"
    "Background"
    ];



imdsTest = imageDatastore('testImage.png'); % image location and name
pxdsTest = pixelLabelDatastore('testLabel.png',classes,labelIDs);
tic
I = read(imdsTest);
I = imresize(I,[256 256]);
C = semanticseg(I, net);

%Display the results.
B = labeloverlay(I, C, 'Colormap', cmap, 'Transparency',0.4);
figure
imshow(B)
pixelLabelColorbar(cmap, classes);

L = read(pxdsTest);
expectedResult = imresize(L{1},[256 256],'nearest');
actual = uint8(C);
expected = uint8(expectedResult);
figure;
imshowpair(actual, expected)

iou = jaccard(C, expectedResult);
table(classes,iou)

%Evaluate Trained Network
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

toc