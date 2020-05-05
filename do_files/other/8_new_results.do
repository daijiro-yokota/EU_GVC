cd "C:\Users\dai81\Documents\STATA"
*clear all
* Clear the old estimates:
estimates clear

*use 95to11_industry_summary.dta, clear

*gen NMS = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
*replace NMS = 0 if missing(NMS)
*gen EU = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
*replace EU = 0 if missing(EU)
*gen yearJoin = 1 if year>2003
*replace yearJoin = 0 if missing(yearJoin)
estimates clear
use 95to11_industry_cleaned.dta, clear
ssc install estout, replace
drop if deu > 1
drop if i_code == 35

** regression 1
keep if EU == 1
*save graph1 twoway(scatter deu year)(lfit deu year if year<2004)(lfit deu year if year>2003), by(NMS) legend()

gen did = NMS*yearJoin
reg deu NMS yearJoin did, r
eststo reg1 
*outreg2 using reg.txt, replace ctitle(All_industry)

** regression 2 with industry FE
reg deu NMS yearJoin did i.i_code, r
eststo reg2
*outreg2 using reg.txt, append ctitle(indstry FE)

** regression 3 with country FE
reg deu yearJoin did i.c_code, r
eststo reg3
*outreg2 using reg.txt, append ctitle(country FE)

** regression 4 with year FE
reg deu NMS did i.year, r
eststo reg4
*outreg2 using reg.txt, append ctitle(year FE)

** regression 5 with country and industry FE //don't do year*country because it's perfectly multicolinearly with did
reg deu yearJoin did i.c_code i.i_code , r
eststo reg5
*outreg2 using reg.txt, append ctitle(country&industry FE)

** regression 6 with country, year, and industry FE //don't do year*country because it's perfectly multicolinearly with did
reg deu did i.c_code i.i_code i.year, r
eststo reg6
*outreg2 using reg.txt, append ctitle(country&industry FE)

esttab _all using "main4.doc", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Main Results") mtitles("Model 1" "Indstry FE" "Country FE" "Year FE" "I&C FE" "I&C&Y FE")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (did NMS yearJoin _cons)


* Clear the old estimates:
estimates clear

******* ROBUSTNESS // B&R and MANUFACTURING ********

use 95to11_industry_cleaned.dta, clear
keep if EU == 1
gen did = NMS*yearJoin

** regression 5
reg deu yearJoin did i.c_code i.i_code, r
eststo reg5

*** regression 7 (excluding B&R)
keep if !inlist(c_code, 4, 33)
reg deu yearJoin did i.c_code i.i_code, r
eststo reg7 


use 95to11_industry_cleaned.dta, clear
keep if EU == 1
gen did = NMS*yearJoin

* ONLY MANUFACTURING *
gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

** regression 8
reg deu did yearJoin i.c_code i.i_code, r
eststo reg8

*** regression 9 (excluding B&R)
keep if !inlist(c_code, 4, 33)
reg deu did yearJoin i.c_code i.i_code, r
eststo reg9

esttab _all using "robust5.doc", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Robustness Test") mtitles("Model 5" "exclude B&R" "Manufacturing" "exclude B&R")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (yearJoin did _cons)

* Clear the old estimates:
estimates clear

