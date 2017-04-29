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

  # Count number of individual elements in all the sequences
  indivAmino <- countIndividualAminoacides(proteinDict)
  # FIXME: CHANGE THE WAY WE ARE SAVING THE TRAINING AND TESTING DATASETS BECAUSE OF COMPOSITION!

  # Generate training and testing datasets for all the families!
  generateTrainingDataSets(proteinDict, castTable, indivAmino)
  generateTestingDatasets(proteinDict, castTable, indivAmino)
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

countIndividualAminoacides <- function(proteinDict) {
  #
  #
  # Args:
  #   proteinDict: 
  #

  individualsList <- c()
  for (i in 1:length(names(proteinDict))) {
    currentSequence <- proteinDict[names(proteinDict)[i]]
    currentSequence <- currentSequence[[1]]
    
    for (j in 1:nchar(currentSequence)) {
      curr_character <- tolower(substr(currentSequence, j, j))
      
      # Ignore 'x' (in both lower and upper case)
      if ( (curr_character != 'x') & (!(curr_character %in% individualsList)) ) {
          individualsList <- c(individualsList, curr_character)
      }
    }
  }

  return(individualsList)
}

generateTrainingDataSets <- function(proteinDict, castTable, indivAmino) {
  #
  # 
  # Args:
  #   proteinDict: 
  #   castTable:
  # 

  # Iterate over each column of castTable, that is, each family
  for (key in names(castTable)) {
    generateDatasetForFamily(proteinDict, castTable, indivAmino, key, training = TRUE)
  }
}

generateTestingDatasets <- function(proteinDict, castTable, indivAmino) {
  #
  # 
  # Args:
  #   proteinDict: 
  #   castTable:
  #

  # Iterate over each column of castTable, that is, each family
  for (key in names(castTable)) {
    generateDatasetForFamily(proteinDict, castTable, indivAmino, key, training = FALSE)
  }
}

generateDatasetForFamily <- function(proteinDict, castTable, indivAmino, columnName, training = TRUE) {
  #
  # 
  # Args:
  #   proteinDict: 
  #   castTable:
  #   columnName:
  #   training: 
  #
  
  dataset <- list()
  rowNames <- row.names(castTable)
  currentList <- castTable[[columnName]]
  labelName <- 'Label'

  for (index in 1:length(currentList)) {
    value <- currentList[index]
    proteinName <- rowNames[index]
    proteinSequence <- proteinDict[proteinName]

    if (training) {
      # 1 -> Positive Train
      # 3 -> Negative Train
      if (value == 1) {
        # Generate sample
        compositionDict <- applyCompositionToProteinSequence(proteinSequence, indivAmino)
        compositionDict[[labelName]] <- 1

        # Append to list of samples
        dataset[[length(dataset) + 1]] <- compositionDict
      } else if (value == 3) {
        # Generate sample
        compositionDict <- applyCompositionToProteinSequence(proteinSequence, indivAmino)
        compositionDict[[labelName]] <- 0

        # Append to list of samples
        dataset[[length(dataset) + 1]] <- compositionDict
      }
    } else {
      # 2 -> Positive Test
      # 4 -> Negative Test
      if (value == 2) {
        # Generate sample
        compositionDict <- applyCompositionToProteinSequence(proteinSequence, indivAmino)
        compositionDict[[labelName]] <- 1

        # Append to list of samples
        dataset[[length(dataset) + 1]] <- compositionDict
      } else if (value == 4) {
        # Generate sample
        compositionDict <- applyCompositionToProteinSequence(proteinSequence, indivAmino)
        compositionDict[[labelName]] <- 0

        # Append to list of samples
        dataset[[length(dataset) + 1]] <- compositionDict
      }
    }
  }

  # Save the results in a .csv file
  if (training) {
    type_str <- 'train'
  } else {
    type_str <- 'test'
  }

  fileName <- paste('data/', type_str, '/SCOP40_', columnName, '_', type_str, '.csv', sep='')

  for (i in 1:length(dataset)) {
    # Get current training/testing instance
    current_instance <- dataset[[i]]

    # Get the sample as a matrix (and transpose to be in a row); Save it to the file
    current_instance <- as.matrix(t(current_instance))
    if (i==1) {
      writeColNames <- TRUE
    } else {
      writeColNames <- FALSE
    }
    write.table(current_instance, file=fileName, append=TRUE, quote=FALSE, sep=';',
                col.names=writeColNames, row.names=FALSE)
  }
}

applyCompositionToProteinSequence <- function(proteinSequence, indivAmino) {
  #
  # 
  # Args:
  #   proteinSequence: 
  #

  # Initialize dictionary for the protein (to count the number of occurrences of each character)
  proteinCompositionDict <- list()
  for (i in 1:length(indivAmino)) {
    proteinCompositionDict[[indivAmino[i]]] <- 0
  }

  # Simply count the number of occurrences
  for (i in 1:nchar(proteinSequence)) {
    curr_character <- tolower(substr(proteinSequence, i, i))
    if (curr_character != 'x') {
      proteinCompositionDict[[curr_character]] <- proteinCompositionDict[[curr_character]] + 1 
    }
  }

  return(proteinCompositionDict)
}