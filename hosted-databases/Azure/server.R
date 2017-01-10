library(shiny)
library(RMySQL)
library(DT)

login_details <-
  read.csv(file = "azure_mysql_login.csv", stringsAsFactors = F)
database_domain <- "eu-cdbr-azure-north-e.cloudapp.net"
database_name <- "testdatabase2"

azure_connection <- dbConnect(
  RMySQL::MySQL(),
  dbname = database_name,
  host = database_domain,
  username = login_details$username,
  password = login_details$password,
  port = 3306
)


shinyServer(function(input, output) {
  database_data <- reactiveValues()
  
  database_data$surnames <-
    eventReactive(
      input$update_database,
      dbReadTable(azure_connection, "new_table")$surname,
      ignoreNULL = F
    )
  
  database_data$whole_database <-
    eventReactive(input$update_database,
                  dbReadTable(azure_connection, "new_table"),
                  ignoreNULL = F)
  
  output$surname_to_update_UI <- renderUI({
    selectInput(
      "surname_to_update",
      "Update Surname",
      choices = dbReadTable(azure_connection, "new_table")$surname
    )
  })
  
  
  
  output$new_DOB_UI <-
    renderUI(textInput("new_DOB", label = h3("Text input"), placeholder = "Enter birthdate in yyyy-mm-dd"))
  
  observeEvent(input$update_database,
               {
                 write_statement <- paste0(
                   "UPDATE new_table",
                   " ",
                   "SET dateOfBirth='",
                   input$new_DOB,
                   "'",
                   " ",
                   "WHERE surname='",
                   input$surname_to_update,
                   "';"
                 )
                 
                 dbSendQuery(azure_connection, write_statement)
               })
  
  observeEvent(input$disconnect_database,
               dbDisconnect(azure_connection))
  
  data_to_display <- eventReactive(input$update_database,
                                   dbReadTable(azure_connection, "new_table"),
                                   ignoreNULL = FALSE)
  
  output$database_table <-
    DT::renderDataTable({
      # if(input$update_database == 0){
      #   "bleurg"
      # } else
      #   database_data$whole_database
      Sys.sleep(0.5)
      data_to_display()
      
    })
  
})
