////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Problem Set 2
////////////////////////////////////////////////////////////////////////////////

/ Author: Viktor Reif
/ Heidelberg University - Winter Semester 2021
 */
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
*** I - Replicating Table 1
////////////////////////////////////////////////////////////////////////////////

***a) i)
//We want to show that the groups are similar to prove that heterogeneity between groups cannot bias our results.
***a) ii)
clear all 
set more off
global path = "C:\Users\fx236\Documents\impact_eval\Impact_Eval\PS2_Viktor_Reif"
cd "$path" 
capture log close
log using "ps2.log", replace
use "namelist.dta", clear
//browse // I use browse to get familiar with the data...
use "schoolvar.dta"
//browse


*** b)
use "namelist.dta", clear
// I assume every child in the datset had the first visit in 1998
keep if visit==981


*** c)
//duplicates drop pupid, force  would also work
keep if dupid==1
duplicates report pupid

*** d)
merge 1:1 pupid using "pupq.dta"

*** e) i)
gen absent_share = absdays_98_6/20

*** e) ii)
// I assume often sick only holds if value is "often ". "Sometime" does not count.
gen often_sick = 0
replace often_sick=1 if fallsick_98_37==3
*** e) iii)
// I assume "a bit dirty" does not count as clean.
gen clean = 0
replace clean=1 if clean_98_15==1

*** f)
//collapse converts the dataset in memory into a dataset of means, sums, medians, etc. clist must refer to numeric variables exclusively
//collapse absent_share bloodst_98_58 often_sick malaria_98_48 clean 
collapse sex elg98 stdgap yrbirth wgrp* absent_share bloodst_98_58 often_sick malaria_98_48 clean (count) number_pupils=pupid, by (schid) 
bys wgrp: summ sex elg98 stdgap yrbirth absent_share bloodst_98_58 often_sick malaria_98_48 clean [aweight=number_pupils] 

*** g)
foreach var in sex elg98 stdgap yrbirth absent_share bloodst_98_58 often_sick malaria_98_48 { 
	regress `var' wgrp1 wgrp2 [aweight=number_pupils] 
		} 

*** h)
clear
use "schoolvar.dta"
bys wgrp: summ mk96_s distlake pup_pop latr_pup z_inf98 pop1_3km_updated pop1_36k_updated popT_3km_updated popT_36k_updated 
// regress `var' wgrp  does not work because stata does not understand categorical variables. I use dummies but omit category 3
gen wgrp_1 = (wgrp==1) 
gen wgrp_2 = (wgrp==2) 
foreach var in mk96_s distlake pup_pop latr_pup z_inf98 pop1_3km_updated pop1_36k_updated popT_3km_updated popT_36k_updated { 
			regress `var' wgrp_1 wgrp_2 
		} 

*** i)


*** j)






