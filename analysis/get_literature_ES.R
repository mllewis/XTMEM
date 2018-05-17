### Get XT2007 and SPSS ES ###
# Save effect sizes from XT2007 and SPSS2011 as csv 

library(tidyverse)

OUTFILE <-  "../data/literature_ES.csv"

#  Here are the means and sd based on SPSS2011 Table 1 (includes XT)
literature_df <- data.frame(exp_recoded = c("XT_adults_e1",
                                                      "XT_children_e2",
                                                      "SPSS_e1",
                                                      "SPSS_e2",
                                                      "SPSS_e3",
                                                      "SPSS_eS1",
                                                      "SPSS_eS2"),
                                      one_means = c(76, 40, 48.24, 30.83, 39.91, 24.56, 15.79), 
                                      three_means = c(9, 6, 10.53, 53.33, 51.75, 16.67, 11.40),
                                      one_sd = c(40.40, 40.40, 40.40, 37.18, 35.20, 32.09, 24.51),
                                      three_sd = c(24.97, 24.97, 24.97, 36.11, 42.63, 25.45, 24.25),
                                      n = c(22, 36, 19, 20, 19, 19, 19))

# Calculate previous effect sizes from literature.
effect_sizes <- compute.es::mes(literature_df$one_means/100,
                                           literature_df$three_means/100, 
                                           literature_df$one_sd/100,
                                           literature_df$three_sd/100,
                                           literature_df$n,
                                           literature_df$n, verbose = F) %>%
  select(d, l.d,u.d, var.d) %>%
  rename(high = u.d,
         low = l.d,
         d_var = var.d)

# bind together
literature_effect_sizes <- literature_df %>%
  select(exp_recoded, n) %>%
  bind_cols(effect_sizes)

write_csv(literature_effect_sizes, OUTFILE)
