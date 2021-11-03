////////////////////////////////////////////////////////////////////////////////
/* Impact Evaluations for Social Programs

////////////////////////////////////////////////////////////////////////////////
/ Lab Session 1: Introduction to Stata
////////////////////////////////////////////////////////////////////////////////

/ Author: Charlotte Robert + Alexandra Avdeenko
/ Heidelberg University - Winter Semester 2021
/ Student version
In this tutorial, we will generate our own dataset and look at the most helpful 
commands. You can type in your commands in the box below the screen, but it is 
better to store them in a do-file. Then you can share your code with others or 
use it again later. */
////////////////////////////////////////////////////////////////////////////////


/* !!!!!!!!!!!!!!!!!!!!!!!! Remember:
To execute a do-file:
- highligh the command on your do
- press Ctrl + d or click on the button "Execute"
Do NOT copy-paste in the window command 
*/


////////////////////////////////////////////////////////////////////////////////
*** Quick starter guide
////////////////////////////////////////////////////////////////////////////////

 
clear all //clears your memory and everything in it
set more off //if many commands follow, you oftentimes do not want to press any keys to continue


////////////////////////////////////////////////////////////////////////////////
*** Setting your working environment 
////////////////////////////////////////////////////////////////////////////////


cd "C:\Users\Robert\Dropbox\2.1_Heildeberg\2_Exercises\Tutorial 1" //sets you directory: where Stata will look for files and save files 
dir //view the files in your directory

*Store your results in a log file (useful to keep track of your work and results):

capture log close
log using "test.log", replace


////////////////////////////////////////////////////////////////////////////////
** Basic description of data 
////////////////////////////////////////////////////////////////////////////////


*Creation of the dataset
set obs 100 //Set the number of observations to 100

*Let's generate 100 normally distributed random numbers with a mean of 1000 and an std of 500:
gen var1 = rnormal(1000, 500) in 1/100 

*Then generate a second normally distributed variable with a mean of 3000 and an std of 1000, your turn:
gen var2 = rnormal(3000, 1000) in 1/100

*Let's look at our data. Mean and Std correspond to the parameters set before.
summarize var1

*However, it would be interesting to have a bit more information about the variable 
summarize var1, detail
*The detail behind the "," is an option. Most Stata commands allow for option. If you want to check them out for e. g. summarize: 
help summarize //the help command directs you to the user guide of each command 

*Let's look at var2:
sum var2, d //stata also allows abbreviations if the abbreviation is unique

list var1 var2 in 1/20 //look at the first 20 observations of your variables

*We would like to have a global view of our dataset. Stata allows to scroll through the dataset:
browse //look at your dataset

*We can also select what we want to see: 
browse var1 

describe //lets you see your variables and their types. E.g. float is for numbers, string is for characters (words). 
codebook //This command produces a 'codebook' of the dataset in memory. This is especially useful when we are using external datasets 
* so that we can make sure the data has been extracted correctly. Also offers useful summary of the variable

tab var1 //shows the variable on the screen, but similar values are not shown twice [tab= tabulate]

count //this command counts the number of observations in the dta. You can also see it directly on the screen (Observations)

mdesc //check for missings


////////////////////////////////////////////////////////////////////////////////
*** Data manipulation - the basics 
////////////////////////////////////////////////////////////////////////////////

*We already saw how to generate new variables. Now it's your turn to create a variable that is the sum of our two variables: 
gen test = var1 + var2

*Not so useful, let's drop it:
drop test //deletes the variable

*Generate a variable entirely filled with missing values 
gen test = . 
*Alternative way of dropping variables:
keep var1 var2 //keeps only those, drops test again.

*** Using conditions:
*Creating a variable of missings again:
gen var3 = .
*Replace the values taken by our variable based on a condition: 
replace var3 = 2 if var3==. //replaces all the missing values with 2
replace var3 = 1 in 51/100 //replaces the last 50 obs of test with a 1 - !!!!not good practice but useful here for the simulation
*Rename our variable:
rename var3 sex 

*Labels are very useful to add descriptions. You can label variables, and values taken by variables:
label define sex1 1 "male"
label define sex1 2 "female", add
label variable sex "Sex of respondent" 
tab sex
label values sex sex1
tab sex

*Now we gerenate an income variable which corresponds to var1 for females and var2 for males:
gen income  = var1
replace income = var2 if sex == 1 // the if condition is frequently used and very important

*Label your income variable:
label variable income "Income of respondent"

*Let's look at our income variable
summarize income
codebook income
tab income

*Notice any issue? Some values are negative. Let's get rid of them:
drop if income < 0

*Who earns more: men or women? 
bysort sex: sum income //we can now see that men are earning more than women on average.
//bysort command is very useful: Most Stata commands allow the by prefix, which repeats the command for each group of observations for which the values of the variables in varlist are the same. "bysort" tells stata to first sort the data by gender


*Your turn: generate or change the income variable so that women earn more than men on average
replace income = var1 if sex ==1
replace income = var2 if sex ==2 
*Check your results: 
bysort sex: sum income //we can now see that men are earning more than women on average.

*Let's check how gender and income are correlated:
corr sex income
pwcorr sex income //this command keeps missing values when computing the correlation

*Use the help command to display stars when computing correlations:
pwcorr sex income, star(0.5)


*** Conditional subsetting 
* We now only want to keep income above a certain threshold: 
keep if income >= 500
*And below a certain threshold: 
keep if income <= 3000


*** Looping - very useful  
*Here we create a LOCAL `i', it is only internally used within the loop: 
forvalues i = 1/2 {

gen income_`i' = income if sex==`i'

}

drop income_* //the star represents an arbitrary ending - Stata deletes every variables of the form "income_..."


*For more interactions, we need a second local that is based within the loop.
local j = 1
forvalues i = 1/2 {

gen income_`i' = income if sex==`j'

local j = `j'+1 //for an increase of +1, you could also write: local ++example
}

drop income_*



////////////////////////////////////////////////////////////////////////////////
*** Graphs
////////////////////////////////////////////////////////////////////////////////
** Graphs are a great way to get a sense of the data and the relations between the variables

scatter income sex //this command graphs a scatter plot 
//The graph will open up in a new window 

histogram income 
// This command creates a histogram of the variable specified 
// The image will open in a new window 

histogram income if sex==1 & income <2000

histogram income, by(sex)

graph bar (mean) income, over(sex) 


//install package to make graphs look better: https://github.com/asjadnaqvi/Stata-schemes 

set scheme plotplain, permanently
help scheme files 



////////////////////////////////////////////////////////////////////////////////
*** Merging datasets
////////////////////////////////////////////////////////////////////////////////

** Creating aan identification key:
gen id = _n //we create a new variable that will uniquely identify each row (each observation)
*We now want to merge our data with the dataset occupation.dta, which uses the same identification key and has data on the professional occupations of our individuals:
sort id //always sort both datasets that need to be merged by the common identifier 

merge 1:1 id using occupation // merge 1:1 tells stata that each row in dataset A will be uniquely matched to one row in dataset B, using the common "id" key
// merge m:1 (many to one) is also possible. will add the information from dataset B onto the rows of dataset A with the same common identifier
// merge 1:m should only be used in very special cases 
browse // look at what your data looks like now

*Notice the new variable _merge. It indicates which rows were matched or not matched. Here, everything was matched, we can drop the variable:
drop _merge

*How many female engineers are in the dataset? 
tab occupation sex 
tab occupation sex, cell // relative frequency of each cell
tab occupation sex, col // conditional probability: report relative frequency within its column of each cell

*Another useful command is the collapse command: 
help collapse
preserve
collapse (mean) income_avg = income, by(sex)
restore




*Save the dataset
save "test.dta", replace //saves your dataset in a .dta format. You can also give a specific path if you would like to save your data elsewhere than in the directory "D:\data\test.dta". 
//Replace tells stata to overwrite the existing file with the same name
use "test.dta", clear //opens your dataset
use test, clear //alternative way to open .dta dataset
erase "test.dta" //erases it if its not worth storing.


log close 


