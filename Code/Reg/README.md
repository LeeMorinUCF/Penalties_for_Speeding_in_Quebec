# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022


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

