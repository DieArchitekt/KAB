#property strict
#property copyright "© DieArchitekt 2025"
#property link "github.com/DieArchitekt"
#property version "1.00"
#property description "Recursive signal smoother with ATR-ratio adaptive gain and optional smoothing."

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "KAB"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrchid
#property indicator_width1  2

input double KAB_BaseAlpha      = 0.1;
input int    KAB_ShortATRPer    = 10;
input int    KAB_LongATRPer     = 50;
input bool   UseTwoStageSmooth  = true;
input double SmoothFactor       = 0.2;
input double AlphaClampMax      = 0.2;
input bool   LockOnHighVol      = true;
input double VolLockThreshold   = 2.0;

#define EPS 1e-10

double KABBuffer[];

int OnInit()
{
   SetIndexBuffer(0, KABBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrOrchid);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_vol[],
                const long &vol[],
                const int &spread[])
{
   if (rates_total < MathMax(KAB_LongATRPer + 2, 3))
      return(0);

   int start = MathMax(prev_calculated - 1, 1);
   if (start < KAB_LongATRPer + 1)
      start = KAB_LongATRPer + 1;

   static double shortATR_prev = 0.0, longATR_prev = 0.0;

   if (prev_calculated == 0)
   {
      KABBuffer[0] = close[0];
      for (int i = 1; i < start; i++)
         KABBuffer[i] = close[i];

      for (int i = 1; i <= KAB_ShortATRPer; i++)
         shortATR_prev += CalcTR(high[i], low[i], close[i - 1]);
      shortATR_prev /= KAB_ShortATRPer;

      longATR_prev = shortATR_prev;
   }

   double kShort = 2.0 / (1.0 + KAB_ShortATRPer);
   double kLong  = 2.0 / (1.0 + KAB_LongATRPer);

   for (int i = start; i < rates_total; i++)
   {
      double tr = CalcTR(high[i], low[i], close[i - 1]);

      shortATR_prev = (1.0 - kShort) * shortATR_prev + kShort * tr;
      longATR_prev  = (1.0 - kLong)  * longATR_prev  + kLong  * shortATR_prev;

      double ratio = shortATR_prev / MathMax(longATR_prev, EPS);
      double adaptiveAlpha = KAB_BaseAlpha * ratio;
      if (adaptiveAlpha > AlphaClampMax)
         adaptiveAlpha = AlphaClampMax;

      bool isLocked = (LockOnHighVol && ratio > VolLockThreshold);
      double prev = KABBuffer[i - 1];
      double next;

      if (isLocked)
      {
         next = prev;

         if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && i == rates_total - 1 && rates_total > 1)
            next = KABBuffer[i - 1];
      }
      else
      {
         double unsmoothedStep = prev + adaptiveAlpha * (close[i] - prev);
         next = UseTwoStageSmooth ? prev + SmoothFactor * (unsmoothedStep - prev) : unsmoothedStep;
      }

      KABBuffer[i] = next;
   }

   return(rates_total);
}

double CalcTR(double hi, double lo, double prevClose)
{
   return MathMax(hi - lo, MathMax(MathAbs(hi - prevClose), MathAbs(lo - prevClose)));
}