# Penalties_for_Speeding_in_Quebec

This repository contains the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022

All scripts are available on the GitHub code repository 
available at the following link: 
[Penalties_for_Speeding_in_Quebec](https://github.com/LeeMorinUCF/Penalties_for_Speeding_in_Quebec)
Any updates will be available on the GitHub code repository.


## Data Availability

### Traffic Tickets

The primary data source is an anonymized record of traffic tickets from the SAAQ for each year in the sample. 
The data were provided to the authors under an understanding
that the data not be made publicly available. 


### Statistics on Individual Drivers

The above record of tickets are market with
driver-specific identifier, which serves as a key for 
a dataset of driver-specific characteristics.
This dataset contains the driver identification number, 
along with the gender and date of birth of each driver. 

### Aggregate Counts of Drivers

Counts of individual drivers were obtained 
from the website of the Banque de données des statistiques officielles sur le Québec, available 
[here](https://bdso.gouv.qc.ca/pls/ken/ken213_afich_tabl.page_tabl?p_iden_tran=REPERRUNYAW46-44034787356%7C@%7Dzb&p_lang=2&p_m_o=SAAQ&p_id_ss_domn=718&p_id_raprt=3370#tri_pivot_1=500400000). 

The statistics were compiled into a single spreadsheet
```SAAQ_drivers_annual.csv```, 
which is available in the ```Data``` folder. 


# Instructions:

All regression results, tables and figures in the manuscript
can be obtained by running the shell script ```SAAQ_CJE.sh```. 
The workflow proceeds in three stages: 
one set of instructions outlines the operations 
to transform the raw data in the 
SAAQ database into the dataset that is the input 
for the statistical analysis
in the next stage. 
In the final stage, the estimation results 
are used to create the figures and tables for the manuscript. 


## Data Preparation

Run the scripts in the ```Code/Prep``` folder, which 
perform the following operations:

1. Run the R script ```SAAQ_tickets.R```, which
	collects the record of tickets for each year into a 
	single dataset of tickets. 
	 This produces the dataset ```SAAQ_tickets.csv```, 
	  which is the record of events in the regression models. 

1. Run the R script ```SAAQ_point_balances.R```, which
  calculates the accumulated demerit point balances
  for each driver and collects counts of drivers at each 
  demerit point level. 
	 This produces the dataset ```SAAQ_point_balances.csv```, 
	  which is the record of counts of drivers at each 
  demerit point level for each day in the sample period.
  This is the record of non-events for the subset of drivers
  *who have ever received tickets*. 

1. Run the R script ```SAAQ_driver_counts.R```, which
  collects the public record of the number of drivers in 
  each gender and age group category. 
  It uses linear interpolation to transform 
  the dataset ```SAAQ_drivers_annual.csv```
  into a record of daily counts ```SAAQ_drivers_daily.csv```. 
	 This dataset is the the record of non-events for the subset 
	 of drivers *who have never received tickets*. 

1. Run the R script ```SAAQ_join.R```, which
  joins the above datasets into the complete record of 
  events and non-events for all drivers in Quebec. 
	 This produces the dataset ```SAAQ_full.csv```, 
	  which is used in the regression analysis in the next stage.



## Statistical Analysis

The script in the ```Code/Reg``` folder contains 
is the main script for 
the sequence of regression models. 

Run this script, ```SAAQ_Regs.R```, which
estimates all models in the paper in a series of loops. 
It perform the following operations:

1.  Read in the main dataset ```SAAQ_full.csv```.
1.  Create and modify categorical variables.
1.  Define the policy indicator
    to represent the change in legislation on April 1, 2008
    and the sample period 
    over the four-year period centered on this date. 
1.  Defines the sequence of sets of models to be estimated, 
    including the full sample, high-point drivers, 
    an event study and an analysis by demerit point balances,
    as well as placebo regressions. 

For each model, the script performs the following operations: 

1.  Define the target variable. 
1.  Set the relevant sample period, 
    which differs for the placebo regression.
1.  Set the sample selection, 
    to select either the full sample or high-point drivers. 
1.  Estimate the linear and logistic regression model. 
1.  Calculate HCCME standard errors 
    for the linear probability model. 
1.  Calculate the marginal effects for the relevant coefficients. 
1.  Save the estimation results in files stored in the
    ```Estn``` folder to produce tables and figures 
    for the manuscript. 



## Manuscript

Once the estimates are obtained, 
run a series of scripts 
to draw from values in the estimation
results to produce the figures and tables in the manuscript. 

Run the scripts in the ```Code/Out``` folder
perform the following operations:

1.  Run the script ```SAAQ_Tables.R```, which
    produces tables of estimates from the results in
    the ```Estn``` folder. 
    These tables are all output to the ```Tables``` folder. 
1.  Run the script ```SAAQ_estn_figs.R```, which
    produces the
    figures from the estimation of the event studies and 
    the estimation with granular demerit-point categories.
    These figures are output to the ```Figures``` folder, 
    which are ultimately named 
    ```Figure3.eps``` and ```Figure4.eps```. 
1.  Run the script ```SAAQ_count_figs.R```, which 
    produces the
    figures of the frequency of tickets
    from aggregate data by month. 
    This produces ```Figure1.eps``` and ```Figure2.eps```,
    which are both output to the ```Figures``` folder, 
    

## Libraries

The above programs use functions defined in the following libraries, which are stored in the ```Code/Lib``` folder. 

1.  The script ```SAAQ_Reg_Lib.R``` defines functions
    for running regressions with data aggregated by the 
    number of driver days for each combination of the 
    dependent variables. 
    Since weighted regression is used in different contexts, 
    this library makes adjustments for degrees of freedom 
    and so on
    to make the results appear equivalent to those 
    from the full dataset with one observation per driver per day. 
1.  The script ```SAAQ_Reg_Lib.R``` also defines functions
    defines functions for the 
    calculation of heteroskedasticity-corrected standard errors.
1.  The script ```SAAQ_MFX_Lib.R``` defines functions
    to calculate marginal effects. 
1.  The script ```SAAQ_Tab_Lib.R``` defines functions
    to generate LaTeX tables from regression results. 


## Computing Requirements

All the tables
and figures in the paper can be performed on a single microcomputer, 
such as a laptop computer.
The particular model of computer 
on which the statistical analysis was run
is a 
Dell Precision 3520,
running a 64-bit Windows 10 operating system, 
with a 4-core x64-based processor,
model Intel(R) Core(TM) i7-7820HQ CPU, 
running at 2.90GHz, 
with 16 GB of RAM.


## Software

The statistical analysis was conducted in R, version 4.0.2,
which was released on June 22, 2020, 
on a 64-bit Windows platform x86_64-w64-mingw32/x64. 

The attached packages include the following:

- ```foreign``` version 0.8-81, to open datasets in ```.dta``` format. 

- ```data.table```, version 1.13.0 (using 4 threads), to handle the main data table for data preparation and analysis 
in the scripts in the ```Code/Prep``` and ```Code/Reg``` folders. 

- ```xtable```, version 1.8-4, to generate LaTeX tables for Tables 3, 4, 5, 6, and 7.

Upon attachment of the above packages, 
the following packages were loaded via a namespace, but not attached,
with the following versions:

- ```Rcpp``` version 1.0.5
- ```RcppParallel``` version 5.0.2
- ```parallel``` version 4.0.2
- ```compiler``` version 4.0.2
- ```pkgconfig``` version 2.0.3
- ```haven``` version 2.3.1
- ```stringr``` version 1.4.0
- ```withr``` version 2.4.2       
- ```foreign``` version 0.8-81    
- ```tidyr``` version 1.1.3       
- ```scales``` version 1.1.1      
- ```stringi``` version 1.5.3    

## References

- Société de l'assurance automobile du Québec, 
  Administrative Dataset: Traffic Violations 2004-2010.

- Société de l'assurance automobile du Québec, 
  Administrative Dataset: Vital Statistics 
  for Drivers with Traffic Violations 2004-2010.

- Banque de données des statistiques officielles sur le Québec
[Nombre de titulaires d'un permis de conduire ou d'un permis probatoire selon le sexe et l'âge, Québec et régions administratives](https://bdso.gouv.qc.ca/pls/ken/ken213_afich_tabl.page_tabl?p_iden_tran=REPERRUNYAW46-44034787356%7C@%7Dzb&p_lang=2&p_m_o=SAAQ&p_id_ss_domn=718&p_id_raprt=3370#tri_pivot_1=500400000)


## Acknowledgements

The authors would like to thank Francois Tardif for his help with the data in the early
stages of this project, as well as Catherine Maclean for helpful suggestions and
valuable comments.
Jeffrey Penney acknowledges support from SSHRC. 
The authors are especially grateful to the editor and two anonymous referees 
for comments and suggestions that led to substantial improvements from the original manuscript. 
 
