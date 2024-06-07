function [params, success] = loadSparseParams(output_path, dense, adj_mat)
    % Helper func to load params for a subject
    % Args:
    %   output_path: Path to the saved output .h5 file
    %   dense: (Optional) Whether to load dense or sparse params
    %           defaults to 0 (sparse)
    %   adj_mat: (Optional) Adjacency matrix to mask the params, required for dense
    % Returns:
    params = zeros(1); success = 0;
    if ~exist("dense", "var")
        dense = 0;
    end

    if not(exist(output_path, 'file') == 2)
        fprintf("%s not found", output_path)
        return
    end
    
    success = 1;
    if dense
        A = h5read(output_path, '/rdcm/m_all');
        A = A(:,1:end-1);  % removed c vector
        adj_mat(logical(eye(size(adj_mat)))) = 0;  % Make adj_mat diagonals zero
        A = A(logical(adj_mat));

        params = reshape(A, 1, []);  % Make row vector
        return
    end
        
    A = h5read(output_path, '/srdcm/m_all');
    z_all = h5read(output_path, '/srdcm/z_all');

    A = A(:,1:end-1);  % removed c matrix
    % A(logical(eye(size(A)))) = 0;  % Make self-connections zero
    z_all(logical(eye(size(z_all)))) = 0; % Make z_all diagonals zero
    z_all = z_all(:, 1:end-1);
    % masked = A(z_all>thresh); % Threshold based on posterior probability, don't because variable feature length
    masked = A .* z_all;  % weight A with z_all probabilities

    params = reshape(masked, 1, []);  % Make row vector
    % disp(size(params))  % debug

end