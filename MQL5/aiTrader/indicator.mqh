#include "basic.mqh"

class LkIndicator {
public:
    LkIndicator();
    
    virtual LkAction GetAction(bool& isError, string& errorMsg) = 0;
};