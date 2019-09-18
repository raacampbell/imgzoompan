function example1
% imgzoompan example1
%
% Simple use case: Load an image (provided) and show it,
% then add zoompan functionality.
% When using GUIDE, provide a handle to your own figure window.

help(mfilename)

addpath('../');

Img = imread('myimage.jpg');
imshow(Img);
[h, w, ~] = size(Img);
imgzoompan(gcf, 'ImgWidth', w, 'ImgHeight', h);