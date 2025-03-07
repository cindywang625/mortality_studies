# Calculating mortality using PM2.5

## Input data
- ARISE data - monthly surface PM2.5 
- mortality_all_new.csv -> contains the IFs total mortality for all countries -> RegionID values are countries in order, CohortID are age brackets. Can be acessed here: https://drive.google.com/file/d/1Q9IRljRhL76RkOPDIqcKjkEJ0gifMsze/view?usp=sharing
- population.xlsx = population dataset from SEDAC
- dim_region.csv = for the IFS data, country by their RegionID
- gpw_v4_national_identifier_grid_rev11_15_min.shp = GPW data used to establish borders


## Scripts

### under processing_data
- year_bmr.ipynb --> processes the IFS data so that the deaths/1000 from non communicative disease + respiratory infection of a country is applied evenly to every grid cell for that specific country. This generates BMR for each year.
- calculate_RR.ipynb --> calculates RR following Peng et al., 2021 and using GEMM parameter estimates from Burnett et al., 2018. This is calculated using regridded PM2.5 data for SSP2-4.5 and the ARISE simulations.  The code enables this to be calculated for each ensemble member and the ensemble average.
