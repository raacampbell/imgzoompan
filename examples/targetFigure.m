function targetFigure
% imgzoompan targetFigure examples
%
% Shows how to target imgzoompan to a particular figure window


help(mfilename)

addpath('../');


fig1 = figure;
fig1.Name = 'TARGET WINDOW';
Img = imread('myimage.jpg');
imshow(Img);

fig2 = figure;
fig2.Name = 'DESTRACTOR WINDOW';
p=peaks(256);
imagesc(p)



[h, w, ~] = size(Img);
imgzoompan('hFig',fig1, 'ImgWidth', w, 'ImgHeight', h);