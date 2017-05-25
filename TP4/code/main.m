% Joaquim Leitão - 2011150072
% 2016/2017 School Year
% Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
% Assignment 4

% ========================== Load Data ===========================
ts = 1;
num = 2;
den = [1 5 6.75 2.25];
[trainData, testData] = loadDataset(num, den, ts);

% Further work steps:
% 1) Inicialisar regras fazendo clustering usando dados de treino - Obter FIS inicial
% 2) Usar regras obtidas no clustering na inicialisação da rede neuronal no ANFIS - Treinar rede com dados de treino -
%    Como output obter o modeo FIS tuned -- definir método de treino (híbrido vs retropropagação)
% 3) Depois de ter o modelo treinado validar com dados de teste


% =================================== Clustering =====================================

% TODO: Vary parameters here!!!

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

% TODO: Vary parameters here!!!

subtractiveEpochNumber = 10;
subtractiveOptimizationMethod = 1;  % 1 - Hybrid ; 0 - Backpropagation
[subtractiveANFIS, subtractiveError] = trainANFIS(subtractiveFIS, trainData, subtractiveEpochNumber,...
    subtractiveOptimizationMethod);

[~, ncols] = size(testData);
yReal = testData(:, ncols);
y = evalfis(testData(:, 1:ncols-1), subtractiveANFIS);
% TODO: Calcular root mean squared error

fcmEpochNumber = 10;
subtractiveOptimizationMethod = 1;  % 1 - Hybrid ; 0 - Backpropagation
[fcmANFIS, fcmError] = trainANFIS(fcmFIS, trainData, fcmEpochNumber, subtractiveOptimizationMethod);

[~, ncols] = size(testData);
yReal = testData(:, ncols);
y = evalfis(testData(:, 1:ncols-1), fcmANFIS);
% TODO: Calcular root mean squared error


% ================== Compute Delays ================
rootsDen = roots(den);
inverseRoots = -1./rootsDen;
minRoot = min(inverseRoots);
timeDelay = minRoot/2;
