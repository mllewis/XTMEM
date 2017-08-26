# Save effect sizes from XT2007 and SPSS2 as csv 

rm(list = ls())

library(tidyverse)
library(forcats)
library(compute.es)


#  Here are the means and sd based on SPSS table 1 (includes XT)
literature_effect_sizes <- data.frame(exp_recoded = c("XT_adults_e1",
                                                      "XT_children_e2",
                                                      "SPSS_e1",
                                                      "SPSS_e2",
                                                      "SPSS_e3",
                                                      "SPSS_eS1",
                                                      "SPSS_eS2"),
                                      one_means = c(76, 40, 48.24, 30.83, 39.91, 24.56, 15.79), 
                                      three_means = c(9, 6, 10.53, 53.33, 51.75, 16.67, 11.40),
                                      one_sd = c(40.40, 40.40, 40.40,37.18,35.20,32.09,24.51),
                                      three_sd = c(24.97, 24.97, 24.97,36.11,42.63,25.45,24.25),
                                      n = c(22, 36, 19, 20, 19,19,19))

# Calculate previous effect sizes from literature.
literature_effect_sizes$d <- mes(literature_effect_sizes$one_means/100,
                                 literature_effect_sizes$three_means/100, 
                                 literature_effect_sizes$one_sd/100,
                                 literature_effect_sizes$three_sd/100,
                                 literature_effect_sizes$n,
                                 literature_effect_sizes$n, verbose = F)$d

literature_effect_sizes$d_var <- mes(literature_effect_sizes$one_means/100,
                                     literature_effect_sizes$three_means/100,
                                     literature_effect_sizes$one_sd/100,
                                     literature_effect_sizes$three_sd/100,
                                     literature_effect_sizes$n, 
                                     literature_effect_sizes$n,
                                     verbose = F)$var.d

literature_effect_sizes <- literature_effect_sizes %>%
  mutate(high = d + (1.96*d_var),
         low = d - (1.96*d_var)) %>%
  select(-one_means, -three_means, -one_sd, -three_sd) %>%
  mutate(es_type = "nonpaired")

write_csv(literature_effect_sizes, "../data/literature_ES.csv")
