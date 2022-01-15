library(tidyverse)
library(geojsonio)
library(reshape2)
library(shiny)
library(treemap)
library(RColorBrewer)
library(leaflet)
library(shinythemes)
library(DT)

load("main_data/list_country.rda")
load("main_data/dtf_country_group.rda")

# set mapping colour for each year
col_2015 = "#cc4c02"
col_2016 = "#662506"
col_2017 = "#045a8d"
col_2018 = "#4d004b"
col_2019 = "#016c59"
col_2020 = "#7F5AA2"



# 1) sideplot: country_line
country_line = function(trade_type) {
  plot_df = data.frame(us_world_total)
  if(trade_type == "import"){ plotline = geom_smooth(mapping = aes(x = year, y = total_import_m, group = 1), color = '#D95F02')} else{
    plotline = geom_smooth(mapping = aes(x = year, y = total_export_m, group = 1), color = '#a6bddb')}
  g1 = ggplot(plot_df) + plotline + labs(x ="Year", y = "Total Trade Volume (USD_m)")
  g1
}

# 2) sideplot: counterparty_treemap
 counterparty_treemap = function(topn, trade_type){
  if(trade_type == "import"){
  plot_df = data.frame( df_background[c("country", "avg_import_m")]) %>% top_n(topn, df_background$avg_import_m ) 
  treemap(plot_df, index = "country", vSize = "avg_import_m", title ="",  palette = "Oranges")} else{
  plot_df = data.frame( df_background[c("country", "avg_export_m")]) %>% top_n(topn, df_background$avg_export_m) 
  treemap(plot_df, index = "country", vSize = "avg_export_m", title ="", palette = "Blues")}} 

# create plotting parameters for map
 bins = c(0, 100, 1000, 5000, 10000, 50000,Inf)
 export_pal <- colorBin("Blues", domain = df_background$avg_export_m, bins = bins)
 import_pal <- colorBin("Oranges", domain = df_background$avg_import_m, bins = bins)
 
# create basic trade map

export_map = leaflet(world_map) %>%
  addTiles() %>%
  addLayersControl(
    position = "bottomright",
    overlayGroups = c(2015, 2016, 2017, 2018, 2019, 2020),
    options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup(c(2016, 2017, 2018, 2019, 2020)) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  fitBounds(~-100,-60,~60,70) %>%
  addLegend("topright", pal = export_pal, values = ~df_background$avg_export_m,
            title = "<small>Export Volume in USD million</small>") %>% 
  addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 0.5, 
              fillColor = ~export_pal(df_background$avg_export_m))  
  

import_map = leaflet(world_map) %>% 
  addTiles() %>% 
  addLayersControl(
    position = "bottomright",
    overlayGroups = c(2015, 2016, 2017, 2018, 2019, 2020),
    options = layersControlOptions(collapsed = FALSE)) %>% 
  hideGroup(c(2016, 2017, 2018, 2019, 2020)) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  fitBounds(~-100,-60,~60,70) %>%
  addLegend("topright", pal = import_pal, values = ~df_background$avg_import_m,
            title = "<small>Import Volume in USD million</small>")

# 2.state level function
# 1) sideplot: state_line
state_line = function(trade_type) {
  plot_df = data.frame(state_total)
  if(trade_type == "import"){ plotline = geom_smooth(mapping = aes(x = year, y = imports, group = 1), color = '#D95F02')} else{
    plotline = geom_smooth(mapping = aes(x = year, y = exports, group = 1), color = '#a6bddb')}
  g1 = ggplot(plot_df) + plotline + labs(x ="Year", y = "Total Trade Volume (USD_m)")
  g1
}

# 2) treemap for state level
treemap_state = function(topn, trade_type){
  if(trade_type == "import"){
    plot_df = data.frame( state_background[c("state", "avrg_import")]) %>% top_n(topn, state_background$avrg_import) 
    treemap(plot_df, index = "state", vSize = "avrg_import", title ="",  palette = "Oranges")} else{
      plot_df = data.frame( state_background[c("state", "avrg_export")]) %>% top_n(topn, state_background$avrg_export) 
      treemap(plot_df, index = "state", vSize = "avrg_export", title ="", palette = "Blues")}}

# 3) the change of states from 2015 to 2018
state_time_series <- function(name, trade_type){
  if(trade_type == "import"){
    import_tot_tidy %>% 
      filter(State == name) %>% 
      ggplot(aes(year, values, group = 1)) +
      geom_line() +
      geom_smooth(mapping = aes(x = year, y = values , group = 1), color = '#D95F02') +
      labs(x ="Year", y = "Trade Volume (USD_m)")
  }else{
    export_tot_tidy %>% 
      filter(State == name) %>% 
      ggplot(aes(year, values, group = 1)) +
      geom_line() +
      geom_smooth(mapping = aes(x = year, y = values, group = 1), color = '#a6bddb') +
      labs(x ="Year", y = "Trade Volume (USD_m)")
  }
}

# 4) create plotting parameters for state map
bins = c(0, 100, 1000, 5000, 10000, 50000,Inf)
export_pal_state <- colorBin("Blues", domain = state_background$avrg_export, bins = bins)
import_pal_state <- colorBin("Oranges", domain = state_background$avrg_import, bins = bins)

# 5) create basic map for state level
export_map_state = leaflet(states_js) %>%
  addTiles() %>%
  addLayersControl(
    position = "bottomright",
    options = layersControlOptions(collapsed = FALSE)) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  fitBounds(~-100,-60,~60,70) %>%
  addLegend("topright", pal = export_pal_state, values = ~state_background$avrg_export,
            title = "<small>Export Volume in USD million</small>") %>% 
  addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 0.5, 
              fillColor = ~export_pal_state(state_background$avrg_export))

import_map_state = leaflet(states_js) %>%
  addTiles() %>%
  addLayersControl(
    position = "bottomright",
    options = layersControlOptions(collapsed = FALSE)) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  fitBounds(~-100,-60,~60,70) %>%
  addLegend("topright", pal = import_pal_state, values = ~state_background$avrg_import,
            title = "<small>Import Volume in USD million</small>") %>% 
  addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 0.5, 
              fillColor = ~import_pal_state(state_background$avrg_import))

###########################################################################
ui <- bootstrapPage(
  navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
             HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">US International Trade Pattern Visualization</a>'), id="nav",
             windowTitle = "US International Trade map Visualization",
             
             tabPanel("Global Trade Map",
                      div(class="outer",
                          tags$head(includeCSS("original_data/styles.css")),
                          leafletOutput("mymap", width="90%", height="90%"),
                          absolutePanel(id = "controls", class = "panel panel-default",
                                        top = 50, left = 30, width = 320, fixed= FALSE,
                                        draggable = TRUE, height = "auto",
                                        
                                        span(tags$i(h4("Internation trade data are subject to significant variation in political and economic environment worldwide.")), style="color:#045a8d"),
                                        
                                        selectInput("trade_type",
                                                    label = h4("please select trade type"),
                                                    choices = c("export", "import")),
                                        
                                        plotOutput("country_line", height="150px", width="100%"),
                                        
                                        sliderInput(inputId = "top_n",
                                                    label = h4("please select the top N trade counterparties"),
                                                    max = 10,
                                                    min = 1,
                                                    value = 5),
                                        
                                        plotOutput("counterparty_treemap", height="200px", width="100%")
                                        )
                                        
                          )
             ),
             
             tabPanel("States Trade Map",
                      div(class="outer",
                          tags$head(includeCSS("original_data/styles.css")),
                          leafletOutput("mymap2", width="90%", height="90%"),
                          absolutePanel(id = "controls", class = "panel panel-default",
                                        top = 50, left = 30, width = 480, fixed= FALSE,
                                        draggable = TRUE, height = "auto",
                                        
                                        span(tags$i(h4("Various states play different roal in the international trade patterns.")), style="color:#045a8d"),
                                        
                                        selectInput("state_trade_type",
                                                    label = h4("please select trade type"),
                                                    choices = c("export", "import")),
                                        
                                        plotOutput("state_line", height="150px", width="100%"),
                                        sliderInput(inputId = "top_n_state",
                                                    label = h4("please select the top N state"),
                                                    max = 10,
                                                    min = 1,
                                                    value = 5),
                                        
                                        plotOutput("treemap_state", height="150px", width="100%"),
                                        selectInput(inputId = "state_name",
                                                    label = h4("please choose state to plot from 2015 to 2018"),
                                                    choices = c("Alabama", "Alaska", "Arizona",
                                                                "Arkansas",	"California",	"Colorado",
                                                                "Connecticut"	,"Delaware",	"District of Columbia",
                                                                "Florida",	"Georgia",	"Hawaii",	"Idaho",
                                                                "Illinois",	"Indiana",	"Iowa",
                                                                "Kansas",	"Kentucky",	"Louisiana",
                                                                "Massachusetts",	"Maryland",	"Maine",
                                                                "Michigan",	"Minnesota",	"Missouri",
                                                                "Mississippi",	"Montana",	"North Carolina",
                                                                "North Dakota",	"Nebraska",	"New Hampshire",
                                                                "New Jersey",	"New Mexico",	"Nevada",
                                                                "New York",	"Ohio","Oklahoma",
                                                                "Oregon",	"Pennsylvania",	"Puerto Rico",
                                                                "Rhode Island",	"South Carolina",	"South Dakota",
                                                                "Tennessee",	"Texas",	"Utah",
                                                                "Virginia",	"Virgin Islands",	"Vermont",
                                                                "Washington",	"Wisconsin",	"West Virginia", "Wyoming")),
                                        
                                        plotOutput("state_time_series", height="150px", width="100%")
                                        
                          )
                          
                      )),
             
             tabPanel("Data",
                      fluidPage(
                        sidebarLayout(
                          sidebarPanel(
                            width = 3,
                            selectInput(
                              width = "100%",
                              inputId = "dataset_list",
                              label = "check the original data here",
                              choices = c(choose = "List of data frame...",
                                          "data for global trade map", "data for national trade map"),
                              selectize = FALSE
                            )),
                            mainPanel(
                        fluidRow(
                        column(12,
                               DT::dataTableOutput("dataSet"))
                      )))
             ),
             tags$br(),tags$br(),
             "For more data about US international trade, please visit ", tags$a(href="https://www.census.gov/foreign-trade/index.html", 
                                                                "U.S. Census Bureau/ Foreign Trade")
             
  )
  )
)


### SHINY SERVER ###

server = function(input, output, session) {
  
  # global trade map 
    reactive_db = reactive({df_background})

    reactive_db_large = reactive({
    large_countries = reactive_db() %>% filter(alpha3 %in% worldmap$ADM0_A3)
    worldmap_subset = worldmap[worldmap$ADM0_A3 %in% df_background$alpha3, ]
    large_countries = large_countries[match(worldmap_subset$ADM0_A3, large_countries$alpha3),]
    large_countries
  })
    
    reactive_polygons = reactive({
    worldmap[worldmap$ADM0_A3 %in% reactive_db_large()$alpha3, ]
  })
    
  observeEvent(input$trade_type, {
    if (input$trade_type == "export"){
      output$mymap <- renderLeaflet({export_map})
      leafletProxy("mymap") %>% 
        clearMarkers() %>%
        clearShapes() %>%
        
        addPolygons(data = reactive_polygons(), stroke = FALSE, smoothFactor = 0.2, fillOpacity = 0.35,
                    fillColor = ~export_pal(reactive_db_large()$avg_export_m)) %>%
        
        
        addCircleMarkers(data = us_country_sum_2015, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_export_m/7000), 
                         fillOpacity = 0.2, color = col_2015, group = "2015",
                         label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2015$country, us_country_sum_2015$total_import_m, us_country_sum_2015$total_export_m, us_country_sum_2015$import_share, us_country_sum_2015$export_share) %>% lapply(htmltools::HTML),
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2015),
                           textsize = "15px", direction = "auto")) %>%
        
        addCircleMarkers(data = us_country_sum_2016, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_export_m/7000), 
                         fillOpacity = 0.2, color = col_2016, group = "2016",
                         label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2016$country, us_country_sum_2016$total_import_m, us_country_sum_2016$total_export_m, us_country_sum_2016$import_share, us_country_sum_2016$export_share) %>% lapply(htmltools::HTML),
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2016),
                           textsize = "15px", direction = "auto")) %>%
        
        addCircleMarkers(data = us_country_sum_2017, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_export_m/7000), 
                         fillOpacity = 0.2, color = col_2017, group = "2017",
                         label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2017$country, us_country_sum_2017$total_import_m, us_country_sum_2017$total_export_m, us_country_sum_2017$import_share, us_country_sum_2017$export_share) %>% lapply(htmltools::HTML),
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2017),
                           textsize = "15px", direction = "auto")) %>%
        
        addCircleMarkers(data = us_country_sum_2018, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_export_m/7000), 
                         fillOpacity = 0.2, color = col_2018, group = "2018",
                         label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2018$country, us_country_sum_2018$total_import_m, us_country_sum_2018$total_export_m, us_country_sum_2018$import_share, us_country_sum_2018$export_share) %>% lapply(htmltools::HTML),
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2018),
                           textsize = "15px", direction = "auto")) %>%
        
        addCircleMarkers(data = us_country_sum_2019, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_export_m/7000), 
                         fillOpacity = 0.2, color = col_2019, group = "2019",
                         label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2019$country, us_country_sum_2019$total_import_m, us_country_sum_2019$total_export_m, us_country_sum_2019$import_share, us_country_sum_2019$export_share) %>% lapply(htmltools::HTML),
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2019),
                           textsize = "15px", direction = "auto")) %>%
        
        addCircleMarkers(data = us_country_sum_2020, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_export_m/7000), 
                         fillOpacity = 0.2, color = col_2020, group = "2020",
                         label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2020$country, us_country_sum_2020$total_import_m, us_country_sum_2020$total_export_m, us_country_sum_2020$import_share, us_country_sum_2020$export_share) %>% lapply(htmltools::HTML),
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2020),
                           textsize = "15px", direction = "auto"))
    }
    else{
    if(input$trade_type == "import"){
      output$mymap <- renderLeaflet({import_map })
      
    leafletProxy("mymap") %>% 
      clearMarkers() %>%
      clearShapes() %>%

      addPolygons(data = reactive_polygons(), stroke = FALSE, smoothFactor = 0.2, fillOpacity = 0.35,
                  fillColor = ~import_pal(reactive_db_large()$avg_import_m)) %>%

      addCircleMarkers(data = us_country_sum_2015, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_import_m/12000), 
                       fillOpacity = 0.2, color = col_2015, group = "2015",
                       label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2015$country, us_country_sum_2015$total_import_m, us_country_sum_2015$total_export_m, us_country_sum_2015$import_share, us_country_sum_2015$export_share) %>% lapply(htmltools::HTML),
                       labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2015),
                         textsize = "15px", direction = "auto")) %>%

      addCircleMarkers(data = us_country_sum_2016, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_import_m/12000), 
                       fillOpacity = 0.2, color = col_2016, group = "2016",
                       label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2016$country, us_country_sum_2016$total_import_m, us_country_sum_2016$total_export_m, us_country_sum_2016$import_share, us_country_sum_2016$export_share) %>% lapply(htmltools::HTML),
                       labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2016),
                         textsize = "15px", direction = "auto")) %>%
      
      addCircleMarkers(data = us_country_sum_2017, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_import_m/12000), 
                       fillOpacity = 0.2, color = col_2017, group = "2017",
                       label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2017$country, us_country_sum_2017$total_import_m, us_country_sum_2017$total_export_m, us_country_sum_2017$import_share, us_country_sum_2017$export_share) %>% lapply(htmltools::HTML),
                       labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2017),
                         textsize = "15px", direction = "auto")) %>%
      
      addCircleMarkers(data = us_country_sum_2018, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_import_m/12000), 
                       fillOpacity = 0.2, color = col_2018, group = "2018",
                       label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2018$country, us_country_sum_2018$total_import_m, us_country_sum_2018$total_export_m, us_country_sum_2018$import_share, us_country_sum_2018$export_share) %>% lapply(htmltools::HTML),
                       labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2018),
                         textsize = "15px", direction = "auto")) %>%
      
      addCircleMarkers(data = us_country_sum_2019, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_import_m/12000), 
                       fillOpacity = 0.2, color = col_2019, group = "2019",
                       label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2019$country, us_country_sum_2019$total_import_m, us_country_sum_2019$total_export_m, us_country_sum_2019$import_share, us_country_sum_2019$export_share) %>% lapply(htmltools::HTML),
                       labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2019),
                         textsize = "15px", direction = "auto")) %>%
      
      addCircleMarkers(data = us_country_sum_2020, lat = ~ latitude, lng = ~ longitude, weight = 1, radius = ~(total_import_m/12000), 
                       fillOpacity = 0.2, color = col_2020, group = "2020",
                       label = sprintf("<strong>%s</strong><br/>import million  %g<br/>export million %g<br/>import percent %s<br/>export percent %s", us_country_sum_2020$country, us_country_sum_2020$total_import_m, us_country_sum_2020$total_export_m, us_country_sum_2020$import_share, us_country_sum_2020$export_share) %>% lapply(htmltools::HTML),
                       labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px", "color" = col_2020),
                         textsize = "15px", direction = "auto")) 
    }
    }
  })
  
  output$country_line <- renderPlot({
    country_line(input$trade_type)
  })

  observeEvent(input$trade_type, {
  output$counterparty_treemap <- renderPlot({
    counterparty_treemap(input$top_n, input$trade_type)
  })
  })
  
  # national level
  observeEvent(input$state_trade_type, {
    if (input$state_trade_type == "export"){
      output$mymap2 <- renderLeaflet({export_map_state})}
    else{if(input$state_trade_type == "import"){
        output$mymap2 <- renderLeaflet({import_map_state })}}
      })
  
  output$state_line <- renderPlot({
    state_line(input$state_trade_type)
  })
  
  observeEvent(input$state_trade_type, {
    output$treemap_state <- renderPlot({
      treemap_state(input$top_n_state, input$state_trade_type)
    })
  })
  
  observeEvent(input$state_name, {
    output$state_time_series <- renderPlot({
      state_time_series(name = c(input$state_name), input$state_trade_type)
    })
  })
  
  # dataset
  values <- reactiveValues(tbl=NULL)
  
  observeEvent(input$dataset_list, {
    if(input$dataset_list == "data for global trade map"){
      values$tbl <- us_country_sum}
    else{values$tbl <- data_tab_state}
      output$dataSet <- DT::renderDataTable({
        tryCatch({
          df <- values$tbl
        },
        error = function(e) {
          stop(safeError(e))
        })
      },
      extensions = c('Scroller', 'FixedColumns'),
      options = list(
        deferRender = TRUE,
        scrollX = TRUE,
        scrollY = 400,
        scroller = TRUE,
        dom = 'Bfrtip',
        fixedColumns = TRUE
      ))
  } )
}


shinyApp(ui, server)
