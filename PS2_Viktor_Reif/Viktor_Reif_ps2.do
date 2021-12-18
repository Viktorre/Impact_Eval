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
browse
use "schoolvar.dta"
browse


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


*** g)


*** h)


*** i)


*** j)