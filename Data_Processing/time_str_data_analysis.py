"""
@author: Peilin Yang

A method of tackle with time Series data

difference and conversion
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

num=0
data['early_time']=0.00
for i in range(len(data)):
    data['early_time'][i]=(datetime.datetime.strptime(data['ed_tc'][i], "%Y/%m/%d %H:%M") - datetime.datetime.strptime(data['shift_start'][i], "%Y/%m/%d %H:%M")).total_seconds()/60/60
    if data['early_time'][i]<0 or data['shift_end_dcord_tc'][i]>0:
        num+=1

def split_re(string):
    return re.split(r'[ :]',string)
date_time=pd.DataFrame(list(data['ed_tc'].apply(split_re)))
data['arrivetime']=date_time[1]

data['shift_end_dcord_tc']=data['shift_date']

# 'shift_end_dcord_tc' is the difference and leaving time
for i in range(len(data)):
    data['shift_end_dcord_tc'][i]=(datetime.datetime.strptime(data['dcord_tc'][i], "%Y/%m/%d %H:%M") - datetime.datetime.strptime(data['shift_end'][i], "%Y/%m/%d %H:%M")).total_seconds()/60/60

