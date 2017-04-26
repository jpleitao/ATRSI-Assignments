# Joaquim Leitão - 2011150072
# 2016/2017 School Year
# Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
# Assignment 3

preprocessDataset <- function(fastaFilePath, castFilePath) {
  # 
  #
  # Args:
  #   fastaFilePath: The path to the .fasta file, containing the correspondence between the family and the DNA sequences
  #   castFilePath: The path to the .cast file, where the association between the families is stored, for both the
  #                 training and testing datasets
  
  # Process .fasta file and compute dicitonary of protein names and DNA sequences!
  proteinDict <- processFastaFile(fastaFilePath)

  # Read table in the .cast file
  castTable <- read.table(castFilePath, header = TRUE)

  # Generate training and testing datasets for all the families!
  # generateTrainingDataSets(proteinDict, castTable)
  generateTestingDatasets(proteinDict, castTable)
}

processFastaFile <- function(fastaFilePath) {
  #
  # 
  # Args:
  #   fastaFilePath: 
  #
  # Return:
  #   proteinDict: 
  
  # Read text file and store information in a "dictionary-like" structure where, for each protein name we have the
  # correspondent DNA sequence
  proteinDict <- c()

  con = file(fastaFilePath, 'r')
  while (TRUE) {
    line = readLines(con, n = 1)
    if ( length(line) == 0 ) {
      break
    } else if (substr(line, 1, 1) == '>') {
      # Going to read new protein family - Get the name of the protein
      proteinName = substr(line, 2, nchar(line))
      
      # Read next line
      proteinSequence = readLines(con, n = 1)
      if (length(line) > 0) {
        proteinDict[proteinName] <- proteinSequence
      }
    }
  }
  close(con)

  return(proteinDict)
}

generateTrainingDataSets <- function(proteinDict, castTable) {
  #
  # 
  # Args:
  #   proteinDict: 
  #   castTable:
  # 

  # Iterate over each column of castTable, that is, each family
  for (key in names(castTable)) {
    generateDatasetForFamily(proteinDict, castTable, key, training = TRUE)
  }
}

generateTestingDatasets <- function(proteinDict, castTable) {
  #
  # 
  # Args:
  #   proteinDict: 
  #   castTable:
  #

  # Iterate over each column of castTable, that is, each family
  for (key in names(castTable)) {
    generateDatasetForFamily(proteinDict, castTable, key, training = FALSE)
  }
}

generateDatasetForFamily <- function(proteinDict, castTable, columnName, training = TRUE) {
  #
  # 
  # Args:
  #   proteinDict: 
  #   castTable:
  #   columnName:
  #   training: 
  #

  dataset <- c()
  rowNames <- row.names(castTable)
  count <- 0
  currentList <- castTable[[columnName]]

  for (index in 1:length(currentList)) {
    value <- currentList[index]
    proteinName <- rowNames[index]
    proteinSequence <- proteinDict[proteinName]

    composition <- applyCompositionToProteinSequence(proteinSequence)

    if (training) {
      # 1 -> Positive Train
      # 3 -> Negative Train
      if (value == 1) {
        dataset[composition] <- 1
      } else if (value == 3) {
        dataset[composition] <- 0
      }

    } else {
      # 2 -> Positive Test
      # 4 -> Negative Test
      if (value == 2) {
        dataset[composition] <- 1
        count <- count + 1
      } else if (value == 4) {
        dataset[composition] <- 0
        count <- count + 1
      }
    }
  }

  # Convert dataset to matrix
  dataset <- as.matrix(dataset)
  # Save the results in a .csv file
  if (training) {
    type_str <- 'train'
  } else {
    type_str <- 'test'
  }

  fileName <- paste('data/', type_str, '/SCOP40_', columnName, '_', type_str, '.csv', sep='')
  write.csv2(dataset, file=fileName)
  print(count)
}

applyCompositionToProteinSequence <- function(proteinSequence) {
  #
  # 
  # Args:
  #   proteinSequence: 
  #

  # FIXME: Confirm how to apply the composition! - Number of occurrences of each character or sequences of 3 characters!!!

  return(proteinSequence)
}