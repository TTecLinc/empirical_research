use "C:~",clear
//summarize

//pair corr
pwcorr iq s,sig
regress lw s expr tenure rns smsa,r  //Robust Standard Error
reg lw s iq expr tenure rns smsa,r
ivregress 2sls lw s expr tenure rns smsa (iq=med kww mrt age),r
estat overid  //exogenous test
// If the chi^2 too big (p->0) invaild
//ssc install ivreg2 //* install the non-official stat
ivreg2 lw s expr tenure rns smsa (iq=med kww mrt age),r orthog(mrt age) 

//orthog : test the orth(exo) nature of the regress
// C==51.43 C_statistic rej H0
ivregress 2sls lw s expr tenure rns smsa (iq=med kww),r first
// first means the 1st stage conclusion
estat overid //over identification

//2. IV and Endo Corr
estat firststage, all forcenonrobust
ivregress liml lw s expr tenure rns smsa (iq=med kww),r
//LIML : is less senstive to Weak IV
// The cofficient of LIML is closed to 2SLS, which means WIV doesn't exist
ivreg2 lw s expr tenure rns smsa (iq=med kww),r redundant(kww)
//redundant test for KWW var
quietly reg lw iq s expr tenure rns smsa //qui: no show
estimates store ols
qui ivregress 2sls lw s expr tenure rns smsa (iq=med kww)
estimates store iv
hausman iv ols, constant sigmamore
//<5% iq is endogenous
estat endogenous
ivreg2 lw  expr tenure rns smsa (iq=med kww), r endog(iq)
//if iq is endogenous
ivregress gmm lw  expr tenure rns smsa (iq=med kww)
// if heterogenous exists, then GMM is more efficient
estat overid
ivregress gmm lw  expr tenure rns smsa (iq=med kww),igmm
//ssc install estout
qui reg lw s expr tenure rns smsa,r
est sto ols_no_iq
qui reg lw iq s expr tenure rns smsa,r
est sto ols_iq
qui ivregress 2sls lw s expr tenure rns smsa (iq=med kww),r
est sto tsls
qui ivregress liml lw s expr tenure rns smsa (iq=med kww),r
est sto liml
qui ivregress gmm lw s expr tenure rns smsa (iq=med kww)
est sto gmm
qui ivregress gmm lw s expr tenure rns smsa (iq=med kww),igmm
est sto igmm
estimates table ols_no_iq ols_iq tsls liml gmm igmm,b se //b:coff se: std error
esttab ols_no_iq ols_iq tsls liml gmm igmm, se r2 mtitle star(* 0.1 ** 0.05 *** 0.01)
//model name as title
//* rich text format: word format
esttab ols_no_iq ols_iq tsls liml gmm igmm using iv.rtf, se r2 mtitle star(* 0.1 ** 0.05 *** 0.01) 
