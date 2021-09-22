import flask
from flask import request, jsonify
from tensorflow.keras import models
import numpy
import datetime

PATH = "B:\\sw\\ai\\"
model = models.load_model(PATH + "model-M1-Buy-EURUSD-50-10-50")
N = 100

app = flask.Flask(__name__)
app.config["DEBUG"] = False

@app.route('/', methods=['POST'])
def home():    
    x_input = numpy.zeros((1, N))
    for i in range(0, N):
    	x_input[0][i] = float(request.json["data"][i])
    
    prediction = model(x_input)
    
    if prediction[0][0] > prediction[0][1]:
        return "0"
    else:
        return "1"

app.run()