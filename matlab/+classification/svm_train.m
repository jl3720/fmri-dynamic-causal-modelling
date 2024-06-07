function svm_train(disease, sparse, latent_dim, extra, p0, rootDir)
    % Perform dimensionality reduction 

    % Args:
    %   disease -       Either "pain" or "schizophrenia"
    %   sparse -        Boolean flag to use sparse inversion outputs
    %   latent_dim -    Dimension to reduce parameter features to. Number of
    %                   Principal Components to take.
    %   extra -         (Optional) String {"standard", "reduced_noise", "reduced_connectivity"},
    %                   extra options for vanilla rDCM
    %   p0 -            (Optional) {"low" (0.25), "high" (0.5)}. Sparsity prior for s-rDCM. 
    %   rootDir -       (Optional) Path to root of repository. Defaults to

    % Set up logs and handle optional args
    if not(isdir("logs/training"))
        mkdir("logs", "training")
    end

    if ~exist('rootDir', 'var')
        rootDir = '../'
    end
    if ~exist('extra', 'var')
        extra = "standard";
    end

    model_name = sprintf("SVMModel_%s_%i_%i", disease, sparse, latent_dim);

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

    diary("logs/training/" + model_name + ".txt")

    if extra == "reduced_connectivity"
        reduced_connectivity = 1;
    else
        reduced_connectivity = 0;
    end

    EST_DIR = fullfile(rootDir, "estimates");
    SPLIT = "train";
    
    if sparse
        feats_dir = fullfile(EST_DIR, disease, SPLIT, "sparse");
        % filename = sprintf("%s_%i.mat", extra, int64(p0*100));
        filename = extra + "_" + num2str(p0*100) + ".mat";
    else
        feats_dir = fullfile(EST_DIR, disease, SPLIT, "dense");
        filename = extra + ".mat";
    end

    % Load features and labels
    try
        load(fullfile(feats_dir, filename), "X", "y");
    catch
        fprintf("Failed to load %s\n", fullfile(feats_dir, filename))
        return
    end
    fprintf("X size: %i, %i\n", size(X))
    fprintf("y size: %i, %i\n", size(y))

    X = normalize(X, 1);  % Normalize each feature separately, prior to PCA
    X(isnan(X)) = 0;  % Replace NaNs with 0, rows with 0 std will have NaNs

    % Create train, crossval, test split
    % [X_train, X_val, X_test, y_train, y_val, y_test] = classification.createSplits(X, y);

    disp("Performing dimensionality reduction")
    % Perform dimensionality reduction on each split
    [coeff, score, latent, tsquared, explained] = pca(X);

    % Select the top r principal components
    r = latent_dim;
    if r > min(size(X))
        disp("r must be smaller than the rank of the data matrix")
        return
    end
    X = score(:, 1:r);
    disp(size(X))
    fprintf("Explained variance: %f %%\n", sum(explained(1:r)))
    save(fullfile(feats_dir, "pca" + model_name + ".mat"), "coeff", "score", "explained")

    % For now, allow data leak and do dim-red first before splits
    % [X_train, X_val, X_test, y_train, y_val, y_test] = classification.createSplits(X, y);
    hpartitions = cvpartition(length(y), 'HoldOut', 0.2);
    trainIdx = training(hpartitions);
    testIdx = test(hpartitions);
    X_train = X(trainIdx, :);
    y_train = y(trainIdx, :);
    X_test = X(testIdx, :);
    y_test = y(testIdx, :);

    % Fit SVM
    % Model = fitcsvm(X_train, y_train, 'Standardize', true)
    Model = fitcsvm(X_train, y_train)

    % Save model

    if ~isdir("checkpoints")
        mkdir("checkpoints")
    end

    try
        save("checkpoints/" + model_name + ".mat", "Model")
    catch
        disp("Failed saving SVMModel")
    end

    % Training prediction
    fprintf("Train size: %i\n", hpartitions.TrainSize)
    train_preds = predict(Model, X_train);
    train_acc = sum(train_preds == y_train) ./ length(y_train)
    disp(train_preds)
    disp(y_train)

    % Cross-Val predictions
    fprintf("Cross-val size: %i\n", hpartitions.TestSize)
    crossval_preds = predict(Model, X_test);
    crossval_acc = sum(crossval_preds == y_test) ./ length(y_test)
    disp(crossval_preds)
    disp(y_test)

    try
        % Uncomment to plot explained variance as r varies
        classification.plotExplainedVar(score, explained)
    catch
        disp("Failed to plot explained variance")
    end
    diary off
end