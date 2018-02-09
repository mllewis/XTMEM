### Pre-processing script for XTMEM analysis ###
# Merge raw data from all 12 experiments into single dataframe, 
# anonymize, and save as csv (data/anonymized_data/all_raw_A.csv).
# Also saves munged form of data as csv (data/anonymized_data/all_data_munged_A.csv).

# define number of experiments in total
NUMEXPS <- 12

# load libraries 
library(tidyverse) 
library(jsonlite)
library(stringr)

# function to anonymize subject ids by giving them a value 1:num_subjects
anonymize.sids <- function(df, subject_column_label) {
  subj_col = which(names(df) == subject_column_label) # get workerid column index
  temp <- data.frame(workerid = unique(df[,subj_col])) # make new df of unique workerids
  temp$subid <- 1:length(unique(df[,subj_col])) # make list of subids
  index <- match(df[,subj_col], temp$workerid) 
  df$subids <- temp$subid[index]
  df[,subj_col] <- NULL 
  df$subids  = as.factor(df$subids)
  return(df)
}

############# save csv of merged, anonymized data ################
# read in and process data
d_raw <- data.frame()
for (j in 1:NUMEXPS){
  files = dir(paste0("../experiments/exp", as.character(j), "/production-results/"))
  for (i in 1:length(files)[1]) {
    s <- fromJSON(paste0("../experiments/exp", as.character(j), "/production-results/", files[i]))
    s$answers$asses = ifelse(is.null(s$answers$asses), "NA", s$answers$asses)
    d_raw <- bind_rows(d_raw, data.frame(s, exp = j))
  }
}

# anonymize
names(d_raw) <- str_replace(names(d_raw), "answers.", "")
d_anonymized <- anonymize.sids(d_raw, "WorkerId")

# write to csv
# write_csv(d_anonymized, "../data/anonymized_data/all_raw_A.csv")

########################### save munged csv ###################
d_anonymized <- read_csv("../data/anonymized_data/all_raw_A.csv")

d_anonymized_long <-  d_anonymized %>%
  gather(variable, value, contains("_")) %>%
  mutate(trial_num =  unlist(lapply(strsplit(as.character(variable),
                                             "_T"),function(x) x[2])),
         variable = unlist(lapply(strsplit(as.character(variable),
                                           "_"),function(x) x[1]))) %>%
  spread(variable, value) %>%
  mutate(trial_num = as.numeric(trial_num)) %>%
  mutate_if(is.character, funs(as.factor)) 

d_anonymized_long_munged <-  d_anonymized_long %>%
  select(exp, subids, trial_num, category, condition, selected) %>%
  mutate(selected_cat = lapply(str_split(selected, ","), 
                               function(x) {str_sub(x, 2, 2)}), # category number of each selected item (1-3)
         selected = lapply(str_split(selected, ","), 
                           function(x) {str_sub(x, 4, 6)})) %>%  # category level type of each selected item (basic, superordinate, or subordinate)
  rowwise() %>%
  mutate(n_unique_selected_cat = length(unique(unlist(selected_cat))), # exemplars from how many categories were selected?
         first_cat = unlist(selected_cat)[1],
         cat_num = if_else(category == "animals", 3, # target category number of trial
                           if_else(category == "vehicles", 2, 1)),
         selected_filtered = list(lapply(selected_cat, function(x, y) {x == y[1]}, cat_num)), # test whether selections were in category
         selected_in_cat = list(unlist(selected)[unlist(selected_filtered)])) %>%
  ungroup()


# do proportions on target category only
d_anonymized_long_munged_clean <- d_anonymized_long_munged %>%  
  mutate(prop_sub = unlist(lapply(selected_in_cat, function(x){sum(x == "sub")/2})), # get proportions
         prop_bas = unlist(lapply(selected_in_cat, function(x){sum(x == "bas")/2})),
         prop_sup = unlist(lapply(selected_in_cat, function(x){sum(x == "sup")/4}))) %>%
  select(-selected, -selected_cat, -selected_in_cat, -selected_filtered) %>%
  mutate(only_responded_with_target_category = # code whether participant only selected target category exemplars on trial 
           if_else(n_unique_selected_cat == 1 & first_cat == cat_num, "only_target", "other"),
         only_responded_with_target_category = as.factor(only_responded_with_target_category))

# write to csv
# write_csv(d_anonymized_long_munged_clean, "../data/anonymized_data/all_data_munged_A.csv")
