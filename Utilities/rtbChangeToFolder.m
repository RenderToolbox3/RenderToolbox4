function wasCreated = rtbChangeToFolder(folder)
%% Change to the given folder, create it if necessary.
%
%
% rtbChangeToFolder(folder) will cd() to the @a folder, creating it if it
% doesn't exist already.
%
% Returns true if the folder had to be created.
%
%%% RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%%% About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%%% RenderToolbox4 is released under the MIT License.  See LICENSE file.

parser = inputParser();
parser.addRequired('folder', @ischar);
parser.parse(folder);
folder = parser.Results.folder;

wasCreated = false;

if ~exist(folder, 'dir')
    mkdir(folder);
    wasCreated = true;
end

cd(folder);
