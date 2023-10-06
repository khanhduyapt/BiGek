//+------------------------------------------------------------------+
//|                                       UniverseNavigatorIndex.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Draw_Bollinger_Bands();
   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
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
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Draw_Bollinger_Bands();

   string symbol = Symbol();
   ENUM_TIMEFRAMES timeframe = PERIOD_M5;
   int period = 14; // Chu kỳ RSI
   int shift = 0; // Vị trí trên biểu đồ

   string rsi = CheckRSIDivergence(symbol, PERIOD_M5, period, shift);
   if(rsi != "NONE")
     {
      Alert("Phân kỳ RSI đã được phát hiện trên khung M5.", rsi);
     }
  }

// Vẽ Bollinger Bands lên biểu đồ
void Draw_Bollinger_Bands()
  {
   string symbol = Symbol();
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places


   double upper_15[], middle_15[], lower_15[];
   CalculateBollingerBands(symbol, PERIOD_M15, upper_15, middle_15, lower_15, digits);
//Alert("PERIOD_15 iTime=", iTime(symbol, PERIOD_M15, 0), "   lower_15_0=", format_double_to_string(lower_15[0], digits), "   middle_15_0=", format_double_to_string(middle_15[0], digits), "   upper_15_0=", format_double_to_string(upper_15[0], digits));


   double upper_h1[], middle_h1[], lower_h1[];
   CalculateBollingerBands(symbol, PERIOD_H1, upper_h1, middle_h1, lower_h1, digits);
//Alert("PERIOD_H1 iTime=", iTime(symbol, PERIOD_H1, 0), "   lower_h1_0=", format_double_to_string(lower_h1[0], digits), "   middle_h1_0=", format_double_to_string(middle_h1[0], digits), "   upper_h1_0=", format_double_to_string(upper_h1[0], digits));

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits);
//Alert("PERIOD_h4 iTime=", iTime(symbol, PERIOD_H4, 0), "   lower_h4_0=", format_double_to_string(lower_h4[0], digits), "   middle_h4_0=", format_double_to_string(middle_h4[0], digits), "   upper_h4_0=", format_double_to_string(upper_h4[0], digits));

   double upper_d1[], middle_d1[], lower_d1[];
   CalculateBollingerBands(symbol, PERIOD_D1, upper_d1, middle_d1, lower_d1, digits);
//Alert("PERIOD_D1 iTime=", iTime(symbol, PERIOD_D1, 0), "   lower_d1_0=", format_double_to_string(lower_d1[0], digits), "   middle_d1_0=", format_double_to_string(middle_d1[0], digits), "   upper_d1_0=", format_double_to_string(upper_d1[0], digits));

   /*
   // Vẽ Đường Trên (Upper Bollinger Band)
      ObjectCreate("UpperBB", OBJ_TREND, 0, 0, iTime(symbol, timeframe, shift), upper[shift], iTime(symbol, timeframe, count - 1), upper[count - 1]);
      ObjectSetInteger(0, "UpperBB", OBJPROP_COLOR, clrRed); // Màu Đường Trên
      ObjectSetInteger(0, "UpperBB", OBJPROP_RAY_RIGHT, true); // Vẽ ra phải

   // Vẽ Đường Dưới (Lower Bollinger Band)
      ObjectCreate("LowerBB", OBJ_TREND, 0, 0, iTime(symbol, timeframe, shift), lower[shift], iTime(symbol, timeframe, count - 1), lower[count - 1]);
      ObjectSetInteger(0, "LowerBB", OBJPROP_COLOR, clrGreen); // Màu Đường Dưới
      ObjectSetInteger(0, "LowerBB", OBJPROP_RAY_RIGHT, true); // Vẽ ra phải
   */

  }

//+------------------------------------------------------------------+
// Hàm tính toán Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
   double deviation = 2.0; // Độ lệch chuẩn cho Bollinger Bands
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

// Hàm tính RSI
double CalculateRSI(string symbol, ENUM_TIMEFRAMES timeframe, int period, int shift)
  {
   double rsiBuffer[];
   int copied = CopyBuffer(NULL, 0, 0, period + shift + 1, rsiBuffer);
   if(copied <= 0)
      return 0.0;

// Lấy giá trị RSI tại vị trí shift
   return rsiBuffer[shift];
  }
//+------------------------------------------------------------------+
// Hàm kiểm tra phân kỳ RSI và trả về tín hiệu "BUY" hoặc "SELL"
string CheckRSIDivergence(string symbol, ENUM_TIMEFRAMES timeframe, int period, int shift)
  {
   double currentRSI = CalculateRSI(symbol, timeframe, period, shift);
   double previousRSI = CalculateRSI(symbol, timeframe, period, shift + 1);

// Kiểm tra phân kỳ RSI: Nếu RSI tăng và giá giảm
   if(currentRSI > previousRSI && iClose(symbol, timeframe, shift) < iClose(symbol, timeframe, shift + 1))
     {
      return "SELL"; // Tín hiệu SELL khi có phân kỳ RSI
     }

// Kiểm tra phân kỳ RSI: Nếu RSI giảm và giá tăng
   if(currentRSI < previousRSI && iClose(symbol, timeframe, shift) > iClose(symbol, timeframe, shift + 1))
     {
      return "BUY"; // Tín hiệu BUY khi có phân kỳ RSI
     }

   return "NONE"; // Không có phân kỳ RSI
  }
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
