# Function that imputes missing values
# Imputes the median of each numeric column in a dataframe
# Impuptes "MISSING" for categorical columns

library(dplyr)

impute_data <- function(df) {
  df <- df %>%
    mutate(across(where(is.numeric),
                  ~ ifelse(is.na(.), median(., na.rm = TRUE), .))) %>%
    mutate(across(where(is.character),
                  ~ ifelse(. == "", "MISSING", .)))
  return(df)
}