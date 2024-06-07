function individual_connection_analysis(path,row,col)
% ----------------------------------------------------------------------
% ranks connectivity values for one connection by size between samples. 
% Allows analysis of how accurately a single connection predicts group 
% membership with a given set.
%
% 0 corresponds to control, 1 to patient
%
% Input:
%           row: row index of connection to be analyzed
%           col: column index of connection to be analyzed
%           path: path to folder storing A matrices
% --------------------------------------------------------------------
files = dir(fullfile(path, '*.mat'));
conns=[];
% gets the strength of the specified connection for all samples
for k = 1:length(files)
            filePath = fullfile(path, files(k).name);
            data=load(filePath);
            A=data.A;
            conn=A(row,col);
            conns=[conns,conn];
end
[sortedValues, originalIndices] = sort(conns, 'descend');
% Display the results
disp('Sorted connectivity values:');
disp(sortedValues);

disp('Original indices of samples:');
disp(originalIndices);

assigngment = zeros(size(originalIndices));
% Set values in assignment to 0 where the corresponding values in A are above median
 assigngment(originalIndices <= length(originalIndices)/2) = 0;
 assigngment(originalIndices > length(originalIndices)/2) = 1;
disp('group membership of samples with connection strength ranked in the upper half')
disp(assigngment(1:length(originalIndices)/2));
disp('group membership of samples with connection strength ranked in the lower half')
disp(assigngment(end-length(originalIndices)/2+1:end));
end