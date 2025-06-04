# Calculating mortality for Ozone

Calculate mortalities attributed to ozone from cardiovascular (Burnett et al., 2018) and respiratory infections (Malashock et al., 2022) based on epidemiological cohort studies of long-term exposure to ozone.


# Methodology 

## Input data
### provided
- ssp2_2020.nc = population dataset from SEDAC --> https://www.earthdata.nasa.gov/data/catalog/sedac-ciesin-sedac-gpwv4-natiden-r11-4.11#:~:text=Description,use%20in%20aggregating%20population%20data
- gpw_v4_national_identifier_grid_rev11_15_min.shp = GPW data used to establish borders
- population_new.csv --> total population for each country, used to calculate the fraction of the population for each age group

### accessible elsewhere
- ARISE data - monthly surface PM2.5 
- mortality_all_new.csv -> https://drive.google.com/file/d/1zZ8HdAx9vBry7Ej8iLaxI__zxMdSp0W5/view?usp=sharing  --> contains the IFs total mortality for all countries -> RegionID values are countries in order, CohortID are age brackets.

## Processed data
- pop_by_age_frac.nc --> ratio of the population for each age group to the total population for each country
- [P]  2020_demo_frac.nc --> https://drive.google.com/drive/folders/1VWgtstelTGjJi526dN2D02Kt1JrG9_W2?usp=sharing -->gets the total population for each gender and age group for each grid cell
- [AF] --> RR and AF from calculate_RR.ipynb --> 'RR_diff'
- [BMR]  mortality rates processed from year_bmr.ipynb --> https://drive.google.com/drive/folders/1j4S5CcEmTXJV4-Z4rGSygOXikLzkK8E-?usp=sharing

*** AF and BMR are big datasets and can be transferred from GLOBUS if needed

## Scripts

### under processing_data (kind of in order)
- year_bmr.ipynb --> processes the IFS data so that the deaths/1000 from non communicative disease + respiratory infection of a country is applied evenly to every grid cell for that specific country. This generates BMR for each year.
- calculate_RR.ipynb --> calculates RR following Peng et al., 2021 and using GEMM parameter estimates from Burnett et al., 2018. This is calculated using regridded PM2.5 data for SSP2-4.5 and the ARISE simulations.  The code enables this to be calculated for each ensemble member and the ensemble average.
- check_demographic.ipynb --> calculates the ratio of the population for each age group to the total population for each country --> generates male_pop_by_age_frac and female_pop_by_age_frac
- get_tot_pop.ipynb --> uses pop_by_age_frac and SEDAC 2020 population to get the total population for each age group and gender for every grid cell --> generates male_2020_demo_frac and female_2020_demo_frac
- deaths_by_grid.ipynb --> calculates death for each grid cell
- deaths_by_country.ipynb --> sums up death for each grid cell within country border and saves it as deaths per country.


