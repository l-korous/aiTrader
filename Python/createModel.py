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
import numpy as np
import tensorflow as tf
tf.keras.backend.set_floatx('float64')
print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))

x_train = np.genfromtxt("vars-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")
y_train = np.genfromtxt("res-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")
x_test = np.genfromtxt("testvars-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")
y_test = np.genfromtxt("testres-" + CASE_IDENTIFIER + ".csvx", delimiter = ",")

# Rescale to [-1, 1]
x_train = 2.*(x_train - np.min(x_train))/np.ptp(x_train) - 1
x_test = 2.*(x_test - np.min(x_test))/np.ptp(x_test) - 1

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

model.compile(optimizer='adam', loss = 'binary_crossentropy', metrics=['accuracy'])

model.fit(x_train, y_train, epochs = 10, shuffle = True)

model.evaluate(x_test, y_test, verbose = 2)

model.save("model-" + CASE_IDENTIFIER)

new_model = tf.keras.models.load_model("model-" + CASE_IDENTIFIER)
new_model.summary()

