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
   int totalObjects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }

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
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ

   if(chartPeriod > PERIOD_H12)
     {
      ObjectsDeleteAll();
      return;
     }

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(daily_open > daily_close)
     {
      mid = daily_close + mid;
     }
   else
     {
      mid = daily_open + mid;
     }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double pivot = (daily_high + daily_low + daily_close) / 3;
   double support1 = (2 * pivot) - daily_high;
   double support2 = pivot - (daily_high - daily_low);
   double support3 = daily_low - 2 * (daily_high - pivot);
   double resistance1 = (2 * pivot) - daily_low;
   double resistance2 = pivot + (daily_high - daily_low);
   double resistance3 = daily_high + 2 * (pivot - daily_low);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double amp = MathAbs(support3 - support2) + MathAbs(support2 - support1) + MathAbs(support1 - pivot) + MathAbs(pivot - resistance1) + MathAbs(resistance1 - resistance2) + MathAbs(resistance2 - resistance3);
   amp = amp / 6;

   support1 = mid - amp;
   support2 = support1 - amp;
   support3 = support2 - amp;
   resistance1 = mid + amp;
   resistance2 = resistance1 + amp;
   resistance3 = resistance2 + amp;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int    digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);     // number of decimal places
   mid                = format_double(mid, digits);
   pivot              = format_double(pivot, digits);
   support1           = format_double(support1, digits);
   support2           = format_double(support2, digits);
   support3           = format_double(support3, digits);
   resistance1        = format_double(resistance1, digits);
   resistance2        = format_double(resistance2, digits);
   resistance3        = format_double(resistance3, digits);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "mid", OBJ_TREND, 0, daily_time, mid, TimeCurrent(), mid);
   ObjectSetInteger(0, "mid", OBJPROP_COLOR, candle_color);
   ObjectSetInteger(0, "mid", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "mid", OBJPROP_WIDTH, 2); // Độ dày của đường trendline
   TextCreate(0,"Label_mid", 0, TimeCurrent(), mid, (string)mid + " d", candle_color);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "S1", OBJ_TREND, 0, daily_time, support1, TimeCurrent(), support1);
   ObjectSetInteger(0, "S1", OBJPROP_COLOR, clrBlack);
   TextCreate(0,"ds1", 0, TimeCurrent(), support1, (string)support1, clrBlack);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "S2", OBJ_TREND, 0, daily_time, support2, TimeCurrent(), support2);
   ObjectSetInteger(0, "S2", OBJPROP_COLOR, clrBlack);
   TextCreate(0,"ds2", 0, TimeCurrent(), support2, (string)support2, clrBlack);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "S3", OBJ_TREND, 0, daily_time, support3, TimeCurrent(), support3);
   ObjectSetInteger(0, "S3", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "S3", OBJPROP_WIDTH, 2);
   TextCreate(0,"ds3", 0, TimeCurrent(), support3, (string)support3, clrBlack);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "R1", OBJ_TREND, 0, daily_time, resistance1, TimeCurrent(), resistance1);
   ObjectSetInteger(0, "R1", OBJPROP_COLOR, clrBlack);
   TextCreate(0,"dr1", 0, TimeCurrent(), resistance1, (string)resistance1, clrBlack);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "R2", OBJ_TREND, 0, daily_time, resistance2, TimeCurrent(), resistance2);
   ObjectSetInteger(0, "R2", OBJPROP_COLOR, clrBlack);
   TextCreate(0,"dr2", 0, TimeCurrent(), resistance2, (string)resistance2, clrBlack);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "R3", OBJ_TREND, 0, daily_time, resistance3, TimeCurrent(), resistance3);
   ObjectSetInteger(0, "R3", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "R3", OBJPROP_WIDTH, 2);
   TextCreate(0,"dr3", 0, TimeCurrent(), resistance3, (string)resistance3, clrBlack);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectCreate(0, "Close", OBJ_TREND, 0, daily_time, daily_close, TimeCurrent(), daily_close);
   ObjectSetInteger(0, "Close", OBJPROP_COLOR, candle_color);
   ObjectSetInteger(0, "Close", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "Close", OBJPROP_HIDDEN, false);

// -----------------------------------------------------------------------
   double pre_week_open = iOpen(Symbol(), PERIOD_W1, 1);
   double pre_week_close = iClose(Symbol(), PERIOD_W1, 1);
   double pre_week_mid = format_double((pre_week_open + pre_week_close) / 2.0, digits);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double this_week_open = iOpen(Symbol(), PERIOD_W1, 0);
   double this_week_close = iClose(Symbol(), PERIOD_W1, 0);
   double this_week_mid = format_double((this_week_open + this_week_close) / 2.0, digits);

   color week_mid_color = clrGreen;// Màu nền xanh cho tuần lên
   if(pre_week_mid > this_week_mid)
     {
      week_mid_color = clrRed;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   datetime pre_week_time = iTime(Symbol(), PERIOD_W1, 1);
   ObjectCreate(0, "Week_Trend", OBJ_TREND, 0, pre_week_time, pre_week_mid, TimeCurrent(), this_week_mid);
   ObjectSetInteger(0, "Week_Trend", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "Week_Trend", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "Week_Trend", OBJPROP_WIDTH, 2);
   TextCreate(0,"Label_Week_Trend", 0, TimeCurrent(), this_week_mid, (string)this_week_mid + " w", week_mid_color);

// -----------------------------------------------------------------------
   double week_hig = iHigh(Symbol(), TimeFrame, 1);
   double week_low = iLow(Symbol(), TimeFrame, 1);
   double week_clo = iClose(Symbol(), TimeFrame, 1);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double week_pivot = format_double((week_hig + week_low + week_clo) / 3, digits);
   double week_s1    = format_double((2 * week_pivot) - week_hig, digits);
   double week_s2    = format_double(week_pivot - (week_hig - week_low), digits);
   double week_s3    = format_double(week_low - 2 * (week_hig - week_pivot), digits);
   double week_r1    = format_double((2 * week_pivot) - week_low, digits);
   double week_r2    = format_double(week_pivot + (week_hig - week_low), digits);
   double week_r3    = format_double(week_hig + 2 * (week_pivot - week_low), digits);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double week_amp = MathAbs(week_s3 - week_s2) + MathAbs(week_s2 - week_s1) + MathAbs(week_s1 - week_pivot) + MathAbs(week_pivot - week_r1) + MathAbs(week_r1 - week_r2) + MathAbs(week_r2 - week_r3);
   week_amp = format_double(week_amp / 6, digits);

   /*
      week_s1 = format_double(pre_week_mid - week_amp, digits);
      week_s2 = format_double(week_s1 - week_amp- week_amp, digits);

      week_r1 = format_double(pre_week_mid + week_amp, digits);;
      week_r2 = format_double(week_r1 + week_amp + week_amp, digits);

      ObjectCreate(0, "week_s1", OBJ_TREND, 0, pre_week_time, week_s1, TimeCurrent(), week_s1);
      ObjectSetInteger(0, "week_s1", OBJPROP_COLOR, week_mid_color);
      ObjectSetInteger(0, "week_s1", OBJPROP_STYLE, STYLE_DOT);

      ObjectCreate(0, "week_r1", OBJ_TREND, 0, pre_week_time, week_r1, TimeCurrent(), week_r1);
      ObjectSetInteger(0, "week_r1", OBJPROP_COLOR, week_mid_color);
      ObjectSetInteger(0, "week_r1", OBJPROP_STYLE, STYLE_DOT);

      ObjectCreate(0, "week_s2", OBJ_TREND, 0, pre_week_time, week_s2, TimeCurrent(), week_s2);
      ObjectSetInteger(0, "week_s2", OBJPROP_COLOR, week_mid_color);
      ObjectSetInteger(0, "week_s2", OBJPROP_STYLE, STYLE_SOLID);
      //TextCreate(0,"Label_week_s2", 0, TimeCurrent(), week_s2, (string)week_s2, week_mid_color);

      ObjectCreate(0, "week_r2", OBJ_TREND, 0, pre_week_time, week_r2, TimeCurrent(), week_r2);
      ObjectSetInteger(0, "week_r2", OBJPROP_COLOR, week_mid_color);
      ObjectSetInteger(0, "week_r2", OBJPROP_STYLE, STYLE_SOLID);
      //TextCreate(0,"Label_week_r2", 0, TimeCurrent(), week_r2, (string)week_r2, week_mid_color);
   */
// ----------------------------------------------------------------------



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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   string numberString = DoubleToString(number, 10);
   int dotPosition = StringFind(numberString, ".");
   if(dotPosition != -1 && StringLen(numberString) > dotPosition + digits)
     {
      int integerPart = (int)MathFloor(number);
      string fractionalPart = StringSubstr(numberString, dotPosition + 1, digits);
      numberString = (string)integerPart+ "." + fractionalPart;
     }

   return StringToDouble(numberString);
  }

//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                string                  text="Text",              // the text itself
                const color             clr=clrRed,               // color
                const string            font="Arial",             // font
                const int               font_size=10,             // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_CENTER,     // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=false,             // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
//ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text

   StringReplace(text, "00000000001", "");
   StringReplace(text, "99999999999", "");
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,"                " + text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE, angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR, anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR, clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, selection);

   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, z_order);
//--- successful execution

   return(true);
  }
//+------------------------------------------------------------------+
