capture log close
set more off
version 16
	
log using mturklab_cleaning_release, text replace
	
*Loading data:	
use ../processed/mturklab_release.dta, clear
est clear

*Generating indicator for republican. "Do not prefer to answer" to missing.
gen republican=1
replace republican=0 if political>1
replace republican=. if political==4

*"Do not prefer to answer" to missing. Imputing highest value (1.5)
replace income=. if income==25
replace income=375000 if income==250000

*Indicators for educ (at least some college), age and income (latter two based on sample medians)
gen higheduc=1 if educ==4
replace higheduc=0 if educ<4
label variable higheduc "High educ."

gen highage=1 if age>35
replace highage=0 if age<36
replace highage=. if age==.
label variable highage "High age" 

gen highinc=1 if income>52500 
replace highinc=0 if income<52501
replace highinc=. if income==.
label variable highinc "High inc." 

*Flipping variables
gen priority_society=10-priority_self
gen agree_unfair=6-disagree_unfair

*Indicator for agreeing that luck inequality is unfair
gen agree=1 if agree_unfair>3
replace agree=0 if agree_unfair<4

*Indicator for not prioritizing self over society.
gen societyfirst=1
replace societyfirst=0 if priority_society<5

save ../processed/mturklab_cleaned, replace
