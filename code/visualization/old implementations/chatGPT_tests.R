
### PROMPT: generate a R script to correlate multiple matrices and all the combinations

# Load required libraries
library(corrplot) # For visualizing correlation matrices

# Generate example matrices
matrix1 <- matrix(rnorm(25), nrow = 5) # Matrix 1
matrix2 <- matrix(rnorm(25), nrow = 5) # Matrix 2
matrix3 <- matrix(rnorm(25), nrow = 5) # Matrix 3

# Combine matrices into a list
matrices <- list(matrix1, matrix2, matrix3)

# Function to compute correlations and visualize correlation matrix
compute_and_visualize_correlation <- function(matrix) {
  correlation_matrix <- cor(matrix) # Compute correlation matrix
  corrplot(correlation_matrix, method = "color", type = "upper", title = "Correlation Matrix")
}

# Loop through all combinations of matrices and compute correlations
for (i in 1:length(matrices)) {
  for (j in i:length(matrices)) {
    cat("Correlation between Matrix", i, "and Matrix", j, ":\n")
    compute_and_visualize_correlation(matrices[[i]])
    compute_and_visualize_correlation(matrices[[j]])
    cat("\n")
  }
}


### Can you join two tables in R? 
### They have the same columns and I would like an additional column 
### in the final table to identify where which entry comes from

# Create two sample tables
table1 <- data.frame(id = c(1, 2, 3), value = c(10, 20, 30))
table2 <- data.frame(id = c(2, 3, 4), value = c(15, 25, 35))

# Add identifier columns to each table
table1$table_name <- "Table1"
table2$table_name <- "Table2"

# Merge the tables
merged_table <- merge(table1, table2, by = "id", all = TRUE, suffixes = c("_table1", "_table2"))






### Can you save those correlations in a matrix?

# Load required libraries
library(corrplot) # For visualizing correlation matrices

# Generate example matrices
matrix1 <- matrix(rnorm(25), nrow = 5) # Matrix 1
matrix2 <- matrix(rnorm(25), nrow = 5) # Matrix 2
matrix3 <- matrix(rnorm(25), nrow = 5) # Matrix 3

# Combine matrices into a list
matrices <- list(matrix1, matrix2, matrix3)

# Function to compute correlations and return correlation matrix
compute_correlation <- function(matrix1, matrix2) {
  correlation_matrix <- cor(matrix1, matrix2) # Compute correlation matrix
  return(correlation_matrix)
}

# Initialize empty matrix to store correlation results
num_matrices <- length(matrices)
correlation_results <- matrix(NA, nrow = num_matrices, ncol = num_matrices)

# Loop through all combinations of matrices and compute correlations
for (i in 1:num_matrices) {
  for (j in (i+1):num_matrices) {
    correlation_results[i, j] <- compute_correlation(matrices[[i]], matrices[[j]])
    correlation_results[j, i] <- correlation_results[i, j] # Fill in lower triangular part of the matrix
  }
}

# Print correlation results
print(correlation_results)

# Optionally export correlation results to a CSV file
write.csv(correlation_results, file = "correlation_results.csv", row.names = FALSE)

### PROMPT: can you create a list in R that contains a name and an array of numbers in each row?

# Create a list with names and arrays of numbers
my_list <- list(
  list(name = "List1", numbers = c(1, 2, 3)),
  list(name = "List2", numbers = c(4, 5, 6)),
  list(name = "List3", numbers = c(7, 8, 9))
)

# Access list elements by name
print(my_list[[1]])
print(my_list[[2]])
print(my_list[[3]])

# Access list elements by name and subsetting
print(my_list[[1]]$name)
print(my_list[[1]]$numbers)
