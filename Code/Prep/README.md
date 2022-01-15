# Penalties_for_Speeding_in_Quebec

This is the code base to accompany the manuscript 
"Penalties for Speeding and their Effect on Moving Violations: 
Evidence from Quebec Drivers" 
by Chandler, Morin, and Penney in the Canadian Journal of Economics, 2022


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



