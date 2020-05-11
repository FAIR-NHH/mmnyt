capture log close
set more off
version 16
log using cleaning_ipsos_mmnyt_release, text replace
	
*Loading data:	
use ../raw/ipsos_mmnyt_release, clear
est clear

*Cleaning dataset
drop ReturnCode IDType MRK_SMPGRP MRK_SMPSRC
drop MRK_STATUS_GDW MRK_DIFF_TIME_GDW QUOTA_GDW QUOTA_CAN_GENDER_GDW QUOTA_CAN_AGERANGE_GDW QUOTA_CAN_REGION_GDW
drop MRK_ROT_GDW_1 MRK_ROT_GDW_2 QMRK_TREAT_GDW_2

rename USHOU1 house
rename QTREATMENT1_1 prime_affected
rename QTREATMENT1_2 prime_weeks
rename QTREATMENT3 luck_unfair_agree
rename QTREATMENT4 luck_determ_agree
rename QTREATMENT5 prior_self_over_soc
rename QTREATMENT6 compassion_agree
rename QTREATMENT7 prior_national_over_global
rename QTREATMENT8 noborders_agree
rename QTREATMENT9 gov_reduce_inequality_agree
rename QGDW5A fed_univ_healthcare

rename resp_age age

decode State_Recoded, generate(state)

gen corona=1
gen weight=Weightvar

gen corona_prime=0 if luck_unfair_agree!=.
replace corona_prime=1 if prime_affected<11 
label variable corona_prime "Covid-19"

label define labels54 5 "Strongly agree" 4 "Somewhat agree" 3 "Neither agree nor disagree" 2 "Somewhat disagree" 1 "Strongly disagree", replace

replace luck_unfair_agree=6-luck_unfair_agree if luck_unfair_agree!=.
replace luck_determ_agree=6-luck_determ_agree if luck_determ_agree!=.
replace compassion_agree=6-compassion_agree if compassion_agree!=.
replace noborders_agree=6-noborders_agree if noborders_agree!=.
replace gov_reduce_inequality_agree=4-gov_reduce_inequality_agree if gov_reduce_inequality_agree!=.

label values luck_determ_agree labels54
label values compassion_agree labels54
label values noborders_agree labels54
label define labels60 3 "Generally agree" 2 "Neither agree nor disagree" 1 "Generally disagree", replace

replace fed_univ_healthcare=0 if fed_univ_healthcare==1
replace fed_univ_healthcare=1 if fed_univ_healthcare==2
label define labels61 2 "", modify
label define labels61 1 "Yes, government is responsible", modify
label define labels61 0 "No, government is not responsible", add

*Generating income variable from USHHI2
gen income=.
replace income=5000 if USHHI2==1
replace income=7500 if USHHI2==2
replace income=12500 if USHHI2==3
replace income=17500 if USHHI2==4
replace income=22500 if USHHI2==5
replace income=27500 if USHHI2==6
replace income=32500 if USHHI2==7
replace income=37500 if USHHI2==8
replace income=42500 if USHHI2==9
replace income=47500 if USHHI2==10
replace income=52500 if USHHI2==11
replace income=57500 if USHHI2==12
replace income=62500 if USHHI2==13
replace income=67500 if USHHI2==14
replace income=72500 if USHHI2==15
replace income=77500 if USHHI2==16
replace income=85000 if USHHI2==17
replace income=95000 if USHHI2==18
replace income=112500 if USHHI2==19
replace income=137500 if USHHI2==20
replace income=162500 if USHHI2==21
replace income=225000 if USHHI2==22
replace income=250000 if USHHI2==23
replace income=. if USHHI2==24

*Generating living alone
gen alone=0
replace alone=1 if HHCMP10==1
label variable alone "Living alone" 

*Generating highincome (above median in sample - should be US)
sum income [weight=Weightvar], detail
return list

gen highinc=1 if income>67500
replace highinc=0 if income<67501
replace highinc=. if income==.
label variable highinc "High inc." 

*Generating highage (above median in US)
gen highage=1 if age>46
replace highage=0 if age<47
replace highage=. if age==.
label variable highage "High age" 

*Generating retired-dummy
gen retirement_age=1 if age>65
replace retirement_age=0 if age<66
replace retirement_age=. if age==.
label variable retirement_age "Retirement age" 

label variable age "Age"

*Generating conservative (republican) vs. non-republican dummy (includes 'prefer not to answer'):
gen conservative=1 if GDW6==1
replace conservative=0 if GDW6!=1

*Generating republican vs. non-republican dummy:
gen republican=1 if GDW6==1
replace republican=0 if GDW6==2
replace republican=0 if GDW6==3
label variable republican "Republican"

*Generating urban (incl semiurban) vs. rural dummy:
gen urban=1 if LIV==3
replace urban=1 if LIV==2
replace urban=0 if LIV==1
label variable urban "Urban"

*Generating female vs. male dummy:
gen female=1 if resp_gender==2
replace female=0 if resp_gender!=2
label variable female "Female"

*Generating education dummy
gen higheduc=1 if usedu3_der==6 | usedu3_der==7
replace higheduc=0 if usedu3_der<6
label variable higheduc "High educ."

*Generating child-dummy (having at least one child under 18 in your household)
gen child=0
replace child=1 if KIDS02>0
label variable child "Child"

*Generating region dummies
gen northeast=0
replace northeast=1 if HCAL_STDREGION_4CODES_US==1
label variable northeast "Northeast"

gen midwest=0
replace midwest=1 if HCAL_STDREGION_4CODES_US==2
label variable midwest "Midwest"

gen south=0
replace south=1 if HCAL_STDREGION_4CODES_US==3
label variable south "South"

gen west=0
replace west=1 if HCAL_STDREGION_4CODES_US==4
label variable west "West"


save ../processed/ipsos_mmnyt_processed_release, replace
