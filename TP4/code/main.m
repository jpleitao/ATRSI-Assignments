% Joaquim Leitão - 2011150072
% 2016/2017 School Year
% Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
% Assignment 4

% =================================== Compute Delays ===================================
num = 2;
den = [1 5 6.75 2.25];
rootsDen = roots(den);
inverseRoots = -1./rootsDen;
minRoot = min(inverseRoots);
timeDelay = minRoot/3;

% =================================== Load Data ===================================
[numerator, denominator] = c2dm(num, den, 1, 'zoh');
[trainData, testData] = loadDataset(numerator, denominator, timeDelay);


% =================================== Clustering ===================================

% Subtractive ANFIS parameters
clusterInfluenceRange = 0.5;
squashFactor = 1.25;
acceptRatio = 0.5;
rejectRatio = 0.15;

% FCM Clustering ANFIS parameters
exponent = 2.0;
maxNumIteration = 100;
minImprovement = 1e-5;
numClusters = 'auto';

subtractiveFIS = initialiseFIS('SubtractiveClustering', clusterInfluenceRange, squashFactor, acceptRatio,...
    rejectRatio, trainData);
fcmFIS = initialiseFIS('FCMClustering', exponent, maxNumIteration, minImprovement, numClusters, trainData);

% ====================================== ANFIS ===========================================

% ********** Train Subtractive
epochNumber = 200;
optimizationMethod = 1;  % 1 - Hybrid ; 0 - Backpropagation
[subtractiveHybridAnfis, subtractiveHybridError] = trainANFIS(subtractiveFIS, trainData, epochNumber,...
    optimizationMethod);

optimizationMethod = 0;  % 1 - Hybrid ; 0 - Backpropagation
[subtractiveBackAnfis, subtractiveBackError] = trainANFIS(subtractiveFIS, trainData, epochNumber,...
    optimizationMethod);

% ********** Train FCM
optimizationMethod = 1;  % 1 - Hybrid ; 0 - Backpropagation
[fcmHybridAnfis, fcmHybridError] = trainANFIS(fcmFIS, trainData, epochNumber, optimizationMethod);

optimizationMethod = 0;  % 1 - Hybrid ; 0 - Backpropagation
[fcmBackAnfis, fcmBackError] = trainANFIS(fcmFIS, trainData, epochNumber, optimizationMethod);

% ********** Test Subtractive
[~, ncols] = size(testData);
yReal = testData(:, ncols);
ysubtractiveHybrid = evalfis(testData(:, 1:ncols-1), subtractiveHybridAnfis);
ysubtractiveBack = evalfis(testData(:, 1:ncols-1), subtractiveBackAnfis);
yfcmHybrid = evalfis(testData(:, 1:ncols-1), fcmHybridAnfis);
yfcmBack = evalfis(testData(:, 1:ncols-1), fcmBackAnfis);

errorSubtractiveHybridTest = rms(yReal - ysubtractiveHybrid);
errorSubtractiveBackTest = rms(yReal - ysubtractiveBack);
errorFcmHybridTest = rms(yReal - yfcmHybrid);
errorFcmBackTest = rms(yReal - yfcmBack);

% Export all 4 anfis
writefis(subtractiveHybridAnfis, 'subtractiveHybridAnfis');
writefis(subtractiveBackAnfis, 'subtractiveBackAnfis');
writefis(fcmHybridAnfis, 'fcmHybridAnfis');
writefis(fcmBackAnfis, 'fcmBackAnfis');

% Run final simulink simulation
sim('fuzzyModel.slx');

% Comparar com o modelo no simulink e meter os resultados
% TODO: Fazer para seno, onda quadrada, dente serra...

% Plot simout and compute RMSE
simulationValues = simout.signals.values;
time = simout.time;

transFun = simulationValues(:, 1);
subHybrid = simulationValues(:, 2);
subBack = simulationValues(:, 3);
fcmHybrid = simulationValues(:, 4);
fcmBack = simulationValues(:, 5);

figure();
plot(time, transFun, time, subHybrid, time, subBack, time, fcmHybrid, time, fcmBack);
title('Transfer Function and Fuzzy Systems Responses');
legend('Transfer Function', 'subtractiveHybrid', 'subtractiveBackpropagation', 'fcmHybrid', 'fcmBackpropagation');

errorSubtractiveHybridVal = rms(transFun - subHybrid);
errorSubtractiveBackVal = rms(transFun - subBack);
errorFcmHybridVal = rms(transFun - fcmHybrid);
errorFcmBackVal = rms(transFun - fcmBack);
