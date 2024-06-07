function plotExplainedVar(score, explained)
    % Calculate the explained variance by the selected principal components
    cumulative_explained = cumsum(explained);

    % Plot the explained variance for the first r principal components
    fig1 = figure();
    r_max = min(size(score)); % rank of Eigenvector basis
    plot(1:r_max, cumulative_explained(1:r_max), 'b-o', 'LineWidth', 2);
    xlabel('Number of Principal Components (r)');
    ylabel('Cumulative Explained Variance (%)');
    title('Variance Explained by Principal Components');
    grid on;
    hold on;
    yline(90, 'r--', 'LineWidth', 1.5, 'Label', '90% Variance Explained', 'LabelHorizontalAlignment', 'left');
    hold off;
    saveas(fig1, "explained_variance.png")
end