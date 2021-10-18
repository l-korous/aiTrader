import sys
CASE_IDENTIFIER = sys.argv[1]
vars = CASE_IDENTIFIER.split("-")
iAction = vars[1]
iBarsPast = int(vars[3])
import flask
from flask import request, jsonify
from tensorflow.keras import models
import numpy as np
import datetime
import os
import logging
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

PATH = os.getcwd()
model = models.load_model(PATH + "\\model-" + CASE_IDENTIFIER)

app = flask.Flask(__name__)
app.config["DEBUG"] = False

@app.route('/', methods=['POST'])
def home():    
    x_input = np.zeros((1, iBarsPast))
    for i in range(0, iBarsPast):
    	x_input[0][i] = float(request.json["data"][i])

    threshold = float(request.json["threshold"])
    # print(threshold)

    prediction = model(x_input)
    print(prediction)
    
    if iAction != "BOTH":
        actionPrediction = prediction[0][1 if iAction == "BUY" else 2]
        if (actionPrediction - prediction[0][0]) > threshold:
            return ("1" if iAction == "BUY" else "2")
        else:
            return "0"
    else:
        if ((prediction[0][0] > (prediction[0][1] - threshold)) and ((prediction[0][0] > prediction[0][2] - threshold))):
            return "0"
        else:
            if (prediction[0][1] > (prediction[0][2] + threshold)):
                return "1"
            elif (prediction[0][2] > (prediction[0][1] + threshold)):
                return "2"
            else:
                return "0"

app.run()