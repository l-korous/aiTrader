import sys
CASE_IDENTIFIER = sys.argv[1]
vars = CASE_IDENTIFIER.split("-")
iBarsPast = int(vars[3])
iAction = vars[1]
iWithVolume = vars[6]

import os
os.system("fixEncoding.bat")
#os.environ["CUDA_VISIBLE_DEVICES"]="-1"   

import keras.backend as K
import numpy
import tensorflow as tf
tf.keras.backend.set_floatx('float64')

x_train = numpy.genfromtxt("vars-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")
y_train = numpy.genfromtxt("res-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")
x_test = numpy.genfromtxt("testvars-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")
y_test = numpy.genfromtxt("testres-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")

finalLayerShape = 3 if iAction == "BOTH" else 2
barsCountMultiplier = 2 if iWithVolume == "WithVolume" else 1
model = tf.keras.models.Sequential([
	tf.keras.Input(shape=(barsCountMultiplier * iBarsPast,)),
	tf.keras.layers.Dense(barsCountMultiplier * iBarsPast, activation='relu'),
	tf.keras.layers.Dense(2 * barsCountMultiplier * iBarsPast, activation='relu'),
	tf.keras.layers.Dense(barsCountMultiplier * iBarsPast, activation='relu'),
	tf.keras.layers.Dense(int(0.5 * barsCountMultiplier * iBarsPast), activation='relu'),
	tf.keras.layers.Dense(finalLayerShape)
])

predictions = model(x_train[:1]).numpy()

tf.nn.softmax(predictions).numpy()

model.compile(optimizer='adam', loss = tf.keras.losses.MeanAbsoluteError(), metrics=['accuracy'])
			  
model.fit(x_train, y_train, epochs = 100, shuffle = True)

model.evaluate(x_test, y_test, verbose = 2)

model.save("model-" + CASE_IDENTIFIER)

new_model = tf.keras.models.load_model("model-" + CASE_IDENTIFIER)
new_model.summary()

