#### Munge and save anonymized version of XTMEM data for single exp###

# set exp number
EXPTNUM <- 11

# load libraries and pacakges
source("useful_ML.R")
library(tidyverse) 
library(jsonlite)
library(stringr)

## Read in and process data
raw_path <- paste0("../experiments/exp", EXPTNUM, "/production-results/")
files <- dir(raw_path)
d_raw <- data.frame()
for (i in 1:length(files)[1]) {
  s <- fromJSON(paste0(raw_path, files[i]))
  s$answers$asses = ifelse(is.null(s$answers$asses), "NA", s$answers$asses)
  d_raw <- bind_rows(d_raw, data.frame(s))
}
names(d_raw) <- str_replace(names(d_raw), "answers.", "")
d_anonymized <- anonymize.sids(d_raw, "WorkerId")

raw_anonymized_path <- paste0("../data/anonymized_raw_data/exp", EXPTNUM, "_A.csv")
write_csv(d_anonymized, raw_anonymized_path)

# Munge
d_anonymized <- read_csv(raw_anonymized_path)

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
  select(subids, trial_num, category, condition, selected) %>%
  mutate(selected = lapply(str_split(selected, ","), 
                           function(x) {str_sub(x, 4, 6)})) %>%
  mutate(prop_sub = unlist(lapply(selected, function(x){sum(x == "sub")/2})),
         prop_bas = unlist(lapply(selected, function(x){sum(x == "bas")/2})),
         prop_sup = unlist(lapply(selected, function(x){sum(x == "sup")/4})),
         exp = EXPTNUM) %>%
  select(-selected)

# Write
write_csv(d_anonymized_long_munged, paste0("../data/munged_data/exp", EXPTNUM, "_data_munged.csv"))

