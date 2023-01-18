# orderly::orderly_develop_start("data_areas")
# setwd("src/data_areas")

unzip("depends/usa_shapefile.zip", exdir = "depends")
southern_13_areas <- st_read("depends/Southern_13_Albers.shp")
names(southern_13_areas)

#' Checking that this looks like the right geometry

pdf("shapefile-plot.pdf", h = 10, w = 12)

plot(southern_13_areas$geometry)

dev.off()

#' Save boundaries
write_sf(southern_13_areas, "southern13_areas.geojson")
