//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//input ENUM_TIMEFRAMES TimeFrame = PERIOD_D1; // Chọn khung thời gian (D1 là mặc định)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   DrawDailyPivot();
   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
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
   datetime last_bar_time = iTime(Symbol(), PERIOD_D1, 0);
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
   ObjectsDeleteAll();
   string symbol = Symbol();
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places


   datetime close_time_today = iTime(symbol, PERIOD_D1, 0) + 86400;

   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   double   yesterday_open   = iOpen(symbol, PERIOD_D1, 1);
   double   yesterday_close  = iClose(symbol, PERIOD_D1, 1);
   double   yesterday_high   = iHigh(symbol, PERIOD_D1, 1);
   double   yesterday_low    = iLow(symbol, PERIOD_D1, 1);
   color    yesterday_color  = get_line_color(yesterday_open, yesterday_close);

   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;
   double   today_open = iOpen(symbol, PERIOD_D1, 0);
   double   today_close = iClose(symbol, PERIOD_D1, 0);

   double pre_day_mid = (yesterday_open + yesterday_close) / 2.0;
   double today_mid = (today_open + today_close) / 2.0;
   color day_mid_color = get_line_color(pre_day_mid, today_mid);

   /*
      ObjectCreate(0, "Today_Trend", OBJ_TREND, 0, yesterday_time, pre_day_mid, today_close_time, today_mid);
      ObjectSetInteger(0, "Today_Trend", OBJPROP_COLOR, day_mid_color);
      ObjectSetInteger(0, "Today_Trend", OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, "Today_Trend", OBJPROP_WIDTH, 1);
      TextCreate(0,"Label_Today_Trend", 0, today_close_time, today_mid, " ", day_mid_color);
   */
// -----------------------------------------------------------------------
   double pre_week_open = iOpen(symbol, PERIOD_W1, 1);
   double pre_week_close = iClose(symbol, PERIOD_W1, 1);

   double this_week_open = iOpen(symbol, PERIOD_W1, 0);
   double this_week_close = iClose(symbol, PERIOD_W1, 0);

   double pre_week_mid = (pre_week_open + pre_week_close) / 2.0;
   double this_week_mid = (this_week_open + this_week_close) / 2.0;
   color  week_mid_color = get_line_color(pre_week_mid, this_week_mid);

   double week_hig = iHigh(symbol, PERIOD_W1, 1);
   double week_low = iLow(symbol, PERIOD_W1, 1);
   double week_clo = iClose(symbol, PERIOD_W1, 1);


   double w_pivot    = format_double((week_hig + week_low + week_clo) / 3, digits);
   double week_s1    = format_double((2 * w_pivot) - week_hig, digits);
   double week_s2    = format_double(w_pivot - (week_hig - week_low), digits);
   double week_s3    = format_double(week_low - 2 * (week_hig - w_pivot), digits);
   double week_r1    = format_double((2 * w_pivot) - week_low, digits);
   double week_r2    = format_double(w_pivot + (week_hig - week_low), digits);
   double week_r3    = format_double(week_hig + 2 * (w_pivot - week_low), digits);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double week_amp = MathAbs(week_s3 - week_s2) + MathAbs(week_s2 - week_s1) + MathAbs(week_s1 - w_pivot) + MathAbs(w_pivot - week_r1) + MathAbs(week_r1 - week_r2) + MathAbs(week_r2 - week_r3);
   week_amp = format_double(week_amp / 6, digits);
   double d_amp = week_amp / 2.0;

   int total_candle = 50;
   double total_amp_h4 = 0.0;
   double amp_max_d1 = 0.0;
   for(int index = 1; index <= total_candle; index ++)
     {
      double   tmp_hig_h4         = iHigh(symbol, PERIOD_H4, index);
      double   tmp_low_h4         = iLow(symbol, PERIOD_H4, index);
      total_amp_h4 += (tmp_hig_h4 - tmp_low_h4);

      double   tmp_hig_d1         = iHigh(symbol, PERIOD_D1, index);
      double   tmp_low_d1         = iLow(symbol, PERIOD_D1, index);

      if(amp_max_d1 = (tmp_hig_d1 - tmp_low_d1))
        {
         amp_max_d1 = (tmp_hig_d1 - tmp_low_d1);
        }

     }
   double amp_avg_h4 = format_double(total_amp_h4 / total_candle, digits);



//Biên độ trung bình của 20 cây nến H4
   if(chartPeriod <= PERIOD_H1)
     {
      for(int index = 0; index <= 5; index ++)
        {
         datetime tmp_open_time   = iTime(symbol, PERIOD_D1, index);
         datetime tmp_open_08am   = tmp_open_time + 3600;
         datetime tmp_close_time  = tmp_open_time + 86400;

         double   tmp_open_price  = iOpen(symbol, PERIOD_D1, index);
         double   tmp_close_price = iClose(symbol, PERIOD_D1, index);

         double   day_pridict_hig = tmp_close_price + amp_max_d1;
         double   day_pridict_low = tmp_close_price - amp_max_d1;

         double   h4_pridict_hig  = tmp_close_price + amp_avg_h4;
         double   h4_pridict_low  = tmp_close_price - amp_avg_h4;

         MqlDateTime struct_open_time;
         TimeToStruct(tmp_open_time, struct_open_time);
         string   prefix = date_time_to_string(struct_open_time);


         ObjectCreate(0, prefix + "_open", OBJ_TREND, 0, tmp_open_time, tmp_open_price, tmp_open_08am, tmp_open_price);
         ObjectSetInteger(0, prefix + "_open", OBJPROP_COLOR, get_line_color(tmp_open_price, tmp_close_price));

         ObjectCreate(0, prefix + "_close", OBJ_TREND, 0, tmp_open_time, tmp_close_price, tmp_close_time, tmp_close_price);
         ObjectSetInteger(0, prefix + "_close", OBJPROP_COLOR, get_line_color(tmp_open_price, tmp_close_price));

         create_lable_trim(prefix + "_h4_pri_up", tmp_close_time, h4_pridict_hig, "<h>" + format_double_to_string(h4_pridict_hig, digits), clrBlack, digits);
         create_lable_trim(prefix + "_h4_pri_dn", tmp_close_time, h4_pridict_low, "<h>" + format_double_to_string(h4_pridict_low, digits), clrBlack, digits);

         create_lable_trim(prefix + "_d1_pri_up", tmp_close_time, day_pridict_hig, "<d>" + format_double_to_string(day_pridict_hig, digits), clrBlack, digits); // clrBlue
         create_lable_trim(prefix + "_d1_pri_dn", tmp_close_time, day_pridict_low, "<d>" + format_double_to_string(day_pridict_low, digits), clrBlack, digits); // clrFireBrick

         if(chartPeriod <= PERIOD_M15)
           {
            double   tmp_low_price = iLow(symbol, PERIOD_D1, index);
            double   tmp_hig_price = iHigh(symbol, PERIOD_D1, index);
            RectangleCreate(0, prefix + "_sleep_time", tmp_open_time, tmp_low_price, tmp_open_08am, tmp_hig_price, STYLE_DOT, 1, true, true, false, true, 0, clrGainsboro);
           }
        }
     }


   if(chartPeriod > PERIOD_M10)
     {
      datetime pre_week_time = iTime(symbol, PERIOD_W1, 1);
      ObjectCreate(0, "w_mid", OBJ_TREND, 0, pre_week_time, pre_week_mid, TimeCurrent(), this_week_mid);
      ObjectSetInteger(0, "w_mid", OBJPROP_COLOR, week_mid_color);
      ObjectSetInteger(0, "w_mid", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "w_mid", OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, "w_mid", OBJPROP_WIDTH, 2);

      double percent = MathAbs(pre_week_mid - this_week_mid);
      string lable_lbl_w_mid = format_double_to_string(week_amp, digits) + " / " + format_double_to_string(amp_avg_h4, digits) + " / ";
      lable_lbl_w_mid += format_double_to_string(100*(percent/week_amp), 0) + "%";

      create_lable_trim("lbl_w_mid", today_close_time, this_week_mid, lable_lbl_w_mid, week_mid_color, digits);


      double w_close = iClose(symbol, PERIOD_W1, 1);
      create_trend_line("w_close",pre_week_time, TimeCurrent(), w_close, week_mid_color, digits, true);
      ObjectSetInteger(0, "w_close", OBJPROP_STYLE, STYLE_DASH);

      for(int index = 1; index < 25; index ++)
        {
         double w_s1  = w_close - (week_amp*index);
         double w_r1  = w_close + (week_amp*index);
         create_trend_line("w_s" + (string)index, pre_week_time, TimeCurrent(), w_s1, clrBlack, digits, true, true);
         create_trend_line("w_r" + (string)index, pre_week_time, TimeCurrent(), w_r1, clrBlack, digits, true, true);
        }
     }
   else
     {
      double d_close = iClose(symbol, PERIOD_D1, 1);//default=1: hôm qua; 2:hôm kia; 3: hôm kìa
      double d_s1  = d_close - d_amp;
      double d_r1  = d_close + d_amp;
      double d_s2  = d_s1 - d_amp;
      double d_r2  = d_r1 + d_amp;
      double d_s3  = d_s2 - d_amp;
      double d_r3  = d_r2 + d_amp;
      double d_s4  = d_s3 - d_amp;
      double d_r4  = d_r3 + d_amp;
      double d_s5  = d_s4 - d_amp;
      double d_r5  = d_r4 + d_amp;

      yesterday_time   = iTime(symbol, PERIOD_D1, 0);
      create_trend_line("d_r1",yesterday_time, TimeCurrent(), d_r1, clrBlack, digits, false, false);
      create_trend_line("d_s2",yesterday_time, TimeCurrent(), d_s2, clrBlack, digits, false, false);
      create_trend_line("d_r2",yesterday_time, TimeCurrent(), d_r2, clrBlack, digits, false, false);
      create_trend_line("d_s3",yesterday_time, TimeCurrent(), d_s3, clrBlack, digits, false, false);
      create_trend_line("d_r3",yesterday_time, TimeCurrent(), d_r3, clrBlack, digits, false, false);
      create_trend_line("d_s4",yesterday_time, TimeCurrent(), d_s4, clrBlack, digits, false, false);
      create_trend_line("d_s5",yesterday_time, TimeCurrent(), d_s5, clrBlack, digits, false, false);
      create_trend_line("d_r4",yesterday_time, TimeCurrent(), d_r4, clrBlack, digits, false, false);
      create_trend_line("d_r5",yesterday_time, TimeCurrent(), d_r5, clrBlack, digits, false, false);



      datetime time_fr_1 = iTime(symbol, PERIOD_D1, 1);
      datetime time_to_1  = time_fr_1 + 86400;
      double   d_ope_1   = iOpen(symbol, PERIOD_D1, 1);
      double   d_clo_1   = iClose(symbol, PERIOD_D1, 1);
      double   d_hig_1   = iHigh(symbol, PERIOD_D1, 1);
      double   d_low_1   = iLow(symbol, PERIOD_D1, 1);
      draw_amp(d_amp, d_clo_1, "d_1", digits, time_fr_1, time_to_1, d_low_1, d_hig_1, clrBlack, false, false);

      datetime time_fr_2 = iTime(symbol, PERIOD_D1, 2);
      datetime time_to_2 = iTime(symbol, PERIOD_D1, 1);
      double   d_clo_2   = iClose(symbol, PERIOD_D1, 2);
      double   d_hig_2   = iHigh(symbol, PERIOD_D1, 2);
      double   d_low_2   = iLow(symbol, PERIOD_D1, 2);
      draw_amp(d_amp, d_clo_2, "d_2", digits, time_fr_2, time_to_2, d_low_2, d_hig_2, clrBlack, false, false);

      datetime time_fr_3 = iTime(symbol, PERIOD_D1, 3);
      datetime time_to_3 = iTime(symbol, PERIOD_D1, 2);
      double   d_clo_3   = iClose(symbol, PERIOD_D1, 3);
      double   d_hig_3   = iHigh(symbol, PERIOD_D1, 3);
      double   d_low_3   = iLow(symbol, PERIOD_D1, 3);
      draw_amp(d_amp, d_clo_3, "d_3", digits, time_fr_3, time_to_3, d_low_3, d_hig_3, clrBlack, false, false);

      datetime time_fr_4 = iTime(symbol, PERIOD_D1, 4);
      datetime time_to_4 = iTime(symbol, PERIOD_D1, 3);
      double   d_clo_4   = iClose(symbol, PERIOD_D1, 4);
      double   d_hig_4   = iHigh(symbol, PERIOD_D1, 4);
      double   d_low_4   = iLow(symbol, PERIOD_D1, 4);
      draw_amp(d_amp, d_clo_4, "d_4", digits, time_fr_4, time_to_4, d_low_4, d_hig_4, clrBlack, false, false);

      datetime time_fr_5 = iTime(symbol, PERIOD_D1, 5);
      datetime time_to_5 = iTime(symbol, PERIOD_D1, 4);
      double   d_clo_5   = iClose(symbol, PERIOD_D1, 5);
      double   d_hig_5   = iHigh(symbol, PERIOD_D1, 5);
      double   d_low_5   = iLow(symbol, PERIOD_D1, 5);
      draw_amp(d_amp, d_clo_5, "d_5", digits, time_fr_5, time_to_5, d_low_5, d_hig_5, clrBlack, false, false);


      MqlDateTime ngay_0;
      TimeToStruct(TimeCurrent(), ngay_0);
      RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-5), iTime(symbol, PERIOD_D1, 5), iOpen(symbol, PERIOD_D1, 5), iTime(symbol, PERIOD_D1, 4), iClose(symbol, PERIOD_D1, 5));
      RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-4), iTime(symbol, PERIOD_D1, 4), iOpen(symbol, PERIOD_D1, 4), iTime(symbol, PERIOD_D1, 3), iClose(symbol, PERIOD_D1, 4));
      RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-3), iTime(symbol, PERIOD_D1, 3), iOpen(symbol, PERIOD_D1, 3), iTime(symbol, PERIOD_D1, 2), iClose(symbol, PERIOD_D1, 3));
      RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-2), iTime(symbol, PERIOD_D1, 2), iOpen(symbol, PERIOD_D1, 2), iTime(symbol, PERIOD_D1, 1), iClose(symbol, PERIOD_D1, 2));
      RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-1), iTime(symbol, PERIOD_D1, 1), iOpen(symbol, PERIOD_D1, 1), iTime(symbol, PERIOD_D1, 0), iClose(symbol, PERIOD_D1, 1));
      RectangleCreate(0, get_day_of_week(ngay_0.day_of_week), iTime(symbol, PERIOD_D1, 0), today_open, TimeCurrent(), today_close);
     }

   if(chartPeriod <= PERIOD_H2)
     {
      VLineCreate(0, "close_time_today", 0, close_time_today);

      for(int index = 0; index < 20; index ++)
        {
         VLineCreate(0, "d"+ (string)index + "_c_time", 0, iTime(symbol, PERIOD_D1, index));
        }
     }
// ----------------------------------------------------------------------

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_amp(double d_amp, double d_close, string name, int digits, datetime time_from, datetime time_to, double yesterday_low, double yesterday_high, const color d_color=clrBlack
              , bool ray_left = false, bool ray_right = true)
  {
   double d_s1  = d_close - d_amp;
   double d_r1  = d_close + d_amp;
   double d_s2  = d_s1 - d_amp;
   double d_r2  = d_r1 + d_amp;
   double d_s3  = d_s2 - d_amp;
   double d_r3  = d_r2 + d_amp;
   double d_s4  = d_s3 - d_amp;
   double d_r4  = d_r3 + d_amp;
   double d_s5  = d_s4 - d_amp;
   double d_r5  = d_r4 + d_amp;

   create_trend_line(name + "_cl", time_from, time_to, d_close, d_color, digits, ray_left, ray_right);

   if(d_s1 > yesterday_low)
      create_trend_line(name + "_s1", time_from, time_to, d_s1, d_color, digits, ray_left, ray_right);

   if(d_r1< yesterday_high)
      create_trend_line(name + "_r1", time_from, time_to, d_r1, d_color, digits, ray_left, ray_right);

   if(d_s2 > yesterday_low)
      create_trend_line(name + "_s2", time_from, time_to, d_s2, d_color, digits, ray_left, ray_right);

   if(d_r2 < yesterday_high)
      create_trend_line(name + "_r2", time_from, time_to, d_r2, d_color, digits, ray_left, ray_right);

   if(d_s3 > yesterday_low)
      create_trend_line(name + "_s3", time_from, time_to, d_s3, d_color, digits, ray_left, ray_right);

   if(d_r3 < yesterday_high)
      create_trend_line(name + "_r3", time_from, time_to, d_r3, d_color, digits, ray_left, ray_right);

   if(d_s4 > yesterday_low)
      create_trend_line(name + "_s4", time_from, time_to, d_s4, d_color, digits, ray_left, ray_right);

   if(d_s5 > yesterday_low)
      create_trend_line(name + "_s5", time_from, time_to, d_s5, d_color, digits, ray_left, ray_right);

   if(d_r4 < yesterday_high)
      create_trend_line(name + "_r4", time_from, time_to, d_r4, d_color, digits, ray_left, ray_right);

   if(d_r5 < yesterday_high)
      create_trend_line(name + "_r5", time_from, time_to, d_r5, d_color, digits, ray_left, ray_right);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_of_week(const int index)
  {
   string daysOfWeek[7];

   daysOfWeek[0] = "Sun";   // Sunday
   daysOfWeek[1] = "Mon";   // Monday
   daysOfWeek[2] = "Tue";   // Tuesday
   daysOfWeek[3] = "Wed";   // Wednesday
   daysOfWeek[4] = "Thu";   // Thursday
   daysOfWeek[5] = "Fri";   // Friday
   daysOfWeek[6] = "Sat";   // Saturday

   if((1 <= index) && (index <= 5))
     {
      return daysOfWeek[index];
     }
   if(index <= 0)
     {
      return daysOfWeek[5+index];
     }

   return "d" + (string)index;
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
string format_double_to_string(double number, int digits)
  {
   string numberString = DoubleToString(number, 10);
   int dotPosition = StringFind(numberString, ".");
   if(dotPosition != -1 && StringLen(numberString) > dotPosition + digits)
     {
      int integerPart = (int)MathFloor(number);
      string fractionalPart = StringSubstr(numberString, dotPosition + 1, digits);
      numberString = (string)integerPart+ "." + fractionalPart;
     }

   return numberString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {

   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const bool              ray_left = false,
   const bool              ray_right = true
)
  {


   ObjectCreate(0, name, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

   create_lable(name, time_to, price, clr_color, digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, "        " + format_double_to_string(price, digits), clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, "        " + label, clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_trim(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, label, clr_color);
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
                const int               font_size=8,             // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,     // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,             // hidden in the object list
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

   ObjectSetString(chart_ID,name,OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT, font);
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


//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool VLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="VLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time=0,            // line time
                 const color           clr=clrBlack,        // line color
                 const ENUM_LINE_STYLE style=STYLE_DOT, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=false,    // highlight to move
                 const bool            ray=false,          // line's continuation down
                 const bool            hidden=true,      // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the line time is not set, draw it via the last bar
   if(!time)
      time=TimeCurrent();
//--- reset the error value
   ResetLastError();
//--- create a vertical line
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of displaying the line in the chart subwindows
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_rectangle

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price (Open)
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price (Close)
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            background=false,        // in the background
                     const bool            selection=false,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0,         // priority for mouse click
                     const color           def_color=clrBlack
                    )
  {
   int             sub_window=0;      // subwindow index

//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }

   color clr = get_line_color(price1, price2);
   if(def_color != clrBlack)
     {
      clr = def_color;
     }

//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,background);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color get_line_color(double open_price, double close_price)
  {
   color candle_color = clrBlue;
   if(open_price > close_price)
     {
      candle_color = clrFireBrick;
     }

   return candle_color;
  }
//+------------------------------------------------------------------+
string date_time_to_string(const MqlDateTime &deal_time)
  {
   string result = "";//(string)deal_time.year;
   if(deal_time.mon < 10)
     {
      result += "0" + (string)deal_time.mon ;
     }
   else
     {
      result += (string)deal_time.mon ;
     }
   if(deal_time.day < 10)
     {
      result += "0" + (string)deal_time.day ;
     }
   else
     {
      result += (string)deal_time.day;
     }


   return result;
  }

//+------------------------------------------------------------------+
