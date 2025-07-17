
library(glmnet)
library(dplyr)
library(caret)
library(ggplot2)

#Function that runs an Elastic Net regression on a dataframe

ElasticNet_funct <- function(df, alpha = 0.5, seed = 123) {
  # 1. Create binary outcome
  df <- df %>%
    mutate(bp_control_binary = ifelse(bp_control_accaha == "Yes", 1, 0))
  
  # 2. Remove outcome variable from predictors
  df_clean <- df %>%
    select(-bp_control_accaha)
  
  # 3. Remove predictors with only one unique value
  df_clean <- df_clean %>%
    select(where(~ length(unique(.)) > 1))
  
  # 4. Create model matrix (remove intercept)
  x <- model.matrix(bp_control_binary ~ ., data = df_clean)[, -1]
  y <- df_clean$bp_control_binary
  
  # 5. Split into train/test sets
  set.seed(seed)
  train_idx <- sample(seq_len(nrow(x)), size = 0.7 * nrow(x))
  x_train <- x[train_idx, ]
  x_test  <- x[-train_idx, ]
  y_train <- y[train_idx]
  y_test  <- y[-train_idx]
  
  # 6. Fit Elastic Net logistic regression
  elastic_fit <- cv.glmnet(x_train, y_train, family = "binomial", alpha = alpha)
  best_lambda <- elastic_fit$lambda.min
  
  # 7. Predict on test set
  pred_probs_test <- predict(elastic_fit, newx = x_test, s = best_lambda, type = "response")
  pred_class_test <- ifelse(pred_probs_test > 0.5, 1, 0)
  
  # 8. Confusion matrix
  cm <- confusionMatrix(factor(pred_class_test), factor(y_test), positive = "1")
  
  # 9. Return results
  return(list(
    confusion_matrix = cm,
    elastic_fit = elastic_fit,
    best_lambda = best_lambda,
    x_train = x_train,
    y_train = y_train,
    y_test = y_test,
    pred_probs_test = pred_probs_test
  ))
  
}


#Function that plots the top 20 predictors resulting from an Elastic Net


plot_ElasticNet_funct <- function(elastic_fit, best_lambda, top_n = 2, title = NULL) {
  # 1. Extract coefficients at best lambda
  elastic_coefs <- coef(elastic_fit, s = best_lambda)
  
  # 2. Convert to tidy data frame
  coef_df <- as.data.frame(as.matrix(elastic_coefs))
  coef_df$variable <- rownames(coef_df)
  colnames(coef_df)[1] <- "coefficient"
  
  # 3. Remove intercept and zero coefficients
  coef_df <- coef_df %>%
    filter(variable != "(Intercept)", coefficient != 0)
  
  # 4. Sort by absolute value and keep top n
  coef_df <- coef_df %>%
    mutate(abs_coef = abs(coefficient)) %>%
    arrange(desc(abs_coef)) %>%
    slice(1:top_n)
  
  # 5. Plot
  ggplot(coef_df, aes(x = reorder(variable, abs_coef), y = coefficient)) +
    geom_col(fill = "darkorange") +
    coord_flip() +
    labs(
      title = ifelse(is.null(title),
                     paste("Top", top_n, "Elastic Net Predictors"),
                     title),
      x = "Predictor",
      y = "Coefficient"
    ) +
    theme_minimal()
}
