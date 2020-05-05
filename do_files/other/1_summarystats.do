
cd "C:\Users\dai81\Documents\STATA"

****************** Import Mean Table ****************
ssc install estout, replace

use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

drop if EU == 0 // ONLY EU countries

bysort NMS year: egen avg_from_world_NMS = mean(from_world) 
bysort NMS year: egen avg_from_foreign_NMS = mean(from_foreign) 
bysort NMS year: egen avg_from_eu_NMS = mean(from_eu) 
bysort NMS year: egen avg_im_deu_NMS = mean(im_deu) 
by NMS year: egen avg_im_df_NMS = mean(im_df)

keep if inlist(year,1995,2011)

estimates clear

bysort NMS year: eststo: quietly estpost summarize from_world from_foreign from_eu im_deu im_df

esttab, cells("mean ") ,using "im_sum.txt",replace label nodepvar title("Mean Statistics - Import") mtitles("Other EU 1995" "Other EU 2011" "NMS 1995" "NMS 2011" ) 

****** Bar graph *******
use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if NMS == 1
keep if inlist(year,1995,2011)
graph hbar (mean)im_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Import DEU Mean by Industry")


****************** Export Mean Table ****************

use 95to11_industry_cleaned.dta, clear
rename deu ex_deu
rename dforeign ex_df
drop if ex_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

drop if EU == 0 // ONLY EU countries

bysort NMS year: egen avg_to_world_NMS = mean(to_world) 
bysort NMS year: egen avg_to_foreign_NMS = mean(to_foreign) 
bysort NMS year: egen avg_to_eu_NMS = mean(to_eu) 
bysort NMS year: egen avg_ex_deu_NMS = mean(ex_deu) 
by NMS year: egen avg_ex_df_NMS = mean(ex_df)

keep if inlist(year,1995,2011)

estimates clear

bysort NMS year: eststo: quietly estpost summarize to_world to_foreign to_eu ex_deu ex_df

esttab, cells("mean ") ,using "ex_sum.txt",replace label nodepvar title("Mean Statistics - Export") mtitles("Other EU 1995" "Other EU 2011" "NMS 1995" "NMS 2011" ) 

****** Bar graph *******
use 95to11_industry_cleaned.dta, clear
rename deu ex_deu
rename dforeign ex_df
drop if ex_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if NMS == 1
keep if inlist(year,1995,2011)
graph hbar (mean)ex_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Export DEU Mean by Industry")

****** Bar graph *******
use 95to11_industry_cleaned.dta, clear
rename deu ex_deu
rename dforeign ex_df
drop if ex_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if EU == 1
keep if NMS == 0
keep if inlist(year,1995,2011)
graph hbar (mean)ex_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Export DEU Mean by Industry")

**************** Country-level DEU DF SPEC ***********

use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

estimates clear
collapse im_deu im_df ,by(country year NMS EU)

save temp_im.dta, replace

use 95to11_industry_cleaned.dta, clear
rename deu ex_deu
rename dforeign ex_df
drop if ex_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 // Drop Private Households because most values are zero

*drop if inlist(country, 26, 4, 33)
*keep if EU == 1
drop mean_va_weight weight_resid

*** SPEC ****
bysort country year : egen ind_weight_mean = mean(ind_weight)
gen resid_sq = (ind_weight - ind_weight_mean)^2
by country year: egen spec = sum(resid_sq) 
bysort NMS year: egen nms_avg_spec = mean(spec)

estimates clear
collapse ex_deu ex_df spec ,by(country year NMS EU)

merge m:1 country year using "temp_im.dta"
drop _merge

gen NMS_EU = 2 if NMS == 1 & EU == 1
replace NMS_EU = 1 if NMS == 0 & EU == 1
replace NMS_EU = 0 if NMS == 0 & EU == 0

save country_level_summary.dta, replace

use country_level_summary.dta, clear

keep if inlist(year,1995,2011)
estimates clear

bysort NMS_EU year: eststo: quietly estpost summarize im_deu im_df ex_deu ex_df  spec

esttab, cells("mean ") ,using "country_sum.txt",replace label nodepvar title("Country-level Mean Statistics") mtitles("Non_EU" "Non_EU" "Other EU" "Other EU" "NMS" "NMS" ) 

use country_level_summary.dta, clear

collapse (mean)spec ,by(NMS_EU year) 
xtset NMS_EU year 
xtline spec

*********** ONLY MANUFACTURING XTLINE ***********

use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 // Drop im_deu = zero 
drop if !inrange(i_code,3,15)
// Drop non-manufacturing

estimates clear
collapse im_deu im_df ,by(country year NMS EU)

save temp_im_mfg.dta, replace

use 95to11_industry_cleaned.dta, clear
rename deu ex_deu
rename dforeign ex_df
drop if ex_deu > 1 // Drop im_deu = zero 
drop if !inrange(i_code,3,15)
// Drop non-manufacturing

*drop if inlist(country, 26, 4, 33)
*keep if EU == 1
drop mean_va_weight weight_resid

*** SPEC ****
bysort country year : egen ind_weight_mean = mean(ind_weight)
gen resid_sq = (ind_weight - ind_weight_mean)^2
by country year: egen spec = sum(resid_sq) 
bysort NMS year: egen nms_avg_spec = mean(spec)

estimates clear
collapse ex_deu ex_df spec ,by(country year NMS EU)

merge m:1 country year using "temp_im_mfg.dta"
drop _merge

gen NMS_EU = 2 if NMS == 1 & EU == 1
replace NMS_EU = 1 if NMS == 0 & EU == 1
replace NMS_EU = 0 if NMS == 0 & EU == 0

save country_summary_mfg.dta, replace

use country_summary_mfg.dta, clear

collapse (mean)spec ,by(NMS_EU year) 
xtset NMS_EU year 
xtline spec

use country_summary_mfg.dta, clear
drop if NMS == 0
xtset country year
gen dex_deu = ex_deu / l.ex_deu
gen dspec = spec / l.spec
xtline dex_deu dspec



