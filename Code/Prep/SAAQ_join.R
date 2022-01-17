################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Joins data from events and counts of non-events
#
# Lealand Morin, Ph.D.
# Assistant Professor
# Department of Economics
# College of Business Administration
# University of Central Florida
#
# January 7, 2022
#
################################################################################
#
# This script is part of the code base to accompany the manuscript
# "Penalties for Speeding and their Effect on Moving Violations:
# Evidence from Quebec Drivers"
# by Chandler, Morin, and Penney
# in the *Canadian Journal of Economics*, 2022
#
# All scripts are available on the GitHub code repository
# "Penalties_for_Speeding_in_Quebec"
# available at the following link:
# https://github.com/LeeMorinUCF/Penalties_for_Speeding_in_Quebec
# Any updates will be available on the GitHub code repository.
#
################################################################################



################################################################################
# Declaring Packages
################################################################################

# Load package for importing datasets in proprietary formats.
library(foreign)

# Load data table package for quick selection on seq.
library(data.table)


################################################################################
# Set parameters for file IO
################################################################################

# The original data are stored in 'Data/'.
data_dir <- 'Data'

# Set name of file with records of tickets.
tickets_file_name <- 'SAAQ_tickets.csv'

# Set name of file with counts of drivers
# who have received tickets.
pts_bal_file_name <- 'SAAQ_point_balances.csv'

# Set name of file with counts of drivers without tickets.
driver_counts_file_name <- 'SAAQ_drivers_daily.csv'


# Set name of output file for full dataset.
out_file_name <- 'SAAQ_full.csv'




################################################################################
# Set Parameters for variables
################################################################################

# Create rows for list of dates.
day_1 <- as.numeric(as.Date('1998-01-01'))
day_T <- as.numeric(as.Date('2010-12-31'))
date_list <- as.Date(seq(day_1, day_T), origin = as.Date('1970-01-01'))



# Age group categories for defining factors.
age_group_list <- c('0-19',
                    '20-24', '25-34', '35-44', '45-54',
                    '55-64', '65-199')


# Current points group categories for defining factors.
curr_pts_grp_list <- c(seq(0,10), '11-20', '21-30', '31-150')


# Current version has current points groups and indicator
# for pre-policy-change mid-to-high points balance:
agg_var_list <- c('date', 'sex', 'age_grp', 'past_active',
                  'curr_pts_grp', 'points')



################################################################################
# Load Datasets
################################################################################

#-------------------------------------------------------------------------------
# Load Daily Driver Counts
#-------------------------------------------------------------------------------

# Driver population includes all drivers,
# including those with no past tickets or current points.
in_path_file_name <- sprintf('%s/%s', data_dir, driver_counts_file_name)
driver_counts <- fread(in_path_file_name)


# Need to add empty column of curr_pts_grp to
# default population with no tickets.
driver_counts[, curr_pts_grp := 0]

# Also need to add empty column of past_active to
# default population with no tickets.
driver_counts[, past_active := FALSE]


# Define categorical variables as factors.
driver_counts[, sex := factor(sex, levels = c('M', 'F'))]
driver_counts[age_grp %in% c('0-15', '16-19'), age_grp := '0-19']
driver_counts[age_grp %in% c('65-74', '75-84', '85-89', '90-199'), age_grp := '65-199']
driver_counts[, age_grp := factor(age_grp, levels = age_group_list)]
driver_counts <- unique(driver_counts[, num := sum(num), by = c('date', 'age_grp', 'sex')])
driver_counts[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]



#-------------------------------------------------------------------------------
# Load Points Balances
#-------------------------------------------------------------------------------

# Load dataset with counts of drivers
# who have received tickets.
in_path_file_name <- sprintf('%s/%s', data_dir, pts_bal_file_name)
saaq_past_counts <- fread(file = in_path_file_name)


# Add variables to match other datasets.
saaq_past_counts[, points := 0]
saaq_past_counts[, num := N]
saaq_past_counts[, N := NULL]
saaq_past_counts[, seq := 0]


# Define categorical variables as factors.
saaq_past_counts[, sex := factor(sex, levels = c('M', 'F'))]
saaq_past_counts[age_grp %in% c('0-15', '16-19'), age_grp := '0-19']
saaq_past_counts[age_grp %in% c('65-74', '75-84', '85-89', '90-199'), age_grp := '65-199']
saaq_past_counts[, age_grp := factor(age_grp, levels = age_group_list)]
saaq_past_counts <- unique(saaq_past_counts[, num := sum(num),
                                            by = c('date', 'age_grp', 'sex',
                                                   'past_active', 'curr_pts_grp')])
saaq_past_counts[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]





#-------------------------------------------------------------------------------
# Load data from records of tickets.
#-------------------------------------------------------------------------------


# Load data from records of tickets.
in_path_file_name <- sprintf('%s/%s', data_dir, tickets_file_name)
saaq_tickets <- fread(file = in_path_file_name)



# Each unique ticket event happens once.
saaq_tickets[, num := 1]
saaq_tickets[, train_num := 1]
saaq_tickets[, test_num := 1]
saaq_tickets[, estn_num := 1]



# Define categorical variables as factors.
saaq_tickets[, sex := factor(sex, levels = c('M', 'F'))]
saaq_tickets[age_grp %in% c('0-15', '16-19'), age_grp := '0-19']
saaq_tickets[age_grp %in% c('65-74', '75-84', '85-89', '90-199'), age_grp := '65-199']
saaq_tickets[, age_grp := factor(age_grp, levels = age_group_list)]
saaq_tickets[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]


# Aggregate data to reduce number of rows.
saaq_agg <- saaq_tickets[, .N, by = agg_var_list]
colnames(saaq_agg) <- c(agg_var_list, 'num')

# Change type to factor.
saaq_agg[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]




################################################################################
# Join Daily Driver Events with Full Dataset of Non-events
################################################################################


# First put the tables in the same order.
saaq_past_counts <- saaq_past_counts[order(date, sex, age_grp, past_active, curr_pts_grp), ]
driver_counts <- driver_counts[order(date, sex, age_grp, past_active, curr_pts_grp), ]
saaq_agg <- saaq_agg[order(date, sex, age_grp, past_active, curr_pts_grp), ]



# Stack the data frames with properly ordered columns.
saaq_agg_out <- rbind(saaq_agg[, c(agg_var_list, 'num'), with = FALSE],
                      driver_counts[, c(agg_var_list, 'num'), with = FALSE],
                      saaq_past_counts[, c(agg_var_list, 'num'), with = FALSE])


# Reorder for output.
saaq_agg_out <- saaq_agg_out[order(date, sex, age_grp, curr_pts_grp, past_active, points), ]



################################################################################
# Output Daily Driver Counts
################################################################################

out_path_file_name <- sprintf('%s%s', data_dir, out_file_name)
write.csv(x = saaq_agg_out, file = out_path_file_name, row.names = FALSE)



################################################################################
# End
################################################################################
