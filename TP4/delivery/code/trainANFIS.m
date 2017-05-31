function [trainedAnfis, error] = trainANFIS(varargin)    
    initFis = varargin(1);
    initFis = initFis{1};
    
    trainData = varargin(2);
    trainData = trainData{1};
    
    epochNumber = varargin(3);
    epochNumber = epochNumber{1};
    
    optimizationMethod = varargin(4);
    optimizationMethod = optimizationMethod{1};
    
    opt = anfisOptions();
    opt.InitialFIS = initFis;
    opt.EpochNumber = epochNumber;
    opt.OptimizationMethod = optimizationMethod;
    opt.DisplayANFISInformation = 1;
    
    [trainedAnfis, error] = anfis(trainData, opt);
end

