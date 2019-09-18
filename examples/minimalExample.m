function minimalExample
% imgzoompan minimalExample
%
% Simple use case: Load an image (provided) and show it,
% then add zoompan functionality.
% When using GUIDE, provide a handle to your own figure window.

help(mfilename)

addpath('../');

Img = imread('myimage.jpg');
imshow(Img);
[h, w, ~] = size(Img);
imgzoompan('ImgWidth', w, 'ImgHeight', h);