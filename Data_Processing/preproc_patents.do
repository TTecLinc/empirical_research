insheet using "preproc_patents.csv", clear

keep if first_app_year<=2012
drop if state_patent=="GU"
drop if state_patent=="PR"
drop if state_patent=="UM"
drop if state_patent=="VI"

replace state_patent="NE" if state_patent=="NB"

// change the punct
replace name_patent=subinstr(name_patent," AND "," & ",.)

replace name_patent = subinstr(name_patent, `"""',  "", .)
local ch_lists "! # $ % ' ( ) * + , - . / : ; < = > ? @ [ \ \ ] ^ _ ` { } ~"
foreach ch of local ch_lists{
di "`ch'"
	replace name_patent=subinstr(name_patent,"`ch'","",.)
}

//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
// Step 1 : stdandstem function part
replace name_patent=lower(name_patent)
replace name_patent=subinstr(name_patent," and "," & ",.)
replace name_patent=subinstr(name_patent,"   "," ",.)
replace name_patent=subinstr(name_patent,"  "," ",.)
replace name_patent=strltrim(name_patent)
replace name_patent=strrtrim(name_patent)


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
names=np.array(Data.get("name_patent"))
# // Matching Each Word and Change to Matching in the list
for i in range(len(names)):
	names[i] = re.sub(r"\b(\w+)\b", lambda m: nets_abbr.get(m.group(1), m.group(1)), names[i])
	names[i] = re.sub(r"\b(\w+)\b", lambda m: standcomp.get(m.group(1), m.group(1)), names[i])
Data.store("name_patent", None, names)
end

// Remove trailing character
replace name_patent=regexr(name_patent,"\s\w$","")


//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
* Step2: Contrust nocomp variable


gen name_patent_nocomp=subinstr(name_patent,"  "," ",.)

replace name_patent_nocomp=regexr(name_patent_nocomp,"^(\w)\s(\w)\s(\w)\s(\w\s)","\1_\2_\3_\4")
replace name_patent_nocomp=regexr(name_patent_nocomp,"^(\w)\s(\w)\s(\w\s)","\1_\2_\3")
replace name_patent_nocomp=regexr(name_patent_nocomp,"^(\w)\s(\w\s)","\1_\2")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s&$","")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w$","")


local comlist "corp inc ltd ptnr partnr ptnr llc llp ltd `l lc' `l lp' lp lc co delaware del de `a cal' cal not inc co corp hldg not inc co inc corp ltd"

// Remove Corp / Co at the END of a name
foreach co of local comlist{ 
	replace name_patent_nocomp=regexr(name_patent_nocomp,"`co'","")
	replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w$","")
	}
	
	
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w$","")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w{2}$","")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s[0-9]+$","")

//remove obs which are just whitespace
//Strip whitespaces again	
drop if name_patent_nocomp==""
replace name_patent_nocomp=subinstr(name_patent_nocomp,"   "," ",.)

replace name_patent_nocomp=strltrim(name_patent_nocomp)
replace name_patent_nocomp=strrtrim(name_patent_nocomp)

//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
* Step3: Dedup Patents: tf-idf
// Some stata package have the similar function about fuzzy matching or tf-idf, Levenshtein algo: textfind; strgroup; matchit; reclink; reclink2
python
import gc
import pandas as pd
from sfi import Data
from string_grouper import StringGrouper

#//---------------------------------------------------------------------------------------------
def dedup(state, minsim):
	# Create a new StringGrouper
	state.reset_index(drop=True, inplace=True)
	state['allinfo'] = state['name_patent'].str.cat(
		state['city_patent'], sep=", ")
	string_grouper = StringGrouper(state['allinfo'], min_similarity=minsim)
	string_grouper = string_grouper.fit()
	state['uniqname'] = string_grouper.get_groups()
	# Create deduplicated data set
	index = np.array(range(0, len(state)-1))
	cols = ['name_patent', 'first_app_year',
			'city_patent', 'state_patent', 'pat_ids']
	out = pd.DataFrame(index=index, columns=cols)
	out['name_patent'] = state['uniqname'].str.split(', ').str[0]
	out['first_app_year'] = state.groupby(
		'uniqname')['first_app_year'].transform('min')
	out['city_patent'] = state['city_patent']
	out['state_patent'] = state['state_patent']
	out['pat_ids'] = state.groupby(['uniqname'])[
		'pat_ids'].transform(lambda x: ','.join(x))
	out.drop_duplicates(inplace=True)
	return out.reset_index(drop=True)
#//--------------------------------------------------------------------------------
def dedup_patent(patent, minsim):
	# Create deduplicated data frame
	j = 0
	for i, g in patent.groupby('state_patent'):
		j = j+1
		globals()['df_' + str(i)] =  g.copy().reset_index(drop=True)
		globals()['df_' + str(i)] = dedup(globals()['df_' + str(i)], minsim)
		if j ==1:
			newpat = globals()['df_' + str(i)].copy()
		else:
			newpat = newpat.append(globals()['df_' + str(i)], ignore_index=True)
		del globals()['df_' + str(i)]
			
	gc.collect()
	return newpat.reset_index(drop=True)

#// Get the Data From Stata and Reimport to Stata
patent=Data.get()
name_list=[]
num_count = Data.getVarCount()
for i in range(num_count):
	name_list.append(Data.getVarName(i))
patent = pd.DataFrame(patent,columns=name_list)
patent = patent.astype("str")
patent["state_fips"] = patent["state_fips"].astype("float")
patent["first_app_year"] = patent["first_app_year"].astype("int")
patent["county_fips"] = patent["county_fips"].astype("float")
patent = dedup_patent(patent, minsim=0.85)
patent.to_csv('preproc_patents.csv')
end

insheet using "preproc_patents.csv", clear
drop v1


//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
* Step 4: standardize and create stems for new data set
//-----------------------------------------------------------------------------------------------
replace name_patent=lower(name_patent)
replace name_patent=subinstr(name_patent," and "," & ",.)
replace name_patent=subinstr(name_patent,"   "," ",.)
replace name_patent=subinstr(name_patent,"  "," ",.)
replace name_patent=strltrim(name_patent)
replace name_patent=strrtrim(name_patent)


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
names=np.array(Data.get("name_patent"))
# // Matching Each Word and Change to Matching in the list
for i in range(len(names)):
	names[i] = re.sub(r"\b(\w+)\b", lambda m: nets_abbr.get(m.group(1), m.group(1)), names[i])
	names[i] = re.sub(r"\b(\w+)\b", lambda m: standcomp.get(m.group(1), m.group(1)), names[i])
Data.store("name_patent", None, names)
end

// Remove trailing character
replace name_patent=regexr(name_patent,"\s\w$","")

//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
* Step 4.2: Contrust nocomp variable
gen name_patent_nocomp=subinstr(name_patent,"  "," ",.)

replace name_patent_nocomp=regexr(name_patent_nocomp,"^(\w)\s(\w)\s(\w)\s(\w\s)","\1_\2_\3_\4")
replace name_patent_nocomp=regexr(name_patent_nocomp,"^(\w)\s(\w)\s(\w\s)","\1_\2_\3")
replace name_patent_nocomp=regexr(name_patent_nocomp,"^(\w)\s(\w\s)","\1_\2")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s&$","")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w$","")


local comlist "corp inc ltd ptnr partnr ptnr llc llp ltd `l lc' `l lp' lp lc co delaware del de `a cal' cal not inc co corp hldg not inc co inc corp ltd"

// Remove Corp / Co at the END of a name
foreach co of local comlist{ 
	replace name_patent_nocomp=regexr(name_patent_nocomp,"`co'","")
	replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w$","")
	}
	
	
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w$","")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s\w{2}$","")
replace name_patent_nocomp=regexr(name_patent_nocomp,"\s[0-9]+$","")

//remove obs which are just whitespace
//Strip whitespaces again	
drop if name_patent_nocomp==""
replace name_patent_nocomp=subinstr(name_patent_nocomp,"   "," ",.)

replace name_patent_nocomp=strltrim(name_patent_nocomp)
replace name_patent_nocomp=strrtrim(name_patent_nocomp)

// Remove Company Abbreviation

gen name_std_patent=subinstr(name_patent,"&"," ",.)
gen stem_name_patent=subinstr(name_patent,"&"," ",.)
gen stem_std_patent=subinstr(name_std_patent,"&", " ",.)

replace name_patent=regexr(name_patent,"\s\w$","")
replace name_std_patent=regexr(name_std_patent,"\s\w$","")
replace stem_name_patent=regexr(stem_name_patent,"\s\w$","")
replace stem_std_patent=regexr(stem_std_patent,"\s\w$","")

replace name_patent=regexr(name_patent,"\s\w{2}$","")
replace name_std_patent=regexr(name_std_patent,"\s\w{2}$","")
replace stem_name_patent=regexr(stem_name_patent,"\s\w{2}$","")
replace stem_std_patent=regexr(stem_std_patent,"\s\w{2}$","")

gen name_std2_patent=subinstr(name_std_patent,"  ","",.)

// make lower case and strip for the whole list

local name_varlist name_patent name_patent_nocomp name_std_patent stem_name_patent stem_std_patent name_std2_patent city_patent state_patent

foreach name of local name_varlist{
replace `name'=subinstr(`name',"  "," ",.)
replace `name'=subinstr(`name'," & ","&",.)
replace `name'=strltrim(`name')
replace `name'=strrtrim(`name')
replace `name'=lower(`name')
}

//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------

//Step 5: drop if cleaned name shorter than 4 characters

duplicates drop pat_ids, force

//drop NAs
drop if name_patent==""|name_patent_nocomp==""
gen len_string1=strlen(name_patent)
gen len_string2=strlen(name_patent_nocomp)
drop if len_string1<=4
drop if len_string2<=3