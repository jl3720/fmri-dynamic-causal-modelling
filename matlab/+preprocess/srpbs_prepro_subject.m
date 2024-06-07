function matlabbatch = srpbs_prepro_subject(dataDir, run)

% matlabbatch = srpbs_prepro_subject(dataDir, run)
% Performs / sets up a preprocessing pipeline.
%
% Inputs:
%       dataDir: Path to subject data folder (must contain anat/ and
%                 func/ subfolders with anatomical and volume data)
%                 Note that func data need to end on .nii (change names if
%                 needed).
%       run:      if 0 -> just create struct [default]
%                 if 1 -> run directly
%                 if 2 -> run interactively (open Batch editor with analysis)
%
% Outputs:
%       matlabbatch: batch containing information about analysis.
%
% Created: Apr 2024, Jakob Heinzle, Translational Neuromodeling Unit, IBT
% University and ETH Zurich

if nargin < 2
    run = 0;
end

currentpath = pwd;
cd(dataDir);
dataDir = pwd;
cd(currentpath);


% Check whether data folder exists.
if ~exist(dataDir, 'dir')
    error('Could not find specified data folder');
end
% Check whether subfolders exist.
struct_dir = fullfile(dataDir, 'anat');
if ~exist(struct_dir, 'dir')
    error('Could not find anat/ subfolder');
end
func_dir = fullfile(dataDir, 'func');
if ~exist(func_dir, 'dir')
    error('Could not find func/ subfolder');
end

% Find out where the Tissue Probability Maps (TPMs) of SPM are located
% on your computer.
tpm_dir = fullfile(fileparts(which('spm')), 'tpm');

matlabbatch = {};
%--------------------------------------------------------------------------
% Slice timing correction
matlabbatch{1}.spm.temporal.st.scans{1} = cellstr(spm_select('ExtFPList',func_dir,sprintf('^vol.*.nii'),Inf));
matlabbatch{1}.spm.temporal.st.nslices = 40;
matlabbatch{1}.spm.temporal.st.tr = 2.5;
matlabbatch{1}.spm.temporal.st.ta = 2.5-(2.5/40);%ta=TR-(TR/nslices)
matlabbatch{1}.spm.temporal.st.so = 1:40; % bottom-to-top, 40:-1:1 if top-to-bottom
matlabbatch{1}.spm.temporal.st.refslice = 20; % reference slice, typically nslices/2
matlabbatch{1}.spm.temporal.st.prefix = 'a';
%--------------------------------------------------------------------------
% Realign: motion correction and align two fMRI runs
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
%--------------------------------------------------------------------------
% Normalisation (skstruct -> standard)
matlabbatch{3}.spm.spatial.preproc.channel.vols = {fullfile(struct_dir, 'defaced_mprage.nii')};
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {fullfile(tpm_dir,'TPM.nii,1')};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {fullfile(tpm_dir,'TPM.nii,2')};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {fullfile(tpm_dir,'TPM.nii,3')};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {fullfile(tpm_dir,'TPM.nii,4')};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {fullfile(tpm_dir,'TPM.nii,5')};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {fullfile(tpm_dir,'TPM.nii,6')};
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [1 1];
%--------------------------------------------------------------------------
% Coregistration (mean functional -> skstruct [bias corrected])
matlabbatch{4}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{4}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{4}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
%--------------------------------------------------------------------------
% Write functionals to standard space
matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = ...
    [-78 -112 -70
    78 76 85];
matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';
%--------------------------------------------------------------------------
% Smooth functionals
matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{6}.spm.spatial.smooth.fwhm = [8 8 8]; % for dataset1 authors use 6mm
matlabbatch{6}.spm.spatial.smooth.dtype = 0;
matlabbatch{6}.spm.spatial.smooth.im = 0;
matlabbatch{6}.spm.spatial.smooth.prefix = 's8';
%--------------------------------------------------------------------------
% Write [bias corrected] structural to standard space
matlabbatch{7}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{7}.spm.spatial.normalise.write.woptions.bb = ...
    [-78 -112 -70
    78 76 85];
matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{7}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{7}.spm.spatial.normalise.write.woptions.prefix = 'w';
%--------------------------------------------------------------------------

if run == 2
    spm_jobman('initcfg');
    spm_jobman('interactive',matlabbatch);
elseif run == 1
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end