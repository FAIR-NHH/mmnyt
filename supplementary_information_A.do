capture log close
set more off
version 16
log using supplementary_information_A, text replace

/* 
Need to have "esttab" and rwolf installed: 
net install st0085_2.pkg	
ssc install rwolf
*/ 
	
*Loading data:
insheet using data/corona_status_March-28.csv, clear
tempfile coronastat
save `coronastat'
use data/processed/ipsos_mmnyt_processed_release, clear
merge m:1 state using `coronastat'

*set scheme plainplot  xlab(,nogrid) ylab(,nogrid) 
est clear

******************
*Extra variables
******************
gen prior_soc_over_self=10-prior_self_over_soc
gen prior_global_over_national=10-prior_national_over_global

*gen prior_national=.
*replace prior_national=1 if prior_national_over_global>5 & prior_national_over_global!=.
*replace prior_national=0 if prior_national_over_global<6

******************
*Interactions
*****************
gen republicanXcorona_prime=republican*corona_prime
label variable republicanXcorona_prime "Republican $\times$"
gen highincXcorona_prime=highinc*corona_prime
label variable highincXcorona_prime "High inc. $\times$"
gen higheducXcorona_prime=higheduc*corona_prime
label variable higheducXcorona_prime "High educ. $\times$"
gen femaleXcorona_prime=female*corona_prime
label variable femaleXcorona_prime "Female $\times$"
gen retirement_ageXcorona_prime=retirement_age*corona_prime
label variable retirement_ageXcorona_prime "Retirement age $\times$"

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

sum prior_national_over_global [weight=Weightvar], detail
return list
gen zprior_national_over_global=(prior_national_over_global-r(mean))/r(sd)

sum noborders_agree [weight=Weightvar], detail
return list
gen znoborders_agree=(noborders_agree-r(mean))/r(sd)

sum gov_reduce_inequality_agree [weight=Weightvar], detail
return list
gen zgov_reduce_inequality_agree=(gov_reduce_inequality_agree-r(mean))/r(sd)

sum fed_univ_healthcare [weight=Weightvar], detail
return list
gen zfed_univ_healthcare=(fed_univ_healthcare-r(mean))/r(sd)

*****************
*Confirmed Covid-19 infected state per person*100, March 28th
*****************
gen infected_march28=(confirmed/pop2019)*100
label variable infected_march28 "Confirmed cases"

sum infected_march28 [weight=Weightvar], detail
return list
*Weighted median confirmed cases, 0.01645803
gen high_confirmed=0
replace high_confirmed=1 if infected_march28>0.01645803

gen infected_march28Xcorona_prime=infected_march28*corona_prime
label variable infected_march28Xcorona_prime "Confirmed cases $\times$"

label variable high_confirmed "High confirmed"
gen high_confirmedXcorona_prime=high_confirmed*corona_prime
label variable high_confirmedXcorona_prime "High confirmed $\times$"

*For descriptives table
gen infected_march28_des=(confirmed/pop2019)*100000


*************************************************************************
*DESCRIPTIVES, Table S1
*************************************************************************
preserve
drop if luck_determ_agree==.

table GDW6 if corona_prime==0
table GDW6 if corona_prime==1
table GDW6

sum income if corona_prime==0, detail
sum income if corona_prime==1, detail
sum income, detail

gen income_imputed=income
replace income_imputed=375000 if income_imputed==250000
sum income_imputed if corona_prime==0
sum income_imputed if corona_prime==1
sum income_imputed

sum highinc if corona_prime==0, detail
sum highinc if corona_prime==1, detail
sum highinc, detail

sum higheduc if corona_prime==0, detail
sum higheduc if corona_prime==1, detail
sum higheduc, detail

sum female if corona_prime==0, detail
sum female if corona_prime==1, detail
sum female, detail

sum age if corona_prime==0, detail
sum age if corona_prime==1, detail
sum age, detail

sum retirement_age if corona_prime==0, detail
sum retirement_age if corona_prime==1, detail
sum retirement_age, detail

sum child if corona_prime==0, detail
sum child if corona_prime==1, detail
sum child, detail

sum alone if corona_prime==0, detail
sum alone if corona_prime==1, detail
sum alone, detail

sum urban if corona_prime==0, detail
sum urban if corona_prime==1, detail
sum urban, detail

sum northeast if corona_prime==0, detail
sum northeast if corona_prime==1, detail
sum northeast, detail

sum midwest if corona_prime==0, detail
sum midwest if corona_prime==1, detail
sum midwest, detail

sum west if corona_prime==0, detail
sum west if corona_prime==1, detail
sum west, detail

sum south if corona_prime==0, detail
sum south if corona_prime==1, detail
sum south, detail

sum infected_march28_des if corona_prime==0, detail
sum infected_march28_des if corona_prime==1, detail
sum infected_march28_des, detail

sum high_confirmed if corona_prime==0, detail
sum high_confirmed if corona_prime==1, detail
sum high_confirmed, detail

restore

*************************************************************************
*PRIMING EFFECTS, MAIN OUTCOMES, Table S2
*************************************************************************

reg zprior_soc_over_self corona_prime [pw=Weightvar], robust
est store col1
reg zprior_soc_over_self corona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
est store col2

reg zprior_national_over_global corona_prime [pw=Weightvar], robust
est store col3
reg zprior_national_over_global corona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
est store col4

reg zluck_unfair_agree corona_prime [pw=Weightvar], robust
est store col5
reg zluck_unfair_agree corona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/priming.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(corona_prime retirement_age female highinc republican higheduc child alone urban high_confirmed northeast midwest south _cons) ///
label mtitle("Solidarity (std.)"  "Solidarity (std.)"  "Nationalism (std.)" "Nationalism (std.)" "Luck unfair (std.)" "Luck unfair (std.)") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, SOLIDARITY, Table S3
*************************************************************************

reg zprior_soc_over_self corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1=r(estimate)
estadd scalar sd1=r(se)
est store col1

reg zprior_soc_over_self corona_prime highincXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg zprior_soc_over_self corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg zprior_soc_over_self corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg zprior_soc_over_self corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

reg zprior_soc_over_self corona_prime high_confirmedXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + high_confirmedXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/heterogeneityzsol.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interac.)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime high_confirmedXcorona_prime _cons) ///
label mtitle("Solidarity (std.)" "Solidarity (std.)" "Solidarity (std.)" "Solidarity (std.)" "Solidarity (std.)" "Solidarity (std.)") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, NATIONALISM, Table S4
*************************************************************************
reg zprior_national_over_global corona_prime  republicanXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg zprior_national_over_global corona_prime highincXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg zprior_national_over_global corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg zprior_national_over_global corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg zprior_national_over_global corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

reg zprior_national_over_global corona_prime high_confirmedXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + high_confirmedXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/heterogeneity_znationalism.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder+ Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime high_confirmedXcorona_prime _cons) ///
label mtitle("Nationalism (std.)" "Nationalism (std.)" "Nationalism (std.)" "Nationalism (std.)" "Nationalism (std.)" "Nationalism (std.)") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, LUCK UNFAIR, Table S5
*************************************************************************
reg zluck_unfair_agree corona_prime republicanXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg zluck_unfair_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg zluck_unfair_agree corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg zluck_unfair_agree corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg zluck_unfair_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

reg zluck_unfair_agree corona_prime high_confirmedXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + high_confirmedXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/het_zunfairluck.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder + Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime high_confirmedXcorona_prime _cons) ///
label mtitle("Luck unfair (std.)" "Luck unfair (std.)" "Luck unfair (std.)" "Luck unfair (std.)" "Luck unfair (std.)" "Luck unfair (std.)") ///
b(3)

*************************************************************************
*ASSOCIATIONS, REDISTRIBUTION/MORAL VIEWS, Table S6
*************************************************************************
reg zgov_reduce_inequality_agree zprior_soc_over_self [pw=Weightvar], robust
est store col1
reg zgov_reduce_inequality_agree zprior_soc_over_self i.State_Recoded [pw=Weightvar], robust
est store col2
reg zgov_reduce_inequality_agree zprior_soc_over_self republican highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar], robust
est store col3

reg zgov_reduce_inequality_agree zprior_national_over_global [pw=Weightvar], robust
est store col4
reg zgov_reduce_inequality_agree zprior_national_over_global i.State_Recoded [pw=Weightvar], robust
est store col5
reg zgov_reduce_inequality_agree zprior_national_over_global republican highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar], robust
est store col6

reg zgov_reduce_inequality_agree zluck_unfair_agree [pw=Weightvar], robust
est store col7
reg zgov_reduce_inequality_agree zluck_unfair_agree i.State_Recoded [pw=Weightvar], robust
est store col8
reg zgov_reduce_inequality_agree zluck_unfair_agree republican highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar], robust
est store col9

esttab col1 col2 col3 col4 col5 col6 col7 col8 col9 using tables/corrredistr.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(zprior_soc_over_self zprior_national_over_global zluck_unfair_agree republican highinc higheduc female retirement_age high_confirmed child alone urban _cons) ///
label mtitle("Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)") ///
b(3)

*************************************************************************
*ASSOCIATIONS, HEALTH CARE/MORAL VIEWS, Table S7
*************************************************************************
reg zfed_univ_healthcare zprior_soc_over_self [pw=Weightvar], robust
est store col1
reg zfed_univ_healthcare zprior_soc_over_self i.State_Recoded [pw=Weightvar], robust
est store col2
reg zfed_univ_healthcare zprior_soc_over_self republican highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar], robust
est store col3

reg zfed_univ_healthcare zprior_national_over_global [pw=Weightvar], robust
est store col4
reg zfed_univ_healthcare zprior_national_over_global i.State_Recoded [pw=Weightvar], robust
est store col5
reg zfed_univ_healthcare zprior_national_over_global republican highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar], robust
est store col6

reg zfed_univ_healthcare zluck_unfair_agree [pw=Weightvar], robust
est store col7
reg zfed_univ_healthcare zluck_unfair_agree i.State_Recoded [pw=Weightvar], robust
est store col8
reg zfed_univ_healthcare zluck_unfair_agree republican highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar], robust
est store col9

esttab col1 col2 col3 col4 col5 col6 col7 col8 col9 using tables/corrhealth.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(zprior_soc_over_self zprior_national_over_global zluck_unfair_agree republican highinc higheduc female retirement_age high_confirmed child alone urban _cons) ///
label mtitle("Health care (std.)"  "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)") ///
b(3)

*************************************************************************
*ASSOCIATIONS, REDISTRIBUTION/MORAL VIEWS, republicans, Table S8
*************************************************************************
reg zgov_reduce_inequality_agree zprior_soc_over_self [pw=Weightvar] if republican==1, robust
est store col1
reg zgov_reduce_inequality_agree zprior_soc_over_self i.State_Recoded [pw=Weightvar]  if republican==1, robust
est store col2
reg zgov_reduce_inequality_agree zprior_soc_over_self highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar]  if republican==1, robust
est store col3

reg zgov_reduce_inequality_agree zprior_national_over_global [pw=Weightvar]  if republican==1, robust
est store col4
reg zgov_reduce_inequality_agree zprior_national_over_global i.State_Recoded [pw=Weightvar]  if republican==1, robust
est store col5
reg zgov_reduce_inequality_agree zprior_national_over_global highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar]  if republican==1, robust
est store col6

reg zgov_reduce_inequality_agree zluck_unfair_agree [pw=Weightvar] if republican==1, robust
est store col7
reg zgov_reduce_inequality_agree zluck_unfair_agree i.State_Recoded [pw=Weightvar]  if republican==1, robust
est store col8
reg zgov_reduce_inequality_agree zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar]  if republican==1, robust
est store col9

esttab col1 col2 col3 col4 col5 col6 col7 col8 col9 using tables/corrredistrrep.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(zprior_soc_over_self zprior_national_over_global zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban _cons) ///
label mtitle("Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)") ///
b(3)

*************************************************************************
*ASSOCIATIONS, REDISTRIBUTION/MORAL VIEWS, non-republicans, Table S9
*************************************************************************
reg zgov_reduce_inequality_agree zprior_soc_over_self [pw=Weightvar] if republican==0, robust
est store col1
reg zgov_reduce_inequality_agree zprior_soc_over_self i.State_Recoded [pw=Weightvar]  if republican==0, robust
est store col2
reg zgov_reduce_inequality_agree zprior_soc_over_self highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar]  if republican==0, robust
est store col3

reg zgov_reduce_inequality_agree zprior_national_over_global [pw=Weightvar]  if republican==0, robust
est store col4
reg zgov_reduce_inequality_agree zprior_national_over_global i.State_Recoded [pw=Weightvar]  if republican==0, robust
est store col5
reg zgov_reduce_inequality_agree zprior_national_over_global highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar]  if republican==0, robust
est store col6

reg zgov_reduce_inequality_agree zluck_unfair_agree [pw=Weightvar] if republican==0, robust
est store col7
reg zgov_reduce_inequality_agree zluck_unfair_agree i.State_Recoded [pw=Weightvar]  if republican==0, robust
est store col8
reg zgov_reduce_inequality_agree zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar]  if republican==0, robust
est store col9

esttab col1 col2 col3 col4 col5 col6 col7 col8 col9 using tables/corrredistrnonrep.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(zprior_soc_over_self zprior_national_over_global zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban _cons) ///
label mtitle("Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)") ///
b(3)

*************************************************************************
*ASSOCIATIONS, HEALTH CARE/MORAL VIEWS, republicans, Table S10
*************************************************************************
reg zfed_univ_healthcare zprior_soc_over_self [pw=Weightvar] if republican==1, robust
est store col1
reg zfed_univ_healthcare zprior_soc_over_self i.State_Recoded [pw=Weightvar] if republican==1, robust
est store col2
reg zfed_univ_healthcare zprior_soc_over_self highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar] if republican==1, robust
est store col3

reg zfed_univ_healthcare zprior_national_over_global [pw=Weightvar] if republican==1, robust
est store col4
reg zfed_univ_healthcare zprior_national_over_global i.State_Recoded [pw=Weightvar] if republican==1, robust
est store col5
reg zfed_univ_healthcare zprior_national_over_global highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar] if republican==1, robust
est store col6

reg zfed_univ_healthcare zluck_unfair_agree [pw=Weightvar] if republican==1, robust
est store col7
reg zfed_univ_healthcare zluck_unfair_agree i.State_Recoded [pw=Weightvar] if republican==1, robust
est store col8
reg zfed_univ_healthcare zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar] if republican==1, robust
est store col9

esttab col1 col2 col3 col4 col5 col6 col7 col8 col9 using tables/corrhealthrep.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(zprior_soc_over_self zprior_national_over_global zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban _cons) ///
label mtitle("Health care (std.)"  "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)") ///
b(3)

*************************************************************************
*ASSOCIATIONS, HEALTH CARE/MORAL VIEWS, non-republicans, Table S11
*************************************************************************
reg zfed_univ_healthcare zprior_soc_over_self [pw=Weightvar] if republican==0, robust
est store col1
reg zfed_univ_healthcare zprior_soc_over_self i.State_Recoded [pw=Weightvar] if republican==0, robust
est store col2
reg zfed_univ_healthcare zprior_soc_over_self highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar] if republican==0, robust
est store col3

reg zfed_univ_healthcare zprior_national_over_global [pw=Weightvar] if republican==0, robust
est store col4
reg zfed_univ_healthcare zprior_national_over_global i.State_Recoded [pw=Weightvar] if republican==0, robust
est store col5
reg zfed_univ_healthcare zprior_national_over_global highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar] if republican==0, robust
est store col6

reg zfed_univ_healthcare zluck_unfair_agree [pw=Weightvar] if republican==0, robust
est store col7
reg zfed_univ_healthcare zluck_unfair_agree i.State_Recoded [pw=Weightvar] if republican==0, robust
est store col8
reg zfed_univ_healthcare zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban i.State_Recoded [pw=Weightvar] if republican==0, robust
est store col9

esttab col1 col2 col3 col4 col5 col6 col7 col8 col9 using tables/corrhealthnonrep.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(zprior_soc_over_self zprior_national_over_global zluck_unfair_agree highinc higheduc female retirement_age high_confirmed child alone urban _cons) ///
label mtitle("Health care (std.)"  "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)") ///
b(3)

*************************************************************************
*PRIMING EFFECTS, POLICY, Table S12
*************************************************************************
reg zgov_reduce_inequality_agree corona_prime [pw=Weightvar], robust
est store col1
reg zgov_reduce_inequality_agree corona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
est store col2

reg zfed_univ_healthcare corona_prime [pw=Weightvar], robust
est store col3
reg zfed_univ_healthcare corona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
est store col4

esttab col1 col2 col3 col4 using tables/primingpolicy.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(N r2, layout(@ @) labels("Observations" "\(R^{2}\)")) /// ///
keep(corona_prime retirement_age female highinc republican higheduc child alone urban high_confirmed northeast midwest south _cons) ///
label mtitle("Redistr. (std.)" "Redistr (std.)" "Healthcare (std.)"  "Healthcare (std.)") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, REDISTRIBUTION, Table S13
*************************************************************************
reg zgov_reduce_inequality_agree corona_prime  republicanXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg zgov_reduce_inequality_agree corona_prime highincXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg zgov_reduce_inequality_agree corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg zgov_reduce_inequality_agree corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg zgov_reduce_inequality_agree corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

reg zgov_reduce_inequality_agree corona_prime high_confirmedXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + high_confirmedXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/heterogeneity_zredistr.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder+ Interaction)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime high_confirmedXcorona_prime _cons) ///
label mtitle("Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)" "Redistribution (std.)") ///
b(3)

*************************************************************************
*PRIMING EFFECT, HETEROGENEITY, HEALTHCARE, Table S14
*************************************************************************
reg zfed_univ_healthcare corona_prime  republicanXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime +  republicanXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col1

reg zfed_univ_healthcare corona_prime highincXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + highincXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col2

reg zfed_univ_healthcare corona_prime higheducXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + higheducXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col3

reg zfed_univ_healthcare corona_prime femaleXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + femaleXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col4

reg zfed_univ_healthcare corona_prime retirement_ageXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + retirement_ageXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col5

reg zfed_univ_healthcare corona_prime high_confirmedXcorona_prime republican highinc higheduc female retirement_age high_confirmed child alone urban northeast midwest south [pw=Weightvar], robust
lincom corona_prime + high_confirmedXcorona_prime
estadd scalar Wint1 r(estimate)
estadd scalar sd1 r(se)
est store col6

esttab col1 col2 col3 col4 col5 col6 using tables/heterogeneity_zhealth.tex, ///
replace star(* 0.10 ** 0.05 *** 0.01) booktabs se stats(Wint1 sd1 N r2, layout(@ (@)) labels("Linear combination" "(Reminder+ Interac.)" "Observations" "\(R^{2}\)")) /// ///
keep(corona_prime republicanXcorona_prime retirement_ageXcorona_prime femaleXcorona_prime higheducXcorona_prime highincXcorona_prime high_confirmedXcorona_prime _cons) ///
label mtitle("Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)" "Health care (std.)") ///
b(3)

*****************************************
*Multiple hypothesis testing, Table S15
********************************************
*Change of names because of STATA restrictions on variable length
gen znational=zprior_national_over_global
gen cp=corona_prime

*rwolf zluck_unfair_agree zluck_determ_agree zprior_soc_over_self zcompassion_agree znational znoborders_agree [pw=Weightvar], indepvar(cp) method(regress) controls(retirement_age female highinc republican higheduc child alone urban high_confirmed northeast midwest south) reps(9999)
