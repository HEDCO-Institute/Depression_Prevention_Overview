
# **Replication Package for 2024 JCCP Publication**

**Date of Release:** 3/24/2025  
**Title:** Effectiveness of School-Based Depression Prevention Interventions: An Overview of Systematic Reviews With Meta-Analyses on Depression Outcomes  
**OSF Component for Publication:** <https://osf.io/kg57y/> <br>
**Package Author:** Shaina Trevino 



## **🔹 Overview**
This folder contains the replication materials for the following publication:  

Grant, S., Schweer-Collins, M., Day, E., Trevino, S. D., Steinka-Fry, K., & Tanner-Smith, E. E. (2024). Effectiveness of school-based depression prevention interventions: An overview of systematic reviews with meta-analyses on depression outcomes. Journal of Consulting and Clinical Psychology. Advance online publication. <https://doi.org/10.1037/ccp0000930>

This replication package follows **[AEA Data and Code Availability Standards](https://datacodestandard.org/)** and includes:
- Datasets used to generate reported results.
- Code necessary to reproduce quantitative results reported.
- Computational environment details to ensure reproducibility.



## **🔹 Data and Code Availability Statement**
### **Data Sources**
The data used in this publication were derived from a larger [living systematic review on school-based depression prevention](https://github.com/HEDCO-Institute/Depression_Prevention_Overview). 
- Data for this publication were collected in FileMaker initially and additional data collection was completed in DistillerSR. 
- Some files, such as the citation matrix, were constructed in excel.
- Datasets used for this publication reflect a fixed version of the data, captured during analysis. 
- Metadata (variable names and descriptions) are provided as the first tab of each data file.

The following datasets used for analyses are available in the `data` subfolder:

| Data File | Description | Data Structure |
|-----------|-------------|-----------| 
| `2024_JCCP_citation_matrix.xlsx` | Primary study overlap across reviews and primary study eligibility decisions| One row per primary study included in eligible reviews | 
| `2024_JCCP_Depression_Overview_Review_Data.xlsx` | Extracted descriptive data, study quality assessment (AMSTAR), and risk of bias assessment (ROBIS) for eligible reviews from FileMaker | One row per eligible review |
| `2024_JCCP_Depression_Overview_Search_Data.xlsx` | Abstract and full-text screening decisions from FileMaker | One row per report/citation | 
| `2024_JCCP_supplemental_eligibility.xlsx` | Full-text eligibility decisions from Distiller | One row per systematic review |
| `2024_JCCP_supplemental_review_data.xlsx` |  Extracted descriptive data, study quality assessment (AMSTAR), and risk of bias assessment (ROBIS) for eligible reviews from DistillerSR | One row per eligible review |
| `2024_JCCP_included_reviews.bib` | Zotero bibliography file of included systematic reviews assessed in FileMaker | One entry per review (main citation when multiple reports) |
<br>

### **Analysis Script**
The analysis script used to generate quantitative results for this publication is in the `code` subfolder. 

### **Data Citation**
Please cite this version of the data as follows:

Trevino, S. D., Grant, S., Schweer-Collins, M., Day, E., Steinka-Fry, K., & Tanner-Smith, E. E. (2024). Data for "School-Based Interventions for Primary and Secondary Prevention of Depression: An Overview of Systematic Reviews with Meta-Analyses." [OSF](https://osf.io/kg57y/). doi:10.17605/OSF.IO/KG57Y 

### **Handling of Missing Data**
- Missing values in the datasets are coded as `-999`, `Not Reported`, or `NA` and indicate those values were not reported in studies/reviews.




## **🔹 Computational Requirements**
### **Software Environment**
- **R Version:** 4.2.2  
- **Operating System:** Windows 10 Enterprise (x86_64-w64-mingw32/x64)  

### **Reproducing the Environment**
The `2024_JCCP_analysis.Rmd` file contains code to install the correct package versions and set up the environment using the `renv` package:
1. Install `renv` (if not already installed):
```r
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
```
2. Load the environment:
```r
renv::load("publications/2024_JCCP")
```
3. Restore any missing packages:
```r
renv::restore("publications/2024_JCCP")
```

Once the environment is restored, load the necessary packages:
```r
library(rmarkdown)
library(devtools)
library(here)
library(readxl)
library(janitor)
library(tidyverse)
library(openxlsx)
library(lubridate)
library(gt)
library(webshot2)
library(stringi)
library(bib2df)
library(ccaR)
```



## **🔹 Instructions for Replication**

### **Data Preparation and Analysis**
To replicate our results: 

**If you have Rstudio and Git installed and connected to your GitHub account:**

1. Clone the [main repository](https://github.com/HEDCO-Institute/Depression_Prevention_Overview) to your local machine ([click for help](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2))
1. Open the `Depression_Prevention_Overview` R project in R Studio
1. Navigate to the `publications/2024_JCCP` folder
1. Run the `2024_JCCP_analysis.Rmd` script in the `code` subfolder (this should automatically activate the `renv` environment)

**If you need to install or connect R, Rstudio, Git, and/or GitHub:**

1. [Create a GitHub account](https://happygitwithr.com/github-acct.html#github-acct)
1. [Install R and RStudio](https://happygitwithr.com/install-r-rstudio.html)
1. [Install Git](https://happygitwithr.com/install-git.html)
1. [Link Git to your GitHub account](https://happygitwithr.com/hello-git.html)
1. [Sign into GitHub in Rstudio](https://happygitwithr.com/https-pat.html)

**To reproduce our results without using Git and GitHub, you may use the following steps:** 

1. Download the ZIP file from the [main repository](https://github.com/HEDCO-Institute/Depression_Prevention_Overview) 
1. Open the `Depression_Prevention_Overview` R project in R Studio (this will automatically set the working directory)
1. Navigate to the `publications/2024_JCCP` folder
1. Run the `2024_JCCP_analysis.Rmd` script in the `code` subfolder (this should automatically activate the `renv` environment)


### **Notes on Reproducibility**
- All file paths are relative; no hardcoded paths are used.
- Data cleaning, analyses, and visualizations are fully automated in the provided `.Rmd` file.
- All generated tables, figures, and supplements are saved in the `outputs` subfolder. If you prefer not to rerun the scripts, you can directly access these files
- Some results were removed or reformatted in the final published manuscript following reviewer recommendations. Thus, generated outputs may not exactly match the final published tables or figures.

### **Non-Reproducible Elements**
Some components cannot be reproduced using the analysis script:
- Eligibility numbers reported in the PRISMA diagram were manually compiled from DistillerSR
- Table 3, Figure 1, and Supplement 1 were manually created in Word and are not part of the outputs generated by the analysis script

### **Known Discrepancies**
There are some discrepancies between outputs from the analysis script and those reported in the publication since data package was created after publication:
- The final published paper reports 472 included studies across reviews, but the analysis script reports 473 studies due to a data update
- In Table 1, two responses for Kambara 2021 were corrected:
  - AMSTAR Domain 9 and Domain 11 should be reported as "No" rather than "Yes" due to the NRSI rating




## **🔹 Folder Structure**
```
📁 2024_JCCP/
│── 📁 code/                   # Analysis scripts for reproducibility
│    └── 2024_JCCP_analysis.Rmd
│
│── 📁 data/                   # Datasets used for this publication
│    ├── 2024_JCCP_citation_matrix.xlsx
│    ├── 2024_JCCP_Depression_Overview_Review_Data.xlsx
│    ├── 2024_JCCP_Depression_Overview_Search_Data.xlsx
│    ├── 2024_JCCP_included_reviews.bib
│    ├── 2024_JCCP_supplemental_eligibility.xlsx
│    └── 2024_JCCP_supplemental_review_data.xlsx
│
│── 📁 outputs/                # Generated tables, figures, and supplements
│    ├── 2024_JCCP_figure2.png
│    ├── 2024_JCCP_figure3.png
│    ├── 2024_JCCP_supplement2.html
│    ├── 2024_JCCP_supplement3.html
│    ├── 2024_JCCP_table1.html
│    └── 2024_JCCP_table2.html
│
│── 📁 renv/                   # Renv environment for reproducibility
│── 📄 renv.lock               # Package versions and dependencies
│── 📄 .Rprofile               # Renv configuration file
│── 📄 README.md               # This README document
```




## **🔹 Licensing**
The code and data in this replication package are licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0); see the LICENSE file in the main repository root directory for full terms



## **🔹 Contact Information**
For questions about this replication package, contact:  
✉️ **Shaina Trevino** (strevino@uoregon.edu)  

