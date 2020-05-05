cd "C:\Users\dai81\Documents\STATA"

use 95to11_industry_cleaned.dta, clear
ssc install estout, replace

drop if deu > 1
drop if i_code == 35
drop if inlist(country, 26, 4, 33)
keep if EU == 1

gen did = NMS*yearJoin

bysort country year: egen c_avg_deu = mean(deu)
bysort NMS year: egen nms_avg_deu = mean(c_avg_deu)

twoway(scatter nms_avg_deu year)(lfit nms_avg_deu year if year < 2004 )(lfit nms_avg_deu year if inrange(year, 2004, 2008)),by(NMS)


drop if EU == 0 // ONLY EU countries
drop if inlist(country, 26, 4, 33) // taking out LUX BGA ROU

bysort NMS year: egen avg_to_world_NMS = mean(to_world) 
bysort NMS year: egen avg_to_foreign_NMS = mean(to_foreign) 
bysort NMS year: egen avg_to_eu_NMS = mean(to_eu) 
bysort NMS year: egen avg_ex_deu_NMS = mean(ex_deu) 
by NMS year: egen avg_ex_df_NMS = mean(ex_df)

twoway(scatter avg_ex_deu_NMS year)(lfit avg_ex_deu_NMS year if year < 2004 )(lfit avg_ex_deu_NMS year if inrange(year, 2004, 2008)),by(NMS)

reg deu yearJoin did i.c_code i.i_code , r

* ONLY MANUFACTURING *
gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

keep if inlist(year, 1995, 2007) 
graph hbar (mean)deu ,over(industryname, label(labsize(vsmall))) over(year) by(NMS) 

graph hbar (mean)deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) by(NMS)

graph hbar (mean)to_world, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname) title("Industry DEU Mean") by(NMS)

*graph save Graph Graphs/Industry_DEU.gph, replace