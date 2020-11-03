use "C:", clear
* Set Time and Individual
xtset state year

xtdescribe
* T<n Short Panel
xtsum fatal beertax spircons unrate perinck state year
* xtline fatal

* Mix regression
* Cluster Robust Error
reg fatal beertax spircons unrate perinck, vce(cluster state)
estimates store OLS
xtreg fatal beertax spircons unrate perinck,fe r
estimates store FE_robust

reg fatal beertax spircons unrate perinck i.state, vce(cluster state)
estimates store LSDV

tab year, gen(year)
xtreg fatal beertax spircons unrate perinck year2-year7,fe r
estimates store FE_TW
xtreg fatal beertax spircons unrate perinck i.year,fe r

*Husman Test
hausman FE RE,constant sigmamore