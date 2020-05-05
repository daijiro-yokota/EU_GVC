use 95to11_industry_summary.dta, clear

gen NMS = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
replace NMS = 0 if missing(NMS)
gen EU = 1 if inlist(c_code, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
replace EU = 0 if missing(EU)
gen yearJoin = 1 if year>2003
replace yearJoin = 0 if missing(yearJoin)

save 95to11_industry_cleaned.dta, replace
*ssc install diff
*ssc install estout, replace
ssc install outreg2, replace

** regression 1
keep if EU == 1
*save graph1 twoway(scatter deu year)(lfit deu year if year<2004)(lfit deu year if year>2003), by(NMS) legend()

reg deu year if year < 2004 & NMS == 0
reg deu year if year < 2004 & NMS == 1
gen did = NMS*yearJoin
reg deu NMS yearJoin did, r
outreg2 using reg.txt, replace ctitle(All_industry)
*eststo reg1 


*diff deu, t(NMS) p(yearJoin)

*** regression 2 (excluding B&R)

keep if !inlist(c_code, 4, 33)
*twoway(scatter deu year)(lfit deu year if year<2004)(lfit deu year if year>2003), by(NMS)
reg deu NMS yearJoin did, r
outreg2 using reg.txt, append ctitle(w/o R&B)
*eststo reg2 
*diff deu, t(NMS) p(yearJoin)


use 95to11_industry_cleaned.dta, clear
* ONLY MANUFACTURING *
gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

** regression 3
keep if EU == 1
gen did = NMS*yearJoin
*twoway(scatter deu year)(lfit deu year if year<2004)(lfit deu year if year>2003), by(NMS)
reg deu NMS yearJoin did, r
outreg2 using reg.txt, append ctitle(manufacturing)
*eststo reg3
*diff deu, t(NMS) p(yearJoin)

*** regression 4 (excluding B&R)

keep if !inlist(c_code, 4, 33)
*twoway(scatter deu year)(lfit deu year if year<2004)(lfit deu year if year>2003), by(NMS)
reg deu NMS yearJoin did, r
outreg2 using reg.txt, append ctitle(w/o B&R)
*eststo reg4
*diff deu, t(NMS) p(yearJoin)


*Create the table:
esttab _all using "main.txt", b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) order() label interaction(" X ")  nomtitles replace stats(N r2_a F, layout(@ @ @) star(F) fmt(%9.0fc %9.2f %9.2f) labels("N" "adj. $ R^2$" "F stat")) 
 

*** Regional Industry SPEC compared to EU ****
use 95to11_industry_cleaned.dta, clear




** regression 5
*keep if EU == 1
*bysort i_code year: egen ind_weight_EU_mean = mean(ind_weight) 
gen resid_EU = ind_weight - ind_weight_EU_mean
replace resid_EU = 0 if resid_EU < 0
gen resid_EU_squared = resid_EU^2

twoway(scatter resid_EU_squared year)(lfit resid_EU_squared year), by(NMS)
diff resid_EU, t(NMS) p(yearJoin)

xtset country year
xtline regional_spec_EU




keep if EU == 1
bysort i_code year: egen ind_weight_EU_mean = mean(ind_weight) 
gen resid_squared_EU = (ind_weight - ind_weight_EU_mean)^2
bysort country year: egen regional_spec_EU = sum(resid_squared_EU) 
collapse (mean)regional_spec_EU NMS ,by(country year)
twoway(scatter regional_spec_EU year)(lfit regional_spec_EU year), by(NMS)

xtset country year
xtline regional_spec_EU






















** breakdowb **
use 95to11_industry_cleaned.dta, clear

by country year: egen rank_deu = rank(-deu) 
gen top5 = 1 if rank_deu<6
replace top5 = 0 if missing(top5)
*keep if top5 == 1

gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
*keep if manufacturing == 1

** table 1
keep if inlist(year,1995, 2010)
graph hbar (mean) top5, over(year, label(labsize(tiny))) asyvars bar(1, fcolor(navy)) bar(2, fcolor(white)) over(industry, label(labsize(vsmall))) by(NMS)


use 95to11_industry_cleaned.dta, clear

gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

by country year: egen rank_deu = rank(-deu) 
gen top5 = 1 if rank_deu<6
replace top5 = 0 if missing(top5)

** table 1
keep if inlist(year,1995, 2010)
graph hbar (mean) top5, over(year, label(labsize(tiny))) asyvars bar(1, fcolor(navy)) bar(2, fcolor(white)) over(industry, label(labsize(vsmall))) by(NMS)




gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
*keep if manufacturing == 1

** table 1
keep if inlist(year,1995, 2010)
graph hbar (mean) top5, over(year, label(labsize(tiny))) asyvars bar(1, fcolor(navy)) bar(2, fcolor(white)) over(industry, label(labsize(vsmall))) by(NMS)









use 95to11_industry_cleaned.dta, clear

by country year: egen rank_df = rank(-dforeign) 
gen df_top5 = 1 if rank_df<6
replace df_top5 = 0 if missing(df_top5)
keep if df_top5 == 1

gen manufacturing = 1 if inrange(i_code, 3,16)
replace manufacturing = 0 if missing(manufacturing)
keep if manufacturing == 1

** table 2
*keep if inlist(year,1995, 2010)
*graph hbar (count) df_top5, over(year, label(labsize(tiny))) asyvars bar(1, fcolor(navy)) bar(2, fcolor(white)) over(industry, label(labsize(tiny))) by(NMS)

//likelihood of being one of the top4 industries in the economy
*graph hbar (mean)top4 ,over(industryname, label(labsize(vsmall))) 
