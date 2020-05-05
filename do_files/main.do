*** This is a do-file for my capstone research project at Macalester College. ***
*** The class was ECON 494 Multinational Corporations with Prof. Friedt in 2019 fall semester. ***
*** I worked with another student in the class Venkat Somala ''20. ***
*** The data is created by World Input-Output table and can be requested to dyokota@macalester.edu ***

cd "C:\Users\dai81\Documents\STATA\fall_2019_GVC"
clear all
ssc install estout, replace


******* SUMMARY STATISTICS **********

************** Table 1 - Industry-level Import Mean Table ************
*** Create two text files used for Table 1 in the paper.***
use im_95to11_industry_cleaned.dta, clear

drop if im_deu > 1 // Drop irregular deus that's higher than 1. This was discussed in the WIOT paper  
drop if i_code == 35 // Drop Private Households because all values are zero
drop if EU == 0 // We look at EU countries

keep if inlist(year,1995,2011) // Compare two years

estimates clear
bysort NMS year: eststo: quietly estpost summarize from_world from_foreign from_eu im_deu im_df

esttab, cells("mean ") ,using "im_sum.txt",replace label nodepvar title("Mean Statistics - Import") mtitles("Other EU 1995" "Other EU 2011" "NMS 1995" "NMS 2011" ) 

****************** Export Mean Table ****************
use ex_95to11_industry_cleaned.dta, clear

drop if ex_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero
drop if EU == 0 // ONLY EU countries

keep if inlist(year,1995,2011)

estimates clear
bysort NMS year: eststo: quietly estpost summarize to_world to_foreign to_eu ex_deu ex_df

esttab, cells("mean ") ,using "ex_sum.txt",replace label nodepvar title("Mean Statistics - Export") mtitles("Other EU 1995" "Other EU 2011" "NMS 1995" "NMS 2011" ) 

******* Table 2 Country-level Summary Statistics: DEU DF SPEC *******
use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 
drop if i_code == 35 // Drop Private Households because most values are zero

collapse im_deu im_df ,by(country year NMS EU)
save temp_im.dta, replace

use ex_95to11_industry_cleaned.dta, clear
drop if ex_deu > 1 
drop if i_code == 35 // Drop Private Households because most values are zero

*** Calculate SPEC ****
bysort country year : egen ind_weight_mean = mean(ind_weight)
gen resid_sq = (ind_weight - ind_weight_mean)^2
by country year: egen spec = sum(resid_sq) 
bysort NMS year: egen nms_avg_spec = mean(spec)

collapse ex_deu ex_df spec ,by(country year NMS EU)

merge m:1 country year using "temp_im.dta"
drop _merge

gen NMS_EU = 2 if NMS == 1 & EU == 1
replace NMS_EU = 1 if NMS == 0 & EU == 1
replace NMS_EU = 0 if NMS == 0 & EU == 0

save country_level_summary.dta, replace

keep if inlist(year,1995,2011)

estimates clear
bysort NMS_EU year: eststo: quietly estpost summarize im_deu im_df ex_deu ex_df  spec

esttab, cells("mean ") ,using "country_sum.txt",replace label nodepvar title("Country-level Mean Statistics") mtitles("Non_EU" "Non_EU" "Other EU" "Other EU" "NMS" "NMS" ) 

****** Graph 1 Mean Export DEU by industry - NMS *******
use ex_95to11_industry_cleaned.dta, clear
drop if ex_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if NMS == 1
keep if inlist(year,1995,2011)
graph hbar (mean)ex_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Export DEU Mean by Industry")

****** Other EU countries *******
use ex_95to11_industry_cleaned.dta, clear
drop if ex_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if EU == 1 & NMS == 0
keep if inlist(year,1995,2011)
graph hbar (mean)ex_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Export DEU Mean by Industry")

***** Graph 2 SPEC trend ********
use country_level_summary.dta, clear

collapse (mean)spec ,by(NMS_EU year) 
xtset NMS_EU year 
xtline spec


******* REGRESSIONS - Main Results - **********

********** Table 3 - Main regression for Import-DEU *********
use im_95to11_industry_cleaned.dta, clear
estimates clear //Clear the old estimates

drop if im_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

** regression 1
keep if EU == 1
gen did = NMS*yearJoin
reg im_deu NMS yearJoin did, r
eststo reg1 

** regression 2 with industry FE
reg im_deu NMS yearJoin did i.i_code, r
eststo reg2

** regression 3 with country FE
reg im_deu yearJoin did i.c_code, r
eststo reg3

** regression 4 with year FE
reg im_deu NMS did i.year, r
eststo reg4

** regression 5 with country and industry FE 
//don't do year*country because it's perfectly multicolinearly with did
reg im_deu yearJoin did i.c_code i.i_code , r
eststo reg5

** regression 6 with country, year, and industry FE 
//don't do year*country because it's perfectly multicolinearly with did
reg im_deu did i.c_code i.i_code i.year, r
eststo reg6

esttab _all using "im_main.txt", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Main Results - Imports") mtitles("Model 1" "Indstry FE" "Country FE" "Year FE" "I&C FE" "I&C&Y FE")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (did NMS yearJoin _cons)

******* ROBUSTNESS // B&R and MANUFACTURING ********
use im_95to11_industry_cleaned.dta, clear
estimates clear //Clear the old estimates

drop if im_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

keep if EU == 1
gen did = NMS*yearJoin

** regression 5
reg im_deu yearJoin did i.c_code i.i_code, r
eststo reg5

*** regression 7 (excluding B&R)
keep if !inlist(c_code, 4, 33)
reg im_deu yearJoin did i.c_code i.i_code, r
eststo reg7 

use im_95to11_industry_cleaned.dta, clear

drop if im_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero
keep if EU == 1
gen did = NMS*yearJoin

* ONLY MANUFACTURING *
gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

** regression 8
reg im_deu did yearJoin i.c_code i.i_code, r
eststo reg8

*** regression 9 (excluding B&R)
keep if !inlist(c_code, 4, 33)
reg im_deu did yearJoin i.c_code i.i_code, r
eststo reg9

esttab _all using "im_robust.txt", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Robustness Test - Import") mtitles("Model 5" "exclude B&R" "Manufacturing" "exclude B&R")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (yearJoin did _cons)

	
********** Table 4 - Main regression for Export-DEU *********
use ex_95to11_industry_cleaned.dta, clear
estimates clear //Clear the old estimates

drop if ex_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

** regression 1
keep if EU == 1
gen did = NMS*yearJoin
reg ex_deu NMS yearJoin did, r
eststo reg1 

** regression 2 with industry FE
reg ex_deu NMS yearJoin did i.i_code, r
eststo reg2

** regression 3 with country FE
reg ex_deu yearJoin did i.c_code, r
eststo reg3

** regression 4 with year FE
reg ex_deu NMS did i.year, r
eststo reg4

** regression 5 with country and industry FE 
//don't do year*country because it's perfectly multicolinearly with did
reg ex_deu yearJoin did i.c_code i.i_code , r
eststo reg5

** regression 6 with country, year, and industry FE 
//don't do year*country because it's perfectly multicolinearly with did
reg ex_deu did i.c_code i.i_code i.year, r
eststo reg6

esttab _all using "ex_main.txt", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Main Results - Exports") mtitles("Model 1" "Indstry FE" "Country FE" "Year FE" "I&C FE" "I&C&Y FE")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (did NMS yearJoin _cons)

******* ROBUSTNESS // B&R and MANUFACTURING ********
use ex_95to11_industry_cleaned.dta, clear
estimates clear //Clear the old estimates

drop if ex_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

keep if EU == 1
gen did = NMS*yearJoin

** regression 5
reg ex_deu yearJoin did i.c_code i.i_code, r
eststo reg5

*** regression 7 (excluding B&R)
keep if !inlist(c_code, 4, 33)
reg ex_deu yearJoin did i.c_code i.i_code, r
eststo reg7 

use ex_95to11_industry_cleaned.dta, clear

drop if ex_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero
keep if EU == 1
gen did = NMS*yearJoin

* ONLY MANUFACTURING *
gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

** regression 8
reg ex_deu did yearJoin i.c_code i.i_code, r
eststo reg8

*** regression 9 (excluding B&R)
keep if !inlist(c_code, 4, 33)
reg ex_deu did yearJoin i.c_code i.i_code, r
eststo reg9

esttab _all using "ex_robust.txt", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Robustness Test - Export") mtitles("Model 5" "exclude B&R" "Manufacturing" "exclude B&R")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (yearJoin did _cons)