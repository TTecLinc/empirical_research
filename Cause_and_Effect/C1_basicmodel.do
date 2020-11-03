use "C:~",clear
rename tc TC
drop lntc
generate lntc=log(TC)
generate large=(q>=10000) //dummy var
replace large=(q>=6000)
//drop ln* //delete the front is *
display log(2)
display normal(1.96)

constraint def 1 lnpf+lnpk+lnpl=1 //def cons condition def 1
cnsreg lntc lnq lnpl lnpk lnpf, c(1) //def 1
cons def 2 lnq=1
cnsreg lntc lnq lnpl lnpk lnpf, c(1 -2) //def 1 2
//log off log on log close

//return list ereturn list
// r(sd)/r(mean)



regress lntc lnq lnpl lnpk lnpf
vce //cov matrix
regress lntc lnq lnpl lnpk lnpf,noconstant
regress lntc lnq lnpl lnpk lnpf if large //~large large==0
regress lntc lnq lnpl lnpk lnpf if q>=6000 //
predict lntchat //fit value
predict e1,residual
display 1/_b[lnq] // the coff group _b 
test lnq=1
test (lnq=1)(lnpl+lnpk+lnpf=1) //p=0 rej H0
test lnpl lnpk //significance
testnl _b[lnpl]=_b[lnq]^2 //nonlin test
avplots


list TC
summarize TC,detail  
tabulate pl  //cumulative distribution function
pwcorr pl pf pk,sig star(.05) //pairwise correlation, sig(significance), if p<=0.05, then star it.

histogram q,width(1000) frequency //the num of data trap in to each group 
kdensity q //continuous
scatter tc q
gen n=_n
scatter TC q,mlabel(n) mlabpos(6) //6 o'clock poition of the point
twoway (scatter TC q)(lfit TC q)
graph save scatter1
twoway (scatter TC q)(qfit TC q)
graph save scatter2
graph combine scatter1.gph scatter2.gph
help histogram

the detail of the descriptive statistic
describe //descriptive statistic
label data "Nerlove1963" //add the label for the whole data set

/*foreach x of varlist * {
              local vlabel = `x'[1]
              label var `x' "`vlabel'"
			  
}*/
//describe

//list TC Q   //show the data of TC and Q

list TC Q in 1/5
list TC Q in 32/36
list TC Q if q>=10000   //~= is non equal to
drop if q>=10000 //delete the data
keep if q>=10000 //keep the data only q>10000
summarize q //descriptive statistic
summarize q if q>=10000


