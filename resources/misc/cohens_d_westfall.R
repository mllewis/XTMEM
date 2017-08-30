### Comparions to Jake Westfalls within ES measures

# our method is the same as his "Classic Cohen's d"

## his example
dat <- read_table2("effectSizePuzzler.txt")

means <- with(dat, tapply(rt, cond, mean)) 
means_dif <- means[2] - means[1] 
sd_pooled <- with(dat, sqrt(mean(tapply(rt, cond, var))))

means_dif/sd_pooled

## our data for one experiments (-> matches paper calculations)
ms2 <- ms %>%
  filter(exp == 2) %>%
  ungroup() %>%
  select(subids, condition, value) %>%
  mutate(condition = as.character(condition)) %>%
  filter(condition == "one" | condition == "three_subordinate") 

means <- with(ms2, tapply(value, condition, mean)) 
means_dif <- means[2] - means[1]
sd_pooled <- with(ms2, sqrt(mean(tapply(value, condition, var))))
  
means_dif/sd_pooled