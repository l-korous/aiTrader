#include "money.mqh"

class LkPosition {
public:
    LkPosition(int M, LkMoney* lkMoney, LkSlTp* lkSlTp, bool lkTrailing, int lkMagic, bool& isError, string& errorMsg);
    
    void OpenPosition(LkAction action, bool& isError, string& errorMsg) const;
    
    bool PositionExists(LkAction action, bool& isError, string& errorMsg) const;
    
    bool ShouldClosePosition(LkAction indicatorAction, ulong positionTicket, bool& isError, string& errorMsg) const;

private:
    
    LkMoney* lkMoney;
    LkSlTp* lkSlTp;
    int lkMagic;
    bool lkTrailing;
    int M;
};