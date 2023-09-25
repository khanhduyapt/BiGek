//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
input ENUM_TIMEFRAMES TimeFrame = PERIOD_D1; // Chọn khung thời gian (D1 là mặc định)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   DrawDailyPivot();
   EventSetMillisecondTimer(60000); // Cập nhật mỗi phút
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   datetime current_time = TimeCurrent();
   datetime last_bar_time = iTime(Symbol(), TimeFrame, 0);
   if(current_time > last_bar_time)
     {
      ObjectsDeleteAll();
      DrawDailyPivot();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectsDeleteAll()
  {
  }

//+------------------------------------------------------------------+
//Daily Pivot thường được tính dựa trên công thức sau:

//Pivot Point (PP): Điểm Pivot là điểm giữa giá đóng cửa (Close), giá cao (High), và giá thấp (Low) của phiên giao dịch trước đó. Công thức tính Pivot Point là:
//PP = (High + Low + Close) / 3

//Support và Resistance Levels: Dựa vào Pivot Point, bạn có thể tính toán các mức hỗ trợ (Support) và kháng cự (Resistance) hàng ngày.
//Các mức này thường được tính dựa trên các công thức khác nhau, nhưng một trong những cách phổ biến để tính mức Support và Resistance là sử dụng các công thức sau:

//Support 1 (S1): S1 = (2 * PP) - High
//Support 2 (S2): S2 = PP - (High - Low)
//Resistance 1 (R1): R1 = (2 * PP) - Low
//Resistance 2 (R2): R2 = PP + (High - Low)
//+------------------------------------------------------------------+
void DrawDailyPivot()
  {

   datetime daily_time = iTime(Symbol(), TimeFrame, 1);
   double daily_open = iOpen(Symbol(), TimeFrame, 1);
   double daily_high = iHigh(Symbol(), TimeFrame, 1);
   double daily_low = iLow(Symbol(), TimeFrame, 1);
   double daily_close = iClose(Symbol(), TimeFrame, 1);


   double mid = daily_close - daily_open;
   color candle_color = clrBlue;
   if(daily_open > daily_close)
     {
      candle_color = clrRed;
      mid = daily_open - daily_close;
     }

   mid = (mid / 2);

   if(daily_open > daily_close)
     {
      mid = daily_close + mid;
     }
   else
     {
      mid = daily_open + mid;
     }


   double pivot = (daily_high + daily_low + daily_close) / 3;
   double support1 = (2 * pivot) - daily_high;
   double support2 = pivot - (daily_high - daily_low);
   double support3 = daily_low - 2 * (daily_high - pivot);
   double resistance1 = (2 * pivot) - daily_low;
   double resistance2 = pivot + (daily_high - daily_low);
   double resistance3 = daily_high + 2 * (pivot - daily_low);

   double amp = MathAbs(support3 - support2) + MathAbs(support2 - support1) + MathAbs(support1 - pivot) + MathAbs(pivot - resistance1) + MathAbs(resistance1 - resistance2) + MathAbs(resistance2 - resistance3);
   amp = amp / 6;

   support1 = mid - amp;
   support2 = support1 - amp;
   support3 = support2 - amp;
   resistance1 = mid + amp;
   resistance2 = resistance1 + amp;
   resistance3 = resistance2 + amp;

   int    digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);     // number of decimal places
   mid                = NormalizeDouble(mid, digits);
   pivot              = NormalizeDouble(pivot, digits);
   support1           = NormalizeDouble(support1, digits);
   support2           = NormalizeDouble(support2, digits);
   support3           = NormalizeDouble(support3, digits);
   resistance1        = NormalizeDouble(resistance1, digits);
   resistance2        = NormalizeDouble(resistance2, digits);
   resistance3        = NormalizeDouble(resistance3, digits);


   ObjectCreate(0, "mid", OBJ_TREND, 0, daily_time, mid, TimeCurrent(), mid);
   ObjectSetInteger(0, "mid", OBJPROP_COLOR, candle_color);
   ObjectSetInteger(0, "mid", OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, "mid", OBJPROP_WIDTH, 2); // Độ dày của đường trendline


   ObjectCreate(0, "S1", OBJ_TREND, 0, daily_time, support1, TimeCurrent(), support1);
   ObjectSetInteger(0, "S1", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "S2", OBJ_TREND, 0, daily_time, support2, TimeCurrent(), support2);
   ObjectSetInteger(0, "S2", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "S3", OBJ_TREND, 0, daily_time, support3, TimeCurrent(), support3);
   ObjectSetInteger(0, "S3", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "R1", OBJ_TREND, 0, daily_time, resistance1, TimeCurrent(), resistance1);
   ObjectSetInteger(0, "R1", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "R2", OBJ_TREND, 0, daily_time, resistance2, TimeCurrent(), resistance2);
   ObjectSetInteger(0, "R2", OBJPROP_COLOR, clrBlack);

   ObjectCreate(0, "R3", OBJ_TREND, 0, daily_time, resistance3, TimeCurrent(), resistance3);
   ObjectSetInteger(0, "R3", OBJPROP_COLOR, clrBlack);


   ObjectCreate(0, "Open", OBJ_TREND, 0, daily_time, daily_open, TimeCurrent(), daily_open);
   ObjectSetInteger(0, "Open", OBJPROP_COLOR, candle_color);

   ObjectCreate(0, "Close", OBJ_TREND, 0, daily_time, daily_close, TimeCurrent(), daily_close);
   ObjectSetInteger(0, "Close", OBJPROP_COLOR, candle_color);

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
