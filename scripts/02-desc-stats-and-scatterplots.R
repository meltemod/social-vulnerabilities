#################################
#
# Desc stats and scatter plots
#
# Author: Meltem Odabas
# Date: 2025-07-16
#
#####################################

# load packages ----
library(tidyverse)

# load data ----
df_county_summary <- read_csv(
  file.path("data", "phl_county_desc_stats.csv"))

df_tract_means <- read_csv(
  file.path("data", "phl_county_ shares_by_tract.csv"))


# Pplot for demography shares and social vulnerability proxies

  

df_combined <- df_county_summary %>%
  filter(Variable %in% c("Ppl Below 150% Poverty", "BIPOC Residents",
                         "Households with no vehicle",
                         "Percent of Overcrowded Housing Units",
                         "People 25+ w/o high school diploma")) %>%
  mutate(
    Type = case_when(
      Variable %in% c("Ppl Below 150% Poverty", "BIPOC Residents") ~ "Demographic",
      TRUE ~ "Vulnerability"
    ),
    Color = case_when(
      Type == "Demographic" ~ "#97a7b8",
      Type == "Vulnerability" ~ "#595460"
    )
  )



p_combined <- ggplot(df_combined, aes(x = fct_reorder(Variable, perc), y = perc)) +
  geom_col(aes(fill = Color), width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(perc, 1), "%")), 
            hjust = -0.1, size = 3.5) +
  coord_flip() +
  ylim(0, 100) +
  facet_wrap(~ Type, scales = "free_y", ncol = 1) +
  scale_fill_identity() +
  labs(title = "Demographic and Vulnerability\nCharacteristics of\nPhiladelphia County",
       x = NULL, y = "Percent of Population or Households") +
  theme_minimal() +
  theme(
    strip.text = element_text(hjust = 0, face = "bold"), 
    strip.background = element_blank()  
  )


############################
# Prep tract-level data (long format)
df_tract_vuln <- df_tract_means %>%
  select(`FIPS Code`, perc_hhnovehicle, perc_hh_overcrowd, perc_approx_hs) %>%
  pivot_longer(cols = -`FIPS Code`, names_to = "Indicator", values_to = "Value") %>%
  mutate(Indicator = case_when(
    Indicator == "perc_hhnovehicle" ~ "No Vehicle Access",
    Indicator == "perc_hh_overcrowd" ~ "Overcrowded Housing",
    Indicator == "perc_approx_hs" ~ "No HS Diploma (25+)"
  ))

# Get county-level means for those variables (in % terms)
df_county_means <- df_county_summary %>%
  filter(Variable %in% c("Households with no vehicle",
                         "Percent of Overcrowded Housing Units",
                         "People 25+ w/o high school diploma")) %>%
  mutate(Indicator = case_when(
    Variable == "Households with no vehicle" ~ "No Vehicle Access",
    Variable == "Percent of Overcrowded Housing Units" ~ "Overcrowded Housing",
    Variable == "People 25+ w/o high school diploma" ~ "No HS Diploma (25+)"
  ))

# Plot
p_tract_vuln <- ggplot(df_tract_vuln, aes(x = Value, y = Indicator)) +  # convert to percent
  geom_jitter(height = 0.2, color = "#fcbba1", alpha = 0.6, size = 1.5) +  # tract dots
  geom_point(data = df_county_means, aes(x = perc, y = Indicator),
             color = "#99000d", size = 4) +  # county mean
  labs(title = "Tract-Level Variation in Social Vulnerability",
       x = "Percent", y = NULL) +
  theme_minimal() +
  xlim(0, 100)

##############################################################
# Tract level corr scatterplots

# Prepare full data set for plotting
df_tract_corr <- df_tract_means %>%
  select(`FIPS Code`,
         perc_bipoc, perc_belowpov150,
         perc_hhnovehicle, perc_hh_overcrowd, perc_approx_hs) %>%
  rename(
    `% BIPOC` = perc_bipoc,
    `% Below Poverty` = perc_belowpov150,
    `% No Vehicle` = perc_hhnovehicle,
    `% Overcrowded Housing` = perc_hh_overcrowd,
    `% No HS Diploma (25+)` = perc_approx_hs
  ) %>%
  pivot_longer(cols = c(`% No Vehicle`, `% Overcrowded Housing`, `% No HS Diploma (25+)`),
               names_to = "Vulnerability", values_to = "VulnValue") %>%
  pivot_longer(cols = c(`% BIPOC`, `% Below Poverty`),
               names_to = "Demographic", values_to = "DemoValue")

# Generate plot
p_tract_corr <- ggplot(df_tract_corr, aes(x = DemoValue, y = VulnValue)) +
  geom_point(color = "#fcbba1", alpha = 0.6, size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, color = "#99000d", linewidth = 1) +
  facet_grid(Vulnerability ~ Demographic, scales = "free") +
  labs(title = "Correlation Between Demographics and\nVulnerability Indicators",
       x = "Demographic (%)", y = "Vulnerability (%)") +
  theme_minimal() +
  xlim(0, 100) + ylim(0, 100)

#######################################
# SAVE PLOTS

# Save desc stats at county level
ggsave(file.path("output",
                 "desc-plots",
                 "phl_county_desc_stats.png"),
       plot = p_combined,
       width = 5, height = 5, dpi = 300)


# Save the correlation plot
ggsave(file.path("output",
                 "desc-plots",
                 "correlation_demographics_vulnerability.png"),
       plot = p_tract_corr,
       width = 6.5, height = 5, dpi = 300)
