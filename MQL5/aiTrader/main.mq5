//#define _DEBUG
//#define _DETAIL_DEBUG

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include "basic.mqh"
#include "sltp.mqh"
#include "money.mqh"
#include "position.mqh"
#include "ai_indicator.mqh"

const int lkMagic = PeriodSeconds() + 1;

// Case
input string caseIdentifier = "M1-BOTH-EURUSD-60-15-40";
input int N = 60;
input int M = 15;
// !!! This comes from the model !!!
// TODO - add this param to the model, and maybe check when calling it to avoid mistakes
input double tpPercent = 0.04;

// Volume & trading
const double iFixedVolume = 1.e-6;
#define iPercentOfBalance 0.5
input int iMaxSpread = 10;

// Tp Sl
input double slTpRatio = 1.0;

// Global
bool _isError = false;
string _errorMsg;
LkMoney lkMoney(iPercentOfBalance, iFixedVolume);
LkSlTp lkSlTp(tpPercent, slTpRatio, _isError, _errorMsg);
LkPosition lkPosition(M, &lkMoney, &lkSlTp, false, lkMagic, _isError, _errorMsg);

LkAiIndicator indicator(caseIdentifier, N, _isError, _errorMsg);

int OnInit() {
    EventSetTimer(PeriodSeconds() < 3600 ? 5 : 60);
    
    if(HandleError(_isError, _errorMsg))
        return INIT_FAILED;
    else
        return(INIT_SUCCEEDED);
}

datetime prevTimeCurrent = TimeCurrent();
int lastMod = 0;
void OnTimer() {
    // Simple catch of market being closed.
    if (TimeCurrent() == prevTimeCurrent)
        return;
    prevTimeCurrent = TimeCurrent();
    
    // Want to run this at the beginning of each bar
    int currentMod = (int)MathMod(prevTimeCurrent, PeriodSeconds());
    if(currentMod > lastMod) {
        lastMod = currentMod;
        return;
    }
    // maybe 5 seconds (to be safe) after the beginning
    else if(currentMod <= 5) {
        return;
    }
    else {
        // Don't want to trade if spread is too high.
        int currentSpread = (int)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
        if(currentSpread > iMaxSpread) {
            #ifdef _DETAIL_DEBUG Print("Spread too high(", Symbol(), "): ", currentSpread); #endif
            return;
        }
        
        lastMod = currentMod;
        
        bool havePositions = (PositionsTotal() > 0);
        
        LkAction action = indicator.GetAction(_isError, _errorMsg);
        #ifdef _DEBUG Print("action: ", LkActionToString(action)); #endif
    
        if(havePositions)
            ClosePositions(action, _isError, _errorMsg);
            
        bool shouldTrade = LkActionProper(action);
        if(shouldTrade)
            OpenPositions(action, _isError, _errorMsg);
    }
}

void ClosePositions(const LkAction& indicatorAction, bool& isError, string& errorMsg) {
    int total = PositionsTotal();
    
    for(int i = 0; i < total; i++) {
        ulong positionTicket = PositionGetTicket(i);
        if(lkPosition.ShouldClosePosition(indicatorAction, positionTicket, isError, errorMsg)) {
            CTrade trade;
            trade.PositionClose(positionTicket);
        }
    }
}

void OpenPositions(const LkAction& action, bool& isError, string& errorMsg) {
    if(LkActionProper(action) && !lkPosition.PositionExists(action, isError, errorMsg)) {
        lkPosition.OpenPosition(action, isError, errorMsg);
        HandleError(isError, errorMsg);
    }
}

void OnDeinit(const int reason) {
    EventKillTimer();
}