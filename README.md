## U.S. International Trade Pattern interactive tool

The purpose of this project is to build a interactive App with RShiny based on the internatioanl trade data of U.S from 2015 to 2021.
This App aims to realize three functions maily:  1)a user‐friendly interactive dashboard 2) a dynamic worldwide map with multiple-year dimensions, and 3) a display platform for intuitive graphs and tables.

Internatioanl trade data are all obtained from [U.S. Census Bureau/ Foreign Trade](https://www.census.gov/foreign-trade/data/index.html). We use data from 'product detail and partner country' section(2015-2021) to construct the world trade map and realted graphs. Besides, we also use data from 'top 25 trading partner countries for each state' section(2015-2020) to devise the correspending states trade map.   

## Shiny interface

Follow [this](https://vac-lshtm.shinyapps.io/ncov_tracker/) link for the interactive Shiny app. A screenshot of the interface is provided below.

(<img src="./golbal_trade_map.png" alt="Shiny app interface" style="width: 600px;"/>)

## Analysis code

Key elements of the analysis code are as follows:
- *jhu_data_full.R* – an R script that extracts and reformats time-series from the [Johns Hopkins Center for Systems Science and Engineering github page](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series). The output files are saved in the *input_data* folder.
- *ny_data_us.R* – an R script that extracts and reformats time-series from the [New York Times github page](https://github.com/nytimes/covid-19-data). The output files are saved in the *input_data* folder.
- *app.R* - an R script used to render the Shiny app. This consists of several plotting functions as well as the ui (user interface) and server code required to render the Shiny app. The script has become more complex over time as a growing number of interactive features has been added.
- *input_data* - a folder containing dynamic input data relating to the evolving COVID-19 pandemic (updated by *jhu_data_full.R* and  *ny_data_us.R*) and static input data relating to past epidemics and country mapping coordinates.

## Updates

From 1st May 2020 onwards, this github page will no longer be updated daily. The [Shiny app](https://vac-lshtm.shinyapps.io/ncov_tracker/) automatically updates itself based on the code in *jhu_data_full.R* and *ny_data_us.R* and updated case data can be downloaded directly from the app via the 'Data' tab. To create up-to-date versions of the input data, users can clone this repository and run *jhu_data_full.R* and *ny_data_us.R* locally. Updated input data will also be uploaded to this github page at regular intervals.

From 3rd September onwards, the numbers of recovered cases are no longer plotted owing to large discrepancies in reporting rates among countries.

## Other resources

Several resources proved invaluable when building this app, including:
- A [tutorial by Florianne Verkroost](https://rviews.rstudio.com/2019/10/09/building-interactive-world-maps-in-shiny/) on building interactive maps;
- The [SuperZIP app](https://shiny.rstudio.com/gallery/superzip-example.html) and [associated code](https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example);
- The [RStudio Leaflet tutorials](https://rstudio.github.io/leaflet/).

## Authors
Dr Edward Parker, The Vaccine Centre, London School of Hygiene & Tropical Medicine

Quentin Leclerc, Department of Infectious Disease Epidemiology, London School of Hygiene & Tropical Medicine

## Contact
edward.parker@lshtm.ac.uk
