function k_means(collated_data_path)
    % Run k-means clustering on the generative embeddings (parameter mean estimates)

    % First perform dimensionality reduction on connectivity parameters with PCA
    % Then run k-means with k=2.

    % Args:
    %   collated_data_path - Path to the .mat file containing the collated (X, y) data

    load(collated_data_path, "X", "y");
    k = 2;  % Number of clusters

    disp("all params size: "); disp(size(X));
    disp("y size: "); disp(size(y));
    disp("")
    disp("################################")
    disp("")    

    % Perform dimensionality reduction
    [coeff, score, latent, tsquared, explained] = pca(X);

    % Select the top r principal components
    r = 2;
    if r > min(size(X))
        disp("r must be smaller than the rank of the data matrix")
        return
    end
    disp(size(score))
    X_reduced = score(:, 1:r);

    % Calculate the explained variance by the selected principal components
    explainedVar = sum(explained(1:r));

    % Display the explained variance
    fprintf('The top %d principal components explain %.2f%% of the variance.\n', r, explainedVar);

    % Perform k-means clustering for 2D space.
    [idx, C, sumd, D] = kmeans(X_reduced, k)  % k clusters
    idx = idx - 1;

    % Plot clustered data, ONLY FOR r=2
    fig1 = figure(); hold on;
    for i=0:k-1
        % Predictions
        plot(X_reduced(idx==i, 1), X_reduced(idx==i, 2), 'o', 'MarkerSize', 13, ...
        'DisplayName', "PredictedCluster " + num2str(i));  % belong to ith cluster
    end
    % Plot ground truth labels
    for i=0:1
        plot(X_reduced(y==i, 1), X_reduced(y==i, 2), '.', 'MarkerSize', 12,...
        'DisplayName', "TrueLabel " + num2str(i))
    end
    plot(C(:, 1), C(:, 2), 'kx', 'MarkerSize', 15, 'LineWidth', 2.5, 'DisplayName', "Cluster Centers")
    legend('boxoff', 'Location', 'southwest', 'Orientation', 'vertical', 'NumColumns', 2)
    hold off;
    title("k-means after reducing to 2-dims, k=" + num2str(k))
    xlabel("1st Principal Component")
    ylabel("2nd Principal Component")
    saveas(fig1, num2str(k) + "-means_2D.png")

    % Perform k-means clustering for 3D space.
    r = 3; % Allow 3 dim rep, k still same
    X_reduced = score(:, 1:r);

    % Calculate the explained variance by the selected principal components
    explainedVar = sum(explained(1:r));

    % Display the explained variance
    fprintf('The top %d principal components explain %.2f%% of the variance.\n', r, explainedVar);

    [idx, C, sumd, D] = kmeans(X_reduced, k)  % k clusters
    idx = idx - 1;

    % Plot clustered data, ONLY FOR r=3
    fig2 = figure(); hold on;
    for i=0:k-1
        % Predictions
        plot3(X_reduced(idx==i, 1), X_reduced(idx==i, 2), X_reduced(idx==i, 3), 'o', 'MarkerSize', 13, ...
        'DisplayName', "PredictedCluster " + num2str(i));  % belong to ith cluster
    end
    % Plot ground truth
    for i=0:1
        plot3(X_reduced(y==i, 1), X_reduced(y==i, 2), X_reduced(y==i, 3), '.', 'MarkerSize', 12,...
        'DisplayName', "TrueLabel " + num2str(i))
    end
    plot3(C(:, 1), C(:, 2), C(:, 3), 'kx', 'MarkerSize', 15, 'LineWidth', 2.5, 'DisplayName', "Cluster Centers")
    legend('boxoff', 'Location', 'southwest', 'Orientation', 'vertical', 'NumColumns', 2)
    hold off;
    title("k-means after reducing to 3-dims, k=" + num2str(k))
    xlabel("1st Principal Component")
    ylabel("2nd Principal Component")
    zlabel("3rd Principal Component")
    view(3)
    saveas(fig2, num2str(k) + "-means_3D.png")
    savefig(fig2, num2str(k) + "-means_3D.fig")
end