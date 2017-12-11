# get one dataframe (all experiments) with duplicate participants removed

# load libraries and pacakges
source("useful_ML.R")
library(tidyverse) 
library(jsonlite)
library(stringr)

NUMEXPS <- 12

d = data.frame()
for (j in 1:NUMEXPS){
  files = dir(paste0("../experiments/exp", as.character(j), "/production-results/"))
  for (i in 1:length(files)[1]) {
    s <- fromJSON(paste0("../experiments/exp", as.character(j), "/production-results/", files[i]))
    s$exp = j
    s$answers$asses = ifelse(is.null(s$answers$asses), "NA", s$answers$asses)
    d = bind_rows(d, data.frame(s))
  }
}
names(d) <- str_replace(names(d), "answers.", "")

d$WorkerId <- as.factor(d$WorkerId)

hit_counts <- group_by(d, WorkerId) %>%
  summarize(count = n()) %>%
  left_join(select(d, WorkerId, exp, "AssignmentId")) %>%
  group_by(WorkerId) %>%
  mutate(first_exp = min(exp),
         include = as.factor(ifelse(exp == first_exp,
                                    "keep", "remove"))) %>%
  select(-exp)

filter_data <- d %>%
  left_join(hit_counts, 
            by = c("WorkerId", "AssignmentId")) %>%
  filter(include == "keep") %>%
  select(-count, -include)

d_filtered_anonymized <- anonymize.sids(filter_data, "WorkerId")

d_filtered_anonymized_long = d_filtered_anonymized %>%
  gather(variable, value, contains("_")) %>%
  mutate(trial_num =  unlist(lapply(strsplit(as.character(variable),
                                             "_T"),function(x) x[2])),
         variable = unlist(lapply(strsplit(as.character(variable),
                                           "_"),function(x) x[1]))) %>%
  spread(variable, value) %>%
  mutate(trial_num = as.numeric(trial_num)) %>%
  mutate_if(is.character, funs(as.factor)) %>%
  filter(!is.na(condition))


d_filtered_anonymized_long_munged = d_filtered_anonymized_long %>%
  select(exp, subids, trial_num, category, condition, selected) %>%
  mutate(selected_cat = lapply(str_split(selected, ","), 
                               function(x) {str_sub(x, 2, 2)}),
         selected = lapply(str_split(selected, ","), 
                           function(x) {str_sub(x, 4, 6)})) %>%
  rowwise() %>%
  mutate(n_unique = length(unique(unlist(selected_cat))),
         first_cat = unlist(selected_cat)[1],
         cat_num = if_else(category == "animals", 3, 
                           if_else(category == "vehicles", 2, 1)),
         selected_filtered = list(lapply(selected_cat, function(x, y) {x == y[1]}, cat_num)),
         selected_in_cat = list(unlist(selected)[unlist(selected_filtered)])) %>%
  ungroup()

# do proportions only on target category
d_filtered_anonymized_long_munged_clean <- d_filtered_anonymized_long_munged %>%  
  mutate(prop_sub = unlist(lapply(selected_in_cat, function(x){sum(x == "sub")/2})),
         prop_bas = unlist(lapply(selected_in_cat, function(x){sum(x == "bas")/2})),
         prop_sup = unlist(lapply(selected_in_cat, function(x){sum(x == "sup")/4}))) %>%
  select(-selected, -selected_cat, -selected_in_cat, -selected_filtered) %>%
  mutate(only_responded_with_target_category = as.factor(if_else(n_unique == 1 & first_cat == cat_num, 
                                                                 "only_target", "other")))




write_csv(d_filtered_anonymized_long_munged_clean, "../data/anonymized_data/no_dups_data_munged_A.csv")

