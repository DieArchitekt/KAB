import numpy as np
import pandas as pd

# df must contain: ['open', 'high', 'low', 'close']
# CSV or broker API

def calc_tr(high, low, prev_close):
    return np.maximum(high - low, np.maximum(np.abs(high - prev_close), np.abs(low - prev_close)))

def compute_kab(df,
                base_alpha=0.1,
                short_atr_period=10,
                long_atr_period=50,
                use_two_stage_smooth=True,
                smooth_factor=0.2,
                alpha_clamp_max=0.2,
                lock_on_high_vol=True,
                vol_lock_threshold=2.0):

    close = df['close'].values
    high = df['high'].values
    low = df['low'].values
    length = len(close)

    kab = np.full(length, np.nan)
    short_atr = 0.0
    long_atr = 0.0
    EPS = 1e-10

    # ---- INIT SEED ----
    kab[0] = close[0]
    for i in range(1, long_atr_period + 1):
        kab[i] = close[i]
        short_atr += calc_tr(high[i], low[i], close[i - 1])
    short_atr /= short_atr_period
    long_atr = short_atr

    k_short = 2.0 / (1.0 + short_atr_period)
    k_long = 2.0 / (1.0 + long_atr_period)

    for i in range(long_atr_period + 1, length):
        tr = calc_tr(high[i], low[i], close[i - 1])
        short_atr = (1.0 - k_short) * short_atr + k_short * tr
        long_atr = (1.0 - k_long) * long_atr + k_long * short_atr

        ratio = short_atr / max(long_atr, EPS)
        adaptive_alpha = base_alpha * ratio
        adaptive_alpha = min(adaptive_alpha, alpha_clamp_max)
        is_locked = lock_on_high_vol and ratio > vol_lock_threshold

        prev = kab[i - 1]
        if is_locked:
            next_val = prev
        else:
            unsmoothed = prev + adaptive_alpha * (close[i] - prev)
            next_val = prev + smooth_factor * (unsmoothed - prev) if use_two_stage_smooth else unsmoothed

        kab[i] = next_val

    # ---- OUTPUT COLUMN: 'kab' ----
    df['kab'] = kab
    return df