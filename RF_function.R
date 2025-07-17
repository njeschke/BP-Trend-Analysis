
library(randomForest)
library(dplyr)
library(caret)
library(ggplot2)

#Function that runs a Random Forest model on a dataframe
RF_funct <- function(data, outcome_var = "bp_control_accaha", seed = 123, ntree = 500) {
  
  # 1: Create binary outcome
  data_rf <- data %>%
    mutate(bp_control_binary = ifelse(.data[[outcome_var]] == "Yes", "Yes", "No"),
           bp_control_binary = factor(bp_control_binary)) %>%
    select(-all_of(outcome_var)) %>%  # Remove original outcome
    select(where(~ length(unique(.)) > 1))  # Remove non-informative variables
  
  # 2: Train/test split
  set.seed(seed)
  train_idx <- sample(seq_len(nrow(data_rf)), size = 0.7 * nrow(data_rf))
  train_data <- data_rf[train_idx, ]
  test_data  <- data_rf[-train_idx, ]
  
  # 3: Fit model
  rf_model <- randomForest(bp_control_binary ~ ., data = train_data, importance = TRUE, ntree = ntree)
  
  # Step 4: Predict and evaluate
  rf_preds <- predict(rf_model, newdata = test_data)
  cm <- confusionMatrix(rf_preds, test_data$bp_control_binary, positive = "Yes")
  
  # 4. Return model and results
  return(list(
    model = rf_model,
    confusion_matrix = cm,
    predictions = rf_preds,
    test_data = test_data
  ))
}


#Function that plots the top 20 predictors resulting from a Random Forest

plot_RF_funct <- function(rf_model, top_n = 20, fill_color = "forestgreen") {
  # 1. Check input
  if (!inherits(rf_model, "randomForest")) {
    stop("Input must be a randomForest model.")
  }
  
  # 2. Extract and prepare importance data
  rf_importance_df <- as.data.frame(importance(rf_model))
  rf_importance_df$variable <- rownames(rf_importance_df)
  
  # 3. Select top N predictors by MeanDecreaseGini
  plot_df <- rf_importance_df %>%
    arrange(desc(MeanDecreaseGini)) %>%
    slice_head(n = top_n)
  
  # 4. Create plot
  p <- ggplot(plot_df, aes(x = reorder(variable, MeanDecreaseGini), y = MeanDecreaseGini)) +
    geom_col(fill = fill_color) +
    coord_flip() +
    labs(
      title = paste("Top", top_n, "Random Forest Predictors of BP Control"),
      x = "Predictor",
      y = "Mean Decrease in Gini"
    ) +
    theme_minimal(base_size = 14)
  
  return(p)
}

