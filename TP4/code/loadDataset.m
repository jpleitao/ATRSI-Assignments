function [trainData, testData] = loadDataset(numerator, denominator, ts)
    transferFunction = tf(numerator, denominator, ts);
    transferFunction  % Just to have it pretty printed!

    sim('inputGenerator.slx');

    % Gerar dados!
    inputData = inputRandom.Data;
    outputData = discreteOut.Data;
    lenOutputData = length(outputData);

    dataMatrix = [
        outputData(3:lenOutputData-1) outputData(2:lenOutputData-2) outputData(1:lenOutputData-3)...
        inputData(3:lenOutputData-1) inputData(2:lenOutputData-2) inputData(1:lenOutputData-3) outputData(4:lenOutputData)];

    numData = length(dataMatrix);
    numTrainData = ceil(0.7 * numData);
    trainIndexes = randperm(numData, numTrainData);
    trainData = dataMatrix(trainIndexes, :);
    testData = setdiff(dataMatrix, trainData, 'rows');
end

