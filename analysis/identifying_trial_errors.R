# Identifying trial errors (prop > 1)

bad_trials <- read_csv("../data/anonymized_data/no_dups_data_munged_A.csv") %>%
  filter(prop_sub >1 | prop_bas > 1| prop_sup > 1)  %>%
  as.data.frame()


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
                           function(x) {str_sub(x, 4, 6)})) 

all_bad <- left_join(bad_trials, d_anonymized_long) %>%
  select(c(1:8, 24:26))