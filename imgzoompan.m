function imgzoompan(hfig, varargin)
% imgzoompan provides instant mouse zoom and pan
%
% function imgzoompan(hfig, varargin)
%
%% Purpose
% This function provides instant mouse zoom (mouse wheel) and pan (mouse drag) capabilities 
% to figures, designed for displaying 2D images that require lots of drag & zoom. For more
% details see README file.
%
% 
%% Inputs (optional param/value pairs)
% The following relate to zoom config
% * 'Magnify' General magnitication factor. 1.0 or greater (default: 1.1). A value of 2.0 
%             solves the zoom & pan deformations caused by MATLAB's embedded image resize method.
% * 'XMagnify'        Magnification factor of X axis (default: 1.0).
% * 'YMagnify'        Magnification factor of Y axis (default: 1.0).
% * 'ChangeMagnify'.  Relative increase of the magnification factor. 1.0 or greater (default: 1.1).
% * 'IncreaseChange'  Relative increase in the ChangeMagnify factor. 1.0 or greater (default: 1.1).
% * 'MinValue' Sets the minimum value for Magnify, ChangeMagnify and IncreaseChange (default: 1.1).
% * 'MaxZoomScrollCount' Maximum number of scroll zoom-in steps; might need adjustements depending 
%                        on your image dimensions & Magnify value (default: 30).
% The following relate to pan configuration:
% 'ImgWidth' Original image pixel width. A value of 0 disables the functionality that prevents the 
%            user from dragging and zooming outside of the image (default: 0).
% 'ImgHeight' Original image pixel height (default: 0).
%
%
%% Outputs
%  none
%
% 
%% ACKNOWLEDGEMENTS:
%
% *) Hugo Eyherabide (Hugo.Eyherabide@cs.helsinki.fi) as this project uses his code
%    (FileExchange: zoom_wheel) as reference for zooming functionality.
% *) E. Meade Spratley for his mouse panning example (FileExchange: MousePanningExample).
% *) Alex Burden for his technical and emotional support.
%
% Send code updates, bug reports and comments to: Dany Cabrera (dcabrera@uvic.ca)
% Please visit https://github.com/danyalejandro/imgzoompan (or check the README.md text file) for
% full instructions and examples on how to use this plugin.
%
%% Copyright (c) 2018, Dany Alejandro Cabrera Vargas, University of Victoria, Canada,
% published under BSD license (http://www.opensource.org/licenses/bsd-license.php).


%  Run in current figure unless otherwise requested
if isempty(findobj('type','figure'))
    fprintf('%s -- finds no open figure windows. Quitting.\n', mfilename)
    return
end

if nargin==0 || isempty(hfig) || ~isa(hfig,'matlab.ui.Figure')
    hfig = gcf;
end

% Parse configuration options
p = inputParser;
% Zoom configuration options
p.addOptional('Magnify', 1.1, @isnumeric);
p.addOptional('XMagnify', 1.0, @isnumeric);
p.addOptional('YMagnify', 1.0, @isnumeric);
p.addOptional('ChangeMagnify', 1.1, @isnumeric);
p.addOptional('IncreaseChange', 1.1, @isnumeric);
p.addOptional('MinValue', 1.1, @isnumeric);
p.addOptional('MaxZoomScrollCount', 30, @isnumeric);

% Pan configuration options
p.addOptional('ImgWidth', 0, @isnumeric);
p.addOptional('ImgHeight', 0, @isnumeric);

% Mouse options and callbacks
p.addOptional('PanMouseButton', 2, @isnumeric);
p.addOptional('ResetMouseButton', 3, @isnumeric);
p.addOptional('ButtonDownFcn',  @(~,~) 0);
p.addOptional('ButtonUpFcn', @(~,~) 0) ;

% Parse & Sanitize options
parse(p, varargin{:});
opt = p.Results;

if opt.Magnify<opt.MinValue
    opt.Magnify=opt.MinValue;
end
if opt.ChangeMagnify<opt.MinValue
    opt.ChangeMagnify=opt.MinValue;
end
if opt.IncreaseChange<opt.MinValue
    opt.IncreaseChange=opt.MinValue;
end


% Place the settings and temporary variable into the figure's UserData property
hfig.UserData.zoompan = opt;
hfig.UserData.zoompan.zoomScrollCount = 0;
hfig.UserData.zoompan.origH=[];
hfig.UserData.zoompan.origXLim=[];
hfig.UserData.zoompan.origYLim=[];

% Set up callback functions
set(hfig, 'WindowScrollWheelFcn', @zoom_fcn);
set(hfig, 'WindowButtonDownFcn', @down_fcn);
set(hfig, 'WindowButtonUpFcn', @up_fcn);





% -------------------------------
% Start of callback functions 


function zoom_fcn(src, evt)
    % This callback function is called when the mouse scroll wheel event fires. 
    % The callback is used to manage figure zooming

    scrollChange = evt.VerticalScrollCount; % -1: zoomIn, 1: zoomOut
    zpSet = src.UserData.zoompan;

    if ((zpSet.zoomScrollCount - scrollChange) <= zpSet.MaxZoomScrollCount)
        axish = gca;

        if (isempty(zpSet.origH) || axish ~= zpSet.origH)
            zpSet.origH = axish;
            zpSet.origXLim = axish.XLim;
            zpSet.origYLim = axish.YLim;
        end

        % calculate the new XLim and YLim
        cpaxes = mean(axish.CurrentPoint);
        newXLim = (axish.XLim - cpaxes(1)) * (zpSet.Magnify * zpSet.XMagnify)^scrollChange + cpaxes(1);
        newYLim = (axish.YLim - cpaxes(2)) * (zpSet.Magnify * zpSet.YMagnify)^scrollChange + cpaxes(2);

        newXLim = floor(newXLim);
        newYLim = floor(newYLim);
        % only check for image border location if user provided ImgWidth
        if (zpSet.ImgWidth > 0)
            if (newXLim(1) >= 0 && newXLim(2) <= zpSet.ImgWidth && newYLim(1) >= 0 && newYLim(2) <= zpSet.ImgHeight)
                axish.XLim = newXLim;
                axish.YLim = newYLim;
                zpSet.zoomScrollCount = zpSet.zoomScrollCount - scrollChange;
            else
                axish.XLim = zpSet.origXLim;
                axish.YLim = zpSet.origYLim;
                zpSet.zoomScrollCount = 0;
            end
        else
            axish.XLim = newXLim;
            axish.YLim = newYLim;
            zpSet.zpSet.zoomScrollCount = zpSet.zpSet.zoomScrollCount - scrollChange;
        end
        %fprintf('XLim: [%.3f, %.3f], YLim: [%.3f, %.3f]\n', axish.XLim(1), axish.XLim(2), axish.YLim(1), axish.YLim(2));
    end
    hfig.UserData.zoompan = zpSet;


function down_fcn(src, evt)
    % This callback function is called when the mouse button goes down. 
    % The callback is used to manage figure panning.

    zpSet = src.UserData.zoompan;
    zpSet.ButtonDownFcn(src, evt); % First, run callback from options


    clickType = evt.Source.SelectionType;

    % Panning action
    panBt = zpSet.PanMouseButton;
    if (panBt > 0)
        if (panBt == 1 && strcmp(clickType, 'normal')) || ...
            (panBt == 2 && strcmp(clickType, 'alt')) || ...
            (panBt == 3 && strcmp(clickType, 'extend'))

            guiArea = hittest(src);
            parentAxes = ancestor(guiArea,'axes');

            % if the mouse is over the desired axis, trigger the pan fcn
            if ~isempty(parentAxes)
                startPan(parentAxes)
            else
                setptr(evt.Source,'forbidden')
            end
        end
    end


function up_fcn(src, evt)
    % This callback function is called when the mouse button goes up. 
    % The callback is used to manage figure panning.

    zpSet = src.UserData.zoompan;
    zpSet.ButtonUpFcn(src, evt); % First, run callback from options

    % Reset action
    clickType = evt.Source.SelectionType;
    resBt = zpSet.ResetMouseButton;
    if (resBt > 0 && ~isempty(zpSet.origXLim))
        if (resBt == 1 && strcmp(clickType, 'normal')) || ...
            (resBt == 2 && strcmp(clickType, 'alt')) || ...
            (resBt == 3 && strcmp(clickType, 'extend'))

            guiArea = hittest(src);
            parentAxes = ancestor(guiArea,'axes');
            parentAxes.XLim=zpSet.origXLim;
            parentAxes.YLim=zpSet.origYLim;
        end
    end

    set(gcbf,'WindowButtonMotionFcn',[]);
    setptr(gcbf,'arrow');




% -------------------------------
% Start of helper functions for axis panning

function startPan(hAx)
    % Call this Fcn in your 'WindowButtonDownFcn'
    % Take in desired Axis to pan
    % Get seed points & assign the Panning Fcn to top level Fig
    hFig = ancestor(hAx, 'Figure', 'toplevel');   % Parent Fig

    seedPt = get(hAx, 'CurrentPoint'); % Get init mouse position
    seedPt = seedPt(1, :); % Keep only 1st point

    % Temporarily stop 'auto resizing'
    hAx.XLimMode = 'manual'; 
    hAx.YLimMode = 'manual';

    set(hFig,'WindowButtonMotionFcn',{@panningFcn,hAx,seedPt});
    setptr(hFig, 'hand'); % Assign 'Panning' cursor



function panningFcn(src,~,hAx,seedPt)
    % Controls the real-time panning on the desired axis
    zpSet = src.UserData.zoompan;
    % Get current mouse position
    currPt = get(hAx,'CurrentPoint');

    % Current Limits [absolute vals]
    XLim = hAx.XLim;
    YLim = hAx.YLim;

    % Original (seed) and Current mouse positions [relative (%) to axes]
    x_seed = (seedPt(1)-XLim(1))/(XLim(2)-XLim(1));
    y_seed = (seedPt(2)-YLim(1))/(YLim(2)-YLim(1));

    x_curr = (currPt(1,1)-XLim(1))/(XLim(2)-XLim(1));
    y_curr = (currPt(1,2)-YLim(1))/(YLim(2)-YLim(1));

    % Change in mouse position [delta relative (%) to axes]
    deltaX = x_curr-x_seed;
    deltaY = y_curr-y_seed;

    % Calculate new axis limits based on mouse position change
    newXLims(1) = -deltaX*diff(XLim)+XLim(1);
    newXLims(2) = newXLims(1)+diff(XLim);

    newYLims(1) = -deltaY*diff(YLim)+YLim(1);
    newYLims(2) = newYLims(1)+diff(YLim);

    % MATLAB lack of anti-aliasing deforms the image if XLims & YLims are not integers
    newXLims = round(newXLims);
    newYLims = round(newYLims);

    % Update Axes limits
    if (newXLims(1) > 0.0 && newXLims(2) < zpSet.ImgWidth)
        set(hAx,'Xlim',newXLims);
    end
    if (newYLims(1) > 0.0 && newYLims(2) < zpSet.ImgHeight)
        set(hAx,'Ylim',newYLims);
    end

