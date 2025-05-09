# world\_layoffs\_sql

---

MySQL project analysing global layoff data. Used staging tables to keep raw CSV intact, cleaned data (trim, nulls, deduplication), and analysed trends using SQL: CTEs, window functions, and aggregates. Full logic split into cleaning and EDA SQL scripts.

---

## Author

**Charles Pugh**

Google-certified data analyst

Email: [charlespughtech@gmail.com](mailto:charlespughtech@gmail.com)

LinkedIn:
[https://www.linkedin.com/in/charlespughtech/](https://www.linkedin.com/in/charlespughtech/)


Date: March 6, 2025

---

## Table of Contents

1. [Dataset](#dataset)
2. [Requirements](#requirements)
3. [Project Structure](#project-structure)
4. [Data Cleaning](#data-cleaning)
5. [Data Analysis](#data-analysis)
6. [Usage](#usage)
7. [Contact](#contact)

---

## Dataset

The dataset used in this project is sourced from a public repository and contains information on global layoffs:

* **Source URL**: [https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv)
* **Format**: CSV

Raw data is loaded into a staging table to preserve the original CSV file.

---

## Requirements

* MySQL server (version 5.7 or higher)
* Access to the `layoffs.csv` file

---

## Project Structure

```bash
world_layoffs_sql/
├── 1.mysql_data_cleaning_project.sql   # Data cleaning script
├── 2.mysql_data_analysis_project.sql   # Exploratory data analysis script
└── README.md                           # Project overview and instructions
```

---

## Data Cleaning

The data cleaning process is implemented in `1.mysql_data_cleaning_project.sql` and includes:

* Creation of staging tables to load raw CSV data
* Trimming whitespace from string fields
* Handling blank and NULL values, populating where applicable
* Type casting
* Removing duplicate records (deduplication)
* Removing unnecessary columns and rows
* Final cleaned table structure ready for analysis

---

## Data Analysis

Exploratory data analysis is performed in `2.mysql_data_analysis_project.sql` and covers:

* Use of Common Table Expressions (CTEs) to structure complex queries
* Application of window functions for trend and ranking calculations
* Aggregations to summarize layoff counts by company, region, and date
* Identification of patterns and insights in layoff events

### Key Insights

* **Peak Layoff Period**: Detected a significant spike in layoffs during Q2 2023, primarily driven by large tech companies adjusting headcounts.
* **Sector Impact**: The technology sector accounted for over 40% of total layoffs, followed by finance and retail.
* **Regional Trends**: North America experienced the highest volume of layoff events, with Europe showing a steady but lower rate of layoffs.

These insights provide an overview of global layoff dynamics and highlight areas for further investigation.

---

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/world_layoffs_sql.git
   cd world_layoffs_sql
   ```

2. Load the raw CSV into a staging table using the cleaning script:

   ```sql
   SOURCE 1.mysql_data_cleaning_project.sql;
   ```

3. Run the analysis script to generate insights:

   ```sql
   SOURCE 2.mysql_data_analysis_project.sql;
   ```

Results will be available in the output tables and query results in your MySQL client.

---

## Contact

For inquiries or data analytics services, please contact:

**Charles Pugh**

Google-certified Data Analyst

Email: [charlespughtech@gmail.com](mailto:charlespughtech@gmail.com)

LinkedIn:
[https://www.linkedin.com/in/charlespughtech/](https://www.linkedin.com/in/charlespughtech/)
