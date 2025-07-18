# BP-Trend-Analysis

# Description

This project is based on the ENAR 2025 DataFest data analysis competition. The project aims to understand the decline in blood pressure (BP) control among US adults with hypertension. BP control is defined as systolic BP < 140 and diastolic BP < 90. The prevalence of BP control had been rising until 2013, but since then rate of controlled BP has been decreasing. The goal of this project is to understand and explain what factors explain this trend. It uses the US National Health and Nutrition Examination Survey (NHANES) data, which has been collecting health data on Americans every two years since 1999. The ENAR DataFest provided a preprocessed dataset to analyze, which contains ~26,000 observations of 160 variables. In this project, I load the data, do an exploratory analysis, clean the data and handle missing values, apply machine learning methods (LASSO, Elastic Net, and Random Forest) to find top predictors for BP control, and plot relationships between variables. 


# Statistical Methods

**LASSO:** Short for Least Absolute Shrinkage and Selection Operator. It's a linear regression method that adds a penalty to the absolute value of the coefficients. It helps prevent overfitting and performs variable selection by shrinking some coefficients to zero. Good for when only a few uncorrelated predictors matter.

**Elastic Net:** It is a linear regression method similar to a LASSO, although with a different penalty coefficient. It does not shrink any variables to exactly zero, but handles colinearity better and is more flexible than the LASSO.

**Random Forest:** An ensemble of decision trees using bootstrapped samples with random feature selection. This method better captures nonlinear relationships and interactions between variables, compared to the LASSO and Elastic Net, which are regressions.


# Project Structure

**01_load_data.R** - Loads data

**02_EDA.Rmd** - Exploratory data analysis, looks at the trends, data structure, and variables

**03_data_cleaning.R** - Removes unneeded columns and combines similar variables

**04_bp_data_analysis.Rmd** - Fits  LASSO, Elastic Net, and Random Forest models on the data and plots the top predictors for each

**05_trend_analysis.Rmd** - Analyzes the relation between the significant variables found in the analysis and the BP control trend

**Impute_function.R** - Function that imputes missing data into the dataframe

**LASSO_function.R** - Function that fits a LASSO model to the dataframe and plots top predictors

**Elastic_Net_function.R** - Function that fits an Elastic Net model to the dataframe and plots top predictors

**RF_function.R** - Function that fits a Random Forest model to the data frame and plots top predictors


# Results

The AUC for the LASSO and Elastic Net models are 0.88 and 0.87 for the Forest Plot. This high AUC is indicative of a model that is good at distinguishing between positive and negative cases. Across all three models, BP med use is the strongest predictor of BP control. In the LASSO and Elastic Net regression models, hypertension resistance is the second strongest predictor. However, the Random Forest model showed hypertension awareness as the second strongest predictor. When analyzing the trends, the trend between BP control and hypertension resistance does not show a very strong correlation, whereas hypertension awareness, BP med use, and BP control are all highly correlated. 


# Conclusion

My findings indicate that BP control is decreasing due to a lack of hypertension awareness and in turn decreasing BP med use. Increased BP testing to ensure patients are aware of their own hypertension and are perscribed the correct medication is key to increasing BP control.

# Libraries Needed

dplyr, pROC, ggplot2, tidyr, glmnet, caret, randomForest


# Acknowledgements
This project is based on the 2025 ENAR competition and was completed as a part of the Data Mining course at WashU. Data was provided by the competition and course instructors, using publicly available NHANES survey data.


