capture log close
set more off
version 16

	
log using mturklab_analysis, text replace
	
*Loading data:	
use data/processed/mturklab_cleaned.dta, clear
est clear

***************************************************

reg societyfirst republican highinc higheduc female highage, robust
est store col1

reg agree republican highinc higheduc female highage, robust
est store col2

reg share_self republican highinc higheduc female highage, robust
est store col3

reg share_self societyfirst agree republican highinc higheduc female highage, robust
est store col4

esttab col1 col2 col3 col4 using tables/mturklab_indic.tex, ///
	replace star(* 0.10 ** 0.05 *** 0.01) booktabs r2 se ///
	keep(societyfirst agree republican highinc higheduc highage female _cons) ///
	label mtitle("Solidarity" "Luck unfair" "Amount to self" "Amount to self") ///
	b(3)
