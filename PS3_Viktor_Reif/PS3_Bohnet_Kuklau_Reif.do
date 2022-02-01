////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Problem Set 3
////////////////////////////////////////////////////////////////////////////////

/ Author: Marc-Phillipp Bohnet, Timo Kuklau, Viktor Reif
/ Heidelberg University - Winter Semester 2021
 */
////////////////////////////////////////////////////////////////////////////////
***Part1:
//Q1:  The paper tries to reveal the causal link between minimum wage and employment, where minimum wage affects employment. 
//The motivation of the paper is that during that time many new minimum wage laws were passed in the US and that "classic" economic models of competitive markets are maybe wrong about that causal link.  The main research question is: Does an increase in minimum wage yield an adverse employment effect in a competitive low-wage labor market? 
//The main result is that the minimum wage does not have a significant effect on employment. This result is not in line with conventional theory, in which a negative employment effect is expected when wages are exogenously increased.  Furthermore, prices are expected to increase with respect to the elasticity of demand and new store openings should decrease. With respect to store openings or permanent closures, they could not identify any adverse effect. Prices, however, rose in the comparison across states even though these price effects could not be directly linked to increased labor costs, as restaurants that were heavily affected by the increase in minimum wages did not increase prices more than other restaurants within New Jersey. 
//Q2: Ideally, we could either clone New Jersey (NJ) and assign the minimum wage to all the restaurants in the low wage sector in one of them and observe the difference in employment, wages and prices after implementation holding the environment of both NJ constant. However, the authors argue that fast-food restaurants face similar economic conditions in Pennsylvania (PA) and NJ such that PA restaurants qualify as a natural control group, hence setting up their analysis as a natural experiment. Furthermore, they use a diff-in-diff approach to account for unobservable variation within each state.
//Also, they check internal validity by comparing high and low wage restaurants within the state of NJ – if the minimum wage is lower than in baseline "high wage" restaurants, these are hardly affected by it.
//They interview "nearly 100 percent of stores" right before the intervention and 7-8 months after. Furthermore, they take account of employment changes in closed stores to tackle possible selection bias due to attrition. 

//Q3: They assume exogeneity: there might be some omitted variables, reverse causality (across-state-spillover effects, general equilibrium effects, etc) that bias the coefficient of interest. 
//Furthermore, the employment difference within NJ is assumed to be representative for any year to year comparison. Also, they assume that PA and NJ are representative samples for all states in the USA such that they can generalize their findings. Moreover, they assume the chosen sample (fast food restaurants) suffices to generalize the findings for all industries that employ minimum wage workers. 
//One potential threat is the omission of controls for price dynamics and non-wage offsets, which would (if true) lead to a positive bias. This means the estimate of interest is higher than its true value. Another potential problem is the fact that NJ is in recession at the time the minimum wage is implemented. If we assume that negative employment effects due to recession asymmetrically affects low skilled workers since it is easier to replace/hire them back if the economy improves again, we have an upwards bias in the employment effect. 

 
//Q4: Probably the criticism due to them having only data of wages at only two points in time and NJ being in recession. It could be the case that the natural employment level was higher anyways and the timing of the study only made it seem like there was no decrease in employment. With their chart, they show that employment levels afterwards are more or less following the same neutral trend in the long run and there was never the case that the short-run movement of employment decreased right after an intervention, rather the contrary that employment spiked a little or at least changed a downward-facing trend in direction after implementation of higher minimum wages.

//Q5: The two critical points for me are model specification and sample scope.
//One weakness is the lack of testing the model with alternative controls, which increases the risk of a strong bias in the estimated coefficients. Another weakness is the sample selection, which if not representative could not allow for generalization (which is necessary to work the research hypothesis) even if the inference is correct. Yet another weakness is the timeframe. There are only two points of time, which makes inference about time trends or endanger causality.




////////////////////////////////////////////////////////////////////////////////
*** Part2: 
////////////////////////////////////////////////////////////////////////////////


clear all 
set more off
global path = "C:\Users\fx236\Documents\impact_eval\Impact_Eval\PS3_Viktor_Reif"
cd "$path" 
capture log close
log using "ps2.log", replace
use "cardkrueger94.dta", clear


*** 1)
label variable store "Unique store ID"
label variable chain "1=Burger King, 2=KFC, 3=Roys, 4=Wendys"
label variable co_owned "1 if company owned (else 0)"
label variable state "1 if New Jersey; 0 if Pennsylvania"
label variable southj "1 if in south NJ"
label variable centralj "1 if in central NJ"
label variable northj "1 if in northern NJ"
label variable pa1 "1 if in PA, northeast suburbs of Philadelphia"
label variable pa2 "1 if in PA, otherwise"
label variable shore "1 if on NJ shore"
label variable ncalls "Number of call-backs (0 if contacted on first call)"
label variable empft "# full-time employees"
label variable emppt "# part-time employees"
label variable nmgrs "# managers/assistant managers"
label variable wage_st "Starting wage (dollars per hour)"
label variable inctime "Months to usual first raise"
label variable firstinc "Usual amount of first raise (dollars/hour)"
label variable meals "Free/reduced price code (see below)"
label variable open "Hour of opening"
label variable hoursopen "Number hours open per day"
label variable pricesoda "Price of medium soda, including tax"
label variable pricefry "Price of small fries, including tax"
label variable priceentree "Price of entrée, including tax"
label variable nregisters "Number of cash registers in store"
label variable nregisters11 "Number of registers open at 11am"
label variable time "0 if first survey (2/15/1992 – 3/4/1992),1 if second survey (11/5/1992 – 12/31/1992)"

***2
gr tw (kdensity wage_st if time==0, name(g1, replace) nodraw) 
gr tw (kdensity wage_st if time==1, name(g2, replace) nodraw)
gr tw (kdensity empft if time==0, name(g3, replace) nodraw)
gr tw (kdensity empft if time==1, name(g4, replace) nodraw)
graph combine g1 g2 g3 g4
graph display `combine', xsize(10)
graph export exercise_2.pdf, replace
//legend is missing!!!

***3

***3 
* Sorry but it cost a lot of time to see if this table can be replicated but we think it cannot at least with this dataset. WE just used the unique store data from the dataset and created local macros for the other number as we would know them. 
* tab1 ncalls if time == 0, m // this makes no sense to observe the refusals.

*Table outputs for Wave 1
sum store if time == 0
local x31 = strofreal(`r(N)', "%9.0g")
sum store if time == 0 & state == 1
local x32 = strofreal(`r(N)', "%9.0g")
sum store if time == 0 & state == 0
local x33 = strofreal(`r(N)', "%9.0g")

local x41 = strofreal(86.7, "%9.0g")
local x42 = strofreal(90.9, "%9.0g")
local x43 = strofreal(72.5, "%9.0g")

local x21 = strofreal(round(1/`x41'*`x31',1), "%9.0g")
local x22 = strofreal(round(1/`x42'*`x32',1), "%9.0g")
local x23 = strofreal(round(1/`x43'*`x33',1), "%9.0g")

local x11 = strofreal(`x31'+`x21', "%9.0g")
local x12 = strofreal(`x32'+`x22', "%9.0g")
local x13 = strofreal(`x33'+`x23', "%9.0g")


*Table outputs for Wave 2
sum store if time == 1
local x51 = strofreal(`r(N)', "%9.0g")
sum store if time == 1 & state == 1
local x52 = strofreal(`r(N)', "%9.0g")
sum store if time == 1 & state == 0
local x53 = strofreal(`r(N)', "%9.0g")


local x61 = strofreal(6, "%9.0g")
local x62 = strofreal(5, "%9.0g")
local x63 = strofreal(1, "%9.0g")

local x71 = strofreal(2, "%9.0g")
local x72 = strofreal(2, "%9.0g")
local x73 = strofreal(0, "%9.0g")

local x81 = strofreal(2, "%9.0g")
local x81 = strofreal(2, "%9.0g")
local x81 = strofreal(0, "%9.0g")

local x91 = strofreal(1, "%9.0g")
local x92 = strofreal(1, "%9.0g")
local x93 = strofreal(0, "%9.0g")

local x101 = strofreal(`x51'-`x61'-`x71'-`x81'-`x91', "%9.0g")
local x102 = strofreal(`x52'-`x62'-`x72'-`x82'-`x92', "%9.0g")
local x103 = strofreal(`x53'-`x63'-`x73'-`x83'-`x93', "%9.0g")


/*----------------------------------------------------*/
   /* [>   latex document setup   					 <] */
/*----------------------------------------------------*/
texdoc init table_1.tex, replace force
tex \documentclass{article}
tex \usepackage{booktabs}
tex \usepackage{float}
tex \usepackage{array}
tex \begin{document}

/*------------------------------------------------*/
/* [>   Table 1  Sample Design & Response Rate			 <] */
/*------------------------------------------------*/
tex
tex \begin{table}[ht]
tex \centering
tex \caption{SAMPLE DESIGN AND RESPONSE RATES}\label{t_main}
tex \setlength{\tabcolsep}{2.5pt}
tex \begin{tabular}{@{}lccc@{}}
tex \toprule \toprule 
tex \multicolumn{2}{c}{Stores in:} & \\
tex \cmidrule{3-4}
tex & All & MJ & PA \\   \cmidrule{1-4}
tex \emph{WaveI, February 15-March 4, 1992:} \\
tex \\
tex Number of stores in sample frame: & `x11' & `x12' & `x13'\\
tex Number of refusals: & `x21' & `x22' & `x23'\\
tex Number interviewed: & `x31' & `x32' & `x33'\\
tex Response rate (percentage): & `x41' & `x42' & `x43'\\
tex \\
tex \emph{Wave 2, Nocember 5 - December 31, 1992:} \\
tex \\
tex Number of stores in sample frame: & `x51' & `x52' & `x53'\\
tex Number closed: & `x61' & `x62' & `x63'\\
tex Number under rennovation: & `x71' & `x72' & `x73'\\
tex Number temporarily closed: & `x81' & `x82' & `x83'\\
tex Number of refusals: & `x91' & `x92' & `x93'\\
tex Number interviewed: & `x101' & `x102' & `x103'\\
tex \bottomrule
tex \end{tabular}
tex \end{table}


/*----------------------------------------------------*/
   /* [>   End table latex documet   <] */
/*----------------------------------------------------*/
tex \end{document}
texdoc close
*/


//Interpretation: The purpose of this table is to showcase distribution and quality of the sample for the analysis. This sample is survey data and as it can be seen in the table we have a rather complete data set and almost no refusals.






***4
*generate binary variables
gen bk = 0
replace bk = 1 if chain == 1
gen kfc = 0
replace kfc = 1 if chain == 2
gen rr = 0
replace rr = 1 if chain == 3
gen w = 0
replace w = 1 if chain == 4


*Table outputs for panel A 
*1st row
ttest bk, by(state)
local x11 = strofreal(round(`r(mu_1)'*100,.1), "%9.0g")
local x12 = strofreal(round(`r(mu_2)'*100,.1), "%9.0g")
local x13 = strofreal(round(`r(t)',.1), "%9.0g")

ttest kfc, by(state)
local x21 = strofreal(round(`r(mu_1)'*100,.1), "%9.0g")
local x22 = strofreal(round(`r(mu_2)'*100,.1), "%9.0g")
local x23 = strofreal(round(`r(t)', .1), "%9.0g")

ttest rr, by(state)
local x31 = strofreal(round(`r(mu_1)'*100,.1), "%9.0g")
local x32 = strofreal(round(`r(mu_2)'*100,.1), "%9.0g")
local x33 = strofreal(round(`r(t)',.1), "%9.0g")

ttest w, by(state)
local x41 = strofreal(round(`r(mu_1)'*100,.1), "%9.0g")
local x42 = strofreal(round(`r(mu_2)'*100,.1), "%9.0g")
local x43 = strofreal(round(`r(t)',.1), "%9.0g")

ttest co_owned, by(state)
local x51 = strofreal(round(`r(mu_1)'*100,.1), "%9.0g")
local x52 = strofreal(round(`r(mu_2)'*100,.1), "%9.0g")
local x53 = strofreal(round(`r(t)',.1), "%9.0g")

*Panel B (time = 0)
ttest empft if time == 0, by(state)
local x61 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x62 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x63 = strofreal(round(`r(t)',.1), "%9.0g")
local p61 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p62 = strofreal(round(`r(sd_2)',.01), "%9.0g")


gen perc_fte = empft / (empft + emppt)
ttest perc_fte if time == 0, by(state)
local x71 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x72 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x73 = strofreal(round(`r(t)',.1), "%9.0g")
local p71 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p72 = strofreal(round(`r(sd_2)',.01), "%9.0g")

ttest wage_st if time == 0, by(state)
local x81 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x82 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x83 = strofreal(round(`r(t)',.1), "%9.0g")
local p81 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p82 = strofreal(round(`r(sd_2)',.01), "%9.0g")

gen min_wage = 1 if wage_st == 4.25
ttest min_wage if time == 0, by(state)
local x91 = strofreal(round(`r(mu_1)'*100,.1), "%9.0g")
local x92 = strofreal(round(`r(mu_2)'*100,.1), "%9.0g")
local x93 = strofreal(round(`r(t)',.1), "%9.0g")
local p91 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p92 = strofreal(round(`r(sd_2)',.01), "%9.0g")

gen price_meal = priceentree + pricefry + pricesoda
ttest price_meal if time == 0, by(state)
local x101 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x102 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x103 = strofreal(round(`r(t)',.1), "%9.0g")
local p101 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p102 = strofreal(round(`r(sd_2)',.01), "%9.0g")

ttest hoursopen if time == 0, by(state)
local x111 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x112 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x113 = strofreal(round(`r(t)',.1), "%9.0g")
local p111 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p112 = strofreal(round(`r(sd_2)',.01), "%9.0g")

*recuiting bonus
*local x121 = strofreal(round(`r(mu_1)',.1), "%9.0g")
*local x122 = strofreal(round(`r(mu_2)',.1), "%9.0g")
*local x123 = strofreal(round(`r(t)',.1), "%9.0g")
*local p121 = strofreal(round(`r(sd_1)',.01), "%9.0g")
*local p122 = strofreal(round(`r(sd_2)',.01), "%9.0g")



* Panel C (time = 1)
ttest empft if time == 0, by(state)
local x131 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x132 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x133 = strofreal(round(`r(t)',.1), "%9.0g")
local p131 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p132 = strofreal(round(`r(sd_2)',.01), "%9.0g")


ttest perc_fte if time == 0, by(state)
local x141 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x142 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x143 = strofreal(round(`r(t)',.1), "%9.0g")
local p141 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p142 = strofreal(round(`r(sd_2)',.01), "%9.0g")

ttest wage_st if time == 0, by(state)
local x151 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x152 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x153 = strofreal(round(`r(t)',.1), "%9.0g")
local p151 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p152 = strofreal(round(`r(sd_2)',.01), "%9.0g")


ttest min_wage if time == 0, by(state)
local x161 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x162 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x163 = strofreal(round(`r(t)',.1), "%9.0g")
local p161 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p162 = strofreal(round(`r(sd_2)',.01), "%9.0g")

gen min_wage2 = 1 if wage_st == 5.05
ttest min_wage if time == 0, by(state)
local x171 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x172 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x173 = strofreal(round(`r(t)',.1), "%9.0g")
local p171 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p172 = strofreal(round(`r(sd_2)',.01), "%9.0g")


ttest price_meal if time == 0, by(state)
local x181 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x182 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x183 = strofreal(round(`r(t)',.1), "%9.0g")
local p181 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p182 = strofreal(round(`r(sd_2)',.01), "%9.0g")

ttest hoursopen if time == 0, by(state)
local x191 = strofreal(round(`r(mu_1)',.1), "%9.0g")
local x192 = strofreal(round(`r(mu_2)',.1), "%9.0g")
local x193 = strofreal(round(`r(t)',.1), "%9.0g")
local p191 = strofreal(round(`r(sd_1)',.01), "%9.0g")
local p192 = strofreal(round(`r(sd_2)',.01), "%9.0g")

*recruiting bonus
*local x201 = strofreal(round(`r(mu_1)',.1), "%9.0g")
*local x202 = strofreal(round(`r(mu_2)',.1), "%9.0g")
*local x203 = strofreal(round(`r(t)',.1), "%9.0g")
*local p201 = strofreal(round(`r(sd_1)',.01), "%9.0g")
*local p202 = strofreal(round(`r(sd_2)',.01), "%9.0g")

/*----------------------------------------------------*/
   /* [>   latex document setup   					 <] */
/*----------------------------------------------------*/
texdoc init table_2.tex, replace force
tex \documentclass{article}
tex \usepackage{booktabs}
tex \usepackage{float}
tex \usepackage{array}
tex \begin{document}

/*------------------------------------------------*/
/* [>   Table 1  Sample Design & Response Rate			 <] */
/*------------------------------------------------*/

tex \begin{table}[ht]
tex \centering
tex \caption{MEANS OF KEY VARIABLES}\label{t_main}
tex \setlength{\tabcolsep}{2.5pt}
tex \begin{tabular}{@{}lccc@{}}
tex \toprule \toprule
tex \multicolumn{2}{c}{Stores in:} & \\
tex \cmidrule{2-3}
tex & NJ & PA & t \\   \cmidrule{1-3}
tex 1. \emph{Distribution of Store Types (percentages):} \\
tex \\
tex a. Burger King & `x11' & `x12' & `x13'\\
tex b. KFC & `x21' & `x22' & `x23'\\
tex c. Roy Rogers & `x31' & `x32' & `x33'\\
tex d. Wendy's & `x41' & `x42' & `x43'\\
tex e. Company-owned & `x51' & `x52' & `x53'\\
tex \\
tex 2. \emph{Means in Wave 1:} \\
tex \\
tex a. FTE employment & `x61' & `x62' & `x63'\\
tex   & (`p61') & (`p62') &\\
tex b. Percentage full-time employees & `x71' & `x72' & `x73'\\
tex   & (`p71') & (`p72') & \\
tex c. Starting wage & `x81' & `x82' & `x83'\\
tex   & (`p81') & (`p81') & \\
tex d. Wage = 4.25 (percentage) & `x91' & `x92' & `x93'\\
tex   & (`p91') & (`p92') &\\
tex e. Price of full meal Number of refusals: & `x101' & `x102' & `x103'\\
tex   & (`p101') & (`p102') & \\
tex f. Hours open & `x111' & `x112' & `x113'\\
tex   & (`p111') & (`p112') & \\
tex g. Recruiting bonus & `x121' & `x122' & `x123'\\
tex   & (`p121') & (`p122') & \\
tex \\
tex 3. \emph{Means in Wave 2:} \\
tex \\
tex a. FTE employment & `x131' & `x132' & `x133'\\
tex   & (`p131') & (`p132') & \\
tex b. Percentage full-time employees & `x141' & `x142' & `x143'\\
tex   & (`p141') & (`p142') & \\
tex c. Starting wage & `x151' & `x152' & `x153'\\
tex   & (`p151') & (`p152') & \\
tex d. Wage = 4.25 (perecntage) & `x161' & `x162' & `x163'\\
tex   & (`p161') & (`p162') &\\
tex e. Wage = 5.05 (perecntage) & `x171' & `x172' & `x173'\\
tex   & (`p171') & (`p172') &\\
tex f. Price of full meal Number of refusals: & `x181' & `x182' & `x183'\\
tex   & (`p181') & (`p182') & \\
tex g. Hours open & `x191' & `x192' & `x193'\\
tex   & (`p191') & (`p192') &\\
tex h. Recruiting bonus & `x201' & `x202' & `x203'\\
tex   & (`p201') & (`p202') &\\

tex \bottomrule
tex \end{tabular}
tex \end{table}


texdoc close

//Interpretation: The purpose of this table is simply to give the reader an idea what the most important variables in the dataset are and to statistically summarize (distribution and mean) them.
***5

twoway hist wage_st if time==0 | state ==0,percent  bc(blue) ///
|| hist wage_st if time==0 | state ==1, percent  bc(black) ///
legend(off)
twoway hist wage_st if time==1 | state ==0,percent  bc(blue) ///
|| hist wage_st if time==1 | state ==1, percent  bc(black) ///
legend(off)

//Interpretation: They use that figure to visualize the extent and distribution of the variable "initial wage gap". It can be seen that indeed many stores had to increase their wage substantially to reach the new minimum. The variable is laterused as a control in regressions.



***6
***7

//Interpretation: The robust standard errors are very similar. This means that we have independently and identically distributed errors. I can thusly say about the data that there are no latent dynamics in the data that could falsify the statistical significance in the regression.

***8

***9
// Table 3 shows that in NJ stores employment increased after the minimum wage raise, whereas in PA employment decreased. Moreover, in NJ and PA stores that had no intial wage gap (ie unaffacted by the minimum wage) employed less workers (overall decrease of employment). Arguably this decrease was a result of the economic recession of that time. For stores having a intial wage gap, employment increased.







