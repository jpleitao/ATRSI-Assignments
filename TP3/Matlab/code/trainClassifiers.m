function [bestAUCS] = trainClassifiers(dataDir)
    % List all .csv files int the train folder
    trainDataDir = [dataDir, 'train/'];
    testDataDir = [dataDir, 'test/'];
    trainDirContents = dir([trainDataDir, '*.csv']);
    
    bestAUCS = [];
    
    for i=1:length(trainDirContents)
       fileName = trainDirContents(i).name;
       
       fprintf('Training model for file %s\n', fileName);
       
       % Remove extension and '_train' from file name
       [~, name, ~] = fileparts(fileName);
       currFamily = name(1:length(name)-6);
       
       trainFilePath = [trainDataDir, fileName];
       testFilePath = [testDataDir, currFamily, '_test.csv'];
       bestAUC = buildSVM(trainFilePath, testFilePath, currFamily);
       bestAUCS = [bestAUCS, bestAUC];
    end
    
    
    % If it call trainSVM which will train a bunch of SVMs and choose the
    % one that performs better in the test dataset!

end


function [bestAUC] = buildSVM(trainFilePath, testFilePath, family)    
    % Load train and test datasets
    trainDataset = loadDataset(trainFilePath);
    testDataset = loadDataset(testFilePath);
    
    % Split into features and label
    [~, ncolsTrain] = size(trainDataset);
    [~, ncolsTest] = size(testDataset);
    xTrain = trainDataset(:, 1:ncolsTrain-1);
    yTrain = trainDataset(:, ncolsTrain);
    xTest = testDataset(:, 1:ncolsTest-1);
    yTest = testDataset(:, ncolsTest);
    
    % ==================== Train SVM varying the parameters ===============
    % In this script the parameters for the cost and gamma of the RBF SVM
    % will be changed
    flags = '-t 2 -v 10'; % RBF type
    
    % cValues = [10^-3 : 10^-3 : 10^3];
    % gammaValues = [10^-3 : 10^-3 : 10^3];
    
    cValues = [100, 110, 118, 120, 130];
    gammaValues = [0.01, 0.02, 0.05, 0.10];
    
    bestAUC = 0;
    bestModel = 0;
    
    %{
    for i=1:length(cValues)
        cVal = cValues(i);
       for j=1:length(gammaValues)
           % Train model
           model = svmtrain(yTrain, xTrain, [flags, '-c ', cVal,' -g ', gammaValues(j)]);
           
           % Test model and compute auc
           [predicted, ~, ~] = svmpredict(yTest, xTest, model);
           [~, ~, ~, auc] = perfcurve(yTest, predicted, 1);
           
           % Check if is the best
           if auc > bestAUC
               bestAUC = auc;
               bestModel = model;
           end
       end
    end
    %}
    
    net = newrb(xTrain', yTrain', 0.001);
    predicted_rbf = sim(net, xTest');
    [~, ~, ~, auc] = perfcurve(yTest, predicted_rbf', 1);
    
    if auc > bestAUC
        bestAUC = auc;
    end
    
    fprintf('Got %f and max is %f\n', auc, bestAUC);
    
    % Save model
    
    % FIXME: Add more flags
    % model = svmtrain(yTrain, xTrain, '-t 2 -v 10 -c 100 -g 0.01');
    
    % Test and assess auc of the model
    % [predicted, accuracy, ~] = svmpredict(yTest, xTest, model);
    
    % [~, ~, ~, auc] = perfcurve(yTest, predicted, 1);
    

end