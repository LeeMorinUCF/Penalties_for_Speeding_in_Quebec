
################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Calculates the number of drivers
# in each gender and age group category
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

# Load data table package for quick selection on seq.
# It also includes dependencies for dealing with dates (i.e. lubridate).
library(data.table)


################################################################################
# Set parameters for file IO
################################################################################

# The original data are stored in 'Data/'.
data_dir <- 'Data'

# The file of annual counts of drivers from SAAQ Website.
annual_file_name <- 'SAAQ_drivers_annual.csv'

# Set name of output file.
out_file_name <- 'SAAQ_drivers_daily.csv'


################################################################################
# Load Annual Driver Counts
################################################################################

# Totals are based on the number of driver's licenses outstanding
# for each category as of June 1 of each year.

annual_path_file_name <- sprintf('%s/%s', data_dir, annual_file_name)
annual <- read.csv(file = annual_path_file_name)




################################################################################
# Construct Daily Driver Counts
################################################################################

# Construct a date series from dates in main dataset.


day_1 <- as.numeric(as.Date('1998-01-01'))
day_T <- as.numeric(as.Date('2010-12-31'))

date_list <- as.Date(seq(day_1, day_T), origin = as.Date('1970-01-01'))


# Get dimensions from product of sex and age groups.
age_group_list <- c('0-15', '16-19', '20-24', '25-34', '35-44', '45-54',
                    '55-64', '65-74', '75-84', '85-89', '90-199')

num_rows <- length(date_list)*length(age_group_list)*2



# Initialize a data frame for all the drivers without tickets each day.
driver_counts <- data.frame(date = rep(date_list,
                                       each = length(age_group_list)*2),
                            seq = rep(0, num_rows),
                            age_grp = rep(age_group_list,
                                          length(date_list)*2),
                            sex = rep(rep(c('F', 'M'),
                                          each = length(age_group_list)),
                                      length(date_list)),
                            points = rep(0, num_rows),
                            num = rep(NA, num_rows))


# Populate the number of licensed drivers by category.


# Initialize counts with year 2000 totals for previous years.
# Data are only available for the years 2000 and beyond.
# This doesn't matter for the two-year window around 2008.
this_year <- 2000
next_june_counts <- annual[annual[, 'age_group'] != 'Total' &
                              annual[, 'sex'] != 'T',
                            sprintf('yr_%d', this_year)]
last_june_counts <- next_june_counts

next_june_date <- date_list[year(date_list) == this_year &
                              month(date_list) == 6 &
                              mday(date_list) == 1]
last_june_date <- next_june_date

for (date_num in 1:length(date_list)) {

  this_date <- date_list[date_num]
  this_year <- year(this_date)
  this_month <- month(this_date)
  this_day <- mday(this_date)

  # Print a progress report.
  if (this_day == 1 & this_month == 1) {
    print(sprintf('Now counting drivers in year %d.', this_year))
  }

  # Select rows to be modified.
  row_nums <- seq((date_num - 1)*length(age_group_list)*2 + 1,
                  date_num*length(age_group_list)*2)

  # Constant totals at earliest recorded date.
  if (this_date <= date_list[year(date_list) == 2000 &
                             month(date_list) == 6 &
                             mday(date_list) == 1]) { # Before "2000-06-01"

    driver_counts[row_nums, 'num'] <- next_june_counts

  } else {

    # Calculate weighted average of day.
    next_june_wt <- as.numeric(this_date - last_june_date) /
      as.numeric(next_june_date - last_june_date)

    # Calculate the weighted average of counts.
    this_date_counts <- next_june_wt*next_june_counts +
      (1 - next_june_wt)*last_june_counts

    driver_counts[row_nums, 'num'] <- round(this_date_counts)

  }


  # Every June 1, refresh the totals.
  if (this_month == 6 & this_day == 1 & this_year >= 2000) {

    last_june_counts <- next_june_counts

    next_june_counts <- annual[annual[, 'age_group'] != 'Total' &
                                  annual[, 'sex'] != 'T',
                                sprintf('yr_%d', (this_year + 1))]

    # last_june_date <- this_date
    last_june_date <- next_june_date # More robust to date.
    if (this_year == 2010) {
      # Next june not in date_list.
      next_june_date <- as.Date('2011-06-01')

    } else {
      next_june_date <- date_list[year(date_list) == (this_year + 1) &
                                    month(date_list) == 6 &
                                    mday(date_list) == 1]
    }

  }



}


################################################################################
# Output Daily Driver Counts
################################################################################

out_path_file_name <- sprintf('%s/%s', data_dir, out_file_name)
write.csv(x = driver_counts, file = out_path_file_name, row.names = FALSE)




################################################################################
# End
################################################################################

