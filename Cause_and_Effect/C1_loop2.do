clear

set obs 5
tempvar x y

gen `x'=_n
gen `y'=_N

gen z=`x'+`y'
//edit
* use temp var you have to use `'
sysuse auto,clear

list price length weight in 1/5
local v3 "price length weight"
list `v3' in 1/5


local cmd "list"
`cmd' `v3' in 1/5

local pre "pri"
local suf "ce"
`cmd' `pre'`suf'
tab rep`=26*3'

sysuse auto,clear
global v3 "price length weight"
list $v3 in 1/5
global cmd "list"
$cmd $v3 in 1/5

capture program drop gini 
program gini 
syntax varlist [if] [in] [,title(string)] 
tempvar tinc tp m gini 
marksample touse  // tempvar
preserve 
quietly {
keep if `touse' 
egen `tinc'=sum(`1')
if "`2'"=="" { local 2=1 }

egen `tp'=sum(`2') 
gen `m'=`1'/`2' 
sort `m' 
gen `gini'=1-sum(`2'/`tp'*(2*sum(`1'/`tinc')-`1'/`tinc')) 
}
display as result "`title'：" as error `gini'[_N] 
restore
end

clear
set obs 10
forvalues i=1/5{
	gen v`i'=.
	forvalues j=2(2)8{
	replace v`i'=`i'+`j' in `j'
	}
}
