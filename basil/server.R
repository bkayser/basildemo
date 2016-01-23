library(shiny)
library(ggplot2)
library(lubridate)
testfile <- '../data/testdata.RData'

# Load signal and baseline datasets
load(file=testfile)

# Define server logic required to draw the metric plots
shinyServer(function(input, output) {

    output$charts <- renderPlot({
        r <- threshold_eval(signal,
                            lead_time=input$leadin,
                            num_sigmas = input$nsigma)  
        
        ggplot(r) + aes(x=start, y=value) + 
            geom_line() +
            facet_grid(name ~ .,scales = 'free_y') +
            geom_step(aes(y=baseline), color='#669900') +
            geom_rect(aes(xmin=start, xmax=start+minutes(1), alpha=trigger, 
                          ymax=value, ymin=baseline, fill=trigger), alpha=0.2) +
            scale_fill_manual(values=c('#FFEEFF', '#FF3333', '#CCCC00')) +
            scale_alpha_manual(values=c(0, .4, .4)) +
            geom_ribbon(aes(ymax=baseline+threshold, ymin=baseline-threshold), color='#CCCCCC', alpha=0.2) +
            theme_bw()
    })
})

