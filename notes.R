
library(ggplot2)
library(lubridate)
load('./data/testdata.RData')

map <- function(name) {
    switch(name,
           "Controller/chart_data/metric_charts/app_breakdown"= '/browse.html',
           "Controller/chart_data/metric_charts/error_rate"='/add.html',
           "Controller/chart_data/metric_charts/single_metric"='/save.html',
           "Controller/current_status/status_bar"='/checkout.do',
           "HttpDispatcher"='Throughput',
           '/browse.html'='/browse.html',
           '/add.html'='/add.html',
           '/save.html'='/save.html',
           '/checkout.do'='/checkout.do',
           'Throughput'='Throughput')
}

signal$name <- sapply(signal$name, map,USE.NAMES = F)
baseline$summary_values$name <-sapply(baseline$summary_values$name, map, USE.NAMES = F)

names(baseline$metrics) <- sapply(names(baseline$metrics), map, USE.NAMES = F)
baseline$baseline$name <- sapply(baseline$baseline$name, map,USE.NAMES = F)

# Remove Throughput and Checkout
preferred <- function(name) {
    !(name %in% c('Throughput', '/checkout.do'))
}

signal <- filter(signal, preferred(name))
baseline$summary_values <- filter(baseline$summary_values, preferred(name))
baseline$metrics <- baseline$metrics[preferred(names(baseline$metrics))]
baseline$baseline <- filter(baseline$baseline, preferred(name))

save(signal, baseline, file='./data/testdata.RData')
