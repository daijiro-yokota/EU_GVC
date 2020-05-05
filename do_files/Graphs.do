* These codes create graphs for our datesets and results *

clear all
cd "C:\Users\dai81\Documents\STATA\fall_2019_GVC"

*** EM_DATA SUMMARY GRAPHS ***

* a: with ROW included *
* b: without ROW *
use EM_DAT/total_disaster_with_duration.dta, clear

* Graph 1 distribution by disaster *
/*graph bar (count), over(disastertype, label(angle(45))) title("Distribution by disaster type") subtitle("w/ ROW, (1995 Jan. - 2019 Jul.)")
graph save Graph Graphs/1a_disaster_type_w_ROW.gph, replace*/
graph bar (count), over(ROW) asyvars bar(1, fcolor(navy)) bar(2) over(disastertype, label(angle(45))) stack legend(label (1 "40 countries") label (2 "ROW")) title("Distribution by disaster type") subtitle("(1995 Jan. - 2018 Dec.)")
graph save Graph Graphs/1_disaster_type.gph, replace
*findit sutex
*sutex disastertype duration, lab nobs key(descstat) replace file(descstat2.tex) title("EM_DAT Summary Statistics") minmax

use EM_DAT/behind_d_score_w_ROW.dta, clear

* Graph 2 disaster frequency *
graph bar (count), over(dis_dummy, label(labsize(vsmall))) asyvars bar(1, fcolor(white)) bar(2, fcolor(navy)) over(iso, label(labsize(vsmall) angle(45))) legend( label (1 "#Months w/o disaster") label (2 "#Months with disaster")) title("Monthly disaster frequency by country") subtitle("w/ ROW, 1995 Jan. - 2018 Dec.)")
graph save Graph Graphs/2_monthly_dis_freq_by_country_w_ROW.gph, replace

* Graph 3 Major disaster frequency*
graph bar (count), over(maj_dis, label(labsize(vsmall))) asyvars bar(1, fcolor(white)) bar(2, fcolor(brown)) over(iso, label(labsize(vsmall) angle(45))) legend( label (1 "#Months w/o major disaster") label (2 "#Months with major disaster")) title("Monthly major disaster frequency by country") subtitle("w/ ROW, (1995 Jan. - 2018 Dec.)")
graph save Graph Graphs/3_monthly_maj_dis_freq_by_country_w_ROW.gph, replace
** You can see that ROW has high frequency of major disasters. **

* Graph 4. Diastster Density **
use Tables/2_Disaster_Density.dta, clear
merge m:1 country using EM_DAT/c_code_2.dta
keep if _merge == 3
drop _merge
graph bar density if iso != "ROW", over(disastertype, label(labsize(vsmall))) asyvars bar(1, fcolor(white)) bar(2, fcolor(brown)) over(iso, label(labsize(vsmall) angle(45))) legend(size(small)) ytitle("#disaster/sq.km") title("Disaster Density by country") subtitle("(w/o ROW, 1995 Jan. - 2018 Dec.)")
graph save Graph Graphs/4a_disaster_density.gph, replace

* by disastertype *
graph bar density if disastertype == "Earthquake" & iso != "ROW", over(iso, label(labsize(vsmall) angle(45)))
graph save Graph Graphs/4b_disaster_density.gph, replace
graph bar density if disastertype == "Storm" & iso != "ROW", over(iso, label(labsize(vsmall) angle(45)))
graph save Graph Graphs/4c_disaster_density.gph, replace
graph bar density if disastertype == "Flood" & iso != "ROW", over(iso, label(labsize(vsmall) angle(45)))
graph save Graph Graphs/4d_disaster_density.gph, replace


*** IIP SUMMARY GRAPHS ***

use Tables/7a_IIP_weighted.dta, clear

xtline y_avg_pro if year>1994, overlay t(year) i(industry) legend(order(1 "Basic/Fabricated Metal" 2 "Chemicals" 3 "Coke, Refined Petroleum" 4 "Electrical Equipment" 5 "Food" 6 "Leather" 7 "Machinery" 8 "Mining" 9 "Other Non-Metallic Mineral" 10 "Pulp, Paper, Printing" 11 "Rubber and Plastics" 12 "Textiles" 13 "Transport Equipment" 14 "Wood") size(vsmall) symys(*.4) symxs(*2)) xtitle("year")  ytitle("production avg.") title("Production index over time")
graph save Graph Graphs/5a_Production.gph, replace

xtline y_avg_shi if year>1994, overlay t(year) i(industry) legend(order(1 "Basic/Fabricated Metal" 2 "Chemicals" 3 "Coke, Refined Petroleum" 4 "Electrical Equipment" 5 "Food" 6 "Leather" 7 "Machinery" 8 "Mining" 9 "Other Non-Metallic Mineral" 10 "Pulp, Paper, Printing" 11 "Rubber and Plastics" 12 "Textiles" 13 "Transport Equipment" 14 "Wood") size(vsmall) symys(*.4) symxs(*2)) xtitle("year")  ytitle("shipments avg.") title("Shipments index over time")
graph save Graph Graphs/5b_Shipments.gph, replace

xtline y_avg_inv if year>1994, overlay t(year) i(industry) legend(order(1 "Basic/Fabricated Metal" 2 "Chemicals" 3 "Coke, Refined Petroleum" 4 "Electrical Equipment" 5 "Food" 6 "Leather" 7 "Machinery" 8 "Mining" 9 "Other Non-Metallic Mineral" 10 "Pulp, Paper, Printing" 11 "Rubber and Plastics" 12 "Textiles" 13 "Transport Equipment" 14 "Wood")  size(vsmall) symys(*.4) symxs(*2)) xtitle("year")  ytitle("inventory avg.") title("Inventory index over time")
graph save Graph Graphs/5c_Inventory.gph, replace

xtline y_avg_iratio if year>1994, overlay t(year) i(industry) legend(order(1 "Basic/Fabricated Metal" 2 "Chemicals" 3 "Coke, Refined Petroleum" 4 "Electrical Equipment" 5 "Food" 6 "Leather" 7 "Machinery" 8 "Mining" 9 "Other Non-Metallic Mineral" 10 "Pulp, Paper, Printing" 11 "Rubber and Plastics" 12 "Textiles" 13 "Transport Equipment" 14 "Wood")  size(vsmall) symys(*.4) symxs(*2)) xtitle("year") ytitle("inventory ratio avg.") title("Inventory Ratio index over time")
graph save Graph Graphs/5d_InventoryRatio.gph, replace

*** GVCD and risk relationship *

use Tables/6a_risk_change.dta, clear
** MAKE 1995 RISK and 2010 RISK from different GVCD and RISK **
twoway(scatter gvcd_risk risk, mlabel(WIOT_icode))(lfit gvcd_risk risk), title("risk vs gvcd*risk with ROW")
graph save Graph Graphs/6a_GVCDandRisk_w_ROW.gph, replace

use Tables/6b_risk_change.dta, replace
twoway(scatter gvcd_risk risk, mlabel(WIOT_icode))(lfit gvcd_risk risk), title("risk vs gvcd*risk without ROW")
graph save Graph Graphs/6b_GVCDandRisk_without_ROW.gph, replace


use Tables/6a_risk_change.dta, clear
* Graph 7 industry comparison of risk *
graph hbar gvcd95 gvcd_risk, over(industry, label(labsize(vsmall))) bar(1, fcolor(white)) bar(2, fcolor(green)) bar(2) legend(label (1 "GVCD") label (2 "GVC risk")) title("GVC Risk industry comparison") subtitle("w/ ROW, mean based on GVCD(1995) and disasters (1995 - 2017)")
graph save Graph Graphs/7a_GVCD_Risk_w_ROW.gph, replace

graph hbar risk risk_maj, over(industry, label(labsize(vsmall))) bar(1, fcolor(white)) bar(2, fcolor(orange)) bar(2) legend(label (1 "disaster risk") label (2 "major disaster risk") size(small)) title("General vs Major Risk by industry") subtitle("w/ ROW, mean based on disasters (1995 - 2017)")
graph save Graph Graphs/8a_Two_Risks_w_ROW.gph, replace

*** without ROW ***
use Tables/6b_risk_change.dta, clear
* Graph 7 industry comparison of risk *
graph hbar gvcd95 gvcd_risk, over(industry, label(labsize(vsmall))) bar(1, fcolor(white)) bar(2, fcolor(green)) bar(2) legend(label (1 "GVCD") label (2 "GVC risk")) title("GVC Risk industry comparison") subtitle("w/o ROW, mean based on GVCD(1995) and disasters (1995 - 2017)")
graph save Graph Graphs/7b_GVCD_Risk_w_ROW.gph, replace

graph hbar risk risk_maj, over(industry, label(labsize(vsmall))) bar(1, fcolor(white)) bar(2, fcolor(orange)) bar(2) legend(label (1 "disaster risk") label (2 "major disaster risk") size(small)) title("General vs Major Risk by industry") subtitle("w/o ROW, mean based on disasters (1995 - 2017)")
graph save Graph Graphs/8b_Two_Risks_w_ROW.gph, replace

***** THE IDEAL GRAPH SHOWS 4 values in two stack bars next to each other! ****


*** WIOT SUMMARY GRAPHS ***
use Tables/3_WIOT_summary.dta, clear
drop if WIOT_icode==35
sort WIOT_icode

*graph bar FVA10 DVA10, over(industry, label(angle(45) labsize(vsmall))) stack percent
graph save Graph Graphs/9_FVAS_trend.gph, replace


* GVCD vs Production Growth *
use Tables/8a_GVCDvsGrowth.dta, clear
twoway(scatter p_growth gvcd95_ROW)(lfit p_growth gvcd95_ROW)
twoway(scatter p_growth d_gvcd95_ROW)(lfit p_growth d_gvcd95_ROW)

* disaggregated *
use Tables/8b_GVCDvsGrowth.dta, clear
twoway(scatter p_growth gvcd95_ROW)(lfit p_growth gvcd95_ROW)
twoway(scatter p_growth d_gvcd95_ROW)(lfit p_growth d_gvcd95_ROW)



** GECE example **
use Final_7_domestic_w_ROW.dta, clear 

xtset METI_icode date
xtline production if inlist(date,602,612,613,614,615,626), overlay t(date) i(METI_icode) legend(off)
xtline shipments if inlist(date,602,612,613,614,615,626), overlay t(date) i(METI_icode) legend(off)
xtline inventory if inlist(date,602,612,613,614,615,626), overlay t(date) i(METI_icode) legend(off)
xtline inventory_ratio if inlist(date,602,612,613,614,615,626), overlay t(date) i(METI_icode) legend(off)

** 2008 Recession example **
use Final_7_domestic_w_ROW.dta, clear 

xtset METI_icode date
gen year = yofd(dofm(date))
collapse (mean)production shipments inventory inventory_ratio, by(year WIOT_icode)
xtset WIOT_icode year
xtline production if inrange(year,2007,2010), overlay t(year) i(WIOT_icode) legend(off)
xtline shipments if inrange(year,2007,2010), overlay t(year) i(WIOT_icode) legend(off)
xtline inventory if inrange(year,2007,2010), overlay t(year) i(WIOT_icode) legend(off)
xtline inventory_ratio if inrange(year,2007,2010), overlay t(year) i(WIOT_icode) legend(off)

** inventory ratio spiked up in 2009 because production dropped more than inventory. Is that right? ** 



dd //labor
use timeworked.dta, replace

bysort year new_icode: egen avg_worked = mean(worked)

collapse (mean) worked, by(year new_icode ind)
xtset new_icode year
xtline worked, overlay t(year) i(new_icode) legend(off) xtitle("year")  ytitle("hoursworked") title("Hours worked over time")

