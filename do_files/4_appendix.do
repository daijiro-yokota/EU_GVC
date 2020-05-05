
cd "C:\Users\dai81\Documents\STATA"
clear all

****** APPENDIX *******

*** Import DEU trends ***

use im_95to11_industry_cleaned.dta, clear

drop if im_deu > 1 // Drop im_deu = zero 
drop if i_code == 35 
// Drop Private Households because most values are zero

drop if EU == 0 // ONLY EU countries
drop if inlist(country, 26, 33) // taking out LUX ROU

bysort NMS year: egen avg_from_world_NMS = mean(from_world) 
bysort NMS year: egen avg_from_foreign_NMS = mean(from_foreign) 
bysort NMS year: egen avg_from_eu_NMS = mean(from_eu) 
bysort NMS year: egen avg_im_deu_NMS = mean(im_deu) 
by NMS year: egen avg_im_df_NMS = mean(im_df)


twoway(scatter avg_im_deu_NMS year)(lfit avg_im_deu_NMS year if year < 2004 )(lfit avg_im_deu_NMS year if inrange(year, 2004, 2008)),by(NMS) ///
	legend(order(1 "Mean DEU" 2 "Before 2004" 3 "2004 to 2008"))

*label(1 "Other EU w/o LUX" 2 "NMS w/o ROU") 

*** Export DEU trends and SPEC ***
use 95to11_industry_cleaned.dta, clear

rename deu ex_deu
rename dforeign ex_df

*twoway(scatter spec year, msize(tiny))(scatter nms_avg_spec year)(lfit nms_avg_spec year if year < 2004 )(lfit nms_avg_spec year if inrange(year, 2004, 2011)),by(NMS)

drop if EU == 0 // ONLY EU countries
drop if inlist(country, 26, 33) // taking out LUX ROU

bysort NMS year: egen avg_to_world_NMS = mean(to_world) 
bysort NMS year: egen avg_to_foreign_NMS = mean(to_foreign) 
bysort NMS year: egen avg_to_eu_NMS = mean(to_eu) 
bysort NMS year: egen avg_ex_deu_NMS = mean(ex_deu) 
by NMS year: egen avg_ex_df_NMS = mean(ex_df)


twoway(scatter avg_ex_deu_NMS year)(lfit avg_ex_deu_NMS year if year < 2004 )(lfit avg_ex_deu_NMS year if inrange(year, 2004, 2008)),by(NMS) ///
	legend(order(1 "Mean DEU" 2 "Before 2004" 3 "2004 to 2008"))
	
****** Appendix 5 - Import DEU *******
use im_95to11_industry_cleaned.dta, clear
drop if im_deu > 1 // Drop im_deu = zero 
keep if inrange(i_code, 3, 16) // Drop Private Households because most values are zero
keep if NMS == 1
keep if inlist(year,1995,2011)
graph hbar (mean)im_deu, over(year) asyvars bar(1) bar(2, fcolor(orange)) over(industryname, label(labsize(vsmall))) title("Import DEU Mean by Industry")
