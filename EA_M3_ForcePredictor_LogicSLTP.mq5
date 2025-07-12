// Sample EA with improved entry and pending logic
// This file contains only excerpts demonstrating the upgraded functions.

#include <Trade/Trade.mqh>

struct PendingProfile {
    int layers;
    double offset[3];
    double lot[3];
};

// Example configuration variable
input double InpLotSize = 0.01;

int GetMarketRhythmLevel() {
    // Dummy implementation for illustration
    return 70; // assume medium rhythm
}

bool IsMultiPeriodBullResonance() { return true; }
bool IsMultiPeriodBearResonance() { return true; }

int GetTrendScore100() { return 50; }
int GetStructureScore100() { return 20; }

//=== Improved direction scoring ===
int GetFinalDirection() {
    int trendScore  = GetTrendScore100();
    int structScore = GetStructureScore100();
    int rhythm      = GetMarketRhythmLevel();
    int totalScore  = trendScore + structScore;
    int threshold   = 8;
    if (rhythm >= 80)      threshold = 3;
    else if (rhythm >= 60) threshold = 5;

    bool bullRes = IsMultiPeriodBullResonance();
    bool bearRes = IsMultiPeriodBearResonance();

    if (bullRes && totalScore >= threshold)
        return 1;
    if (bearRes && totalScore <= -threshold)
        return -1;
    return 0;
}

//=== Improved pending order profile ===
PendingProfile GetPendingProfile(int structScore, int trendScore) {
    PendingProfile pf;
    pf.layers = 0;
    ArrayInitialize(pf.offset, 0);
    ArrayInitialize(pf.lot, 0);

    int totalScore = structScore + trendScore;
    int rhythm     = GetMarketRhythmLevel();

    double baseOffset = 1.2;
    double lotFactor  = 1.0;
    if (rhythm >= 80)      { baseOffset = 0.9; lotFactor = 1.2; }
    else if (rhythm >= 60) { baseOffset = 1.1; lotFactor = 1.0; }
    else                   { baseOffset = 1.3; lotFactor = 0.8; }

    if (totalScore >= 120) {
        pf.layers = 3;
        pf.offset[0] = baseOffset * 1.0;
        pf.offset[1] = baseOffset * 1.5;
        pf.offset[2] = baseOffset * 2.2;
        pf.lot[0] = pf.lot[1] = pf.lot[2] = InpLotSize * lotFactor;
    }
    else if (totalScore >= 90) {
        pf.layers = 2;
        pf.offset[0] = baseOffset * 1.5;
        pf.offset[1] = baseOffset * 2.2;
        pf.lot[0] = pf.lot[1] = InpLotSize * lotFactor;
    }
    else {
        pf.layers = 1;
        pf.offset[0] = baseOffset * 2.5;
        pf.lot[0]   = InpLotSize * 0.8 * lotFactor;
    }

    return pf;
}

