# Data Cleaning
# Goal: Shrink the data frame before running analysis to focus on most relevant columns

# Unneeded variables

# Survey variables - not relevant in this analysis
## svy_psu
## svy_subpop_chol
## svy_strata
## SDMVPSU
## SDMVSTRA
## svy_weight_mec

# Direct measure of blood pressure - do not want to predict BP using BP
## bp_sys_mean
## bp_dia_mean
## BPACSZ
## BPXSY1
## BPXDI1
## BPXSY2
## BPXDI2
## BPXSY3
## BPAARM
## BPQ020
## BPXDI3

# Repetitive measures - already measured in an existing variable or irrelevant
## demo_age_cat 
## SDDSRVYR 
## Begin_Year
## YEAR
## RIDAGEYR
## DMDHRGND
## RIDSTATR
## RIDEXMON
## RIAGENDR
## RIDRETH1
## WTINT2YR
## WTMEC2YR

# Measures with only one unique value - not predictive
## htn_any_resistant
## htn_accaha

# Load dyplr
library(dplyr)

# List of variables to remove
vars_to_remove <- c(
  "svy_psu", "svy_subpop_chol", "svy_strata", 
  "SDMVPSU", "SDMVSTRA", "svy_weight_mec",
  
  "bp_sys_mean", "bp_dia_mean", "BPACSZ", 
  "BPXSY1", "BPXDI1", "BPXSY2", "BPXDI2", 
  "BPXSY3", "BPAARM", "BPQ020", "BPXDI3",
  
  "demo_age_cat", "SDDSRVYR", "Begin_Year", 
  "YEAR", "RIDAGEYR", "DMDHRGND", "RIDSTATR", 
  "RIDEXMON", "RIAGENDR", "RIDRETH1", "WTINT2YR", 
  "WTMEC2YR",   
  
  "htn_any_resistant", "htn_accaha"
)

# Remove the specified columns from bp_data_all, create new dataframe called bp_data
bp_data <- bp_data_all[ , !(names(bp_data_all) %in% vars_to_remove)]

# Remove columns with missingness >80%, not enough information
high_missing_cols <- names(missing_props[missing_props > 0.8])
bp_data <- bp_data[, !(names(bp_data) %in% high_missing_cols)]


#combining Hypertension resistant columns - hypertension resistant by any criteria

bp_data <- bp_data %>%
  rowwise() %>%
  mutate(htn_any_resistant = if_else(any(c_across(starts_with("htn_resistant_")) == "Yes"), "Yes", "No")) %>%
  ungroup() %>%
  select(-starts_with("htn_resistant_"))

# Combining cholesterol med columns 
# these one's must be listed out specifically to avoid incorporating chol_med_reccomended columsn

chol_med_cols <- c(
  "chol_med_statin",
  "chol_med_ezetimibe",
  "chol_med_pcsk9i",
  "chol_med_fibric_acid",
  "chol_med_simvastatin",
  "chol_med_rosuvastatin",
  "chol_med_pravastatin",
  "chol_med_fluvastatin",
  "chol_med_lovastatin",
  "chol_med_other",
  "chol_med_bile",
  "chol_med_atorvastatin",
  "chol_med_pitavastatin"
)

# Create combined column and remove the originals
bp_data <- bp_data %>%
  rowwise() %>%
  mutate(chol_med_any = if_else(any(c_across(all_of(chol_med_cols)) == "Yes"), "Yes", "No")) %>%
  ungroup() %>%
  select(-all_of(chol_med_cols))



