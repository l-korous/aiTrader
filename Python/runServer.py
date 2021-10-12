import sys
CASE_IDENTIFIER = sys.argv[1]
vars = CASE_IDENTIFIER.split("-")
iBarsPast = int(vars[3])
import flask
from flask import request, jsonify
from tensorflow.keras import models
import numpy
import datetime
import os

PATH = os.getcwd()
model = models.load_model(PATH + "\\model-" + CASE_IDENTIFIER)

app = flask.Flask(__name__)
app.config["DEBUG"] = False

@app.route('/', methods=['POST'])
def home():    
    x_input = numpy.zeros((1, iBarsPast))
    for i in range(0, iBarsPast):
    	x_input[0][i] = float(request.json["data"][i])
    
    prediction = model(x_input)
    
    if prediction[0][0] > prediction[0][1]:
        return "0"
    else:
        return "1"

app.run()