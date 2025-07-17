#################################
#
# Prep Data for Analysis
#
# Author: Meltem Odabas
# Date: 2025-07-16
#
#####################################

# load packages ----
library(tidyverse)

# define parameters ----
FILEPATH <- file.path("raw_data",
                      "iteam-exercise-data.csv")

VARS <- c("Population",
          "Housing Units",
          "Households",
          "Ppl Below 150% Poverty",
          "BIPOC Residents",
          "Households with no vehicle",
          "Percent of Overcrowded Housing Units",
          "People 25+ w/o high school diploma")

EST_25PLUS_PERC <- 0.7 

######################################
# STEP 1: load data and filter to Philadelphia Country

df <- read_csv(FILEPATH) %>%
  filter(grepl("Philadelphia", County))

#######################################
# STEP 2: present stats at county level

county_summary <- map_dfr(VARS, function(var) {
  tibble(
    Variable = var,
    Mean = mean(df[[var]], na.rm = TRUE),
    Median = median(df[[var]], na.rm = TRUE),
    SD = sd(df[[var]], na.rm = TRUE),
    N = sum(!is.na(df[[var]]))
  )
})


# Extract denominator values from county_summary
pop_mean   <- county_summary %>% filter(Variable == "Population") %>% pull(Mean)
hunit_mean <- county_summary %>% filter(Variable == "Housing Units") %>% pull(Mean)
hh_mean    <- county_summary %>% filter(Variable == "Households") %>% pull(Mean)

# Add share column based on corresponding denominator
county_summary <- county_summary %>%
  mutate(perc = case_when(
    Variable == "Ppl Below 150% Poverty" ~ 100 * Mean / pop_mean,
    Variable == "BIPOC Residents" ~ 100 * Mean / pop_mean,
    Variable == "Households with no vehicle" ~ 100 * Mean / hh_mean,
    Variable == "Percent of Overcrowded Housing Units" ~ Mean,
    Variable == "People 25+ w/o high school diploma" ~ 
      100 * (1 / EST_25PLUS_PERC) * (Mean / hunit_mean),
    TRUE ~ NA_real_
  ))

print(county_summary)

#######################################
# STEP 3: present means for each tract

tract_means_long <- map_dfr(VARS, function(var) {
  df %>%
    group_by(`FIPS Code`) %>%  # change to your actual tract column name
    summarize(
      Variable = var,
      Mean = mean(.data[[var]], na.rm = TRUE),
      .groups = "drop"
    )
})


tract_means <- tract_means_long %>%
  pivot_wider(names_from = Variable,
              values_from = Mean) %>%
  mutate(perc_belowpov150 = 100 * `Ppl Below 150% Poverty` / Population,
         perc_bipoc = 100 * `BIPOC Residents` / Population,
         perc_hhnovehicle = 100 * `Households with no vehicle` / Households,
         perc_approx_hs = 100 * (1 / EST_25PLUS_PERC) * 
           (`People 25+ w/o high school diploma` / Population)) %>%
  rename(perc_hh_overcrowd = `Percent of Overcrowded Housing Units`) %>%
  select(`FIPS Code`,
         starts_with("perc"))
#################################
# Save data

write_csv(county_summary,
          file.path("data", "phl_county_desc_stats.csv"))

write_csv(tract_means,
          file.path("data", "phl_county_ shares_by_tract.csv"))
          
          






