////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Lab Session 3: Randomized Control Trials - Case Study - Part 1 
////////////////////////////////////////////////////////////////////////////////

/ Author: Charlotte Robert 
/ Heidelberg University - Winter Semester 2021
/ Teacher version
 */
////////////////////////////////////////////////////////////////////////////////


/* !!!!!!!!!!!!!!!!!!!!!!!! Remember:
To execute a do-file:
- highligh the command on your do
- press Ctrl + d or click on the button "Execute"
Do NOT copy-paste in the window command 
*/


////////////////////////////////////////////////////////////////////////////////
*** Setting your working environment 
////////////////////////////////////////////////////////////////////////////////


clear all //clears your memory and everything in it
set more off //set more on, which is the default, tells Stata to wait until you press a key before continuing when a -more- message is displayed
// set more off tells Stata not to pause or display the more message; it is useful when you work with large datasets. 
// Normally, Stata pauses to display output after a certain number of lines and waits for any key to be pressed in order to continue; 
// we do not want that and want Stata to run smoothly without interruption.


*Global macros: create a shortcut to be used later on. For instance, you may want to create a computer path
global path = "..."
cd "$path" //to call a global  just add a dollar sign in front of the global name. Here $path
//dir //view the files in your directory
//capture log close
//log using "tut3.log", replace


////////////////////////////////////////////////////////////////////////////////
*** PART 1 : Correlation vs Causality - Demonstration using HISP data
////////////////////////////////////////////////////////////////////////////////

** Using data from HISP - Health Insurance Subsidy Program - fictional data of a program implemented to reduce the burden of health-related **out-of-pocket** expenditures for low income households. 
use "$path\data\HISP.dta", clear

* Descriptive Stats
**==========	
** Use HISP data: 
	* Check the variables: 
		describe, fullnames

	* Summarize to have an overview of our variable 
		summarize 
		summarize health_expenditures, detail
		
		set scheme plotplain
		hist health_expenditures //right-skewed - long tail on the right 

	* Number of villages? 
		tab locality_identifier
		codebook locality_identifier

	*Number of treated villages? 
		egen villages_treated=group(locality_identifier) if treatment_locality==1 
		//creates a new unique identifier only for treated villages
		sum villages_treated

	*Number of untreated villages? 
		egen villages_nt=group(locality_identifier) if treatment_locality==0 
		sum villages_nt
		
	* Number of hh? Before treatment ? After treatment ? Number of treated hh ? Number of non treated hh in treated villages? 
		
		* Number of households? => 9914
		codebook household_identifier 
		*Number of households in treated villages? => 4960
		codebook household_identifier if treatment_locality == 1 
		*Number of households in untreated villages? => 4954
		codebook household_identifier if treatment_locality == 0 

		*Before HISP / After HISP
			tab  treatment_locality if round==0
			tab  treatment_locality if round==1
		*One household added in the sample? Likely an error 	
			
			
	*Number of treated households? => 2964
		tab enrolled if round==0
	*	if round==1 = 2965
		tab enrolled if round==1

	*Number of non treated hh in treated villages? => 1995
		tab enrolled if round==0 & treatment_locality==1 
		
* I. Simple before after on the treated 
**==========
	* Let's only keep the households that live in a treated village and that were treated:
		use "$path\data\HISP.dta", clear
		keep if treatment_locality==1 
		keep if enrolled ==1

	*Are the average out of pocket health expenditures different for pre- and post-HISP treatments?
		ttest health_expenditures, by(round)
		//We see a significant reduction in health_expenditures in the treated. 

		
		
	*We can see the same thing with a regression
		reg health_expenditures round
	*Is this result satisfactory? Can you explain why or why not?
	
	*Maybe changes in some household characteristics between the 2 rounds explain some of the decrease in expenditure between the two rounds,
	*If we control for these potential factors, i.e., all other things being equal, what is then the effect of the program?
	
	
	
	*Regression with control variables: 
		global controls age_hh age_sp educ_hh educ_sp female_hh indigenous hhsize dirtfloor bathroom land hospital_distance
		
		reg health_expenditures round $controls

		
		
	*QUESTION :

		* / Is this evaluation method convincing and reliable?
			* No! because many factors can affect the level of health expenditure over time,
			* and are not controlled in the model (i.e. not included in the list of explanatory/control variables);
			* For example: economic conditions, lower medicinal drug prices, more or better weather affecting disease risk, etc.
			* In these circumstances, the decline in spending cannot be attributed to the program with certainty



* II. With / Without comparison, 2 years after the program 
**==========
	* Let's only keep data from the second round and treated villages 
		use "$path\data\HISP.dta", clear
		keep if treatment_locality==1
		keep if round==1

	* Are mean expenditures different after HISP between treated and untreated?
	* Comparison of means test 
		ttest health_expenditures, by(enrolled)
		
	* Bivariate linear regression
		reg health_expenditures enrolled
		

	*It is possible that the decision to engage in the program is not independent of household characteristics
	*The estimated impact would therefore not be explained (only) by the program but also the characteristics that make a hh enroll in the program
	*To address this problem of initial differences between treated and untreated individuals,
	*Control variables are added to the model to capture these differences:
	
	* Multivariate regression
		reg health_expenditures enrolled $controls

		*QUESTIONS :

			* Is this evaluation method convincing and reliable?			
/*	

* No! It is unlikely that the control variables included in the model capture all of the initial differences that may have an effect on health expenditures. 
			* between the 2 groups (treated vs untreated)...
			* e.g., household preferences, risk aversion, confidence level, etc.
			* may explain why some engage and others do not...

	***CONCLUSION ON THESE METHODS :
		* These two "simple" difference methods produce unreliable estimates
		* (they do not offer a valid counterfactual)
		* The result is two very different estimates, 
		* leading to different policy recommendations (scale-up or not scale-up the program?)
*/




* III. Exploiting the fact that treatment was RANDOMLY ASSIGNED
**==========
	* The program is randomized at the village level, so we compare changes between treated and untreated villages
	* The 100 treated villages were randomly selected from the 200 eligible poor villages nationwide,
	* Households in treated and untreated villages should have similar characteristics
	* (i.e., zero expected difference)
	* The only thing that differentiates them is whether or not they were enrolled in the program.
	* In this case, the untreated households offer a good counterfactual of what would have happened if the treated villages had not been treated!

	*Let's only keep eligible households (households that were poor enough)
		use "$path\data\HISP.dta", clear
		keep if eligible==1

	* Are households in treated and untreated villages identical?
		* Differences in mean
		foreach x of global controls {
			describe `x'
			ttest `x' if round ==0, by(treatment_locality)
			}
			
	* Are the two groups of villages similar?
	/*
	* The two groups of villages appear to be roughly similar
	* The only significant differences at the 5% level are for the variables age_hh, educ_hh & hospital_distance
	* While the differences are statistically significant, they are not economically substantial
	*/

		***
		* Previously, we have carried out balance tests on the control variables 
		* - make sure that treatment groups do not differ significantly from control group 
		* Now we want to make sure that at baseline, there is no significant difference in the outcome (enrollment) 
		* between both treatment arms and control group
		* -> Check that the assignment to treatment is truly independent from the potential outcome 
		
	* Difference in expenditure before treatment (Testing Baseline Balance)		
		ttest health_expenditures if round ==0, by(treatment_locality)
		
		reg health_expenditures treatment_locality if round ==0, cl(locality_identifier)
		
	* Pre-program, households in the treatment group and the ones in the control group have similar levels of out of pocket health expenditures
	* The difference in health expenditures between the two groups can thus entirely be attributed to the treatment 
		ttest health_expenditures if round==1, by(treatment_locality)

	* With a regression (clustering by village)
		reg health_expenditures treatment_locality if round ==1, cluster(locality_identifier)
		//Interpretation: Being treated is associated with lower expenditures by 10$ on average compared to untreated villages, 2 years after the program. 
		
		
	* With a multivariate regression (clustering by village)
		reg health_expenditures treatment_locality $controls if round ==1, cluster(locality_identifier)

		
	* Both (randomized!) groups were exposed to the same shocks and public policies
	* Observable post-program differences are therefore attributed to the program



////////////////////////////////////////////////////////////////////////////////
*** PART 2 : Case Study RCTs - Using Baird et al
////////////////////////////////////////////////////////////////////////////////

use "$path\data\baird.dta", replace

* Reminder of important varialbes: 
* schoolgirl_CCT: dummy variable = 1 if schoolgirl is receiving conditional cash transfers 
* schoolgirl_UCT: dummy variable = 1 if schoolgirl is receiving unconditional cash transfers 
* schoolgirl_control: dummy variable = 1 if schoolgirl is in the control group 
* girlid: unique identifier of schoolgirls
* round: = 1 Baseline (Pre-2008), = 2 Round 2 (2008-2009), = 3 Round 3 (2010)
* hhsurvey_round3: dummy variable equal to 1 if schoolgirl was interviewed in Round 3 
* all_rounds_surveyed: dummy variable equal to 1 if schoolgirl was interviewed in all rounds


* I. Measuring attrition: 
**==========

		* At the baseline, there were 2284 schoolgirl identified:
		codebook girlid
		tab hhsurvey_round3 round
		tab all_rounds_surveyed round
		
		* Out of these 2284 observations, 2186 are still included in the Round 3 household survey and 2089 were in ALL three rounds
		* Why should we care about this? 
		* Household survey consisted of multitopic questionnaire administered to the households in which the sampled respondents resided. 
		* Hh survey includes question on self-reported school enrollment status 
		
	
* Attrition is a problem if there is unequal loss of participants in the control group compared to the treatment group and vice versa. 
		* We call it attrition bias when there is systematic error caused by the withdrawal of participants in the study
		* Causes of attritions are numerous: 
		* In this case, we can think of households migrating, leaving the village, 
		* individuals within the household leaving (schoolgirl leaving to join another family member, marrying and leaving the region with no contact), 
		* individuals no longer wanting to be surveyed 
		* deaths 
		
* Attrition is a problem for estimators: randomized assignment, DiD, RDD
		* If the households were initially randomly selected to "represent" the population, 
		* then the second wave survey sample no longer represents the population! => loss of external validity
		* because those who left the sample may have particular (distinguishing) characteristics: wealth, education, confidence, risk aversion...
		* Attrition can also affect the statistical balance between treated and untreated => internal validity, assignment to treatment no longer random
		
* Attrition can also more generally threaten the statistical power of the study: 
		* The statistical power of a study refers to the ability to detect an effect if one exists.
		* If you compare two treatments and you find there is no significant difference between them, 
		* if you do not have sufficient statistical power, you do not know whether you failed to find a difference because: 
		* a) there is no difference 
		* b) you were not able to detect the difference 

* Therefore, we check if attrition is significant:
		* 1/ Verify that the initial characteristics of the "drop-outs" are similar to the initial characteristics of those who stay 
		* 2/ Verify that the attrition rates of treated and untreated individuals are similar/balanced
		* If these 2 conditions are met, then attrition does not threaten the validity of the evaluation

		



* #delimit; //using #delimit tells stata that a line of code ends with ';', not with line wrapping 
* -> useful when having long lines and to make your code more readable (for example making graphs)
* Delimitation stops until next comment

* Let's regress the dummy variable = 1 if schoolgirl was in a household that got interviewed in the 3rd round as part of the hh survey
		* Dependent variable: dummy variable => probability that girl is in interviewed hh at round 3
		* Explanatory variables: dummy variables for each treatment arm 
		* Coefficients: how does being in the CCT arm/UCT arm influence the probability that the girl lives in an interviewed hh at round 3, 
		* compared to the baseline -> compared to being in the control group
		
reg  hhsurvey_round3 schoolgirl_CCT schoolgirl_UCT if round==3 [pw=wgt], robust cl(eaid) 
	estimates store reg //We store estimated parameters in the last regression ran 
	ereturn list //Let's look at what we stored 
	help ereturn 
	
* What are the results? 
		* -> CCT and UCT dummies are statistically not significant -> chances to be in all three rounds is not 
		* significanlty associated with being in treatment groups VS. being in control group
		
* But there could still be an imbalance in attrition between both treatment groups: 
		* We store the estimates of the regression, and then test the coefficients against another -> are they statistically different? 	
		* test is command to perform a Wald test. We check if the coefficients are statistically different from each other
		
	test schoolgirl_CCT=schoolgirl_UCT 

	
	//Command 'test' tests linear hypotheses after estimation by performing a Wald test 
	//-> Here we test in the null hypothesis if the difference between both coefficients measured for CCT/UCT is equal to zero.
	//Very high p-value: we can't reject H0 -> We can't claim that the coefficients are significantly different 
	
	//Wald test: The null hypothesis for the test is: some parameter = some value.  
	
	eststo reg1


* Same thing looking at girls in hh surveyed in all three rounds: 
reg  all_rounds_surveyed schoolgirl_CCT schoolgirl_UCT if round==3 [pw=wgt], robust cl(eaid)
	estimates store reg2
	test schoolgirl_CCT=schoolgirl_UCT 
	eststo reg2
	





* II. Reproducing main results:  Table IV, Panel A
**==========


* We want to reproduce the main results: measure the impact of both UCTs and CCTs on school enrolment, and how this impacted school enrolment (self reported)
		* Create a global of controls, same as in the analysis: 
		global controls= "highest_grade_baseline asset_index_baseline never_had_sex_baseline _Iage_R1_14- _Iage_R1_20 stratum1 stratum2" 
		* Age variables are dummy variables equal to 1 if girl is age X at round 1 - (including all age variables until age 20)
		* stratum1-2 control for the strata used to perform block randomization
		* Age and stratum specific sampling weights are used to make the results representative of the target population in the study area
		
		
		** Year 1 : 2008 
		* Dependent variables: term1_r2 term2_r2 term3_r2 -> equal to one if a schoolgirl self reported being enrolled in the first term of Year 1 (2008)
		* /!\ Year 1 is not equal to round 1. Round 1 occured before 2008 
est clear 	
reg term1_r2 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if all_rounds_surveyed==1 & round==2, cluster(eaid)
	estimates store reg1
	test schoolgirl_CCT=schoolgirl_UCT // Checking if the coefficients for both arms are significantly different from each other
	estadd scalar CCT_UCT = r(p), replace

** Interpretation of the results: 
/*
		* Receiving conditional transfers compared to being in the control group is not 
		* significantly associated with the probability of being enrolled in the first term of year 2008, age, stratum, 
		* asset index and highest grade attended being held equal. 
		
		* Receiving unconditional transfers is significantly associated with a higher probability to be enrolled in the first term of year 2008 by 3.4% 
		* compared to not receiving any transfer (control group) at the 1% significance level, age, stratum, 
		* asset index and highest grade attended being held equal.
		
		* We can argue that this measured impact is causal: the impact of UCT transfers on enrollment in the first term of 2008 is 3.4%. 
*/
reg term2_r2 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if all_rounds_surveyed==1 & round==2, cluster(eaid)
	estimates store reg2
	test schoolgirl_CCT=schoolgirl_UCT // Checking if the coefficients for both arms are significantly different from each other
	estadd scalar CCT_UCT = r(p), replace

/*
** Interpretation of the results: 
		* Receiving conditional transfers is significantly associated with a higher probability to be enrolled in the second term of year 2008 by 1.9% 
		* compared to not receiving any transfer (control group) at the 10% significance level, age, stratum, 
		* asset index and highest grade attended being held equal.
		
		* Receiving unconditional transfers is significantly associated with a higher probability to be enrolled in the second term of year 2008 by 5.1% 
		* compared to not receiving any transfer (control group) at the 1% significance level, age, stratum, 
		* asset index and highest grade attended being held equal.
		
		* Both coefficients are signficantly different: UCTs have a significantly higher impact than CCTs on school enrollment 
*/

** Recreating the complete table: 

reg term3_r2 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if  all_rounds_surveyed==1 & round==2, cl(eaid)
estimates store reg3
test schoolgirl_CCT=schoolgirl_UCT
estadd scalar CCT_UCT = r(p), replace

reg inschool_term1_2009 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if  all_rounds_surveyed==1 & round==3, cl(eaid)
estimates store reg4
test schoolgirl_CCT=schoolgirl_UCT
estadd scalar CCT_UCT = r(p), replace


reg inschool_term2_2009 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if  all_rounds_surveyed==1 & round==3, cl(eaid)
estimates store reg5
test schoolgirl_CCT=schoolgirl_UCT
estadd scalar CCT_UCT = r(p), replace


reg inschool_term3_2009 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if  all_rounds_surveyed==1 & round==3, cl(eaid)
estimates store reg6
test schoolgirl_CCT=schoolgirl_UCT
estadd scalar CCT_UCT = r(p), replace

reg num_terms_enrolled schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if  all_rounds_surveyed==1 & round==3, cl(eaid)
estimates store reg7
test schoolgirl_CCT=schoolgirl_UCT
estadd scalar CCT_UCT = r(p), replace

reg inschool_term1_2010 schoolgirl_CCT schoolgirl_UCT $controls [pw=wgt] if  all_rounds_surveyed==1 & round==3, cl(eaid)
estimates store reg8
test schoolgirl_CCT=schoolgirl_UCT
estadd scalar CCT_UCT = r(p), replace

esttab reg*, cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
collabels(none) label prehead(\begin{tabular}{l*{@M}{c}} "\hline") posthead("\hline") postfoot("\hline" "\end{tabular}") ///
	noabbrev mlabels("2008 Term 1" "2008 Term 2" "2008 Term 3" "2009 Term 1" "2009 Term 2" "2009 Term 3" "TOTAL number of terms" "2010 Term 1") ///
	stats(r2 N CCT_UCT , labels( "R-squared" "Observations"  "schoolgirl CCT=schoolgirl UCT (p-value)" )  ///
	fmt(0 0 2 0 0 3)) keep(schoolgirl_CCT schoolgirl_UCT ) style(tex) numbers("(" ")") replace
	
**Exporting results to LaTeX 
estout reg* using "mainresults.txt", cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
collabels(none) label prehead(\begin{tabular}{l*{@M}{c}} "\hline") posthead("\hline") postfoot("\hline" "\end{tabular}") ///
	noabbrev mlabels("2008 Term 1" "2008 Term 2" "2008 Term 3" "2009 Term 1" "2009 Term 2" "2009 Term 3" "TOTAL number of terms" "2010 Term 1") ///
	stats(r2 N CCT_UCT , labels( "R-squared" "Observations"  "schoolgirl CCT=schoolgirl UCT (p-value)" )  ///
	fmt(0 0 2 0 0 3)) keep(schoolgirl_CCT schoolgirl_UCT ) style(tex) numbers("(" ")") replace
	

log close 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

	
	
	

