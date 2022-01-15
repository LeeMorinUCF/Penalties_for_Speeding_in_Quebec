# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022



## Libraries

The above programs use functions defined in the following libraries. 

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


