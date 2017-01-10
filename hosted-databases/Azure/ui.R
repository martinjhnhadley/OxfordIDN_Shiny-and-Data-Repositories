library(shiny)
library(DT)

shinyUI(
  fluidPage(
    "Select a surname from the dropdown list",
    uiOutput("surname_to_update_UI"),
    "Type a new birthdate",
    uiOutput("new_DOB_UI"),
    wellPanel(p("Click 'Update Database' to update the database and see the result below."),
    p("BE A GOOD CITIZEN: Press 'disconnect from database' when finished as limited to 4 connections!")),
    actionButton("update_database","Update Database"),
    actionButton("disconnect_database","Disconnect from database"),
    DT::dataTableOutput("database_table")
  )
)
