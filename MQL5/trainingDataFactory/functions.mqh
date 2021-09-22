enum LkAction {
    LkBuy,
    LkSell,
    LkBuyAndSell,
    LkNoAction
};

string LkActionToString(LkAction action);

enum LkDatasetType {
    LkTraining,
    LkTest
};

string LkDatasetTypeToString(LkDatasetType datasetType);

enum LkIncludeVolume {
    LkNoVolume,
    LkWithVolume
};

string LkIncludeVolumeToString(LkIncludeVolume lkIncludeVolume);

bool shouldAddDataForBar(int maxSpread);

bool shouldInsertBreakIntoData();

string PeriodToString(ENUM_TIMEFRAMES tf);