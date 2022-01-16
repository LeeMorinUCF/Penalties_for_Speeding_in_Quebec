################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Estimation of Regression Models
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

# Set directory for full dataset.
data_dir <- 'Data'

# Set name of input file for estimation samples.
data_file_name <- sprintf('%s/saaq_full.csv', data_dir)


# Set path for estimation results.
estn_dir <- 'Estn'


# Read script for calculating marginal effects.
mfx_path <- "Code/Lib/SAAQ_MFX_Lib.R"
source(mfx_path)

# Read library of functions for regression modeling.
reg_lib_path <- "Code/Lib/SAAQ_Reg_Lib.R"
source(reg_lib_path)


# Load functions for regressions with aggregated data.
agg_reg_path <- "Code/Lib/SAAQ_Agg_Reg_Lib.R"
source(agg_reg_path)

# Load functions for calculation of HCCME with aggregated data.
agg_het_path <- "Code/Lib/SAAQ_Agg_Het_Lib.R"
source(agg_het_path)




################################################################################
# Set Parameters for variables
################################################################################

# Age group categories for defining factors.
age_group_list <- c('0-19',
                    '20-24', '25-34', '35-44', '45-54',
                    '55-64', '65-199')
orig_age_grp_list <- age_grp_list


# Current points group categories for defining factors.
curr_pts_grp_list <- c(seq(0,10), '11-20', '21-30', '31-150')

# Weekday indicators.
weekday_list <- c('Sunday',
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday')

# Set date of policy change.
april_fools_date <- '2008-04-01'


################################################################################
# Load Dataset
################################################################################

# Full dataset.
in_path_file_name <- sprintf('%s/%s', data_dir, data_file_name)
saaq_data <- fread(in_path_file_name)

summary(saaq_data)


################################################################################
# Define additional variables
################################################################################

# Define categorical variables as factors.

saaq_data[, sex := factor(sex, levels = c('M', 'F'))]
table(saaq_data[, sex], useNA = "ifany")

saaq_data[, age_grp := factor(age_grp, levels = orig_age_grp_list)]
table(saaq_data[, age_grp], useNA = "ifany")

saaq_data[curr_pts_grp == '30-150', curr_pts_grp := '31-150']
saaq_data[, curr_pts_grp := factor(curr_pts_grp, levels = curr_pts_grp_list)]
table(saaq_data[, curr_pts_grp], useNA = "ifany")

# Define new variables for seasonality.
# Numeric indicator for month.
saaq_data[, month := substr(date, 6, 7)]
month_list <- unique(saaq_data[, month])
month_list <- month_list[order(month_list)]
saaq_data[, month := factor(month, levels = month_list)]
table(saaq_data[, month], useNA = "ifany")

# Weekday indicator.
saaq_data[, weekday := weekdays(date)]
saaq_data[, weekday := factor(weekday, levels = weekday_list)]
table(saaq_data[, weekday], useNA = "ifany")

# Define the indicator for the policy change.
saaq_data[, policy := date >= april_fools_date]

summary(saaq_data)


#--------------------------------------------------------------------------------
# Create new factors by consolidating some categories
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Age groups.
#--------------------------------------------------------------------------------
table(saaq_data[, age_grp], useNA = 'ifany')

# Consolidate age group categories.
saaq_data[, age_grp_orig := age_grp]
age_grp_list <- c(orig_age_grp_list[seq(7)], '65-199')

saaq_data[, 'age_grp'] <- as.factor(NA)
saaq_data[, age_group_sel := age_grp_orig %in% orig_age_grp_list[seq(7)]]
saaq_data[age_group_sel == TRUE, age_grp := age_grp_orig]
saaq_data[age_group_sel == FALSE, age_grp := age_grp_list[8]]
saaq_data[, age_grp := factor(age_grp, levels = age_grp_list)]


# Trust but verify.
table(saaq_data[, age_grp],
      saaq_data[, age_grp_orig], useNA = 'ifany')
# Check.

#--------------------------------------------------------------------------------





#--------------------------------------------------------------------------------
# Current point balance groups.
#--------------------------------------------------------------------------------
table(saaq_data[, 'curr_pts_grp'], useNA = 'ifany')

# Consolidate categories of current points balances.
saaq_data[, curr_pts_grp_orig := curr_pts_grp]
new_curr_pts_grp_list <- c('0', '1-3', '4-6', '7-9', '10-150')

# Create the new factor.
saaq_data[, 'curr_pts_grp'] <- as.factor(NA)
levels(saaq_data[, 'curr_pts_grp']) <- new_curr_pts_grp_list

# Add the zero points group first.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[1]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_grp := curr_pts_grp_orig]
# Add groups 1-3.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[2:4]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_grp := new_curr_pts_grp_list[2]]
# Add groups 4-6.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[5:7]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_grp := new_curr_pts_grp_list[3]]
# Add groups 7-9.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[8:10]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_grp := new_curr_pts_grp_list[4]]
# Add the rest: 10-150.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[11:14]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_grp := new_curr_pts_grp_list[5]]


# Reset levels of new curr_pts_grp factor.
saaq_data[, curr_pts_grp := factor(curr_pts_grp,
                                   levels = new_curr_pts_grp_list)]
table(saaq_data[, curr_pts_grp], useNA = 'ifany')


# Trust but verify.
table(saaq_data[, curr_pts_grp],
      saaq_data[, curr_pts_grp_orig], useNA = 'ifany')
# Check.
#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
# Current point balances for detailed regression by demerit point balance.
#--------------------------------------------------------------------------------
table(saaq_data[, curr_pts_grp], useNA = 'ifany')

# Consolidate categories of current points balances.
saaq_data[, curr_pts_reg := curr_pts_grp]
curr_pts_reg_list <- c(as.character(seq(0,9)), '10-150')

# Create the new factor.
saaq_data[, 'curr_pts_reg'] <- as.factor(NA)
levels(saaq_data[, 'curr_pts_reg']) <- curr_pts_reg_list

# Add the separate point levels first.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[1:10]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_reg := curr_pts_grp_orig]
# Add the rest: 10-150.
saaq_data[, curr_pts_grp_sel := curr_pts_grp_orig %in% curr_pts_grp_list[11:14]]
saaq_data[curr_pts_grp_sel == TRUE, curr_pts_reg := curr_pts_reg_list[11]]


# Reset levels of new curr_pts_reg factor.
saaq_data[, curr_pts_reg := factor(curr_pts_reg,
                                   levels = curr_pts_reg_list)]
table(saaq_data[, curr_pts_reg], useNA = 'ifany')


# Trust but verify.
table(saaq_data[, curr_pts_reg],
      saaq_data[, curr_pts_grp_orig], useNA = 'ifany')
# Check.
#--------------------------------------------------------------------------------



################################################################################
# Generate new variables to be defined within loop
################################################################################


# Generate variables for regressions.
saaq_data[, 'policy'] <- NA
saaq_data[, 'window'] <- NA
saaq_data[, 'events'] <- NA



################################################################################
# Estimation
################################################################################


# Set the combinations of model specifications to be estimated.

past_pts_list <- c('all')
reg_list <- c('LPM', 'Logit')
sex_list <- c('All', 'Male', 'Female')
pts_target_list <- c('all',
                     '1', '2', '3', '4', '5', '7',
                     '9+')
age_int_list <- c('no', 'with') # ..  age interactions

pts_int_list <- c('no', 'with') # ..  demerit-point interactions


# Specify headings for each point level.
pts_headings <- data.frame(pts_target = pts_target_list,
                           heading = NA)
pts_headings[1, 'heading'] <- 'All violations combined'
pts_headings[2, 'heading'] <- 'One-point violations (for speeding 11-20 over)'
pts_headings[3, 'heading'] <- 'Two-point violations (speeding 21-30 over or 7 other violations)'
pts_headings[4, 'heading'] <- 'Three-point violations (speeding 31-60 over or 9 other violations)'
pts_headings[5, 'heading'] <- 'Four-point violations (speeding 31-45 over or 9 other violations)'
pts_headings[6, 'heading'] <- 'Five-point violations (speeding 46-60 over or a handheld device violation)'
pts_headings[7, 'heading'] <- 'Seven-point violations (speeding 61-80 over or combinations)'
pts_headings[8, 'heading'] <- 'All pairs of infractions 9 or over (speeding 81 or more and 10 other offences)'



############################################################
# Set parameters for marginal effects
############################################################


# Set parameters for typical driver who gets tickets.
mfx_data_MER <- data.frame(TRUE, 'policyFALSE', 'M', '20-24',
                           '4-6', '07', 'Monday', 1)
colnames(mfx_data_MER) <- c("policy", "policy_month", "sex", "age_grp",
                            "curr_pts_grp", "month", "weekday", "num")



############################################################
# Set List of Regression Specifications
############################################################

# Loop through the specification groups for the analysis.
spec_group <- NULL


#------------------------------------------------------------
# Specification: All Drivers with Monthly and weekday seasonality
spec_group <- c(spec_group_list, 'all')
#------------------------------------------------------------

#------------------------------------------------------------
# Sensitivity Analysis: High-point drivers.
# (with monthly and weekday seasonality)
spec_group <- c(spec_group_list, 'high_pts')
#------------------------------------------------------------

#------------------------------------------------------------
# Sensitivity Analysis: Placebo regression.
spec_group <- c(spec_group_list, 'placebo')
#------------------------------------------------------------

#------------------------------------------------------------
# Specification: REAL event study with seasonality
spec_group <- c(spec_group_list, 'events')
#------------------------------------------------------------

#------------------------------------------------------------
# Specification: Plot by demerit point groups
spec_group <- c(spec_group_list, 'points')
#------------------------------------------------------------


for (spec_group in spec_group_list) {


  model_list <- model_spec(spec_group,
                           sex_list, age_grp_list, age_int_list,
                           pts_target_list, reg_list)

  # Set path for printed results.
  estn_file_name <- sprintf('estimates_%s.csv', spec_group)
  estn_file_path <- sprintf('%s/%s', estn_dir, estn_file_name)





  #------------------------------------------------------------
  # Run estimation in a loop on the model specifications.
  #------------------------------------------------------------

  # Initialize data frame to store estimation results.
  estn_results <- NULL


  # Initialize path.
  for (estn_num in 1:nrow(model_list)) {

    # Extract parameters for this estimated model.
    past_pts_sel <- model_list[estn_num, 'past_pts']
    window_sel <- model_list[estn_num, 'window']
    season_incl <- model_list[estn_num, 'seasonality']
    reg_type <- model_list[estn_num, 'reg_type']
    sex_sel <- model_list[estn_num, 'sex']
    pts_target <- model_list[estn_num, 'pts_target']
    age_int <- model_list[estn_num, 'age_int']
    pts_int <- model_list[estn_num, 'pts_int']


    #--------------------------------------------------
    # Data preparation.
    # Calculate variables specific to the model specification.
    #--------------------------------------------------

    saaq_data <- saaq_data_prep(saaq_data,
                                window_sel,
                                past_pts_sel,
                                sex_sel,
                                age_int, age_grp_list,
                                pts_target)


    #--------------------------------------------------
    # Set formula for regression model
    #--------------------------------------------------

    var_list <- reg_var_list(sex_sel,
                             window_sel,
                             age_int, age_grp_list,
                             pts_int,
                             season_incl)

    fmla <- as.formula(sprintf('events ~ %s',
                               paste(var_list, collapse = " + ")))




    #--------------------------------------------------
    # Run regressions
    #--------------------------------------------------
    if (reg_type == 'LPM') {

      # Estimating a Linear Probability Model

      # Estimate the model accounting for the aggregated nature of the data.
      agg_lm_model_1 <- agg_lm(data = saaq_data[sel_obsn == TRUE, ], weights = num,
                               formula = fmla, x = TRUE)
      summ_agg_lm <- summary_agg_lm(agg_lm_model_1)

      # Adjust standard errors for heteroskedasticity.
      agg_lpm_hccme_1 <- white_hccme_med(agg_lm_model_1)
      summ_model <- agg_lpm_hccme_1

      est_coefs <- summ_model$coef_hccme


      # Save the covariance matrix for models with demerit-point interactions.
      if (pts_int == "with") {
        # Set path for saving covariance matrix.
        cov_file_name <- sprintf('points_fig/cov_mat_%s_%s_age_int_%s.csv',
                                 spec_group, age_int, substr(sex_sel, 1, 1))
        cov_file_path <- sprintf('%s/%s', estn_dir, cov_file_name)

        write.csv(agg_lpm_hccme_1$vcov_hccme, file = cov_file_path)
      }

    } else if (reg_type == 'Logit') {

      # Estimate logistic regression model.
      log_model_1 <- glm(data = saaq_data[sel_obsn == TRUE, ], weights = num,
                         formula = fmla,
                         family = 'binomial')

      # Calculate SE based on chosen method.
      # "Standard" standard errors for logistic regression.
      summ_model <- summary(log_model_1)
      est_coefs <- summ_model$coefficients


    } else {
      stop(sprintf("Model type '%s' not recognized.", reg_type))
    }


    #--------------------------------------------------
    # Calculate marginal effects, if appropriate.
    #--------------------------------------------------

    # Only meaningful for logit regressions.
    if (reg_type == 'Logit') {
      mfx_mat <- mfx_mat_calc(saaq_data,
                              log_model_1,
                              est_coefs,
                              mfx_data_MER,
                              var_list,
                              window_sel,
                              sex_sel,
                              age_int, age_grp_list)
    } else {
      mfx_mat <- NA
    }




    #--------------------------------------------------
    # Store the regression results for tables.
    #--------------------------------------------------

    estn_results_sub <- estn_results_table(est_coefs, estn_num,
                                           num_obs = sum(saaq_data[sel_obsn == TRUE, 'num']),
                                           reg_type, mfx_mat,
                                           age_int, age_grp_list, window_sel)


    # Bind it to the full data frame of results.
    estn_results <- rbind(estn_results, estn_results_sub)

  }

  # Save the data frame of estimates.
  write.csv(estn_results, file = estn_file_path)

}

################################################################################
# End
################################################################################

