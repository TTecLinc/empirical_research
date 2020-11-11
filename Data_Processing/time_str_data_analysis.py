"""
@author: Peilin Yang
"""
import pandas as pd
import re
import datetime

from datetime import datetime, date
import datetime

data=pd.read_csv('test_data.txt')

def split_re(string):
    return re.split(r'( )',string)

# Replace the " noon "
data['shiftid']=data['shiftid'].str.replace ( 'noon' , '12 a.m.' )
date_time=pd.DataFrame(list(data['shiftid'].apply(split_re)))

data['shift_date']=date_time[0]
data['shift_starttime_h']=date_time[2]
data['shift_starttime_ampm']=date_time[4]
data['shift_endtime_h']=date_time[8]
data['shift_endtime_ampm']=date_time[10]

data['shift_start']=data['shift_date']
data['shift_end']=data['shift_date']

# Replace all the P.M. to the 24 hours format
# Function 
for i in range(len(data)):
    if data['shift_starttime_ampm'][i]=='p.m.':
        data['shift_start'][i]=str(data['shift_date'][i]+" "+str(data['shift_starttime_h'][i]+12)+":00")
    else:
        data['shift_start'][i]=str(data['shift_date'][i]+" "+str(data['shift_starttime_h'][i])+":00")
    # Shift End: Change the time to Std Mode
    # The Span of Day 24
    if data['shift_starttime_ampm'][i]=='p.m.' and data['shift_endtime_ampm'][i]=='a.m.':
        dt =datetime.datetime.strptime(data['shift_date'][i], "%Y/%m/%d")
        out_date = (dt + datetime.timedelta(days=1)).strftime("%Y/%m/%d")
        data['shift_end'][i]=str(out_date+" "+str(data['shift_endtime_h'][i])+":00")
    elif data['shift_endtime_ampm'][i]=='p.m.':
        data['shift_end'][i]=str(data['shift_date'][i]+" "+str(data['shift_endtime_h'][i]+12)+":00")
    else:
        data['shift_end'][i]=str(data['shift_date'][i]+" "+str(data['shift_endtime_h'][i])+":00")

#--------------------------------------------------------------------------------------------------------------------
# Problem 1: Caculate 
# IF 'early_time'<0 then we name it early than Patients
num=0
data['early_time']=0.00
for i in range(len(data)):
    data['early_time'][i]=(datetime.datetime.strptime(data['ed_tc'][i], "%Y/%m/%d %H:%M") - datetime.datetime.strptime(data['shift_start'][i], "%Y/%m/%d %H:%M")).total_seconds()/60/60
    if data['early_time'][i]<0 or data['shift_end_dcord_tc'][i]>0:
        num+=1
#--------------------------------------------------------------------------------------------------------------------
# Problem 2: Patients Mode

def split_re(string):
    return re.split(r'[ :]',string)
date_time=pd.DataFrame(list(data['ed_tc'].apply(split_re)))
data['arrivetime']=date_time[1]

data['shift_end_dcord_tc']=data['shift_date']

# 'shift_end_dcord_tc' is the difference and leaving time
for i in range(len(data)):
    data['shift_end_dcord_tc'][i]=(datetime.datetime.strptime(data['dcord_tc'][i], "%Y/%m/%d %H:%M") - datetime.datetime.strptime(data['shift_end'][i], "%Y/%m/%d %H:%M")).total_seconds()/60/60
    
#--------------------------------------------------------------------------------------------------------------------
# Problem 3: Generate Index
data['Index']=data['shift_date']

for i in range(len(data)):
    data['Index'][i]=min(int(data['shift_end_dcord_tc'][i]),3)

#--------------------------------------------------------------------------------------------------------------------
# Problem 4: Regression Data Pre-Processing
data['real_time']=0.00
data['working_time']=0.00
for i in range(len(data)):
    data['real_time'][i]=(datetime.strptime(data['dcord_tc'][i], "%Y/%m/%d %H:%M") - datetime.strptime(data['ed_tc'][i], "%Y/%m/%d %H:%M")).total_seconds()/60/60
    # Working Time
    data['working_time'][i]=(datetime.strptime(data['dcord_tc'][i], "%Y/%m/%d %H:%M") - datetime.strptime(data['shift_start'][i], "%Y/%m/%d %H:%M")).total_seconds()/60/60
    # Time Fix Effect



