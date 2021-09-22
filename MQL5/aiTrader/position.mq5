#include <Trade\Trade.mqh>
#include "position.mqh"

LkPosition::LkPosition(int _M, LkMoney* _lkMoney, LkSlTp* _lkSlTp, bool _lkTrailing, int _lkMagic, bool& isError, string& errorMsg) :
   lkMoney(_lkMoney),
   lkSlTp(_lkSlTp),
   lkMagic(_lkMagic),
   lkTrailing(_lkTrailing),
   M(_M)
{}

void LkPosition::OpenPosition(LkAction action, bool& isError, string& errorMsg) const {
   if(!LkActionProper(action))
      return;
   
   MqlTradeRequest request;
   MqlTradeResult  result = {0};
   ZeroMemory(request);
   ZeroMemory(result);
   
   double currentPrice = GetCurrentPrice(Symbol(), action);
   
   lkSlTp.GetSlTp(action, request.sl, request.tp);
   request.sl = NormalizeDouble(request.sl, _Digits);
   request.tp = NormalizeDouble(request.tp, _Digits);
         
   if(lkTrailing)
      request.tp = EMPTY_VALUE;
   request.volume = lkMoney.GetVolumeForNewTrade(action, MathAbs(request.sl - currentPrice), isError, errorMsg);
   
   if(HandleError(isError, errorMsg))
      return;
     
   request.action = TRADE_ACTION_DEAL;
   request.magic = lkMagic;
   request.symbol = Symbol();
   request.price = currentPrice;
   request.comment = "AI Trader " + (string)PeriodSeconds();
   
   request.type = LkActionToOrderType(action, isError, errorMsg);
   if(HandleError(isError, errorMsg))
      return;
     
   #ifdef _DEBUG Print("OpenPosition", ", request.tp: ", request.tp, ", request.sl: ", request.sl, ", request.volume: ", request.volume, ", request.price: ", request.price); #endif
   
   if(!OrderSend(request, result))
      PrintFormat("OrderSend error %d", GetLastError());
}

CPositionInfo position;

bool LkPosition::PositionExists(LkAction action, bool& isError, string& errorMsg) const {
    int total = PositionsTotal();
    for(int i = 0; i < total; i++) {
        ulong positionTicket = PositionGetTicket(i);
        if(position.SelectByTicket(positionTicket)) {
            if(PositionGetInteger(POSITION_MAGIC) != lkMagic)
                continue;
            if(PositionGetString(POSITION_SYMBOL) != Symbol())
                continue;
            if(PositionGetInteger(POSITION_TYPE) == LkActionToPositionType(action, isError, errorMsg))
               return true;
        }
    }
    
    return false;
}
    
bool LkPosition::ShouldClosePosition(LkAction indicatorAction, ulong positionTicket, bool& isError, string& errorMsg) const {
    position.SelectByTicket(positionTicket);
    if(PositionGetInteger(POSITION_MAGIC) != lkMagic)
        return false;
    if(PositionGetString(POSITION_SYMBOL) != Symbol())
        return false;
        
    datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
    int barShift = iBarShift(Symbol(), 0, openTime);
    if(barShift > M)
      return true;

    // Opposite actions
    LkAction positionAction = LkPositionTypeToAction(position.PositionType());
    if(LkActionsOpposite(indicatorAction, positionAction))
        return true;
        
    return false;
}