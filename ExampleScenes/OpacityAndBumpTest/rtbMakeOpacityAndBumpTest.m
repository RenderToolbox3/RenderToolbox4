%% Render a vase to test mask and bump textures.
% This vase is from the Crytek scene. It has opacity and bump textures.

%% Choose batch renderer options.
clear;

hints.imageWidth = 320;
hints.imageHeight = 240;
hints.fov = deg2rad(5);
hints.recipeName = 'OpacityAndBumpTest';

hints.renderer = 'PBRT';

resources = rtbWorkingFolder( ...
    'folderName', 'resources', ...
    'hints', hints);

%% Load the test scene.

parentSceneFile = fullfile(rtbRoot(), 'ExampleScenes', ...
    'OpacityAndBumpTest', 'Data', 'crytekSmall.obj');
scene = mexximpCleanImport(parentSceneFile,...
    'flipUVs',true,...
    'toReplace',{'jpg','png'},...
    'targetFormat','exr', ...
    'workingFolder', resources, ...
    'strictMatching', true);


%% Add camera and lights

% Add camera
% Note: Centralize does not seem to put camera in a good spot?
scene = mexximpCentralizeCamera(scene);

% Move camera
from = [10 5 6];
to = [0 0 0];
up = [0 1 0];
cameraTransform = mexximpLookAt(from, to, up);
cameraNodeSelector = strcmp(scene.cameras.name, {scene.rootNode.children.name});
scene.rootNode.children(cameraNodeSelector).transformation = cameraTransform;

scene = mexximpAddLanterns(scene);

%% Render
nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints);
radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);

SRGBMontage = ...
    rtbMakeMontage(radianceDataFiles, ...
    'toneMapFactor', 10, ...
    'isScale', true, ...
    'hints', hints);

montageName = sprintf('Original');
rtbShowXYZAndSRGB([], SRGBMontage, montageName);
