library(shiny)

shinyUI(fluidPage(
    
    # Application title
    titlePanel("Basil Parameter Tuning"),
    
    sidebarLayout(
        sidebarPanel(
            sliderInput("nsigma",
                        "Number of standard deviations for threshold:",
                        min = 1,
                        max = 10,
                        value = 4),
            sliderInput("leadin",
                        "Number of minutes to wait before triggering:",
                        min = 1,
                        max = 20,
                        value = 5),

            h2('Instructions'),
            p("The chart on the right shows a sample plot of the average response time",
              "of three different pages over the course of six hours.  The green",
              "line is a plot of the baseline based on historical data."),
            p("Use the controls on the left to tune the parameters for triggering",
              "alerts on your application's page response times.  Choose parameters",
              "that show red highlights in the regions of poor page performance for which you would expect to be",
              "alerted."),
            p("The gray band represents the 'safe' area where the response times",
              "will not trigger an alert.  The width is given by the number of",
              "standard deviations chosen in the top control."),
            p("The red areas represent sections that would trigger an alert based",
              "on having the response times exceed the alert threshold for",
              "a consecutive number of minutes specified in the seond input.")
            ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("charts", width="100%", height="700px")
        )
    )
))