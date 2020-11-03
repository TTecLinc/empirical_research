use "~\mus08cigar.dta", clear

* Introduce time effect

gen t = year-62
* LSDV
* i.state: fixed effect
reg lnc lnp lnpmin lny i.state t, vce(cluster state)
estimates store OLS

* Panel Data Modified Std
xtpcse lnc lnp lnpmin lny i.state t
estimates store PCSE

xtpcse lnc lnp lnpmin lny i.state t, corr(ar1)
estimates store AR1

xtpcse lnc lnp lnpmin lny i.state t, corr(psar1)
estimates store PSAR1

esttab OLS PCSE AR1 PSAR1, r2 se mtitles star(* 0.1 ** 0.05 *** 0.01)

* Inter-panel idiosyncratic, corr
xtgls lnc lnp lnpmin lny i.state t, panels(cor) corr(ar1)
xtgls lnc lnp lnpmin lny i.state t, panels(cor) corr(psar1)

* test idio 
xtreg lnc lnp lnpmin lny i.state t, r fe
xttest3

* test auto - in group
tab state, gen(state)
xtserial lnc lnp lnpmin lny state2-state10 t
* test auto - diff group
xttest2
