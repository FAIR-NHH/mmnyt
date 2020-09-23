# This file is intended to concatenate the googletrends data.
library("tidyverse")
library("janitor")

virus <- read_csv(here::here("data","raw","20200923_googletrends-Virus.csv"), skip=2) %>% clean_names()
corona <- read_csv(here::here("data","raw","20200923_googletrends-Corona.csv"), skip=2) %>% clean_names()
covid <- read_csv(here::here("data","raw","20200923_googletrends-Covid.csv"), skip=2) %>% clean_names()

google_trends <- virus %>%
  left_join(corona, by="day") %>%
  left_join(covid, by="day") %>%
  rename(Virus = virus_united_states,
         Corona = corona_united_states,
         Covid = covid_united_states) %>%
  mutate(Covid = ifelse(Virus %in% c("0","<1"), "0", Virus),
         Covid = as.numeric(Covid)) %>%
  pivot_longer(Virus:Covid, names_to="search_term", values_to="searches")

saveRDS(google_trends, file=here::here("data","googletrends.rds"))
