function multipleSubPlots
% imgzoompan multipleSubPlots
%
% Shows how imgzoompan behaves when there are multiple sub-plots in one figure window.

help(mfilename)

addpath('../');

clf

subplot(1,2,1)
Img = imread('myimage.jpg');
imshow(Img);

subplot(1,2,2)
P = peaks(256);
imagesc(P)

[h, w, ~] = size(P);
imgzoompan('ImgWidth', w, 'ImgHeight', h);