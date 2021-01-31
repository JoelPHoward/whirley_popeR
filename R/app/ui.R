ui <- fluidPage(
    tags$style(mycss),
    theme = shinytheme("slate"),
    sidebarPanel(
        fluidRow(
            column(
                width = 3,
                h4('Status:')
            ),
            column(
                width = 9,
                uiOutput("status")
            )
        ),
        sliderInput('motor_speed', 'Motor Speed', min = 0, max = 255, value = 0),
        fluidRow(
            column(
                width = 8,
                textInput(inputId = 'obs', label = 'Observation', value = 'beans added')
            ),
            column(
                width = 1,
                br(),
                bsButton('obs_btn', label = 'add')
            )
        ),
        fluidRow(
            column(
                width = 8,
                textInput("file", "Out File", value = paste0("roast_", gsub(" ", "_", gsub(":", ".", date())), ".csv"))
            ),
            column(
                width = 1,
                br(),
                checkboxInput("save", strong("Save"))
            )
        )
    ),
    mainPanel(
        fluidRow(
            plotlyOutput('plot')   
        )
    )
)