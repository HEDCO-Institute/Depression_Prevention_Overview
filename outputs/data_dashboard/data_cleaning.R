#install and load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rio, here, readxl, shiny, bib2df, stringi, DT, openxlsx)

######################### DATA CLEANING ########################################
##Import
#set path to eligibility data
elig_path <- here("data", "Depression_Overview_Eligibility_Data.xlsx")

#import eligibility_decisions sheet of excel file
ps_eligibility <- read_excel(elig_path, sheet = "eligibility_decisions")

#import excel primary study reference sheet
ps_allreferences <- read_excel(elig_path, sheet = "reports")

#import excel citation matrix (with header to calculate # of included/eligible studies)
ps_cm <- read_excel(elig_path, sheet = "citation_matrix")

#import excel citation matrix sheet (without header to transpose for lists of included/eligible reviews)
citation_matrix <- read_excel(elig_path, sheet = "citation_matrix", col_names = FALSE)

#import main primary study reference from Zotero .bib export
bib_ps_df <- bib2df(here("data", "included_studies.bib")) %>%
  janitor::clean_names()

#set path to study-level data
sd_path <- here("data", "Depression_Overview_Primary_Study_Data.xlsx")

#import primary study level descriptive data
study_level <- read_excel(sd_path, sheet = "study_level")

#import study level risk of bias data for individual RCTs
study_irob <- read_excel(sd_path, sheet = "iROB")

#import study level risk of bias data for cluster RCTs
study_crob <- read_excel(sd_path, sheet = "cROB")

#import study level risk of bias data for non-randomized trials
study_robins <- read_excel(sd_path, sheet = "ROBINS-I")

#import group level descriptive data
group_level <- read_excel(sd_path, sheet = "group_level")

#import outcome level descriptive data
outcome_level <- read_excel(sd_path, sheet = "outcome_level")

#import external links
public_links <- import(here("data", "DPO_public_links.xlsx")) %>% 
  janitor::clean_names() %>% 
  select(refid, study_author_year, starts_with("link"))

##Tidy
#create object to match revision code
ps_elig_td <- ps_eligibility

#pull list of included studies
inc_ps <- ps_eligibility %>%
  filter(decision == "Include") %>%
  pull(study)

#create object to match revision code
td_cm <- ps_cm

#clean study level data
td_study <- study_level %>%
  arrange(str_to_lower(study_author_year)) %>%
  mutate(cluster_size = as.numeric(cluster_size),
         school_type = case_when(school_type == "Public Private" ~ "Public, Private",
                                 school_type == "Private Public" ~ "Private, Public",
                                 TRUE ~ school_type),
         school_type = str_replace(school_type, "\r\n", ", ")) %>%
  mutate_if(is.numeric, ~ if_else(. == -999, NA_real_, .))

#extract study id and study names
study_idbyname <- td_study %>%
  select(primary_study_id, study_author_year)

#select variables for irob ratings
irob_df <- study_irob %>%
  select(primary_study_id, ends_with("judgment"), iROB_overall_rating)

#select variables for crob ratings
crob_df <- study_crob %>%
  select(primary_study_id, ends_with("judgment"), cROB_overall_rating)

#select variables for robins-i info
robins_df <- study_robins %>%
  select(primary_study_id, ends_with("judgment"), robins_overall_rating)

#group level
td_group <- group_level %>%
  mutate(intervention_intensity = case_when(intervention_intensity == "20 to 30" ~ "50",
                                            intervention_intensity == "20 to 40" ~ "30",
                                            intervention_intensity == "20 to 40" ~ "30",
                                            intervention_intensity == "20 to 60" ~ "40",
                                            intervention_intensity == "30 to 60" ~ "45",
                                            intervention_intensity == "30 to 90" ~ "60",
                                            intervention_intensity == "35 to 60" ~ "47.5",
                                            intervention_intensity == "35 to 40" ~ "37.5",
                                            intervention_intensity == "40 to 60" ~ "50",
                                            intervention_intensity == "40 to 45" ~ "42.5",
                                            intervention_intensity == "40 to 50" ~ "45",
                                            intervention_intensity == "45 to 50" ~ "47.5",
                                            intervention_intensity == "45 to 50" ~ "47.5",
                                            intervention_intensity == "45 to 60" ~ "52.5",
                                            intervention_intensity == "45 to 90" ~ "67.5",
                                            intervention_intensity == "50 to 60" ~ "55",
                                            TRUE ~ intervention_intensity)) %>%
  mutate(intervention_intensity = as.numeric(intervention_intensity),
         intervention_frequency = ifelse(intervention_frequency == "6. Cannot Tell", "-999", intervention_frequency)) %>%
  mutate_if(is.numeric, ~ if_else(. == -999, NA_real_, .))

#make study ID numeric and create variable that aggregates outcome measures
td_outcome <- outcome_level %>%
  mutate(primary_study_id = as.numeric(primary_study_id)) %>%
  mutate(outcome_measure_lc = str_to_lower(outcome_measure),
         agg_outcome_meas = case_when(str_detect(outcome_measure_lc, "beck depression inventory") ~
                                        "Beck Depression Inventory",
                                      str_detect(outcome_measure_lc, "center for epidemiologic studies depression scale") ~
                                        "Center for Epidemiologic Studies Depression Scale",
                                      str_detect(outcome_measure_lc, "children") & str_detect(outcome_measure_lc, "depression inventory") ~
                                        "Children’s Depression Inventory",
                                      str_detect(outcome_measure_lc, "revised children’s manifest anxiety scale") ~
                                        "Revised Children’s Manifest Anxiety Scale",
                                      str_detect(outcome_measure_lc, "mood and feelings questionnaire") ~
                                        "Mood and Feelings Questionnaire",
                                      str_detect(outcome_measure_lc, "depression anxiety stress scale") ~
                                        "Depression Anxiety Stress Scale",
                                      str_detect(outcome_measure_lc, "reynolds adolescent depression scale") ~
                                        "Reynolds Adolescent Depression Scale",
                                      str_detect(outcome_measure_lc, "spence") & str_detect(outcome_measure_lc, "anxiety scale") ~
                                        "Spence Children's Anxiety Scale",
                                      str_detect(outcome_measure_lc, "structured clinical interview") ~ "Structured Clinical Interview",
                                      TRUE ~ outcome_measure))

#create function to clean outcome_measure variable
mutate_outcome_measure <- function(df){
  df %>%
    mutate(outcome_measure_lc = str_to_lower(outcome_measure),
           agg_outcome_meas = case_when(str_detect(outcome_measure_lc, "beck depression inventory") ~
                                          "Beck Depression Inventory",
                                        str_detect(outcome_measure_lc, "center for epidemiologic studies depression scale") ~
                                          "Center for Epidemiologic Studies Depression Scale",
                                        str_detect(outcome_measure_lc, "children") & str_detect(outcome_measure_lc, "depression inventory") ~
                                          "Children’s Depression Inventory",
                                        str_detect(outcome_measure_lc, "revised children’s manifest anxiety scale") ~
                                          "Revised Children’s Manifest Anxiety Scale",
                                        str_detect(outcome_measure_lc, "mood and feelings questionnaire") ~
                                          "Mood and Feelings Questionnaire",
                                        str_detect(outcome_measure_lc, "depression anxiety stress scale") ~
                                          "Depression Anxiety Stress Scale",
                                        str_detect(outcome_measure_lc, "reynolds adolescent depression scale") ~
                                          "Reynolds Adolescent Depression Scale",
                                        str_detect(outcome_measure_lc, "spence") & str_detect(outcome_measure_lc, "anxiety scale") ~
                                          "Spence Children's Anxiety Scale",
                                        str_detect(outcome_measure_lc, "structured clinical interview") ~ "Structured Clinical Interview",
                                        str_detect(outcome_measure_lc, "diagnostic interview for children and adolescents") ~ "Diagnostic Interview for Children and Adolescents",
                                        str_detect(outcome_measure_lc, "reynolds child depression scale") ~ "Reynolds Child Depression Scale",
                                        str_detect(outcome_measure_lc, "revised children's anxiety and depression scale") ~ "Revised Children's Anxiety and Depression Scale",
                                        str_detect(outcome_measure_lc, "multidimensional anxiety scale for children") ~ "Multidimensional Anxiety Scale for Children",
                                        str_detect(outcome_measure_lc, "children’s automatic thoughts scale") ~ "Children’s Automatic Thoughts Scale",
                                        str_detect(outcome_measure_lc, "stai-ch") ~ "State-Trait Anxiety Inventory for Children",
                                        TRUE ~ outcome_measure))
}

##Format
#select relevant individual rob data
t4_irob <- study_irob %>%
  select(primary_study_id, iROB_overall_rating) %>%
  rename(overall_rob_rating = iROB_overall_rating)

#select relevant cluster rob data
t4_crob <- study_crob %>%
  select(primary_study_id, cROB_overall_rating) %>%
  rename(overall_rob_rating = cROB_overall_rating)

#select relevant QED rob data
t4_robins <- study_robins %>%
  select(primary_study_id, robins_overall_rating) %>%
  rename(overall_rob_rating = robins_overall_rating)

#bind together all rob data for primary studies
t4_allrob <- rbind(t4_irob, t4_crob, t4_robins)
#select variables needed from group level data
t4_group <- group_level %>%
  select(primary_study_id, group_number, group_type, gname, ig_group_type,  comparison_type) %>%
  left_join(study_idbyname) %>%
  mutate_all(list(~ifelse(. == -999, "Not reported", .))) %>%
  mutate_at(vars(group_type, ig_group_type, comparison_type), list(~str_remove(., "^[0-9]+\\. "))) %>%
  select(primary_study_id, study_author_year, everything()) %>%
  arrange(study_author_year)

#transform intervention names data to merge
t4group_intnames <- t4_group %>%
  group_by(study_author_year, group_type) %>%
  summarize(group_names = paste(gname, collapse = "; ")) %>%
  ungroup() %>%
  filter(group_type == "Intervention")

#transform comparison types data to merge
t4group_compnames <- t4_group %>%
  mutate(comparison_type = case_when(comparison_type == "Active" ~ paste("Active:", gname),
                                     TRUE ~ comparison_type)) %>%
  group_by(study_author_year, group_type) %>%
  summarize(comp_type = paste(comparison_type, collapse = "; ")) %>%
  ungroup() %>%
  filter(group_type == "Comparison")

#merge group names and transform to wide format
t4group_wide <- t4group_intnames %>%
  left_join(t4group_compnames, by = "study_author_year") %>%
  rename(Intervention = group_names,
         Comparison = comp_type) %>%
  select(-starts_with("group")) %>%
  mutate_all(~ str_replace_all(., "Cannot tell", "Not Reported"))


#select study level info and format for table
a5_info <- td_study %>%
  mutate_at(vars(school_level, state, urbanicity, research_design, assignment_level, cluster_type), list(~str_remove(., "^[0-9]+\\. "))) %>%
  mutate(school_level = str_replace(school_level, ",(...)(.*)", ",\\2"),
         urbanicity = str_replace_all(urbanicity, "\\s\\d+\\.", ",")) %>%
  mutate(school_level = case_when(school_level == "Only Reported Secondary School" ~ "Secondary School",
                                  school_level == "Only Reported Primary School" ~ "Primary School",
                                  school_level == "Only Reported Primary School, Only Reported Secondary School" ~ "Primary School , Secondary School",
                                  school_level == "Cannot tell" ~ "Not reported",
                                  TRUE ~ school_level),
         grade_level = ifelse(grade_level == "Cannot tell", "Not reported", grade_level),
         urbanicity = str_replace_all(urbanicity, "\\s+,", ","),
         urbanicity = str_replace_all(urbanicity, ",,", ","),
         cluster_type = ifelse(assignment_level != "Cluster", "NA", cluster_type),
         cluster_size = ifelse(assignment_level != "Cluster", "NA", cluster_size)) %>%
  mutate(school_level = str_replace(school_level, "(,.)", " and "),
         percent_mixed = ifelse(percent_mixed == "-999", NA_real_, as.numeric(percent_mixed)),
         percent_other = ifelse(percent_other == "-999", NA_real_, as.numeric(percent_other)),
         state = ifelse(state == "Cannot tell", "Not reported", state),
         research_design = ifelse(research_design == "QED - Regression adjustment", "Quasi-experimental design", research_design),
         age_dispersion = ifelse(age_average_type == "1. Mean" & age_dispersion != "-999", as.character(round(as.numeric(age_dispersion), 2)), age_dispersion)) %>%
  mutate(study_start_date = ifelse(nchar(study_start_date) == 10, format(ymd(study_start_date), "%B %d, %Y"), study_start_date),
         study_end_date = ifelse(nchar(study_end_date) == 10, format(ymd(study_end_date), "%B %d, %Y"), study_end_date)) %>%
  mutate(study_start_date = ifelse(nchar(study_start_date) == 7, format(ym(study_start_date), "%B %Y"), study_start_date),
         study_end_date = ifelse(nchar(study_end_date) == 7, format(ym(study_end_date), "%B %Y"), study_end_date)) %>%
  mutate(number_participants = format(number_participants, big.mark = ",", scientific = FALSE),
         sample_size = case_when(!is.na(number_participants) & !is.na(number_classrooms) & !is.na(number_schools) ~
                                   paste(number_participants, "students,", number_classrooms, "classrooms,", number_schools, "schools"),
                                 !is.na(number_participants) & !is.na(number_classrooms) & is.na(number_schools) ~
                                   paste(number_participants, "students,", number_classrooms, "classrooms"),
                                 !is.na(number_participants) & is.na(number_classrooms) & is.na(number_schools) ~
                                   paste(number_participants, "students"),
                                 !is.na(number_participants) & is.na(number_classrooms) & !is.na(number_schools) ~
                                   paste(number_participants, "students,", number_schools, "schools"),
                                 is.na(number_participants) & !is.na(number_classrooms) & !is.na(number_schools) ~
                                   paste(number_classrooms, "classrooms,", number_schools, "schools"),
                                 is.na(number_participants) & !is.na(number_classrooms) & is.na(number_schools) ~
                                   paste(number_classrooms, "classrooms"),
                                 is.na(number_participants) & is.na(number_classrooms) & !is.na(number_schools) ~
                                   paste(number_schools, "schools")),
         sample_size = str_trim(sample_size, side = "left"),
         grd_schl_level = paste(grade_level, "/", school_level),
         age_mean_sd = paste0(average_age, " (", age_dispersion, ")"),
         percent_female = ifelse(!is.na(percent_female), paste0(percent_female * 100, "%"), "Not reported"),
         percent_ELL = ifelse(!is.na(percent_ELL), paste0(percent_ELL * 100, "%"), "Not reported"),
         percent_FRPL = ifelse(!is.na(percent_FRPL), paste0(percent_FRPL * 100, "%"), "Not reported"),
         percent_race_ethnicity = case_when(is.na(percent_white) & is.na(percent_black) & is.na(percent_aian) &
                                              is.na(percent_asian) & is.na(percent_nhpi) & is.na(percent_latinx) &
                                              is.na(percent_mixed) & is.na(percent_other) ~ "Not reported",
                                            TRUE ~ paste0(percent_aian * 100, "% AIAN, ", percent_asian * 100, "% Asian, ",
                                                          percent_black * 100, "% Black, ", percent_latinx * 100, "% Latinx, ",
                                                          percent_nhpi * 100, "% NHPI, ", percent_white * 100, "% White, ",
                                                          percent_mixed * 100, "% Mixed, ", percent_other * 100, "% Other")),
         country_state = case_when(state != "Non-US Study" ~ paste0(country, " (", state, ")"),
                                   TRUE ~ country)) %>%
  mutate(age_mean_sd = case_when(age_mean_sd == "NA (-999)" ~ "Not reported",
                                 str_detect(age_mean_sd, "-999") ~ paste(average_age),
                                 TRUE ~ age_mean_sd),
         percent_race_ethnicity = str_replace_all(percent_race_ethnicity, c("NA% AIAN, " = "", "NA% Asian, " = "", "NA% Black, " = "",
                                                                            "NA% Latinx, " = "", "NA% NHPI, " = "", "NA% White, " = "",
                                                                            "NA% Mixed, " = "", "NA% Other" = ""))) %>%
  mutate(percent_race_ethnicity = gsub(", $", "", percent_race_ethnicity)) %>%
  mutate(across(everything(), ~ifelse(.x == -999 | .x == "Cannot tell" | .x == "Cannot Tell" | is.na(.x), "Not reported", .x))) %>%
  select(study_author_year, study_start_date, study_end_date, recruitment_approach,
         eligibility_criteria, research_design, assignment_level, cluster_type, cluster_size, study_groups,
         sample_size, grd_schl_level, age_mean_sd, percent_female, percent_race_ethnicity, percent_ELL, percent_FRPL,
         country_state, urbanicity, school_type, consort_flow_diagram, study_registration, availability_statement,
         grade_level, school_level, country, state, study_author_name)

#merge with group/intervention names created for table 4
a5_groups <- left_join(a5_info, t4group_wide)

#merge with outcome data and combine outcomes for each study
a5_outcome <- outcome_level %>%
  left_join(study_idbyname) %>%
  mutate(outcome_domain = str_remove(outcome_domain, "^[0-9]+\\. ")) %>%
  distinct(study_author_year, outcome_domain, .keep_all = TRUE) %>%
  group_by(study_author_year) %>%
  summarize(outcome_list = paste(outcome_domain, collapse = ", ")) %>%
  ungroup() %>%
  mutate(outcome_list = sapply(lapply(str_split(outcome_list, ", "), sort), paste, collapse = ", ")) %>%
  select(study_author_year, outcome_list) %>%
  right_join(a5_groups) %>%
  arrange(str_to_lower(study_author_year))

#merge with rob data created in table 4
a5_rob <- t4_allrob %>%
  left_join(study_idbyname) %>%
  right_join(a5_outcome) %>%
  mutate(overall_rob_rating = str_remove(overall_rob_rating, "^[0-9]+\\. "),
         overall_rob_rating = str_replace(overall_rob_rating, "-999", "Not reported")) %>%
  select(study_author_year, study_start_date, study_end_date, recruitment_approach,
         eligibility_criteria, research_design, assignment_level, cluster_type, cluster_size, study_groups,
         sample_size, grd_schl_level, age_mean_sd, percent_female, percent_race_ethnicity, percent_ELL, percent_FRPL,
         country_state, urbanicity, school_type, Intervention, Comparison, outcome_list, overall_rob_rating,
         consort_flow_diagram, study_registration, availability_statement,
         grade_level, school_level, country, state, study_author_name)

#combine all references for a primary study in a single variable, separated by a semicolon
ps_citations <- ps_allreferences %>%
  rename(citation = report) %>%
  filter(study %in% inc_ps)

#create a variable that combines all references for a study into one cell
study_reports <- ps_citations %>%
  group_by(study) %>%
  summarize(all_reports = paste(citation, collapse = " ; ")) %>%
  ungroup() %>%
  mutate(all_reports = str_replace_all(all_reports, "; ", "<br><br>")) %>%
  rename(study_author_year = study)

#extract titles and study names from Zotero .bib
ps_titles <- bib_ps_df %>%
  rowwise() %>%
  mutate(author_unlist = paste(lapply(author, paste, collapse = ","), collapse = ", "),
         author = str_extract(author_unlist, "^[^,]+"),
         author_year = paste(author, year),
         title = str_replace_all(title, "[{}]", ""),
         title = str_remove(title, "\\.$"),
         merge_author = stri_trans_general(author_year, "Latin-ASCII"),
         merge_author = str_to_lower(merge_author)) %>%
  arrange(str_to_lower(author_year))

#format public links df to merge
study_links <- public_links %>% 
  mutate(author_year = str_replace(study_author_year, "(\\d{4}).*", "\\1"),
         merge_author = stri_trans_general(author_year, "Latin-ASCII"),
         merge_author = str_to_lower(merge_author)) %>% 
  distinct(merge_author, .keep_all = TRUE) %>% 
  select(-study_author_year, -author_year, -refid)

#merge titles with full citation and links
study_ref_info <- study_reports %>%
  mutate(author_year = str_replace(study_author_year, "(\\d{4}).*", "\\1"),
         merge_author = stri_trans_general(author_year, "Latin-ASCII"),
         merge_author = str_to_lower(merge_author)) %>%
  select(-author_year) %>%
  left_join(ps_titles) %>%
  left_join(study_links) %>% 
  select(title, all_reports, merge_author, starts_with("link")) 


# merge all info for appendix 5 together
a5 <- a5_rob %>%
  mutate(author_year = str_replace(study_author_year, "(\\d{4}).*", "\\1"),
         merge_author = stri_trans_general(author_year, "Latin-ASCII"),
         merge_author = str_to_lower(merge_author)) %>%
  left_join(study_ref_info, by = "merge_author", multiple = "all") %>%
  distinct(study_author_year, .keep_all = TRUE) %>%
  mutate(study_years = ifelse(study_start_date == "Not reported" & study_end_date == "Not reported", "Not Reported",
                              paste0(study_start_date, " - ", study_end_date)),
         cluster_level_type = ifelse(assignment_level == "Cluster", paste0(assignment_level, " (", cluster_type, ")"),
                                     assignment_level),
         publication_year = str_extract(study_author_year, "\\d{4}"),
         outcome_list = ifelse(is.na(outcome_list), "Not reported", outcome_list)) %>%
  select(study_author_year, publication_year, title, study_author_name,
         country_state, study_years, urbanicity, school_type,
         grd_schl_level, sample_size, age_mean_sd,
         Intervention, Comparison, outcome_list,
         research_design, cluster_level_type,
         percent_female, percent_race_ethnicity, percent_ELL, percent_FRPL,
         grade_level, school_level, country, state, starts_with("link")) %>%
  mutate_if(is.numeric, as.character) %>%
  #arrange(str_to_lower(stringi::stri_trans_general(study_author_year, "Latin-ASCII")))
  arrange(desc(publication_year))

# Export cleaned data for use in app
#export(a5, here("outputs", "data_dashboard", "data", "dpo_app_data.xlsx"))
#export(a5, here("data", "dpo_app_data.xlsx"))
