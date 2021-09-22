#include "functions.mqh"

datetime prevTimeCurrent = TimeCurrent();
bool shouldAddDataForBar(int maxSpread) {
   // Simple catch of market being closed.
   if (TimeCurrent() == prevTimeCurrent)
      return false;
   int currentSpread = (int)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
    if(currentSpread > maxSpread)
        return false;
   prevTimeCurrent = TimeCurrent();
   return true;
}

bool shouldInsertBreakIntoData() {
   MqlDateTime date;
   TimeToStruct(TimeCurrent(), date);
   if(date.mon == 12 && date.day > 15)
      return true;
      
   return false;
}

string LkActionToString(LkAction action) {
    if(action == LkBuy)
        return "BUY";
    else if(action == LkSell)
        return "SELL";
    else
        return "BOTH";
}

string PeriodToString(ENUM_TIMEFRAMES tf) {
    switch(tf) {
        case PERIOD_D1:
            return "D1";
            break;
        case PERIOD_H1:
            return "H1";
            break;
        case PERIOD_M15:
            return "M15";
            break;
        case PERIOD_M5:
            return "M5";
            break;
        case PERIOD_M1:
            return "M1";
            break;
    }
    
    return "ERROR";            
}

string LkDatasetTypeToString(LkDatasetType datasetType) {
    if(datasetType == LkTraining)
        return "Training";
    else
        return "Test";
}

string LkIncludeVolumeToString(LkIncludeVolume lkIncludeVolume) {
    if(lkIncludeVolume == LkNoVolume)
        return "NoVolume";
    else
        return "WithVolume";
}