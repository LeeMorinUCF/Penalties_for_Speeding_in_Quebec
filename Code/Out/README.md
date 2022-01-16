# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022


## Manuscript

These scripts will draw from values in the estimation
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
    

