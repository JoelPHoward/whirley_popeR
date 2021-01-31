# need a way to start/stop/reset...port from arduinor repo
# need a way to select first crack, second crack, observations...an add observation feature (observation, time, add_btn)
# motor speed control, default to max...record motor speed in out file
# Analysis tab to look at previous data

server <- function(input, output, session){
    
    session$onSessionEnded(function(){
        ar_close(con)
        stopApp
    })
    
    t <- 0
    
    rv <- reactiveValues()
    rv$state <- 1
    rv$realtime <- NULL
    rv$obs <- NULL
    
    output$plot <- renderPlotly({
        p <- plot_ly(type = 'scatter', mode = 'lines+markers', line = list(width = 3)) %>%
            layout(plot_bgcolor='rgb(39, 43, 48)', 
                   paper_bgcolor='rgb(39, 43, 48)', 
                   font = list(family = "Arial", size = 14, color = 'white'),
                   xaxis = list(color = 'white', title = 'Time (s)'),
                   yaxis = list(color = 'white', title = "Temperature (\u00B0C)"))
            
        for (y_i in 2:length(first_dot)) {
            p <- add_trace(p, y = first_dot[y_i], name = names(first_dot[y_i]), color = I(wes_palettes$GrandBudapest1[y_i-1]))
        }
        return(p)
    })
    
    observe({
        invalidateLater(1000)
        flag <- 1
        if (rv$state) {
            #ar_flush_hard(con, 0.04, FALSE)
            rv$realtime <- sep_fun(ar_read(con))
            if(is.null(rv$realtime) | identical(rv$realtime, numeric(0))){
                status <- "<h4 style=color:red>ERROR: Check Arduino Connection. Restart might be required.</h4>"
                flag <- 0
            }else if(rv$realtime[1] == 0){
                status <- "<h4 style=color:red>ERROR: Check Thermocouple Connection.</h4>"
            }else{
                status <- "<h4 style=color:green>NOMINAL</h4>"
            }
            output$status <- renderUI({HTML(status)})
            
            if(flag == 1){
                observeEvent(input$save, {
                    if (!file.exists(input$file)) {
                        file.create(input$file)
                        cat(csv_newline(names(first_dot)), file = input$file)
                    }
                }, ignoreInit = TRUE)
                
                if (input$save) {
                    cat(csv_newline(rv$realtime), file = input$file, append = TRUE)
                }
                realtime_y <- lapply(rv$realtime[2:length(rv$realtime)], list)
                realtime_list <- list(y = realtime_y)
                to_traces <- as.list(1:2)
                plotlyProxy("plot", session) %>%
                    plotlyProxyInvoke("extendTraces", realtime_list, to_traces)
                
                if(input$save & file.exists(input$file)){
                    out <- c(rv$realtime[1], t, input$motor_speed, rv$realtime[2:3])
                    if(is.null(rv$obs)){
                        out <- c(out, '')
                    }else{
                        out <- c(out, rv$obs)
                        rv$obs <- NULL
                    }
                    cat(paste0(paste(c(out), collapse = ','),'\n'), file = paste0(wd, input$file), append = TRUE)
                }
            }
        }
        t <<- t + 1
    })
    
    observeEvent(input$obs_btn, {
        rv$obs <- input$obs
        plotlyProxy("plot", session) %>% 
            plotlyProxyInvoke("addTraces", 
                              list(x=c(t,t), y=c(0,400), 
                                   type='scatter', 
                                   mode='lines',
                                   name = input$obs,
                                   line = list(dash = 'dot'),
                                   showlegend=T))
    })
    
    observeEvent(input$save, {
        cat("status,time,mSpeed,extT,intT,obs\n", file = paste0(wd, input$file))
    }, ignoreInit = TRUE, once = TRUE)
}
