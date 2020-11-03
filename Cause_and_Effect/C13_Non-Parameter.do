use "~\mpyr.dta", clear

* kernal regression
* ivankerny kernal (k=3);
* grid=100
kernreg1 logv r, k(3) np(100) gen(logv_kern r_grid)

//graph twoway (scatter logv r)(lfit logv r, lpattern("-"))(line logv_kern r_grid)

* optimal band
dis $s_1

* k near
knnreg logv r, knum(10) gen(logv_kkern)
//graph line logv_kern r

lpoly logv r, b($s_1) degree(1) gen(logv_lkern r_lgrid)
lowess logv r, b($s_1) gen(logv_lkess)
graph twoway (scatter logv r)(lfit logv r, lpattern("-"))(line logv_kern r_grid)(line logv_kkern r, sort lp("-"))

use "~\nerlove.dta", clear

reg lntc lnq lnpl lnpk lnpf,r
est sto reg

* Semi-Para
* ci: confidence internal
semipar lntc lnq lnpl lnpk, nonpar(lnpf) robust xtitle(lnPF) ytitle(lnTC) ci
est sto semipar
