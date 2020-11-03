/*
clear
capture drop count5
* use the count5

program count5
* define value without `', but operate the value use `'
local i=1
while `i'<=5{
display `i'
local i=`i'+1
}
end

forvalues i=1/5{
display `i'
}
forvalues i=4(-0.2)0{
display `i'
}
scalar s=0
forvalues i=1/100{
scalar s=s+`i'
}
scalar list s

foreach v of varlist nonwhite-servocc{                                  
tab `v’      
}
foreach file in economy math {      
append using "`file'"       
}
foreach file in `flist’ {      
append using "`file'"    
} 
local flist economy math 
foreach file in `flist’ {      
append using "`file'"     
} 
local grains “rice wheat flax maize” 
foreach x of local grains {        di “`x’”   } 
 
global money “Dollar Lira Pound RMB” 
foreach y of global money {         di “`y’”   } 

set obs 10 
foreach v of newlist b1-b5 { 
gen `v'=uniform() 
}

foreach num of numlist 1/4 8 105 { di `num' } 
*/
clear
set obs 10
forvalues i=1/5{
	gen v`i'=.
	forvalues j=2(2)8{
	* In row j and col i
		replace v`i'=`i'+`j' in `j'
	}
}
* C++ ?!
* gen p1=price-100 if forein==0 replace p1=price+100 if foreign==1 is the same as following
gen p2=cond(foreign==0,(price-100),(price+100)) 

capture program drop odd 
program odd 
args num if int(`num’ /2)!=(`num’-1)/2 {  
display “num is NOT an odd number”         
} else {       display “num IS an odd number” 
} end 


capture program drop check program check capture confirm variable `1’ if _rc!=0 {        display “`1’ not found”        exit      } display “the variable `1’ exists.” end 
forvalues x=6/200 {   if mod(`x’,2)==0 & mod(`x’,3)==0 & mod(`x’,5)==0 {           di “the ALL common multiple of 2,3 ,and 5 is  `x’ “     } } 

forvalues x=6/500 {    if mod(`x’,2)==0 & mod(`x’,3)==0 & mod(`x’,5)==0 {         di “the LEAST common multiple of 2,3 ,and 5 is  `x’ “         continue, break     } } 








