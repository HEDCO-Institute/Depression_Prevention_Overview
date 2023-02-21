---
title: "Depression Prevention Overview Repository"
output: 
  html_document:
   embed_resources: true
   standalone: true
---


This repository contains the data and R code to reproduce the results of our Depression Prevention Overview titled "School Based Interventions for Primary and Secondary Prevention of Depression: An Overview of Systematic Reviews with Meta-Analyses." <br>
Additional materials, including the protocol, **codebook**, and **report** are available at <https://osf.io/c7nyz/>.

## Computational Environment

<!-- Plan to eventually create and include docker images to reproduce environment-->

All of our analyses were ran on a Windows 10 Enterprise platform (x86_64-w64-mingw32/x64). <br>
Our analyses were conducted in R (version 4.2.2) and are reported in Rmarkdown files (version 2.14) <br>
We use a variety of R packages that need to be installed. Code to install and load all required packages are included in the beginning of the coding scripts. See below for the full list of required packages (and version used):

- `pacman` (0.5.1)
- `devtools` (2.4.5)
- `here` (1.0.1)
- `readxl` (1.4.0)
- `janitor` (2.1.0)
- `tidyverse` (1.3.2)
- `openxlsx` (4.2.5)
- `robumeta` (2.0)
- `metafor` (3.8-1)
- `ccaR` (0.1.0)
- `robvis` (0.3.0.900)

## Data

The excel data and codebook for this overview are publicly available at <https://osf.io/c7nyz/>. All data files are included in the data folder of this repository. See below for a description of each data file: <br>
<br>

#### Review Level Data:

| Data File | Sheet Name | Description | Data Structure |
|-----------|:----------:|-------------|-----------| 
| Depression_Overview_FileMaker_Data.xlsx | reference_level | Abstract and full-text screening decisions | One row per reference ID (citation) |
| Depression_Overview_FileMaker_Data.xlsx | review_level | Extracted descriptive data on eligible reviews | One row per review ID (systematic review)|
| Depression_Overview_FileMaker_Data.xlsx | amstar| AMSTAR risk of bias assessment | One row per review ID |
| Depression_Overview_FileMaker_Data.xlsx | robis | ROBIS risk of bias assessment | One row per review ID |
<br>

#### Primary Study Level Data:

| Data File | Sheet Name | Description | File Structure |
|-----------|:----------:|-------------|-----------| 
| Eligibility_Data.xlsx | Eligibility_Decisions | Abstract and full-text screening decisions | One row per study ID (primary study) |
| Eligibility_Data.xlsx | Reports | Citations associated with each study ID for tracking multiple reports | One row per primary study reference |
| Eligibility_Data.xlsx | Citation_Matrix| Primary study overlap across reviews | One row per study ID; columns are review IDs |
| Depression_Overview_FileMaker_Data.xlsx | study_level | Extracted descriptive data on eligible primary studies | One row per study ID |
| Depression_Overview_FileMaker_Data.xlsx | iROB | Risk of bias assessment for individual RCTs | One row per study ID |
| Depression_Overview_FileMaker_Data.xlsx | cROB | Risk of bias assessment for cluster RCTs | One row per study ID |
| Depression_Overview_FileMaker_Data.xlsx | ROBINS-I | Risk of bias assessment for non-randomized studies | One row per study ID |
| Depression_Overview_FileMaker_Data.xlsx | group_level | Extracted descriptive data for each study group | One row per user-created group ID |
| Depression_Overview_FileMaker_Data.xlsx | outcome_level | Extracted descriptive data for each outcome of interest | One row per user-created outcome ID |
| Depression_Overview_FileMaker_Data.xlsx | effect_level | Extracted effect size data for each group comparison and outcome combination | One row per user-created effect size ID |
| Depression_Overview_Meta_Analysis.xlsx | Depression Diagnosis | Effect size data for depression diagnosis meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Depression Symptoms | Effect size data for depression symptoms meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Anxiety | Effect size data for anxiety meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Educational Achievement | Effect size data for educational achievement meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Self Harm | Effect size data for self harm meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Stress | Effect size data for stress meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Suicidal Ideation | Effect size data for suicidal ideation meta-analysis | **One row per follow-up effect size** |
| Depression_Overview_Meta_Analysis.xlsx | Well-being | Effect size data for well-being meta-analysis | **One row per follow-up effect size** | 

## Code

All code necessary to reproduce our findings are included in one main Rmarkdown file in the scripts folder: 

- Analysis_Script.Rmd

This file is organized to present results in the order in which they appear in our report, "School Based Interventions for Primary and Secondary Prevention of Depression: An Overview of Systematic Reviews with Meta-Analyses," with corresponding section headers.  

## Replication Steps

To replicate our results: 

**If you have Rstudio and Git installed and connected to your GitHub account:**

1. Clone this repository to your local machine ([click for help](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2))
1. Run Analysis_Script.Rmd

**If you need to install or connect R, Rstudio, Git, and/or GitHub:**

1. [Create a GitHub account](https://happygitwithr.com/github-acct.html#github-acct)
1. [Install R and RStudio](https://happygitwithr.com/install-r-rstudio.html)
1. [Install git](https://happygitwithr.com/install-git.html)
1. [Link git to your GitHub account](https://happygitwithr.com/hello-git.html)
1. [Sign into GitHub in Rstudio](https://happygitwithr.com/https-pat.html)

**To reproduce our results without using Git and GitHub, you may use the following steps:** 

1. Create an R project on your local machine ([click for help](https://rpubs.com/Dee_Chiluiza/create_RProject))
1. Create the following folders in your R project root directory: data, scripts
1. Download all data files listed above from the repository and put them in the data folder you created
1. Download the Analysis_Script.Rmd listed above from the repository and put it in the scripts folder you created
1. Run Analysis_Script.Rmd

<!-- ## Additional Information-->

<!-- anything from SSDA guidance? IF ANY NOT MENTIONED ABOVE-->

<!-- TABLES AND FIGURES SECTION, and add report folder to replication steps-->

<!-- Plan to eventually create and include docker images to reproduce environment-->

## Contact

If you have any questions, concerns, or feedback, feel free to email Shaina Trevino at [strevino\@uoregon.edu](mailto:strevino@uoregon.edu){.email}

