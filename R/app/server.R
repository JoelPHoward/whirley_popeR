# need a way to start/stop/reset...port from arduinor repo
# need a way to select first crack, second crack, observations...an add observation feature (observation, time, add_btn)
# motor speed control, default to max...record motor speed in out file
# Analysis tab to look at previous data

server <- function(input, output, session){
    t0 <- Sys.time()
    t <- 0
    recon_cntr <- 1
    flag <- 1
    
    session$onSessionEnded(function(){
        ar_close(con)
        stopApp
    })
    
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
            p <- add_trace(p, x = t, y = first_dot[y_i], name = names(first_dot[y_i]), color = I(my_palette[y_i-1]))
        }
        return(p)
    })
    
    observe({
        invalidateLater(1000)
        if (rv$state) {
            rv$realtime <- sep_fun(ar_read(con))
            if(is.null(rv$realtime) || is.na(rv$realtime) || identical(rv$realtime, numeric(0))){
                status <- "<h4 style=color:red>Arduino Connection ERROR.</h4>"
                ar_close(con)
                con <- ar_init(con_path, baud = 9600)
                recon <- ar_read(con)
                recon <- sep_fun(recon)
                print(paste0("Trying to connect .... ", recon_cntr))
                print(recon)
                recon_cntr <<- recon_cntr + 1
                flag <- -1
            }else if(rv$realtime[1] == 0){
                status <- "<h4 style=color:red>Thermocouple Connection ERROR.</h4>"
                flag <- 1
            }else{
                status <- "<h4 style=color:green>NOMINAL</h4>"
                flag <- 1
                recon_cntr <<- 1
            }
            output$status <- renderUI({HTML(status)})
            if(flag == 1){
                t <<- round(as.numeric(difftime(Sys.time(), t0, units = 'secs')), 2)
                t_list <- lapply(rep(t, length(rv$realtime) - 1), list)
                realtime_y <- lapply(rv$realtime[2:length(rv$realtime)], list)
                realtime_list <- list(x = t_list, y = realtime_y)
                to_traces <- as.list(1:2)
                plotlyProxy("plot", session) %>%
                    plotlyProxyInvoke("extendTraces", realtime_list, to_traces)
                
                if(input$save & file.exists(paste0(wd, input$file))){
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
    })
    
    observeEvent(input$obs_btn, {
        rv$obs <- input$obs
        plotlyProxy("plot", session) %>% 
            plotlyProxyInvoke("addTraces", 
                              list(x=c(t,t), y=c(0,205), 
                                   type='scatter', 
                                   mode='lines',
                                   name = input$obs,
                                   line = list(dash = 'dot'),
                                   showlegend=T))
    })
    
    observeEvent(input$motor_speed, {
        ar_write(con, as.character(input$motor_speed))
    })
    
    observeEvent(input$save, {
        cat("status,time,mSpeed,extT,intT,obs\n", file = paste0(wd, input$file))
    }, ignoreInit = TRUE, once = TRUE)
}
