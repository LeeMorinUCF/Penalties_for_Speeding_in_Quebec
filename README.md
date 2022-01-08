# Penalties_for_Speeding_in_Quebec

This repository contains the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022

Any updates will be available on the GitHub code repository 
available at the following link: 
[Penalties_for_Speeding_in_Quebec](https://github.com/LeeMorinUCF/Penalties_for_Speeding_in_Quebec)


## Data Availability

### Traffic Tickets

The primary data source is an anonymized record of traffic tickets
for the SAAQ. 
The data were provided to the authors under an understanding
that the data not be made publicly available. 


### Statistics on Individual Drivers



### Aggregate Counts of Drivers



# Instructions:

The workflow proceeds in two stages: 
one set of instructions outlines the operations 
to transform the raw data in the 
SAAQ database into the dataset that is the input 
for the statistical analysis
in the next stage. 


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

- ```data.table```, version 1.13.0 (using 4 threads), to handle the main data table for analysis in the ```_prelim.R``` and ```_estim.R``` scripts. 

- ```xtable```, version 1.8-4, to generate LaTeX tables for Tables 1, 2, and 3.

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

- SAAQ Administrative Dataset

- Other data, available here:


## Acknowledgements


Jeffrey Penney acknowledges support from SSHRC. 
The authors are especially grateful to the editor and two anonymous referees 
for comments and suggestions that led to substantial improvements from the original manuscript. 
 