*** 5 summary statistics table ***
cd "/Users/dyokota/Desktop/summary"

use 95to11_summarystats.dta, clear

reshape long spec_ , i(row_c) j(spec_year)
reshape long to_eu_ , i(row_c spec_year) j(to_eu_year)
drop if spec_year != to_eu_year
rename spec_year year

reshape long to_world_ , i(row_c year) j(to_world_year)
drop if to_world_year != year

reshape long to_foreign_ , i(row_c year) j(to_foreign_year)
drop if to_foreign_year != year

reshape long deu_ , i(row_c year) j(deu_year)
drop if deu_year != year

reshape long dforeign_ , i(row_c year) j(dforeign_year)
drop if dforeign_year != year

drop to_eu_year to_world_year to_foreign_year deu_year dforeign_year

foreach x in spec to_eu to_world to_foreign deu dforeign{
	rename `x'_ `x'
}

gen EU = 1 if inlist(row_c,4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16) 
replace EU = 0 if missing(EU)

bysort NMS year: egen avg_deu_NMS = mean(deu) 
by NMS year: egen avg_dforeign_NMS = mean(dforeign)
by NMS year: egen avg_spec_NMS = mean(spec)
bysort EU year: egen avg_deu_EU = mean(deu) 
by EU year: egen avg_dforeign_EU = mean(dforeign)
by EU year: egen avg_spec_EU = mean(spec)

sort row_c year

rename row_c c_code
xtset c_code year
merge m:1 c_code using c_code.dta, keepusing(row_country)
keep if _merge == 3
drop _merge

encode row_country, gen(country)
drop row_country

gen nonNMS = 1 if EU == 1 & NMS == 0
replace nonNMS = 0 if missing(nonNMS)

save 95to11_summary_cleaned.dta, replace

// EU vs NonEU
twoway(lfit deu year)(scatter deu year), by(EU)
twoway(lfit spec year)(scatter spec year), by(EU)

xtreg deu EU
xtreg spec EU

//NMS vs nonNMS in EU
keep if EU == 1
twoway(lfit deu year)(scatter deu year), by(NMS)
twoway(lfit spec year)(scatter spec year), by(NMS)

xtreg deu NMS
xtreg spec NMS

* install asdoc
*ssc install asdoc

* Default statistics for selected variables
*asdoc sum va_total_1995 va_foreign_1995 va_eu_1995 deu_1995 dforeign_1995 spec_1995 va_total_2010 va_foreign_2010 va_eu_2010 deu_2010 dforeign_2010 spec_2010, by(NMS), save(95tp10summary.doc), replace
*xtline to_world to_foreign to_eu if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36) //NMS

