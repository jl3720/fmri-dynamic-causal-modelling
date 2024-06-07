function [params, success] = loadParams(output_path, adj_mat, reduced_connectivity)
    % Helper func to load params for a subject

    % dcm_path = fullfile(baseDir, subject, "DCM.mat"
    % load(dcm_path, "DCM");
    if ~exist("reduced_connectivity", "var")
        reduced_connectivity = 0;
    end

    success = 0;
    params = zeros(1);
    % output_path = fullfile(baseDir, subject, "rdcm_output.mat")
    if exist(output_path, 'file') == 2
        load(output_path, "output");
        success = 1;
    else
        fprintf("%s not found", output_path)
        return
    end
    
    A = output.Ep.A;
    tmp = A;
    if ~reduced_connectivity  % reduced_connectivity means already removed
        adj_mat(logical(eye(size(adj_mat)))) = 0;  % Make adj_mat diagonals zero
        tmp = A(logical(adj_mat));  % Remove diagonals and non connections
    end

    params = reshape(tmp, 1, []);  % Make row vector
    % disp(size(params))  % debug

end