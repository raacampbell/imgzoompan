function customCallbacks1
% imgzoompan customCallbacks1
%
% This example provides custom callback functions for the ButtonDown 
% and ButtonUp mouse events from the root Figure.

help(mfilename)

addpath('../')

Img = imread('myimage.jpg');
imshow(Img);
imgzoompan('ButtonDownFcn', @myFuncDown, 'ButtonUpFcn', @myFuncUp);

% Custom button down function handler
function myFuncDown(hObject, event)
    clickType = event.Source.SelectionType;
    fprintf('Mouse down button: %s\n', clickType);


% Custom button up function handler
function myFuncUp(hObject, event)
    fprintf('Mouse up!\n');
