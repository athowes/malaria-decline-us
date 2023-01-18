# orderly::orderly_develop_start("process_county-characteristics")
# setwd("process_county-characteristics")

usa_data <- read_csv("depends/malariadata.csv")

#' County characteristics
#' * county_area (and _acres): (Alex)	Acres in county
#' * mean_slope: (Alex)	Mean slope
#' * mean_elevation_m: (Alex) Mean elevation
#' * mean_dist_coastline_m:	(Alex) Distance from coastline
#' * mean_dist_inland_water_m: (Alex)	Distance from inland water
#' * mean_dist_waterway_m: (Alex)	Distance from waterway

#' No year information!

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("country_area"), #' Y
    starts_with("country_acres"), #' N
    starts_with("mean_slope"), #' Y
    starts_with("mean_elevation_m"), #' Y
    starts_with("mean_dist_coastline_m"), #' Y
    starts_with("mean_dist_inland_water_m"), #' Y
    starts_with("mean_dist_waterway_m") #' Y
  )

names(df)

#' There are no time points for these covariates
df_urbanisation <- df

write_csv(df_urbanisation, "processed-covariates.csv", na = "")
