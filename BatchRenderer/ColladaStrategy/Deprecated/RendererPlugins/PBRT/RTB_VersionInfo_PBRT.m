%%% RenderToolbox4 Copyright (c) 2012-2013 The RenderToolbox4 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox4/wiki/About-Us
%%% RenderToolbox4 is released under the MIT License.  See LICENSE.txt.
%
% Get version information about the PBRT.
%
% @details
% This is the RenderToolbox4 "VersionInfo" function for PBRT.
%
% @details
% See RTB_VersionInfo_SampleRenderer() for more about VersionInfo
% functions.
%
% Usage:
%   versionInfo = RTB_VersionInfo_PBRT()
function versionInfo = RTB_VersionInfo_PBRT()

% PBRT executable date stamp
try
    versionInfo = dir(getpref('PBRT', 'executable'));
catch err
    versionInfo = err;
end