// A simulation of decomposing OLS coefficient

clear
set obs 100
gen rand_num=invnorm(uniform())*1 //variance is 1
gen S=6*(uniform()-0.5)

//beta: 1; mu: 0.6
gen y=0.6+2*S+rand_num

qui reg y S

correlate S y, covariance
* Position 1,2: same as Cov_Sy/var_SS=coefficient
local cov_Sy=r(cov_12)
local var_SS=r(cov_11)
local varyy=r(cov_22)


gen d1=0
gen d2=0
gen d3=0
gen d4=0
gen d5=0


replace d1=1 if S>=-2
replace d2=1 if S>=-1
replace d3=1 if S>=0
replace d4=1 if S>=1
replace d5=1 if S>=2

//-------------------------------------------------------------
// Generate Marginal Effect: ME

qui reg y d1 d2 d3 d4 d5
mat me_ols=e(b)
forvalues x=1/5{
gen me_`x'=me_ols[1,`x']
}

//-------------------------------------------------------------
// Generate Selection Bias
predict re_ols,re
correlate re_ols S,covariance
gen phi=r(cov_12)
su S
replace phi=phi/r(Var)

//-------------------------------------------------------------
// Generate Weight Vector

forvalues x=1/5{
qui reg d`x' S
matrix cof = e(b)
gen w_`x'=cof[1,1]
}

//-------------------------------------------------------------
// Generate Weight Vector:*ME Vector
gen sum_me=0
forvalues x=1/5{
replace sum_me=sum_me+w_`x'*me_`x'
}
gen sum_me_selection_bias=sum_me+phi

su sum_me
su sum_me_selection_bias
reg y S
