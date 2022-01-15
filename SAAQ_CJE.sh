#!/bin/bash

################################################################################
#
# Analysis of Penalties for Speeding in Quebec
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


################################################################################
# Run scripts for Data Manipulation
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

mv Figures/num_pts_5_10_all.eps Figures/Figure1.eps
mv Figures/num_pts_7_14_all.eps Figures/Figure2.eps
mv Figures/points_fig_with_age_int.eps Figures/Figure3.eps
mv Figures/Event_Study.eps Figures/Figure4.eps


echo "Finished generating tables and figures."
echo ""
echo "#-------------------------------------------------"
echo ""



################################################################################
# End
################################################################################
