function [dataset] = loadDataset(filePath)
    % Import data in struct
    dataset = importdata(filePath);
    
    % Only retrieve the actual data, forget about the column names?
    dataset = dataset.data;
end