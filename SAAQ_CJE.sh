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

Rscript Code/file1.R > Code/file1.out
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

Rscript Code/file2.R > Code/file2.out
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

Rscript Code/file2.R > Code/file2.out
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
