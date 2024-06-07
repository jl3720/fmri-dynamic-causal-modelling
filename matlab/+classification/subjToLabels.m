function participantDiagMap = subjToLabels(tab)
    % Function to create a map from participant_id to diag value
    % Inputs:
    %   tab - A table with columns 'participant_id' and 'diag'
    % Outputs:
    %   participantDiagMap - A dict mapping participant_id to diag

    % Extract the participant_id and diag columns
    participant_ids = tab.participant_id;
    diags = tab.diag;
    
    % Initialize the containers.Map object
    participantDiagMap = dictionary;
    
    % Loop through the rows of the table and populate the map
    for i = 1:height(tab)
        % Convert participant_id from cell to string
        participant_id = string(participant_ids{i});
        % Convert diag from numeric to double
        diag_value = double(diags(i));
        % Add to the map
        participantDiagMap(participant_id) = diag_value;
    end
end