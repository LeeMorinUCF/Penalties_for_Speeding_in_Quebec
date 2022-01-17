#!/bin/bash

################################################################################
#
# Analysis of Penalties for Speeding in Quebec
#
# Main Script
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
# Run scripts for Data Preparation
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Generating dataset..."
echo ""

Rscript Code/SAAQ_tickets.R
Rscript Code/SAAQ_point_balances.R
Rscript Code/SAAQ_driver_counts.R
Rscript Code/SAAQ_join.R
echo ""

echo "Generating dataset."
echo ""
echo "#-------------------------------------------------"
echo ""

################################################################################
# Run script for Estimation
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Estimating models..."
echo ""

Rscript Code/SAAQ_Regs.R
echo ""

echo "Finished estimating models."
echo ""
echo "#-------------------------------------------------"
echo ""


################################################################################
# Run script for Generating Tables and Figures
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Generating tables and figures..."
echo ""

Rscript Code/SAAQ_Tables.R
Rscript Code/SAAQ_estn_figs.R
Rscript Code/SAAQ_count_figs.R
echo ""

echo ""
echo "Renaming figures for CJE naming conventions..."
echo ""

mv Figures/num_pts_5_10.eps Figures/Figure1.eps
mv Figures/num_pts_7_14.eps Figures/Figure2.eps
mv Figures/demerit_points_with_age_int.eps.eps Figures/Figure3.eps
mv Figures/event_study.eps Figures/Figure4.eps


echo "Finished generating tables and figures."
echo ""
echo "#-------------------------------------------------"
echo ""



################################################################################
# End
################################################################################
