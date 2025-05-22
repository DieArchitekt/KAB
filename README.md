# KAB
The Kennedy Adaptive Baseline (KAB) Indicator

ABOUT:
-------------
KAB is a recursive smoother that adapts to market volatility.
It uses a ratio of short-term and long-term ATR to scale gain.
Result: stable during chaos, responsive during drift.

MECHANISM:
-------------
1. Calculates short and long ATR
2. Computes ratio = short / long
3. Uses ratio to scale smoothing coefficient (alpha)
4. Caps max gain (optional)
5. Can freeze output when volatility exceeds a threshold
6. Optional second smoothing pass for signal refinement

INPUTS:
---------------
- BaseAlpha           = base smoothing gain (default: 0.1)
- ShortATRPer         = fast ATR window (default: 10)
- LongATRPer          = slow ATR window (default: 50)
- UseTwoStageSmooth   = enable second smoothing layer (default: true)
- SmoothFactor        = gain for 2nd-stage smoothing (default: 0.2)
- AlphaClampMax       = max allowed adaptive gain (default: 0.2)
- LockOnHighVol       = freeze signal if vol too high (default: true)
- VolLockThreshold    = lock trigger ratio (default: 2.0)

USAGE:
------
- Input:   High, Low, Close series
- Output:  Smoothed signal (overlay or buffer)
- Apply:   Trend filters, breakout confirmation, signal gating

NOTES:
------
- Python version provided for research/backtesting workflows.
- MQL5 version built for deployment in MetaTrader 5 terminal.
- Outputs are consistent across platforms.

LICENSE:
--------
(c) 2025 DieArchitekt. All rights reserved.
Use, modify, and distribute with credit.

R. P. Kennedy  
ORCID: [0009-0006-3598-0581](https://orcid.org/0009-0006-3598-0581)  
GitHub: https://github.com/DieArchitekt  
MQL5: https://www.mql5.com/en/users/diearchitekt
