#install and load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rio, here, readxl, shiny, bib2df, stringi, DT, openxlsx)

######################### DATA CLEANING ########################################
# ##Import
# #set path to eligibility data
# elig_path <- here("data", "Depression_Overview_Eligibility_Data.xlsx")
# 
# #import eligibility_decisions sheet of excel file
# ps_eligibility <- read_excel(elig_path, sheet = "eligibility_decisions")
# 
# #import excel primary study reference sheet
# ps_allreferences <- read_excel(elig_path, sheet = "reports")
# 
# #import excel citation matrix (with header to calculate # of included/eligible studies)
# ps_cm <- read_excel(elig_path, sheet = "citation_matrix")
# 
# #import excel citation matrix sheet (without header to transpose for lists of included/eligible reviews)
# citation_matrix <- read_excel(elig_path, sheet = "citation_matrix", col_names = FALSE)
# 
# #import main primary study reference from Zotero .bib export
# bib_ps_df <- bib2df(here("data", "included_studies.bib")) %>%
#   janitor::clean_names()
# 
# #set path to study-level data
# sd_path <- here("data", "Depression_Overview_Primary_Study_Data.xlsx")
# 
# #import primary study level descriptive data
# study_level <- read_excel(sd_path, sheet = "study_level")
# 
# #import study level risk of bias data for individual RCTs
# study_irob <- read_excel(sd_path, sheet = "iROB")
# 
# #import study level risk of bias data for cluster RCTs
# study_crob <- read_excel(sd_path, sheet = "cROB")
# 
# #import study level risk of bias data for non-randomized trials
# study_robins <- read_excel(sd_path, sheet = "ROBINS-I")
# 
# #import group level descriptive data
# group_level <- read_excel(sd_path, sheet = "group_level")
# 
# #import outcome level descriptive data
# outcome_level <- read_excel(sd_path, sheet = "outcome_level")
# 
# ##Tidy
# #create object to match revision code
# ps_elig_td <- ps_eligibility
# 
# #pull list of included studies
# inc_ps <- ps_eligibility %>%
#   filter(decision == "Include") %>%
#   pull(study)
# 
# #create object to match revision code
# td_cm <- ps_cm
# 
# #clean study level data
# td_study <- study_level %>%
#   arrange(str_to_lower(study_author_year)) %>%
#   mutate(cluster_size = as.numeric(cluster_size),
#          school_type = case_when(school_type == "Public Private" ~ "Public, Private",
#                                  school_type == "Private Public" ~ "Private, Public",
#                                  TRUE ~ school_type),
#          school_type = str_replace(school_type, "\r\n", ", ")) %>%
#   mutate_if(is.numeric, ~ if_else(. == -999, NA_real_, .))
# 
# #extract study id and study names
# study_idbyname <- td_study %>%
#   select(primary_study_id, study_author_year)
# 
# #select variables for irob ratings
# irob_df <- study_irob %>%
#   select(primary_study_id, ends_with("judgment"), iROB_overall_rating)
# 
# #select variables for crob ratings
# crob_df <- study_crob %>%
#   select(primary_study_id, ends_with("judgment"), cROB_overall_rating)
# 
# #select variables for robins-i info
# robins_df <- study_robins %>%
#   select(primary_study_id, ends_with("judgment"), robins_overall_rating)
# 
# #group level
# td_group <- group_level %>%
#   mutate(intervention_intensity = case_when(intervention_intensity == "20 to 30" ~ "50",
#                                             intervention_intensity == "20 to 40" ~ "30",
#                                             intervention_intensity == "20 to 40" ~ "30",
#                                             intervention_intensity == "20 to 60" ~ "40",
#                                             intervention_intensity == "30 to 60" ~ "45",
#                                             intervention_intensity == "30 to 90" ~ "60",
#                                             intervention_intensity == "35 to 60" ~ "47.5",
#                                             intervention_intensity == "35 to 40" ~ "37.5",
#                                             intervention_intensity == "40 to 60" ~ "50",
#                                             intervention_intensity == "40 to 45" ~ "42.5",
#                                             intervention_intensity == "40 to 50" ~ "45",
#                                             intervention_intensity == "45 to 50" ~ "47.5",
#                                             intervention_intensity == "45 to 50" ~ "47.5",
#                                             intervention_intensity == "45 to 60" ~ "52.5",
#                                             intervention_intensity == "45 to 90" ~ "67.5",
#                                             intervention_intensity == "50 to 60" ~ "55",
#                                             TRUE ~ intervention_intensity)) %>%
#   mutate(intervention_intensity = as.numeric(intervention_intensity),
#          intervention_frequency = ifelse(intervention_frequency == "6. Cannot Tell", "-999", intervention_frequency)) %>%
#   mutate_if(is.numeric, ~ if_else(. == -999, NA_real_, .))
# 
# #make study ID numeric and create variable that aggregates outcome measures
# td_outcome <- outcome_level %>%
#   mutate(primary_study_id = as.numeric(primary_study_id)) %>%
#   mutate(outcome_measure_lc = str_to_lower(outcome_measure),
#          agg_outcome_meas = case_when(str_detect(outcome_measure_lc, "beck depression inventory") ~
#                                         "Beck Depression Inventory",
#                                       str_detect(outcome_measure_lc, "center for epidemiologic studies depression scale") ~
#                                         "Center for Epidemiologic Studies Depression Scale",
#                                       str_detect(outcome_measure_lc, "children") & str_detect(outcome_measure_lc, "depression inventory") ~
#                                         "Children’s Depression Inventory",
#                                       str_detect(outcome_measure_lc, "revised children’s manifest anxiety scale") ~
#                                         "Revised Children’s Manifest Anxiety Scale",
#                                       str_detect(outcome_measure_lc, "mood and feelings questionnaire") ~
#                                         "Mood and Feelings Questionnaire",
#                                       str_detect(outcome_measure_lc, "depression anxiety stress scale") ~
#                                         "Depression Anxiety Stress Scale",
#                                       str_detect(outcome_measure_lc, "reynolds adolescent depression scale") ~
#                                         "Reynolds Adolescent Depression Scale",
#                                       str_detect(outcome_measure_lc, "spence") & str_detect(outcome_measure_lc, "anxiety scale") ~
#                                         "Spence Children's Anxiety Scale",
#                                       str_detect(outcome_measure_lc, "structured clinical interview") ~ "Structured Clinical Interview",
#                                       TRUE ~ outcome_measure))
# 
# #create function to clean outcome_measure variable
# mutate_outcome_measure <- function(df){
#   df %>%
#     mutate(outcome_measure_lc = str_to_lower(outcome_measure),
#            agg_outcome_meas = case_when(str_detect(outcome_measure_lc, "beck depression inventory") ~
#                                           "Beck Depression Inventory",
#                                         str_detect(outcome_measure_lc, "center for epidemiologic studies depression scale") ~
#                                           "Center for Epidemiologic Studies Depression Scale",
#                                         str_detect(outcome_measure_lc, "children") & str_detect(outcome_measure_lc, "depression inventory") ~
#                                           "Children’s Depression Inventory",
#                                         str_detect(outcome_measure_lc, "revised children’s manifest anxiety scale") ~
#                                           "Revised Children’s Manifest Anxiety Scale",
#                                         str_detect(outcome_measure_lc, "mood and feelings questionnaire") ~
#                                           "Mood and Feelings Questionnaire",
#                                         str_detect(outcome_measure_lc, "depression anxiety stress scale") ~
#                                           "Depression Anxiety Stress Scale",
#                                         str_detect(outcome_measure_lc, "reynolds adolescent depression scale") ~
#                                           "Reynolds Adolescent Depression Scale",
#                                         str_detect(outcome_measure_lc, "spence") & str_detect(outcome_measure_lc, "anxiety scale") ~
#                                           "Spence Children's Anxiety Scale",
#                                         str_detect(outcome_measure_lc, "structured clinical interview") ~ "Structured Clinical Interview",
#                                         str_detect(outcome_measure_lc, "diagnostic interview for children and adolescents") ~ "Diagnostic Interview for Children and Adolescents",
#                                         str_detect(outcome_measure_lc, "reynolds child depression scale") ~ "Reynolds Child Depression Scale",
#                                         str_detect(outcome_measure_lc, "revised children's anxiety and depression scale") ~ "Revised Children's Anxiety and Depression Scale",
#                                         str_detect(outcome_measure_lc, "multidimensional anxiety scale for children") ~ "Multidimensional Anxiety Scale for Children",
#                                         str_detect(outcome_measure_lc, "children’s automatic thoughts scale") ~ "Children’s Automatic Thoughts Scale",
#                                         str_detect(outcome_measure_lc, "stai-ch") ~ "State-Trait Anxiety Inventory for Children",
#                                         TRUE ~ outcome_measure))
# }
# 
# ##Format
# #select relevant individual rob data
# t4_irob <- study_irob %>%
#   select(primary_study_id, iROB_overall_rating) %>%
#   rename(overall_rob_rating = iROB_overall_rating)
# 
# #select relevant cluster rob data
# t4_crob <- study_crob %>%
#   select(primary_study_id, cROB_overall_rating) %>%
#   rename(overall_rob_rating = cROB_overall_rating)
# 
# #select relevant QED rob data
# t4_robins <- study_robins %>%
#   select(primary_study_id, robins_overall_rating) %>%
#   rename(overall_rob_rating = robins_overall_rating)
# 
# #bind together all rob data for primary studies
# t4_allrob <- rbind(t4_irob, t4_crob, t4_robins)
# #select variables needed from group level data
# t4_group <- group_level %>%
#   select(primary_study_id, group_number, group_type, gname, ig_group_type,  comparison_type) %>%
#   left_join(study_idbyname) %>%
#   mutate_all(list(~ifelse(. == -999, "Not reported", .))) %>%
#   mutate_at(vars(group_type, ig_group_type, comparison_type), list(~str_remove(., "^[0-9]+\\. "))) %>%
#   select(primary_study_id, study_author_year, everything()) %>%
#   arrange(study_author_year)
# 
# #transform intervention names data to merge
# t4group_intnames <- t4_group %>%
#   group_by(study_author_year, group_type) %>%
#   summarize(group_names = paste(gname, collapse = "; ")) %>%
#   ungroup() %>%
#   filter(group_type == "Intervention")
# 
# #transform comparison types data to merge
# t4group_compnames <- t4_group %>%
#   mutate(comparison_type = case_when(comparison_type == "Active" ~ paste("Active:", gname),
#                                      TRUE ~ comparison_type)) %>%
#   group_by(study_author_year, group_type) %>%
#   summarize(comp_type = paste(comparison_type, collapse = "; ")) %>%
#   ungroup() %>%
#   filter(group_type == "Comparison")
# 
# #merge group names and transform to wide format
# t4group_wide <- t4group_intnames %>%
#   left_join(t4group_compnames, by = "study_author_year") %>%
#   rename(Intervention = group_names,
#          Comparison = comp_type) %>%
#   select(-starts_with("group")) %>%
#   mutate_all(~ str_replace_all(., "Cannot tell", "Not Reported"))
# 
# 
# #select study level info and format for table
# a5_info <- td_study %>%
#   mutate_at(vars(school_level, state, urbanicity, research_design, assignment_level, cluster_type), list(~str_remove(., "^[0-9]+\\. "))) %>%
#   mutate(school_level = str_replace(school_level, ",(...)(.*)", ",\\2"),
#          urbanicity = str_replace_all(urbanicity, "\\s\\d+\\.", ",")) %>%
#   mutate(school_level = case_when(school_level == "Only Reported Secondary School" ~ "Secondary School",
#                                   school_level == "Only Reported Primary School" ~ "Primary School",
#                                   school_level == "Only Reported Primary School, Only Reported Secondary School" ~ "Primary School , Secondary School",
#                                   school_level == "Cannot tell" ~ "Not reported",
#                                   TRUE ~ school_level),
#          grade_level = ifelse(grade_level == "Cannot tell", "Not reported", grade_level),
#          urbanicity = str_replace_all(urbanicity, "\\s+,", ","),
#          urbanicity = str_replace_all(urbanicity, ",,", ","),
#          cluster_type = ifelse(assignment_level != "Cluster", "NA", cluster_type),
#          cluster_size = ifelse(assignment_level != "Cluster", "NA", cluster_size)) %>%
#   mutate(school_level = str_replace(school_level, "(,.)", " and "),
#          percent_mixed = ifelse(percent_mixed == "-999", NA_real_, as.numeric(percent_mixed)),
#          percent_other = ifelse(percent_other == "-999", NA_real_, as.numeric(percent_other)),
#          state = ifelse(state == "Cannot tell", "Not reported", state),
#          research_design = ifelse(research_design == "QED - Regression adjustment", "Quasi-experimental design", research_design),
#          age_dispersion = ifelse(age_average_type == "1. Mean" & age_dispersion != "-999", as.character(round(as.numeric(age_dispersion), 2)), age_dispersion)) %>%
#   mutate(study_start_date = ifelse(nchar(study_start_date) == 10, format(ymd(study_start_date), "%B %d, %Y"), study_start_date),
#          study_end_date = ifelse(nchar(study_end_date) == 10, format(ymd(study_end_date), "%B %d, %Y"), study_end_date)) %>%
#   mutate(study_start_date = ifelse(nchar(study_start_date) == 7, format(ym(study_start_date), "%B %Y"), study_start_date),
#          study_end_date = ifelse(nchar(study_end_date) == 7, format(ym(study_end_date), "%B %Y"), study_end_date)) %>%
#   mutate(number_participants = format(number_participants, big.mark = ",", scientific = FALSE),
#          sample_size = case_when(!is.na(number_participants) & !is.na(number_classrooms) & !is.na(number_schools) ~
#                                    paste(number_participants, "students,", number_classrooms, "classrooms,", number_schools, "schools"),
#                                  !is.na(number_participants) & !is.na(number_classrooms) & is.na(number_schools) ~
#                                    paste(number_participants, "students,", number_classrooms, "classrooms"),
#                                  !is.na(number_participants) & is.na(number_classrooms) & is.na(number_schools) ~
#                                    paste(number_participants, "students"),
#                                  !is.na(number_participants) & is.na(number_classrooms) & !is.na(number_schools) ~
#                                    paste(number_participants, "students,", number_schools, "schools"),
#                                  is.na(number_participants) & !is.na(number_classrooms) & !is.na(number_schools) ~
#                                    paste(number_classrooms, "classrooms,", number_schools, "schools"),
#                                  is.na(number_participants) & !is.na(number_classrooms) & is.na(number_schools) ~
#                                    paste(number_classrooms, "classrooms"),
#                                  is.na(number_participants) & is.na(number_classrooms) & !is.na(number_schools) ~
#                                    paste(number_schools, "schools")),
#          sample_size = str_trim(sample_size, side = "left"),
#          grd_schl_level = paste(grade_level, "/", school_level),
#          age_mean_sd = paste0(average_age, " (", age_dispersion, ")"),
#          percent_female = ifelse(!is.na(percent_female), paste0(percent_female * 100, "%"), "Not reported"),
#          percent_ELL = ifelse(!is.na(percent_ELL), paste0(percent_ELL * 100, "%"), "Not reported"),
#          percent_FRPL = ifelse(!is.na(percent_FRPL), paste0(percent_FRPL * 100, "%"), "Not reported"),
#          percent_race_ethnicity = case_when(is.na(percent_white) & is.na(percent_black) & is.na(percent_aian) &
#                                               is.na(percent_asian) & is.na(percent_nhpi) & is.na(percent_latinx) &
#                                               is.na(percent_mixed) & is.na(percent_other) ~ "Not reported",
#                                             TRUE ~ paste0(percent_aian * 100, "% AIAN, ", percent_asian * 100, "% Asian, ",
#                                                           percent_black * 100, "% Black, ", percent_latinx * 100, "% Latinx, ",
#                                                           percent_nhpi * 100, "% NHPI, ", percent_white * 100, "% White, ",
#                                                           percent_mixed * 100, "% Mixed, ", percent_other * 100, "% Other")),
#          country_state = case_when(state != "Non-US Study" ~ paste0(country, " (", state, ")"),
#                                    TRUE ~ country)) %>%
#   mutate(age_mean_sd = case_when(age_mean_sd == "NA (-999)" ~ "Not reported",
#                                  str_detect(age_mean_sd, "-999") ~ paste(average_age),
#                                  TRUE ~ age_mean_sd),
#          percent_race_ethnicity = str_replace_all(percent_race_ethnicity, c("NA% AIAN, " = "", "NA% Asian, " = "", "NA% Black, " = "",
#                                                                             "NA% Latinx, " = "", "NA% NHPI, " = "", "NA% White, " = "",
#                                                                             "NA% Mixed, " = "", "NA% Other" = ""))) %>%
#   mutate(percent_race_ethnicity = gsub(", $", "", percent_race_ethnicity)) %>%
#   mutate(across(everything(), ~ifelse(.x == -999 | .x == "Cannot tell" | .x == "Cannot Tell" | is.na(.x), "Not reported", .x))) %>%
#   select(study_author_year, study_start_date, study_end_date, recruitment_approach,
#          eligibility_criteria, research_design, assignment_level, cluster_type, cluster_size, study_groups,
#          sample_size, grd_schl_level, age_mean_sd, percent_female, percent_race_ethnicity, percent_ELL, percent_FRPL,
#          country_state, urbanicity, school_type, consort_flow_diagram, study_registration, availability_statement,
#          grade_level, school_level, country, state, study_author_name)
# 
# #merge with group/intervention names created for table 4
# a5_groups <- left_join(a5_info, t4group_wide)
# 
# #merge with outcome data and combine outcomes for each study
# a5_outcome <- outcome_level %>%
#   left_join(study_idbyname) %>%
#   mutate(outcome_domain = str_remove(outcome_domain, "^[0-9]+\\. ")) %>%
#   distinct(study_author_year, outcome_domain, .keep_all = TRUE) %>%
#   group_by(study_author_year) %>%
#   summarize(outcome_list = paste(outcome_domain, collapse = ", ")) %>%
#   ungroup() %>%
#   mutate(outcome_list = sapply(lapply(str_split(outcome_list, ", "), sort), paste, collapse = ", ")) %>%
#   select(study_author_year, outcome_list) %>%
#   right_join(a5_groups) %>%
#   arrange(str_to_lower(study_author_year))
# 
# #merge with rob data created in table 4
# a5_rob <- t4_allrob %>%
#   left_join(study_idbyname) %>%
#   right_join(a5_outcome) %>%
#   mutate(overall_rob_rating = str_remove(overall_rob_rating, "^[0-9]+\\. "),
#          overall_rob_rating = str_replace(overall_rob_rating, "-999", "Not reported")) %>%
#   select(study_author_year, study_start_date, study_end_date, recruitment_approach,
#          eligibility_criteria, research_design, assignment_level, cluster_type, cluster_size, study_groups,
#          sample_size, grd_schl_level, age_mean_sd, percent_female, percent_race_ethnicity, percent_ELL, percent_FRPL,
#          country_state, urbanicity, school_type, Intervention, Comparison, outcome_list, overall_rob_rating,
#          consort_flow_diagram, study_registration, availability_statement,
#          grade_level, school_level, country, state, study_author_name)
# 
# #combine all references for a primary study in a single variable, separated by a semicolon
# ps_citations <- ps_allreferences %>%
#   rename(citation = report) %>%
#   filter(study %in% inc_ps)
# 
# #create a variable that combines all references for a study into one cell
# study_reports <- ps_citations %>%
#   group_by(study) %>%
#   summarize(all_reports = paste(citation, collapse = " ; ")) %>%
#   ungroup() %>%
#   mutate(all_reports = str_replace_all(all_reports, "; ", "<br><br>")) %>%
#   rename(study_author_year = study)
# 
# #extract titles and study names from Zotero .bib
# ps_titles <- bib_ps_df %>%
#   rowwise() %>%
#   mutate(author_unlist = paste(lapply(author, paste, collapse = ","), collapse = ", "),
#          author = str_extract(author_unlist, "^[^,]+"),
#          author_year = paste(author, year),
#          title = str_replace_all(title, "[{}]", ""),
#          title = str_remove(title, "\\.$"),
#          merge_author = stri_trans_general(author_year, "Latin-ASCII"),
#          merge_author = str_to_lower(merge_author)) %>%
#   arrange(str_to_lower(author_year))
# 
# #merge titles with full citation
# study_ref_info <- study_reports %>%
#   mutate(author_year = str_replace(study_author_year, "(\\d{4}).*", "\\1"),
#          merge_author = stri_trans_general(author_year, "Latin-ASCII"),
#          merge_author = str_to_lower(merge_author)) %>%
#   select(-author_year) %>%
#   left_join(ps_titles) %>%
#   select(title, all_reports, merge_author)
# 
#merge all info for appendix 5 together
# a5 <- a5_rob %>%
#   mutate(author_year = str_replace(study_author_year, "(\\d{4}).*", "\\1"),
#          merge_author = stri_trans_general(author_year, "Latin-ASCII"),
#          merge_author = str_to_lower(merge_author)) %>%
#   left_join(study_ref_info, by = "merge_author", multiple = "all") %>%
#   distinct(study_author_year, .keep_all = TRUE) %>%
#   mutate(study_years = ifelse(study_start_date == "Not reported" & study_end_date == "Not reported", "Not Reported",
#                               paste0(study_start_date, " - ", study_end_date)),
#          cluster_level_type = ifelse(assignment_level == "Cluster", paste0(assignment_level, " (", cluster_type, ")"),
#                                      assignment_level),
#          publication_year = str_extract(study_author_year, "\\d{4}"),
#          outcome_list = ifelse(is.na(outcome_list), "Not reported", outcome_list)) %>%
#   select(study_author_year, publication_year, title, study_author_name,
#          country_state, study_years, urbanicity, school_type,
#          grd_schl_level, sample_size, age_mean_sd,
#          Intervention, Comparison, outcome_list,
#          research_design, cluster_level_type,
#          percent_female, percent_race_ethnicity, percent_ELL, percent_FRPL,
#          grade_level, school_level, country, state) %>%
#   mutate_if(is.numeric, as.character) %>%
#   #arrange(str_to_lower(stringi::stri_trans_general(study_author_year, "Latin-ASCII")))
#   arrange(desc(publication_year))

# Export cleaned data for use in app
#export(a5, here("outputs", "data_dashboard", "data", "dpo_app_data.xlsx"))
#export(a5, here("data", "dpo_app_data.xlsx"))

######### APP (IMPORT CLEANED DATA FROM CLEANING SCRIPT) ####################################################

#import cleaned app data (SEE 4DSW CODE)
#cleaned_df <- import(here("data", "dpo_app_data.xlsx"))
#ANY ADDITIONAL CLEANING/FORMATTING IF NEEDED

# # Define UI for application
# ui <- fluidPage(
# 
#     # Application title
#     titlePanel("Depression Prevention Research Database"),
#     
#     # Insructions
#     div("Step 1 - Select criteria to filter data:", 
#         style = "text-align: left; font-size: 16px; margin-top: 10px; padding-left: 10px; color: #007030; font-weight: bold;"),
#     div("Tip: Filters will show all studies that include, but are not limited to, your selected filter(s). ", 
#         style = "text-align: left; font-size: 12px; margin-top: 2px; padding-left: 10px; margin-bottom: 5px;"),
#     
#     # Top panel with filters
#     fluidRow(
#       div(
#         selectizeInput("country_filter", "Country:", choices = c("None", unique(a5$research_design), selected = "None"), multiple = TRUE),
#         style = "display:inline-block; width:25%; margin-left: 25px;"),
#       div(
#         selectizeInput("school_type_filter", "School Type:", choices = c("None", unique(a5$school_type), selected = "None", multiple = TRUE),
#         style = "display:inline-block; width:25%;"),
#       div(
#         selectizeInput("urbanicity_filter", "Community Type (Rurality):", choices = c("None", unique(a5$urbanicity), selected = "None"), multiple = TRUE),
#         style = "display:inline-block; width:25%;")
#     ),
# 
#     fluidRow(
#       div(
#         selectizeInput("design_filter", "Research Design:", choices = c("None", unique(a5$research_design), selected = "None"), multiple = TRUE),
#         style = "display:inline-block; width:25%; margin-left: 25px;"
#       ),
#     # div(
#     #   selectizeInput("fifthday_filter", "Fifth Day Activity:", choices = fifthday_choices, multiple = TRUE),
#     #   style = "display:inline-block; width:25%;"
#     # ),
#     # div(
#     #   selectizeInput("effectiveness_filter", "Outcome Domain Studied:", choices = effect_choices, multiple = TRUE),
#     #   style = "display:inline-block; width:25%;"
#     # ),
#       
#       fluidRow(div(
#         actionButton("resetFilters", "Reset Filters", class = "reset-button"),
#         style = "padding-left: 30px;")),
#     #),
# 
#     # Sidebar with a slider input for number of bins 
#     # sidebarLayout(
#     #     sidebarPanel(
#     #       selectInput("design_filter", "Select Design:", choices = c("None", unique(a5$research_design)), selected = "None"),
#     #       selectInput("country_filter", "Select Location:", choices = c("None", unique(a5$country_state)), selected = "None"),
#     #       selectInput("urbanicity_filter", "Select Area:", choices = c("None", unique(a5$urbanicity)), selected = "None"),
#     #       selectInput("school_type_filter", "Select School Type:", choices = c("None", unique(a5$school_type)), selected = "None")  
#     #       #sliderInput("bins",
#     #        #             "Number of bins:",
#     #         #            min = 1,
#     #          #           max = 50,
#     #           #          value = 30)
#     #     ),
# 
#         # Show a plot of the generated distribution
#         mainPanel(
#            tableOutput("table")
#         )
#     )
# ))

#### Set-up ####

# Import cleaned app data from shinyapps working directory
a5 <- import(here("data", "dpo_app_data.xlsx"))

# Define filter options
country_choices <- sort(unique(a5$country))
state_choices <- sort(unique(a5$state[!a5$state %in% c("Non-US Study", "Not reported")]))
grade_choices <- c("K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
schtyp_choices <- sort(unique(trimws(unlist(strsplit(a5$school_type[!a5$school_type %in% c("Not reported")], ",")))))
community_choices <- sort(unique(trimws(unlist(strsplit(a5$urbanicity[!a5$urbanicity %in% c("Not reported")], ",")))))
design_choices <- sort(unique(a5$research_design))
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
             font-family: "Open Sans", sans-serif;
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
  div("Step 1 - Select criteria to filter data:", 
      style = "text-align: left; font-size: 16px; margin-top: 10px; padding-left: 10px; color: #007030; font-weight: bold;"),
  div("Tip: Filters will show all studies that include, but are not limited to, your selected filter(s). If an option isn't available in a filter, no studies included data for it.", 
      style = "text-align: left; font-size: 12px; margin-top: 2px; padding-left: 10px; margin-bottom: 5px;"),
  
  # # Top panel with filters
  # fluidRow(
  #   div(selectizeInput("country_filter", "Country:", choices = country_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%; margin-left: 25px;"),
  #   # Conditional Panel to show State filter only if "United States" is selected
  #   conditionalPanel(
  #     condition = "input.country_filter.includes('United States')",
  #     div(
  #       selectizeInput("state_filter", "State:", choices = state_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%;"
  #     )
  #   ),
  #   div(selectizeInput("school_type_filter", "School Type:", choices = schtyp_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%;"),
  #   div(selectizeInput("urbanicity_filter", "Community Type (Rurality):", choices = community_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%;")
  # ),
  # 
  # fluidRow(
  #   div(selectizeInput("grade_level_filter", "Grade Level:", choices = grade_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%; margin-left: 25px;"),
  #   div(selectizeInput("outcome_filter", "Outcome:", choices = outcome_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%;"),
  #   div(selectizeInput("design_filter", "Research Design:", design_choices, multiple = TRUE),
  #       style = "display:inline-block; width:25%;")
  # ),
  

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
      selectizeInput("outcome_filter", "Outcome:", choices = outcome_choices, multiple = TRUE),
      style = "display:inline-block; width:25%;"
    ),
    div(
      selectizeInput("design_filter", "Research Design:", choices = design_choices, multiple = TRUE),
      style = "display:inline-block; width:25%;"
    )
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
                       
                       h4("Data Years:"),
                       p("The years from which data originated."),
                       
                       h4("Community Type:"),
                       p("Rural, Suburban, and/or Urban."),
                       
                       h4("School Type"),
                       p("Type of school (e.g., Charte, Public)."),
                       
                       h4("Grade/School Level:"),
                       p("Grade level of students / Education level of schools (e.g., Elementary, Primary)."),
                       
                       h4("Sample Size:"),
                       p("Number of students, classrooms, and schools included in the study."),
                       
                       h4("Age:"),
                       p("Average or median age with the standard or deviation or range, depending on what was reported in the study."),
                       
                       h4("Intervention:"),
                       p("Name(s) of the depression prevention intervention studied."),
                       
                       tags$ul(
                         tags$li(HTML("<strong>UP-A:</strong> Definition")),
                         tags$li(HTML("<strong>Intervention Name:</strong> Definition")),
                         tags$li(HTML("<strong>Intervention Name:</strong> Definition")),
                         tags$li(HTML("<strong>Intervention Name:</strong> Definition"))
                       ),
                       
                       h4("Comparison:"),
                       p("Type of comparison group used in the study."),
                       
                       tags$ul(
                         tags$li(HTML("<strong>Active</strong> Definition")),
                         tags$li(HTML("<strong>Attention Control:</strong> Definition")),
                         tags$li(HTML("<strong>No Treatment:</strong> Definition")),
                         tags$li(HTML("<strong>TAU:</strong> Definition")),
                         tags$li(HTML("<strong>Waitlist:</strong> Definition"))
                       ),
                       
                       h4("Outcome:"),
                       p("Variables researchers reported as outcomes."),
                       
                       tags$ul(
                         tags$li(HTML("<strong>Anxiety:</strong> Definition")),
                         tags$li(HTML("<strong>Depression Diagnosis:</strong> Definition")),
                         tags$li(HTML("<strong>Depression Symptoms:</strong> Definition")),
                         tags$li(HTML("<strong>Educational Achievement:</strong> Definition")),
                         tags$li(HTML("<strong>Self-Harm:</strong> Definition")),
                         tags$li(HTML("<strong>Stress:</strong> Definition")),
                         tags$li(HTML("<strong>Substance-Use:</strong> Definition")),
                         tags$li(HTML("<strong>Subsyndromal Depression:</strong> Definition")),
                         tags$li(HTML("<strong>Suicidal Ideation:</strong> Definition")),
                         tags$li(HTML("<strong>Well-being:</strong> Definition"))
                       ),
                       
                       h4("Design:"),
                       p("Study design used to test intervention effects."),
                       
                       tags$ul(
                         tags$li(HTML("<strong>Randomized Trial:</strong> Definition")),
                         tags$li(HTML("<strong>Quasi-Experimental Design:</strong> Definition"))
                       ),
                       
                       h4("Cluster Type:"),
                       p("Whether the study was an individual or cluster based design. If a cluster design, the type of cluster is reported in parentheses."),
                       
                       tags$ul(
                         tags$li(HTML("<strong>Individual:</strong> Definition")),
                         tags$li(HTML("<strong>Cluster (Classroom):</strong> Definition")),
                         tags$li(HTML("<strong>Cluster (School):</strong> Definition"))
                       ),
                       
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
server <- function(input, output) {
  # Create a reactive filtered dataset based on user selections ####
  filtered_dataset <- reactive({
    filtered_data <- a5
    
    # Filter by design
    if (!is.null(input$design_filter) && length(input$design_filter) > 0) {
      filter_expr_design <- do.call(cbind, lapply(input$design_filter, function(design_filter) {
        grepl(design_filter, filtered_data$research_design, ignore.case = TRUE)
      }))
      filtered_data <- filtered_data %>%
        filter(rowSums(filter_expr_design) > 0)
    }
    
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
      dplyr::select(-study_author_year, -state, -country, -grade_level, -school_level)
    
    # Check if filtered_data has rows
    if (nrow(filtered_data) > 0) {
      # Render the datatable with options
      datatable(
        filtered_data, 
        escape = FALSE,   # No escaping needed if HTML formatting is used
        rownames = FALSE,
        colnames = c("Publication Year", "Title", "Corresponding Author", "Country (State)", 
                     "Data Years", "Community Type", "School Type", "Grade/School Level",
                     "Sample Size", "Age*", "Intervention", "Comparison", 
                     "Outcome", "Design", "Cluster Type", "% Female", "% Race/Ethnicity",
                     "% ELL", "% FRPL"),
        options = list(
          dom = 'lBfrtipC',
          columnDefs = list(list(width = "1000px", targets = which(colnames(filtered_data) == "Title"))),
          pageLength = 20
        ),
        ,
        caption = htmltools::tags$caption(
          style = 'caption-side: bottom; text-align: left; font-size: 12px; color: #555;',
          "* Age represents the mean or median with standard deviation or range, depending on what the study reported."
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
    updateSelectizeInput(session, "design_filter", selected = character(0))
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
                     "research_design", "outcome_list")

      # Use lapply to process data for each variable
      tables_list <- lapply(vars_list, process_summary_tables, data = filtered_data)
      
      # Set custom headers for each table
      tables_list[[1]] <- setNames(tables_list[[1]], c("Publication Year", "Count", "Percent"))
      tables_list[[2]] <- setNames(tables_list[[2]], c("Community Type", "Count", "Percent"))
      tables_list[[3]] <- setNames(tables_list[[3]], c("School Type", "Count", "Percent"))
      tables_list[[4]] <- setNames(tables_list[[4]], c("School Level", "Count", "Percent"))
      tables_list[[5]] <- setNames(tables_list[[5]], c("Study Design", "Count", "Percent"))
      tables_list[[6]] <- setNames(tables_list[[6]], c("Outcome", "Count", "Percent"))

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
            h3("School Level"),
            rendered_tables_list[[4]]
        ),
        div(class = "table",
            h3("Grade Level Table"),
            grade_text_table_render
        ),
        div(class = "table",
            h3("Publication Year"),
            rendered_tables_list[[1]]
        ),
        div(class = "table",
            h3("Outcome Table"),
            rendered_tables_list[[6]]
        ),
        div(class = "table",
            h3("Study Design Table"),
            rendered_tables_list[[5]]
        ),
       )

    } else {
      # Display a message when there are no matching results
      div(
        p("No data matches your filters."),
        style = "text-align: center; font-size: 16px; margin-top: 10px; font-weight: bold;"
      )
    }



  })

  # TODO: Download buttons ####

  output$downloadData <- downloadHandler(
    filename = "depression_prevention_data.xlsx",
    content = function(file) {
      cleaned_df_to_export <- a5 %>% 
        select(-study_author_year, -grade_level:-state)
      
      write.xlsx(cleaned_df_to_export, file)  # all data
    }
  )

  # output$downloadFilteredData <- downloadHandler(
  #   filename = "4dsw_filtered_data.xlsx",
  #   content = function(file) {
  #     filtered_data_export <- filtered_dataset() %>%
  #     mutate(title_text = str_extract(title, "(?<=>)[^<]+"))
  #
  #     colnames(filtered_data_export) <- cap_names
  #
  #     write.xlsx(filtered_data_export, file)  # filtered data
  #   }
  # )

  output$downloadFilteredData <- downloadHandler(
    filename = "depression_filtered_data.xlsx",
    content = function(file) {
      filtered_data <- filtered_dataset()

      filtered_data_export <- filtered_data %>%
        select(-study_author_year, -grade_level:-state) #%>%
        # rename(title = title_text,
        #        corr_author_name = author_text,
        #        link = title_link) %>%
        # select(publication_year, title, corr_author_name, everything())

      write.xlsx(filtered_data_export, file)  # Write the filtered data
    }
  )
    
  
}



#### Run ####
shinyApp(ui, server)


#### Deploy ####
#file needs to be .R; files need to be in data_dashboard folder; account needs to be setup
#library(rsconnect)
#rsconnect::deployApp(appDir = "outputs/data_dashboard", appName = "depression_data_dashboard")

