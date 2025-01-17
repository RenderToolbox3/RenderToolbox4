function recipe = rtbCleanRecipe(recipe)
%% Clear out recipe derived data fileds.
%
% recipe = rtbCleanRecipe(recipe) clears out derived data fields from the
% given recupe and returns the updated recupe.
%
%%% RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%%% About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%%% RenderToolbox4 is released under the MIT License.  See LICENSE file.

parser = inputParser();
parser.addRequired('recipe', @isstruct);
parser.parse(recipe);
recipe = parser.Results.recipe;

% Clear all derived data fields
recipe.rendering = [];
recipe.processing = [];
recipe.dependencies = [];
recipe.log = [];