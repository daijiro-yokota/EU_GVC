** Calculating DEU and SPEC for EU countries

cd "/Users/dyokota/Desktop/summary"

forvalues i =1995/2011 {

use matrixG/`i'_matrix_G.dta, clear

reshape long g, i(row_c_i) j(col_c_i, string)

split col_c_i, p("_")
rename col_c_i1  col_c
rename col_c_i2 col_i
destring col_c col_i, replace
drop col_c_i rows
gen col_c_i = col_c*100 + col_i

order row_c_i col_c_i g row_c row_i col_c col_i
sort row_c_i col_c_i

gen NMS_exp = 1 if inlist(row_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
gen EU_imp = 1 if inlist(col_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)

gen NMS_imp = 1 if inlist(col_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
gen EU_exp = 1 if inlist(row_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
gen domestic = 1 if row_c == col_c

foreach x in NMS_exp NMS_imp EU_exp EU_imp domestic {
	replace `x' = 0 if missing(`x')
}

rename g va

save value_added/`i'_value_added.dta, replace

****** DEU ******

collapse (sum) va if EU_imp == 1 & domestic == 0 ,by(row_c) 
rename va to_eu
save temporary/to_EU.dta, replace

use value_added/`i'_value_added.dta, clear
collapse (sum) va ,by(row_c) 
rename va to_world
save temporary/to_world.dta, replace

use value_added/`i'_value_added.dta, clear
collapse (sum) va if domestic == 0 ,by(row_c) 
rename va to_foreign
save temporary/to_foreign.dta, replace

use temporary/to_EU.dta, replace
merge 1:1 row_c using temporary/to_world.dta
drop _merge
merge 1:1 row_c using temporary/to_foreign.dta
drop _merge

gen NMS = 1 if inlist(row_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
replace NMS = 0 if missing(NMS)
gen deu = to_eu/to_world
gen dforeign = to_foreign/to_world

save countrySummary/`i'_summary_country.dta, replace

* for industry
use value_added/`i'_value_added.dta, clear

collapse (sum) va if EU_imp == 1 & domestic == 0 ,by(row_c_i)
rename va to_eu
save temporary/to_EU.dta, replace

use value_added/`i'_value_added.dta, clear
collapse (sum) va ,by(row_c_i) 
rename va to_world
save temporary/to_world.dta, replace

use value_added/`i'_value_added.dta, clear
collapse (sum) va if domestic == 0 ,by(row_c_i) 
rename va to_foreign
save temporary/to_foreign.dta, replace

use temporary/to_EU.dta, replace
merge 1:1 row_c_i using temporary/to_world.dta
drop _merge
merge 1:1 row_c_i using temporary/to_foreign.dta
drop _merge

gen deu = to_eu/to_world
gen dforeign = to_foreign/to_world

save indSummary/`i'_summary_industry.dta, replace

****** SPEC ******

gen row_c = floor(row_c_i/100)
gen row_i = mod(row_c_i, 100)
bysort row_c: egen country_total = sum(to_world) 
gen ind_weight_in_country = to_world/country_total
by row_c: egen mean_va_weight = mean(ind_weight_in_country) 
gen resid_squared = (ind_weight_in_country - mean_va_weight)^2
by row_c: egen spec = sum(resid_squared) 

collapse (sum) spec, by(row_c)
merge 1:1 row_c using countrySummary/`i'_summary_country.dta
drop _merge

rename spec spec_`i'
rename to_eu to_eu_`i'
rename to_world to_world_`i'
rename to_foreign to_foreign_`i'
rename deu deu_`i'
rename dforeign dforeign_`i'

save countrySummary/`i'_summary_country.dta, replace
}

use countrySummary/1995_summary_country.dta, clear

forvalues i = 1996/2011{ /* change year to 2011 2/2 */
	merge 1:1 row_c using countrySummary/`i'_summary_country.dta
	drop _merge
}

sort NMS

save 95to11_summarystats.dta, replace




