library(tidyverse)
library(readxl)
library(xlsx)
library(zipcodeR)
library(scales)
library(shinyWidgets)
library(tigris)
library(dplyr)
library(leaflet)
library(geojsonio)


### step1 import and tidy data

us_data = read_excel('original_data/sitc115presdigit.xlsx')
countries_coordinates <- read.csv('main_data/countries_codes_and_coordinates.csv')
us_data = us_data[, c(1 : 4, 41, 42)]
names(us_data) <-  c("year", "SITC", "class", "country", "export", "import")
export = read_csv('original_data/export.csv')
import = read_csv('original_data/import.csv')
states <- states(cb=T)
state_geo <- read.csv('original_data/state_lat_long.csv')
states_js <- geojson_read(x = "https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/us-states.json", what = "sp")


### step 2 prepare data for Rshiny - us global country data
worldmap = geojson_read("main_data/50m.geojson", what = "sp")

us_country_sum <- group_by(us_data, year, country) %>% summarize(total_export = sum(export), total_import = sum(import))

us_world_total <- filter(us_country_sum, country == "World Total")  

us_country_sum <- merge(us_country_sum, us_world_total, by = "year" ) %>% mutate(export_share = label_percent(accuracy =0.01)(total_export.x/total_export.y),
                                                                                 import_share = label_percent(accuracy =0.01)(total_import.x/total_import.y),
                                                                                 total_export_m = total_export.x/1000000,
                                                                                 total_import_m = total_import.x/1000000)

us_world_total <-mutate(us_world_total, total_export_m = total_export/1000000, total_import_m = total_import/1000000)
  
us_country_sum <- us_country_sum[, -c(5:7)] 

names(us_country_sum) <- c("year", "country", "total_export", "total_import", "export_share", "import_share", "total_export_m", "total_import_m")


us_country_sum <- filter(us_country_sum, !(country == "World Total")) %>% inner_join(countries_coordinates, by = "country")
world_map <- worldmap[worldmap$ADM0_A3 %in% us_country_sum$alpha3, ]
us_country_sum <- filter(us_country_sum, us_country_sum$alpha3 %in% worldmap$ADM0_A3)

df_background <- group_by(us_country_sum, country, alpha3, latitude, longitude) %>% summarize(avg_export_m = mean(total_export_m), avg_import_m = mean(total_import_m))
df_background <- df_background[order(df_background$alpha3),]

us_country_sum_2015 <- filter(us_country_sum, year == 2015)
us_country_sum_2016 <- filter(us_country_sum, year == 2016)
us_country_sum_2017 <- filter(us_country_sum, year == 2017)
us_country_sum_2018 <- filter(us_country_sum, year == 2018)
us_country_sum_2019 <- filter(us_country_sum, year == 2019)
us_country_sum_2020 <- filter(us_country_sum, year == 2020)




### step 3 prepare for the national level data
## create state_total
# chose world value for export and import
export$rank <- as.integer(export$rank)
export$val2018 <- as.integer(export$val2018)
export$val2015 <- as.integer(export$val2015)
export$val2016 <- as.integer(export$val2016)
export$val2017 <- as.integer(export$val2017)
export <- subset(export, export$countryd=="World")
import$rank <- as.integer(import$rank)
import$val2018 <- as.integer(import$val2018)
import$val2015 <- as.integer(import$val2015)
import$val2016 <- as.integer(import$val2016)
import$val2017 <- as.integer(import$val2017)
import <- subset(import, import$countryd=="World")

# chose year from 2015 to 2016
export_tot <- subset(export, select = c("statename","val2015","val2016","val2017", "val2018"))
import_tot <- subset(import, select = c("statename","val2015","val2016","val2017", "val2018"))

# rename
names(export_tot)[names(export_tot) == 'statename'] <- 'state'
names(export_tot)[names(export_tot) == 'val2015'] <- '2015'
names(export_tot)[names(export_tot) == 'val2016'] <- '2016'
names(export_tot)[names(export_tot) == 'val2017'] <- '2017'
names(export_tot)[names(export_tot) == 'val2018'] <- '2018'
names(import_tot)[names(import_tot) == 'statename'] <- 'state'
names(import_tot)[names(import_tot) == 'val2015'] <- '2015'
names(import_tot)[names(import_tot) == 'val2016'] <- '2016'
names(import_tot)[names(import_tot) == 'val2017'] <- '2017'
names(import_tot)[names(import_tot) == 'val2018'] <- '2018'

# calculate the total value
export_sum_2015 <- as.integer(sum(export_tot[, '2015']) / 1000)
export_sum_2016 <- as.integer(sum(export_tot[, '2016']) / 1000)
export_sum_2017 <- as.integer(sum(export_tot[, '2017']) / 1000)
export_sum_2018 <- as.integer(sum(export_tot[, '2018']) / 1000)
import_sum_2015 <- as.integer(sum(import_tot[, '2015']) / 1000)
import_sum_2016 <- as.integer(sum(import_tot[, '2016']) / 1000)
import_sum_2017 <- as.integer(sum(import_tot[, '2017']) / 1000)
import_sum_2018 <- as.integer(sum(import_tot[, '2018']) / 1000)

# create state_total
year <- c("2015", "2016", "2017", "2018")
exports <- c(export_sum_2015, export_sum_2016, export_sum_2017, export_sum_2018)
imports <- c(import_sum_2015, import_sum_2016, import_sum_2017, import_sum_2018)
state_total = data.frame(year, exports, imports)

## create state_background
# calculate the average value
export_tot$avrg_export <- as.integer(rowMeans(export_tot[,c('2015', '2016', '2017', '2018')], na.rm=TRUE))
import_tot$avrg_import <- as.integer(rowMeans(import_tot[,c('2015', '2016', '2017', '2018')], na.rm=TRUE))

# join df
names(states)[names(states) == 'NAME'] <- 'state'
avrg_export_state <- subset(export_tot, select = c("state", "avrg_export"))
avrg_import_state <- subset(import_tot, select = c("state", "avrg_import"))
state_background <- left_join(avrg_export_state, avrg_import_state, by = "state")
state_background <- left_join(state_background, states, by = "state")


## create export_tot_tidy and import_tot_tidy
export_tot_tidy <- gather(export_tot, "year", "values", 2:5)
import_tot_tidy <- gather(import_tot, "year", "values", 2:5)
names(export_tot_tidy)[names(export_tot_tidy) == 'state'] <- 'State'
names(import_tot_tidy)[names(import_tot_tidy) == 'state'] <- 'State'

## data to the 3rd tab
names(export_tot)[names(export_tot) == '2015'] <- '2015ex'
names(export_tot)[names(export_tot) == '2016'] <- '2016ex'
names(export_tot)[names(export_tot) == '2017'] <- '2017ex'
names(export_tot)[names(export_tot) == '2018'] <- '2018ex'
names(import_tot)[names(import_tot) == '2015'] <- '2015im'
names(import_tot)[names(import_tot) == '2016'] <- '2016im'
names(import_tot)[names(import_tot) == '2017'] <- '2017im'
names(import_tot)[names(import_tot) == '2018'] <- '2018im'
data_tab_state <- left_join(export_tot, import_tot, by = "state")

