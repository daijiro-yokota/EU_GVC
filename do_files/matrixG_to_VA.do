** Calculating VA from matrix G for each year

cd "/Users/dyokota/Desktop/summary"

forvalues i =1995/2011 {

use matrixG/`i'_matrix_G.dta, clear

reshape long g, i(row_c_i) j(col_c_i, string)

split col_c_i, p("_")
rename col_c_i1  col_c
rename col_c_i2 col_i
destring col_c col_i, replace
drop col_c_i rows
gen col_c_i = col_c*100 + col_i

order row_c_i col_c_i g row_c row_i col_c col_i
sort row_c_i col_c_i

gen NMS_exp = 1 if inlist(row_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
gen EU_imp = 1 if inlist(col_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)

gen NMS_imp = 1 if inlist(col_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36)
gen EU_exp = 1 if inlist(row_c, 4, 8, 9, 13, 18, 27, 25, 29, 33, 31, 35, 36, 2,3,11,14,15,10,17,21,22,26,30,32,12,37,16)
gen domestic = 1 if row_c == col_c

foreach x in NMS_exp NMS_imp EU_exp EU_imp domestic {
	replace `x' = 0 if missing(`x')
}

rename g va

save value_added/`i'_value_added.dta, replace