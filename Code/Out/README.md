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
1.  The script ```SAAQ_estn_figs.R``` produces the
    figures from the estimation of the event studies and 
    the estimation with granular demerit-point categories.
    These figures are output to the ```Figures``` folder, 
    which are ultimately named 
    ```Figure3.eps``` and ```Figure4.eps```. 
1.  The script ```SAAQ_count_figs.R``` produces the
    figures of the frequency of tickets
    from aggregate data by month. 
    This produces ```Figure1.eps``` and ```Figure2.eps```,
    which are both output to the ```Figures``` folder, 
    

