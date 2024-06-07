function [subjects_positive, subjects_control] = getSubjectList(disease, split)
    % Args:
        % disease: string, {"pain", "schizophrenia"}
        % split: string, {"train", "test"}
    % Returns:
        % subjects: cell array of strings, list of subject IDs
    subjects_positive = [];
    subjects_control = [];
    if split == "train"
        subjects_schizos = ["sub-0089", "sub-0091", "sub-0094", "sub-0095", "sub-0097", "sub-0098", "sub-0099", "sub-0100", "sub-0102", "sub-0103", "sub-0167", "sub-0191", "sub-0230"];

        subjects_control = ["sub-0025", "sub-0026", "sub-0027", "sub-0030", "sub-0031", "sub-0032", "sub-0033", "sub-0036", "sub-0037", "sub-0038", "sub-0039", "sub-0040"];

        subjects_pain = ["sub-1387", "sub-1388", "sub-1389", "sub-1391", "sub-1394", "sub-1395", "sub-1396", "sub-1397", "sub-1398", "sub-1399", "sub-1401", "sub-1403", "sub-1405", "sub-1408", "sub-1409", "sub-1410"];

        subjects_pain_control = ["sub-1363", "sub-1364", "sub-1365", "sub-1366", "sub-1368", "sub-1369", "sub-1370", "sub-1371", "sub-1372", "sub-1373", "sub-1374", "sub-1375", "sub-1376", "sub-1377", "sub-1381", "sub-1382", "sub-1383", "sub-1384", "sub-1386"];
    elseif split == "test"
        subjects_schizos = ["sub-0670", "sub-0671", "sub-0672", "sub-0673", "sub-0674", ...
                            "sub-0675", "sub-0676", "sub-0677", "sub-0678", "sub-0679", ...
                            "sub-0680", "sub-0681", "sub-0682", "sub-0683", "sub-0684", ...
                            "sub-0685", "sub-0686", "sub-0687", "sub-0688", "sub-0689", "sub-0690"];
        
        subjects_control = ["sub-0715", "sub-0716", "sub-0717", "sub-0718", "sub-0719", "sub-0720", "sub-0721", "sub-0722", "sub-0723", "sub-0724", ...
            "sub-0725", "sub-0726", "sub-0727", "sub-0728", "sub-0729", "sub-0730", "sub-0731", "sub-0732", "sub-0733", "sub-0734", "sub-0735"];
        
    else
        disp("Invalid `split` argument")
        return

    end

    if disease == "schizophrenia"
        subjects_positive = subjects_schizos;
        subjects_control = subjects_control;
    elseif disease == "pain"
        subjects_positive = subjects_pain;
        subjects_control = subjects_pain_control;
    else
        disp("Invalid `disease` argument")
        return
    end