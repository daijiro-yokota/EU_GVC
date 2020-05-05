** These codes calculate import Foreign VA share (FVAS) from the value-added files**
** It also calculates EU share because that's what we did for our capstone. **
** You can calculate the export share by changing the "if" statements after "collapse" **

cd "C:\Users\dai81\Documents\STATA"

forvalues i =1995/2011 {

use value_added/`i'_value_added.dta, replace

collapse (sum) va if EU_exp == 1 & domestic == 0 ,by(col_c_i)
rename va from_eu
save temporary/from_EU.dta, replace

use value_added/`i'_value_added.dta, clear
collapse (sum) va ,by(col_c_i) 
rename va from_world
save temporary/from_world.dta, replace

use value_added/`i'_value_added.dta, clear
collapse (sum) va if domestic == 0 ,by(col_c_i) 
rename va from_foreign
save temporary/from_foreign.dta, replace

use temporary/from_EU.dta, replace
merge 1:1 col_c_i using temporary/from_world.dta
drop _merge
merge 1:1 col_c_i using temporary/from_foreign.dta
drop _merge

gen im_deu = from_eu/from_world
gen im_df = from_foreign/from_world
gen year = `i'
save im_indSummary/im_`i'_summary_industry.dta, replace
}

use im_indSummary/im_1995_summary_industry.dta, clear

forvalues i = 1996/2011{ 
	append using im_indSummary/im_`i'_summary_industry.dta
}

gen col_c = floor(col_c_i/100)
gen col_i = mod(col_c_i, 100)

rename col_c c_code

merge m:1 c_code using c_code.dta, keepusing(col_country) 
//make this on c_code.dta
keep if _merge == 3
drop _merge

encode col_country, gen(country)
drop col_country

rename col_i i_code

merge m:1 i_code using inames.dta, keepusing(industry)
keep if _merge == 3
drop _merge

encode industry, gen(industryname)
drop industry

order c_code i_code year country 
sort c_code i_code year

gen NMS = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
replace NMS = 0 if missing(NMS)
gen EU = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
replace EU = 0 if missing(EU)
gen yearJoin = 1 if year>2003
replace yearJoin = 0 if missing(yearJoin)

save im_95to11_industry_cleaned.dta, replace
