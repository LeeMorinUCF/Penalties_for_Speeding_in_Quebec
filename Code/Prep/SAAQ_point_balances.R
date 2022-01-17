################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Calculate number of drivers by age group
# and demerit point balance categories
# on each day in the sample.
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
library(data.table)



################################################################################
# Set parameters for file IO
################################################################################

# Set path to datasets.
data_dir <- 'Data'

# Set name of file with records of tickets.
tickets_in_file_name <- 'saaq_tickets.csv'


# Set name of output file for totals by demerit point category.
balance_out_file_name <- 'saaq_point_balances.csv'



################################################################################
# Set parameters for variable definitions.
################################################################################

#--------------------------------------------------------------------------------
# Set parameters related to dates
#--------------------------------------------------------------------------------

# Set date of policy change.
april_fools_2008 <- '2008-04-01'


# Create rows for list of dates.
day_1 <- as.numeric(as.Date('1998-01-01'))
day_T <- as.numeric(as.Date('2013-01-01')) # Allows for all points to expire.
date_list <- as.Date(seq(day_1, day_T), origin = as.Date('1970-01-01'))


#--------------------------------------------------------------------------------
# Set parameters for age and point categories.
#--------------------------------------------------------------------------------

# Age categories.
age_group_list <- c('0-15', '16-19', '20-24', '25-34', '35-44', '45-54',
                    '55-64', '65-74', '75-84', '85-89', '90-199')
age_cut_points <- c(0, 15.5, 19.5, seq(24.5, 84.5, by = 10), 89.5, 199)


# Point balance categories.
curr_pts_grp_list <- c(seq(0,10), '11-20', '21-30', '31-150')
curr_pts_cut_points <- c(seq(-0.5, 10.5, by = 1), 20.5, 30.5, 150)



# Create a list of active drivers before the policy change.
past_active_pts_list <- c('6', '7', '8', '9', '10')


################################################################################
# Load data from records of tickets.
################################################################################


# Start with the dataset of tickets.
in_path_file_name <- sprintf('%s/%s', data_dir, tickets_in_file_name)
saaq_point_hist <- fread(file = in_path_file_name)



#--------------------------------------------------------------------------------
# Convert categorical variables to factors.
#--------------------------------------------------------------------------------

# Sex is the first priority.
saaq_point_hist[, sex := factor(sex, levels = c('M', 'F'))]

# Now redefine age categories.
saaq_point_hist[, 'age_grp'] <- cut(saaq_point_hist[, age], breaks = age_cut_points,
                            labels = age_group_list)

saaq_point_hist[, age_grp := factor(age_grp, levels = age_group_list)]



################################################################################
# Generate new variables for violation history.
################################################################################


#--------------------------------------------------------------------------------
# Add events for removal of points after expiry two years later.
#--------------------------------------------------------------------------------


# Sort by date and seq.
saaq_point_hist <- saaq_point_hist[order(seq, date), ]

# Create a data table to calculate cumulative points balances.
# Stack two copies of point events.
# One is the original, when points are added.
# The other is a copy, two years later, when points are removed.


# Calculate cumulative points total by driver.
# Copy the dataset to calculate a record of expiries of tickets.
saaq_point_hist_exp <- copy(saaq_point_hist)
# By default, data.table makes a shallow copy,
# which is normally a good idea.
# We need a deep copy, since we truly want a duplicate table
# but want to lead the dates 2 years and reverse the demerit points,
# without changing the original with positive point values.


# Translate into the drops in points two years later.
# Notice that this uses the "date" date variable,
# which is used to keep track of drivers at different point balances.
saaq_point_hist_exp[, date := as.Date(date + 730)]
saaq_point_hist[, date := as.Date(date)] # Change original date to match class.

# Negative points two years later will subtract
# expiring points from two-year balance.
saaq_point_hist_exp[, points := - points]



# Append the original observations, then sort.
saaq_point_hist <- rbind(saaq_point_hist, saaq_point_hist_exp)

saaq_point_hist <- saaq_point_hist[order(seq,
                         date,
                         points)]

# Remove the duplicate, which is no longer needed after joining.
rm(saaq_point_hist_exp)



#--------------------------------------------------------------------------------
# Generate counts of cumulative point balances.
#--------------------------------------------------------------------------------


# Calculate point balances.
saaq_point_hist[, curr_pts := cumsum(points)]


# For recording the transitions between point balance categories,
# current points include today's ticket(s),
# previous points include all point changes up to midnight yesterday night.
saaq_point_hist[, prev_pts := curr_pts - points]


#--------------------------------------------------------------------------------
# Categorization of point total balances
#--------------------------------------------------------------------------------

# Categories:
# 0-10 separately, for granularity.
# 11-20 for next category.
# 21-30 for next category.
# 31+ for last category.

saaq_point_hist[, 'curr_pts_grp'] <- cut(saaq_point_hist[, curr_pts],
                                              breaks = curr_pts_cut_points,
                                              labels = curr_pts_grp_list)

saaq_point_hist[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]



# Allocate previous point balances to the same categories.
saaq_point_hist[, 'prev_pts_grp'] <- cut(saaq_point_hist[, prev_pts],
                                         breaks = curr_pts_cut_points,
                                         labels = curr_pts_grp_list)

saaq_point_hist[, prev_pts_grp := factor(prev_pts_grp, levels = curr_pts_grp_list)]


#--------------------------------------------------------------------------------
# Create an indicator for highest point category before policy change.
# Use it to determine if the bad guys change their habits.
#--------------------------------------------------------------------------------

saaq_point_hist[, pre_policy := date < as.Date(april_fools_2008)]
table(saaq_point_hist[, pre_policy], useNA = 'ifany')
# Pre-policy period is much longer with an asymmetric window.

# Create a list of active drivers before the policy change.
past_active_list <- unique(saaq_point_hist[prev_pts_grp %in% past_active_pts_list &
                                             pre_policy == TRUE, seq])
# Note that this variable is not used for prediction.
# It is used for classifying a subsample.

# Allocate drivers to the list of those with an active past.
saaq_point_hist[, past_active := seq %in% past_active_list]


#--------------------------------------------------------------------------------
# Generate counts of cumulative two-year point totals.
#--------------------------------------------------------------------------------

# Requires only certain variables to proceed.
saaq_point_hist <- saaq_point_hist[, c('seq', 'sex', 'age_grp', 'past_active',
                                       'date', 'date',
                                       'points', 'curr_pts', 'prev_pts',
                                       'curr_pts_grp', 'prev_pts_grp')]




#--------------------------------------------------------------------------------
# Analysis of two-year point total balances
#--------------------------------------------------------------------------------


# List the possible values.
past_pts_list <- unique(saaq_point_hist[, curr_pts])
past_pts_list <- past_pts_list[order(past_pts_list)]
# Every number up to 110, then more sparse up to 150.

# Inspect the distribution to choose categories.
quantile(saaq_point_hist[, curr_pts], probs = seq(0, 1, by = 0.1))
# 0%  10%  20%  30%  40%  50%  60%  70%  80%  90% 100%
# 0    0    0    1    2    3    3    4    6    8  150

quantile(saaq_point_hist[, curr_pts], probs = seq(0.9, 1, by = 0.01))
# 90%  91%  92%  93%  94%  95%  96%  97%  98%  99% 100%
# 8    9    9   10   10   11   12   13   15   18  150

quantile(saaq_point_hist[, curr_pts], probs = seq(0.99, 1, by = 0.001))
# 99% 99.1% 99.2% 99.3% 99.4% 99.5% 99.6% 99.7% 99.8% 99.9%  100%
# 18    18    19    20    21    22    23    25    27    32   150


# 0-10 gets up to the 95 percentile.
# 15 gets to 98th percentile.
# 20 gets inside 99th percentile.
# 30 gets to 99.9%.

# This analysis inspired the definition of the balance categories.


#--------------------------------------------------------------------------------
# Categorization of balances by full-day activity
# since some drivers have multiple tickets per day.
#--------------------------------------------------------------------------------


# Now this dataset can be used to calculate counts by category.
# But one more adjustment is required: some drivers have several tickets in one day.
# These drivers are counted several times over.
# Need to select current and previous category for each driver-day.

# Add indicator for event.
saaq_point_hist[, 'event_id'] <- seq(nrow(saaq_point_hist))

# Each driver-day, record the first id and last id.
saaq_point_hist[, first_id := min(event_id), by = list(seq, date)]
saaq_point_hist[, last_id := max(event_id), by = list(seq, date)]

# Create true full-day transition from first balance
# category to last balance category.
# Values at the end of the day or the beginning of the day.
saaq_point_hist[event_id == last_id, curr_pts_EOD := curr_pts]
saaq_point_hist[event_id == first_id, prev_pts_BOD := prev_pts]

# Assign full-day balance categories.
saaq_point_hist[, curr_pts_EOD := mean(curr_pts_EOD, na.rm = TRUE), by = list(seq, date)]
saaq_point_hist[, prev_pts_BOD := mean(prev_pts_BOD, na.rm = TRUE), by = list(seq, date)]


# Allocate them to balance categories.
saaq_point_hist[, 'curr_pts_grp_EOD'] <- cut(saaq_point_hist[, curr_pts_EOD],
                                         breaks = curr_pts_cut_points,
                                         labels = curr_pts_grp_list)

saaq_point_hist[, curr_pts_grp_EOD := factor(curr_pts_grp_EOD, levels = curr_pts_grp_list)]



# Allocate previous point balances to the same categories.
saaq_point_hist[, 'prev_pts_grp_BOD'] <- cut(saaq_point_hist[, prev_pts_BOD],
                                         breaks = curr_pts_cut_points,
                                         labels = curr_pts_grp_list)

saaq_point_hist[, prev_pts_grp_BOD := factor(prev_pts_grp_BOD, levels = curr_pts_grp_list)]


table(saaq_point_hist[, curr_pts_grp_EOD], useNA = 'ifany')
table(saaq_point_hist[, prev_pts_grp_BOD], useNA = 'ifany')
# These do differ because the end-of-ticket values do not necessarily appear at the
# beginning of another day.



#--------------------------------------------------------------------------------
# Calculate counts of drivers by category.
#--------------------------------------------------------------------------------


# Create an aggregated version to streamline counting.
# Eliminate all but the first record per driver day (with full-day transitions).
saaq_pts_chgs <- saaq_point_hist[event_id == first_id, .N,
                               by = c('date', 'sex', 'age_grp', 'past_active', # Fixed categories.
                                      'prev_pts_grp_BOD', 'curr_pts_grp_EOD')]   # Transition category.


# Replace the column name as if drivers only got one ticket per day.
colnames(saaq_pts_chgs) <- c('date', 'sex', 'age_grp', 'past_active',
                             'prev_pts_grp', 'curr_pts_grp', 'N')

# Points groups need to be converted to factors.
# And levels must be defined in order, so that counts of transitions match in rows.
saaq_pts_chgs[, prev_pts_grp := factor(prev_pts_grp, levels = curr_pts_grp_list)]
saaq_pts_chgs[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]


# Sort.
saaq_pts_chgs <- saaq_pts_chgs[order(date, sex, age_grp, past_active,
                                     prev_pts_grp, curr_pts_grp)]


#--------------------------------------------------------------------------------
# Daily categorization of point total balances across age and sex categories
#--------------------------------------------------------------------------------

# This creates a time series of counts by point-age-sex-past_active categories.

# Start with a dataset of all possible permutations of the categories, each day.
# Initialize with zeros for the combinations that didn't happen.
saaq_past_counts <- data.table(expand.grid(date = date_list,
                                           sex = c('M', 'F'),
                                           age_grp = age_group_list,
                                           past_active = c(FALSE, TRUE),
                                           curr_pts_grp = curr_pts_grp_list,
                                           N = 0L))
saaq_past_counts <- saaq_past_counts[order(date, sex, age_grp, past_active, curr_pts_grp)]


# Create a single-day list for padding.
saaq_zero_curr <- data.table(expand.grid(sex = c('M', 'F'),
                                         age_grp = age_group_list,
                                         past_active = c(FALSE, TRUE),
                                         curr_pts_grp = curr_pts_grp_list,
                                         N = 0L))
saaq_zero_curr <- saaq_zero_curr[order(sex, age_grp, past_active, curr_pts_grp)]
# Create another for padding deductions from previous counts.
saaq_zero_prev <- saaq_zero_curr
colnames(saaq_zero_prev)[4] <- 'prev_pts_grp'


# Set date range.
beg_date <- date_list[1]
beg_date_num <- which(date_list == beg_date)
end_date <- '2013-01-01' # Allows all points to expire.
end_date_num <- which(date_list == end_date)
# Note that this leaves many dates at zero, outside of the range.
date_num_list <- beg_date_num:end_date_num


# Initialize counts at zero point group.
# Initialize counts with number of drivers in each category combination.
date_curr <- date_list[beg_date_num]
add_counts <- unique(saaq_point_hist[event_id == first_id,
                                     c('seq', 'sex', 'age_grp', 'past_active')])
add_counts <- unique(add_counts[, .N, by = c('sex', 'age_grp', 'past_active')])
add_counts[, curr_pts_grp := 0]
# Change column order to match.
add_counts <- add_counts[, c('sex', 'age_grp', 'past_active',
                                'curr_pts_grp', 'N')]
# Pad list of changes with zero entries.
add_counts <- rbind(add_counts, saaq_zero_curr)
# Aggregate and sort.
add_counts <- add_counts[, N := sum(N),
                         by = c('sex', 'age_grp', 'past_active',
                                'curr_pts_grp')]
add_counts <- unique(add_counts)
add_counts[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]
add_counts <- add_counts[order(sex, age_grp, past_active, curr_pts_grp)]
# Add to initial balances in curr_pts_grp zero.
saaq_past_counts[date == date_curr, 'N'] <- add_counts[, 'N']


# Loop on dates and calculate the totals.
for (date_num in date_num_list) {

  # Select row for current date.
  date_curr <- date_list[date_num]
  if (date_num == date_num_list[1]) {
    date_prev <- NULL
  } else {
    date_prev <- date_list[date_num - 1]
  }

  # Print progress report.
  if (wday(date_curr) == 1) {
    print(sprintf('Now tabulating for date %s.', as.character(date_curr)))
  }

  # Pull all point changes on this date.
  point_changes <- saaq_pts_chgs[date == date_curr, ]
  # Only need drivers who actually changed categories.
  # Some stay in 11-20, 21-30, or 31-150.
  point_changes <- point_changes[curr_pts_grp != prev_pts_grp]

  # Deduct from count of drivers in the previous categories.

  deduct_counts <- point_changes[, c('sex', 'age_grp', 'past_active',
                                     'prev_pts_grp', 'N')]

  # Pad list of changes with zero entries.
  deduct_counts <- rbind(deduct_counts, saaq_zero_prev)

  # Aggregate and sort.
  deduct_counts <- deduct_counts[, N := sum(N),
                                 by = c('sex', 'age_grp', 'past_active',
                                        'prev_pts_grp')]
  deduct_counts <- unique(deduct_counts)
  deduct_counts[, prev_pts_grp := factor(prev_pts_grp, levels = curr_pts_grp_list)]
  deduct_counts <- deduct_counts[order(sex, age_grp, past_active, prev_pts_grp)]

  if (date_num == date_num_list[1]) {
    saaq_past_counts[date == date_curr, 'N'] <-
      saaq_past_counts[date == date_curr, 'N'] -
      deduct_counts[, 'N']
  } else {
    saaq_past_counts[date == date_curr, 'N'] <-
      saaq_past_counts[date == date_prev, 'N'] -
      deduct_counts[, 'N']
  }


  # Add to count of drivers in the current categories.
  add_counts <- point_changes[, c('sex', 'age_grp', 'past_active',
                                     'curr_pts_grp', 'N')]

  # Pad list of changes with zero entries.
  add_counts <- rbind(add_counts, saaq_zero_curr)

  # Aggregate and sort.
  add_counts <- add_counts[, N := sum(N),
                                 by = c('sex', 'age_grp', 'past_active',
                                        'curr_pts_grp')]
  add_counts <- unique(add_counts)
  add_counts[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]
  add_counts <- add_counts[order(sex, age_grp, past_active, curr_pts_grp)]


  saaq_past_counts[date == date_curr, 'N'] <-
    saaq_past_counts[date == date_curr, 'N'] +
    add_counts[, 'N']


}




################################################################################
# Output Counts of Drivers by Point Balances
################################################################################

out_path_file_name <- sprintf('%s/%s', data_dir, balance_out_file_name)
write.csv(x = saaq_past_counts, file = out_path_file_name, row.names = FALSE)


################################################################################
# End
################################################################################
