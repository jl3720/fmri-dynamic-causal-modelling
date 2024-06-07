function model_inversion(subject, dataDir)
    if ~exist('dataDir', 'var')
        dataDir = '/cluster/scratch/spruthi/project4/SRPBS_OPEN/data'
    end
    % Load DCM specification 
    dcm_path = fullfile(dataDir, subject, 'DCM.mat')
    load(dcm_path, 'DCM');

    options = DCM.options;
    options.type = 'r';  % real data

    output = tapas_rdcm_estimate(DCM, options.type, options, 1)  % original rDCM variant
    save(fullfile(dataDir, subject, 'rdcm_output.mat'), 'output')
end