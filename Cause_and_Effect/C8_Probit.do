use "C:`",clear

reg work age married children education,r

* Logit Estimate

logit work age married children education,nolog

logit work age married children education,nolog r
* Not exist model setting problem

logit work age married children education,or nolog

margins, dydx(*)

margins, dydx(*) atmeans

margins, dydx(age) at (age=30)

estat clas

logit work age married children education,nolog vce(cluster age)

probit work age married children education,nolog

margins, dydx(*)

estat clas
