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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   DrawDailyPivot();
   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   DrawDailyPivot();
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
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol, int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol, PERIOD_W1, week_index);
   double week_low = iLow(symbol, PERIOD_W1, week_index);
   double week_clo = iClose(symbol, PERIOD_W1, week_index);

   double w_pivot    = format_double((week_hig + week_low + week_clo) / 3, digits);
   double week_s1    = format_double((2 * w_pivot) - week_hig, digits);
   double week_s2    = format_double(w_pivot - (week_hig - week_low), digits);
   double week_s3    = format_double(week_low - 2 * (week_hig - w_pivot), digits);
   double week_r1    = format_double((2 * w_pivot) - week_low, digits);
   double week_r2    = format_double(w_pivot + (week_hig - week_low), digits);
   double week_r3    = format_double(week_hig + 2 * (w_pivot - week_low), digits);

   double week_amp = MathAbs(week_s3 - week_s2)
                     + MathAbs(week_s2 - week_s1)
                     + MathAbs(week_s1 - w_pivot)
                     + MathAbs(w_pivot - week_r1)
                     + MathAbs(week_r1 - week_r2)
                     + MathAbs(week_r2 - week_r3);

   week_amp = format_double(week_amp / 6, digits);

   return week_amp;
  }

//+------------------------------------------------------------------+
string format_double_to_string(double number, int digits = 5)
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_amp_week(string symbol, int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_week_amp(symbol, index);
     }
   double week_amp = total_amp / size;

   return week_amp;
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
//   ObjectsDeleteAll();

   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;

   /*
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   datetime close_time_today = iTime(symbol, PERIOD_D1, 0) + 86400;


   double   yesterday_open   = iOpen(symbol, PERIOD_D1, 1);
   double   yesterday_close  = iClose(symbol, PERIOD_D1, 1);
   double   yesterday_high   = iHigh(symbol, PERIOD_D1, 1);
   double   yesterday_low    = iLow(symbol, PERIOD_D1, 1);
   color    yesterday_color  = get_line_color(yesterday_open, yesterday_close);


   datetime today_close_time   = today_open_time + 86400;
   double   today_open = iOpen(symbol, PERIOD_D1, 0);
   double   today_close = iClose(symbol, PERIOD_D1, 0);
   double   today_low = iLow(symbol, PERIOD_D1, 0);
   double   today_hig = iHigh(symbol, PERIOD_D1, 0);

   double pre_day_mid = (yesterday_high + yesterday_low) / 2.0;
   double today_mid = (today_hig + today_low) / 2.0;
   color day_mid_color = get_line_color(pre_day_mid, today_mid);

   // -----------------------------------------------------------------------
   if(chartPeriod <= PERIOD_H4)
     {
      VLineCreate(0, "close_time_today", 0, close_time_today);

      for(int index = 0; index < 30; index ++)
        {
         VLineCreate(0, "d"+ (string)index + "_c_time", 0, iTime(symbol, PERIOD_D1, index));
        }
     }
   // -----------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_lot_size;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
   double week_amp = dic_amp_w;
   //double week_amp = calc_avg_amp_week(symbol, 20);

   double d_amp = week_amp / 2.0;

   int total_candle = 50;
   double total_amp_h4 = 0.0;
   double amp_max_d1 = 0.0;
   double amp_avg_d1 = 0.0;
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
      amp_avg_d1 += (tmp_hig_d1 - tmp_low_d1);
     }

   double amp_avg_h4 = format_double(total_amp_h4 / total_candle, digits);
   amp_avg_d1 = format_double(amp_avg_d1 / total_candle, digits);
   */
// -----------------------------------------------------------------------



// -----------------------------------------------------------------------


// Vẽ Bollinger Bands lên biểu đồ
     {
      string symbol = Symbol();
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places
      datetime yesterday_time = iTime(symbol, PERIOD_D1, 0);
      datetime today_close_time   = yesterday_time + 86400;

      double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
      CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
      double hi_h1_20_1 = upper_h1_20_1[0];
      double mi_h1_20_0 = middle_h1_20_1[0];
      double lo_h1_20_1 = lower_h1_20_1[0];
      double amp_h1 = MathAbs(hi_h1_20_1 - mi_h1_20_0);

      double hi_h1_20_2 = hi_h1_20_1 + amp_h1;
      double lo_h1_20_2 = lo_h1_20_1 - amp_h1;

      double hi_h1_20_3 = hi_h1_20_2 + amp_h1;
      double lo_h1_20_3 = lo_h1_20_2 - amp_h1;

      create_lable_trim("lbl_hi_h1_20_2", today_close_time, hi_h1_20_2, " (+2) "+ format_double_to_string(hi_h1_20_2, digits), clrBlue, digits);
      create_trend_line("hi_h1_20_2", today_open_time, today_close_time, hi_h1_20_2, clrBlue, digits, false, false, true);

      create_lable_trim("lbl_mi_h1_20_0", today_close_time, mi_h1_20_0, " (00) "+ format_double_to_string(mi_h1_20_0, digits), clrRed, digits);
      create_trend_line("mi_h1_20_0", today_open_time, today_close_time, mi_h1_20_0, clrRed, digits, false, false);
      ObjectSetInteger(0, "mi_h1_20_0", OBJPROP_STYLE, STYLE_DASH);

      create_lable_trim("lbl_lo_h1_20_2", today_close_time, lo_h1_20_2, " (-2) "+ format_double_to_string(lo_h1_20_2, digits), clrBlue, digits);
      create_trend_line("lo_h1_20_2", today_open_time, today_close_time, lo_h1_20_2, clrBlue, digits, false, false, true);


      create_lable_trim("lbl_hi_h1_20_1", today_close_time, hi_h1_20_1, " (+1) " + format_double_to_string(hi_h1_20_1, digits), clrBlack, digits);
      create_lable_trim("lbl_lo_h1_20_1", today_close_time, lo_h1_20_1, " (-1) " + format_double_to_string(lo_h1_20_1, digits), clrBlack, digits);
      create_trend_line("hi_h1_20_1", today_open_time, today_close_time, hi_h1_20_1, clrBlack, digits, false, false);
      create_trend_line("lo_h1_20_1", today_open_time, today_close_time, lo_h1_20_1, clrBlack, digits, false, false);


      create_lable_trim("lbl_hi_h1_20_3", today_close_time, hi_h1_20_3, " (+3) "+ format_double_to_string(hi_h1_20_3, digits), clrBlack, digits);
      create_lable_trim("lbl_lo_h1_20_3", today_close_time, lo_h1_20_3, " (-3) "+ format_double_to_string(lo_h1_20_3, digits), clrBlack, digits);
      create_trend_line("hi_h1_20_3", today_open_time, today_close_time, hi_h1_20_3, clrBlack, digits, false, false);
      create_trend_line("lo_h1_20_3", today_open_time, today_close_time, lo_h1_20_3, clrBlack, digits, false, false);

      double hi_h1_20_4 = hi_h1_20_3 + amp_h1;
      double lo_h1_20_4 = lo_h1_20_3 - amp_h1;
      create_lable_trim("lbl_hi_h1_20_4", today_close_time, hi_h1_20_4, " (+4) "+ format_double_to_string(hi_h1_20_4, digits), clrBlack, digits);
      create_lable_trim("lbl_lo_h1_20_4", today_close_time, lo_h1_20_4, " (-4) "+ format_double_to_string(lo_h1_20_4, digits), clrBlack, digits);
      create_trend_line("hi_h1_20_4", today_open_time, today_close_time, hi_h1_20_4, clrBlack, digits, false, false);
      create_trend_line("lo_h1_20_4", today_open_time, today_close_time, lo_h1_20_4, clrBlack, digits, false, false);

      double stop_loss_buy = mi_h1_20_0 - (amp_h1*5);
      double stop_loss_sel = mi_h1_20_0 + (amp_h1*5);
      create_trend_line("stop_loss_buy", today_open_time, today_close_time, stop_loss_buy, clrRed, digits, false, false);
      create_trend_line("stop_loss_sel", today_open_time, today_close_time, stop_loss_sel, clrRed, digits, false, false);

      double upper_h4[], middle_h4[], lower_h4[];
      CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
      double hi_h4_20_2 = upper_h4[0];
      double lo_h4_20_2 = lower_h4[0];
      create_lable("H4(20, 2)", today_close_time, hi_h4_20_2, "                     H4(2)", clrBlack, digits);
      create_lable("H4(20, 2)", today_close_time, lo_h4_20_2, "                     H4(-2)", clrBlack, digits);
      create_trend_line("hi_h4_20_2", today_open_time, today_close_time, hi_h4_20_2, clrTeal, digits, false, false, true);
      create_trend_line("lo_h4_20_2", today_open_time, today_close_time, lo_h4_20_2, clrTeal, digits, false, false, true);

     }
   /*
   // sleep_time
      if(chartPeriod <= PERIOD_H1)
        {
         for(int index = 0; index <= 5; index ++)
           {
            datetime tmp_open_time   = iTime(symbol, PERIOD_D1, index);
            datetime tmp_open_08am   = tmp_open_time + 3600;
            datetime tmp_close_time  = tmp_open_time + 86400;

            double   tmp_open_price  = iOpen(symbol, PERIOD_D1, index);
            double   tmp_close_price = iClose(symbol, PERIOD_D1, index);

            MqlDateTime struct_open_time;
            TimeToStruct(tmp_open_time, struct_open_time);
            string   prefix = date_time_to_string(struct_open_time);

            double   tmp_low_price = iLow(symbol, PERIOD_D1, index);
            double   tmp_hig_price = iHigh(symbol, PERIOD_D1, index);
            RectangleCreate(0, prefix + "_sleep_time", tmp_open_time, tmp_low_price, tmp_open_08am, tmp_hig_price, STYLE_DOT, 1, true, true, false, true, 0, clrGainsboro);
           }
        }

      if(chartPeriod > PERIOD_H1)
        {
         datetime week_time_1 = iTime(symbol, PERIOD_W1, 1);
         //   double w_open       = iOpen(symbol, PERIOD_W1, 1);
         //   create_trend_line("w_open", week_time_1, TimeGMT(), w_open, clrBlack, digits, false);
         //   ObjectSetInteger(0, "w_open", OBJPROP_STYLE, STYLE_DASH);
         //   ObjectSetInteger(0, "w_open", OBJPROP_WIDTH, 1);
         //   double w_close       = iClose(symbol, PERIOD_W1, 1);
         //   create_trend_line("w_close", week_time_1, TimeGMT(), w_close, clrBlack, digits, false);
         //   ObjectSetInteger(0, "w_close", OBJPROP_STYLE, STYLE_DASH);
         //   ObjectSetInteger(0, "w_close", OBJPROP_WIDTH, 1);

         //Print(symbol, " init:",  dic_top_price, " amp:", week_amp);
         for(int index = 0; index < 25; index ++)
           {
            double w_s1  = dic_top_price - (week_amp*index);
            create_trend_line("w_dn_" + (string)index, week_time_1, TimeGMT(), w_s1, clrBlack, digits, true, true);

            double w_r1  = dic_top_price + (week_amp*index);
            create_trend_line("w_up_" + (string)index, week_time_1, TimeGMT(), w_r1, clrBlack, digits, true, true);
           }
        }
        */
// ----------------------------------------------------------------------
  }

// Hàm tính toán Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits, double deviation = 2)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
// double deviation = 2; // Độ lệch chuẩn cho Bollinger Bands
   int shift = 0; // Vị trí trên biểu đồ
   int count = 50;//Bars(symbol, timeframe); // Số nến trên biểu đồ

   for(int i = 0; i < count; i++)
     {
      double sum = 0.0;
      double sumSquared = 0.0;

      for(int j = 0; j < period; j++)
        {
         double price = iClose(symbol, timeframe, i + shift + j);
         sum += price;
         sumSquared += price * price;
        }


      double variance = sumSquared / period - (sum / period) * (sum / period);
      double stddev = MathSqrt(variance);

      double middle_i = sum / period;
      double upper_i = middle_i + deviation * stddev;
      double lower_i = middle_i - deviation * stddev;

      ArrayResize(middle, i + 1);
      ArrayResize(upper, i + 1);
      ArrayResize(lower, i + 1);

      middle[i] = format_double(middle_i, digits);
      upper[i] = format_double(upper_i, digits);
      lower[i] = format_double(lower_i, digits);
     }
  }
// Hàm tính giá trị của MA(89) cho cây nến hiện tại
double CalculateMAxx(string symbol, ENUM_TIMEFRAMES timeframe, int ma=89, int candle_no=1)
  {
   double maValue = iMA(symbol, timeframe, ma, 0, MODE_SMA, candle_no);
   return (maValue);
  }
// Hàm tính giá trị của MA(89) cho cây nến trước cây nến hiện tại
double CalculateMAxxPrevious(string symbol, ENUM_TIMEFRAMES timeframe, int ma=89)
  {
   double maValue = iMA(symbol,  timeframe, ma, 0, MODE_SMA, 1);
   return (maValue);
  }

// Hàm tính giá trị tối đa và tối thiểu của 50 cây nến gần nhất
void CalculateMaxMinPrices(string symbol, ENUM_TIMEFRAMES timeframe, double &maxPrice, double &minPrice)
  {
   maxPrice = -DBL_MAX; // Khởi tạo giá trị max với giá trị nhỏ nhất
   minPrice = DBL_MAX; // Khởi tạo giá trị min với giá trị lớn nhất

   int candlesToCheck = 50; // Số cây nến cần xem xét

   for(int i = 0; i < candlesToCheck; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i); // Giá cao nhất của cây nến
      double lowPrice = iLow(symbol, timeframe, i); // Giá thấp nhất của cây nến

      // Tìm giá trị max và min
      if(highPrice > maxPrice)
         maxPrice = highPrice;

      if(lowPrice < minPrice)
         minPrice = lowPrice;
     }
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
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const bool              ray_left = false,
   const bool              ray_right = true,
   const bool              is_solid_line = false
)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
     }
   else
     {
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

//create_lable(name, time_to, price, clr_color, digits);
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
      time=TimeGMT();
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
      time1=TimeGMT();
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
   color candle_color = clrDarkGreen;
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

// Hàm để lấy dữ liệu từ Dictionary
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &lot_size_per_500usd)
  {
   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      amp_w = 1060.00;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "DX")
     {
      i_top_price = 106.8;
      amp_w = 0.69500;
      lot_size_per_500usd = 7.00;
      return;
     }
   if(symbol == "USOIL.cash")
     {
      i_top_price = 99.85;
      amp_w = 2.50000;
      lot_size_per_500usd = 1.75;
      return;
     }
   if(symbol == "XAGUSD")
     {
      i_top_price = 28.380;
      amp_w = 0.63500;
      lot_size_per_500usd = 0.15;
      return;
     }
   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      amp_w = 22.9500;
      lot_size_per_500usd = 0.20;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 15920;
      amp_w = 271.500;
      lot_size_per_500usd = 1.75;
      return;
     }
   if(symbol == "US30.cash")
     {
      i_top_price = 35700;
      amp_w = 388.350;
      lot_size_per_500usd = 1.00;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.6500;
      amp_w = 1.07795;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "AUDUSD")
     {
      i_top_price = 0.72000;
      amp_w = 0.00765;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "EURAUD")
     {
      i_top_price = 1.73000;
      amp_w = 0.01375;
      lot_size_per_500usd = 0.50;
      return;
     }
   if(symbol == "EURGBP")
     {
      i_top_price = 0.90265;
      amp_w = 0.00455;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "EURUSD")
     {
      i_top_price = 1.12500;
      amp_w = 0.00790;
      lot_size_per_500usd = 0.60;
      return;
     }
   if(symbol == "GBPUSD")
     {
      i_top_price = 1.31365;
      amp_w = 0.01085;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.40775;
      amp_w = 0.00795;
      lot_size_per_500usd = 0.85;
      return;
     }
   if(symbol == "USDCHF")
     {
      i_top_price = 0.94235;
      amp_w = 0.00715;
      lot_size_per_500usd = 0.60;
      return;
     }
   if(symbol == "USDJPY")
     {
      i_top_price = 154.395;
      amp_w = 1.29500;
      lot_size_per_500usd = 0.50;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.70200;
      amp_w = 0.00500;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "CADJPY")
     {
      i_top_price = 112.000;
      amp_w = 1.00000;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "CHFJPY")
     {
      i_top_price = 169.320;
      amp_w = 1.41000;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "EURJPY")
     {
      i_top_price = 162.065;
      amp_w = 1.39000;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "GBPJPY")
     {
      i_top_price = 188.115;
      amp_w = 1.61500;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "NZDJPY")
     {
      i_top_price = 90.7000;
      amp_w = 0.90000;
      lot_size_per_500usd = 0.70;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.51938;
      amp_w = 0.00945;
      lot_size_per_500usd = 0.70;
      return;
     }
   if(symbol == "EURCHF")
     {
      i_top_price = 1.01016;
      amp_w = 0.00455;
      lot_size_per_500usd = 1.00;
      return;
     }
   if(symbol == "EURNZD")
     {
      i_top_price = 1.89388;
      amp_w = 0.01585;
      lot_size_per_500usd = 0.50;
      return;
     }
   if(symbol == "GBPAUD")
     {
      i_top_price = 2.02830;
      amp_w = 0.01605;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "GBPCAD")
     {
      i_top_price = 1.75620;
      amp_w = 0.01210;
      lot_size_per_500usd = 0.55;
      return;
     }
   if(symbol == "GBPCHF")
     {
      i_top_price = 1.16955;
      amp_w = 0.00685;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "GBPNZD")
     {
      i_top_price = 2.18685;
      amp_w = 0.01705;
      lot_size_per_500usd = 0.45;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.94763;
      amp_w = 0.00735;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "AUDCHF")
     {
      i_top_price = 0.65518;
      amp_w = 0.00545;
      lot_size_per_500usd = 0.85;
      return;
     }
   if(symbol == "AUDNZD")
     {
      i_top_price = 1.11568;
      amp_w = 0.00595;
      lot_size_per_500usd = 1.25;
      return;
     }
   if(symbol == "NZDCAD")
     {
      i_top_price = 0.87860;
      amp_w = 0.00725;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "NZDCHF")
     {
      i_top_price = 0.58565;
      amp_w = 0.00515;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "NZDUSD")
     {
      i_top_price = 0.65315;
      amp_w = 0.00670;
      lot_size_per_500usd = 0.70;
      return;
     }


   i_top_price = iClose(symbol, PERIOD_W1, 1);
   amp_w =  calc_avg_amp_week(symbol, 20);
   lot_size_per_500usd = 0;

//Alert(" Add Symbol Data:",  symbol, " amp:", amp_w);
   return;

  }
//+------------------------------------------------------------------+
