# -*- coding: utf-8 -*-
"""
Created on Sat Nov  7 11:12:41 2020

@author: Peilin Yang
"""

import pandas as pd
import re, csv, os, pickle
from nltk.stem.snowball import SnowballStemmer
import numpy as np

def punct(nets):
	nets['name_NETS'] = nets['name_NETS'].str.replace(' AND ', ' & ')
	punct = '!"#$%\'()*+,-./:;<=>?@[\\]^_`{}~'   # `|` and '&' is not present here
	transtab = str.maketrans(dict.fromkeys(punct, ''))

	return nets.assign(name_NETS=nets['name_NETS'].str.translate(transtab))

def stdandstem(nets, auxdir):

	# Load Dictionaries 
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

	# Define cleaning functions
	def unab_nets(name):
		name = re.sub(
			r"\b(\w+)\b", lambda m: nets_abbr.get(m.group(1), m.group(1)), str(name))
		return name

	def std_comp(name):
		name = re.sub(
			r"\b(\w+)\b", lambda m: standcomp.get(m.group(1), m.group(1)), str(name))
		return name

	def rm_comp(name):
		name = re.sub(
			r"\b(\w+)\b", lambda m: compstop.get(m.group(1), m.group(1)), str(name))
		return name

	def std_abbr(name):
		name = re.sub(
			r"\b(\w+)\b", lambda m: stdabbr.get(m.group(1), m.group(1)), str(name))
		return name

	def stem_names(sentence):
		stemmer = SnowballStemmer("english")
		tokens = sentence.split()
		stemmed_tokens = [stemmer.stem(token) for token in tokens]
		return ' '.join(stemmed_tokens).lower()
	
	# make all lower case
	nets['name_NETS'] = nets['name_NETS'].str.lower()

	# Standardize some things:
	# Change & into "and"
	nets['name_NETS'] = nets['name_NETS'].str.replace(' and ', '&')

	# Remove double spaces
	nets['name_NETS'] = nets['name_NETS'].str.replace('   ', ' ')
	nets['name_NETS'] = nets['name_NETS'].str.replace('  ', ' ')

	# Strip white spaces at end and front
	nets['name_NETS'] = nets['name_NETS'].str.strip()

	# Undo NETS specific abbreviations
	nets['name_NETS'] = nets['name_NETS'].apply(unab_nets)

	# Standardize Company Names
	nets['name_NETS'] = nets['name_NETS'].apply(std_comp)

	# Remove Trailing Single Characters
	nets['name_NETS'] = [re.sub(r'\s\w$','', str(x)) for x in nets['name_NETS']]

	nets['name_NETS_nocomp'] = nets['name_NETS'].str.replace('&', ' ')
	nets['name_NETS_nocomp'] = nets['name_NETS_nocomp'].str.replace('  ', ' ')
	nets = cleaner(nets, 'name_NETS_nocomp')

	# Remove Company abbreviations
	nets['name_std_NETS'] = nets['name_NETS'].str.replace('&', ' ')
	nets['name_std_NETS'] = nets['name_std_NETS'].str.replace('  ', ' ')
	nets['name_std_NETS'] = nets['name_std_NETS'].apply(rm_comp)

	nets['stem_name_NETS'] = nets['name_NETS'].str.replace('&', ' ')
	nets['stem_name_NETS'] = nets['stem_name_NETS'].str.replace('  ', ' ')
	nets['stem_name_NETS'] = nets['stem_name_NETS'].apply(rm_comp)

	# Standardize other words
	nets['name_std_NETS'] = nets['name_std_NETS'].apply(std_abbr)

	# Remove Trailing Single and Double Characters
	nets['name_std_NETS'] = [re.sub(r'\s\w$','', str(x)) for x in nets['name_std_NETS']]
	nets['name_std_NETS'] = [re.sub(r'\s\w{2}$','', str(x)) for x in nets['name_std_NETS']]

	# Stem words
	nets['stem_std_NETS'] = nets['name_std_NETS'].apply(stem_names)
	nets['stem_name_NETS'] = nets['stem_name_NETS'].apply(stem_names)
	
	# Remove all white space 
	nets['name_std2_NETS'] = nets['name_std_NETS'].str.replace(' ','')

	nets = nets.applymap(lambda x: x.replace('  ', ' ') if isinstance(x, str) else x)
	nets = nets.applymap(lambda x: x.replace(' & ', ' ') if isinstance(x, str) else x)

	# Make sure all variables are stripped and lower cased
	nets = nets.applymap(lambda x: x.strip() if isinstance(x, str) else x)
	nets = nets.applymap(lambda x: x.lower() if isinstance(x, str) else x)

	return nets

def cleaner(df, name):
	comlist = ['corp','inc','ltd ptnr','partnr', 'ptnr' 'llc', 'llp', 
		'ltd', 'l lc','l lp', 'lp', 'lc', 'co', 'delaware', 'del', 'de', 'a cal', 'cal',
		'not','inc','co','corp','hldg', 'not', 'inc', 'co','inc','corp', 'ltd']   
	
	df[name] = [re.sub(r'^(\w)\s(\w)\s(\w)\s(\w\s)', r'\1_\2_\3_\4', str(x)) for x in df[name]]
	df[name] = [re.sub(r'^(\w)\s(\w)\s(\w\s)', r'\1_\2_\3', str(x)) for x in df[name]]
	df[name] = [re.sub(r'^(\w)\s(\w\s)', r'\1_\2', str(x)) for x in df[name]]
	df[name] = [re.sub(r'\s&$', '', str(x)) for x in df[name]]

	# Remove Corp / Co at the END of a name
	for item in comlist:
		# Remove trailing single character
		df[name] = [re.sub(r'\s\w$','', str(x)) for x in df[name]]

		rec = re.compile(r'\s*(' + re.escape(item) + ')$')    
		df[name] = [re.sub(rec,'', str(x)) for x in df[name]]
		df[name] = [re.sub(r'\s\w$','', str(x)) for x in df[name]]

	# Remove trailing single character
	df[name] = [re.sub(r'\s\w$','', str(x)) for x in df[name]]
	
	# Remove trailing double character
	df[name] = [re.sub(r'\s\w{2}$','', str(x)) for x in df[name]]

	# Remove trailing numbers
	df[name] = [re.sub(r'\s[0-9]+$','', str(x)) for x in df[name]]

	# remove obs which are just whitespace
	df[name].replace('', np.nan, inplace=True)
	df[name].dropna(inplace=True)

	# Strip whitespaces again	
	df[name] = df[name].str.replace('  ', ' ')
	df[name] = df[name].str.strip()

	return(df)

#----------------------------------------------------------------------------------------------------------
nets_compare = pd.read_csv("NETS_AL.csv")

nets = pd.read_csv("NETS_AL.csv")
nets['name_NETS'].dropna(inplace=True)

# remove punctuation
nets = punct(nets)

# standardize and create stems
nets = stdandstem(nets, 'results/aux_f/')
# drop NAs
nets['name_NETS'].dropna(inplace=True)
nets['name_std_NETS'].dropna(inplace=True)
# drop if cleaned name shorter than 4 characters
nets = nets[nets['name_NETS'].map(lambda x: len(str(x)) > 4)].copy()
nets = nets[nets['name_NETS_nocomp'].map(lambda x: len(str(x)) > 3)].copy()
nets.reset_index(inplace=True, drop=True)

pickleloc = 'results/results/dict.nets'
pickle_out = open(pickleloc,"wb")
pickle.dump(nets, pickle_out)
pickle_out.close()
