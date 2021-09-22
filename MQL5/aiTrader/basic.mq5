#include "basic.mqh"

bool LkActionsOpposite(LkAction actionA, LkAction actionB) {
   if(((actionA == LkBuy) || (actionA == LkDontSell)) && ((actionB == LkSell) || (actionB == LkDontBuy)))
      return true;
   if(((actionB == LkBuy) || (actionB == LkDontSell)) && ((actionA == LkSell) || (actionA == LkDontBuy)))
      return true;
    if(((actionA == LkBuy) || (actionA == LkSell)) && (actionB == LkDontBuyOrSell))
        return true;
    if(((actionB == LkBuy) || (actionB == LkSell)) && (actionA == LkDontBuyOrSell))
        return true;
      
   return false;
}

LkAction MergeActions(LkAction actionA, LkAction actionB) {
    if(LkActionsOpposite(actionA, actionB))
        return LkDontBuyOrSell;
    else if((actionA == LkDontBuyOrSell) || (actionB == LkDontBuyOrSell))
        return LkDontBuyOrSell;
    else if((actionA == LkSell) && ((actionB == LkDontBuy) || (actionB == LkNoAction) || (actionB == LkSell)))
        return LkSell;
    else if((actionB == LkSell) && ((actionA == LkDontBuy) || (actionA == LkNoAction) || (actionA == LkSell)))
        return LkSell;
    else if((actionA == LkBuy) && ((actionB == LkDontSell) || (actionB == LkNoAction) || (actionB == LkBuy)))
        return LkBuy;
    else if((actionB == LkBuy) && ((actionA == LkDontSell) || (actionA == LkNoAction) || (actionA == LkBuy)))
        return LkBuy;
    else if((actionA == LkDontBuy) || (actionB == LkDontBuy))
        return LkDontBuy;
    else if((actionA == LkDontSell) || (actionB == LkDontSell))
        return LkDontSell;
    else
        return LkNoAction;
}

bool LkActionsIdentical(LkAction actionA, LkAction actionB) {
    return (actionA == actionB);
}

LkAction LkPositionTypeToAction(ENUM_POSITION_TYPE positionType) {
    if(positionType == POSITION_TYPE_BUY)
       return LkBuy;
    if(positionType == POSITION_TYPE_SELL)
       return LkSell;
    return LkNoAction;
}

bool LkActionProper(LkAction action) {
    return ((action == LkBuy) || (action == LkSell));
}

string LkActionToString(LkAction action) {
    if(action == LkBuy)
        return "BUY";
    else if(action == LkSell)
        return "SELL";
    else if(action == LkDontBuy)
        return "DONT BUY";
    else if(action == LkDontSell)
        return "DONT SELL";
    else if(action == LkDontBuyOrSell)
        return "DONT BUY or SELL";
    else
        return "NONE";
}

ENUM_ORDER_TYPE LkActionToOrderType(LkAction lkAction, bool& isError, string& errorMsg) {
    if(lkAction == LkBuy)
        return ORDER_TYPE_BUY;
    else if(lkAction == LkSell)
        return ORDER_TYPE_SELL;
    else {
        isError = true;
        errorMsg = "Wrong action in LkActionToOrderType";
        return -1;
    }
}

ENUM_POSITION_TYPE LkActionToPositionType(LkAction lkAction, bool& isError, string& errorMsg) {
    if(lkAction == LkBuy)
        return POSITION_TYPE_BUY;
    else if(lkAction == LkSell)
        return POSITION_TYPE_SELL;
    else {
        isError = true;
        errorMsg = "Wrong action in LkActionToPositionType";
        return -1;
    }
}

double GetCurrentPrice(string symbol, LkAction lkAction) {
    MqlTick tick_;
    SymbolInfoTick(symbol, tick_);
    if(lkAction == LkBuy)
     return tick_.ask;
   else if(lkAction == LkSell)
      return tick_.bid;
   else
    return ((tick_.bid + tick_.ask)  / 2.);
}

double GetStepPrice(ENUM_TIMEFRAMES timeFrame, string symbol, ENUM_APPLIED_PRICE appliedPrice, int stepsBack) {
   double close = iClose(symbol, timeFrame, stepsBack);
   double close2 = iClose(symbol, timeFrame, stepsBack + 1);
   double low = iLow(symbol, timeFrame, stepsBack);
   double high = iHigh(symbol, timeFrame, stepsBack);
   
   if(appliedPrice == PRICE_MEDIAN)
      return 0.5 * (high + low);
   else if(appliedPrice == PRICE_TYPICAL)
      return 0.3333333333333 * (high + close + low);
   else
      return 0.25 * (high + low + close2 + close);
}

double GetAveragePrice(ENUM_TIMEFRAMES timeFrame, string symbol, ENUM_APPLIED_PRICE appliedPrice, int period, int shift) {
    double toReturn = 0.;
    
    for(int i = shift; i < (shift + period); i++)
        toReturn += GetStepPrice(timeFrame, symbol, appliedPrice, i);
        
    return (toReturn / period);
}

bool HandleError(bool& isError, string& errorMsg) {
    if(isError) {
        Print("ERROR: ", errorMsg);
    }
    errorMsg = "";
    isError = false;
    return isError;
}

ENUM_TIMEFRAMES GetHigherTimeframe() {
    switch(PERIOD_CURRENT) {
      case PERIOD_M1:
         return PERIOD_M5;
      case PERIOD_M5:
         return PERIOD_M15;
      case PERIOD_M15:
         return PERIOD_H1;
      case PERIOD_H1:
         return PERIOD_H4;
      case PERIOD_H4:
         return PERIOD_D1;
      case PERIOD_D1:
         return PERIOD_W1;
   }
   
   return PERIOD_D1;
}