capture log close
set more off
version 16
log using supplementary_information_C, text replace

/* 
Need to have "esttab" and rwolf installed: 
net install st0085_2.pkg	
ssc install rwolf
*/ 

*Loading data:	
insheet using data/corona_status_March-26.csv, clear
tempfile coronastat26
save `coronastat26'

use data/processed/final_ipsos_cleaned.dta, clear
merge m:1 state using `coronastat26'

est clear

******************
*Extra variables
******************
gen prior_soc_over_self=10-prior_self_over_soc
gen prior_global_over_national=10-prior_national_over_global

label variable corona_prime "COVID-19 reminder"
******************
*Interactions
*****************
gen republicanXcorona_prime=republican*corona_prime
label variable republicanXcorona_prime "Republican $\times$"
gen highincXcorona_prime=highinc*corona_prime
label variable highincXcorona_prime "High inc. $\times$"
gen higheducXcorona_prime=higheduc*corona_prime
label variable higheducXcorona_prime "High educ. $\times$"
gen retirement_ageXcorona_prime=retirement_age*corona_prime
label variable retirement_ageXcorona_prime "Retirement age $\times$"
gen femaleXcorona_prime=female*corona_prime
label variable femaleXcorona_prime "Female $\times$"

********************
*Standardisations
********************
sum luck_unfair_agree [weight=Weightvar], detail
return list
gen zluck_unfair_agree=(luck_unfair_agree-r(mean))/r(sd)

sum luck_determ_agree [weight=Weightvar], detail
return list
gen zluck_determ_agree=(luck_determ_agree-r(mean))/r(sd)

sum prior_soc_over_self [weight=Weightvar], detail
return list
gen zprior_soc_over_self=(prior_soc_over_self-r(mean))/r(sd)

sum compassion_agree [weight=Weightvar], detail
return list
gen zcompassion_agree=(compassion_agree-r(mean))/r(sd)

sum prior_global_over_national [weight=Weightvar], detail
return list
gen zprior_global_over_national=(prior_global_over_national-r(mean))/r(sd)

sum noborders_agree [weight=Weightvar], detail
return list
gen znoborders_agree=(noborders_agree-r(mean))/r(sd)

sum gov_reduce_inequality_agree [weight=Weightvar], detail
return list
gen zgov_reduce_inequality_agree=(gov_reduce_inequality_agree-r(mean))/r(sd)

sum fed_univ_healthcare [weight=Weightvar], detail
return list
gen zfed_univ_healthcare=(fed_univ_healthcare-r(mean))/r(sd)

********************
*Indexes
********************
*Hyp 1 and 2:
gen luck_unfair_determines_index=zluck_unfair_agree+zluck_determ_agree

*Hyp 3:
gen redistribution_healthcare_index=zgov_reduce_inequality_agree+zfed_univ_healthcare

*Hyp 4:
gen solidarity_compassion_index=zcompassion_agree+zprior_soc_over_self

*Hyp 5:
gen noborders_globalprior_index=znoborders_agree+zprior_global_over_national

*****************
*Confirmed Covid-19 infected state per person*100, March 26th
*****************
gen infected=(confirmed/pop2019)*100
label variable infected "Confirmed cases"

sum infected [weight=Weightvar], detail
return list
*Weighted median confirmed cases, 0.01007567
gen high_confirmed26=0
replace high_confirmed26=1 if infected>0.01007567

label variable high_confirmed26 "High confirmed 26"
gen high_confirmed26Xcorona_prime=high_confirmed26*corona_prime
label variable high_confirmed26Xcorona_prime "High confirmed 26*Corona Prime"

*************************************************************************
*PRIMING EFFECTS, HYPOTHESES 1 AND 2 - LUCK, Table S21
*************************************************************************
reg luck_unfair_agree corona_prime, robust
est store col1
reg luck_unfair_agree corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col2

reg luck_determ_agree corona_prime, robust
est store col3
reg luck_determ_agree corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col4

reg luck_unfair_determines_index corona_prime, robust
est store col5
reg luck_unfair_determines_index corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/hyp1hyp2.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(corona_prime age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Ineq avers" "Ineq avers" "Luck determines" "Luck determines" "Index of std" "Index of std") ///
b(3)

*************************************************************************
*PRIMING EFFECTS, HYPOTHESIS 3 - REDISTRIBTUION AND HEALTH CARE, Table S22
*************************************************************************
reg gov_reduce_inequality_agree corona_prime, robust
est store col1
reg gov_reduce_inequality_agree corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col2

reg fed_univ_healthcare corona_prime, robust
est store col3
reg fed_univ_healthcare corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col4

reg redistribution_healthcare_index corona_prime, robust
est store col5
reg redistribution_healthcare_index corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/hyp3.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(corona_prime age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Redistribution" "Redistribution" "Healthcare" "Healthcare" "Index of std" "Index of std") ///
b(3)

*************************************************************************
*PRIMING EFFECTS, HYPOTHESIS 4 - SELFISHNESS, Table S23
*************************************************************************
reg prior_soc_over_self corona_prime, robust
est store col1
reg prior_soc_over_self corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col2

reg compassion_agree corona_prime, robust
est store col3
reg compassion_agree corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col4

reg solidarity_compassion_index corona_prime, robust
est store col5
reg solidarity_compassion_index corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/hyp4.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(corona_prime age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Solidarity" "Solidarity" "Compassion" "Compassion" "Index of std" "Index of std") ///
b(3)

*************************************************************************
*PRIMING EFFECTS, HYPOTHESIS 5 - NATIONALISM, Table S24
*************************************************************************
reg prior_global_over_national corona_prime, robust
est store col1
reg prior_global_over_national corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col2

reg noborders_agree corona_prime, robust
est store col3
reg noborders_agree corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col4

reg noborders_globalprior_index corona_prime, robust
est store col5
reg noborders_globalprior_index corona_prime republican highinc higheduc female age infected child alone urban northeast midwest south [pw=weight], robust
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/hyp5.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(corona_prime age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Glob over nat." "Glob over nat." "No borders" "No borders" "Index of std" "Index of std") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, UNFAIR LUCK, Table S25
*************************************************************************
reg luck_unfair_agree corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg luck_unfair_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg luck_unfair_agree corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg luck_unfair_agree corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg luck_unfair_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/het_unfairluck.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Luck unfair" "Luck unfair" "Luck unfair" "Luck unfair" "Luck unfair") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, LUCK DETERMINES, Table S26
*************************************************************************
reg luck_determ_agree corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg luck_determ_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg luck_determ_agree corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg luck_determ_agree corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg luck_determ_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/het_luck_determ.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Luck determines" "Luck determines" "Luck determines" "Luck determines" "Luck determines") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, REDISTRIBUTION, Table S27
*************************************************************************
reg gov_reduce_inequality_agree corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg gov_reduce_inequality_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg gov_reduce_inequality_agree corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg gov_reduce_inequality_agree corona_prime femaleXcorona_prime  republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg gov_reduce_inequality_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/het_gov_reduce_inequality.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Redistr" "Redistr" "Redistr" "Redistr" "Redistr") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, HEALTHCARE, Table S28
*************************************************************************
reg fed_univ_healthcare corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg fed_univ_healthcare corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg fed_univ_healthcare corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg fed_univ_healthcare corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg fed_univ_healthcare corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/het_healthcare.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Health care" "Health care" "Health care" "Health care" "Health care") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, SOLIDARITY, Table S29
*************************************************************************
reg prior_soc_over_self corona_prime  republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg prior_soc_over_self corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg prior_soc_over_self corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg prior_soc_over_self corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg prior_soc_over_self corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/heterogeneitysol.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Society over self" "Society over self" "Society over self" "Society over self" "Society over self") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, COMPASSION, Table S30
*************************************************************************
reg compassion_agree corona_prime  republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg compassion_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg compassion_agree corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg compassion_agree corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg compassion_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/het_compassion.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Compassion" "Compassion" "Compassion" "Compassion" "Compassion") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, GLOBAL FIRST, Table S31
*************************************************************************
reg prior_global_over_national corona_prime  republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg prior_global_over_national corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg prior_global_over_national corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg prior_global_over_national corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg prior_global_over_national corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/heterogeneity_prior_global.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("Global" "Global" "Global" "Global" "Global") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, NO BORDERS, Table S32
*************************************************************************
reg noborders_agree corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg noborders_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg noborders_agree corona_prime higheducXcorona_prime  republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg noborders_agree corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg noborders_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age infected child alone urban northeast midwest south [pw=weight], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

esttab col1 col2 col3 col4 col5 using tables/het_noborders.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime retirement_age female highinc republican higheduc child alone urban infected northeast midwest south _cons) ///
label mtitle("No borders" "No borders" "No borders" "No borders" "No borders") ///
b(3)
