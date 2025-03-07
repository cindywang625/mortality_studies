# Calculating mortality using PM2.5

## Input data
### provided
- ssp2_2020.nc = population dataset from SEDAC --> https://www.earthdata.nasa.gov/data/catalog/sedac-ciesin-sedac-gpwv4-natiden-r11-4.11#:~:text=Description,use%20in%20aggregating%20population%20data
- gpw_v4_national_identifier_grid_rev11_15_min.shp = GPW data used to establish borders

### accessible elsewhere
- ARISE data - monthly surface PM2.5 
- mortality_all_new.csv -> https://drive.google.com/file/d/1zZ8HdAx9vBry7Ej8iLaxI__zxMdSp0W5/view?usp=sharing  --> contains the IFs total mortality for all countries -> RegionID values are countries in order, CohortID are age brackets. 


## Scripts

### under processing_data
- year_bmr.ipynb --> processes the IFS data so that the deaths/1000 from non communicative disease + respiratory infection of a country is applied evenly to every grid cell for that specific country. This generates BMR for each year.
- calculate_RR.ipynb --> calculates RR following Peng et al., 2021 and using GEMM parameter estimates from Burnett et al., 2018. This is calculated using regridded PM2.5 data for SSP2-4.5 and the ARISE simulations.  The code enables this to be calculated for each ensemble member and the ensemble average.
