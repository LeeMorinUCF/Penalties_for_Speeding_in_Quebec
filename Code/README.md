# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022



# Instructions:

The workflow proceeds in three stages: 
one set of instructions outlines the operations 
to transform the raw data in the 
SAAQ database into the dataset that is the input 
for the statistical analysis
in the next stage. 
In the final stage, the estimation results 
are used to create the figures and tables for the manuscript. 


## Data Manipulation

These procedures were performed 
on...


1. Run the R script ```file1.R```
	which...

1. Agg

1. Join




The above operations will produce the a dataset called ```my_data.csv```.

Then the estimation results for each set of models will be collected in the datasets
```file3.csv```... and ```file3.csv```.


## Statistical Analysis

1. Estn


## Manuscript

Once the estimates are obtained, 
the following scripts will draw from values in the estimation
results to produce the figures and tables in the manuscript. 


1. Tables of Estimates

1. Figures from estimation

1. Figures from aggregate data

1. Frequency of tickets




# Libraries

The above programs use functions defined in the following libraries. 

## Regression with Aggregated Data

### ```agg_lm.R```

```agg_lm.R``` is used to estimate regression models with data weighted by frequency. 
Since weighted regression is used in different contexts, 
this library makes adjustments for degrees of freedom and so on
to make the results appear equivalent to those from the full dataset
with one observation per driver per day. 










 