function changingSettingsOnTheFly
% imgzoompan changingSettingsOnTheFly
%
% Demonstrates how to alter settings after the plot has been created

help(mfilename)

addpath('../');
f=clf;
Img = imread('myimage.jpg');
imshow(Img);
imgzoompan

fprintf('\n\n\n *** ==> Try zooming then press return to see a change in zoom rate <== **\n\n\n')
pause

f.UserData.zoompan.Magnify=1.4;