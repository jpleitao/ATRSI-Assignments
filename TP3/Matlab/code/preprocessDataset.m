function [] = preprocessDataset(fastaFilePath, castFilePath)

    proteinDict = processFastaFile(fastaFilePath);
    
    % Read table in the .cast file
    castTable = importdata(castFilePath);
    
    % Count number of individual elements in all the sequences
    indivAmino = countIndividualAminoacides(proteinDict);
    
    % Generate training and testing datasets for all the families!
    %generateTrainingDataSets(proteinDict, castTable, indivAmino);
    generateTestingDatasets(proteinDict, castTable, indivAmino);
end


function [proteinDict] = processFastaFile(fastaFilePath)
    
    text = fileread(fastaFilePath);
    splitedText = strsplit(text, '\n');
    proteinDict = containers.Map;
    
    for i=1:2:length(splitedText)
       currLine = cell2mat(splitedText(i));
       
       if isempty(currLine)
           break
       elseif currLine(1) == '>'
           % Going to read new protein family - Get the name of the protein
           proteinName = currLine(2:length(currLine));
           proteinSequence = cell2mat(splitedText(i+1));
           
           proteinDict(proteinName) = proteinSequence;
       end
    end
end

function [individualsList] = countIndividualAminoacides(proteinDict)
    
    individualsList = [];
    
    proteinKeys = keys(proteinDict);
    
    for i=1:length(proteinKeys)
        currentSequence = proteinDict(proteinKeys{i});
        
        for j=1:length(currentSequence)
            currChar = lower(currentSequence(j));
            
            if currChar ~= 'x' && ~(any(individualsList == currChar))
                individualsList = [individualsList; currChar];
            end
        end
    end
end

function [] = generateTrainingDataSets(proteinDict, castTable, indivAmino)
    [~, ncols] = size(castTable.textdata);
    
    for i=2:ncols
       currFamily = cell2mat(castTable.textdata(1, i));
       generateDatasetForFamily(proteinDict, castTable, indivAmino,...
           currFamily, i-1, 1);
    end
end

function [] = generateTestingDatasets(proteinDict, castTable, indivAmino)
    [~, ncols] = size(castTable.textdata);
    
    for i=2:ncols
       currFamily = cell2mat(castTable.textdata(1, i));
       generateDatasetForFamily(proteinDict, castTable, indivAmino,...
           currFamily, i-1, 0);
    end
end

function [] = generateDatasetForFamily(proteinDict, castTable, indivAmino, columnName, col, training)
    currentList = castTable.data(:, col);
    labelName = 'Label';
    dataset = [];
    
    for index=1:length(currentList)
        value = currentList(index);
        proteinName = cell2mat(castTable.textdata(index+1, 1));
        proteinSequence = proteinDict(proteinName);
        
        compositionDict = composeProtein(proteinSequence, indivAmino);
        
        if training == 1
            % 1 -> Positive train
            % 2 -> Negative train
            if value == 1
                compositionDict(labelName) = 1;        
                            
                % Update dataset
                tempList = [];
                for i=1:length(indivAmino)
                    tempList = [tempList compositionDict(indivAmino(i))];
                end
                tempList = [tempList compositionDict(labelName)];
                dataset = [dataset; tempList];
                
            elseif value == 2
                compositionDict(labelName) = -1;
                
                % Update dataset
                tempList = [];
                for i=1:length(indivAmino)
                    tempList = [tempList compositionDict(indivAmino(i))];
                end
                tempList = [tempList compositionDict(labelName)];
                dataset = [dataset; tempList];
            end
        else
            % 3-> Positive test
            % 4-> Negative test
            if value == 3
                compositionDict(labelName) = 1;
                
                % Update dataset
                tempList = [];
                for i=1:length(indivAmino)
                    tempList = [tempList compositionDict(indivAmino(i))];
                end
                tempList = [tempList compositionDict(labelName)];
                dataset = [dataset; tempList];
            elseif value == 4
                compositionDict(labelName) = -1;
                
                % Update dataset
                tempList = [];
                for i=1:length(indivAmino)
                    tempList = [tempList compositionDict(indivAmino(i))];
                end
                tempList = [tempList compositionDict(labelName)];
                dataset = [dataset; tempList];
            end
        end
    end
    if training == 1
        typeStr = 'train';
    else
        typeStr = 'test';
    end
    
    % Write to csv file
    filePath = ['data/', typeStr, '/SCOP40_', columnName, '_', typeStr,'.csv'];
    
    % Save header
    header = [indivAmino' , labelName];
    csvwrite(filePath, header);
    csvwrite(filePath, dataset, 1, 0);
end


function [compositionDict] = composeProtein(proteinSequence, indivAmino)
    compositionDict = containers.Map;
    
    % Initialize dictionary for the protein (to count the number of
    % occurrences of each character)
    for i=1:length(indivAmino)
        compositionDict(indivAmino(i)) = 0;
    end
    
    % Simply count the number of occurrences
    for i=1:length(proteinSequence)
        currChar = lower(proteinSequence(i));
        
        if currChar ~= 'x'
            compositionDict(currChar) = compositionDict(currChar) + 1;
        end
    end
end
