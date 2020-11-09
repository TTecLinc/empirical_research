clear
input str10 income 
"abc"
"ab"
"aa"
"abcd"
"aad"
"aab123"
"cdf12345"
"123"
"Abc"
end

gen index1 = regexm(income,"[0-9]") 

clear
input str3 num str2 name str10 per str6 income
           -1       a          "10 %"    "[974 7"
            1       b          "62%"    "1,234"
            1       a          "53%"    "938.9"
           -1       c          "48,6%"  "*8344"
            2       d          "58%"    "2398"
           -2       e          "46%"    "-"
           -3       c          "78%"    "53822"
            3       d          "92,2%"  "na"
           -1       e          "65%"    "$28477"
            1       b          "3,6%"   "n/a"
end

* Contain Non-Num
gen index1 = ustrregexm(income,"\D") 
* Contain Only-Num
gen index2 = ustrregexm(income,"\d") 
//gen index1 = regexm(income,"\\$")  
//gen index2 = regexm(income,"[\$]")
//gen index3 = regexm(income,"[$]")
//gen index4 = regexm(income,"[`=char(36)']") 
//gen index5 = regexm(income,"\*")            
//gen index6 = regexm(income,"[\*|\[]")


clear
input str10 income 
"abc"
"ab"
"aa"
"abcd"
"aad"
"a1"
"aab123"
"cdf12 345"
"cdf12  345"
"123"
end
gen index1 = regexm(income, "(^[a-z]+)([0-9]+)([ ])([ ])([0-9]+$)")
gen index2 = regexm(income, "([ ]+)([0-9]+$)")


clear
input str50 income 
"abc"
"ab"
"aa"
"1 aaa  b"
"aa2"
"a 123 456 666"
"aab 123  666 "
"cdf12   345666666  "
"123"
end

//gen index1 = ustrregexm(income, "[a]{1}") 
//gen index2 = ustrregexm(income, "[a]{2}") 
//gen index3 = ustrregexm(income, "[0-9]{2}")
//gen index4 = ustrregexm(income, "[0-9]{3}")
//gen index5 = ustrregexm(income, "[0-9]{4}")
//gen index6 = ustrregexm(income, "[0-9]{1,3}") /*1=<x<=3*/
//gen index7 = ustrregexm(income, "[0-9]{4,5}")
//gen index8 = ustrregexm(income, "[0-9]+") /*>0*/
//gen index9 = ustrregexm(income, "[0-9]*") /*0 or more*/
//gen index10 = ustrregexm(income, "[0-9]?") /*0|1*/
//gen index11 = ustrregexm(income, "^[0-9]") 
//gen index12 = ustrregexm(income, "(^[a-z]+)[1]$") 
//gen index13 = ustrregexm(income, "(^[a-z]+)[0-9]$")
gen index66 = regexm(income,"([ ])([0-9]$)")
gen index666 = regexm(income,"([a-z]+)(.*)([0-9]$)")
