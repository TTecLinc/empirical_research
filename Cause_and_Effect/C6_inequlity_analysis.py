# -*- coding: utf-8 -*-
"""
Created on Sat Oct 10 13:54:49 2020

@author: Peilin Yang
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

plt.style.use('ggplot')


# Problem 1

# Get wealth
#'''
data=pd.read_csv('RA_21_22.csv')
data['wealth']=data['asset_total']-data['debt_total']
data['housing_wealth']=data['asset_housing']-data['debt_housing']

race_edu = data.groupby([data['year'],data['race'],data['education']])

race_edu_median=race_edu.median()

race_edu_median.to_csv('median.csv')


race_edu_median=pd.read_csv('median.csv')

race = race_edu_median['race'].unique()
edu = race_edu_median['education'].unique()


for racei in race:
    plt.figure()
    for edui in edu:
        race_edui=race_edu_median[(race_edu_median['race']==racei)&
                                           (race_edu_median['education']==edui)]
        plt.plot(race_edui['year'],race_edui['wealth'],label=racei+','+edui)
    plt.legend()
    plt.savefig(racei+','+edui+'Problem 1.png', dpi=1500)
# Problem 2: Housing Wealth
        
for racei in race:
    plt.figure()
    for edui in edu:
        race_edui=race_edu_median[(race_edu_median['race']==racei)&
                                           (race_edu_median['education']==edui)]
        plt.plot(race_edui['year'],race_edui['housing_wealth'],label=racei+','+edui)
    plt.legend()
    plt.savefig(racei+','+edui+'Problem 2.png', dpi=1500)

# Problem 3
data=pd.read_csv('RA_21_22.csv')
# For age 25 or older and houseowners
data=data[(data['age']>=25)&(data['asset_housing']>0)]
data['wealth']=data['asset_total']-data['debt_total']
data['housing_wealth']=data['asset_housing']-data['debt_housing']
data['nonhousing_wealth']=data['wealth']-data['housing_wealth']

race_house=data.groupby([data['year'],data['race']])
race_house_median=race_house.median()

# Black and White

race_house_median.to_csv('race_house_median.csv')
race_house_median=pd.read_csv('race_house_median.csv')

race=['black','white']
for racei in race:
    race_house_edui=race_house_median[race_house_median['race']==racei]
    plt.plot(race_house_edui['year'],race_house_edui['housing_wealth'],label=racei)
plt.legend()
plt.title('Housing Wealth')
plt.figure()
for racei in race:
    race_house_edui=race_house_median[race_house_median['race']==racei]
    plt.plot(race_house_edui['year'],race_house_edui['nonhousing_wealth'],label=racei)

plt.legend()
plt.title('Non-housing Wealth')
# Loss of Housing Wealth
race_house_black=race_house_median[race_house_median['race']=='black']
race_house_white=race_house_median[race_house_median['race']=='white']
# Proportion and Dollar
race_house_black_loss = float(race_house_black['housing_wealth'][race_house_black['year']==2016])-float(
    race_house_black['housing_wealth'][race_house_black['year']==2007])
race_house_white_loss = float(race_house_white['housing_wealth'][race_house_white['year']==2016])-float(
    race_house_white['housing_wealth'][race_house_white['year']==2007])

p_race_house_black_loss=abs(race_house_black_loss/float(race_house_black['housing_wealth'][race_house_black['year']==2007]))
p_race_house_white_loss=abs(race_house_white_loss/float(race_house_white['housing_wealth'][race_house_white['year']==2007]))

print('Dollar Loss')
print('Black',race_house_black_loss)
print('White',race_house_white_loss)
print('Proportion Loss')
print('Black',p_race_house_black_loss)
print('White',p_race_house_white_loss)




