
cd "C:\Users\dai81\Documents\STATA"
clear all

********** Table 3 - Main regression for Import-DEU *********
use im_95to11_industry_cleaned.dta, clear
ssc install estout, replace
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