function difference_matrix= inter_groups_analysis(path,filetype,n,num_regions,n_perms,plot,show,network)
% --------------------------------------------------------------------------------------------------------------------------
% heuristic analysation tool checking for connectivity differences between healthy controls and patients
%
% Input:
%       - path: necessary input! path to a folder storing all A matrices 
%       - filetype: default is 'mat', might have to enter 'h5'
%       - n: number of connections that go into difference matrix (default: 1000)
%       - num_regions: number of brain regions in A matrices (default: 242)
%       - n_perms:     number of random permutations (default: 100)
%       - plot: bool whether to plot of per-connection intergroup differences (default: false)
%       - show: bool whether to print the n largest connection differences between controls and patients (default: false) 
%       - network: when using a reduced network, specify 'pain' or 'triple'
% Output:
%       - difference_matrix: 242x242 matrix with only the n largest connections of non-zero value
%
% if plot = true: plots difference between inter-group average connectivity values 
%       - for group 1: healthy controls, group 2: patients
%       - for 2 groups with randomly permuted labels as null hypothesis
%
% prints the sum over all average connectivity differences i.e. over all regions
% -----------------------------------------------------------------------------------------------------------------------
if ~exist("n","var")
    n=1000;
end
if ~exist("num_regions","var")
    num_regions=242;
end
if ~exist("n_perms","var")
    n_perms=100;
end
if ~exist("plot","var")
    plot=1;
end
if ~exist("show","var")
    show=0;
end
if ~exist("filetype","var")
    filetype="mat";
end
if filetype~="h5"
    filetype="mat";
end

%get all .mat/.h5 files in the current directory
if filetype== "h5"
    files = dir(fullfile(path,'*.h5'));
elseif filetype=="mat"
    files = dir(fullfile(path, '*.mat'));
end
num_iterations = length(files);



%---------------------------------randomized groups------------------------
%permute n_perms times, calculate the difference between gropus per region, average over regions, average over permutations
all_abs_avgs=0;
all_diffs=0;
for i = 1:n_perms
%initialize
    avg_abs_average_diff_single_connection=0;
    g1=0;
    g2=0;
    average_diff_single_connection=0;
% Generate a random permutation of indices
    random_order = randperm(num_iterations);   
    %random_order= [1 13 2 14 3 15 4 16 5 17 6 18 7 19 8 20 9 21 10 22 11 23 12 24;]
%iterate through all samples, add up connectivity parameter for two groups
    for k = 1:length(files)
            idx=random_order(k);
            filePath = fullfile(pwd, files(idx).name);
            if filetype== 'h5'               
                A=h5read(filePath,'/srdcm/m_all');
                A(:,end)=[];
                z=h5read(filePath,'/srdcm/z_all');
                z(:,end)=[];
                A=A*z;
            else 
                data=load(filePath);
                A=data.A;
            end
            if k <= length(files)/2
                g2=g2+A;
            else 
                g1=g1+A;
            end
    end
%calculate avg. differences between groups
    average_diff_single_connection=(g1-g2)/length(files);
    all_diffs=all_diffs+average_diff_single_connection;
    abs_average_diff_single_connection=abs((g1-g2)/length(files));
    avg_abs_average_diff_single_connection=sum(abs_average_diff_single_connection(:))/(num_regions*num_regions);
    all_abs_avgs=all_abs_avgs+avg_abs_average_diff_single_connection;
end
%calculate differences between randomized groups
all_abs_avgs=all_abs_avgs/n_perms;
all_diffs=all_diffs/n_perms;
disp('average of all average connectivity differences between two random groups averaged over permutations')
disp(all_abs_avgs);  

% ------------------------ group 1 consisting of HCs, group 2 of patients ------------------------------
 HCs=0;
 patients=0;
 %iterate through all samples, add up connectivity parameter for two groups - controls have to be first 
    for k = 1:length(files)
            filePath = fullfile(path, files(k).name);
            disp(files(k).name);
            if filetype== 'h5'
                A=h5read(filePath,'/rdcm/m_all');
                A(:,end)=[];
                z=h5read(filePath,'/srdcm/z_all');
                z(:,end)=[];
                A=A*z;
            else 
                data=load(filePath);
                A=data.A;
            end
            if k <= length(files)/2
                HCs=HCs+A;
            else 
                patients=patients+A;
            end
    end

    %calculate avg. differences between groups
    avg_diff_2=(HCs-patients)/length(files);
    abs_avg_diff_2=abs((HCs-patients)/length(files));
    disp('average of all average connectivity differences between HC group and patient group')
    avg_2=sum(abs_avg_diff_2(:))/(num_regions*num_regions);
    disp(avg_2);
    flat = avg_diff_2(:);

% --- calculate connection strength of the n most negative and n most positive connections -------
    % Sort the 1D array in descending order and get the sorted indices
    [sorted_values, sorted_indices] = sort(flat, 'descend');
    
    % Get the indices and values of the n largest as well as n largest negative elements
    top_n_indices = sorted_indices(1:n);
    top_n_values = sorted_values(1:n);
    bottom_n_indices = sorted_indices(end-n+1:end);
    bottom_n_values = sorted_values(end-n+1:end);
    % Convert 1D indices back to 2D indices
    [pos_row, pos_col] = ind2sub(size(avg_diff_2), top_n_indices);
    pos_indices=[pos_row,pos_col];
    [neg_row, neg_col] = ind2sub(size(avg_diff_2), bottom_n_indices);
    neg_indices=[neg_row,neg_col];

 % --------------------------- displays and plots --------------------------------------------
    if show
    disp('indices and values of the ' + string(n) + ' connections with biggest differences between connection strength of HCs and patients')
    disp(pos_indices);
    disp(top_n_values);
    disp('indices and values of the ' + string(n) + ' connections with biggest negative differences between connection strength of HCs and patients')
    disp(neg_indices);
    disp(bottom_n_values);
    end
    if plot
    figure;
    imagesc(average_diff_single_connection);
    colorbar;
    xlabel('region (from)');
    ylabel('region (to)');
    title('inter-group connectivity differences for randomized groups');
    figure;
    imagesc(avg_diff_2);
    colorbar;
    xlabel('region (from)');
    ylabel('region (to)');
    title('inter-group connectivity differences between HCs and patients');
    end

 % -- save difference matrix including the n biggest and n biggest negative values. If using reduced model, index changes are handled -- 
    if num_regions == 242
        difference_matrix=zeros(242,242);
        
    else
        difference_matrix=zeros(246,246);
        numerical_indices_to_keep=filter_indices(network);
        pos_indices= numerical_indices_to_keep(pos_indices);
        neg_indices= numerical_indices_to_keep(neg_indices);
    end
    for i = 1:size(pos_indices,1)
        row = pos_indices(i,1);
        col = pos_indices(i,2);
        value=top_n_values(i);
        difference_matrix(row,col)=value;
    end
    for i = 1:size(neg_indices,1)
        row = neg_indices(i,1);
        col = neg_indices(i,2);
        value=bottom_n_values(i);
        difference_matrix(row,col)=value;
    end
    if num_regions < 242
        indices_to_remove = [93, 94,117,118];
        rows_to_keep = setdiff(1:size(difference_matrix, 1), indices_to_remove);
        cols_to_keep = setdiff(1:size(difference_matrix, 2), indices_to_remove);
        difference_matrix = difference_matrix(rows_to_keep, cols_to_keep);
    end
  % ------------------------- convert matrix to ASCII table for visualisation --------------------------------
    outputfile='most_important_connections_'+ string(num_regions) + '_regions_' + string(n) + '_conns';
    fid = fopen(outputfile, 'w');
    % Get the size of the matrix
    [rows, cols] = size(difference_matrix);
    
    % Write the matrix as an ASCII table to the file
    for i = 1:rows
        for j = 1:cols
            fprintf(fid, '\t%.6e', difference_matrix(i, j)); 
        end
        fprintf(fid, '\n');
    end    
    % Close the output file
    fclose(fid);      
end