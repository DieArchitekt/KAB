# KAB
*A volatility-aware baseline.*

Retail traders tend to "experiment" with tweaking lookback periods manually, repeatedly, until they curve-fit. Instead of cycling EMA(20), EMA(21), EMA(22), we can use KAB.

Unlike moving averages (SMA, EMA, WMA, etc.) that are static, and more complex ones (Hull, T3) that are parameter driven, KAB is volatility-aware.

The ratio of ATRs (the volatility of volatility) drives the adaptive smoothing gain. Result: stable during chaos, responsive during drift.

Most adaptive indicators (Kaufman’s, VIDYA, etc.) use efficiency ratios (price direction vs. noise) or raw volatility. KAB uses relative volatility (fast vs slow).

KAB behaves similarly to a moving average / baseline, but it's core mechanism is unique.

MECHANISM:
-------------
1. Calculate short and long ATR.
2. Compute ratio = short / long.
3. Scale the smoothing coefficient (`alpha`) by this ratio.
4. Cap the maximum gain (optional).
5. Optionally lock output when volatility exceeds a threshold.
6. Optional second smoothing pass.

INPUTS:
---------------
- `BaseAlpha`          = base smoothing gain (default: 0.1)
- `ShortATRPeriod`     = fast ATR window (default: 8)
- `LongATRPeriod`      = slow ATR window (default: 64)
- `UseTwoStage`        = enable second smoothing layer (default: true)
- `SmoothFactor`       = gain for 2nd-stage smoothing (default: 0.2)
- `MaxAlpha`           = max allowed adaptive gain (default: 0.2)
- `EnableLock`         = freeze signal if vol too high (default: true)
- `LockOnThresh`       = lock trigger ratio (default: 2.0)
- `LockOffThresh`      = unlock ratio (default: 1.8)
- `UnlockBars`         = bars to force-release lock (default: 50)

USAGE:
------
- **Input**: High, Low, Close series
- **Output**: Adaptive smoothed signal (chart overlay or buffer)

LICENSE:
--------
(c) 2025 DieArchitekt. All rights reserved.
Use, modify, and distribute with credit.

R. P. Kennedy  
ORCID: [0009-0006-3598-0581](https://orcid.org/0009-0006-3598-0581)  
GitHub: https://github.com/DieArchitekt  
MQL5: https://www.mql5.com/en/users/diearchitekt
LinkedIn: https://www.linkedin.com/in/diearchitekt/
