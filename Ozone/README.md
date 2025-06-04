# Calculating mortality for Ozone

Calculate mortalities attributed to ozone from cardiovascular (Burnett et al., 2018) and respiratory infections (Malashock et al., 2022) based on epidemiological cohort studies of long-term exposure to ozone.


# Methodology 
## Pre-process data --> get OSMDA8
- Split data into years --> for y in {y1..y2}; do   x=5;   member=$(printf "%03d" $x);   input="/path_to_file";    next_year=$((y + 1));   output_dir="path_out_dir";   output="${output_dir}/name";    mkdir -p "$output_dir";   cdo -selyear,$y "$input" "$output"; done
- Run IDL code to generate ozone_mda8_{year}.nc
- Rename --> for year in {y1..y2}; do; input_file="ozone_mda8_${year}.nc"; output_file="ozone_mda8_${year}_rename.nc"; ncrename -d day,time -v Day,time "$input_file" "$output_file"; done
- Convert to resolution of daily data --> for year in {y1..y2}; do; src="/parth/${year}.nc"; target="ozone_mda8_${year}_rename.nc"; ncks -A -v time "$src" "$target"; echo "✅ Added time variable to $target"; done
- Calculate monthly mean --> for year in {y1..y2}; do; input_file="ozone_mda8_${year}_rename.nc"; output_file="ozone_mda8_${year}_monmean.nc"; cdo monmean "$input_file" "$output_file"; done
- Concatenate --> cdo cat ozone_mda8_*_monmean.nc ozone_mda8_y1-y2_monmean.nc
- Choose djmam of the last year and append it to the end --> for y in {1..num_of_years}; do      cdo seltimestep,$(( (y-1)*12+1 ))/$(( (y-1)*12+5 )) ozone_mda8_y1-y2_monmean.nc ozone_mda8_$(( 20y1+y-1 ))_jfmam.nc;  done
- Copy and make empty monmean_padded that will be filled --> cp  ozone_mda8_y1-y2_monmean.nc ozone_mda8_y1-y2_monmean_padded.nc
- fill monmean_padded --> cdo cat ozone_mda8_y2_jfmam.nc ozone_mda8_y1-y2_monmean_padded.nc
- get 6 month averages --> see Command
- run python code


## Input data
### provided
- ssp2_2020.nc = population dataset from SEDAC --> https://www.earthdata.nasa.gov/data/catalog/sedac-ciesin-sedac-gpwv4-natiden-r11-4.11#:~:text=Description,use%20in%20aggregating%20population%20data
- gpw_v4_national_identifier_grid_rev11_15_min.shp = GPW data used to establish borders
- population_new.csv --> total population for each country, used to calculate the fraction of the population for each age group

### accessible elsewhere
- ARISE data - hourly ozone
- mortality_all_new.csv -> https://drive.google.com/file/d/1zZ8HdAx9vBry7Ej8iLaxI__zxMdSp0W5/view?usp=sharing  --> contains the IFs total mortality for all countries -> RegionID values are countries in order, CohortID are age brackets.

## Processed data
- pop_by_age_frac.nc --> ratio of the population for each age group to the total population for each country
- [P]  2020_demo_frac.nc --> https://drive.google.com/drive/folders/1VWgtstelTGjJi526dN2D02Kt1JrG9_W2?usp=sharing -->gets the total population for each gender and age group for each grid cell
- [AF] --> RR and AF from calculate_RR.ipynb --> 'RR_diff'
- [BMR]  mortality rates processed from year_bmr.ipynb --> https://drive.google.com/drive/folders/1j4S5CcEmTXJV4-Z4rGSygOXikLzkK8E-?usp=sharing

*** AF and BMR are big datasets and can be transferred from GLOBUS if needed

## Scripts

### under processing_data (kind of in order)
- calculate_RR.ipynb
- deaths_by_grid_ozone.ipynb --> calculates death for each grid cell
- deaths_by_country_ozone.ipynb --> sums up death for each grid cell within country border and saves it as deaths per country.


