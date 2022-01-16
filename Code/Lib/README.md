# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022



## Libraries

The scripts in the code base use functions defined in the following libraries. 

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

