#include "sltp.mqh"

LkSlTp::LkSlTp(double _tpPercent, double _sltpRatio, bool& isError, string& errorMsg) :
sltpRatio(_sltpRatio),
tpPercent(_tpPercent) 
{}

void LkSlTp::GetSlTp(LkAction lkAction, double& sl, double& tp) {
    double lastClose = iClose(Symbol(), Period(), 1);
    if(lkAction == LkBuy) {
      tp = lastClose * (1. + (tpPercent / 100.));
      sl = lastClose * (1. - (sltpRatio * tpPercent / 100.));
    }
    else/* if(action == LkSell) */ {
      tp = lastClose * (1. - (tpPercent / 100.));
      sl = lastClose * (1. + (sltpRatio * tpPercent / 100.));
    }
}