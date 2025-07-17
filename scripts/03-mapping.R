#################################
#
# Mapping
#
# Author: Meltem Odabas
# Date: 2025-07-16
#
#####################################

# load libraries ----
library(readr)
library(dplyr)
library(tidycensus)
library(tmap)
library(sf)

# load data ----
df_tract_means <- read_csv(
  file.path("data", "phl_county_ shares_by_tract.csv")) %>%
  mutate(`FIPS Code` = as.character(`FIPS Code`))

# get tracts mapping data (ACS data + geometry) ----

df_tracts_sf <- get_acs(
  geography = "tract",
  variables = "B01003_001",  # total population as a placeholder
  state = "PA",
  county = "Philadelphia",
  geometry = TRUE,
  year = 2021
)


# merge mapping data on census data ----

df_tract_data_map <- df_tracts_sf %>%
  left_join(df_tract_means,
            by = c("GEOID" = "FIPS Code"))

#######################################
# Map vulnerabilities separately

# Map 1: Households with no vehicle
map_vehicle <- tm_shape(df_tract_data_map) +
  tm_polygons("perc_hhnovehicle",
              palette = "Reds",
              style = "quantile",
              title = "% No Vehicle") +
  tm_layout(title = "No Vehicle",
            legend.outside = FALSE)

# Map 2: Overcrowded housing
map_overcrowd <- tm_shape(df_tract_data_map) +
  tm_polygons("perc_hh_overcrowd",
              palette = "Purples",
              style = "quantile",
              title = "% Overcrowded") +
  tm_layout(title = "Overcrowded\nHousing",
            legend.outside = FALSE)

# Map 3: No high school diploma (approximate)
map_nohs <- tm_shape(df_tract_data_map) +
  tm_polygons("perc_approx_hs",
              palette = "Blues",
              style = "quantile",
              title = "% No HS Diploma") +
  tm_layout(title = "No HS Diploma",
            legend.outside = FALSE)

# Arrange maps side-by-side
map_vuln <- tmap_arrange(map_vehicle, map_overcrowd, map_nohs, ncol = 3)


#######################################
# Map vulnerabilities as a composite vulnerability index


# take min/max fir vulnerability vaiables (for normalization)
MIN_HHNOVEHICLE <- min(df_tract_means$perc_hhnovehicle, na.rm = TRUE)
MAX_HHNOVEHICLE <- max(df_tract_means$perc_hhnovehicle, na.rm = TRUE)

MIN_HHOVERCROWD <- min(df_tract_means$perc_hh_overcrowd, na.rm = TRUE)
MAX_HHOVERCROWD <- max(df_tract_means$perc_hh_overcrowd, na.rm = TRUE)

MIN_APPROXHS <- min(df_tract_means$perc_approx_hs, na.rm = TRUE)
MAX_APPROXHS <- max(df_tract_means$perc_approx_hs, na.rm = TRUE)


# Join to spatial data
df_tract_data_map_index <- df_tracts_sf %>%
  # Create simple unweighted index (z-scores or min-max normalize if preferred)
  left_join(df_tract_means %>%
              mutate(
                index_hh_hhnovehicle = (perc_hhnovehicle - MIN_HHNOVEHICLE) / 
                  (MAX_HHNOVEHICLE - MIN_HHNOVEHICLE),
                index_hh_overcrowd = (perc_hh_overcrowd - MIN_HHOVERCROWD) / 
                  (MAX_HHOVERCROWD - MIN_HHOVERCROWD),
                index_approx_hs = (perc_approx_hs - MIN_APPROXHS) / 
                  (MAX_APPROXHS - MIN_APPROXHS),
                index_vuln = (index_hh_hhnovehicle +
                                index_hh_overcrowd +
                                index_approx_hs) / 3) %>%
              select(`FIPS Code`,index_vuln),
            by = c("GEOID" = "FIPS Code"))

# Plot the index
map_index <- tm_shape(df_tract_data_map_index) +
  tm_polygons("index_vuln",
              palette = "Purples",
              style = "quantile",
              title = "Composite Vulnerability Index") +
  tm_layout(title = "Social Vulnerability Index by Tract",
            legend.outside = TRUE)

#######################################
# SAVE MAPS

tmap_save(map_vuln,
          filename = file.path("output",
                               "mapping",
                               "social_vulnerability_vars_map.png"),
          width = 10, height = 6)
tmap_save(map_index,
          filename = file.path("output",
                               "mapping",
                               "social_vulnerability_index_map.png"),
          width = 8, height = 6)




