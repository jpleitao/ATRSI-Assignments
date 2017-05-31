function [initialFis] = initialiseFIS(varargin)
    clusteringType = varargin(1);
    clusteringType = clusteringType{1};
    
    opt = genfisOptions(clusteringType);
    opt.Verbose = true;
    if strcmp(clusteringType, 'SubtractiveClustering')        
        clusterInfluenceRange = varargin(2);
        opt.ClusterInfluenceRange = clusterInfluenceRange {1};
        
        squashFactor = varargin(3);
        opt.SquashFactor = squashFactor{1};
        
        acceptRatio = varargin(4);
        opt.AcceptRatio = acceptRatio{1};
        
        rejectRatio = varargin(5);
        opt.RejectRatio = rejectRatio{1};
    else
        exponent = varargin(2);
        opt.Exponent = exponent{1};
        
        maxNumIteration = varargin(3);
        opt.MaxNumIteration = maxNumIteration{1};
        
        minImprovment = varargin(4);
        opt.MinImprovement = minImprovment{1};
        
        numClusters = varargin(5);
        opt.NumClusters = numClusters{1};
    end
    
    trainData = varargin(6);
    trainData = trainData{1};
    
    [~, ncols] = size(trainData);
    initialFis = genfis(trainData(:, 1:ncols-1) , trainData(:, ncols), opt);
end

