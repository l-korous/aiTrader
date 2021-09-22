#import "webrequest.dll"
int a(char& a[], int size);
#import

#define EXECUTING_SCRIPT "C:\\sw\\ai\\predict.py"

#include "ai_indicator.mqh"

LkAiIndicator::LkAiIndicator(
    string _caseIdentifier,
    int _N,
    bool& isError,
    string& errorMsg
) :
caseIdentifier(_caseIdentifier),
N(_N),
LkIndicator()
{}

LkAction LkAiIndicator::GetAction(bool& isError, string& errorMsg) {
    LkAction toReturn = LkNoAction;
    
    // 1 - Get the vector
    double cl[], clReturn[], vol[];
    ArrayResize(cl, N + 1);
    ArrayResize(clReturn, N);
    ArrayResize(vol, N);
    // 1 -  get the 'raw' data
    for(int i = 0; i <= N; i++)
      cl[N - i] = iClose(Symbol(), Period(), 1 + i);
    for(int i = 0; i < N; i++)
      vol[N - i - 1] = (double)iVolume(Symbol(), Period(), 1 + i);
       
    // 2 - calculate volume min max
    double vol_max = vol[0], vol_min = vol[0];
      for(int i = 1; i < N; i++) {
         if(vol[i] > vol_max)
            vol_max = vol[i];
         if(vol[i] < vol_min)
            vol_min = vol[i];
      }
    
    // 3 - rescale the vectors
    for(int i = 0; i < N; i++) {
       clReturn[i] = (cl[i + 1] - cl[i]) / cl[0];
       vol[i] = (double)(vol[i] - vol_min) / (double)(vol_max - vol_min);
   }
   
    // 2 - Pass it to the model for prediction & 3 - Parse the prediction
    string s = "{\"data\": [";
    for(int i = 0; i < N; i++)
      s += (string)clReturn[i] + ", ";
    for(int i = 0; i < N; i++) {
      s += (string)vol[i];
      if(i < (N - 1))
        s += ", ";
    }
    s += "]}";
    
    char d[];
    StringToCharArray( s, d );
    #ifdef _DETAIL_DEBUG Print("Args to cmd: " + s); #endif
    
    int result = a(d, StringLen(s));
    
    // 4 - Act on it
    if(result == 1)
         toReturn = LkBuy;

    return toReturn;
}