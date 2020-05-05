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