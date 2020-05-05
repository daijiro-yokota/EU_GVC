*** #11 GVCD and disaster creation setup ***

* The codes below create GVCD and VA_Disaster.dta from VA data. *
* VA data is created in #10 from WIOT table for a specified year. *

clear all
cd "/Users/dyokota/Desktop/Daijiro_Final/WIOT/1995"

use 1995_japan_VA_with_ROW.dta, clear

gen WIOT_icode = _n
gen gvcd95 = .
forvalues i =1/35{
	replace gvcd95 = gvc_dep_`i' in `i'
}

replace gvcd95 = gvc_dep_23[1] in 23

keep WIOT_icode gvcd95
drop if missing(gvcd95)

save 1995_GVCD_with_ROW.dta, replace

** VA_disaster data setup **

use 1995_japan_VA_with_ROW.dta, clear

keep country g1-g35 total_imp_va_1-total_imp_va_35 c_dep_1-c_dep_35 d_dep_1-d_dep_35 gvc_dep_1-gvc_dep_35 total_va_1-total_va_35

forvalues i = 1/35{
	rename g`i' VA95_`i'
	rename total_imp_va_`i' TFVA95_`i'
	rename c_dep_`i' CVAS95_`i'
	rename d_dep_`i' DVAS95_`i' //domestic va share
	rename gvc_dep_`i' GVCD95_`i' //foreign va share this is GVCD95
	rename total_va_`i' TVA95_`i'
}

expand 288
sort country

gen date = .
order country date

local r 1
forvalues c = 1/41{
	forvalues i = 199500(100)201800{
		forvalues m = 1/12{
			replace date = `i'+`m' in `r' if country == `c'
			local ++r
		}
	}
}

save 1995_VA_and_GVCD_with_ROW.dta, replace


*** Same process for without_ROW data. ***

use 1995_japan_VA_without_ROW.dta, clear

gen WIOT_icode = _n
gen gvcd95 = .
forvalues i =1/35{
	replace gvcd95 = gvc_dep_`i' in `i'
}

replace gvcd95 = gvc_dep_23[1] in 23

keep WIOT_icode gvcd95

drop if missing(gvcd95)

save 1995_GVCD_without_ROW.dta, replace

** VA_disaster data setup **

use 1995_japan_VA_without_ROW.dta, clear

keep country g1-g35 total_imp_va_1-total_imp_va_35 c_dep_1-c_dep_35 d_dep_1-d_dep_35 gvc_dep_1-gvc_dep_35 total_va_1-total_va_35

forvalues i = 1/35{
	rename g`i' VA95_`i'
	rename total_imp_va_`i' TFVA95_`i'
	rename c_dep_`i' CVAS95_`i'
	rename d_dep_`i' DVAS95_`i' //domestic va share
	rename gvc_dep_`i' GVCD95_`i' //foreign va share this is GVCD95
	rename total_va_`i' TVA95_`i'
}

expand 288
sort country

gen date = .
order country date

local r 1
forvalues c = 1/41{
	forvalues i = 199500(100)201800{
		forvalues m = 1/12{
			replace date = `i'+`m' in `r' if country == `c'
			local ++r
		}
	}
}

save 1995_VA_and_GVCD_without_ROW.dta, replace
