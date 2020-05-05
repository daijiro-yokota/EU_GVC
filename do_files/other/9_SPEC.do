cd "C:\Users\dai81\Documents\STATA"

*** Absolute Country SPEC compared to EU ***
ssc install estout, replace

use 95to11_industry_cleaned.dta, clear
estimates clear

drop if deu > 1
drop if i_code == 35
drop if inlist(country, 26, 4, 33)
keep if EU == 1
drop mean_va_weight weight_resid

bysort country year : egen ind_weight_mean = mean(ind_weight)
gen resid_sq = (ind_weight - ind_weight_mean)^2
by country year: egen abs_spec = sum(resid_sq) 
bysort NMS year: egen nms_avg_spec = mean(abs_spec)

twoway(scatter abs_spec year, msize(tiny))(scatter nms_avg_spec year)(lfit nms_avg_spec year if year < 2004 )(lfit nms_avg_spec year if inrange(year, 2004, 2011)),by(NMS)

gen did = yearJoin*NMS
twoway(scatter abs_spec year, msize(tiny))(lfit abs_spec year),by(NMS)

keep if i_code == 3
reg abs_spec yearJoin did

*** ONLY manufacturing ***
use 95to11_industry_cleaned.dta, clear
estimates clear

gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

drop if deu > 1
drop if i_code == 35
drop if inlist(country, 26, 4, 33)
keep if EU == 1
drop mean_va_weight weight_resid

bysort country year : egen ind_weight_mean = mean(ind_weight)
gen resid_sq = (ind_weight - ind_weight_mean)^2
by country year: egen abs_spec = sum(resid_sq) 
bysort NMS year: egen nms_avg_spec = mean(abs_spec)

twoway(scatter abs_spec year, msize(tiny))(scatter nms_avg_spec year)(lfit nms_avg_spec year if year < 2004 )(lfit nms_avg_spec year if inrange(year, 2004, 2011)),by(NMS)


*** Regional Industry SPEC compared to EU ****
use 95to11_industry_cleaned.dta, clear
estimates clear

drop mean_va_weight weight_resid
*drop if deu > 1
drop if i_code == 35
drop if inlist(country, 4, 33, 26)
keep if EU == 1

bysort i_code year: egen ind_weight_EU_mean = mean(ind_weight) 
gen resid = ind_weight - ind_weight_EU_mean

gen spec = resid if resid > 0
gen did = NMS*yearJoin

bysort country year: egen c_avg_spec = mean(spec)
bysort NMS year: egen nms_avg_spec = mean(c_avg_spec)

*twoway(scatter c_avg_spec year, msize(tiny))(scatter nms_avg_spec year)(lfit nms_avg_spec year if year < 2004 )(lfit nms_avg_spec year if inrange(year, 2004, 2011)),by(NMS)

gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

twoway(scatter spec year, msize(vsmall) ,if spec<0.05)(lfit spec year if year < 2004 )(lfit spec year if inrange(year, 2004, 2008)),by(NMS)

	
** regression 1
reg spec NMS yearJoin did, r
eststo reg1 

** regression 2 with industry FE
reg spec NMS yearJoin did i.i_code, r
eststo reg2

** regression 3 with country FE
reg spec yearJoin did i.c_code, r
eststo reg3

** regression 4 with year FE
reg spec NMS did i.year, r
eststo reg4

** regression 5 with country and industry FE //don't do year*country because it's perfectly multicolinearly with did
reg spec yearJoin did i.c_code i.i_code , r
eststo reg5

** regression 6 with country, year, and industry FE //don't do year*country because it's perfectly multicolinearly with did
reg spec did i.c_code i.i_code i.year, r
eststo reg6

esttab _all using "spec.txt", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Main Results") mtitles("Model 1" "Indstry FE" "Country FE" "Year FE" "I&C FE" "I&C&Y FE")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (did NMS yearJoin _cons)


* Clear the old estimates:
estimates clear

******* ROBUSTNESS // B&R and MANUFACTURING ********
use 95to11_industry_cleaned.dta, clear
keep if EU == 1

drop mean_va_weight weight_resid
drop if deu > 1
drop if i_code == 35
drop if inlist(country, 26, 4, 33)

bysort i_code year: egen ind_weight_EU_mean = mean(ind_weight) 
gen resid = ind_weight - ind_weight_EU_mean

gen spec = resid if resid > 0
gen did = NMS*yearJoin

bysort country year: egen c_avg_spec = mean(spec)
bysort NMS year: egen nms_avg_spec = mean(c_avg_spec)

drop if missing(spec)
** regression 5
reg spec yearJoin did i.c_code i.i_code, r
eststo reg5

* ONLY MANUFACTURING *
gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)

save temp.dta, replace 
keep if manufacturing == 1

drop if missing(spec)
** regression 7
reg spec did yearJoin i.c_code i.i_code, r
eststo reg7

use temp.dta, clear
keep if manufacturing == 0

drop if missing(spec)
** regression 8
reg spec did yearJoin i.c_code i.i_code, r
eststo reg8

esttab _all using "rbust.doc", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() ///
	label title("Robustness Test") mtitles("I&C FE" "Manufacturing" "Non-Manufacturing")  ///
	stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. R^2" "F stat")) ///
	keep (yearJoin did _cons)

	
use 95to11_industry_cleaned.dta, clear
keep if EU == 1

drop mean_va_weight weight_resid
drop if deu > 1
drop if i_code == 35
drop if inlist(country, 26, 4, 33)

keep if inlist(year, 1995, 2010) 

graph hbar (mean)deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))), if NMS == 1

use 95to11_industry_cleaned.dta, clear
keep if EU == 1

drop mean_va_weight weight_resid
drop if deu > 1
drop if i_code == 35
drop if inlist(country, 26, 4, 33)

bysort i_code year: egen ind_weight_EU_mean = mean(ind_weight) 
gen resid = ind_weight - ind_weight_EU_mean
gen spec = resid if resid > 0

drop if missing(spec)
keep if inlist(year, 1995, 2010) 

graph hbar (mean)spec, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))), if NMS == 1