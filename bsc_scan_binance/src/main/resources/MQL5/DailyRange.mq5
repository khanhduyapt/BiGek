//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//#include <MovingAverages.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string INDI_NAME = "DailyRange";
double dbRiskRatio = 0.001; // Rủi ro 0.1%
double INIT_EQUITY = 1000.0; // Vốn ban đầu 200$

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

//https://tradingview.com/chart/?symbol=USINTR
string arr_symbol[] =
  {
   "XAUUSD", "XAGUSD", "USOIL.cash", "BTCUSD",
   "US100.cash", "US30.cash", "US500.cash", "GER40.cash", "UK100.cash", //, "JP225.cash"
   "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
   "CADCHF", "CADJPY", "CHFJPY",
   "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
   "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
   "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
   "USDCAD", "USDCHF", "USDJPY"
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   CalculatePivot("PERIOD_W1", PERIOD_W1);
   CalculateAvgCandleHeigh("PERIOD_W1", PERIOD_W1);

   WriteNotifyToken();
   EventSetTimer(1800); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   WriteNotifyToken();
  }


//+------------------------------------------------------------------+
void WriteNotifyToken()
  {
   ObjectsDeleteAll();

   DrawDailyPivot();

   DrawBB_Label_D1();
  }

//+------------------------------------------------------------------+
void DrawDailyPivot()
  {
   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

// -----------------------------------------------------------------------
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   datetime close_time_today = iTime(symbol, PERIOD_D1, 0) + 86400;
   double   yesterday_open   = iOpen(symbol, PERIOD_D1, 1);
   double   yesterday_close  = iClose(symbol, PERIOD_D1, 1);
   double   yesterday_high   = iHigh(symbol, PERIOD_D1, 1);
   double   yesterday_low    = iLow(symbol, PERIOD_D1, 1);
   color    yesterday_color  = get_line_color(yesterday_open, yesterday_close);

   double   today_open = iOpen(symbol, PERIOD_D1, 0);
   double   today_close = iClose(symbol, PERIOD_D1, 0);
   double   today_low = iLow(symbol, PERIOD_D1, 0);
   double   today_hig = iHigh(symbol, PERIOD_D1, 0);

   double pre_day_mid = (yesterday_high + yesterday_low) / 2.0;
   double today_mid = (today_hig + today_low) / 2.0;
   color day_mid_color = get_line_color(pre_day_mid, today_mid);

// -----------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week);
   double week_amp = dic_amp_w;

// -----------------------------------------------------------------------
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


   datetime week_time_1 = iTime(symbol, PERIOD_W1, 1); //Returns the opening time of the bar
   datetime shift_chart = iTime(_Symbol, _Period, 0) - iTime(_Symbol, _Period, 10);
   datetime time_candle_cur = iTime(_Symbol, _Period, 0) + shift_chart;
   for(int index = 0; index < 25; index ++)
     {
      color line_color = clrBlack;
      bool is_solid = false;
      if(index == 0)
        {
         //is_solid = true;
        }

      double w_s1  = dic_top_price - (week_amp*index);
      create_lable("lbl_w_dn_"+ (string)index, time_candle_cur, w_s1, format_double_to_string(w_s1, digits), clrBlack, digits);
      create_trend_line("w_dn_" + (string)index, week_time_1, TimeGMT(), w_s1, line_color, digits, true, true, is_solid);
      ObjectSetInteger(0, "w_dn_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "w_dn_" + (string)index, OBJPROP_COLOR, clrSilver);

      double w_r1  = dic_top_price + (week_amp*index);
      create_lable("lbl_w_up_"+ (string)index, time_candle_cur, w_r1, format_double_to_string(w_r1, digits), clrBlack, digits);
      create_trend_line("w_up_" + (string)index, week_time_1, TimeGMT(), w_r1, line_color, digits, true, true, is_solid);
      ObjectSetInteger(0, "w_up_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "w_up_" + (string)index, OBJPROP_COLOR, clrSilver);
     }

   double lowest = 0.0;
   double higest = 0.0;
   for(int i = 0; i < 21; i++)
     {
      double lowPrice = iLow(symbol, PERIOD_W1, i);
      double higPrice = iHigh(symbol, PERIOD_W1, i);

      if((i == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((i == 0) || (higest < higPrice))
         higest = higPrice;
     }

   double mid_price = NormalizeDouble((higest + lowest) / 2, digits-1);
   create_lable("lbl_mid_price", time_candle_cur + shift_chart/2, mid_price, format_double_to_string(mid_price, digits-1), clrBlack, digits);
   create_trend_line("mid_price", week_time_1, TimeGMT(), mid_price, clrFireBrick, digits, true, true, true);
   ObjectSetInteger(0, "mid_price", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, "mid_price", OBJPROP_COLOR, clrFireBrick);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBB_Label_D1()
  {
   if(Period() > PERIOD_D1)
      return;

   string symbol = Symbol();

   datetime label_postion = iTime(symbol, _Period, 10);
   if(_Period > PERIOD_H4)
      label_postion = iTime(symbol, _Period, 5);
   if(_Period <= PERIOD_H4)
      label_postion = iTime(symbol, _Period, 10);

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double upper_d1_20_1[], middle_d1_20_1[], lower_d1_20_1[];
   CalculateBollingerBands(symbol, PERIOD_D1, upper_d1_20_1, middle_d1_20_1, lower_d1_20_1, digits, 1);
   double hi_d1_20_1 = upper_d1_20_1[0];
   double mi_d1_20_0 = middle_d1_20_1[0];
   double lo_d1_20_1 = lower_d1_20_1[0];

   double amp_d1 = MathAbs(hi_d1_20_1 - mi_d1_20_0);

   string str_stop = " D(00)";
   double avg_amp_d1 = CalculateAverageCandleHeight(PERIOD_D1, symbol);


   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 1);
   double mi_h4_20_0 = middle_h4[0];
   double amp_h4 = MathAbs(upper_h4[0] - middle_h4[0]);

   double hi_h4_20_2 = mi_h4_20_0 + amp_h4*2;
   double lo_h4_20_2 = mi_h4_20_0 - amp_h4*2;

   string str_line = "";
   for(int index = 1; index <= 50; index++)
      str_line += "-";

   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, "H4(+2)--------------------" + str_line, clrBlack, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, "H4(-2)--------------------" + str_line, clrBlack, digits);

   create_lable_trim("lbl_mi_d1_20_0", label_postion, mi_d1_20_0, str_line + " D(00)", clrRed, digits);

   ObjectSetInteger(0, "mi_d1_20_0", OBJPROP_STYLE, STYLE_DASH);
   for(int i = 1; i<=5; i++)
     {
      bool is_solid = false;
      bool is_ray_left = (i==2) ? true : false;
      color line_color = clrBlack;
      if(i == 1)
         line_color = clrDimGray;
      if(i == 2)
         line_color = clrBlue;
      if(i == 3)
         line_color = clrMediumSeaGreen;
      if(i == 4)
         line_color = clrBlack;
      if(i == 5)
         line_color = clrRed;
      line_color = clrBlack;

      double hi_d1_20_i = mi_d1_20_0 + (i*amp_d1);
      double lo_d1_20_i = mi_d1_20_0 - (i*amp_d1);

      create_lable_trim("lbl_hi_d1_20_" + (string)i, label_postion, hi_d1_20_i, str_line + " D(+" + (string)i + ")", line_color, digits);
      create_lable_trim("lbl_lo_d1_20_" + (string)i, label_postion, lo_d1_20_i, str_line + " D(-" + (string)i + ")", line_color, digits);
     }
  }

//+------------------------------------------------------------------+
bool is_stoc_allow_find_trade_now(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);

   if(handle_iStochastic == INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(black_K <= 20 || red_D <= 20)
      return true;

   if(black_K >= 80 || red_D >= 80)
      return true;

   return false;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CalculatePivot(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_AMP_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = calc_avg_amp_week(symbol, TIME_FRAME, 50);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }


//+------------------------------------------------------------------+
void CalculateAvgCandleHeigh(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_CANDLE_HEIGH_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = CalculateAverageCandleHeight(TIME_FRAME, symbol);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }

//+------------------------------------------------------------------+
bool IsMarketClose()
  {
// Lấy giờ hiện tại theo múi giờ GMT
   datetime currentGMTTime = TimeGMT();

// Get the day of the week
   MqlDateTime dtw;
   TimeToStruct(currentGMTTime, dtw);
   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dtw.day_of_week;

// Check if the current day is Saturday or Sunday
   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
     {
      return true; // It's the weekend
     }

//+-----------------------------------

// Chênh lệch giờ giữa GMT và múi giờ Việt Nam
   int gmtOffset = 7;

// Chuyển đổi giờ hiện tại sang giờ Việt Nam
   datetime vietnamTime = currentGMTTime + gmtOffset * 3600;

// Chuyển giờ sang cấu trúc datetime
   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);

// Lấy giờ từ cấu trúc datetime
   int currentHour = dt.hour;

// Kiểm tra xem giờ hiện tại có nằm trong khoảng từ 3 giờ sáng đến 6 giờ sáng không
   if(3 < currentHour && currentHour < 7)
     {
      return true; //VietnamEarlyMorning
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
double CalculateATR14(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int period = 14;
   double atr = 0.0;

// Lấy độ biến động (true range) của các nến
   for(int i = 1; i <= period; i++)
     {
      double high = iHigh(symbol, timeframe, i);
      double low = iLow(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i - 1);

      // Tính toán true range của nến
      double trueRange = MathMax(high - low, MathMax(MathAbs(high - close), MathAbs(low - close)));

      // Cộng dồn true range
      atr += trueRange;
     }


   atr /= period;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return NormalizeDouble(atr, digits);
  }
//+------------------------------------------------------------------

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
double calcRiskPerTrade()
  {
   double risk_per_trade = format_double(calcRisk(), 2);
//risk_per_trade = 2.0; // USD

   return risk_per_trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   string cpu = "";
   string inputString = TerminalInfoString(TERMINAL_CPU_NAME);
   string startString = "Core ";
   string endString = " @";
   int startIndex = StringFind(inputString, startString) + 5;
   int endIndex = StringFind(inputString, endString);
   if(startIndex != -1 && endIndex != -1)
     {
      cpu = StringSubstr(inputString, startIndex, endIndex - startIndex);
     }

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + "   (GMT: " + (string) current_gmt_hour + "h) ";
   return vntime;
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
double adjust_target_price(double ma10, double dic_top_price, double week_amp)
  {
   double target_price = dic_top_price;

   if(ma10 < dic_top_price)
     {
      // Nếu ma10 nhỏ hơn dic_top_price, giảm target_price cho đến khi nào nó nhỏ hơn ma10
      while(target_price - week_amp >= ma10)
        {
         target_price -= week_amp;
        }
     }
   else
     {
      // Nếu ma10 lớn hơn dic_top_price, tăng target_price cho đến khi nào nó lớn hơn ma10
      while(target_price + week_amp <= ma10)
        {
         target_price += week_amp;
        }
     }

// Kết quả cuối cùng
   return target_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w_2, double &avg_candle_week)
  {
   double amp_w = 0;

   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      amp_w = 1060.00;
      amp_w_2 = 1357.35;
      avg_candle_week = 3697.32;
      return;
     }

   if(symbol == "USOIL.cash")
     {
      i_top_price = 120.000;
      amp_w = 2.50000;
      amp_w_2 = 2.75;
      avg_candle_week = 5.606;
      return;
     }

   if(symbol == "XAGUSD")
     {
      i_top_price = 25.7750;
      amp_w = 0.63500;
      amp_w_2 = 0.63500;
      avg_candle_week = 1.396;
      return;
     }

   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      amp_w = 22.9500;
      amp_w_2 = 27.83;
      avg_candle_week = 65.93;
      return;
     }

   if(symbol == "US500.cash")
     {
      i_top_price = 4785;
      amp_w = 60.00;
      amp_w_2 = 60.00;
      avg_candle_week = 593.00;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 16950;
      amp_w = 271.500;
      amp_w_2 = 274.5;
      avg_candle_week = 503.15;
      return;
     }

   if(symbol == "US30.cash")
     {
      i_top_price = 38100;
      amp_w = 388.350;
      amp_w_2 = 438.76;
      avg_candle_week = 818.86;
      return;
     }

   if(symbol == "UK100.cash")
     {
      i_top_price = 7755.65;
      amp_w = 95.38;
      amp_w_2 = 95.38;
      avg_candle_week = 946.88;
      return;
     }

   if(symbol == "GER40.cash")
     {
      i_top_price = 16585;
      amp_w = 222.45;
      amp_w_2 = 222.45;
      avg_candle_week = 2205.075;
      return;
     }

   if(symbol == "JP225.cash")
     {
      i_top_price = 33281;
      amp_w = 551.7836;
      amp_w_2 = 551.7836;
      avg_candle_week = 5471.75;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.5000;
      amp_w = 1.07795;
      amp_w_2 = 1.100;
      avg_candle_week = 2.097;
      return;
     }

   if(symbol == "AUDUSD")
     {
      i_top_price = 0.7210;
      amp_w = 0.0075;
      amp_w_2 = 0.0075;
      avg_candle_week = 0.01481;
      return;
     }
   if(symbol == "EURAUD")
     {
      i_top_price = 1.71850;
      amp_w = 0.01365;
      amp_w_2 = 0.01365;
      avg_candle_week = 0.02593;
      return;
     }

   if(symbol == "EURGBP")
     {
      i_top_price = 0.9010;
      amp_w = 0.00455;
      amp_w_2 = 0.00497;
      avg_candle_week = 0.00816;
      return;
     }

   if(symbol == "EURUSD")
     {
      i_top_price = 1.12465;
      amp_w = 0.00790;
      amp_w_2 = 0.0080;
      avg_candle_week = 0.01773;
      return;
     }

   if(symbol == "GBPUSD")
     {
      i_top_price = 1.315250;
      amp_w = 0.01085;
      amp_w_2 = 0.01085;
      avg_candle_week = 0.02180;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.38950;
      amp_w = 0.00795;
      amp_w_2 = 0.00795;
      avg_candle_week = 0.01907;
      return;
     }

   if(symbol == "USDCHF")
     {
      i_top_price = 0.93865;
      amp_w = 0.00715;
      amp_w_2 = 0.00750;
      avg_candle_week = 0.01586;
      return;
     }

   if(symbol == "USDJPY")
     {
      i_top_price = 154.525;
      amp_w = 1.29500;
      amp_w_2 = 1.4250;
      avg_candle_week = 3.240;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.702850;
      amp_w = 0.00500;
      amp_w_2 = 0.00515;
      avg_candle_week = 0.00894;
      return;
     }

   if(symbol == "CADJPY")
     {
      i_top_price = 111.635;
      amp_w = 1.00000;
      amp_w_2 = 1.0250;
      avg_candle_week = 2.298;
      return;
     }

   if(symbol == "CHFJPY")
     {
      i_top_price = 170.450;
      amp_w = 1.45000;
      amp_w_2 = 1.365000;
      avg_candle_week = 3.451;
      return;
     }

   if(symbol == "EURJPY")
     {
      i_top_price = 162.565;
      amp_w = 1.39000;
      amp_w_2 = 1.43500;
      avg_candle_week = 3.31;
      return;
     }

   if(symbol == "GBPJPY")
     {
      i_top_price = 188.405;
      amp_w = 1.61500;
      amp_w_2 = 1.61500;
      avg_candle_week = 3.973;
      return;
     }

   if(symbol == "NZDJPY")
     {
      i_top_price = 90.435;
      amp_w = 0.90000;
      amp_w_2 = 0.90000;
      avg_candle_week = 1.946;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.5225;
      amp_w = 0.00945;
      amp_w_2 = 0.00945;
      avg_candle_week = 0.01895;
      return;
     }

   if(symbol == "EURCHF")
     {
      i_top_price = 0.96800;
      amp_w = 0.00455;
      amp_w_2 = 0.00515;
      avg_candle_week = 0.01156;
      return;
     }

   if(symbol == "EURNZD")
     {
      i_top_price = 1.89155;
      amp_w = 0.01585;
      amp_w_2 = 0.01585;
      avg_candle_week = 0.02848;
      return;
     }

   if(symbol == "GBPAUD")
     {
      i_top_price = 1.9905;
      amp_w = 0.01575;
      amp_w_2 = 0.01575;
      avg_candle_week = 0.02700;
      return;
     }

   if(symbol == "GBPCAD")
     {
      i_top_price = 1.6885;
      amp_w = 0.01210;
      amp_w_2 = 0.01210;
      avg_candle_week = 0.02005;
      return;
     }

   if(symbol == "GBPCHF")
     {
      i_top_price = 1.11485;
      amp_w = 0.00685;
      amp_w_2 = 0.0085;
      avg_candle_week = 0.01625;
      return;
     }

   if(symbol == "GBPNZD")
     {
      i_top_price = 2.09325;
      amp_w = 0.01700;
      amp_w_2 = 0.016250;
      avg_candle_week = 0.02895;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.90385;
      amp_w = 0.00735;
      amp_w_2 = 0.0075;
      avg_candle_week = 0.01345;
      return;
     }

   if(symbol == "AUDCHF")
     {
      i_top_price = 0.654500;
      amp_w = 0.00545;
      amp_w_2 = 0.005805;
      avg_candle_week = 0.01076;
      return;
     }

   if(symbol == "AUDNZD")
     {
      i_top_price = 1.09385;
      amp_w = 0.00595;
      amp_w_2 = 0.00595;
      avg_candle_week = 0.01017;
      return;
     }

   if(symbol == "NZDCAD")
     {
      i_top_price = 0.84135;
      amp_w = 0.007200;
      amp_w_2 = 0.007200;
      avg_candle_week = 0.01275;
      return;
     }

   if(symbol == "NZDCHF")
     {
      i_top_price = 0.548615;
      amp_w = 0.00515;
      amp_w_2 = 0.00515;
      avg_candle_week = 0.00988;
      return;
     }

   if(symbol == "NZDUSD")
     {
      i_top_price = 0.6275;
      amp_w = 0.00670;
      amp_w_2 = 0.00660;
      avg_candle_week = 0.01388;
      return;
     }


   i_top_price = iClose(symbol, PERIOD_W1, 1);
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   amp_w_2 = amp_w;
   avg_candle_week = CalculateAverageCandleHeight(PERIOD_W1, symbol);

//Alert(" Add Symbol Data:",  symbol, " amp:", amp_w);
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 50; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      totalHeight += candleHeight;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / 10.0;

   return averageHeight;
  }

//+------------------------------------------------------------------+
double FindMinPrice(const double& prices[])
  {
   double minPrice = prices[0];

   for(int i = 1; i < ArraySize(prices); ++i)
     {
      if(prices[i] < minPrice)
        {
         minPrice = prices[i];
        }
     }

   return minPrice;
  }

// Function to find the maximum value in an array
double FindMaxPrice(const double& prices[])
  {
   double maxPrice = prices[0];

   for(int i = 1; i < ArraySize(prices); ++i)
     {
      if(prices[i] > maxPrice)
        {
         maxPrice = prices[i];
        }
     }

   return maxPrice;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double CalculateMA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= ma_index; i++)
     {
      count += 1;
      ma += closePrices[i];
     }
   ma /= count;

   return ma;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = CalculateMA(closePrices, ma_index);
   return ma_value;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk()
  {
   double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

   double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;

   if(dbValueRisk > 200)
     {
      //Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than 200 per order. Too dangerous.");
      return 200;
     }
   return dbValueRisk;
  }
//+------------------------------------------------------------------+
// Calculate Max Lot Size based on Maximum Risk
//+------------------------------------------------------------------+
double dblLotsRisk(string symbol, double dbAmp, double dbRiskByUsd)
  {
   double dbLotsMinimum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double dbLotsMaximum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double dbLotsStep     = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double dbTickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize < 0.01)
      roundedLotSize = 0.01;

   return roundedLotSize;
  }
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol,  TIMEFRAME, week_index);
   double week_low = iLow(symbol,   TIMEFRAME, week_index);
   double week_clo = iClose(symbol, TIMEFRAME, week_index);

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
double calc_avg_amp_week(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_week_amp(symbol, TIMEFRAME, index);
     }
   double week_amp = total_amp / size;

   return week_amp;
  }




// Định nghĩa lớp CandleData
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend;
   int               count;
   // Default constructor
                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend = "";
      count = 0;
     }
                     CandleData(datetime t, double o, double h, double l, double c, string c_trend, int count_c1)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend = c_trend;
      count = count_c1;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountHeikenList(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_no, CandleData &candle_heiken)
  {
   CandleData candleArray[55];

   datetime pre_HaTime = iTime(symbol, TIME_FRAME, 54);
   double pre_HaOpen = iOpen(symbol, TIME_FRAME, 54);
   double pre_HaHigh = iHigh(symbol, TIME_FRAME, 54);
   double pre_HaLow = iLow(symbol, TIME_FRAME, 54);
   double pre_HaClose = iClose(symbol, TIME_FRAME, 54);
   string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0);
   candleArray[54] = candle;

   for(int index = 53; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh = MathMax(iOpen(symbol, TIME_FRAME, index), MathMax(haClose, pre_cancle.high));
      double haLow = MathMin(iOpen(symbol, TIME_FRAME, index), MathMin(haClose, pre_cancle.low));

      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_trend = 1;
      for(int j = index+1; j < 50; j++)
        {
         if(haTrend == pre_candle_trend && haTrend == candleArray[j].trend)
           {
            count_trend += 1;
           }
         else
           {
            break;
           }
        }

      CandleData candle(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle;
     }

   candle_heiken = candleArray[candle_no];
  }




// Hàm tính toán giá trị của nến Heiken Ashi
void CalculateHeikenAshi(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int index, double &haOpen, double &haClose, double &haHigh, double &haLow)
  {
// Lấy giá trị của nến trước đó
   double prevHaOpen = iOpen(symbol, TIME_FRAME, index + 1);
   double prevHaClose = iClose(symbol, TIME_FRAME, index + 1);
   double prevHaHigh = iHigh(symbol, TIME_FRAME, index + 1);
   double prevHaLow = iLow(symbol, TIME_FRAME, index + 1);

// Tính toán giá trị của nến Heiken Ashi
   haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
   haOpen = (prevHaOpen + prevHaClose) / 2.0;
   haHigh = MathMax(iOpen(symbol, TIME_FRAME, index), MathMax(haClose, prevHaHigh));
   haLow = MathMin(iOpen(symbol, TIME_FRAME, index), MathMin(haClose, prevHaLow));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(double& prices[], int period, int candle_no)
  {
   int maLength = ArraySize(prices);
   double smoothingFactor = 2.0 / (period + 1);

   double ema[];
   ArrayResize(ema, maLength);

   ema[maLength - 1] = prices[maLength - 1];

   for(int i = maLength - 2; i >= 0; i--)
     {
      double currentPrice = prices[i];
      double previousEMA = ema[i + 1];
      ema[i] = format_double((currentPrice * smoothingFactor) + (previousEMA * (1-smoothingFactor)), 5);
     }

   return ema[candle_no];
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSMA(double& prices[], double& sma[], int period)
  {
   int maLength = ArraySize(prices);
   ArrayResize(sma, maLength);
   for(int i = 0; i<maLength ; i++)
     {
      sma[i] = 0;
     }

   for(int i = 0; i < maLength - period; i++)
     {
      double sum = 0;
      for(int j = i; j < i + period; j++)
        {
         sum += prices[j];
        }
      sma[i] = sum / period;
     }
  }
//+------------------------------------------------------------------+
bool allow_trade_by_amp_50candle(string symbol, string find_trend)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int count_candle = 0;
   int length_55 = 55;
   double close_prices_d1[];
   ArrayResize(close_prices_d1, length_55);
   for(int i = length_55 - 1; i >= 0; i--)
     {
      double temp_close = iClose(symbol, PERIOD_D1, i);
      if(temp_close > 0)
         count_candle += 1;

      close_prices_d1[i] = temp_close;
     }
   if(count_candle < 50)
      return false;

   double close_d1_c1 = close_prices_d1[1];

   double min_close_d1 = FindMinPrice(close_prices_d1);
   double max_close_d1 = FindMaxPrice(close_prices_d1);
   double amp_1_3 = MathAbs(max_close_d1 - min_close_d1) / 3;

   double sel_area = max_close_d1 - amp_1_3;
   double buy_area = min_close_d1 + amp_1_3;

   if(find_trend == TREND_BUY && price <= buy_area)
      return true;

   if(find_trend == TREND_SEL && price >= sel_area)
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_heiken(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   CandleData candle_heiken;
   CountHeikenList(symbol, timeframe, 1, candle_heiken);

   return candle_heiken.trend + "("+(string) candle_heiken.count+")" ;
  }

//+------------------------------------------------------------------+
string get_candle_switch_trend_adx(string symbol, ENUM_TIMEFRAMES timeframe, int ma_period)
  {
   double    ExtADXBuffer[];  // ADx
   double    ExtPDIBuffer[];  // DI+
   double    ExtNDIBuffer[];  // DI-

   ArraySetAsSeries(ExtADXBuffer, true);
   ArraySetAsSeries(ExtPDIBuffer, true);
   ArraySetAsSeries(ExtNDIBuffer, true);

   int adx_handle = iADX(symbol, timeframe, ma_period);

   if(adx_handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iADXWilder indicator for the symbol %s/%s, error code %d",
                  symbol,
                  EnumToString(timeframe),
                  GetLastError());
      //--- the indicator is stopped early
      return(string) INIT_FAILED;
     }

   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   string trend = "";
   string str_adx = "";
   if(CopyBuffer(adx_handle,0,0,50,ExtADXBuffer)>=0
      && CopyBuffer(adx_handle,1,0,50,ExtPDIBuffer)>=0
      && CopyBuffer(adx_handle,2,0,50,ExtNDIBuffer)>=0)
     {
      str_adx = "   Adx: " + format_double_to_string(ExtADXBuffer[0], 2) + "   Dm+: " + format_double_to_string(ExtPDIBuffer[0], 2) + "   Dm-: " + format_double_to_string(ExtNDIBuffer[0], 2);

      if(ExtPDIBuffer[1] > ExtNDIBuffer[1])
        {
         trend = TREND_BUY;
         for(int i = 1; i < ArraySize(ExtADXBuffer) - 1; i++)
           {
            if(ExtPDIBuffer[i] < ExtNDIBuffer[i])
              {
               // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
               x = i;
               break;
              }
           }

        }
      else
        {
         trend = TREND_SEL;
         for(int i = 1; i < ArraySize(ExtADXBuffer) - 1; i++)
           {
            if(ExtPDIBuffer[i] > ExtNDIBuffer[i])
              {
               // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
               x = i;
               break;
              }
           }

        }

     }


   if(x != -1)
      return trend + "("+(string) x+")" ;// + str_adx;
   else
      return trend + "(5x)" ;//  + str_adx;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return 50;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,50,K);
   CopyBuffer(handle_iStochastic,1,0,50,D);

   double black_K = K[0];
   double red_D = D[0];

// Tìm vị trí x thỏa mãn điều kiện
   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   for(int i = 0; i < ArraySize(K) - 1; i++)
     {
      if((K[i] < D[i] && K[i + 1] > D[i + 1])
         || (K[i] > D[i] && K[i + 1] < D[i + 1]))
        {
         // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
         x = i;
         break;
        }
     }

   if(x != -1)
     {
      return x;
     }
   else
     {
      return 50;
     }
  }

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(symbol, TIME_FRAME, candle_index, haOpen0, haClose0, haHigh0, haLow0);

   string result = "";
   if(haOpen0 < haClose0)
     {
      result = TREND_BUY;
     }
   else
     {
      result = TREND_SEL;
     }

   return result;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd369(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_signal);

   double m_macd_current    = m_buff_MACD_main[0];
   double m_signal_current  = m_buff_MACD_signal[0];

//double m_macd_previous   = m_buff_MACD_main[1];
//double m_signal_previous = m_buff_MACD_signal[1];
//int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   return (m_signal_current > 0 ? TREND_BUY : TREND_SEL);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc323(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string stoch = "";

   int periodK = 3; // %K
   int periodD = 2; // %D
   int slowing = 3; // Slowing

   string indicatorPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Indicators\\Examples\\Stochastic.mq5";

   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
     {
      stoch += " Error in iStochastic. Error code: " + (string)GetLastError();
      return stoch;
     }

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);

   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);
   double blackK = K[0];
   double redD = D[0];
//stoch += "   K (Black) : " + (string) format_double_to_string(blackK, 2);
//stoch += "   D (Red) : " + (string) format_double_to_string(redD, 2);

   string trend_stoch = "";
   if(redD < blackK)
     {
      return TREND_BUY ;
     }

   if(redD > blackK)
     {
      return TREND_SEL;
     }

   return "";
  }
//+------------------------------------------------------------------+
