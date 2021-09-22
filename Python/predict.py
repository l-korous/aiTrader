import sys
import json
import requests
import datetime
PATH = "c:\\Users\\Lukas Korous\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\\Files\\"
N = 100

x_input = []
for i in range(0, N):
	x_input.append(float(sys.argv[1 + i]))

data = { "data": x_input }
headers = {'content-type': 'application/json'}
r = requests.post(url = 'http://localhost:5000', data = json.dumps(data), headers = headers)

# Ugly hack, just create a dummy "result" file
f = open(PATH + "res" + r.text, "w").close()