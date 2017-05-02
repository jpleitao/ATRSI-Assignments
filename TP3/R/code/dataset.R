# Joaquim Leitão - 2011150072
# 2016/2017 School Year
# Doctoral Program in Information Science and Technology - Real Time Learning in Intelligent Systems
# Assignment 3

loadDataset <- function(filePath) {
  dataset <- read.table(filePath, header=TRUE, sep=';')
  
  # Shuffle dataset
  dataset <- dataset[sample(nrow(dataset)), ]
  return(dataset)
}
