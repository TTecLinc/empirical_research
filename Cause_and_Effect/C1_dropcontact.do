* use "C:", clear
* drop gender
* keep id economy

use "C:",clear

append using "C:"

* drop all lebel
foreach var of varlist _all {
        label var `var' ""
}
* drop all value label
label drop _all
* drop aggreated label
label data `'
save data_2061, replace

use "", clear
keep economy id 
save economy
use "\data_2061.dta", clear
keep math id 
save math
use "\data_2061.dta", clear
drop math economy
save student

use "C:",clear
* Before we merge the data we should sort
sort id
save economy,replace
use student, clear
sort id
merge id using economy
* show the situation of merging
tab _merge
drop _merge
sort id
save mydata2,replace
use math,clear
sort id
merge id using mydata2
drop _merge
save mydata2, replace

use mywide, clear
* id name are the columns that needs to be repeated
* j is new column
reshape long math economy, i(id name) j(year)
reshape wide
* stack operation
stack var1-var6, into(x) clear 
drop _stack 
xpose,clear

clear 
input str15 x 
"10*123" 
"543*21" 
"12*422" 
"43532*32134" 
"4349*1" 
end 
* position of *
* select a part from the string
gen a=strpos(x,"*") 
gen b=substr(x,1,a-1) 
gen c=substr(x,a+1,.)
