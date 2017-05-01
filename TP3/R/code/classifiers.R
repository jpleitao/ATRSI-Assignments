# Joaquim Leitão - 2011150072
# 2016/2017 School Year
# Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
# Assignment 3

library(e1071)
library(pROC)

# Implementar aqui os classificadores (Funções para treino e para teste)

# No caso das SVMs ver como definir linear e nao linear (e já agora também na LaSVM) - Para as SVMs usar LIBSVM

# FIXME: Save trained models in the "models/" folder!

# Colocar aqui função principal de classificação; basicamente recebe o input dataset, tipo de classificação a fazer (SVM vs LaSVM) e caminho para o ficheiro com o modelo (ou entao recebe ja o modelo treinado mesmo o objecto)


computeAUC <- function(model, x, y) {
  pred <- predict(model, x)
  predNew <- c()
  for (i in pred) {
    predNew <- c(predNew, as.numeric(i))
  }
  aucValue <- auc(y, predNew)
  return(aucValue)
}


trainSVM <- function(trainDataset, modelName, testDir) {
  # Split trainDataset into input and output
  y <- as.factor(trainDataset[['Label']])
  x <- trainDataset[1 : length(trainDataset)-1]
  
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

  print('Going to start training')

  # for (currCost in seq(costStart, costLimit, 1.0)) {
    currCost <- 100
    currGamma <- 0.001
    
    # for (currGamma in seq(costStart, costLimit, 1)) {

      # Train
      model <- svm(x, y, kernel='radial', cost=currCost, gamma=currGamma)

      # AUC in training
      aucTrain <- computeAUC(model, x, y)

      # Load test dataset
      testFilePath <- paste(testDir, substr(modelName, 1, nchar(modelName)-4), 'est.csv', sep='')
      testDataset <- loadDataset(testFilePath)

      yTest <- factor(testDataset[['Label']], levels=c(1, -1))
      xTest <- testDataset[1 : length(testDataset)-1]

      # AUC in test
      aucTest <- computeAUC(model, xTest, yTest)

      if (aucTest > bestTestAuc) {
        bestTestAuc <- aucTest
        bestModelAucTrain <- aucTrain
        bestModel <- model
      }

      print(paste('Currently at ', currCost, ' limit is ', costLimit, ' best auc= ', bestTestAuc, ' currAUC=', aucTest, sep=''))
    #}
  # }

  print(paste('Best Model recorded an AUC of ', bestModelAucTrain, ' in the train dataset and an AUC of ',
              aucTest, ' in the test dataset', sep=''))
  print(bestModel)

  print(bestModel$nu)

  # Save model
  save(bestModel, file=paste('models/', modelName, '.rda', sep=''))
}


testSVM <- function(model, testFilePath) {
  # Load test dataset
  dataset <- loadDataset(testFilePath)
  
  # Split dataset into input and output
  y <- factor(dataset[['Label']], levels=c(1, 0))
  x <- dataset[1 : length(dataset)-1]
  
  pred <- predict(model, x)
  predNew <- c()
  for (i in pred) {
    predNew <- c(predNew, as.numeric(i))
  }
  print(predNew)
  
  # Compute AUC for this test
  aucValue <- auc(y, predNew)
  print(aucValue)
}


trainClassifiers <- function(dataDir) {
  # List contents of training dir
  trainDir <- 'data/train/'
  testDir <- 'data/test/'
  modelsDir <- 'models/'
  trainDirContents <- list.files(trainDir)
  
  # For each file in the dir train a classifier
  for (i in 1:length(trainDirContents)) {
    fileName <- trainDirContents[i]

    fileName <- trainDirContents[length(trainDirContents)]
    
    print(paste('Training model for ', fileName, sep=''))
    
    if (grepl('.csv', fileName)) {
      # Only train for .csv file
      trainDataset <- loadDataset(paste(trainDir, fileName, sep=''))
      
      # Build and train an SVM
      trainFileName <- substr(fileName, 1, nchar(fileName)-4)  # Remove extension
      trainSVM(trainDataset, trainFileName, testDir)
      
      return()
      
      # Build and train LaSVM
    }
  }
}
