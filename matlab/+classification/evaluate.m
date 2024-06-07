function [cv_acc, test_acc] = evaluate(sparse, latent_dim, extra, p0, rootDir)
    % Perform testing on held out schizophrenia dataset

    % Args:
    %   sparse -        Boolean flag to use sparse inversion outputs
    %   latent_dim -    Dimension to reduce parameter features to. Number of
    %                   Principal Components to take.
    %   extra -         (Optional) String {"standard", "reduced_noise", "reduced_connectivity"},
    %                   extra options for vanilla rDCM
    %   p0 -            (Optional) {"low" (0.25), "high" (0.5)}. Sparsity prior for s-rDCM. 
    %   rootDir -       (Optional) Path to root of repository. Defaults to
    if ~exist('rootDir', 'var')
        rootDir = '../'  % change to ../
    end
    % Set up logs and handle optional args
    if not(isdir("logs/testing"))
        mkdir("logs", "testing")
    end

    if ~exist('extra', 'var')
        extra = "standard";
    end
    disease = "schizophrenia";

    model_name = sprintf("SVMModel_%s_%i_%i", disease, sparse, latent_dim);
    disp("model_name" + model_name)

    if disease == "schizophrenia" & not(sparse)
        model_name = model_name + "_" + extra;
    end
    if exist("p0", "var") & sparse
        if p0 == "low"
            p0 = 0.25;
        else
            p0 = 0.5;
        end
        model_name = model_name + "_" + num2str(p0*100);
    end

    diary("logs/testing/" + model_name + ".txt")

    if extra == "reduced_connectivity"
        reduced_connectivity = 1;
    else
        reduced_connectivity = 0;
    end

    model_path = fullfile("checkpoints", model_name + ".mat");
    load(model_path, "Model");
    latent_dim = length(Model.Beta);
    disp("Latent dim: " + num2str(latent_dim))

    % Load test features and labels
    EST_DIR = fullfile(rootDir, "estimates");
    SPLIT = "test";
    
    if sparse
        % Features and labels
        feats_dir = fullfile(EST_DIR, disease, SPLIT, "sparse");
        filename = extra + "_" + num2str(p0*100) + ".mat";

        % PCA components
        pca_dir = fullfile(EST_DIR, disease, "train", "sparse");
    else
        feats_dir = fullfile(EST_DIR, disease, SPLIT, "dense");
        filename = extra + ".mat";

        pca_dir = fullfile(EST_DIR, disease, "train", "dense");
    end
    pca_filename = "pca" + model_name + ".mat";

    % Load features and labels
    try
        load(fullfile(feats_dir, filename), "X", "y");
        load(fullfile(pca_dir, pca_filename), "coeff");
    catch
        fprintf("Failed to load %s\n", fullfile(feats_dir, filename))
        return
    end
    fprintf("X_test size: %i, %i\n", size(X))
    fprintf("y_test size: %i, %i\n", size(y))    
    X_test = X;
    y_test = y;
    % Preprocess data same way as training: Normalization + PCA

    X_test = normalize(X_test, 1);  % Normalize each feature separately, prior to PCA
    X_test(isnan(X_test)) = 0;  % Replace NaNs with 0, rows with 0 std will have NaNs

    % Load principal components
    X_test = X_test * coeff(:, 1:latent_dim);  % Project onto top latent_dim components

    % Test predictions
    test_preds = predict(Model, X_test);
    cm = confusionmat(y_test, test_preds)

    specificity = cm(1, 1) ./ sum(cm(1, :))
    sensitivity = cm(2, 2) ./ sum(cm(2, :))
    ppv = cm(2, 2) ./ sum(cm(:, 2))
    npv = cm(1, 1) ./ sum(cm(:, 1))
    
    test_acc = sum(test_preds == y_test) ./ length(y_test)
    % disp(test_preds)
    % disp(y_test)

    fprintf('Number of test samples: %d\n', length(test_preds))
    fprintf('Specificity: %f\n', specificity)
    fprintf('Sensitivity: %f\n', sensitivity)
    fprintf('Positive Predictive Value (PPV): %f\n', ppv)
    fprintf('Negative Predictive Value (NPV): %f\n', npv)
    fprintf("Test accuracy: %f\n", test_acc)

    diary off

    try
        % Plot confusion matrix
        figure;
        confusionchart(cm, {'Control', 'Schizophrenia'}, 'Title', 'Confusion Matrix for Test Data');

        if ~exist("figures", "dir")
            mkdir("figures")
        end
        
        savepath = fullfile("figures", model_name + "_confusion_matrix.png");
        saveas(gcf, savepath)
    catch
        disp("Couldn't create confusion matrix figure")
    end