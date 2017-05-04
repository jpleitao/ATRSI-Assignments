# Joaquim Leitão - 2011150072
# 2016/2017 School Year
# Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
# Assignment 3

averageAUCTest <- function(bestClassifiers) {
  sum <- 0
  classNames <- names(bestClassifiers)
  
  for (currTestName in classNames) {
    sample <- bestClassifiers[[currTestName]]
    sum <- sum + sample['AUC.Test']
  }
  
  return(sum / length(classNames))
}

getBestParametersForFamily <- function(resultsFilePath) {
  # Read data from file
  fileData <- read.table(resultsFilePath, header=TRUE, sep=';')
  
  # Get index of maximum value in the column corresponding to the test AUC
  testData <- unlist(fileData['AUC.Test'])
  bestIndex <- which.max(testData)
  
  return(fileData[bestIndex, 1:ncol(fileData)])
}

getApproachFromFileName <- function(fileName) {
  # Remove extension
  fileName <- substr(fileName, 1, nchar(fileName)-4)
  
  # Split string by '_' and return approach type (follows last '_')
  splittedName <- strsplit(fileName, '_')
  splittedName <- splittedName[[1]]
  return(splittedName[length(splittedName)])
}

getBestClassifiersForApproach <- function(classifier, resultsDir) {
  # List contents of 'resultsDir' directory - Only analyse results for the given classifier
  bestResultsFamily <- list()
  resultsDirContents <- list.files(resultsDir)
  
  for (currentFile in resultsDirContents) {
    # Get approach type from file name
    approachType <- getApproachFromFileName(currentFile)
    
    if (approachType == classifier) {
      bestParameters <- getBestParametersForFamily(paste(resultsDir, currentFile, sep=''))
      
      # Append parameters to the list of best results for family
      if (! (currentFile %in% names(bestResultsFamily)) ) {
        bestResultsFamily[[currentFile]] <- bestParameters
      }
    }
  }
  
  return(bestResultsFamily)
}

postProcess <- function(resultsDir) {
  classifiers <- c('SVM', 'LaSVM')
  
  for (classifier in classifiers) {
    # Get best results for the given approach, for the different families
    bestClassifiers <- getBestClassifiersForApproach(classifier, resultsDir)
    
    # Compute average AUC on test data for the best approaches previously identifies
    averageTestAUC <- averageAUCTest(bestClassifiers)
    
    print(paste('Average AUC in test data for ', classifier, ' = ' , averageTestAUC, sep=''))
  }
  
}
  
