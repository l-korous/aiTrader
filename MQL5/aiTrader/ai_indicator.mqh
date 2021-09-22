#include "indicator.mqh"
class LkAiIndicator : public LkIndicator {
public:
    LkAiIndicator(
      string caseIdentifier,
      int N,
      bool& isError,
      string& errorMsg
   );

   LkAction          GetAction(bool& isError, string& errorMsg);

private:
   string caseIdentifier;
   int N;
};
