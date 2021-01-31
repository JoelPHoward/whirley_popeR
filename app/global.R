library(arduinor)
library(shiny)
library(plotly)
library(shinyBS)
library(shinythemes)
library(wesanderson)

sep_fun <- function(x) {
    x <- sub("\r\n$", "", x)
    return(as.numeric(strsplit(x, ",")[[1]]))
}

csv_newline <- function(x) {
    paste0(paste(x, collapse = ","), "\r\n")
}

inline_widget <- function(x, width = "100px") {
    shiny::div(style = glue::glue("display: inline-block;vertical-align:top; width: {width};"), x)
}

con <- ar_init("/dev/cu.usbserial-01750C70", baud = 9600)

ar_flush_hard(con, 0.05)

n <- 1
while(n<10){
    first_dot <- ar_read(con)
    if (first_dot == "") {
        stop("Your connection is probably dead. Please use ar_init and start",
             " a new connection")
    }
    first_dot <- sep_fun(first_dot)
    print(paste0("Trying to connect .... ", n, "/10"))
    if(any(is.na(first_dot))){
        n <- n + 1
    }else{
        break
    }
}

var_names <- c("Status", "External Temperature", "Internal Temperature")
names(first_dot) <- var_names

wd <- "~/"

runApp("~/repos/whiRleypoPy/app/app")
