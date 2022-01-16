################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Creating Figures from the Record of Tickets
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

# Load data table package for quick selection on seq
# (and functions for dates).
library(data.table)


################################################################################
# Set parameters for file IO
################################################################################

# Set directory for dataset.
data_dir <- 'Data'


# Set path for output of figures.
fig_dir <- 'Figures'

# Set path for output of tables.
tab_dir <- 'Tables'


################################################################################
# Load Annual Driver Counts
################################################################################


in_file_name <- 'saaq_full.csv'
in_path_file_name <- sprintf('%s%s', data_dir, in_file_name)
saaq_agg <- fread(file = in_path_file_name)


# Change date into date format.
saaq_agg[, 'date'] <- as.Date(saaq_agg[, 'date'])


################################################################################
# Analyse Groups of Related Offences
################################################################################


# Set parameters for tables.
april_fools_2008 <- '2008-04-01'

# Generae an indicator for the policy change.
saaq_agg[, 'policy'] <- saaq_agg[, 'dinf'] > april_fools_2008


# Generate indicators for months.
saaq_agg[, 'month_num'] <- month(saaq_agg[, 'dinf'])
table(saaq_agg[, 'month_num'], useNA = 'ifany')



##################################################
# Sample Selection
##################################################

# Select symmetric window around the policy change.
saaq_agg[, 'window'] <- saaq_agg[, 'dinf'] >= '2006-04-01' &
  saaq_agg[, 'dinf'] <= '2010-03-31'

summary(saaq_agg[saaq_agg[, 'window'], 'dinf'])



##################################################
# Agregate data for plots.
##################################################


#--------------------------------------------------------------------------------
# Agregate data by month.
#--------------------------------------------------------------------------------

agg_var_list <- c('month', 'sex', 'age_grp', 'points')

# Need to create date variable by month.
saaq_agg[, 'month'] <- sprintf('%d-%02d',
                               year(saaq_agg[, 'dinf']),
                               month(saaq_agg[, 'dinf']))


saaq_monthly <- aggregate(num ~ month + sex + age_grp + points,
                          data = saaq_agg[saaq_agg[, 'window'], c(agg_var_list, 'num')],
                          FUN = sum)

saaq_monthly <- saaq_monthly[order(saaq_monthly$month,
                                   saaq_monthly$sex, saaq_monthly$age_grp,
                                   saaq_monthly$points), ]



#--------------------------------------------------------------------------------
# Agregate data by month.
#--------------------------------------------------------------------------------

saaq_monthly_freq <- aggregate(num ~ month + points,
                              data = saaq_monthly[, c('month', 'points', 'num')],
                              FUN = sum)

saaq_monthly_freq <- saaq_monthly_freq[order(saaq_monthly_freq$month,
                                           saaq_monthly_freq$points), ]




# Form a data table with columns for point balances.
table(saaq_monthly_freq[, 'points'], useNA = 'ifany')

month_list <- unique(saaq_monthly_freq[, 'month'])
month_list <- month_list[order(month_list)]
point_list <- unique(saaq_monthly_freq[, 'points'])
point_list <- point_list[order(point_list)]
col_names <- sprintf('pts_%d', point_list)

# Initialize table for figures.
saaq_monthly_freq_tab <- data.frame(month = month_list)
saaq_monthly_freq_tab[, col_names] <- 0

for (month in month_list) {
  for (points in point_list) {

    col_name <- sprintf('pts_%d', points)

    # Count tickets by month.
    num <- saaq_monthly_freq[saaq_monthly_freq[, 'month'] == month &
                              saaq_monthly_freq[, 'points'] == points, 'num']
    if (length(num) > 0) {
      saaq_monthly_freq_tab[saaq_monthly_freq_tab[, 'month'] == month,
                           col_name] <- num
    }



  }
}




# Add totals by calendar month.
saaq_monthly_freq[, 'month_num'] <- as.numeric(substr(saaq_monthly_freq[, 'month'], 6,7))
table(saaq_monthly_freq[, 'month_num'], useNA = 'ifany')
saaq_monthly_freq_tab[, 'month_num'] <- as.numeric(substr(saaq_monthly_freq_tab[, 'month'], 6,7))
table(saaq_monthly_freq_tab[, 'month_num'], useNA = 'ifany')


saaq_monthly_freq_tab[, 'month_avg_num'] <- NA
saaq_monthly_freq_tab[, 'month_avg_5_10'] <- NA
saaq_monthly_freq_tab[, 'month_avg_7_14'] <- NA
for (month_num in 1:12) {

  #--------------------------------------------------
  # All violations
  #--------------------------------------------------

  # Calculate monthly seasonal totals from 4 years.
  num <- sum(saaq_monthly_freq[
    saaq_monthly_freq[, 'month_num'] == month_num &
      saaq_monthly_freq[, 'points'] > 0, 'num'])/4

  saaq_monthly_freq_tab[
    saaq_monthly_freq_tab[, 'month_num'] == month_num, 'month_avg_num'] <- num


  #--------------------------------------------------
  # 5- and 10-point violations
  #--------------------------------------------------

  # Calculate monthly seasonal totals from 4 years.
  num <- sum(saaq_monthly_freq[
    saaq_monthly_freq[, 'month_num'] == month_num &
      saaq_monthly_freq[, 'points'] %in% c(5, 10), 'num'])/4

  saaq_monthly_freq_tab[
    saaq_monthly_freq_tab[, 'month_num'] == month_num, 'month_avg_5_10'] <- num


  #--------------------------------------------------
  # 7- and 14-point violations
  #--------------------------------------------------

  # Calculate monthly seasonal totals from 4 years.
  num <- sum(saaq_monthly_freq[
    saaq_monthly_freq[, 'month_num'] == month_num &
      saaq_monthly_freq[, 'points'] %in% c(7, 14), 'num'])/4

  saaq_monthly_freq_tab[
    saaq_monthly_freq_tab[, 'month_num'] == month_num, 'month_avg_7_14'] <- num

}



##################################################
# Plots of numbers of offences over time.
##################################################

# Set date indices for axis labels.
new_year_dates <- substr(saaq_monthly_freq_tab[, 'month'], 6, 7) == '01'
new_year_dates <- (1:nrow(saaq_monthly_freq_tab))[new_year_dates]
new_year_labels <- substr(saaq_monthly_freq_tab[new_year_dates, 'month'], 1, 4)
# Correct for off-by one in graph.
new_year_dates <- new_year_dates - 1


#--------------------------------------------------
# Figure 1 with 5- and 10-point tickets.
#--------------------------------------------------

# Select set of point values.
pts_plot <- c(5, 10)

# Set file location for this draft.
fig_file_name <- sprintf('%s/num_pts_%d_%d.eps',
                         fig_dir, pts_plot[1], pts_plot[2])


# Select data.
counts <- cbind(saaq_monthly_freq_tab[, sprintf('pts_%d', pts_plot[1])],
                saaq_monthly_freq_tab[, sprintf('pts_%d', pts_plot[2])])



# Normalize counts by (monthly) seasonal averages.
counts_avg <- saaq_monthly_freq_tab[, sprintf('month_avg_%d_%d', pts_plot[1], pts_plot[2])]
counts_exs <- counts/counts_avg


setEPS()
postscript(fig_file_name)

# Plot as a stacked bar plot.
barplot(t(counts_exs),
        # t(counts),
        main = '',
        xlab = 'Month',
        ylab = 'Number of Tickets versus Monthly Average',
        ylim = c(0, 2),
        pch = 16,
        xaxt='n',
        space = rep(0, length(saaq_monthly_freq_tab[, sprintf('pts_%d', pts_plot[1])])),
        col = grey.colors(n = 2, start = 0.3, end = 0.9))
abline(v = (1:nrow(saaq_monthly_freq_tab))[saaq_monthly_freq_tab[, 'month'] == '2008-04'] - 1,
       lwd = 3)
axis(1, at = new_year_dates,
     labels = new_year_labels)
abline(h = 1.0, lwd = 2, lty = 'dashed')


dev.off()


#--------------------------------------------------
# Figure 2 with 7- and 14-point tickets.
#--------------------------------------------------

# Select set of point values.
pts_plot <- c(7, 14)

# Set file location for this draft.
fig_file_name <- sprintf('%s/num_pts_%d_%d.eps',
                         fig_dir, pts_plot[1], pts_plot[2])


# Select data.
counts <- cbind(saaq_monthly_freq_tab[, sprintf('pts_%d', pts_plot[1])],
                saaq_monthly_freq_tab[, sprintf('pts_%d', pts_plot[2])])



# Normalize counts by (monthly) seasonal averages.
counts_avg <- saaq_monthly_freq_tab[, sprintf('month_avg_%d_%d', pts_plot[1], pts_plot[2])]
counts_exs <- counts/counts_avg


setEPS()
postscript(fig_file_name)

# Plot as a stacked bar plot.
barplot(t(counts_exs),
        # t(counts),
        main = '',
        xlab = 'Month',
        ylab = 'Number of Tickets versus Monthly Average',
        ylim = c(0, 2),
        pch = 16,
        xaxt='n',
        space = rep(0, length(saaq_monthly_freq_tab[, sprintf('pts_%d', pts_plot[1])])),
        col = grey.colors(n = 2, start = 0.3, end = 0.9))
abline(v = (1:nrow(saaq_monthly_freq_tab))[saaq_monthly_freq_tab[, 'month'] == '2008-04'] - 1,
       lwd = 3)
axis(1, at = new_year_dates,
     labels = new_year_labels)
abline(h = 1.0, lwd = 2, lty = 'dashed')


dev.off()



##################################################
# Output table of frequencies for Table 2
##################################################

tab_1_file <- sprintf('%s/Point_Freq_Gender_Ratio.csv', tab_dir)

# Define selection of columns in table.
tab_sel_M_Pre <- saaq_agg[, 'sex'] == 'M' &
  !saaq_agg[, 'policy']
tab_sel_M_Post <- saaq_agg[, 'sex'] == 'M' &
  saaq_agg[, 'policy']
tab_sel_F_Pre <- saaq_agg[, 'sex'] == 'F' &
  !saaq_agg[, 'policy']
tab_sel_F_Post <- saaq_agg[, 'sex'] == 'F' &
  saaq_agg[, 'policy']

out_tab <- cbind(table(saaq_agg[tab_sel_M_Pre, 'points']),
                 table(saaq_agg[tab_sel_M_Post, 'points']),
                 table(saaq_agg[tab_sel_F_Pre, 'points']),
                 table(saaq_agg[tab_sel_F_Post, 'points']))

# Output the table of frequencies to produce Table 2.
write.csv(out_tab, file = tab_1_file)




##################################################
# End
##################################################

