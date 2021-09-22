#include <Trade\AccountInfo.mqh>
#include "basic.mqh"

class LkMoney {
public:
    LkMoney(double maxPercentOfBalance, double iFixedVolume = -1.);
    
    // Given a stop loss and action, return volume
    // Logic is that we want to trade highest possible volume for the particular symbol that does not expose more than maxPercentOfBalance.
    double GetVolumeForNewTrade(LkAction action, double unitValueAtRisk, bool& isError, string& errorMsg) const;
    
    double GetExchangeRateWithCzk(string currency) const;
    
    const double maxPercentOfBalance;
    const double iFixedVolume;
};