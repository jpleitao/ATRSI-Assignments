function [trainData, testData] = loadDataset(numerator, denominator, ts)
    transferFunction = tf(numerator, denominator, ts);
    transferFunction  % Just to have it pretty printed!

    sim('inputGenerator.slx');
    
    inputData = inputRandom.Data;
    outputData = discreteOut.Data;
    lenOutputData = length(outputData);
    
    fig = figure();
    h = plot(inputRandom.Time, inputData, inputRandom.Time, outputData);
    title('Generated System Input and Output data');
    legend(h, 'Input', 'Output');
    saveas(fig, 'randomInputOutput.png');
    

    dataMatrix = [
        outputData(3:lenOutputData-1) outputData(2:lenOutputData-2) outputData(1:lenOutputData-3)...
        inputData(3:lenOutputData-1) inputData(2:lenOutputData-2) inputData(1:lenOutputData-3) outputData(4:lenOutputData)];

    numData = length(dataMatrix);
    numTrainData = ceil(0.7 * numData);
    trainData = dataMatrix(1:numTrainData, :);
    testData = dataMatrix(numTrainData+1:end, :);
end

