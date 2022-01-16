# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022



# Contents:

This code base is organized into four sections:
- The ```Prep``` folder contains scripts for 
the operations to transform the raw data from the 
SAAQ database into the main dataset for statistical analysis. 
- The ```Reg``` folder contains the main script for 
the sequence of regression models. 
- The ```Out``` folder contains scripts
to create the figures and tables for the manuscript. 
- The ```Lib``` folder contains scripts to
define functions that are used in the above operations.


## Data Preparation

Scripts in the ```Prep``` folder
perform the following operations:

1. The R script ```SAAQ_tickets.R```
	collects the record of tickets for each year into a 
	single dataset of tickets. 
	 This produces the dataset ```SAAQ_tickets.csv```, 
	  which is the record of events in the regression models. 

1. The R script ```SAAQ_point_balances.R```
  calculates the accumulated demerit point balances
  for each driver and collects counts of drivers at each 
  demerit point level. 
	 This produces the dataset ```SAAQ_point_balances.csv```, 
	  which is the record of counts of drivers at each 
  demerit point level for each day in the sample period.
  This is the record of non-events for the subset of drivers
  *who have ever received tickets*. 

1. The R script ```SAAQ_driver_counts.R```
  collects the public record of the number of drivers in 
  each gender and age group category. 
  It uses linear interpolation to transform 
  the dataset ```SAAQ_drivers_annual.csv```
  into a record of daily counts ```SAAQ_drivers_daily.csv```. 
	 This dataset is the the record of non-events for the subset 
	 of drivers *who have never received tickets*. 

1. The R script ```SAAQ_join.R```
  joins the above datasets into the complete record of 
  events and non-events for all drivers in Quebec. 
	 This produces the dataset ```SAAQ_full.csv```, 
	  which is used in the regression analysis in the next stage.




## Statistical Analysis

The script in the ```Reg``` folder contains 
is the main script for 
the sequence of regression models. 

This script, ```SAAQ_Regs.R```, 
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
the scripts will draw from values in the estimation
results to produce the figures and tables in the manuscript. 

Scripts in the ```Out``` folder
perform the following operations:

1.  The script ```SAAQ_Tables.R``` 
    produces tables of estimates from the results in
    the ```Estn``` folder. 
    These tables are all output to the ```Tables``` folder. 
1.  Run the script ```SAAQ_Estn_Figs.R```, which
    produces the
    figures from the estimation of the event studies and 
    the estimation with granular demerit-point categories.
    These figures are output to the ```Figures``` folder
    and are ultimately named 
    ```Figure3.eps``` and ```Figure4.eps```. 
1.  Run the script ```SAAQ_Count_Figs.R```, which 
    produces the
    figures of the frequency of tickets
    from aggregate data by month. 
    This produces ```num_pts_5_10.eps``` 
    and ```num_pts_7_14.eps```,
    which are both output to the ```Figures``` folder
    and are ultimately named 
    ```Figure1.eps``` and ```Figure2.eps```. 
    It also outputs a dataset ```.csv``` which is used to calculate
    the summary statistics in Table 2. 
    

## Libraries

The above programs use functions defined in the following libraries, which are stored in the ```Lib``` folder. 

1.  The script ```SAAQ_Agg_Reg_Lib.R``` defines functions
    for running regressions with data aggregated by the 
    number of driver days for each combination of the 
    dependent variables. 
    Since weighted regression is used in different contexts, 
    this library makes adjustments, 
    such as for degrees of freedom,
    to make the results equivalent to those which would be obtained
    from the full dataset with one observation per driver per day. 
    Since most drivers do not get tickets on most days,
    this library effectively compresses the dataset
    by a factor of one thousand, 
    from billions of driver days to millions of unique observations.
1.  The script ```SAAQ_Agg_Het_Lib.R``` 
    defines functions for the 
    calculation of heteroskedasticity-corrected standard errors
    with aggregated data.
1.  The script ```SAAQ_Reg_Lib.R``` defines helper functions
    for data formatting and preparation for regressions. 
1.  The script ```SAAQ_MFX_Lib.R``` defines functions
    to calculate marginal effects. 
1.  The script ```SAAQ_Tab_Lib.R``` defines functions
    to generate LaTeX tables from regression results. 

