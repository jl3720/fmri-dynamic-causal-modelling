function srpbs_glm_subject(dataDir)

% This script demonstrates how to perform a GLM analysis for a subject from
% the SRPBS Multidisorder MRI dataset. SPM needs to be installed. The
% analysis is done for one subject.

%-----------------------------------------------------------------------
% Created: Apr 2024, Imre Kertesz, Translational Neuromodeling Unit,
% University and ETH Zurich
%-----------------------------------------------------------------------
%subject_choice = 'sub-1410';
% define where the code is located
%[baseDir, ~] = fileparts(mfilename('fullpath'));
%baseDir = 'D:\zurich_spring24\tn\project4\SRPBS_OPEN\data\';
% path to SPM.mat file (GLM result)
firstlevelDir   = fullfile(dataDir,'glm');
disp(firstlevelDir)
% get all regions of interest
preproc_vol = dir(fullfile(dataDir,'func','s8wavol_*'));

% file containing regressors for movement
movement_reg = fullfile(dataDir,'func','rp_avol_001.txt');

for i = length(preproc_vol):-1:1
    preproc_paths{i} = sprintf('%s,1',fullfile(preproc_vol(i).folder,preproc_vol(i).name));
end

preproc_paths = preproc_paths';


matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(firstlevelDir);
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs'; % units for design
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.5;       % repetition time
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;    % microtime resolution
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;    % microtime onset

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = preproc_paths; % path to all fMRI scans for this session

matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(movement_reg);
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128; % high-pass filter cutoff
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8; % masking threshold
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)'; % serial correlations
matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(firstlevelDir,'SPM.mat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(firstlevelDir,'SPM.mat'));
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'mean'; % name of F-contrast
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [0 0 0 0 0 0 1]; % using 7th regressor (mean)
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1; % delete existing contrasts -> yes

spm_jobman('run',matlabbatch);
end
