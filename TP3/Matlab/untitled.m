% Read train data
trainData = SCOP40a;

[nrows, ncols] = size(trainData);

trainX = table2array(trainData(:, 1:ncols-1));
trainY = table2array(trainData(:, ncols));

% Train libsvm classifier
model = svmtrain(trainY, trainX, ['-t 2 -c 100 -g 0.001']);

% Read test data
testData = SCOP40a1;
[nrows, ncols] = size(testData);

testX = table2array(testData(:, 1:ncols-1));
testY = table2array(testData(:, ncols));

[predict_label, accuracy, dec_values] = svmpredict(testY, testX, model);
