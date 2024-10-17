#install and load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rio, here, readxl, shiny, bib2df, stringi, DT, openxlsx)

#### Set-up ####

app_df <- import(here("data", "dpo_app_data.xlsx"))

# Import cleaned app data from shinyapps working directory - to export
a5_to_export <- app_df %>% 
  select(-study_years, -age_mean_sd, -Comparison, -research_design, -cluster_level_type) %>%  #variables removed via TT feedback 10/2/24
  relocate(percent_race_ethnicity, percent_ELL, percent_FRPL, percent_female, Intervention, outcome_list, .after = last_col()) #reorder re: TT feedback
  
# Import cleaned app data - tidied for dashboard
a5 <- app_df %>% 
  select(-study_years, -age_mean_sd, -Comparison, -research_design, -cluster_level_type) %>% #variables removed via TT feedback 10/2/24
  mutate(linked_title = ifelse(!is.na(link_text), paste0("<a href='", link_text, "' target='_blank'>", title, "</a>"), title),
         linked_author = ifelse(!is.na(link_corr_author), paste0("<a href='", link_corr_author, "' target='_blank'>", study_author_name, "</a>"), study_author_name)) %>% 
  select(publication_year, linked_title, linked_author, everything()) %>% 
  relocate(percent_race_ethnicity, percent_ELL, percent_FRPL, percent_female, Intervention, outcome_list, .after = last_col()) #reorder re: TT feedback

# Define filter options
country_choices <- sort(unique(a5$country))
state_choices <- sort(unique(a5$state[!a5$state %in% c("Non-US Study", "Not reported")]))
grade_choices <- c("K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
schtyp_choices <- sort(unique(trimws(unlist(strsplit(a5$school_type[!a5$school_type %in% c("Not reported")], ",")))))
community_choices <- sort(unique(trimws(unlist(strsplit(a5$urbanicity[!a5$urbanicity %in% c("Not reported")], ",")))))
school_choices <- c("Elementary School", "Primary School", "Middle School", "High School", "Secondary School")
#design_choices <- sort(unique(a5$research_design))
outcome_choices <- sort(unique(trimws(unlist(strsplit(a5$outcome_list[!a5$outcome_list %in% c("Not reported")], ",")))))


#### UI #### 
ui <- fluidPage(
  # HTML customization ####
  tags$head(
    tags$style(
      HTML('
           .title-panel {
             text-align: left;
             padding-left: 10px; 
             font-size: 28px;
             font-family: "Source Sans", sans-serif;
           }
           
           .dt-center.dt-body-center.column-Title {
             width: 700px !important; 
           }
           
           body {
             font-family: "Source Sans", sans-serif; 
           }
           
           .reset-button {
             padding-left: 5px; 
           }
           
           table {
             border-collapse: collapse;
             width: 100%;
             border: 1px solid #ddd;
           }
           th, td {
             text-align: left;
             padding: 8px;
             border-bottom: 1px solid #ddd;
           }
           
           .table-container {
             display: grid;
             grid-template-columns: repeat(3, 1fr); 
             gap: 5px;
           }
           .table {
             padding: 5px;
           }
      
            $(document).ready(function() {
             $("[data-toggle=tooltip]").tooltip();
           });
         ')
      ),
    # Google Analytics tracking info (TODO: UPDATE WITH DPO INFO) ####
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css?family=Open+Sans"),
    HTML('<!-- Google tag (gtag.js) -->
          <script async src="https://www.googletagmanager.com/gtag/js?id=G-P3YFV60T9V"></script>
          <script>
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag("js", new Date());
          
            gtag("config", "G-P3YFV60T9V");
          </script>')
      ),
  
  # Application title ####
  tags$h1("Depression Prevention Research Database", class = "title-panel"),
  
  # Instructions ####
  div("Step 1 - Select criteria to filter data (select all that apply):", 
      style = "text-align: left; font-size: 16px; margin-top: 10px; padding-left: 10px; color: #007030; font-weight: bold;"),
  div("Tip: Filters will show all studies that include, but are not limited to, your selected filter(s). If an option isn't available in a filter, no studies included data for it.", 
      style = "text-align: left; font-size: 12px; margin-top: 2px; padding-left: 10px; margin-bottom: 5px;"),
  

  # Filters ####
  fluidRow(
    div(
      selectizeInput(
        "country_filter",
        "Country:",
        choices = country_choices,
        multiple = TRUE
      ),
      style = "display:inline-block; width:25%; margin-left: 25px;"
    ),
    div(
      selectizeInput("school_type_filter", "School Type:", choices = schtyp_choices, multiple = TRUE),
      style = "display:inline-block; width:25%;"
    ),
    div(
      selectizeInput("urbanicity_filter", "Community Type (Rurality):", choices = community_choices, multiple = TRUE),
      style = "display:inline-block; width:25%;"
    )
  ),
  
  # Conditional display of the state filter when "United States" is selected
  conditionalPanel(
    condition = "input.country_filter.includes('United States')",
    fluidRow(
      div(
        selectizeInput("state_filter", "State:", choices = state_choices, multiple = TRUE),
        style = "display:inline-block; width:25%; margin-left: 25px;"
      )
    )
  ),
  
  # Common second row for grade level, outcome, and research design filters
  fluidRow(
    div(
      selectizeInput("grade_level_filter", "Grade Level:", choices = grade_choices, multiple = TRUE),
      style = "display:inline-block; width:25%; margin-left: 25px;"
    ),
    div(
      selectizeInput("school_level_filter", "School Level:", choices = school_choices, multiple = TRUE),
      style = "display:inline-block; width:25%;"
    ),
    div(
      selectizeInput("outcome_filter", "Outcome:", choices = outcome_choices, multiple = TRUE),
      style = "display:inline-block; width:25%;"
    ),
    # div(
    #   selectizeInput("design_filter", "Research Design:", choices = design_choices, multiple = TRUE),
    #   style = "display:inline-block; width:25%;"
    # )
  ),
  
  # Reset button
  fluidRow(
    div(actionButton("resetFilters", "Reset Filters", class = "reset-button"),
        style = "padding-left: 30px;")
  ),
  
  # Instructions ####
  div("Step 2 - Results that meet your criteria are below:", 
      style = "text-align: left; font-size: 16px; margin-top: 10px; padding-left: 10px; margin-bottom: 5px; color: #007030; font-weight: bold;"),
  
  # TabsetPanel data table, summary statistics, and glossary ####
  tabsetPanel(type = "tabs",
              ##### Data Table #####
              tabPanel("Data Table",
                       mainPanel(
                         h2("Research Articles", style = "display: inline-block; margin-right: 20px;"),
                         div(style = "display: flex; justify-content: space-between; align-items: center; ", 
                             p("All studies meeting your criteria:"),
                             ##### Download Button #####
                             div(
                               downloadButton("downloadData", "Download All Data", style = "display: inline-block; margin-right: 10px; margin-bottom: 5px; margin-left: 10px;"),
                               downloadButton("downloadFilteredData", "Download Filtered Data", style = "display: inline-block; margin-bottom: 5px; margin-left: 10px;")
                             )
                         ),
                         DTOutput("table")
                       )
              ),
              ##### Summary Table#####
              tabPanel("Summary Statistics",
                       h2("Summary Statistics"),
                       p("The tables below present frequencies based on the filters you have selected above. The tables will automatically update as you change filters. "),
                       uiOutput("summary_stats_table")
              ),
              ##### Glossary #####
              tabPanel("Glossary",
                       
                       h3("Glossary of Terms"),
                       
                       h4("Publication Year:"),
                       p("Year the study was published."),
                       
                       h4("Title:"),
                       p("Title of the article this study is based on. If a link is available, it will link to the full article."),
                       
                       h4("Corresponding Author:"),
                       p("Author listed in article as corresponding author. If a link is available, it will link to their public website."),
                       
                       h4("Location:"),
                       p("Country (and state if U.S. study) where study was conducted."),
                       
                       #h4("Data Years:"),
                       #p("The years from which data originated."),
                       
                       h4("Community Type:"),
                       p("Rural, Suburban, and/or Urban."),
                       
                       h4("School Type"),
                       p("Type of school (e.g., Charter, Public)."),
                       
                       h4("Grade/School Level:"),
                       p("Grade level of students / Education level of schools (e.g., Elementary, Primary)."),
                       
                       h4("Sample Size:"),
                       p("Number of students, classrooms, and schools included in the study."),
                       
                       #h4("Age:"),
                       #p("Average or median age with the standard or deviation or range, depending on what was reported in the study."),
                       
                       h4("Intervention:"),
                       p("Name(s) of the depression prevention program studied. If a link is available, it will link to the program website. Definitions for generic intervention names are provided below:"),
                       
                       tags$ul(
                         tags$li(HTML("<strong>BA Program:</strong> Behavioral Activation program focused on increasing engagement in positive or rewarding activities")),
                         tags$li(HTML("<strong>CB Group:</strong> Cognitive Behavioral group intervention focused on changing negative thought patterns and behaviors")),
                         tags$li(HTML("<strong>ER Program:</strong> Emotion Regulation program focused on teaching skills related to identifying, understanding, and managing emotions")),
                         tags$li(HTML("<strong>Indicated intervention:</strong> An intervention targeting students who show early signs of depression or are at high risk")),
                         tags$li(HTML("<strong>Mindfulness:</strong> An intervention based on mindfulness techniques")),
                         tags$li(HTML("<strong>Mindfulness condition:</strong> Mindfulness group training specifically developed for adolescents that integrated elements of MBCT and MBSR")),
                         tags$li(HTML("<strong>Pamphlet:</strong> A generic intervention delivered via a pamphlet")),
                         tags$li(HTML("<strong>Peer interaction:</strong> An intervention focused on increasing positive peer interactions")),
                         tags$li(HTML("<strong>Preventive Curriculum:</strong> Primary prevention health class sessions providing education on the behavioral theory of depression")),
                         tags$li(HTML("<strong>Prevention Program:</strong> A generic intervention program designed to prevent the onset of depression")),
                         tags$li(HTML("<strong>Psychoeducational Intervention Program:</strong> An intervention focused on educating students about mental health")),
                         tags$li(HTML("<strong>Social skills training:</strong> An intervention focused on enhancing interpersonal skills")),
                         tags$li(HTML("<strong>Treatment Program:</strong> A generic intervention program designed to treat depressive symptoms")),
                         tags$li(HTML("<strong>Universal intervention:</strong> An intervention offered to all students")),
                         tags$li(HTML("<strong>Video:</strong> A generic intervention delivered via video"))
                       ),
                       
                      # h4("Comparison:"),
                      # p("Type of comparison group used in the study."),
                       
                       #tags$ul(
                       #   tags$li(HTML("<strong>Active</strong> Definition")),
                       #  tags$li(HTML("<strong>Attention Control:</strong> Definition")),
                       #  tags$li(HTML("<strong>No Treatment:</strong> Definition")),
                       #  tags$li(HTML("<strong>TAU:</strong> Definition")),
                       #  tags$li(HTML("<strong>Waitlist:</strong> Definition"))
                       #),
                       
                       h4("Outcome:"),
                       p("Variables researchers reported as outcomes."),
                       
                      tags$ul(
                        tags$li(HTML("<strong>Anxiety:</strong> A state of excessive worry or fear (symptoms or diagnosis).")),
                        tags$li(HTML("<strong>Depression Diagnosis:</strong> A formal diagnosis of clinical depression based on established criteria by a mental health professional or cutoff on a validated screening tool.")),
                        tags$li(HTML("<strong>Depression Symptoms:</strong> Signs of depression, such as persistent sadness, lack of interest, fatigue, and changes in appetite or sleep.")),
                        tags$li(HTML("<strong>Educational Achievement:</strong> The level of success a person has achieved in their academic or educational pursuits.")),
                        tags$li(HTML("<strong>Self-Harm:</strong> Intentional injury inflicted on oneself.")),
                        tags$li(HTML("<strong>Stress:</strong> A physical or emotional response to external pressures or challenges.")),
                        tags$li(HTML("<strong>Substance-Use:</strong> The consumption of drugs or alcohol.")),
                        tags$li(HTML("<strong>Subsyndromal Depression:</strong> A set of depressive symptoms that do not meet the full criteria for a clinical depression diagnosis.")),
                        tags$li(HTML("<strong>Suicidal Ideation:</strong> Thoughts or considerations about taking one's own life.")),
                        tags$li(HTML("<strong>Well-being:</strong> A general state of health, happiness, and life satisfaction."))
                      
                      
                       ),
                       
                       #h4("Design:"),
                       #p("Study design used to test intervention effects."),
                       
                       #tags$ul(
                       #  tags$li(HTML("<strong>Randomized Trial:</strong> Definition")),
                       #  tags$li(HTML("<strong>Quasi-Experimental Design:</strong> Definition"))
                       #),
                       
                      # h4("Cluster Type:"),
                       #p("Whether the study was an individual or cluster based design. If a cluster design, the type of cluster is reported in parentheses."),
                       
                       #tags$ul(
                      #   tags$li(HTML("<strong>Individual:</strong> Definition")),
                      #   tags$li(HTML("<strong>Cluster (Classroom):</strong> Definition")),
                      #   tags$li(HTML("<strong>Cluster (School):</strong> Definition"))
                       #),
                       
                       h4("% Female:"),
                       p("Percentage of female students included in the study."),
                       
                       h4("% Race/Ethnicity:"),
                       p("Percentage of the student race/ethnicity demographics reported in the study."),
                       
                       h4("% ELL"),
                       p("Percentage of students classified as early language learners."),
                       
                       h4("% FRPL"),
                       p("Percentage of students qualifiying for free or reduced priced lunch."),
              )
  )
)

#### SERVER #### 
server <- function(input, output, session) {
  # Create a reactive filtered dataset based on user selections ####
  filtered_dataset <- reactive({
    filtered_data <- a5
    
    # Filter by design - removed via translational team feedback 10/2/24
    # if (!is.null(input$design_filter) && length(input$design_filter) > 0) {
    #   filter_expr_design <- do.call(cbind, lapply(input$design_filter, function(design_filter) {
    #     grepl(design_filter, filtered_data$research_design, ignore.case = TRUE)
    #   }))
    #   filtered_data <- filtered_data %>%
    #     filter(rowSums(filter_expr_design) > 0)
    # }
    
    # Filter by country
    if (!is.null(input$country_filter) && length(input$country_filter) > 0) {
      filter_expr_country <- do.call(cbind, lapply(input$country_filter, function(country_filter) {
        grepl(country_filter, filtered_data$country, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_country) > 0)
    }
    
    # Filter by state
    if (!is.null(input$state_filter) && length(input$state_filter) > 0) {
      filter_expr_state <- do.call(cbind, lapply(input$state_filter, function(state_filter) {
        grepl(state_filter, filtered_data$state, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_state) > 0)
    }
    
    # Filter by urbanicity
    if (!is.null(input$urbanicity_filter) && length(input$urbanicity_filter) > 0) {
      filter_expr_urbanicity <- do.call(cbind, lapply(input$urbanicity_filter, function(urbanicity_filter) {
        grepl(urbanicity_filter, filtered_data$urbanicity, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_urbanicity) > 0)
    }
    
    # Filter by school type
    if (!is.null(input$school_type_filter) && length(input$school_type_filter) > 0) {
      filter_expr_school_type <- do.call(cbind, lapply(input$school_type_filter, function(school_type_filter) {
        grepl(school_type_filter, filtered_data$school_type, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_school_type) > 0)
    }
    
    # Filter by grade level
    if (!is.null(input$grade_level_filter) && length(input$grade_level_filter) > 0) {
      filter_expr_grade_level <- do.call(cbind, lapply(input$grade_level_filter, function(grade_level_filter) {
        grepl(grade_level_filter, filtered_data$grade_level, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_grade_level) > 0)
    }
    
    # Filter by school level
    if (!is.null(input$school_level_filter) && length(input$school_level_filter) > 0) {
      filter_expr_school_level <- do.call(cbind, lapply(input$school_level_filter, function(school_level_filter) {
        grepl(school_level_filter, filtered_data$school_level, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_school_level) > 0)
    }
    
    # Filter by outcome
    if (!is.null(input$outcome_filter) && length(input$outcome_filter) > 0) {
      filter_expr_outcome <- do.call(cbind, lapply(input$outcome_filter, function(outcome_filter) {
        grepl(outcome_filter, filtered_data$outcome_list, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_outcome) > 0)
    }
    
    return(filtered_data)
  })
  
  # Render the filtered dataset as a table ####
  output$table <- DT::renderDT({
    filtered_data <- filtered_dataset() %>% 
      dplyr::select(-study_author_year, -state, -country, -grade_level, -school_level, -title, -study_author_name, -link_text, -link_corr_author)
    
    # Check if filtered_data has rows
    if (nrow(filtered_data) > 0) {
      # Render the datatable with options
      datatable(
        filtered_data, 
        escape = FALSE,   # No escaping needed if HTML formatting is used
        rownames = FALSE,
        colnames = c("Publication Year", "Title", "Corresponding Author", "Country (State)", 
                     #"Data Years",
                     "Community Type", "School Type", "Grade/School Level", "Sample Size", 
                     "% Race/Ethnicity",  "% ELL", "% FRPL", "% Female",
                     #"Age*", 
                     "Intervention", 
                     #"Comparison", 
                     "Outcome" 
                     #"Design", "Cluster Type" 
                     ),
    
        options = list(
          dom = 'lBfrtipC',
          columnDefs = list(list(width = "1000px", targets = which(colnames(filtered_data) == "linked_title"))), #not working
          pageLength = 10
        ),
        ,
        caption = htmltools::tags$caption(
          style = 'caption-side: bottom; text-align: left; font-size: 12px; color: #555;',
          "AIAN = American Indian and Alaskan Native; NHPI = Native Hawaiian and Pacific Islander"
        )
      )
    } else {
      # Handle the case when filtered_data is empty
      empty_data <- as.data.frame(matrix(NA, nrow = 0, ncol = ncol(filtered_data)))
      colnames(empty_data) <- colnames(filtered_data)  # Maintain column names consistency
      datatable(
        empty_data, 
        options = list(
          language = list(
            emptyTable = "No data matches your filters."
          )
        )
      )
    }
  })
  
 
  # Reset filters when reset button is selected ####
  observeEvent(input$resetFilters, {
    updateSelectizeInput(session, "community_filter", selected = character(0))
    updateSelectizeInput(session, "school_type_filter", selected = character(0))
    updateSelectizeInput(session, "grade_level_filter", selected = character(0))
    updateSelectizeInput(session, "country_filter", selected = character(0))
    updateSelectizeInput(session, "state_filter", selected = character(0))
    updateSelectizeInput(session, "urbanicity_filter", selected = character(0))
    updateSelectizeInput(session, "outcome_filter", selected = character(0))
    updateSelectizeInput(session, "school_level_filter", selected = character(0))
    #updateSelectizeInput(session, "design_filter", selected = character(0))
    })

    
  # Render the summary statistics table in the "Summary Statistics" tab ####
  output$summary_stats_table <- renderUI({
    #filtered data to use filters
    filtered_data <- filtered_dataset()


    if (nrow(filtered_data) > 0) {
      
      grade_text_table <- filtered_data %>%
        mutate(grade_level = str_remove_all(grade_level, "; -999|-999; ")) %>%
        separate_rows(grade_level, sep = ", ") %>%
        mutate(grade_level = case_when(grade_level == "K"  ~ "Kindergarten",
                                         grade_level == "1"  ~ "1st Grade",
                                         grade_level == "2"  ~ "2nd Grade",
                                         grade_level == "3"  ~ "3rd Grade",
                                         grade_level == "4"  ~ "4th Grade",
                                         grade_level == "5"  ~ "5th Grade",
                                         grade_level == "6"  ~ "6th Grade",
                                         grade_level == "7"  ~ "7th Grade",
                                         grade_level == "8"  ~ "8th Grade",
                                         grade_level == "9"  ~ "9th Grade",
                                         grade_level == "10" ~ "10th Grade",
                                         grade_level == "11" ~ "11th Grade",
                                         grade_level == "12" ~ "12th Grade",
                                         TRUE ~ grade_level)) %>%
        count(grade_level) %>%
        mutate(
          grade_level = ifelse(grade_level == "-999", "Not Reported", grade_level),
          percent = paste0(round(n / nrow(a5) * 100, 2), "%")
        ) %>%
        arrange(desc(grade_level != "Not Reported"), desc(n)) %>% 
        setNames(c("Grade Level", "Count", "Percent"))
      grade_text_table_render <- renderTable(grade_text_table)


      # function to create summary tables
      process_summary_tables <- function(var_name, data) {
        result <- data %>%
          mutate_at(vars(all_of(var_name)), list(~str_remove_all(.,"; -999|-999; "))) %>%
          mutate(across(all_of(var_name), ~str_replace_all(., ", | and ", "; "))) %>%
          separate_rows(all_of(var_name), sep = "; ") %>%
          mutate(across(all_of(var_name), ~str_trim(.))) %>%
          count(!!sym(var_name)) %>%
          mutate(
            !!var_name := ifelse(!!sym(var_name) == "-999", "Not Reported", !!sym(var_name)),
            percent = paste0(round(n / nrow(data) * 100, 2), "%")
          ) %>%
          arrange(desc(!!sym(var_name) != "Not Reported"), desc(n))

        return(result)
      }


      # List of variables
      vars_list <- c("publication_year", "urbanicity", "school_type", "school_level",
                     #"research_design", 
                     "outcome_list")

      # Use lapply to process data for each variable
      tables_list <- lapply(vars_list, process_summary_tables, data = filtered_data)
      
      # Set custom headers for each table
      tables_list[[1]] <- setNames(tables_list[[1]], c("Publication Year", "Count", "Percent"))
      tables_list[[2]] <- setNames(tables_list[[2]], c("Community Type", "Count", "Percent"))
      tables_list[[3]] <- setNames(tables_list[[3]], c("School Type", "Count", "Percent"))
      tables_list[[4]] <- setNames(tables_list[[4]], c("School Level", "Count", "Percent"))
      #tables_list[[5]] <- setNames(tables_list[[5]], c("Study Design", "Count", "Percent"))
      tables_list[[5]] <- setNames(tables_list[[5]], c("Outcome", "Count", "Percent"))

      #render tables with concise formatting
      rendered_tables_list <- lapply(tables_list, function(tbl) {
        renderTable(tbl)
      })
      
      #show tables in two columns (with css code)
      div(
        class = "table-container",
        div(class = "table",
            h3("Community Type Table"),
            rendered_tables_list[[2]]
        ),
        div(class = "table",
            h3("School Type Table"),
            rendered_tables_list[[3]]
        ),
        div(class = "table",
            h3("School Level Table"),
            rendered_tables_list[[4]]
        ),
        div(class = "table",
            h3("Grade Level Table"),
            grade_text_table_render
        ),
        div(class = "table",
            h3("Publication Year Tab;e"),
            rendered_tables_list[[1]]
        ),
        div(class = "table",
            h3("Outcome Table"),
            rendered_tables_list[[5]]
        ),
        # div(class = "table",
        #     h3("Study Design Table"),
        #     rendered_tables_list[[5]]
        # ),
       )

    } else {
      # Display a message when there are no matching results
      div(
        p("No data matches your filters."),
        style = "text-align: center; font-size: 16px; margin-top: 10px; font-weight: bold;"
      )
    }



  })

  # Download buttons ####

  output$downloadData <- downloadHandler(
    filename = "depression_prevention_data.xlsx",
    content = function(file) {
      cleaned_df_to_export <- a5_to_export %>% 
        select(-study_author_year, -grade_level:-state)
      
      write.xlsx(cleaned_df_to_export, file)  # all data
    }
  )

  output$downloadFilteredData <- downloadHandler(
    filename = "depression_filtered_data.xlsx",
    content = function(file) {
      filtered_data <- filtered_dataset()

      filtered_data_export <- filtered_data %>%
        select(-study_author_year, -grade_level:-state, -linked_title, -linked_author) %>%
        relocate(link_text, link_corr_author, .after = last_col())

      write.xlsx(filtered_data_export, file)  # Write the filtered data
    }
  )
    
  
}



#### Run ####
shinyApp(ui, server)


#### Deploy ####
#file needs to be .R; files need to be in data_dashboard folder; account needs to be setup
# rsconnect::deployApp(appDir = "outputs/data_dashboard", appName = "depression_data_dashboard")

