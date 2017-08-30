####g et one dataframe (all experiments) 


# load libraries and pacakges
source("../analysis/useful_ML.R")
library(tidyverse) 
library(jsonlite)
library(stringr)

# set exp number
NUMEXPS <- 12

## Read in and process data
d_raw <- data.frame()
for (j in 1:NUMEXPS){
  files = dir(paste0("../experiments/exp", as.character(j), "/production-results/"))
  for (i in 1:length(files)[1]) {
    s <- fromJSON(paste0("../experiments/exp", as.character(j), "/production-results/", files[i]))
    s$answers$asses = ifelse(is.null(s$answers$asses), "NA", s$answers$asses)
    d_raw <- bind_rows(d_raw, data.frame(s, exp = j))
  }
}


names(d_raw) <- str_replace(names(d_raw), "answers.", "")
d_anonymized <- anonymize.sids(d_raw, "WorkerId")

write_csv(d_anonymized, "../data/anonymized_data/all_raw_A.csv")

# Munge
d_anonymized <- read_csv("../data/anonymized_data/all_raw_A.csv")

d_anonymized_long = d_anonymized %>%
  gather(variable, value, contains("_")) %>%
  mutate(trial_num =  unlist(lapply(strsplit(as.character(variable),
                                             "_T"),function(x) x[2])),
         variable = unlist(lapply(strsplit(as.character(variable),
                                           "_"),function(x) x[1]))) %>%
  spread(variable, value) %>%
  mutate(trial_num = as.numeric(trial_num)) %>%
  mutate_if(is.character, funs(as.factor)) 

d_anonymized_long_munged = d_anonymized_long %>%
  select(exp, subids, trial_num, category, condition, selected) %>%
  mutate(selected = lapply(str_split(selected, ","), 
                           function(x) {str_sub(x, 4, 6)})) %>%
  mutate(prop_sub = unlist(lapply(selected, function(x){sum(x == "sub")/2})),
         prop_bas = unlist(lapply(selected, function(x){sum(x == "bas")/2})),
         prop_sup = unlist(lapply(selected, function(x){sum(x == "sup")/4}))) %>%
  select(-selected)

# Write
write_csv(d_anonymized_long_munged, paste0("../data/anonymized_data/all_data_munged_A.csv"))

