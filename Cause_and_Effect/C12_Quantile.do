use "~\grilic.dta", clear

reg lw s iq expr tenure rns smsa, r

* half
qreg lw s iq expr tenure rns smsa, nolog


// make the median of the wage increase 10% along with the edu s

set seed 10101
//bsqreg lw s iq expr tenure rns smsa, reps(50) q(.5)

* 10% 50% 90%
* nodots: show no dots in sample
sqreg lw s iq expr tenure rns smsa, reps(50) q(.1 .5 .9)nodots

* F test: if coeffcient of s is homogeneous for 3
test [q10=q50=q90]: s

qui reg lw s iq expr tenure rns smsa
est sto OLS
qui qreg lw s iq expr tenure rns smsa, q(.1)
est sto QR_10
qui qreg lw s iq expr tenure rns smsa, q(.5)
est sto QR_50
qui qreg lw s iq expr tenure rns smsa, q(.9)
est sto QR_90
esttab OLS QR_10 QR_50 QR_90, se mtitle star(* 0.1 ** 0.05 *** 0.01)

* The relationship of coeffcient and quantile
qui bsqreg lw s iq expr tenure rns smsa, reps(50) q(.5)
grqreg, cons ci ols olsci