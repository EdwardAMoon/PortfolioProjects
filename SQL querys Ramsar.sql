-- inital data was downloaded from earth data on 29/04/2024 (link below) as excel an file and then converted into a CSV file format
-- further data was retreaved from worldometers on 29/04/2024 (link below) and converted into a CSV file format

-- https://search.earthdata.nasa.gov/search/granules?p=C1000000260-SEDAC&pg[0][v]=f&pg[0][gsk]=-start_date&g=G1397550791-SEDAC&gdf=Excel&tl=1714373410.694!3!!&fst0=biosphere&lat=13.21875&zoom=0
-- https://www.worldometers.info/geography/7-continents/

-- Ramsar definition: Ramsar Sites are wetlands of international importance and have been designated under the criteria of the Ramsar Convention on Wetlands for containing representative,
--  rare or unique wetland types or for their importance in conserving biological diversity.

-- This data will be analysised to assess the number of unique sites in each continent and comparing them to there ramsar area coverage

-- first select all was performed to see if data was imported correctly and to gain an idea of what the data looked like
SELECT * FROM ramsar_data.ramsar;

-- select data from a specific site -  lee valley was chosen as the location as I know the area so a quick sense check can be performed 
select *
from ramsar_data.ramsar
where site_name = 'lee valley';

-- select the columns from the database that I am initally intrested in

select country, continent, site_name, LON_DD, LAT_DD, GIS_AREA_KM, ELEV_MIN, ELEV_MAX, ELEV_AVG, RISK1, RISK2, PCTRISK1, PCTRISK2, AREA_0, AREA_2, AREA_0_1KM, AREA_1_1KM, AREA_2_1KM, AREA_0_5KM, AREA_1_5KM, AREA_2_5KM,
PCTRISK_1_1KM, PCTRISK_2_1KM, PCTRISK_1_5KM, PCTRISK_2_5KM, URBAN_EX, MAX_PD, MAX_PD_1KM, MAX_PD_5KM, AVG_PD, AVG_PD_1KM, AVG_PD_5KM, IMR2008, IMR2008_1KM, IMR2008_5KM
from ramsar_data.ramsar;

-- first I wanted count total number of distinct country in each continent

select continent, count(distinct country)
from ramsar_data.ramsar
group by continent
;

-- then I want to count total number of sites in each country

select continent, count(distinct country), count(distinct site_name)
from ramsar_data.ramsar
group by continent
;

-- lets clean up the titles

select continent, count(distinct country) as total_countries, count(distinct site_name) as total_unique_sites
from ramsar_data.ramsar
group by continent
;

-- lets look at the total unique per country in each continent and order by total_countries

select continent, count(distinct country) as total_countries, count(distinct site_name) as total_unique_sites, 
(count(distinct site_name)/ count(distinct country)) as number_unique_sites_per_country
from ramsar_data.ramsar
group by continent
order by number_unique_sites_per_country desc
;

-- anaylsis: europe has the highest number of unique sites per country, Oceania has fewest total_countries but the 3rd highest unique number of sites per country
-- but lets compare land masses of the Ramsar sites to total area of the continent, lets add area to our table

select continent, sum(GIS_AREA_KM) as total_area, count(distinct country) as total_countries, count(distinct site_name) as total_unique_sites, 
(count(distinct site_name)/ count(distinct country)) as number_unique_sites_per_country
from ramsar_data.ramsar
group by continent
order by number_unique_sites_per_country desc
;

-- first lets save the table we have made

create table continent_countries_unique_sites
select continent, sum(GIS_AREA_KM) as total_area, count(distinct country) as total_countries, count(distinct site_name) as total_unique_sites, 
(count(distinct site_name)/ count(distinct country)) as number_unique_sites_per_country
from ramsar_data.ramsar
group by continent
order by number_unique_sites_per_country desc
;

-- check table has been saved

select * 
from continent_countries_unique_sites
;

-- join this table to continent_information table

select 	*
from continent_countries_unique_sites
join ramsar_data.continent_information
on continent_countries_unique_sites.continent = ramsar_data.continent_information.continent
;

-- select the data for total area and area km
select continent_countries_unique_sites.continent, continent_countries_unique_sites.total_area, ramsar_data.continent_information.area_km
from continent_countries_unique_sites
join ramsar_data.continent_information
on continent_countries_unique_sites.continent = ramsar_data.continent_information.continent
;

-- save this table to perform further analysis

create table continent_area_anaylsis
select continent_countries_unique_sites.continent, continent_countries_unique_sites.total_area, ramsar_data.continent_information.area_km
from continent_countries_unique_sites
join ramsar_data.continent_information
on continent_countries_unique_sites.continent = ramsar_data.continent_information.continent
;

-- check table has been saved

select *
from continent_area_anaylsis;

-- rename columns and move order to make the table clearer to understand

alter table continent_area_anaylsis
rename column total_area to total_ramsar_area,
rename column area_km to total_continent_area;

alter table continent_area_anaylsis
modify total_ramsar_area text after continent;

-- check that modifications are correct

select *
from continent_area_anaylsis;

-- divide total ramsar area by total continent area

select continent, total_ramsar_area, total_continent_area, (total_ramsar_area / total_continent_area) * 100 as percentage_ramsar_area_per_continent
from continent_area_anaylsis;

-- percentage_ramsar_area_per_continent giving incorrect value as SQL is reading total_continent_area as 31 (0sf) not 31000000 (2sf), remove the commas from the numbers, and order by percentage

select continent, total_ramsar_area, replace(total_continent_area, ',', '') as total_continent_area, (total_ramsar_area / replace(total_continent_area, ',', '')) * 100 as percentage_ramsar_area_per_continent
from continent_area_anaylsis
order by percentage_ramsar_area_per_continent desc
;

-- save this table

create table percentage_ramsar_area_per_continent_table
select continent, total_ramsar_area, replace(total_continent_area, ',', '') as total_continent_area, (total_ramsar_area / replace(total_continent_area, ',', '')) * 100 as percentage_ramsar_area_per_continent
from continent_area_anaylsis
order by percentage_ramsar_area_per_continent desc
;

-- check table has been saved

select *
from percentage_ramsar_area_per_continent_table;

-- alter table to include units

alter table percentage_ramsar_area_per_continent_table
rename column total_continent_area to total_continent_area_km2,
rename column total_ramsar_area to total_ramsar_area_km2;

-- check table

select *
from percentage_ramsar_area_per_continent_table;

-- join this information back into the contient_countries uniquie sites with key information and change titles to include units

select continent_countries_unique_sites.continent, continent_countries_unique_sites.total_countries, continent_countries_unique_sites.total_unique_sites,
continent_countries_unique_sites.number_unique_sites_per_country, percentage_ramsar_area_per_continent_table.total_ramsar_area_km2, percentage_ramsar_area_per_continent_table.total_continent_area_km2,
percentage_ramsar_area_per_continent_table.percentage_ramsar_area_per_continent
from continent_countries_unique_sites
join percentage_ramsar_area_per_continent_table
on continent_countries_unique_sites.continent = percentage_ramsar_area_per_continent_table.continent
order by percentage_ramsar_area_per_continent desc;

-- analysis: even though Africa has the fewest number of unique sites per country at 2.9 (2sf), they have the largest percentage of area coverage of ramsar area at 1.1% (2sf), compared to europe that has ~6.6
-- times the amount of unique sites per country (highest in this category) but only the 3rd percentage coverage. 

 
