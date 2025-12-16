# Subway Ridership vs. Starbucks Stores in Seoul

## Abstract
This project explores whether higher subway station usage in Seoul is associated with a higher concentration of nearby Starbucks stores. Using October 2023 station-level ridership data and Starbucks locations within a 500m radius of each station, I evaluate the relationship via exploratory mapping, top/bottom comparisons, and statistical tests (linear regression and ANOVA). :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

![Regression between Subway Ridership and Starbucks Stores](figures/ridership_starbucks_regression.png)

## Problem
**Hypothesis:** Stations with higher total ridership (boardings + alightings) have more Starbucks stores nearby. :contentReference[oaicite:2]{index=2}

## Approach
- **Data preparation**
  - Ridership: Seoul Open Data Plaza (Oct 2023 station-by-line ridership) + station address dataset for filtering Seoul-only stations. :contentReference[oaicite:3]{index=3}
  - Starbucks: store addresses collected from Starbucks’ store locator, converted to coordinates with a geocoding tool, and counted within **500m buffers** around station locations in QGIS. :contentReference[oaicite:4]{index=4}
- **Analysis workflow**
  1. Map the spatial distribution of stations and Starbucks stores in Seoul (EDA). :contentReference[oaicite:5]{index=5}  
  2. Compare Starbucks counts for **top 10 vs bottom 10** stations by total ridership. :contentReference[oaicite:6]{index=6}  
  3. Because the bottom-10 sample had too few Starbucks stores for robust modeling, expand to **top 40 stations** and run:
     - linear regression (ridership ~ Starbucks count) and
     - ANOVA across four ridership-ranked groups (10 stations per group). :contentReference[oaicite:7]{index=7} :contentReference[oaicite:8]{index=8}

## Key Findings
- **Top 10 vs bottom 10 context:** top stations recorded roughly **3.0–5.5M** monthly board+alight events, while bottom stations were around **60K–140K**. :contentReference[oaicite:9]{index=9}  
- **Regression on top 40:** the linear relationship between total ridership and nearby Starbucks count was **not statistically significant** (R-squared ≈ **0.016**, p-value ≈ **0.433**). :contentReference[oaicite:10]{index=10}  
- **Group differences (ANOVA):** when the top 40 stations were grouped by ridership rank, ANOVA indicated **significant differences between groups** (F ≈ **34.22**, p < 0.05). :contentReference[oaicite:11]{index=11}  
  - Post-hoc results highlighted that the **top 1–10 group** differed significantly from the other groups. :contentReference[oaicite:12]{index=12}

## Code
- `R/subway_starbucks_analysis.R`: End-to-end analysis script for aggregations, visualization, regression, and ANOVA based on the prepared station-level Starbucks counts.

## Tools and Libraries
- **R / RStudio (4.3.2)** :contentReference[oaicite:13]{index=13}  
- R packages used in the analysis (as seen in the code/report workflow): `ggplot2`, `dplyr`, `extrafont` (plus base R stats).  
- External preprocessing tools used for spatial preparation: **GeocodingTool** (address → coordinates) and **QGIS** (500m buffer counting). :contentReference[oaicite:14]{index=14}

## Contribution
- Data cleaning/aggregation, exploratory visualizations, statistical testing (linear regression + ANOVA), and interpretation of results.  
- Seoul Open Data Plaza (Oct 2023 subway ridership dataset)
- Starbucks Korea store locator (store addresses)
