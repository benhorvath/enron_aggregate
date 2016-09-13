# This is a 'library' function containing some boring helper functions I am
# using in the main script.

remove_constants <- function(df) {
        # Given a dataframe, removes columns where the value is constant, including NA.
        # 
        # First, calculate an array with a boolean corresponding to each column, true 
        # if the unique set of the variable's values is of length one, false 
        # otherwise. The function returns the dataset where columns are false,
        # i.e., not constant.

        constant_cols <- sapply(data, function(x) {length(unique(x)) == 1})
        df[which(!constant_cols)]
}

print_answer <- function(df, df_path) {
        # Format output answer to data code test question.
        #
        # Takes the dataset that is the answer to the question, and prints a header
        # describing the answer, the filepath to the full file, and then head(answer).
        # Automatically handles incremententation, e.g., question 1, 2, ..., n.
        
        # Initialize question counter if it doesn't already exist
        if (!exists('q_counter')) {q_counter <- 1}
        
        # Print head of answer df
        answer_header <- paste('\nQuestion', q_counter, 'Answer:', df_path, '\n')
        message(answer_header)
        print(head(df))
        message('\n')
        
        # Increment counter: <<- assigns to global environment
        q_counter <<- q_counter + 1

}