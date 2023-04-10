## Depression Prevention Overview Repository

This repository contains the data and R code to reproduce the results of our Depression Prevention Overview titled "School Based Interventions for Primary and Secondary Prevention of Depression: An Overview of Systematic Reviews with Meta-Analyses." <br>
Additional materials, including the protocol, study materials, and dissemination products are available at <https://osf.io/c7nyz/>.

## Computational Environment

All of our analyses were ran on a Windows 10 Enterprise platform (x86_64-w64-mingw32/x64). <br>
Our analyses were conducted in R (version 4.2.2) and are reported in Rmarkdown files (version 2.20) <br>
We use a variety of R packages that need to be installed. Code to install and load all required packages are included in the beginning of the coding scripts. See below for the full list of packages and versions used:

- `pacman` (0.5.1)
- `devtools` (2.4.5)
- `here` (1.0.1)
- `readxl` (1.4.0)
- `janitor` (2.1.0)
- `tidyverse` (1.3.2)
- `openxlsx` (4.2.5)
- `robumeta` (2.0)
- `metafor` (3.8-1)
- `lubridate` (1.8.0)
- `gt` (0.8.0.9000)
- `webshot2` (0.1.0)
- `DiagrammeR` (1.0.9)
- `prismadiagramR` (1.0.0)
- `stringi` (1.7.6)
- `htmltools` (0.5.4)
- `bibdf` (1.1.1)
- `ccaR` (0.1.0)
- `robvis` (0.3.0.900)

## Data

The excel data and metadata for this overview are included in the `data` folder of this repository. All data files are also publicly available at <https://osf.io/c7nyz/>. See below for a description of each data file:  <br>
<br>

#### Review Level Data:

| Data File | Sheet Name | Description | Data Structure |
|-----------|:----------:|-------------|-----------| 
| `Depression_Overview_Search_Data.xlsx` | metadata | Metadata for this file, including variable descriptions | One row per variable | 
| `Depression_Overview_Search_Data.xlsx` | reference_level | Abstract and full-text screening decisions | One row per reference ID (citation) |
| `Depression_Overview_Review_Data.xlsx` | metadata | Metadata for this file, including variable descriptions | One row per variable | 
| `Depression_Overview_Review_Data.xlsx` | review_level | Extracted descriptive data on eligible reviews | One row per review ID (systematic review)|
| `Depression_Overview_Review_Data.xlsx` | amstar| AMSTAR study quality assessment | One row per review ID |
| `Depression_Overview_Review_Data.xlsx` | robis | ROBIS risk of bias assessment | One row per review ID |
| `included_reviews.bib` | NA | Bibliography for included systematic reviews exported from Zotero | One entry per review (main citation when multiple reports) |
<br>

#### Primary Study Level Data:

| Data File | Sheet Name | Description | File Structure |
|-----------|:----------:|-------------|-----------| 
| `Depression_Overview_Eligibility_Data.xlsx` | metadata | Metadata for this file, including variable descriptions | One row per variable |
| `Depression_Overview_Eligibility_Data.xlsx` | reports | Citations associated with each study ID for tracking multiple reports | One row per primary study citation|
| `Depression_Overview_Eligibility_Data.xlsx` | citation_matrix| Primary study overlap across reviews | One row per primary study; columns are review IDs |
| `Depression_Overview_Eligibility_Data.xlsx` | eligibility_decisions | Abstract and full-text screening decisions | One row per primary study |
| `Depression_Overview_Primary_Study_Data.xlsx` | metadata | Metadata for this file, including variable descriptions | One row per variable |
| `Depression_Overview_Primary_Study_Data.xlsx` | study_level | Extracted descriptive data on eligible primary studies | One row per study ID (primary study) |
| `Depression_Overview_Primary_Study_Data.xlsx` | iROB | Risk of bias assessment for individual RCTs | One row per applicable study ID |
| `Depression_Overview_Primary_Study_Data.xlsx` | cROB | Risk of bias assessment for cluster RCTs | One row per applicable study ID |
| `Depression_Overview_Primary_Study_Data.xlsx` | ROBINS-I | Risk of bias assessment for non-randomized studies | One row per applicable study ID |
| `Depression_Overview_Primary_Study_Data.xlsx` | group_level | Extracted descriptive data for each study group | One row per user-created group ID |
| `Depression_Overview_Primary_Study_Data.xlsx` | outcome_level | Extracted descriptive data for each outcome of interest | One row per user-created outcome ID |
| `Depression_Overview_Primary_Study_Data.xlsx` | effect_level | Extracted effect size data for each group comparison and outcome combination | One row per user-created effect size ID |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | metadata | Metadata for this file, including variable descriptions | One row per variable |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Depression Diagnosis | Effect size data for depression diagnosis meta-analysis | One row per effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Depression Symptoms | Effect size data for depression symptoms meta-analysis | One row per effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Anxiety | Effect size data for anxiety meta-analysis | One row per follow-up effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Educational Achievement | Effect size data for educational achievement meta-analysis | One row per effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Self Harm | Effect size data for self harm meta-analysis | One row per effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Stress | Effect size data for stress meta-analysis | One row per effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Suicidal Ideation | Effect size data for suicidal ideation meta-analysis | One row per effect size |
| `Depression_Overview_Meta_Analysis_Data.xlsx` | Well-being | Effect size data for well-being meta-analysis | One row per effect size | 
| `included_studies.bib` | NA | Bibliography for included primary studies exported from Zotero | One entry per primary study (main citation when multiple reports) |

## Code

All code necessary to reproduce our findings are included in one main Rmarkdown file in the scripts folder: 

- `Analysis_Script.Rmd`

This file is organized to present results in the order in which they appear in our technical report, "School Based Interventions for Primary and Secondary Prevention of Depression: An Overview of Systematic Reviews with Meta-Analyses," with corresponding section headers. There are also embedded comments and contextual information to help the user understand analysis steps and code chunks.  

## Replication Steps

To replicate our results: 

**If you have Rstudio and Git installed and connected to your GitHub account:**

1. Clone this repository to your local machine ([click for help](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2))
1. Run `Analysis_Script.Rmd`

**If you need to install or connect R, Rstudio, Git, and/or GitHub:**

1. [Create a GitHub account](https://happygitwithr.com/github-acct.html#github-acct)
1. [Install R and RStudio](https://happygitwithr.com/install-r-rstudio.html)
1. [Install git](https://happygitwithr.com/install-git.html)
1. [Link git to your GitHub account](https://happygitwithr.com/hello-git.html)
1. [Sign into GitHub in Rstudio](https://happygitwithr.com/https-pat.html)

**To reproduce our results without using Git and GitHub, you may use the following steps:** 

1. Create an R project on your local machine ([click for help](https://rpubs.com/Dee_Chiluiza/create_RProject))
1. Create the following folders in your R project root directory: `data`, `scripts`
1. Download all data files listed above from the repository and put them in the `data` folder you created
1. Download the `Analysis_Script.Rmd` listed above from the repository and put it in the `scripts` folder you created
1. Run `Analysis_Script.Rmd`

## Tables, Figures, and Appendices

All tables, figures, and appendices are located in the `report` folder of the repository in their respective sub-folders. All tables, figures, and appendices can be reproduced in HTML by running the `Analysis_Script.Rmd` file. Please note: if you do run the `Analysis_Script.Rmd`, it will export the HTML tables, figures, and appendices to the correct sub-folder in the `report` folder of the project directory. You can always find our versions of the tables, figures, and appendices in this repo.

## Contact

If you have any questions, concerns, or feedback, feel free to email Shaina Trevino at [strevino\@uoregon.edu](mailto:strevino@uoregon.edu)

