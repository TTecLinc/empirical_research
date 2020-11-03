* Did: Control the group-effect and time-specific effect
* G*D+G+D
* y_it = b0 + b1*x_it+b2 * G_i+ gamma.*D+e;
* Gurantee the x is no corr with e
* ssc install diff
use "C:~",clear
* Use the principle
gen gd=t*treated
reg fte gd treated t,r
diff fte, treated(treated) period(t) robust

reg fte gd treated t bk kfc roys,r
* covariate variable
diff fte, t(treated) p(t) cov(bk kfc roys) robust
diff fte, t(treated) p(t) cov(bk kfc roys wendys) test
* test the mean in controled and treated

