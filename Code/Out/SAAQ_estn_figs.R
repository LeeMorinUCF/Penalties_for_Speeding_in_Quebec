################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Creating Figures from Regression Results
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
# Set parameters for file IO
################################################################################


# Set path for estimation results.
estn_dir <- 'Estn'

# Set path for output of figures.
fig_dir <- 'Figures'



################################################################################
# Plot Figure from Regression by Demerit Point Balance
################################################################################

# Set path for retrieving estimates.
# Specification: Plot by demerit point groups
spec_group <- 'points'
estn_file_name <- sprintf('estimates_%s.csv', spec_group)
estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)


# Read in the estimation results.
estn_results <- read.csv(file = estn_file_path)



# Select model with age interactions
age_int <- 'with'

# Select a subset of young drivers.
age_grp_sel <- '20-24'


points_policy_w_age <- data.frame(curr_pts = curr_pts_reg_list[2:11],
                                  policy_M = numeric(10),
                                  std_err_M = numeric(10),
                                  policy_F = numeric(10),
                                  std_err_F = numeric(10))



for (sex_sel in sex_sel_list) {

  print(sprintf('Calculating predictions for %s Drivers', sex_sel))

  #------------------------------------------------------------
  # Retrieve estimates
  #------------------------------------------------------------

  # Select the rows that correspond to a particular model and subsample.
  estn_sel <- estn_results[, 'sex'] == sex_sel &
    estn_results[, 'age_int'] == age_int
  est_coefs <- estn_results[estn_sel, ]


  #------------------------------------------------------------
  # Retrieve covariance matrix
  #------------------------------------------------------------

  # Set path for retrieving covariance matrix.
  cov_file_name <- sprintf('points_fig/cov_mat_v%d_%s_%s_age_int_%s.csv',
                           estn_version, spec_group, age_int, substr(sex_sel, 1, 1))
  cov_file_path <- sprintf('%s/%s', estn_dir, cov_file_name)

  vcov_hccme <- read.csv(file = cov_file_path)

  # Extract matrix with appropriate labels.
  rownames(vcov_hccme) <- vcov_hccme[, 'X']
  vcov_hccme <- vcov_hccme[, 2:ncol(vcov_hccme)]
  vcov_hccme <- as.matrix(vcov_hccme)


  #------------------------------------------------------------
  # Obtain the estimates and standard errors.
  #------------------------------------------------------------

  for (curr_pts_num in 1:10) {

    curr_pts_grp_sel <- curr_pts_reg_list[curr_pts_num - 1]

    # For version with age group interaction:
    var_sel <- c('policyTRUE',
                 sprintf('policyTRUE:age_grp%s', age_grp_sel),
                 sprintf('policyTRUE:curr_pts_reg%s', curr_pts_grp_sel))

    var_row_sel <- est_coefs[, 'Variable'] %in% var_sel

    col_name <- sprintf('policy_%s', substr(sex_sel, 1, 1))
    points_policy_w_age[curr_pts_num, col_name] <- sum(est_coefs[var_row_sel, 'Estimate'])


    # Calculate standard error of linear combination.
    col_name <- sprintf('std_err_%s', substr(sex_sel, 1, 1))
    points_policy_w_age[curr_pts_num, col_name] <- sqrt(sum(vcov_hccme[var_row_sel, var_row_sel]))



  }


}


#------------------------------------------------------------
# Plot Figure from Regression by Demerit Point Balance
#------------------------------------------------------------

# Set path for output of figure.
fig_file_name <- 'demerit_points_with_age_int.eps'
fig_file_path <- sprintf('%s/%s', fig_dir, fig_file_name)


# Set color scale.
grey_scale <- grey.colors(n = 12, start = 0.0, end = 0.9,
                          gamma = 2.2, rev = FALSE)
col_no_age_M <- grey_scale[1]
col_w_age_M <- grey_scale[3]
col_no_age_F <- grey_scale[6]
col_w_age_F <- grey_scale[8]


# Plot figure.
postscript(fig_file_path)
lines(points_policy_w_age[, 'policy_M']*100000,
     col = col_w_age_M,
     lty = 'dotdash',
     lwd = 3)
# Append standard error bands.
lines((points_policy_w_age[, 'policy_M'] +
         1.96*points_policy_w_age[, 'std_err_M'])*100000,
      col = col_w_age_M,
      lty = 'dotted',
      lwd = 3)
lines((points_policy_w_age[, 'policy_M'] -
         1.96*points_policy_w_age[, 'std_err_M'])*100000,
      col = col_w_age_M,
      lty = 'dotted',
      lwd = 3)

# Append plots for females.
lines((points_policy_w_age[, 'policy_F'])*100000,
      col = 'grey',
      lty = 'dotdash',
      lwd = 3)
lines((points_policy_w_age[, 'policy_F'] +
         1.96*points_policy_w_age[, 'std_err_F'])*100000,
      col = 'grey',
      lty = 'dotted',
      lwd = 3)
lines((points_policy_w_age[, 'policy_F'] -
         1.96*points_policy_w_age[, 'std_err_F'])*100000,
      col = 'grey',
      lty = 'dotted',
      lwd = 3)
dev.off()


############################################################
# Plot Figure from Event Study
############################################################

# Read in the estimates.
# Specification: event study
spec_group <- 'events'
estn_file_name <- sprintf('estimates_%s.csv', spec_group)
estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)
estn_results <- read.csv(file = estn_file_path)

# Select the relevant estimates.
mfx_males <- estn_results[estn_results[, 'sex'] == 'Male' &
                              estn_results[, 'reg_type'] == 'LPM' &
                              estn_results[, 'age_int'] == 'no', ]
mfx_females <- estn_results[estn_results[, 'sex'] == 'Female' &
                                estn_results[, 'reg_type'] == 'LPM' &
                                estn_results[, 'age_int'] == 'no', ]


# Create the time series of policy effects.
perm_males <- mfx_males[mfx_males[, 'Variable'] == 'policyTRUE', 'Estimate']
first_yr_males <- mfx_males[
  substr(mfx_males[, 'Variable'], 1, 18) == 'policy_monthpolicy', 'Estimate']
first_yr_males <- c(first_yr_males, rep(0, 12)) + perm_males

# Repeat for standard errors.
perm_males_SE <- mfx_males[mfx_males[, 'Variable'] == 'policyTRUE', 'Std_Error']
first_yr_males_SE <- mfx_males[
  substr(mfx_males[, 'Variable'], 1, 18) == 'policy_monthpolicy', 'Std_Error']
first_yr_males_SE <- c(first_yr_males_SE, rep(0, 12)) + perm_males_SE



perm_females <- mfx_females[mfx_females[, 'Variable'] == 'policyTRUE', 'Estimate']
first_yr_females <- mfx_females[
  substr(mfx_females[, 'Variable'], 1, 18) == 'policy_monthpolicy', 'Estimate']
first_yr_females <- c(first_yr_females, rep(0, 12)) + perm_females

# Repeat for standard errors.
perm_females_SE <- mfx_females[mfx_females[, 'Variable'] == 'policyTRUE', 'Std_Error']
first_yr_females_SE <- mfx_females[
  substr(mfx_females[, 'Variable'], 1, 18) == 'policy_monthpolicy', 'Std_Error']
first_yr_females_SE <- c(first_yr_females_SE, rep(0, 12)) + perm_females_SE




#------------------------------------------------------------
# Plot Figure from Event Study
#------------------------------------------------------------


# Set file location for this figure.
fig_file_name <- sprintf('%s/event_study.eps',
                         fig_path)

# Set colors.
color_list <- grey.colors(n = 2, start = 0.3, end = 0.6)

setEPS()
postscript(fig_file_name)


# Set axes.
plot(NA,
     xlim = c(1, 24),
     ylim = c(-20, 10),
     xlab = "Months Since Policy Change",
     ylab = "Policy Effect x 100,000",
     # main = c("Salary Comparison for Business Analytics Students*"),
     # cex.main = 1.60, cex.lab = 1.5, cex.axis = 1.5
     xaxt = "n"
)
axis(side = 1, at = seq(3, 24, by = 3)) #, labels = FALSE)
abline(h = 0, lwd = 1, col = 'black', lty = 'solid')



# Plot curves for males.
# lines(seq(13, 24), rep(perm_males*100000, 12), lwd = 3, col = color_list[1], lty = 'solid')
lines(seq(24), first_yr_males*100000, lwd = 3, col = color_list[1], lty = 'solid')
# Plot SE bands for males.
lines(seq(24), (first_yr_males + 1.96*first_yr_males_SE)*100000,
      lwd = 3, col = color_list[1], lty = 'dashed')
lines(seq(24), (first_yr_males - 1.96*first_yr_males_SE)*100000,
      lwd = 3, col = color_list[1], lty = 'dashed')



# Plot curves for females.
# lines(seq(13, 24), rep(perm_females*100000, 12), lwd = 3, col = color_list[2], lty = 'dashed')
lines(seq(24), first_yr_females*100000, lwd = 3, col = color_list[2], lty = 'solid')
# Plot SE bands for females.
lines(seq(24), (first_yr_females + 1.96*first_yr_females_SE)*100000,
      lwd = 3, col = color_list[2], lty = 'dashed')
lines(seq(24), (first_yr_females - 1.96*first_yr_females_SE)*100000,
      lwd = 3, col = color_list[2], lty = 'dashed')


dev.off()



############################################################
# End
############################################################
