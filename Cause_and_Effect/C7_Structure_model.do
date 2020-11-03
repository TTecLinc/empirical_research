use "C:\~",clear

* 3-stage reg
reg3(consump wagepriv wagegovt)(wagepriv consump govt capital1),ols
estimates store OLS

* 2SLS
reg3(consump wagepriv wagegovt)(wagepriv consump govt capital1),2sls
estimates store SLS

* 3SLS
reg3(consump wagepriv wagegovt)(wagepriv consump govt capital1),first
* first: the 1st stage: endo-IV
estimates store TSLS

* Iteration 3SLS
reg3(consump wagepriv wagegovt)(wagepriv consump govt capital1),ireg3
* first: the 1st stage: endo-IV
estimates store TSLS_it
* note that * and # esist a blank!
esttab OLS SLS TSLS TSLS_it, r2 mtitles star(* 0.1 ** 0.05 *** 0.01)

