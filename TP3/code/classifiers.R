# Joaquim Leitão - 2011150072
# 2016/2017 School Year
# Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
# Assignment 3

library(e1071)
library(lasvmR)
library(pROC)

computeAUC <- function(model, x, y, trainSVM) {
  if (trainSVM) {
    pred <- predict(model, x)
  } else {
    pred <- lasvmPredict(x, model, verbose=FALSE)
  }

  predNew <- c()
  for (i in pred) {
    predNew <- c(predNew, as.numeric(i))
  }
  aucValue <- auc(y, predNew)
  return(aucValue)
}


trainModel <- function(trainDataset, modelName, testDir, resultsDir, gammaValue, trainSVM) {
  # Split trainDataset into input and output
  x <- trainDataset[1 : length(trainDataset)-1]
  y <- trainDataset[['Label']]
  yFactor <- as.factor(y)
  xMatrix <- as.matrix(x)
  
  # Count number of training examples of each class to assign weights to each class during training
  numZeros <- 0
  numOnes <- 0
  for (i in y) {
    if (as.numeric(i) == 0) {
      numZeros <- numZeros + 1
    } else {
      numOnes <- numOnes + 1
    }
  }

  bestTestAuc <- 0
  bestModelAucTrain <- 0
  bestModel <- NULL

  costStart <- 10^-3
  costLimit <- 10^3
  
  gammaStart <- 10^-4
  gammaEnd <- 10^4

  if (trainSVM) {
    print('[SVM]Going to start training')
  } else {
    print('[LaSVM]Going to start training')
  }
  
  resultsMatrix <- matrix(c('Cost', 'Gamma', 'AUC Train', 'AUC Test'), ncol=4)

  for (currCost in seq(costStart, costLimit, 0.5)) {
    for (currGamma in seq(gammaStart, gammaEnd, 0.0001)) {
      # Train
      if (trainSVM) {
        model <- svm(x, yFactor, kernel='radial', cost=currCost, gamma=currGamma)
      } else {
        model <- lasvmTrain(xMatrix, y, kernel=2, cost=currCost, gamma=currGamma, verbose=FALSE)
      }

      # AUC in training
      aucTrain <- computeAUC(model, xMatrix, yFactor, trainSVM)

      # Load test dataset
      testFilePath <- paste(testDir, substr(modelName, 1, nchar(modelName)-4), 'est.csv', sep='')
      testDataset <- loadDataset(testFilePath)

      xTest <- testDataset[1 : length(testDataset)-1]
      yTest <- testDataset[['Label']]

      if (trainSVM) {
        yTest <- as.factor(yTest)
      } else {
        xTest <- as.matrix(xTest)
      }

      # AUC in test
      aucTest <- computeAUC(model, xTest, yTest, trainSVM)

      if (aucTest > bestTestAuc) {
        bestTestAuc <- aucTest
        bestModelAucTrain <- aucTrain
        bestModel <- model
      }
      resultsMatrix <- rbind(resultsMatrix, matrix(c(currCost, currGamma, aucTrain, aucTest), ncol=4))
    }
  }

  print(paste('Best Model recorded an AUC of ', bestModelAucTrain, ' in the train dataset and an AUC of ',
              bestTestAuc, ' in the test dataset', sep=''))
  # print(bestModel)

  # Save best model to R data file
  if (trainSVM) {
    modelFilePath <- paste('models/SVM/', modelName, '.rda', sep='')
  } else {
    modelFilePath <- paste('models/LaSVM/', modelName, '.rda', sep='')
  }
  save(bestModel, file=modelFilePath)
  
  # Save experiments data
  if (trainSVM) {
    filePath <- paste(resultsDir, '/', modelName, '_SVM.csv', sep='')
  } else {
    filePath <- paste(resultsDir, '/', modelName, '_LaSVM.csv', sep='')
  }
  write.table(resultsMatrix, file=filePath, quote=FALSE, sep=';', row.names=FALSE, col.names=FALSE)
}

euclideanDistance <- function(vector1, vector2) {
  return( sqrt(sum( (vector1 - vector2)^2 )) )
}

computeSmallerDistanceToNegative <- function(trainDataset, index) {
  nrows <- nrow(trainDataset)
  ncols <- ncol(trainDataset)
  
  currSample <- trainDataset[index, 1:ncols]
  smallerDistance <- NULL
  
  for(i in 1:nrows) {
    if (i == index) {
      next
    } else if (trainDataset[i, ncols] == -1) {
      dist <- euclideanDistance(currSample[1:ncols-1], trainDataset[i, 1:ncols-1])
      
      if (is.null(smallerDistance)) {
        smallerDistance <- dist
      } else if (dist < smallerDistance) {
        smallerdistance <- dist
      }
    }
  }
  return(smallerDistance)
}


computeGammaValue <- function(trainDataset) {
  nrows <- nrow(trainDataset)
  ncols <- ncol(trainDataset)
  
  distancesList <- c()
  
  for (i in 1:nrows) {
    currSample <- trainDataset[i, 1:ncols]
    
    if (currSample[ncols] == 1) {
      smallerDistance <- computeSmallerDistanceToNegative(trainDataset, i)
      
      distancesList <- c(distancesList, smallerDistance)
    }
  }
  return(median(distancesList))
}

trainClassifiers <- function(dataDir) {
  # List contents of training dir
  trainDir <- 'data/train/'
  testDir <- 'data/test/'
  modelsDir <- 'models/'
  resultsDir <- 'data/results/'
  trainDirContents <- list.files(trainDir)
  
  # For each file in the dir train a classifier
  for (i in 1:length(trainDirContents)) {
    fileName <- trainDirContents[i]
    
    print(paste('Training model for ', fileName, sep=''))
    
    if (grepl('.csv', fileName)) {
      # Only train for .csv file
      trainDataset <- loadDataset(paste(trainDir, fileName, sep=''))
      
      gammaValue <- computeGammaValue(trainDataset)
      
      # Build and train an SVM
      trainFileName <- substr(fileName, 1, nchar(fileName)-4)  # Remove extension
      trainModel(trainDataset, trainFileName, testDir, resultsDir, gammaValue, TRUE)
      
      # Build and train LaSVM
      trainModel(trainDataset, trainFileName, testDir, resultsDir, gammaValue, FALSE)
    }
  }
}
