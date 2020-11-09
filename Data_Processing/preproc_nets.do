insheet using "NETS_AL.csv", clear 

drop if name_nets==""

* Step 1: replace the AND and other characters

replace name_nets=subinstr(name_nets," AND "," & ",.)

replace name_nets = subinstr(name_nets, `"""',  "", .)
local ch_lists "! # $ % ' ( ) * + , - . / : ; < = > ? @ [ \ \ ] ^ _ ` { } ~"
foreach ch of local ch_lists{
di "`ch'"
	replace name_nets=subinstr(name_nets,"`ch'","",.)
}


* Step 2: Change the word
// Upper to Lower
replace name_nets=lower(name_nets)
// Double or Triple Space
replace name_nets=subinstr(name_nets,"   "," ",.)
replace name_nets=subinstr(name_nets,"  "," ",.)
// Strip white spaces at end and front
replace name_nets=strltrim(name_nets)  
replace name_nets=strrtrim(name_nets) 


// Interplay of txt lists to sub the name
python
from sfi import Data
import numpy as np
import os, re, csv
#// 4 files of lists
auxdir=r"results\aux_f"
path = os.path.join(auxdir, "nets_abbr.txt")
with open(path, mode='r') as infile:
	reader = csv.reader(infile)
	nets_abbr = {rows[1]: rows[0] for rows in reader}
path = os.path.join(auxdir, "comp_abbr.txt")
with open(path, mode='r') as infile:
	reader = csv.reader(infile)
	standcomp = {rows[0]: rows[1] for rows in reader}
path = os.path.join(auxdir, "comp_stop.txt")
with open(path, mode='r') as infile:
	reader = csv.reader(infile)
	compstop = {rows[0]: rows[1] for rows in reader}
path = os.path.join(auxdir, "std_abbr.txt")
with open(path, mode='r') as infile:
	reader = csv.reader(infile)
	stdabbr = {rows[0]: rows[1] for rows in reader}	
names=np.array(Data.get("name_nets"))
# // Matching Each Word and Change to Matching in the list
for i in range(len(names)):
	names[i] = re.sub(r"\b(\w+)\b", lambda m: nets_abbr.get(m.group(1), m.group(1)), names[i])
	names[i] = re.sub(r"\b(\w+)\b", lambda m: standcomp.get(m.group(1), m.group(1)), names[i])
Data.store("name_nets", None, names)
end


// Remove Trailing Single Characters
replace name_nets=regexr(name_nets,"([\s]+$)","")

gen name_nets_nocomp=subinstr(name_nets,"&"," ",.)
replace name_nets_nocomp=subinstr(name_nets_nocomp,"   "," ",.)
//------------------------------------------------------------------

// Step3: Clean the name_nets_nocomp

replace name_nets_nocomp=regexr(name_nets_nocomp,"^(\w)\s(\w)\s(\w)\s(\w\s)","\1_\2_\3_\4")
replace name_nets_nocomp=regexr(name_nets_nocomp,"^(\w)\s(\w)\s(\w\s)","\1_\2_\3")
replace name_nets_nocomp=regexr(name_nets_nocomp,"^(\w)\s(\w\s)","\1_\2")
replace name_nets_nocomp=regexr(name_nets_nocomp,"\s&$","")
replace name_nets_nocomp=regexr(name_nets_nocomp,"\s\w$","")


local comlist "corp inc ltd ptnr partnr ptnr llc llp ltd `l lc' `l lp' lp lc co delaware del de `a cal' cal not inc co corp hldg not inc co inc corp ltd"

// Remove Corp / Co at the END of a name
foreach co of local comlist{ 
	replace name_nets_nocomp=regexr(name_nets_nocomp,"`co'","")
	replace name_nets_nocomp=regexr(name_nets_nocomp,"\s\w$","")
	}
	
	
replace name_nets_nocomp=regexr(name_nets_nocomp,"\s\w$","")
replace name_nets_nocomp=regexr(name_nets_nocomp,"\s\w{2}$","")
replace name_nets_nocomp=regexr(name_nets_nocomp,"\s[0-9]+$","")

//remove obs which are just whitespace
//Strip whitespaces again	
drop if name_nets_nocomp==""
replace name_nets_nocomp=subinstr(name_nets_nocomp,"   "," ",.)

replace name_nets_nocomp=strltrim(name_nets_nocomp)
replace name_nets_nocomp=strrtrim(name_nets_nocomp)


//drop NAs
drop if name_nets==""|name_nets_nocomp==""
//drop if cleaned name shorter than 4 characters
gen len_string1=strlen(name_nets)
gen len_string2=strlen(name_nets_nocomp)
drop if len_string1<=4
drop if len_string2<=3