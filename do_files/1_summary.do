
cd "C:\Users\dai81\Documents\STATA"
clear all

************** Table 1 - Industry-level Import Mean Table ************
ssc install estout, replace

use im_95to11_industry_cleaned.dta, clear

drop if im_deu > 1 // Drop irregular deu over 1 discussed in the WIOT paper  
drop if i_code == 35 // Drop Private Households because most values are zero
drop if EU == 0 // ONLY EU countries

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

******* Table 2 Country-level Summary Statistics: DEU DF SPEC *********
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

****** Appendix 5 - Import DEU *******
use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if NMS == 1
keep if inlist(year,1995,2011)
graph hbar (mean)im_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Import DEU Mean by Industry")

***** Graph 2 SPEC trend ********
use country_level_summary.dta, clear

collapse (mean)spec ,by(NMS_EU year) 
xtset NMS_EU year 
xtline spec