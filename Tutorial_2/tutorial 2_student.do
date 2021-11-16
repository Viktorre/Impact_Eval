////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Lab Session 2: Descriptive statistics
////////////////////////////////////////////////////////////////////////////////

/ Author: Charlotte Robert + Alexandra Avdeenko
/ Heidelberg University - Winter Semester 2021
/ Student version
In this tutorial, you will learn how to rigourously explore and investigate data before conducting causal analysis.*/
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
global path = "C:\Users\fx236\Documents\impact_eval\Impact_Eval\Tutorial_2"
cd "$path" //to call a global  just add a dollar sign in front of the global name. Here $path
dir //view the files in your directory
capture log close
log using "tut2.log", replace


////////////////////////////////////////////////////////////////////////////////
*** PART 1 : Basic statistics using data in Baird et al.
////////////////////////////////////////////////////////////////////////////////

use "$path/data/baird.dta", clear

** Let's have a look at what is in there 
describe, fullnames //lets us see the variables, their type and their label 

** Quick look at our data
summarize 
summarize asset_index_baseline, detail

** Let's first have a look at our sample. How many schoolgirls are in our data? 
codebook girlid // we have ... unique schoolgirls 
count

** Is there a variable that could help us identify unique schoolgirls? 
tab girlid 

** Have a look at the variable girlid. How do we call this type of dataset?


** For now, we are only interested in the first round (baseline level), before the study took place. Drop the other observations so that we have cross-sectional data: 
drop if round > 1

** Let's focus for now on the variable female_headed. This variable indicates whether a schoolgirl lives in a household where the head is a woman or not. 
** What are the characteristics of female_headed households? Do they differ from non-female headed households? 
** The asset index baseline gives us a relative indication of wealth. Do female headed households differ in terms of wealth? 

** Let's first look at the distribution of the index for the whole sample: 
hist asset_index_baseline 
kdensity asset_index_baseline

/*
*Histograms: Frequency distributions show how often each different value in a set of data occurs. 
*A histogram is the most commonly used graph to show frequency distributions - useful to check if there are outliers and if data is approximately normally distributed


*Kernel density plots: A Density Plot visualises the distribution of data over a continuous interval or time period. 
*This chart is a variation of a Histogram that uses kernel smoothing to plot values, allowing for smoother distributions 
*by smoothing out the noise. The peaks of a Density Plot help display where values are concentrated over the interval.
*Advantage: they're better at determining the distribution shape because they're not affected by the number of bins used.
*/

** Now let's compare both groups: female headed and male headed
** On average, how do they differ in terms of wealth? 

mean(asset_index_baseline) if female_headed == 1
mean(asset_index_baseline) if female_headed == 0

** To have more detailed stats we can use tabstat:
tabstat asset_index_baseline, stats(N mean sd min max p25 p50 p75) by(female_headed)

** Visually: 
hist asset_index_baseline, by(female_headed) // what does this result suggest? 

** Suppose you want to present this finding in a presentation. Let's make it a bit nicer:
kdensity asset_index_baseline if female_headed == 0, ///
	addplot(kdensity asset_index_baseline if female_headed ==1) ///
	legend(ring(0) pos(2) label(1 "Male headed hh") label(2 "Female headed hh")) /// 
	title("Difference in wealth depending on the gender of the household head") /// even though it's quite convincing visually already, it would be even more striking if we plotted the mean for each group that we computed earlier
	xline(-.5245731) xline(.7780255, lpattern(l))
** Let's export it at pdf format
graph export kdensity.pdf 

** Female headed hh seem to considerably differ on average in terms of the asset index compared to other hh. 
** However, since sample means are estimates of the population mean, the difference in average is also an estimate - with a CI and a standard error.
** What we are interested in inferring is whether the estimated difference between both groups is significantly different from zero. 

** To find out, we need to perform a t-test. A t-statistic measures the distance of the estimated value from what the true value would be if H0 was true.
** What is H0 in this case? What is HA? 
** H0: the difference in mean is not significantly different from zero
** HA: the difference in mean is significantly different from zero 
** T-test measures how far the estimated value of the difference in average between our two groups is from zero (H0: diff = 0)
** We compare ttest to a critical value that informs our decision to reject or not H0

ttest asset_index_baseline, by(female_headed) //how do we interpret these results? PVAL=0, reject h0


** Let's now dig into the research question of the study:
** How many girls received conditional transfers? How many girls received unconditional transfers? How many are in the control group? 
codebook girlid if schoolgirl_CCT ==1
codebook girlid if schoolgirl_UCT ==1
codebook girlid if schoolgirl_control ==1
*or
count if schoolgirl_CCT ==1 & round ==1 
count if schoolgirl_UCT ==1 & round ==1 
count if schoolgirl_control ==1 & round ==1 


** What is the probability that a schoolgirl in our sample lives under a female headed household at baseline (round 1)? Which percentage does it represent? 
tab female_headed

**  We saw that, on average, female headed households are significantly poorer than the male headed households. 
** How many schoolgirls live under a female headed household and received cash transfers (at baseline)? how many are in the control group?

tab female_headed if (schoolgirl_CCT == 1 | schoolgirl_UCT == 1) 
tab female_headed if schoolgirl_control == 1

** The share of schoolgirls living in female headed household is slightly larger in the control group then in the group that receives transfers. Is the difference significant? 
** First let's generate a variable that takes the value 1 if the schoolgirl is receiving any transfer at baseline (UCT and CCT combined), 0 otherwise. We will call it treatment:
gen treatment =.
replace treatment = 1 if (schoolgirl_CCT == 1 | schoolgirl_UCT == 1)
replace treatment = 0 if schoolgirl_control == 1

** Let's compute the difference: 
ttest female_headed, by(treatment) // YES SIGNIFICANT DIFFERENCE AND THIS IS A PROBLEM

** Does this lead to a difference in wealth between both groups?
ttest asset_index_baseline, by(treatment)
// There is substantial difference 

** Let's check if both groups differ in other ways 
global controls hhsize female_headed mobile age highest_grade_baseline mother_alive father_alive never_had_sex_baseline ever_preg_r1 //SAVES ALL VARS INTO GLOBAlVAR CALLED CONTROLS

foreach x of global controls {
	
describe `x'
ttest `x', by(treatment)
} //groups differ in dimension: at 5% no other var. only problem with variable from beofre female_headed
** The two groups don't seem to substantially differ too much 


** We saw that, on average, female headed hh are poorer than male headed hh. 
** How are female_headed and asset_index_baseline correlated? 
pwcorr(female_headed asset_index_baseline), sig star(0.05) 
** Living in a female-headed hh is negatively correlated with the relative asset index -> there is a negative association between female_headed and the asset index

**Let's now look at other hh characteristics that are likely to differ depending on the gender of the hh head. We will create a table of correlations: 
pwcorr asset_index_baseline female_headed hhsize father_alive mother_alive mobile 

**Are these correlations significant? (= statistically different from zero?)
pwcorr asset_index_baseline female_headed hhsize father_alive mother_alive mobile, sig star(0.05)

** Another way to look at the association between female_headed and wealth: simple bi-variate regression 
** Simple regression analysis uncovers mean-dependence between two variables: uncovers the average value of a variable y for different values of another variable x
** In other words, how the average value of y varies when x varies 
**Bi-variate regression:
reg asset_index_baseline female_headed 
** Negative coefficient. Is the coefficient significant (= different from zero)? 
** Constant, coefficient, standard error, t-student of the coefficient, p-value of the t-student - H0: coefficient is 0 
** R-square very small - the gender of the hh head is far from explaining the variation in hh wealth among schoolgirls

** Multivariate regression, adding other covariates: 
reg asset_index_baseline $controls, robust //This tells stata to add all of the variables contained in the global controls defined at line 152 //DOLLAR SIGN NEEDED HERE TO CALL CONTROL VARIABLES; BEFORE IN LOOP WE USED "global controls"
** Plotting residuals
predict assethat //This creates a new variable that contains the predicted values y-hat by the model (by the simple regression)
predict e, resid //This creates a new variable containing the residuals from the model: observed value (y) - predicted value (y-hat)
br asset_index_baseline assethat e 
hist e, bin(20) percent fcol(navy*0.8) lcol(navy) //Let's look at the distribution of these resdiuals
scatter assethat e //Plotting the fitted values to the residuals to see any pattern in the data 
//Weird shape because index is bounded 


////////////////////////////////////////////////////////////////////////////////
*** PART 2 : Understanding regressions and log transformations
////////////////////////////////////////////////////////////////////////////////

** In this section, we will use the same case analysis as the one presented in the lecture 
** Code mostly retrieved from https://github.com/gabors-data-analysis/da_case_studies/blob/master/ch07-hotels-simple-reg/ch07-hotels-simple-reg.do
** Recap: 
** We are trying to find a good deal among hotels. The example in the book looks at hotel in Vienna
** We are interested in two variables: price and distance to the city center. We want to find the best deal with regards to price and distance to the city
** Let's first load in the data 
use "$path/data/hotels-vienna.dta", clear

*** We select good rated hotels and drop outlier
*** 3 to 4-star hotels (incl 3.5 stars)
keep if stars>=3 & stars<=4
keep if accommodation_type=="Hotel"
label var distance "Distance to city center, miles"
drop if price>600 	/* likely error */

*** drop hotels not really in Vienna
tab city_actual 
keep if city_actual=="Vienna"
describe, fullnames //lets us see the variables, their type and their label 

** This part creates the graphs seen in the slides - we won't use it in the tutorial. Good to check and understand for your personal knowledge
/*
*********************************************************************
*** NONPARAMETRIC REGRESSION 1: CLOSE VS FAR
** We create two groups, hotels that are close and far with a threshold at 2miles
gen dist_2groups=distance>=2 
 lab def dist_2groups 0 close 1 far
 lab val dist_2groups dist_2groups 
 lab var dist_2groups "Distance to city center: close vs. far"

egen Eprice_cat2=mean(price), by(dist_2groups) //creates a variable that takes the value of the average price of the respective category in which the hotel lies
tab Eprice_
 format Eprice_cat2 %3.0f//rounds the value to an integer
tabstat distance, by(dist_2groups) s(mean sd min max n)
tabstat price, by(dist_2groups) s(mean sd min p25 p50 p75 max n)

* First graph - scatter plot of the average in both groups and the average distance 
scatter Eprice_cat2 dist_2groups, ///
 ms(O) msize(vlarge) mcolor(navy*0.8) mlabel(Eprice_cat2) ///
 xscale(range(-0.5 1.5)) yscale(range(0 400)) ///
 xlab(0 1, valuelabel grid) ylab(0(50)400, grid) ///
 xtitle("Distance to city center (categories)") ///
 ytitle("Average price (US dollars)") ///
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))



cap drop dist4groups Eprice_cat4 //adding cap before drop tells stata to drop the following variables if they exist - if they dont exist, it does not lead to an error like drop alone would 
egen dist4groups=cut(distance), at(0 1 2 3 7) //Creating 4 categories 
replace dist4groups=dist4groups+0.5
replace dist4groups=5 if dist4groups==3.5 
tabstat distance, by(dist4groups) s(min mean max p95 n) 
egen Eprice_cat4=mean(price), by(dist4groups)
 format Eprice_cat4 %3.0f
 lab var Eprice_cat4 "Average price in 4 distance categ."
tabstat distance, by(dist4groups) s(mean sd min max n)
tabstat price, by(dist4groups) s(mean sd min p25 p50 p75 p95 max n)


* Same graph as before but using four categories this time
* PLOT MEAN VALUES BY CLOSE VS FAR -- 4 values
scatter Eprice_cat4 dist4groups, ///
 ms(O) msize(vlarge) mcolor(navy*0.8) mlabel(Eprice_cat4) ///
  xscale(range(0 7)) xlab(1(2)7, grid) yscale(range(0 400)) ylab(0(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Average price (US dollars))") ///
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))
graph export "$output/ch07-figure-1b-scatter-nonpar2-Stata.png", as(png) replace
 
 
*********************************************************************
*** SCATTERPLOT + NONPARAMETRIC REGRESSION AS STEP FUNCTION

*** (4 distance categories)
** Creating the 'steps' variables to add in the graph
egen price4steps = mean(price), by(dist4groups)
 gen p4s_1 = price4steps if dist4groups==0.5
 gen p4s_2 = price4steps if dist4groups==1.5
 gen p4s_3 = price4steps if dist4groups==2.5
 gen p4s_4 = price4steps if dist4groups==5


* Figure 7.2.a
scatter price distance, ///
 ms(O) mlw(small) mcolor(navy*0.7)  ///
 xlab(0(1)7, grid) yscale(range(0 400)) ylab(0(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Price (US dollars)") ///
|| line p4s_* distance, /// adds the step lines
 lp(solid solid solid solid) lcolor(green green green green)  ///
 lw(thick thick thick thick) legend(off)



* 7 bins 
/*
* create 7 bins of distance
egen dist7groups = cut(distance), at(0(1)7)
 tabstat distance, by(dist7g) s(min max n)
* create variable with average price within distance bins
egen price7steps = mean(price), by(dist7groups)
forvalue i=1/7 {
	gen p7s_`i' = price7steps if dist7groups==`i'-1
}

* scatterplot with step function
scatter price distance, ///
 ms(O) mlw(small) mcolor(navy*0.7)  ///
 xlab(0(1)7, grid) yscale(range(0 400)) ylab(0(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Price (US dollars)") ///
|| line p7s_* distance, ///
 lp(solid solid solid solid solid solid solid) lcolor(green green green green green green green)  ///
 lw(thick thick thick thick thick thick thick) legend(off)

* cosmetics: last two bins have one obs only, 
* step function line doesn't show there.
* cosmetic solution:
* create four fake observations, each for the two ends of the last two bins

* first create new distance variable for step function
*  so scattrplot doesn't show them as real observations
gen distfake = distance
* add 4 nes observations
set obs `=_N+4'
count
* set fake distance variable to ends of last bins
replace distfake = 5.1 if _n==_N-3
replace distfake = 5.9 if _n==_N-2
replace distfake = 6.1 if _n==_N-1
replace distfake = 6.9 if _n==_N
* assign average prices to new observations
sum price if dist7groups==5
replace p7s_6 = r(mean) if distfake>5 & distfake<6
sum price if dist7groups==6
replace p7s_7 = r(mean) if distfake>6 & distfake<7

* redo graph so that step fucntion shows in last two bins, too
* Figure 7.2.b
scatter price distance, ///
 ms(O) mlw(small) mcolor(navy*0.7)  ///
 xlab(0(1)7, grid) yscale(range(0 400)) ylab(0(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Price (US dollars)") ///
|| line p7s_* distfake, ///
 lp(solid solid solid solid solid solid solid) lcolor(green green green green green green green)  ///
 lw(thick thick thick thick thick thick thick) legend(off)
graph export "$output/ch07-figure-2b-stepfn7cat-Stata.png", as(png) replace
*/

*********************************************************************
** Non parametric regression with lowess 

* Figure 7.3
*** lowess with scatterplot

lowess price distance , bwidth(0.8) ///
 lineopts(lw(thick) lc(green)) ///
 ms(O) msize(small) mlw(thick) mcolor(navy*0.7)  ///
 xlab(0(1)7, grid) yscale(range(0 300)) ylab(50(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Price (US dollars)") title("") note("") ///
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))
 
*/
********************************************************************
*** LINEAR REGRESSIONS - What does it mean to fit a linear model to our data? 
regress price distance 

* Fig 7.5
*** SCATTERPLOT + REGRESSION LINE

scatter price distance , saving(main) ///
 ms(O) msize(small) mlw(thick) mcolor(navy*0.8) ///
 xlab(0(1)7, grid) ylab(000(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Price(US dollars)") ///
 || lfit price distance, lw(thick) lc(green) legend(off)  /// This adds the fitted line to the scatter plot 
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))
** This line is the line that fits the closest to all the points in the data 


* Histogram of residuals
regress price distance 
predict pred_price
predict e ,resid 
hist e, bin(20) percent fcol(navy*0.8) lcol(white) ///
 xlab(-100(100)300, grid) ylab(0(5)30, grid) ///
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))

* Residuals against fitted values 
scatter pred_price e, saving(residuals) //No specific pattern, residuals clustered around 0, few points with very big residuals // we could already see it on the prevous scatter plot
gr combine main.gph residuals.gph // Combining both plots 
 
* Log transformations 
** Very common to log tranform data 
**NEED TO ADD STUFF HERE** WHY IS IT COMMON 

* Let's generate a new variable that takes the logarithm of prices
gen lnprice = ln(price)

* run and compare regressions	
reg price distance, r
reg lnprice distance, r //r indicates that the regression has robust standard errors (corrected for heteroskedasticity)

/// ADD INTERPRETATION OF COEFFS HERE

	 
* Visually, what did the log change? 

hist price, saving(price)
hist lnprice, saving (lnprice)
gr combine price.gph lnprice.gph //log transforming the variable makes the distribution closer to a normal distribution, which is more convenient and desirable 

scatter price distance , saving(pricescatter) ///
 ms(O) msize(small) mlw(thick) mcolor(navy*0.6) ///
 xlab(0(1)7, grid) ylab(000(50)400, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("Hotel price(US dollars)") ///
 || lfit price distance, lw(thick) lc(green) legend(off)  ///
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))


scatter lnprice distance , saving(lnpricescatter) ///
 ms(O) msize(small) mlw(thick) mcolor(navy*0.6) ///
 xlab(0(1)7, grid) ylab(3.5(0.50)6, grid) ///
 xtitle("Distance to city center (miles)") ///
 ytitle("ln(hotel price in US dollars)") ///
 || lfit lnprice distance, lw(thick) lc(dkgreen) legend(off)  ///
 graphregion(fcolor(white) ifcolor(none))  ///
 plotregion(fcolor(white) ifcolor(white))

gr combine pricescatter.gph lnpricescatter.gph
//Line seems to fit the data better with the log transformation 

log close 