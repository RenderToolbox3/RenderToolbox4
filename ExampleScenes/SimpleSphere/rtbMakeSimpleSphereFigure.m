%%% RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%%% About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%%% RenderToolbox4 is released under the MIT License.  See LICENSE file.
%
%% Make a figure with data about rendered and expected Ward spheres.

%% Render the scene.
rtbMakeMatlabSimpleSphere();
rtbMakeSimpleSphere();

%% Load sphere renderings.

hints.recipeName = 'rtbMakeSimpleSphere';
dataFilePattern = 'SimpleSphere[0-9\-]*\.mat';

% get output from the Render Toolbox reference renderer
%   normalize it, scale it
hints.renderer = 'SphereRenderer';
dataFolder = rtbWorkingFolder( ...
    'folderName', 'renderings', ...
    'rendererSpecific', true, ...
    'hints', hints);
matFile = rtbFindFiles('root', dataFolder, 'filter', dataFilePattern);
fprintf('Using Matlab Sphere Renderer output found here: \n  %s\n', ...
    matFile{1});
refData = load(matFile{1});
refMax = max(refData.multispectralImage(:));
refData.multispectralImage = refData.multispectralImage/refMax;

% get output from PBRT
%   normalize it, scale it
dataFilePattern = 'scene[0-9\-]*\.mat';
hints.renderer = 'PBRT';
dataFolder = rtbWorkingFolder( ...
    'folderName', 'renderings', ...
    'rendererSpecific', true, ...
    'hints', hints);
matFile = rtbFindFiles('root', dataFolder, 'filter', dataFilePattern);
PBRTData = load(matFile{1});
PBRTMax = max(PBRTData.multispectralImage(:));
PBRTData.multispectralImage = PBRTData.multispectralImage/PBRTMax;

% get output from Mitsuba
%   normalize it, scale it
hints.renderer = 'Mitsuba';
dataFolder = rtbWorkingFolder( ...
    'folderName', 'renderings', ...
    'rendererSpecific', true, ...
    'hints', hints);
matFile = rtbFindFiles('root', dataFolder, 'filter', dataFilePattern);
mitsubaData = load(matFile{1});
mitsubaMax = max(mitsubaData.multispectralImage(:));
mitsubaData.multispectralImage = mitsubaData.multispectralImage/mitsubaMax;

% how big are these images?
imageHeight = size(refData.multispectralImage, 1);
imageWidth = size(refData.multispectralImage, 2);

%% Make a figure with renderings and difference images
fig = figure();
clf(fig);
set(fig, 'Name', 'SimpleSphere', 'UserData', 'SimpleSphere');
labelSize = 14;

% choose 3 images and 3 pairwise difference images
%   with associated spectral samplings
names = { ...
    'PBRT', ...
    'Mitsuba-PBRT', ...
    'Mitsuba', ...
    'PBRT-Reference', ...
    'Reference', ...
    'Mitsuba-Reference', ...
    };
images = { ...
    PBRTData.multispectralImage, ...
    mitsubaData.multispectralImage - PBRTData.multispectralImage, ...
    mitsubaData.multispectralImage, ...
    PBRTData.multispectralImage - refData.multispectralImage, ...
    refData.multispectralImage, ...
    mitsubaData.multispectralImage - refData.multispectralImage, ...
    };
samplings = { ...
    PBRTData.S, ...
    refData.S, ...
    mitsubaData.S, ...
    refData.S, ...
    refData.S, ...
    refData.S, ...
    };

% show where a slice will be taken
sliceX = 125;
PBRTColor = [1 0.5 0];
mitsubaColor = [0 0 1];
referenceColor = 0.7*[1 1 1];
sliceColors = { ...
    PBRTColor, ...
    [], ...
    mitsubaColor, ...
    [], ...
    referenceColor, ...
    [], ...
    };

% choose tone mapping parameters
inputScale = 4000;
toneMapFactor = 0;
isGammaScale = false;

% convert images to sRGB and plot them
nImages = numel(images);
for ii = 1:nImages
    imageData = images{ii} / inputScale;
    S = samplings{ii};
    
    % make sRGB image
    [sRGB, XYZ] = rtbMultispectralToSRGB(imageData, S, ...
        'toneMapFactor', toneMapFactor, ...
        'isScale', isGammaScale);
    ax = subplot(3, 3, ii, 'Parent', fig);
    imshow(uint8(sRGB), 'Parent', ax);
    title(ax, names{ii});
    set(ax, 'UserData', names{ii});
    
    sliceColor = sliceColors{ii};
    if ~isempty(sliceColor)
        line(sliceX*[1 1], [0 imageHeight + 1], ...
            'Parent', ax, ...
            'Color', sliceColor, ...
            'LineStyle', ':', ...
            'LineWidth', 2, ...
            'Marker', 'none');
    end
end

% take a slice through each image
wls = MakeItWls(refData.S);
bandIndex = 13;
sliceWavelength = wls(bandIndex);
referenceSlice = refData.multispectralImage(:, sliceX, bandIndex);
PBRTSlice = PBRTData.multispectralImage(:, sliceX, bandIndex);
mitsubaSlice = mitsubaData.multispectralImage(:, sliceX, bandIndex);

% plot the slices
axSlice = subplot(3, 3, 7:9, ...
    'Parent', fig, ...
    'UserData', 'slices', ...
    'XLim', [0 imageHeight + 1], ...
    'XTick', [1, 50:50:imageHeight-3, imageHeight], ...
    'YLim', [-0.1 1.1], ...
    'YTick', [0 1], ...
    'YTickLabel', {'0', 'reference max'});
powerText = sprintf('%dnm power', sliceWavelength);
title(axSlice, powerText, 'FontSize', labelSize);
xlabel(axSlice, 'image row (pixels)', 'FontSize', labelSize);

sliceMax = max(referenceSlice);
line(1:imageHeight, referenceSlice/sliceMax, ...
    'Parent', axSlice, ...
    'Color', referenceColor, ...
    'LineStyle', 'none', ...
    'LineWidth', 1, ...
    'Marker', '.', ...
    'MarkerSize', 30);
line(1:imageHeight, PBRTSlice/sliceMax, ...
    'Parent', axSlice, ...
    'Color', PBRTColor, ...
    'LineStyle', 'none', ...
    'LineWidth', 1, ...
    'Marker', 'square', ...
    'MarkerSize', 10);
line(1:imageHeight, mitsubaSlice/sliceMax, ...
    'Parent', axSlice, ...
    'Color', mitsubaColor, ...
    'LineStyle', 'none', ...
    'LineWidth', 1, ...
    'Marker', '+', ...
    'MarkerSize', 7);
legend(axSlice, ' Reference', 'PBRT', 'Mitsuba', 'Location', 'northeast')

% save the figure as an image file
figureFolder = rtbWorkingFolder( ...
    'folderName', 'images', ...
    'hints', hints);
figureFile = fullfile(figureFolder, [hints.recipeName '.png']);
saveas(fig, figureFile);
