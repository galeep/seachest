#!/usr/bin/env python

import json, os;

try: 
    with open((os.getenv('CONFIGGY_BIT', 'fakejson.tpl'))) as jd:
        json_data = json.load(jd)
except:
    print("Oh snap") 

myAllVars = dict(os.environ)
myWantVars = list(json_data)
print(json.dumps(myWantVars, indent=2, sort_keys=True))
print(json.dumps([myAllVars], indent=2, sort_keys=True))

allSet = set(myAllVars)
varsSet = set(myWantVars)

foodict = {} 

for var in varsSet.intersection(allSet):
   foodict[(var)] = myAllVars[var]

bardict = list([foodict]) 

print(json.dumps(bardict, indent=2, sort_keys=True))
