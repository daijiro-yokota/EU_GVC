*** 6 summary statistics table ***
cd "/Users/dyokota/Desktop/summary"

use indSummary/1995_summary_industry.dta, clear

forvalues i = 1996/2011{ 
	append using indSummary/`i'_summary_industry.dta
}

gen row_c = floor(row_c_i/100)
gen row_i = mod(row_c_i, 100)

rename row_c c_code

merge m:1 c_code using c_code.dta, keepusing(row_country)
keep if _merge == 3
drop _merge

encode row_country, gen(country)
drop row_country

rename row_i i_code

merge m:1 i_code using inames.dta, keepusing(industry)
keep if _merge == 3
drop _merge

encode industry, gen(industryname)
drop industry

order c_code i_code year country 
sort c_code i_code year

bysort country year : egen country_total = sum(to_world) 
gen ind_weight = to_world/country_total
by country year: egen mean_va_weight = mean(ind_weight) 
gen weight_resid = ind_weight - mean_va_weight

*graph box ind_weight_in_country if inlist(c_code,4, 8, 9, 13, 18, 27, 25, 29), over(year) by(country) 

save 95to11_industry_summary.dta, replace

gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)


************** ONLY MANUFACTURING **************

keep if manufacturing == 1

by country year: egen rank_weight_manuf = rank(-ind_weight) 
gen top4 = 1 if rank_weight_manuf<5
replace top4 = 0 if missing(top4)

//likelihood of being one of the top4 industries in the economy
graph hbar (mean)top4 ,over(industryname, label(labsize(vsmall))) 

gen NMS = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
replace NMS = 0 if missing(NMS)
gen EU = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
replace EU = 0 if missing(EU)

*gen top4year = top4*year
*reg deu year top4 top4year if NMS == 1
.
*xtset i_code year
*twoway(scatter deu year)(lfit deu year), by(NMS)

*** Industry SPEC compared to WORLD ***
*bysort i_code year: egen ind_weight_world_mean = mean(ind_weight) 
*gen resid_squared_world = (ind_weight - ind_weight_world_mean)^2



*** Regional Industry SPEC compared to EU ****

keep if EU == 1
twoway(scatter deu year)(lfit deu year), by(NMS)

*keep if !inlist(c_code, 4,  33)
gen yearJoin = 1 if year>2003
replace yearJoin = 0 if missing(yearJoin)

ssc install diff
diff deu, t(NMS) p(yearJoin)


reg deu year yearJoin NMS

bysort i_code year: egen ind_weight_EU_mean = mean(ind_weight) 
gen resid_squared_EU = (ind_weight - ind_weight_EU_mean)^2


bysort country : egen regional_spec_EU = sum(resid_squared_EU) 

gen top4year = top4*year
replace top4year = 0 if missing(top4year)

reg regional_spec_EU top4*year year 

twoway(scatter regional_spec_EU year)(lfit regional_spec_EU year), by(NMS)





keep if rank_va_weight <5

save top4.dta, replace

collapse (sum) ind_weight_in_country ,by(country year c_code)
gen NMS = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
gen EU = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
replace NMS = 0 if missing(NMS)
replace EU = 0 if missing(EU)
gen nonNMS = 1 if NMS == 0 & EU == 1
replace nonNMS = 0 if missing(nonNMS)

xtset country year
xtline ind_weight_in_country, by(NMS)

*save regression1.dta, replace



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
