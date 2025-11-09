# app.R — Taxonomy Converter Tool
# Author: Mahallelah Shauer
# License: GPL-3

library(shiny)
library(dplyr)
library(readr)
library(bdc)
library(taxadb)
library(rgnparser)
library(here)

ui <- fluidPage(
  titlePanel("Taxonomy Checker Tool"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV (must include a 'scientificName' column):"),
      selectInput("db", "Select taxonomic database:",
                  choices = c("gbif", "itis", "col", "ncbi", "wfo")),
      
      # Allow multiple kingdom selections
      selectInput("kingdom", "Select one or more kingdoms:",
                  choices = c("Animalia", "Plantae", "Fungi", 
                              "Bacteria", "Archaea", "Protista", "Chromista"),
                  selected = "Animalia",
                  multiple = TRUE),
      
      actionButton("run", "Run Taxonomy Check"),
      br(),
      downloadButton("download", "Download Cleaned CSV")
    ),
    
    mainPanel(
      tags$h4("Processing Status:"),
      verbatimTextOutput("status"),
      tags$hr(),
      tags$p("Data processed using R packages: bdc, taxadb, and rgnparser."),
      tags$p("Taxonomic databases © their respective owners: GBIF, ITIS, Catalogue of Life, NCBI, WFO."),
      tags$hr(),
      tags$em("Developed by Mahallelah Shauer — 2025")
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$run, {
    req(input$file)
    
    # Read the CSV file
    df <- tryCatch({
      read_csv(input$file$datapath)
    }, error = function(e) {
      output$status <- renderText("Error: Could not read the uploaded CSV file. Please check the format.")
      return(NULL)
    })
    
    if (is.null(df)) return(NULL)
    
    # Input validation: must contain a column named 'scientificName'
    if (!"scientificName" %in% names(df)) {
      output$status <- renderText("Error: The uploaded CSV must include a column named 'scientificName'.")
      return(NULL)
    }
    
    withProgress(message = "Processing taxonomy data...", value = 0, {
      
      incProgress(0.1, detail = "Cleaning scientific names...")
      if (!"notes" %in% names(df)) df$notes <- ""
      parse_names <- bdc_clean_names(sci_names = df$scientificName, save_outputs = FALSE)
      df <- bind_cols(df, parse_names %>% select(.uncer_terms, names_clean))
      
      incProgress(0.3, detail = "Querying selected kingdoms...")
      results <- list()
      
      # Loop over multiple kingdoms
      for (k in input$kingdom) {
        incProgress(0.1, detail = paste("Querying", input$db, "database for", k, "names..."))
        res <- tryCatch({
          bdc_query_names_taxadb(
            sci_name = df$names_clean,
            replace_synonyms = TRUE,
            suggest_names = TRUE,
            suggestion_distance = 0.9,
            db = input$db,
            rank_name = k,
            rank = "kingdom",
            parallel = FALSE,
            export_accepted = FALSE
          )
        }, error = function(e) {
          NULL
        })
        if (!is.null(res)) {
          res$queried_kingdom <- k
          results[[k]] <- res
        }
      }
      
      if (length(results) == 0) {
        output$status <- renderText("Error: No results returned from selected kingdoms.")
        return(NULL)
      }
      
      incProgress(0.8, detail = "Combining results...")
      query_names <- bind_rows(results)
      query_names <- query_names %>% select(-vernacularName)
      
      incProgress(1, detail = "Done!")
      
      # Display completion message with traceability info
      output$status <- renderText(paste0(
        "Completed successfully!\n\n",
        "Database used: ", input$db, "\n",
        "Kingdoms selected: ", paste(input$kingdom, collapse = ", "), "\n",
        "You can now download the cleaned file below."
      ))
      
      # Download handler for results
      output$download <- downloadHandler(
        filename = function() paste0("taxonomy_checked_", Sys.Date(), ".csv"),
        content = function(file) write_csv(query_names, file)
      )
    })
  })
}

shinyApp(ui, server)
