#include "functions.mqh"

input int iBarsFuture = 10;
input int iBarsPast = 60;
input int iPipsToGain = 100;
input int iMaxSpread = 10;
// !!! results: buySuccess => 1; sellSuccess => 2 IN ALL CASES !!!
input LkAction iAction = LkBuy;
input LkDatasetType iDatasetType = LkTraining;
input LkIncludeVolume iIncludeVolume = LkNoVolume;

string GetFileNameSuffix() {
   return "-" + PeriodToString(Period()) + "-" + LkActionToString(iAction) + "-" + Symbol() + "-" + (string)iBarsPast + "-" + (string)iBarsFuture + "-" + (string)iPipsToGain + "-" + LkIncludeVolumeToString(iIncludeVolume);
}

double cl[];
long vol[];
double hi[];
double lo[];
int f_var, f_res;
int OnInit() {
   // Idea is - we have to run once for every period.
   EventSetTimer(PeriodSeconds());
   // Why iBarsPast + iBarsFuture + 1 -> +1 because I want to do returns
   ArrayResize(cl, iBarsPast + iBarsFuture + 1);
   ArrayResize(vol, iBarsPast + iBarsFuture + 1);
   ArrayResize(hi, iBarsPast + iBarsFuture + 1);
   ArrayResize(lo, iBarsPast + iBarsFuture + 1);
   
   f_var = FileOpen((iDatasetType == LkTest ? "test" : "") + "vars" + GetFileNameSuffix() + ".csv", FILE_WRITE, ",");
   f_res = FileOpen((iDatasetType == LkTest ? "test" : "") + "res" + GetFileNameSuffix() + ".csv", FILE_WRITE, ",");
   if(f_var == INVALID_HANDLE || f_res == INVALID_HANDLE)
      Print("File open failed, error ", GetLastError());

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   FileClose(f_var);
   FileClose(f_res);
   EventKillTimer();
}

int runningIndex = 0;
void OnTimer() {
   // Don't want to trade if spread is too high.
   int currentSpread = (int)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
   if(shouldInsertBreakIntoData()) {
      ArrayInitialize(cl, 0.);
      ArrayInitialize(vol, 0.);
      ArrayInitialize(hi, 0.);
      ArrayInitialize(lo, 0.);
      runningIndex = 0;
      return;
   }
   else if(!shouldAddDataForBar(iMaxSpread))
      return;
   else {
      // if array is full:
      if(runningIndex == iBarsPast + iBarsFuture + 1) {
         // - print it
         string str = "";
         // closing prices
         for(int i = 1; i <= iBarsPast; i++)
            str += (string)((cl[i] - cl[i -1]) / cl[0]) + ((i == iBarsPast && iIncludeVolume == LkNoVolume) ? "" : ", ");
         
         // volumes
         if(iIncludeVolume == LkWithVolume) {
             long vol_max = vol[1], vol_min = vol[1];
             for(int i = 2; i <= iBarsPast; i++) {
                if(vol[i] > vol_max)
                   vol_max = vol[i];
                if(vol[i] < vol_min)
                   vol_min = vol[i];
             }
             for(int i = 1; i <= iBarsPast; i++)
                str += (string)((double)(vol[i] - vol_min) / (double)(vol_max - vol_min)) + (i == iBarsPast ? "" : ", ");
         }
         
         FileWrite(f_var, str);
         
         // outcomes
         double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
         int result = 0;
         for(int i = 1; i <= iBarsFuture; i++) {
            if((iAction == LkBuy) || (iAction == LkBuyAndSell)) {
                if((hi[iBarsPast + i] - cl[iBarsPast]) > (tickSize * iPipsToGain))
                    result = 1;
            }
            else if((iAction == LkSell) || (iAction == LkBuyAndSell)) {
                if((lo[iBarsPast + i] - cl[iBarsPast]) < -(tickSize * iPipsToGain))
                    result = 2;
            }
         }
         
         FileWrite(f_res, (string)result);
         
         // - remove the oldest, reshuffle all else
         for(int i = 0; i < (iBarsPast + iBarsFuture); i++) {
            cl[i] = cl[i + 1];
            vol[i] = vol[i + 1];
            hi[i] = hi[i + 1];
            lo[i] = lo[i + 1];
         }
         
         // - decrease the size
         runningIndex--;
      }
      // in any case:
      // - add the newest
      hi[runningIndex] = iHigh(Symbol(), Period(), 1);
      lo[runningIndex] = iLow(Symbol(), Period(), 1);
      cl[runningIndex] = iClose(Symbol(), Period(), 1);
      vol[runningIndex] = iVolume(Symbol(), Period(), 1);
      // - increase the size
      runningIndex++;
   }
}