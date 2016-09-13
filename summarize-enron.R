#!/usr/bin/env Rscript

# Script aggregates an Enron e-mail dataset to count sent and recieved e-mails
# for each e-mail address. Dataset is somewhat messy, so makes use of tidyr and
# dplyr.
#
# From the command line:
#
#      Rscript --vanilla summarize-enron.R <<CSV file>>
#
# Or, from within an R session:
#
#      system('Rscript --vanilla summarize-enron.R <<CSV file>>')
#

#### Preliminaries ####

# Handle command line parameters: Error if there are no parameters; if there 
# is more than one parameter, inform user that the extras will be ignored
param <- commandArgs(trailingOnly=TRUE)
if (length(param) == 0) {
        stop('Required: Input dataset is required (CSV)')
} else if (length(param) > 1) {
        message(paste('Specify input dataset only (CSV);',
                      'ignoring additional parameters'))
}

# Set data file to first/only parameter; error if input dataset file not 
# found
data_file <- param[1]
if (!file.exists(data_file)) {
        stop(paste('File not found:', data_file))
}

# Load external libraries: Check if any are missing, and install
libs <- c('lubridate', 'tidyr', 'stringr', 'dplyr')
libs_need <- libs[!libs %in% installed.packages()[,"Package"]]
if (length(libs_need) > 0) { install.packages(libs_need, dependencies=TRUE) }
invisible(lapply(libs, require, character.only=TRUE))



# Load custom functions (boring stuff)
source(file.path('helpers.R'))

# Create directory, 'answers', to store end dataframe
answers_dir <- file.path('answers')
if (!file.exists(answers_dir)) {
        dir.create(file.path('answers'))
}

#### Load and Clean Data ####

# Load dataset specified by user parameters
data <- read.csv(data_file, header=FALSE, stringsAsFactors=FALSE, 
                 na.strings='')

# Add column names, remove worthless columns
colnames(data) <- c('time', 'email_id', 'sender', 'recipients', 'topic', 
                    'mode')
data <- remove_constants(data)

# Remove entries with NAs (70 entries)
data <- na.omit(data)

# Convert time to human readable datetime format, remove old time column
data$timestamp <- as.POSIXct(data$time/1000, origin='1970-01-01')
data$time <- NULL

#### Analysis: Sent and Received Frequency ####

# Returns a data frame containing the number of e-mails each entity sent and
# received in the data set. 

# Aggregate sender frequencies
sender_freq <- data %>% 
        filter(!duplicated(email_id)) %>% 
        count(email_id, sender) %>% 
        count(sender)
colnames(sender_freq) <- c('person', 'emails_sent')

# Aggregate recipient frequencies: First, create vector of number of 
# recipients per e-mail
qty_recipients <- str_count(data$recipients, '\\|') + 1
max_recipients <- max(qty_recipients)  # 26

# Use tidyr:separate to split recipients into 26 columns
data <- data %>%
        separate(recipients, paste('recipient', 1:max_recipients, sep='_'),
                 '\\|', extra='merge', fill='right')

# Uses gather() to convert wide data (recipients) to long data: 203k unique 
# email_id, almost 500k total rows arrange(timespan) orders dataframe by time
data <- data %>%
       gather(recipient_order, recipient, -c(timestamp, email_id, sender)) %>%
       na.omit() %>%
       arrange(timestamp)

# Finally, count recieved
recipient_freq <- data %>%
        count(email_id, recipient) %>% 
        count(recipient) 
colnames(recipient_freq) <-c('person', 'emails_received')

# Merge sender_freq and recipient_freq, convert NAs to zeros, sort descending by 
# e-mails sent: dplyr:inner_join
email_freq <- inner_join(sender_freq, recipient_freq) %>% arrange(-emails_sent)

#### Output Results ####

# Save result to the 'answers' directory
q1_filepath <- file.path('answers', 'q1.csv')
write.csv(email_freq, q1_filepath, row.names=FALSE)

# Output results
print_answer(email_freq, q1_filepath)