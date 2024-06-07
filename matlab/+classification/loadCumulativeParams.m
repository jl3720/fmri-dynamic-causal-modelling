function params = loadCumulativeParams(extra, paramsDir)

    if ~exist("paramsDir", "var")
        paramsDir = fullfile("/cluster/scratch/spruthi/project4/connectivity_features/schizophrenia/");
    end

    if extra == "standard"
        load(fullfile(paramsDir, "filtered_features_rDCM.mat"), "filtered_features");
    elseif extra == "reduced_noise"
        load(fullfile(paramsDir, "filtered_features_rDCM_reduced_noise.mat"), "filtered_features");
    elseif extra == "reduced_connectivity"
        load(fullfile(paramsDir, "filtered_features_reduced_connectivity.mat"), "filtered_features");
    else
        disp("Invalid `extra` argument");
        return;
    end

    params = filtered_features.';
    params(8, :) = [];  % Remove subject-0034, 8th in subjects list
end