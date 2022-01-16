################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Creating LaTeX Tables from Regression Models
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

# The scales package can print large sample sizes in comma format.
library(scales)


################################################################################
# Set parameters for file IO
################################################################################

# Set path for estimation results.
estn_dir <- 'Estn'

# Set directory for Tables.
tab_dir <- "Tables"

# Read library of functions for generating LaTeX tables.
tab_lib_path <- "Code/Lib/SAAQ_Tab_Lib.R"
source(tab_lib_path)


################################################################################
# Load Estimates for Tables.
################################################################################




#------------------------------------------------------------
# Specification: All Drivers with Monthly and weekday seasonality
#------------------------------------------------------------

spec_group <- 'all'

estn_version <- 12
estn_file_name <- sprintf('estimates_v%d_%s.csv', estn_version, spec_group)
estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)
estn_results_full <- read.csv(file = estn_file_path)
summary(estn_results_full)



#------------------------------------------------------------
# Sensitivity Analysis: High-point drivers.
# (with monthly and weekday seasonality)
#------------------------------------------------------------

spec_group <- 'high_pts'

estn_version <- 13
estn_file_name <- sprintf('estimates_v%d_%s.csv', estn_version, spec_group)
estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)
estn_results_high <- read.csv(file = estn_file_path)
summary(estn_results_high)


#------------------------------------------------------------
# Sensitivity Analysis: Placebo regression.
# (with monthly and weekday seasonality)
#------------------------------------------------------------


spec_group <- 'placebo'

estn_version <- 14
estn_file_name <- sprintf('estimates_v%d_%s.csv', estn_version, spec_group)
estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)
estn_results_placebo <- read.csv(file = estn_file_path)
summary(estn_results_placebo)


#------------------------------------------------------------
# Specification: Event study with seasonality
#------------------------------------------------------------

spec_group <- 'events'

estn_version <- 15
estn_file_name <- sprintf('estimates_v%d_%s.csv', estn_version, spec_group)
estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)
estn_results_events <- read.csv(file = estn_file_path)
summary(estn_results_events)


################################################################################
# Define lists required for tables
################################################################################

# List to divide sample into males and females.
sex_list <- c('All', 'Male', 'Female')

# Create list of age categories for regressions by age group.
age_grp_list <- unique(estn_results_full[substr(estn_results_full[, 'Variable'], 1, 7) ==
                                               'age_grp', 'Variable'])
age_grp_list <- substr(age_grp_list, 8, nchar(age_grp_list))


# Create list of labels for policy*age interactions.
if (join_method == 'orig_agg') {
  age_group_list <- c('0-15', '16-19',
                      '20-24', '25-34', '35-44', '45-54',
                      '55-64', '65-199')
  age_int_var_list <- sprintf('policyTRUE:age_grp%s', age_group_list)
  age_int_label_list <- data.frame(Variable = age_int_var_list,
                                   Label = c('Age 0-15 * policy',
                                             'Age 16-19 * policy',
                                             'Age 20-24 * policy',
                                             'Age 25-34 * policy',
                                             'Age 35-44 * policy',
                                             'Age 45-54 * policy',
                                             'Age 55-64 * policy',
                                             'Age 65+ * policy'))


} else {
  # Coarser grouping to merge less-populated age groups:
  age_group_list <- c('0-19',
                      '20-24', '25-34', '35-44', '45-54',
                      '55-64', '65-199')
  age_int_var_list <- sprintf('policyTRUE:age_grp%s', age_group_list)
  age_int_label_list <- data.frame(Variable = age_int_var_list,
                                   Label = c('Age 16-19 * policy',
                                             'Age 20-24 * policy',
                                             'Age 25-34 * policy',
                                             'Age 35-44 * policy',
                                             'Age 45-54 * policy',
                                             'Age 55-64 * policy',
                                             'Age 65+ * policy'))


}




# Create list of labels for indicators by point value for the dependent variable.
# points_var_list <- unique(estn_results_full[, 'pts_target'])
pts_target_list <- c('all',
                     '1', '2', '3', '4', '5', '7',
                     '9+')
points_label_list <- data.frame(Variable = pts_target_list,
                                Label = c('All point values',
                                          '1 point',
                                          '2 points',
                                          '3 points',
                                          '4 points',
                                          '5 points',
                                          '7 points',
                                          '9 or more points'))


# Create list of labels for policy*month interactions.
event_month_list <- sprintf('policy_monthpolicy%s',
                            c(sprintf('0%d', seq(9)), c('10', '11', '12')))
events_label_list <- data.frame(Variable = event_month_list,
                                Label = sprintf('Month %d',
                                                as.numeric(substr(event_month_list, 19, 20))))





############################################################
# Generate Logit vs LPM Tables.
############################################################


# Set parameters for TeX file for Table.
tab_tag <- 'seas_Logit_vs_LPMx100K'
header_spec <- 'Seasonal Logit and LPM x 100K'

# Set parameters for model selection.
season_incl <- 'mnwk'

# Set parameters for display formatting.
num_fmt <- 'x100K'

# Set captions for tables.
Logit_LPM_description <- c(
  "For each regression, the dependent variable is an indicator that a driver has committed ",
  "any offence on a particular day. ",
  "All regressions contain age category and demerit point category controls,",
  "as well as monthly and weekday indicator variables.",
  "The baseline age category comprises drivers under the age of 16.",
  "The heading ``Sig.\'\' is an abbreviation for statistical significance, with",
  "the symbol * denoting statistical significance at the 0.1\\% level",
  "and ** the 0.001\\% level.",
  "Marginal effects, as well as linear probability model coefficients and standard errors, are ",
  "in scientific notation. ",
  "The linear probability model uses heteroskedasticity-robust standard errors."
)

Logit_LPM_pts_description <- c(
  "The dependent variable in each regression is equal to one ",
  "if a driver receives a ticket with a particular point value  ",
  "(that of the first column for a particular row) on that day, ",
  "and is otherwise equal to zero.",
  "The categories of tickets with 3, 5 and 7 points includes tickets ",
  "with 6, 10 and 14 points after the policy change, respectively, ",
  "and the category with 9 or more points includes tickets ",
  "with all corresponding doubled values after the policy change.",
  "All regressions contain age category and demerit point category controls,",
  "as well as monthly and weekday indicator variables.",
  "The baseline age category comprises drivers under the age of 16.",
  "The heading ``Sig.\'\' is an abbreviation for statistical significance, with",
  "the symbol * denoting statistical significance at the 0.1\\% level",
  "and ** the 0.001\\% level.",
  "Marginal effects, as well as linear probability model coefficients and standard errors, are ",
  "in scientific notation. ",
  "The linear probability model uses heteroskedasticity-robust standard errors. "
)



# Generate tables.
SAAQ_Logit_vs_LPM_2MFX_table_gen(tab_dir, tab_tag, header_spec,
                                 season_incl, num_fmt,
                                 estn_results_by_age = NULL,
                                 estn_results_full, estn_results_high,
                                 estn_results_placebo, estn_results_events,
                                 age_grp_list, age_int_label_list,
                                 points_label_list, sex_list,
                                 orig_description = Logit_LPM_description,
                                 orig_pts_description = Logit_LPM_pts_description,
                                 incl_mfx = TRUE,
                                 est_pooled = FALSE)


################################################################################
# End
################################################################################
