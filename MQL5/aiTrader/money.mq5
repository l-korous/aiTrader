#include "money.mqh"

LkMoney::LkMoney(double _maxPercentOfBalance, double _iFixedVolume) : maxPercentOfBalance(_maxPercentOfBalance), iFixedVolume(_iFixedVolume) {}

double LkMoney::GetVolumeForNewTrade(LkAction action, double unitValueAtRisk, bool& isError, string& errorMsg) const {
    if(iFixedVolume > 0.)
        return MathMax(iFixedVolume, SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN));

    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double _minEquity = 1000.;
    if(equity < _minEquity) {
        isError = true;
        errorMsg = "GetVolumeForNewTrade: not enough equity for anything";
        return 0.;
    }

    double bal = AccountInfoDouble(ACCOUNT_BALANCE);
    double symbolVolume = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
    double volStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    
    // Risk for unit volume
    double unitRiskInProfitCurrency = symbolVolume * unitValueAtRisk;
    string currencyString = SymbolInfoString(Symbol(), SYMBOL_CURRENCY_PROFIT);
    double unitRiskInCzk = unitRiskInProfitCurrency * GetExchangeRateWithCzk(currencyString);
    
    #ifdef _DEBUG Print("GetVolumeForNewTrade", ", bal: ", bal, ", symbolVolume: ", symbolVolume, ", volStep: ", volStep, ", unitRiskInProfitCurrency: ", unitRiskInProfitCurrency, ", unitRiskInCzk: ", unitRiskInCzk, ", currencyString: ", currencyString); #endif
    
    // Exact volume
    double desiredVol = bal * (maxPercentOfBalance / 100.) / unitRiskInCzk;
    // Rounded down to possible volume
    double targetVol = volStep * MathFloor(desiredVol / volStep);
    
    return targetVol;
}

double LkMoney::GetExchangeRateWithCzk(string currency) const {
    if(currency == "EUR")
        return GetCurrentPrice("EURCZK");
    else if(currency == "USD")
        return GetCurrentPrice("USDCZK");
    else if(currency == "GBP")
        return GetCurrentPrice("GBPCZK");
    else if(currency == "JPY")
        return GetCurrentPrice("USDCZK") / GetCurrentPrice("USDJPY");
    else if(currency == "CHF")
        return GetCurrentPrice("USDCZK") / GetCurrentPrice("USDCHF");
    else if(currency == "AUD")
        return GetCurrentPrice("USDCZK") * GetCurrentPrice("AUDUSD");
    else if(currency == "CAD")
        return GetCurrentPrice("USDCZK") / GetCurrentPrice("USDCAD");
    else if(currency == "NZD")
        return GetCurrentPrice("USDCZK") * GetCurrentPrice("NZDUSD");
    else
        return 999999999.;
}