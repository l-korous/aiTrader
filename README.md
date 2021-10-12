# Intro
* primary audience are ML 'people' who want to have a way to use ML for trading
* goal is to have an ML model that can do binary/ternary classification of current market situation (represented by past returns and relative volumes) into recommendation to buy, sell, or nothing based on training of past situations where the market moved by certain amount following a given market situation
* it is an end-to-end framework how to get data, how to train the model, and how to plug the model into actual trading robot and see how it performs not just in ML terms, but on the market
* GOAL IS NOT TO PROVIDE A PERFECT ML MODEL, that is not my expertise, so the model provided in createModel.py is as dumb as they come. This is also the main file that you are expected to fine-tune

# How to read this
* this all unfortunately works on Windows only
* in what follows, I use my actual directory structure, including my username "lukas", and some other parts that are specific to my setup - I believe in all these places, it is obvious what applies to your setup
* some actions are not explained in detail (e.g. 'compile the project'); if you are unsure how to proceed, drop me an email (after making some effort)

# Glossary
* return here means relative difference between one closing price and the previous, so ~ (cl[N+1] - cl[N]) / cl[N]
* relative volume means volume of a particular timeframe rescaled to (0, 1) to fit the min and max volume over the period (= iBarsPast timeframes, see below)

# Getting started

1. Get a demo trading account and get MetaTrader 5 (MT5)
	* I recommend https://admiralmarkets.com - this is a broker, and they also let you download MT5 with their own configuration of servers https://admiralmarkets.com/cz/trading-platforms/metatrader-5
	* If you do that, you will find your MT5 application called 'Admiral Markets MT5'
2. Another unfortunate dependency is using Git, to be downloaded from https://git-scm.com/download/win
	* **there is another step even if you have Git installed already** - you need to add c:\Program Files\Git\usr\bin\ to your PATH variable (we need iconv and rm utilities for some scripting)
3. You should also have python, and added both the folder with Python executable and scripts (such as pip) to PATH; in my case these are:
	* c:\Users\lukas\AppData\Local\Programs\Python\Python39\
	* c:\Users\lukas\AppData\Local\Programs\Python\Python39\Scripts\
	* you will **also** need some common packages (_pip install keras tensorflow flask_)
4. For getting training / testing data, use the c:\Git\aiTrader\MQL5\trainingDataFactory as follows
	1. Copy the folder trainingDataFactory to c:\Users\lukas\AppData\Roaming\MetaQuotes\Terminal\24F345EB9F291441AFE537834F9D8A19\MQL5\Experts\
	2. Open MetaEditor (comes with MT5)
	3. In the Navigator, open the project file trainingDataFactory.mqproj and compile the project
	4. When you do that, in MT5 Navigator, you will now see the 'Expert Advisor' (= MT5 program) called trainingDataFactory
	5. Right-click on it and select Test, or select it in Strategy Tester 'Settings' window/frame
	6. Select the symbol (e.g. EURUSD), the timeframe (e.g. H1 for hourly) and date, leave everything else as is on the Settings tab
	7. Go to Inputs, here is when the fun begins, these are the variables you will want to set:
		1. **iBarsFuture** - just for how many future timeframes we want to predict the movement
		2. **iBarsPast** - based on how many past timeframes we want to do that
		3. **iPipsToGain** - threshold in pips (google if unsure) for labelling
		4. **iMaxSpred** - many brokers, including Admiral Markets do not have stable spreads (google if unsure) during trading day, whereas they are very low during the day, they get very high during the night and during those times, automated trading is not advised. This is a threshold for maximum spread we want to accept. For EURUSD, the default value of 10 is fine.
		5. **iAction** - LkBuy or LkSell or LkBuyAndSell. This drives what classification we are doing (LkBuy or LkSell are binary classifications - we either buy/sell or don't, LkBuyAndSell ternary - buy, or sell, or nothing)
		6. **iDatasetType** - LkTraining or LkTest. This is just so that the produced files have this in their names
		7. **iIncludeVolume** - if we want to include relative trading volumes in the variables
	8. Hit Start to produce the data, they will appear in c:\Users\lukas\AppData\Roaming\MetaQuotes\Tester\24F345EB9F291441AFE537834F9D8A19\Agent-127.0.0.1-3000\MQL5\Files\ (search for them in some parent folders if you can't find them)
		* _vars-H1-BUY-EURUSD-60-10-100-NoVolume.csv_ - variables
		* _res-H1-BUY-EURUSD-60-10-100-NoVolume.csv_ - results (labels)
		* as you can guess, the numbers represent the iBarsFuture, iBarsPast, iPipsToGain values, in what follows the string **H1-BUY-EURUSD-60-10-100-NoVolume-Training** will be referred to as **CASE_IDENTIFIER**
		* if you set iDatasetType to LkTest, the files will have 'test' prepended to them. Of course standard ML practices like ~ 80 / 20 distribution between training and test data should be followed
			* since we will want to have some validation as well, I recommend not setting the training / test data to the most recent. Instead maybe use last 3 months up to today for validation, 3-6 months before that for testing, and 2-3 years before that for training
	9. I recommend inspecting the data:
		* the variables are just as many past returns (per timeframe) as iBarsPast specified. Plus that many relative volumes - as a large array per timeframe (**this is probably something that can be improved for better results**)
		* the results (labels) are just the labels. For LkBuy, positive is represented by 1, for LkSell, positive is represented by 2, for LkBuyAndSell buy label is 1, sell label is 2
5. Training of the model
	1. I recommend copying all files from c:\Users\lukas\AppData\Roaming\MetaQuotes\Tester\24F345EB9F291441AFE537834F9D8A19\Agent-127.0.0.1-3000\MQL5\Files\ to the c:\Git\aiTrader\Python\ folder; these files should be (example for one set of values):
		* _vars-H1-BUY-EURUSD-60-10-100-NoVolume.csv_
		* _res-H1-BUY-EURUSD-60-10-100-NoVolume.csv_
		* _testvars-H1-BUY-EURUSD-60-10-100-NoVolume.csv_
		* _testres-H1-BUY-EURUSD-60-10-100-NoVolume.csv_
	2. When this is done, you can call the script in c:\Git\aiTrader\Python\ like this: python createModel.py H1-BUY-EURUSD-60-10-100-NoVolume (in generic terms, python createModel.py **CASE_IDENTIFIER** )
		* There is some encoding issue on MT5 side, that is why internally the script will run the batch file fixEncoding.bat (this will rename them to .csvx files)
		* this will be failing horribly if you did not setup Git (see steps at the beginning) as instructed
		* the output of this script createModel.py is a saved keras model in a folder **model-CASE_IDENTIFIER**
6. Testing the ML model on real trading
	1. In order to actually see how the trained model would perform in trading, there is an implementation of a trading robot ('Expert Advisor' in MT5 terminology) in c:\Git\aiTrader\MQL5\aiTrader\
	2. First, it needs to be compiled similarly to trainingDataFactory, so:
		1. Copy the folder aiTrader to c:\Users\lukas\AppData\Roaming\MetaQuotes\Terminal\24F345EB9F291441AFE537834F9D8A19\MQL5\Experts\
		2. Open MetaEditor (comes with MT5)
		3. In the Navigator, open the project file aiTrader.mqproj and compile the project
		4. When you do that, in MT5 Navigator, you will now see the 'Expert Advisor' (= MT5 program) called aiTrader
	3. Then, you need to copy c:\Git\aiTrader\DLL\x64\Debug\webRequest.dll to c:\Windows\System32\ (or to any other place in your PATH)
	4. Last piece of the chain here is a super simple web server (written in python) that you need to run by (in the command line):
		* python runServer.py H1-BUY-EURUSD-60-10-100-NoVolume (in generic terms python runServer.py **CASE_IDENTIFIER**)
	5. When you have all the above, you can actually run the aiTrader MT5 program via the Strategy Tester in MT5. It has only these parameters (inputs):
		* **CASE_IDENTIFIER**: obvious, see above if not
		* **iMaxSpread**: same meaning as for trainingDataFactory; why this is not a part of CASE_IDENTIFIER is that in theory you might want to train ML model with different value than when you trade
		* **slTpRatio**: this is ratio between Stop Loss and Take Profit (for both, google if unsure; in short these are price levels that you set when you open your trade for the trade to be automatically closed when the current price hits those levels - and one is where you experience loss, another is when you take profit)
7. That is it, you can of course actually let the setup from previous point trade on a demo / real account. But for that, two points:
	* you can do that on your PC, sure. But that is really not recommended (your PC may crash etc.). And running on a server requires a bit more robust implementation if you plan to not lose money
	* running this on a server also requires to get rid of the DLL and instead connecting directly to the web server - again here, this requires a server (e.g. in the cloud) running the flask server, and again - more robust, fail-safe implementation
	
	
	
