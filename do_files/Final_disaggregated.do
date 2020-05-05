*** Do-file Final_disaggregated ***

cd "/Users/dyokota/Desktop/Daijiro_Final"

* Use these files to replicate the datasets from Original data. *
*do WIOT/1995/2_1995_va_matrix_creation.do
*do WIOT/1995/3_1995_gvcd_and_va_setup.do
*do METI/2_main_IIP_setup.do

use METI/IIP_disaggregated.dta, clear

drop if date < 199500

merge m:1 WIOT_icode using WIOT/1995/1995_GVCD_with_ROW.dta
keep if _merge == 3 
drop _merge

sort date WIOT_icode

merge m:1 date WIOT_icode using EM_DAT/monthly_risk_by_industry_with_ROW.dta
keep if _merge == 3 /* delete 2018 and non-manufacturing industries*/
drop _merge
gen dvcd95 = 1-gvcd95

foreach x in "dis" "dis_count" "ea" "st" "fl" "ia" "dis_den"{
	gen g_r_`x' = gvcd95*risk_`x'
	gen g_r_maj_`x' = gvcd95*risk_maj_`x'
}
foreach y in "ea" "st" "fl"{
	gen g_r_`y'_den = gvcd95*risk_`y'_den
}
* domestic *
foreach x in "dis" "dis_count" "ea" "st" "fl" {
	gen d_r_`x' = dvcd95*dom_risk_`x'
	gen d_r_maj_`x' = dvcd95*dom_risk_maj_`x'
}
gen d_r_ia = dvcd95*dom_risk_ia

merge m:1 METI_icode using METI/pretrend_disaggregated.dta
drop _merge i_group

gen year = floor(date/100)
gen month = mod(date,100)
gen date2 = ym(year, month)
format %tm date2
drop date year month
rename date2 date
order date WIOT_icode METI_icode production shipments inventory inventory_ratio gvcd95 dvcd95 
sort date WIOT_icode 

save Data/Final_5_disaggregated_with_ROW.dta, replace /*no 5 */


******* REPEAT FOR WITHOUT ROW DATA ******

use METI/IIP_disaggregated.dta, clear
drop if date < 199500

merge m:1 WIOT_icode using WIOT/1995/1995_GVCD_without_ROW.dta
keep if _merge == 3 
drop _merge

sort date WIOT_icode

merge m:1 date WIOT_icode using EM_DAT/monthly_risk_by_industry_without_ROW.dta
keep if _merge == 3 /* delete 2018 and non-manufacturing industries*/
drop _merge
gen dvcd95 = 1-gvcd95

foreach x in "dis" "dis_count" "ea" "st" "fl" "ia" "dis_den"{
	gen g_r_`x' = gvcd95*risk_`x'
	gen g_r_maj_`x' = gvcd95*risk_maj_`x'
}
foreach y in "ea" "st" "fl"{
	gen g_r_`y'_den = gvcd95*risk_`y'_den
}
* domestic *
foreach x in "dis" "dis_count" "ea" "st" "fl" {
	gen d_r_`x' = dvcd95*dom_risk_`x'
	gen d_r_maj_`x' = dvcd95*dom_risk_maj_`x'
}
gen d_r_ia = dvcd95*dom_risk_ia

merge m:1 METI_icode using METI/pretrend_disaggregated.dta
drop _merge i_group

gen year = floor(date/100)
gen month = mod(date,100)
gen date2 = ym(year, month)
format %tm date2
drop date year month
rename date2 date
order date WIOT_icode METI_icode production shipments inventory inventory_ratio gvcd95 dvcd95 
sort date WIOT_icode 

save Data/Final_6_disaggregated_without_ROW.dta, replace /*no 6 */

***

xtset date METI_icode
xtreg production g_r_maj_dis i.date, fe



