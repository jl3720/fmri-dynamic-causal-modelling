function sprbs_preprocess_pipeline(subject_choice,run,data_storage_structure)
%Run the entire preprocessing pipeline given in matlab/preprocess
%for 1 subject

%subject_choice = 'sub-0001';
%run = 2 interactive, otherwise 0 - struct, 1 - direct run
%data_storage_structure = 1;
% 0 => data is stored in current directory (where the code is)
% 1 => data is stored as in spruthi's gitlab branch
% <parent(current_folder)>/SRPBS_OPEN/data/

%%%%%%%%
%curDir = pwd;
startup;
disp("Yes")
%subclist = ["sub-0670", "sub-0671", "sub-0672", "sub-0673", "sub-0674", "sub-0675", "sub-0676", "sub-0677", "sub-0678", "sub-0679", "sub-0680", "sub-0681", "sub-0682", "sub-0683", "sub-0684", "sub-0685", "sub-0686", "sub-0687", "sub-0688", "sub-0689", "sub-0690"]
%subclist = ["sub-0715", "sub-0716", "sub-0717", "sub-0718", "sub-0719", "sub-0720", "sub-0721", "sub-0722", "sub-0723", "sub-0724", "sub-0725", "sub-0726", "sub-0727", "sub-0728", "sub-0729", "sub-0730", "sub-0731", "sub-0732", "sub-0733", "sub-0734", "sub-0735"]
if data_storage_structure == 1
    [ParentCurDir, ~] = fileparts(pwd);
    baseDir = fullfile(ParentCurDir,'SRPBS_OPEN','data');
else
    baseDir = curDir;
end

for sub = 1:length(subject_choice)
    disp(subject_choice{sub})
    dataDir = fullfile(baseDir,subject_choice{sub})

    preprocess.srpbs_prepro_subject(dataDir,run) % Basic Preprocessing
    preprocess.srpbs_glm_subject(dataDir) % GLM based Preprocessing
    preprocess.srpbs_extract_VOI_subject(dataDir) % Extracting timeseries

    dcm.sprbs_construct_dcm(baseDir,subject_choice{sub}) % Constructing a DCM based on Tapas
    cd 'D:\zurich_spring24\tn\project4\matlab'
end
%end

%[status,_,_] = rmdir(fullfile(dataDir, 'anat'), 's');
%[status,_,_] = rmdir(fullfile(dataDir, 'func'), 's');
%[status,_,_] = rmdir(fullfile(dataDir, 'rsfmri'), 's');

disp('Preprocessing Done')
end


