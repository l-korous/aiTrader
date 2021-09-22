#include <Trade\PositionInfo.mqh>

enum LkAction {
    LkBuy,
    LkSell,
    LkDontBuy,
    LkDontSell,
    LkDontBuyOrSell,
    LkNoAction
};

LkAction MergeActions(LkAction actionA, LkAction actionB);

bool LkActionsOpposite(LkAction actionA, LkAction actionB);
bool LkActionProper(LkAction action);
string LkActionToString(LkAction action);
LkAction LkPositionTypeToAction(ENUM_POSITION_TYPE positionType);
ENUM_ORDER_TYPE LkActionToOrderType(LkAction lkAction, bool& isError, string& errorMsg);
ENUM_POSITION_TYPE LkActionToPositionType(LkAction lkAction, bool& isError, string& errorMsg);


// Does not have LkPriceRecordType, as this price is really 'Current'
double GetCurrentPrice(string symbol, LkAction lkAction = LkNoAction);

double GetStepPrice(ENUM_TIMEFRAMES timeFrame, string symbol, ENUM_APPLIED_PRICE appliedPrice, int stepsBack);

double GetAveragePrice(ENUM_TIMEFRAMES timeFrame, string symbol, ENUM_APPLIED_PRICE appliedPrice, int period, int shift = 0);

// Returns the value of isError
bool HandleError(bool& isError, string& errorMsg);

ENUM_TIMEFRAMES GetHigherTimeframe();