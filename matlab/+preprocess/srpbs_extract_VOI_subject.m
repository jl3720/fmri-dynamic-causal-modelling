function srpbs_extract_VOI_subject(dataDir)

    % The script demonstrates how to extract time series from a whole-brain
    % parcellation (here: the Brainnetome atlas). SPM needs to be installed.
    % The time series extraction is done for one subject.
    % 
    % Input:
    % 
    % Output:
    % 
    
    % ----------------------------------------------------------------------
    %
    %
    % Author: Stefan Fraessle, TNU, UZH & ETHZ - 2022
    % Copyright 2022 by Stefan Fraessle <stefan_fraessle@gmx.de>
    %
    % Modified: Imre Kertesz, TNU, UZH & ETHZ - Apr 2024
    %
    % Licensed under GNU General Public License 3.0 or later.
    % Some rights reserved. See COPYING, AUTHORS.
    % 
    % ----------------------------------------------------------------------
    
    %subject_choice = 'sub-1410';
    % define where the code is located
    %[baseDir, ~] = fileparts(mfilename('fullpath'));
    %baseDir = 'D:\zurich_spring24\tn\project4\SRPBS_OPEN\data\';
    % path to SPM.mat file (GLM result)
    firstlevelDir   = fullfile(dataDir,'glm');
    disp(firstlevelDir)
    
    % path to Brainnetome folder
    [baseDir,~] = fileparts(dataDir);
    parcelDir       = fullfile(baseDir,'Brainnetome2016');
    
    % add the path to SPM ( PLEASE ADAPT THIS )
    %addpath('/Users/stefan/Documents/SPM/spm12');
    
    % specify the effect of interest
    EoI_nr = NaN;
    
    % get all regions of interest
    ROI_names = dir(fullfile(parcelDir,'all_masks','*.nii'));
    
    
    % time series folder
    VOI_folder = fullfile(firstlevelDir,'VOI');
    
    % check whether folder exists (and if so, delete existing files)
    if ( ~exist(VOI_folder,'dir') )
        mkdir(VOI_folder)
    else
        delete(fullfile(VOI_folder,'VOI*.mat'))
        delete(fullfile(VOI_folder,'VOI*.mat'))
    end
            
    % choose which ROIs to extract
    ROI_analyze = 1:length(ROI_names);
    %clear matlabbatch
    %matlabbatch = {};
    % extract the time series for each region of interest
    for number_of_regions = ROI_analyze
        disp(number_of_regions)
        % define the path where the SPM.mat can be found
        matlabbatch{1}.spm.util.voi.spmmat = cellstr(fullfile(firstlevelDir,'SPM.mat'));
    
        % choose an adjustment of the time series (effects of interest)
        matlabbatch{1}.spm.util.voi.adjust = EoI_nr;
    
        % choose session number
        matlabbatch{1}.spm.util.voi.session = 1;
    
        % set the name of the VOI
        matlabbatch{1}.spm.util.voi.name = ROI_names(number_of_regions).name(1:end-4);
    
        % specify which contrast to use (not doing anything here, because we
        % extract signal from all voxels in the respective mask anyway)
        matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
    
        % specify conjunction (not doing anything here)
        matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
    
        % specify the threshold correction
        matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
    
        % specify the threshold
        matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 1;
    
        % no extent threhsold
        matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
    
        % no SPM mask
        matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    
    
        % define the mask filename
        f = fullfile(parcelDir,'all_masks',ROI_names(number_of_regions).name);
    
        % asign the mask filename
        matlabbatch{1}.spm.util.voi.roi{2}.mask.image = cellstr(f);
    
        % threshold the mask
        matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
    
    
        % intersection of activation and sphere
        matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
    
        % specify input and output filenames
        Vi = [cellstr(fullfile(firstlevelDir,'mask.nii')); cellstr(fullfile(parcelDir,'all_masks',ROI_names(number_of_regions).name))];
        Vo = fullfile(firstlevelDir,'output.nii');
        if isstring(Vo)
            Vo = convertStringsToChars(Vo);
            disp("Converted")
    
        % compute the intersection
        Vo = spm_imcalc(Vi, Vo, '(i1.*i2) ~= 0 & isfinite(i1.*i2)');
    
        % load the output file to check whether there are voxels in VoI
        intersection = spm_read_vols(Vo);
        %disp(intersection)
    
        % run the batch and extract the time series (in case there is data)
        if ( any(intersection(:) ~= 0) )
            try
                %spm_jobman('initcfg');
                spm_jobman('run',matlabbatch);
            catch
                fprintf('\n WARNING: MODULE COULD NOT RUN\n\n')
            end
        else
            fprintf('\n WARNING: NOT ENOUGH VOXELS FOUND IN ROI\n\n')
            continue
        end
    
        % clear the matlabbatch
        clear matlabbatch
    
    end
    
    % move the extracted time series to the results folder
    movefile(fullfile(firstlevelDir,'VOI*.mat'),VOI_folder)
    
    % delete the remaining files
    delete(fullfile(firstlevelDir,'VOI*'))
    
    end