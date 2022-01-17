# Data for Penalties_for_Speeding_in_Quebec

This is part of the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022


## Data Availability

All data were obtained from the 
Société de l'assurance automobile du Québec, 
the driver's licence and insurance agency 
for the province of Québec. 

These primary datasets must be placed in the ```Data```
folder before running the scripts.


### Traffic Tickets

The primary data source is an anonymized record of traffic tickets from the SAAQ for each year in the sample. 
The data were provided to the authors under an understanding
that the data not be made publicly available. 

The datasets are named in the format ```csYYYY.dta```, 
with ```YYYY```` indicating the year in which drivers received tickets. 

The datasets contain the following variables.

- ```pddobt``` is the number of points.
- ```dinf``` is the date of infraction in ```YYYY-MM-DD``` format.
- ```dcon``` is the date of conviction in ```YYYY-MM-DD``` format.
- ```seq``` is a sequence of unique identification numbers for the drivers.


### Statistics for Individual Drivers

The above record of tickets are marked with
driver-specific identifier, which serves as a key for 
a dataset of driver-specific characteristics.
This dataset contains the driver identification number, 
along with the gender and date of birth of each driver.
This information is not publicly available
to protect the privacy of the drivers.


The file ```seq.dta``` contains licensee data 
for 3,911,743 individuals who received tickets
and includes the following variables.

- ```seq``` is a sequence of unique identification numbers for the drivers.
- ```sxz``` is either 1.0 or 2.0, an indicator for male or female, respectively.
- ```an``` is an integer for the year of birth of each driver.
- ```mois``` is an integer for the month of birth of each driver.
- ```jour``` is an integer for the calendar day of birth of each driver.


### Aggregate Counts of Drivers

Counts of individual drivers were obtained 
from the website of the Banque de données des statistiques officielles sur le Québec, available 
[here](https://bdso.gouv.qc.ca/pls/ken/ken213_afich_tabl.page_tabl?p_iden_tran=REPERRUNYAW46-44034787356%7C@%7Dzb&p_lang=2&p_m_o=SAAQ&p_id_ss_domn=718&p_id_raprt=3370#tri_pivot_1=500400000). 

The statistics were compiled into a single spreadsheet
```SAAQ_drivers_annual.csv```, 
which is available in the ```Data``` folder
and contains the following variables. 

- ```age_group``` is an age range in years.
- ```sex``` is an indicator for the gender of drivers, 
  either ```"M"``` or ```"F"```.
- ```yrYYYY``` denotes that the column records the number of drivers in each year ```YYYY``` on June 1 of each year.
