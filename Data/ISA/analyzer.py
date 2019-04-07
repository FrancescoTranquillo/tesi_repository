import pandas as pd
import os
import re
import io
from datetime import datetime


wd = os.getcwd()
path_file = wd + "\\Data\\ISA\\isareport16-19\\16-17-18"
names_list = os.listdir(path_file)
len(names_list)
with open(path_file+"\\"+names_list[1333], mode='r') as f:
    data = f.read()
    print(data)
data

x = re.split(pattern="\n", string=data)
header = x[5:14]
footer = x[-2:]
for i in header:
    obs = re.split(pattern=": ", string=header, maxsplit=1)
obs
start
start = datetime.strptime(start[1], '%d/%m/%Y %H:%M:%S')

print(start)


pd.read_csv(io.StringIO('\n'.join(header)), delim_whitespace=False)

s = *iter(data)*3
data_content=['Country', 'Capital', 'Currency', 'US', 'Washington', 'USD', 'India',  'Delhi', 'Rupee']
data = list(zip(*[iter(data_content)]*2))
pd.DataFrame(data[1:], columns=data[0])
