////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Problem Set 2
////////////////////////////////////////////////////////////////////////////////

/ Author: Viktor Reif
/ Heidelberg University - Winter Semester 2021
 */
////////////////////////////////////////////////////////////////////////////////
***Part1:

//Q1: The motivation of the paper is that a significant amount of people suffer from intestinal helminths and its treatment's benefits are strongly underestimated. Its purpose is to show the benefits of that treatment in the form of externalities in a case study with African schools. The research questions center around finding out what are the direct and external effects of worm treatment on school attendance and on academic test scores. Those questions are relevant because worm treatment would be cheaper than other measures to boost school attendance. Also they are relevant because intestine worms are very common and its treatment effect underestimated.

//Q2: We should believe that there exists said causal relation because some of the previous literature has already shown that relation or similar relations. Eg  Strauss and Thomas (1998) found that health has a causal effect  on income and Glewwe and Jacoby (1995) found that health causally affects academic achievment. Moreover, we should believe that, because this very paper (Miguel and Kramer 2004) empirically finds that relation, too.

//Q3: The experiment is conducted in 75 Kenian schools with 30000 children. treatments means that pupils of an entire school get de-worm treatment. The 75 schools are randomly split into 3 equally large groups: 25 school received treamtent in 1998 and 1999 (group 1), 25 schools only in 1999 (group 2), and the last 25 schools started treatment in 2001 (group 3). In 1998 group 1 is the treatment group and group 2+3 are the comparison group(s). In 1999 group 1+2 are treatment and group 3 is comparison.

//Q4: They do that, because they suspect a bias in treatment selection either on within-school pupil level (children with certain health characteristics receiving significantly more often treatment) or on between-school level (children with certain health characteristics changing schools to get treatment from the experiment).
//This would threaten the results as it could bias the estimates of treatment's direct or external effect on school attendance.
//They find that the groups are in fact similar, and that any bias is likely to be small.

//Q5: Higher worm loads in 98&99 lead to more sick children. This leads to less school participation by the comparison group due that exogenous shock than normal, whereas the treatment group is mostly (as most kids got dewormed) unaffected by the shock and shows higher school participation. Thus, in 98&99 there is a bias when comparing control and treatment as participation in control is lower than usual whilst working with a "normal" (ie largely unaffected by the flooding) treatment group. I expect the bias to be positive. This means that when estimating deworming effects on participation, the analysis will overestimate the effect (which is a positive effect, ie more deworming means more participation) of deworming.





////////////////////////////////////////////////////////////////////////////////
*** Part2: I - Replicating Table 1
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
//eststo test1: estpost 

*** g)
foreach var in sex elg98 stdgap yrbirth absent_share bloodst_98_58 often_sick malaria_98_48 { 
	regress `var' wgrp1 wgrp2 [aweight=number_pupils] 
		} 

*** h)
clear
use "schoolvar.dta"
bys wgrp: summ mk96_s distlake pup_pop latr_pup z_inf98 pop1_3km_updated pop1_36k_updated popT_3km_updated popT_36k_updated 
//estimates store summ2
// regress `var' wgrp  does not work because stata does not understand categorical variables. I use dummies but omit category 3
gen wgrp_1 = (wgrp==1) 
gen wgrp_2 = (wgrp==2) 
foreach var in mk96_s distlake pup_pop latr_pup z_inf98 pop1_3km_updated pop1_36k_updated popT_3km_updated popT_36k_updated { 
			regress `var' wgrp_1 wgrp_2 
			estimates store `var' 
		} 

*** i)
// After playing around with the stata export options, I decided to copy the results directly from the console into an excel file. For group differences, the respective row below the estimated value shows the robust standard errors.

//failed attempts:
	//estimates store reg 
	
	//ereturn list //Let's look at what we stored 
//reg  all_rounds_surveyed schoolgirl_CCT schoolgirl_UCT if round==3 [pw=wgt], robust cl(eaid)
	//estimates store reg2
	//test schoolgirl_CCT=schoolgirl_UCT 
//	eststo reg2

//ereturn list
//esttab test1  using table1.tex,
//esttab base_6t4 lag_6t4 lead_6t4  all_6t4_one using base_6t4.tex,replace keep(ltemp6t410 temp6t410  letemp6t410 ) se brackets  star(* 0.10 ** 0.05 *** 0.01) ///
	//mtitles("base"  "1-Daylag" "1-Day lead"  "all")	
	
*** j)
// My results are very similar to the ones presented in the original paper, thus that its main findings can be confirmed considering my results. Small deviations might be found due to some uncertainties on my side. For example I do not know whether the authors used the overall schoolid or the schoolid of certain years in some parts of the analysis. Also, I might have some small specification errors, in that case due to a typing error.


