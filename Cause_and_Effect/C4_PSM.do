* Peilin Yang
* PSM Method

use "C:",clear

reg re78 t,r

reg re78 t age educ black hisp married re74 re75 u74 u75,r

* PSM
set seed 10101
gen ranorder = runiform()
sort ranorder
* One by one, replacement, allow two
psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) n(1) ate ties logit common

pstest age educ black hisp married re74 re75 u74 u75,both graph

*set seed 10101
*bootstrap r(att)r(atu)r(ate), reps(500): psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) n(1) ate ties logit common
psgraph
* K match
psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) n(4) ate ties logit common

psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) n(4) cal(0.01) ate ties logit common

psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) n(4) radius cal(0.01) ate ties logit common

psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) n(4) radius kernel ate ties logit common

set seed 10101

*bootstrap r(att)r(atu)r(ate), reps(500): psmatch2 t age educ black hisp married re74 re75 u74 u75, outcome(re78) spline ate ties logit common

psmatch2 t, outcome(re78) mahal(age educ black hisp married re74 re75 u74 u75) n(4) ai(4) ate