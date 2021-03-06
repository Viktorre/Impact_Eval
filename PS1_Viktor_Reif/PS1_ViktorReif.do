////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Problem Set 1 - due 14/11/2021 23:59 
/ send to charlotte.robert@awi.uni-heidelberg.de 
/ with the format PS1_name.do 
////////////////////////////////////////////////////////////////////////////////

/ Author: Charlotte Robert
/ Heidelberg University - Winter Semester 2021
/ Student version
*/
////////////////////////////////////////////////////////////////////////////////
// Grade: /10
////////////////////////////////////////////////////////////////////////////////

/* !!!!!!!!!!!!!!!!!!!!!!!! Remember:
To execute a do-file:
- highligh the command on your do
- press Ctrl + d or click on the button "Execute"
Do NOT copy-paste in the window command 
*/

////////////////////////////////////////////////////////////////////////////////
*** Part 1 (5pt): Working with Stata  
/*
Answer questions directly on the do file
Make your code visible in your answer to each question: your results should be replicable using your dofile only. 
Using slash star, copy all tables on the do file. Export your graphs and join them to your email when submitting your PS. 
You may need to search for commands that were not yet introduced in the tutorial - learning to Google questions is an essential skill! 
0.5pt per correct answer, 0.25 if partly correct.
*/
////////////////////////////////////////////////////////////////////////////////
// Set your working directory 
cd "C:\Users\fx236\Documents\impact_eval\Impact_Eval\PS1_Viktor_Reif"

//Load the data - we are using data directly available in stata
sysuse nlsw88.dta , clear
describe, fullnames //have a look at the variables in the data 

// Q1: How many observations are there? How many variables? How many individuals live in the south? 
describe
/*
As seen in table below, we have 2246 observations and 17 variables.
Contains data from C:\Program Files\Stata16\ado\base/n/nlsw88.dta
  obs:         2,246                          NLSW, 1988 extract
 vars:            17                          1 May 2018 22:52
                                              (_dta has notes)
--------------------------------------------------------------------------------------
              storage   display    value
variable name   type    format     label      variable label
--------------------------------------------------------------------------------------
idcode          int     %8.0g                 NLS id
age             byte    %8.0g                 age in current year
race            byte    %8.0g      racelbl    race
married         byte    %8.0g      marlbl     married
never_married   byte    %8.0g                 never married
grade           byte    %8.0g                 current grade completed
collgrad        byte    %16.0g     gradlbl    college graduate
south           byte    %8.0g                 lives in south
smsa            byte    %9.0g      smsalbl    lives in SMSA
c_city          byte    %8.0g                 lives in central city
industry        byte    %23.0g     indlbl     industry
occupation      byte    %22.0g     occlbl     occupation
union           byte    %8.0g      unionlbl   union worker
wage            float   %9.0g                 hourly wage
hours           byte    %8.0g                 usual hours worked
ttl_exp         float   %9.0g                 total work experience
tenure          float   %9.0g                 job tenure (years)
--------------------------------------------------------------------------------------
Sorted by: idcode
*/
codebook south
/*
As seen in table below, there are 942 people living in the osuth, as they have a "1" enocded in the variable south.

--------------------------------------------------------------------------------------
south                                                                   lives in south
--------------------------------------------------------------------------------------

                  type:  numeric (byte)

                 range:  [0,1]                        units:  1
         unique values:  2                        missing .:  0/2,246

            tabulation:  Freq.  Value
                         1,304  0
                           942  1
*/

// Re-label the variable "south" so that the value "1" is labeled "yes" and "0" is labeled "no".
tostring south, replace
replace south = "no" if south == "0" 
replace south = "yes" if south == "1"
// Q2: Give the mean, the sd, the 10th percentile, the 25th percentile and the median of the hourly wage in this country. 
codebook wage
/*
mean = 7.77, sd = 5.76, 10% = 3.22, 25% = 4.26, median = 6.27. all rounded. See table below for exact numbers.
					
wage				hourly	wage
					

	type:	numeric (float)

	range:	[1.0049518,40.74659]	units:  1.000e-07
	unique values:	967	missing .:  0/2,246

	mean:	7.76695
	std. dev:	5.75552

	percentiles:	10%       25%	50%       75%       90%
		3.22061   4.25926	6.27227   9.59742   12.7778
*/

// Q3: Generate a new variable "wage_group" that takes the value "1" if the individual earns more (>=) 
// than the average hourly wage in the sample, and "0" if not (<). Don't forget to label the variable and its values. 
mean wage
gen wage_group = .
replace wage_group = 1 if wage >= 7.76695
replace wage_group = 0 if wage < 7.76695
label define wage_group 1 "above average wage"
label define wage_group 0 "below average wage", add
label variable wage_group "wage group assignment above/below average" 
// How many individuals earn more than the mean? Which profession is the most frequent in the "richer" group? 
// In the "poorer" group? Give frequencies and percentage shares. 
codebook wage_group
/* 814 indivduals are in the richer group, 1432 in the poorer group. See table below:

wage_group	wage	group	assignment above/below	average
				

type:	numeric (float)

range:	[0,1]		units:  1
unique values:	2		missing .:  0/2,246

tabulation:	Freq.  Value
	1,432  0
	814  1
*/
bysort wage_group: tabulate occupation
/* in the richter group (=1) the most common occupation is P"rofessional/technical" with 222 individualsuals making 27.34% of all members in this group. For the poorer group (=0) the most common occupation is "Sales" with 518 individuals making 36.35% of the group's total. See the table below for more details:
----------------------------------------------------------------------
-> wage_group = 0

            occupation |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
Professional/technical |         95        6.67        6.67
        Managers/admin |        106        7.44       14.11
                 Sales |        518       36.35       50.46
    Clerical/unskilled |         69        4.84       55.30
             Craftsmen |         36        2.53       57.82
            Operatives |        208       14.60       72.42
             Transport |         28        1.96       74.39
              Laborers |        259       18.18       92.56
         Farm laborers |          9        0.63       93.19
               Service |         12        0.84       94.04
     Household workers |          2        0.14       94.18
                 Other |         83        5.82      100.00
-----------------------+-----------------------------------
                 Total |      1,425      100.00

----------------------------------------------------------------------
-> wage_group = 1

            occupation |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
Professional/technical |        222       27.34       27.34
        Managers/admin |        158       19.46       46.80
                 Sales |        208       25.62       72.41
    Clerical/unskilled |         33        4.06       76.48
             Craftsmen |         17        2.09       78.57
            Operatives |         38        4.68       83.25
              Laborers |         27        3.33       86.58
               Farmers |          1        0.12       86.70
               Service |          4        0.49       87.19
                 Other |        104       12.81      100.00
-----------------------+-----------------------------------
                 Total |        812      100.00


*/   
// Q4: Drop individuals for which there is missing information in the variables industry, occupation, grade, union, hours and tenure !!!using a loop!!!. 
foreach var in occupation grade union hours tenure {
	drop if missing(`var')
	}
	
// Q5: According to this sample, is there a !!significant!! difference in hourly wage between married and single people? 
// Is there also a significant difference in terms of usual hours worked?
// Can you think of an explanation for these results?  
ttest hours, by(married)
// Yes, the ttest finds a significant difference in hours worked between married True/False in the sample.
// A possible explanation could be that married people are more likely to have children, which is time consuming and many parents therefore reduce their work hours.

// Q6: Is there a significant difference between people that were never married and those that were? 
// Are these results in line with what you found for Q5? How many individuals are divorced?
ttest hours, by(never_married)
// Yes, the ttest finds a significant difference in hours worked between never_married True/False in the sample.
codebook id if married == 0 & never_married == 0
// There are 443 individuals in the sample that are not married at the moment but have been married before. Ie they are divored.
// Q7: Check the distribution of hourly wages in this country using a graph. What can you say? 
histogram wage
// Hourly wages seem to follow a rather normal distribution with a positve skew. I expected a cleaner cutoff on the left hand side of the distribution with many people earning the same low wage and nobody below, but this is not the case. I assume 1 wage unit equals 10$. Therefore, there are only a few indivuduals earning the minimum wage - if there is any. 
// Check how many individuals in the sample earn more than 40$ per hour. Which occupation 
// is the most frequent among these individuals? 
codebook idcode if wage>4
tabulate occupation if wage>4
// Assuming than 1 unit of wage equals 10$, there are 1557 observations with a wage higher than 40$. The most common occupation in this case is "Sales".
 
// Q8: Regress hourly wages on marriage status, and interpret the coefficient. 
regress married wage
// A wage increase by one unit (I assume one unit is 10$) decreaes the expected probability that this indivual is married by 0.6%. This relation is only siginificat at the 5%-level.
// Q9: In a second regression, regress hourly wages on marriage status, controlling 
// for usual hours worked. What can you say about the results? 
regress married wage hours
// When controlling for hours worked, the regression analysis finds no significant relation between wage and married in this sample. 
// Q10: Create a graph that represents the relationship between the average hourly wage and the 
// average usual hours worked for each occupation. (Hint: collapse function might be useful here) 
preserve 
collapse avg_wage = wage avg_hours = hours, by(occupation)
scatter avg_wage avg_hours 
restore
////////////////////////////////////////////////////////////////////////////////
*** Part 2 (5pt): Questions about Baird et al. 2011 - Cash or conditions? Evidence 
*** from a cash transfer experiment
*** Answer directly in the dofile 
////////////////////////////////////////////////////////////////////////////////

// Q1 (1pt): What is the research question the authors address in their paper?
//The paper assesses the question whether imposing conditions on the recipients of cash transfer programs in third world countries has any impacts on the programs' outcome.
// Why is it relevant? 
// Both CCT (conditional cash transfer) and UCT (unconditional cash transfer) are commonly used in development aid for third world countries. For both there is cientific evidence that they significantly improve the receiving beneficiaries situation. Hence, the authors want to sassess which works better in a tailored experiment (as this a question that is not yet fully answered by research).
// Q2 (2pt): Explain the difference between conditional cash transfers and unconditional cash transfers.
//The UCT gives money to poor households without any conditions. The CCT ties the money transfer to certain condtions which the households need to fulfill in order to receive the transfer. In the case of this study the condition is school attendance of the respective houshold's children. 
// What are the advantages and disadvantages of both transfers? (2pts)
//The advantages of UCT are that they are easy to administrate/distribute, they are well established and are less variant in outcome compared to CCT, whose conditions could lead to yet unknown effects. The disadvantage of UCT is that there might be opportunity costs when using them, as there is research that claims that using CCT would be better (eg by incentivising certain behaviour through conditions).
//The advantages of CCT are that they are generally more accepted by middle/higher class voters (net transfers payers). Also, the conditions in CCT have the potential to countersteer an underinvestment in education/health. Another advantage is that - as some researcher claim - CCT outperforms UCT, meaning that with the same resources households could be helped to improve their situation even more when usning CCT instead of UCT. The disadvantages are that CCT waste more resources on administration and the imposed conditions' effects on households are not yet fully known - and therefore a risk.
// Q3 (2pt): According to the authors, why is there a significant reduction in teen pregnancies and marriage in 
// the UCT arm but no significant effect in the CCT arm?  
//UCT lead to more financial resources in the receiving households. These resources are at least partly invested in the childrens' education, which increases their school attendance and total schooling years. This development keeps children for a longer time away from transitioning to aduldts, which thusly leads to later marriages and fewer teen pregnancies. 
//For CCT, the experiment could not find a significant reduction in teen pregnancies and marriage. In the CCT groups, the households that had cases of teen pregnancies/marriage were commonly the ones that received no money from the program, because their children dropped out of school when the program started. In the CCT group exactly these households which did not fulfill the attendance criterion showed almost all cases of teen pregnancies and marriage. This means that the girls that dropped out of school and thusly failed the criterion of the CCT program were the ones who married/got children early. Hence, the effect of UCT, ie more money leads to higher school attendance and thusly to less teen pregnancies/marriage, could no be harnessed by those "dropout" households. The effect on the girls that stayed in school was negligable. In total, the behaviour and outcome of these two groups - namely the dropouts and non-dropouts - leads to no significant reduction in the CCT group.