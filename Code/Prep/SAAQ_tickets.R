################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Compile table of tickets from annual files.
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

# Set name of output file for aggregated dataset.
out_file_name <- 'saaq_tickets.csv'


################################################################################
# Set parameters for date range
################################################################################


# Set the list of years for inclusion in dataset.
year_list <- seq(1998, 2010) # Entire list.

# Set date of policy change.
april_fools_2008 <- '2008-04-01'





################################################################################
# Assemble and Join Tickets with Licensee Data
################################################################################

# Load Licensee Data
file_name <- sprintf('%s/%s.dta', data_dir, 'seq')
drivers <- read.dta(file_name)


# Initialize dataset with the first year of violations.
yr <- year_list[1]
file_name <- sprintf('%s/%s%d.dta', data_dir, 'cs', yr)
tickets <- read.dta(file_name)

# Reorder by date (one year at a time).
tickets <- tickets[order(tickets$dinf), ]

# Join driver data.
tickets <- cbind(tickets, drivers[tickets[, 'seq'], ])

# Replace sex with factor.
tickets[, 'sex'] <- factor(levels = c('M', 'F'))
tickets[tickets[, 'sxz'] == 1, 'sex'] <- 'M'
tickets[tickets[, 'sxz'] == 2, 'sex'] <- 'F'


# Create new variables and variable names.
saaq <- tickets[, c('seq', 'sex', 'an', 'mois', 'jour', 'dinf', 'pddobt', 'dcon')]
colnames(saaq) <- c('seq', 'sex', 'dob_yr', 'dob_mo', 'dob_day', 'dinf', 'points', 'dcon')


# Join tickets and driver data for remaining years.
for (yr in year_list[2:length(year_list)]) {

  # Print progress report.
  print(sprintf('Now loading data for year %d', yr))

  # Load the next set of violations for this yr.
  file_name <- sprintf('%s/%s%d.dta', data_dir, 'cs', yr)
  tickets <- read.dta(file_name)


  # Reorder by date (one year at a time).
  tickets <- tickets[order(tickets$dinf), ]


  # Join driver data.
  tickets <- cbind(tickets, drivers[tickets[, 'seq'], ])
  # Replace sex with factor.
  tickets[, 'sex'] <- factor(levels = c('M', 'F'))
  tickets[tickets[, 'sxz'] == 1, 'sex'] <- 'M'
  tickets[tickets[, 'sxz'] == 2, 'sex'] <- 'F'


  # Create new variables and variable names.
  saaq_yr <- tickets[, c('seq', 'sex', 'an', 'mois', 'jour', 'dinf', 'pddobt', 'dcon')]
  colnames(saaq_yr) <- c('seq', 'sex', 'dob_yr', 'dob_mo', 'dob_day', 'dinf', 'points', 'dcon')


  # Append to current dataset.
  saaq <- rbind(saaq, saaq_yr)


}


# Clean up intermediate datasets.
saaq_yr <- NULL
tickets <- NULL


################################################################################
# Generate categorical variable for age group
################################################################################

# For the LPM and logistic regressions,
# we defined age in years by date of infraction.
saaq[, 'age'] <- as.integer(substr(saaq[, 'dinf'], 1, 4)) - (1900 + saaq[, 'dob_yr'])


# One person of age zero is actually 100 years old (born in 1899).
saaq[saaq[, 'age'] < 10, 'age'] <- 100


# Sort into age groups to match SAAQ categories.

# Moins de 16 ans
# 16-19 ans
# 20-24 ans
# 25-34 ans
# 35-44 ans
# 45-54 ans
# 55-64 ans
# 65-74 ans
# 75-84 ans
# 85-89 ans
# 90 ans ou plus

age_group_list <- c('0-15', '16-19', '20-24', '25-34', '35-44', '45-54',
                    '55-64', '65-74', '75-84', '85-89', '90-199')
age_cut_points <- c(0, 15.5, 19.5, seq(24.5, 84.5, by = 10), 89.5, 199)
saaq[, 'age_grp'] <- cut(saaq[, 'age'], breaks = age_cut_points,
                         labels = age_group_list)


# Redefine name of date variable to match other datasets.
saaq[, date := dinf]
saaq[, dinf := NULL]



################################################################################
# Output Dataset of Tickets
################################################################################

out_path_file_name <- sprintf('%s/%s', data_dir, out_file_name)
write.csv(x = saaq, file = out_path_file_name, row.names = FALSE)



################################################################################
# End
################################################################################
