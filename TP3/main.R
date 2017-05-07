# Joaquim Leitão - 2011150072
# 2016/2017 School Year
# Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
# Assignment 3

main <- function() {
  # Starting point of the execution.
  #
  
  # Add source to scripts
  source('code/preprocess.R')
  source('code/dataset.R')
  source('code/classifiers.R')
  source('code/postProcess.R')
  
  castFilePath <- 'data/SCOP40mini_sequence_minidatabase_19.cast'
  fastaFilePath <- 'data/SCOP40mini.fasta'
  
  preprocessDataset(fastaFilePath, castFilePath)
  trainClassifiers('data/')
  postProcess('data/results/')
}

main()
