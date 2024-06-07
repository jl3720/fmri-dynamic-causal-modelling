function A = get_reduced_connectivity_matrix(network)
% --------------------------------------------------------------------------------------------------------
% reduces the prior A-matrix according to the used network architecture
% Input: 
%           network: defines which network to use
%                    - currently implemented:
%                           - 'triple'
%                           - 'pain'
%
% Output:
%           A: reduced A-matrix
% --------------------------------------------------------------------------------------------------------
        indices = [93, 94,117,118]; %regions missing from Brainnetome connectivity matrix
        [ParentCurDir, ~] = fileparts(pwd);
        baseDir = fullfile(ParentCurDir,'SRPBS_OPEN','data');
        A_conn = fullfile(baseDir,'Brainnetome2016');
        %A_conn=load('SRPBS_OPEN/data/Brainnetome2016/StructConn.mat');
        
        % Insert rows of zeros at the specified indices in order to keep indices aligned with network input 
        for i = 1:length(indices)
            index = indices(i);
            A_conn = [A_conn(1:index-1, :); zeros(1, size(A_conn, 2)); A_conn(index:end, :)];
        end
        
        % Insert columns of zeros at the specified indices
        for i = 1:length(indices)
            index = indices(i);
            A_conn = [A_conn(:, 1:index-1), zeros(size(A_conn, 1), 1), A_conn(:, index:end)];
        end

        numerical_indices_to_keep = filter_indices(network);
        % Create a logical index array to keep the desired rows and columns
        keep_indices = ismember(1:size(A_conn, 1), numerical_indices_to_keep);     
        % Apply logical indexing to exclude rows and columns
        A = A_conn(keep_indices, keep_indices);
end