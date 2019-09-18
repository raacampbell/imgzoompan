function example3
% imgzoompan example3
%
% This example provides custom function handlers for the image axes' ButtonDownFcn callback.
% This callback will only fire if a visible (not overlapped) part of the image area is clicked.

help(mfilename)


addpath('../')

Img = imread('myimage.jpg');
hImage = imshow(Img); % we need this handle to the image
[h, w, ~] = size(Img);
imgzoompan([], 'ImgWidth', w, 'ImgHeight', h);

% imshow resets the axes' callbacks, so we need to set this callback manually
hImage.ButtonDownFcn = @myFuncDown;

% Custom button down function handler
function myFuncDown(src, event)
	fprintf('Mouse button: %d\n', event.Button);

