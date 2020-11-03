* use "C:~,clear


/*
* Date Variable 
webuse destring1, clear
des
sum
destring, replace
* replace all
sum
gen nincom=income*1.3
list nincom income
*/



/*
set obs 1
gen a=1
* compress the data
compress
replace a=101
gen double b=1 
* double pricise
recast double a 
* missing value to data encode
mvencode _all, mv(1)
* data to missing data decode
mvdecode _all, mv(1)

* summarize
sum price weight 
* by group: describe sum
by foreign: sum price weight
* *by X X is the object that is ordered, no sort price
sort foreign price
gen nprice=price+10
list price nprice
replace nprice=nprice-10
list price nprice
* & | ~
list make price if foreign==1 & price>10000 
sum price in 1/10 if foreign==0, detail
* By weight
//sum price[weight=num]
list price in 1/30,sep(10)
list price, nohead
*/

/*
webuse destring2, clear
describe
list date
* ignore the non-vaule word
destring date, replace ignore("")
list date
destring price percent, gen(price2 percent2) ignore("$,%")
list


webuse tostring, clear
tostring year day,replace
des 
list
gen date1=month+"/"+day+"/"+year
list
gen date2=date(date1,"mdy")
list


format state %-14s
* left aligned
list in 1/4
format state %-8.0g



insheet using 3origin.csv, clear 
insheet using 3origin.txt, double clear 
infile id str10 name gender minority economy math using origin.txt, clear 
* some file is fixed format like 012345 002345
* 1 2 are the numbers of start position
infix gender 1 minority 2 economy 3-4 math 5-6 using origin.csv, clear
outsheet using .txt
* no name in the first line
outsheet using myresult.asc, nonames 
* replace the exist file
outsheet using myresult.asc, nonames replace 
*/
* no exist then create
capture mkdir d:/mydata 
renpfix var v
* Change the first
rename v4 minority 
label data "---"
label var id "---"
label define genderlb 1 "A" 2 "B"
label define minoritylb 3 "Noknow", add 
label drop minoritylb 
label dir 



