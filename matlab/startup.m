restoredefaultpath();

thisPath = fileparts(mfilename('fullpath'));
absPath = @(varargin) fullfile(thisPath, varargin{:});

addpath(absPath())
addpath(genpath(absPath('spm12')))
addpath(genpath(absPath('tapas-master','rDCM')))

%clear;
clc;

format long g;