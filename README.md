# Aggregating Enron E-mail Dataset

A R script that performs a simple aggregation on an Enron e-mail dataset: How many e-mails did each unique entity send and receive? Notably, makes use of the dplyr and tidyr packages.

## Usage

From the command line:

      Rscript --vanilla summarize-enron.R <<CSV file>>
      
 Or, from within an R session:
 
      system('Rscript --vanilla summarize-enron.R <<CSV file>>')
      
## Directory

Script will create a folder 'answers' to contain the resulting data frame. Original data is stored in the data folder in a csv. A few helper (boring) functions are sourced in from the helpers.R file.
