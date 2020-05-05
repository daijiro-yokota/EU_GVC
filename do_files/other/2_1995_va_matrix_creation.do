******* Do-File #2 *******

*** Matrix G: g2301-g2335 for Japan=23 in 1995 ****

* These codes create our main VA matrix G from WIOT 1995. *
* The matrix shows VA created from each country's 35 industry to each other. *
* The WIOT_1995 file is created in do-file #4 from the WIOT_original. *
* All the matrix used to create G are created in do files #5-9 *

clear all
cd "/Users/dyokota/Desktop/Daijiro_Final/WIOT/1995"

use WIOT_1995.dta, clear

do 4_matrices.do

mata

v = w*invsym(xhat)
vhat = diag(v)
A = Z*invsym(xhat)

G=J(1435, 35, .)

a=1

while (a<36){
	F230a=Fe[.,a]
	g230a = vhat*luinv(I(1435)-A)*F230a
	G[.,a]=g230a
	a++
}

st_matrix("matrix_G", G)
end

svmat matrix_G, names(g)

save 1995_matrix_G.dta, replace

*** Matrix G to VA for Japanese industries by country ****

* These codes create VA to Japanese industries from WIOT in 1995. *
* The codes repeat the same process for excluding ROW. *

use 1995_matrix_G.dta, clear

gen c_i_code =_n
gen country=.

local k=1
forvalues i=1/41 {
	local j=`i'*35
	replace country=`i' if inrange(c_i_code, `k', `j')
	local k=`j'+1
}

bysort country: gen industry=_n
drop c_i_code

* collapse:
collapse (sum) g1-g35, by(country)

* total imported va
forvalues i=1/35 {
	egen total_imp_va_`i'=sum(g`i')  if country!=23
}

forvalues i=1/35 {
	egen temp = mean(total_imp_va_`i')
	replace total_imp_va_`i'=temp  if country==23
	drop temp
}

* total va :
forvalues i=1/35 {
	egen total_va_`i'=sum(g`i')
}

* foreign country dependence share among total imported va :
forvalues i=1/35 {
	gen c_dep_`i' = g`i'/total_imp_va_`i' if country!=23
}

* domestic dependence :
forvalues i=1/35 {
	gen d_dep_`i' = g`i'/total_va_`i' if country==23
}

* gvc dependence:
forvalues i=1/35 {
	gen gvc_dep_`i' = total_imp_va_`i'/total_va_`i'
}

save 1995_japan_VA_with_ROW.dta, replace


** Without ROW **

use 1995_matrix_G.dta, clear

gen c_i_code =_n
gen country=.

local k=1
forvalues i=1/41 {
	local j=`i'*35
	replace country=`i' if inrange(c_i_code, `k', `j')
	local k=`j'+1
}

bysort country: gen industry=_n
drop c_i_code

* collapse:
collapse (sum) g1-g35, by(country)

* total imported va including ROW
forvalues i=1/35 {
	egen total_imp_va_`i'=sum(g`i')  if country!=23 
}

forvalues i=1/35 {
	egen temp = mean(total_imp_va_`i')
	replace total_imp_va_`i'=temp  if country==23
	drop temp
}

* total va :
forvalues i=1/35 {
	egen total_va_`i'=sum(g`i')
}

* foreign country dependence share among total imported va :
forvalues i=1/35 {
	gen c_dep_`i' = g`i'/total_imp_va_`i' if country!=23 & country!=41
}

* domestic dependence :
forvalues i=1/35 {
	gen d_dep_`i' = g`i'/total_va_`i' if country==23
}

* gvc dependence excluding ROW:
forvalues i=1/35 {
	egen limited_imp_va_sum_`i'=sum(g`i')  if country!=23 
}

forvalues i=1/35 {
	gen gvc_dep_`i' = limited_imp_va_sum_`i'/total_va_`i'
}

save 1995_japan_VA_without_ROW.dta, replace
