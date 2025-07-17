# Social Vulnerabilities

This project visualizes the Social Vulnerability Index (SVI) by census tract in Philadelphia County using a shaded choropleth map. The index highlights areas with differing levels of social vulnerability based on three key indicators.

## Overview

The composite SVI combines three vulnerability variables to measure transportation, education, and housing vulnerabilities:

- **Share of households with no vehicle** (transportation vulnerability)  
- **Share of population aged 25+ without a high school diploma** (education vulnerability)  
- **Share of overcrowded housing units** (housing vulnerability)  

The composite index is calculated as the min-max normalized average of these three variables with equal weighting.

## Interpretation

- **Darker Purple Areas (SVI 0.605 to 1.000)**  
  These tracts show the highest vulnerability, often with concentrations of low-income households, single-parent families, people with disabilities, limited English proficiency, unemployment, and lack of transportation access. Commonly found in North, West, and Southwest Philadelphia.

- **Lighter Purple to White Areas (SVI 0.000 to 0.223)**  
  These tracts are least vulnerable, typically with higher income, better resources, and lower demographic risk. Located mostly in Center City, parts of Northeast Philadelphia, and some Northwest neighborhoods (e.g., Chestnut Hill, Roxborough).

- **Gray Areas ("Missing Data")**  
  Tracts with missing data often correspond to industrial zones, commercial areas, parks, or unpopulated land like the airport or large parks.

## Use Cases

- Public health planning  
- Emergency response targeting  
- Policy and resource allocation  
- Equity assessments  

## Policy Opportunities

- **Transportation Equity:** Expand affordable transit in areas with high rates of households without vehicles.  
- **Integrated Support:** Target multi-issue programs (housing, education, job training) in the most disadvantaged tracts.  
- **Place-Based Investment:** Use the index to prioritize neighborhoods for ARPA or CDBG funding.

## Limitations

- Education variable based on approximated population aged 25 and over.  
- Some indicators are proxies (e.g., overcrowding as a proxy for housing insecurity).  
- ACS data subject to sampling variability at the tract level.
