use "C:~",clear
* Regard 0.5 as discontinuty 
//rd lne d, mbw(100)

//rd lne d, mbw(100) cov(i votpop black blucllr farmer fedwrkr forborn manuf unemplyd union urban veterans)
* Use cov to control the robust natrure of the RDD

//rd lne d, gr bdep oxline

rd lne d, mbw(100) x(i votpop black blucllr farmer fedwrkr forborn manuf unemplyd union urban veterans)

sysdir

DCdensity d, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) graphname(rd.eps)

* Fuzzy RDD
set seed 10101
gen ranwin =cond(uniform()<0.1,1-win,win)
tab ranwin win

rd lne ranwin d, gr mbw(100)
