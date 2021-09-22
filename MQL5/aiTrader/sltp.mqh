class LkSlTp {
public:
    LkSlTp(double tpPercent, double sltpRatio, bool& isError, string& errorMsg);
    
    void GetSlTp(LkAction lkAction, double& sl, double& tp);
    
private:
    double tpPercent, sltpRatio;
};