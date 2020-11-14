insheet using "preproc_patents.csv",clear

python

stata: drop _all
import pandas as pd
import numpy as np
from sfi import Data
data=pd.read_csv("preproc_patents.csv")
data=data.fillna(".")
data_list=list(data.columns)

for name in data_list:
	print(name)
	try:
		Data.addVarStrL(name)
	except:
		pass

Data.addObs(len(data),nofill=True)
for name in data_list:
	print(name)
	try:
		print(np.array(data[name]))
		Data.store(name,None,np.array(data[name]))
	except:
		pass

end
