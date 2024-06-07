% Collate estimates from all different locations into loadable .mat files.
% I.e. for each rDCM configuration, have feature matrix X (num_samples x num_features)
% Where each row is a flattened vector of A matrix (also .* z for sparse rDCM)

ROOT_DIR = "../"  % Change this to your root directory
DATA_DIR = fullfile(ROOT_DIR, "SRPBS_OPEN/data")
EST_DIR = fullfile(ROOT_DIR, "estimates")
ADJ_MAT_PATH = fullfile(DATA_DIR, "Brainnetome2016", "StructConn.mat")

load(ADJ_MAT_PATH, "adjacency_matrix");  % needed for masking

if ~isdir(DATA_DIR)
    fprintf("%s not found", DATA_DIR)
end
if ~isdir(EST_DIR)
    mkdir(EST_DIR)
    disp("Created EST_DIR")
end

% 1. Collate training sparse schizophrenia rDCM estimates
[train_schizo_positive, train_schizo_control] = classification.getSubjectList("schizophrenia", "train");

X_025 = [];
y_025 = [];
X_050 = [];
y_050 = [];

for subject = [train_schizo_positive, train_schizo_control]

    % 0.25 sparsity
    output_025_file = strcat(subject, "_inv_mFz_", num2str(int64(0.25*100)), ".h5");
    output_path = fullfile(DATA_DIR, subject, "sparseInversion", output_025_file)
    [params, success] = classification.loadSparseParams(output_path);
    if success
        X_025 = [X_025; params];
        if ismember(subject, train_schizo_positive)
            y_025 = [y_025; 1];
        else
            y_025 = [y_025; 0];
        end
    end

    % 0.50 sparsity
    output_050_file = strcat(subject, "_inv_mFz_", num2str(int64(0.50*100)), ".h5")
    output_path = fullfile(DATA_DIR, subject, "sparseInversion", output_050_file)
    [params, success] = classification.loadSparseParams(output_path);
    if success
        X_050 = [X_050; params];
        if ismember(subject, train_schizo_positive)
            y_050 = [y_050; 1];
        else
            y_050 = [y_050; 0];
        end
    end
end
% Save to .mat files
savedir = fullfile(EST_DIR, "schizophrenia", "train", "sparse")
if ~isdir(savedir)
    mkdir(savedir)
end

X = X_025; y = y_025;
save(fullfile(savedir, "standard_25.mat"), "X", "y");

X = X_050; y = y_050;
save(fullfile(savedir, "standard_50.mat"), "X", "y");

% 2. Collate (training) sparse pain rDCM estimates (no test for pain)
[train_pain_positive, train_pain_control] = classification.getSubjectList("pain", "train");

X_025 = [];
y_025 = [];
X_050 = [];
y_050 = [];

for subject = [train_pain_positive, train_pain_control]

    % 0.25 sparsity
    output_025_file = strcat(subject, "_inv_mFz_", num2str(int64(0.25*100)), ".h5");
    output_path = fullfile(DATA_DIR, subject, "sparseInversion", output_025_file)
    [params, success] = classification.loadSparseParams(output_path);
    if success
        X_025 = [X_025; params];
        if ismember(subject, train_pain_positive)
            y_025 = [y_025; 1];
        else
            y_025 = [y_025; 0];
        end
    end

    % 0.50 sparsity
    output_050_file = strcat(subject, "_inv_mFz_", num2str(int64(0.50*100)), ".h5")
    output_path = fullfile(DATA_DIR, subject, "sparseInversion", output_050_file)
    [params, success] = classification.loadSparseParams(output_path);
    if success
        X_050 = [X_050; params];
        if ismember(subject, train_pain_positive)
            y_050 = [y_050; 1];
        else
            y_050 = [y_050; 0];
        end
    end
end
% Save to .mat files
savedir = fullfile(EST_DIR, "pain", "train", "sparse")
if ~isdir(savedir)
    mkdir(savedir)
end

X = X_025; y = y_025;
save(fullfile(savedir, "standard_25.mat"), "X", "y");

X = X_050; y = y_050;
save(fullfile(savedir, "standard_50.mat"), "X", "y");

% 3. Dense, pain

[train_pain_positive, train_pain_control] = classification.getSubjectList("pain", "train");

X = [];
y = [];

for subject = [train_pain_positive, train_pain_control]

    output_025_file = strcat(subject, "_inv_mFz_", num2str(int64(0.25*100)), ".h5")
    output_path = fullfile(DATA_DIR, subject, "sparseInversion", output_025_file)
    [params, success] = classification.loadSparseParams(output_path, 1, adjacency_matrix);
    if success
        X = [X; params];
        if ismember(subject, train_pain_positive)
            y = [y; 1];
        else
            y = [y; 0];
        end
    end
end

% Save to .mat files
savedir = fullfile(EST_DIR, "pain", "train", "dense")
if ~isdir(savedir)
    mkdir(savedir)
end

save(fullfile(savedir, "standard.mat"), "X", "y");

% 5. Training, dense, schizophrenia
X = [];
y = [];
feats_dir = fullfile(ROOT_DIR, "connectivity_features/schizophrenia")

% reduced_noise
load(fullfile(feats_dir, "filtered_features_rDCM_reduced_noise.mat"), "filtered_features");
X = filtered_features.';
y = [zeros(13, 1); ones(13, 1)];  % 13 controls, 13 schizophrenics

X(8, :) = [];  % Remove subject-0034, 8th in subjects list
y(8) = [];

savedir = fullfile(EST_DIR, "schizophrenia", "train", "dense")
if ~isdir(savedir)
    mkdir(savedir)
end
save(fullfile(savedir, "reduced_noise.mat"), "X", "y");

% reduced_connectivity
load(fullfile(feats_dir, "filtered_features_reduced_connectivity.mat"), "filtered_features");
X = filtered_features.';
y = [zeros(13, 1); ones(13, 1)];  % 13 controls, 13 schizophrenics

X(8, :) = [];  % Remove subject-0034, 8th in subjects list
y(8) = [];

save(fullfile(savedir, "reduced_connectivity.mat"), "X", "y");

% standard
load(fullfile(feats_dir, "filtered_features_rDCM.mat"), "filtered_features");
X = filtered_features.';
y = [zeros(13, 1); ones(13, 1)];  % 13 controls, 13 schizophrenics

X(8, :) = [];  % Remove subject-0034, 8th in subjects list
y(8) = [];

save(fullfile(savedir, "standard.mat"), "X", "y");

% 6. Testing, dense, schizophrenia
[test_schizo_positive, test_schizo_control] = classification.getSubjectList("schizophrenia", "test");

X = [];
y = [];

test_dir = fullfile(ROOT_DIR, "all_outputs_oos")

% standard
% Load features and labels for controls
negative_dir = fullfile(test_dir, "outputs_controls");
mats = dir(fullfile(negative_dir, '*.mat')); 

X_test = [];
y_test = [];
for q = 1:length(mats) 
    output_path = fullfile(negative_dir, mats(q).name)
    [params, success] = classification.loadParams(output_path, adjacency_matrix);

    if success
        X_test = [X_test; params];
        y_test = [y_test; 0];
    end
end

% Repeat for schizophrenic patients
positive_dir = fullfile(test_dir, "outputs_schizos");
mats = dir(fullfile(negative_dir, '*.mat'));
for q = 1:length(mats) 
    output_path = fullfile(negative_dir, mats(q).name)
    [params, success] = classification.loadParams(output_path, adjacency_matrix);

    if success
        X_test = [X_test; params];
        y_test = [y_test; 1];
    end
end

X = X_test;
y = y_test;

savedir = fullfile(EST_DIR, "schizophrenia", "test", "dense")
if ~isdir(savedir)
    mkdir(savedir)
end

save(fullfile(savedir, "standard.mat"), "X", "y");

% reduced_connectivity
% Load features and labels for controls
negative_dir = fullfile(test_dir, "outputs_controls_reduced");
mats = dir(fullfile(negative_dir, '*.mat')); 

X_test = [];
y_test = [];
for q = 1:length(mats) 
    output_path = fullfile(negative_dir, mats(q).name)
    [params, success] = classification.loadParams(output_path, adjacency_matrix, 1);

    if success
        X_test = [X_test; params];
        y_test = [y_test; 0];
    end
end

% Repeat for schizophrenic patients
positive_dir = fullfile(test_dir, "outputs_schizos_reduced");
mats = dir(fullfile(negative_dir, '*.mat'));
for q = 1:length(mats) 
    output_path = fullfile(negative_dir, mats(q).name)
    [params, success] = classification.loadParams(output_path, adjacency_matrix, 1);

    if success
        X_test = [X_test; params];
        y_test = [y_test; 1];
    end
end

X = X_test;
y = y_test;

save(fullfile(savedir, "reduced_connectivity.mat"), "X", "y");

% 7. Testing, sparse, schizophrenia

[test_schizo_positive, test_schizo_control] = classification.getSubjectList("schizophrenia", "test");

X_025 = [];
y_025 = [];
X_050 = [];
y_050 = [];

test_dir = fullfile(ROOT_DIR, "oos")
negative_dir = fullfile(test_dir, "oos-controls")
positive_dir = fullfile(test_dir, "oos-schizos")

for subject = [test_schizo_positive, test_schizo_control]
    if ismember(subject, test_schizo_positive)
        label = 1;
        tmp_dir = positive_dir
    else
        label = 0;
        tmp_dir = negative_dir
    end

    % 0.25 sparsity
    output_025_file = strcat(subject, "_inv_mFz_", num2str(int64(0.25*100)), ".h5");
    output_path = fullfile(tmp_dir, subject, "sparseInversion", output_025_file)
    [params, success] = classification.loadSparseParams(output_path);
    if success
        X_025 = [X_025; params];
        y_025 = [y_025; label];
    end

    % 0.50 sparsity
    output_050_file = strcat(subject, "_inv_mFz_", num2str(int64(0.50*100)), ".h5")
    output_path = fullfile(tmp_dir, subject, "sparseInversion", output_050_file)
    [params, success] = classification.loadSparseParams(output_path);
    if success
        X_050 = [X_050; params];
        y_050 = [y_050; label];
    end
end
% Save to .mat files
savedir = fullfile(EST_DIR, "schizophrenia", "test", "sparse")
if ~isdir(savedir)
    mkdir(savedir)
end

X = X_025; y = y_025;
save(fullfile(savedir, "standard_25.mat"), "X", "y");

X = X_050; y = y_050;
save(fullfile(savedir, "standard_50.mat"), "X", "y");

fprintf("Successfully saved to %s.\n", EST_DIR)