//+------------------------------------------------------------------+
//|                                                  TimeBreaker.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window


//MetaTreder5: MFF: Destop: C:\Users\Admin\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files
//MetaTreder5: MFF: Laptop: C:\Users\DellE5270\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files
//C:\Users\DellE5270\AppData\Roaming\MetaQuotes\Terminal\49CDDEAA95A409ED22BD2287BB67CB9C\MQL5\Files\Data
int count = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   OnTimer();

   EventSetTimer(900); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   string scap_5m = "_XAUUSD_US30_";
   string indexs_cfd = "_US30_SP500_GER30_GER40_UK100_FRA40_SPN35_EU50_US100_AUS200_";
   MqlDateTime dt_struct;
   datetime dtSer=TimeToStruct(TimeLocal(), dt_struct);
   int cur_minu = (int)dt_struct.min;
   double mod5 = MathMod(cur_minu, 2);

//"EU50.cash", "GER40.cash", "UK100.cash", "AUS200.cash", "FRA40.cash", "SPN35.cash", "NATGAS.f", "ERBN.f",
//"ETHUSD", "DOGEUSD", "DASHUSD", "ADAUSD", "DOTUSD", "LTCUSD", "XRPUSD",
   string arr_symbol[] = {"DX.f", "XAUUSD", "XAGUSD", "USOIL.cash",
                          "US30.cash", "US100.cash", "US500.cash",
                          "BTCUSD",
                          "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
                          "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                          "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
                          "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                          "USDCAD", "USDCHF", "USDJPY", "CADJPY", "CHFJPY", "CADCHF"
                         };

//"AAPL", "AIRF", "AMZN", "BAC", "BAYGn", "DBKGn", "GOOG", "LVMH", "META", "MSFT", "NFLX", "NVDA", "PFE", "RACE", "TSLA", "VOWG_p", "WMT", "BABA", "T", "V", "ZM"
//string arr_stocks[] = {};
//string sAllSymbols[];
//ArrayCopy(sAllSymbols, arr_stocks, ArraySize(arr_stocks));
//ArrayCopy(sAllSymbols, arr_symbol, ArraySize(arr_symbol));

//-------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------
   FileDelete("Data//DailyPivot.csv");
   int nfile_w_pivot = FileOpen("Data//DailyPivot.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_w_pivot != INVALID_HANDLE)
     {
      FileWrite(nfile_w_pivot
                , "TimeCurrent"
                , "symbol"
                , "trend_w1"
                , "w_close"
                , "avg_amp_week"
                , "upper_03"
                , "lower_03"
                , "upper_15"
                , "lower_15"
                , "upper_h1"
                , "lower_h1"
                , "upper_h4"
                , "lower_h4"
                , "upper_d1"
                , "lower_d1"
                , "d_close"
                , "d_today_low"
                , "d_today_hig"
                , "amp_min_d1"
                , "amp_avg_h4");


      int total_fx_stock_size = ArraySize(arr_symbol);

      for(int index = 0; index < total_fx_stock_size; index++)
        {
         string symbol = arr_symbol[index];

         int      digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places
         //-------------------------------------------------------------------------------------------------------------------------------
         double   w_open  = iOpen(symbol, PERIOD_W1, 1);
         double   w_close = iClose(symbol, PERIOD_W1, 1);
         double avg_amp_week = calc_avg_amp_week(symbol, 20);

         double pre_week_close = iClose(symbol, PERIOD_W1, 1);
         avg_amp_week= format_double(avg_amp_week, digits);

         double pre_week_open = iOpen(symbol, PERIOD_W1, 1);
         double pre_week_mid = format_double((pre_week_open + pre_week_close) / 2.0, digits);

         double this_week_open = iOpen(symbol, PERIOD_W1, 0);
         double this_week_close = iClose(symbol, PERIOD_W1, 0);
         double this_week_mid = format_double((this_week_open + this_week_close) / 2.0, digits);

         string trend_w1 = "BUY";
         if(pre_week_mid > this_week_mid)
           {
            trend_w1 = "SELL";
           }

         double d_close = iClose(symbol, PERIOD_D1, 1);
         double d_today_low  = iLow(symbol, PERIOD_D1, 0);
         double d_today_hig  = iHigh(symbol, PERIOD_D1, 0);

         int total_candle = 50;
         double total_amp_h4 = 0.0;
         double amp_min_d1 = avg_amp_week;
         for(int index = 1; index <= total_candle; index ++)
           {
            double   tmp_hig         = iHigh(symbol, PERIOD_H4, index);
            double   tmp_low         = iLow(symbol, PERIOD_H4, index);
            total_amp_h4 += (tmp_hig - tmp_low);


            double d_tmp_low  = iLow(symbol, PERIOD_D1, index);
            double d_tmp_hig  = iHigh(symbol, PERIOD_D1, index);
            if(amp_min_d1 > (d_tmp_hig - d_tmp_low))
              {
               amp_min_d1 = (d_tmp_hig - d_tmp_low);
              }
           }
         double amp_avg_h4 = format_double(total_amp_h4 / total_candle, digits);
/*
         double upper_03[], middle_03[], lower_03[];
         CalculateBollingerBands(symbol, PERIOD_M3, upper_03, middle_03, lower_03, digits);

         double upper_15[], middle_15[], lower_15[];
         CalculateBollingerBands(symbol, PERIOD_M15, upper_15, middle_15, lower_15, digits);

         double upper_h1[], middle_h1[], lower_h1[];
         CalculateBollingerBands(symbol, PERIOD_H1, upper_h1, middle_h1, lower_h1, digits);
*/
         double upper_h4[], middle_h4[], lower_h4[];
         CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits);

         double upper_d1[], middle_d1[], lower_d1[];
         CalculateBollingerBands(symbol, PERIOD_D1, upper_d1, middle_d1, lower_d1, digits);

         FileWrite(nfile_w_pivot
                   , TimeToString(TimeCurrent(), TIME_DATE)
                   , symbol
                   , trend_w1
                   , format_double_to_string(w_close, digits)
                   , format_double_to_string(avg_amp_week, digits)

                   , format_double_to_string(0.0, digits)
                   , format_double_to_string(0.0, digits)

                   , format_double_to_string(0.0, digits)
                   , format_double_to_string(0.0, digits)

                   , format_double_to_string(0.0, digits)
                   , format_double_to_string(0.0, digits)

                   , format_double_to_string(upper_h4[0], digits)
                   , format_double_to_string(lower_h4[0], digits)

                   , format_double_to_string(upper_d1[0], digits)
                   , format_double_to_string(lower_d1[0], digits)

                   , format_double_to_string(d_close, digits)
                   , format_double_to_string(d_today_low, digits)
                   , format_double_to_string(d_today_hig, digits)
                   , format_double_to_string(amp_min_d1, digits)
                   , format_double_to_string(amp_avg_h4, digits)
                  );

        } //for
      //--------------------------------------------------------------------------------------------------------------------

      FileClose(nfile_w_pivot);
     }
   else
     {
      Print("(DailyPivot) Failed to get history data.");
     }

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
   int s_size = ArraySize(arr_symbol);
   FileDelete("Data//TimeBreaker.csv");
   int nfile_handle = FileOpen("Data//TimeBreaker.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "");

      int copied;

      for(int index=0; index < s_size; index++)
        {
         //---------------------------------------------
         //string symbol = StringReplace(arr_symbol[index], ".cash", "");
         string symbol = arr_symbol[index];

         //Get price data
         double current_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
         double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
         double current_price = (current_bid + current_ask) / 2;
         //-------------------------------------------------------------------------------------------------------------------------------
         //-------------------------------------------------------------------------------------------------------------------------------
         MqlRates rates_w1[];
         ArraySetAsSeries(rates_w1,true);
         copied=CopyRates(symbol, PERIOD_W1, 0, 15, rates_w1);
         if(copied>0)
           {
            int size=fmin(copied, 15);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "WEEK", rates_w1[i].time, rates_w1[i].open, rates_w1[i].high, rates_w1[i].low, rates_w1[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_W1");
           }
         //-------------------------------------------------------------------------------------------------------------------------------

         MqlRates rates_d1[];
         ArraySetAsSeries(rates_d1,true);
         copied=CopyRates(symbol, PERIOD_D1, 0, 77, rates_d1);
         if(copied>0)
           {
            int size=fmin(copied, 77);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "DAY", rates_d1[i].time, rates_d1[i].open, rates_d1[i].high, rates_d1[i].low, rates_d1[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_D1");
           }
         //-------------------------------------------------------------------------------------------------------------------------------
         MqlRates rates_h4[];
         ArraySetAsSeries(rates_h4,true);
         copied=CopyRates(symbol, PERIOD_H4, 0, 77, rates_h4);
         if(copied>0)
           {
            int size=fmin(copied, 77);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "HOUR_04", rates_h4[i].time, rates_h4[i].open, rates_h4[i].high, rates_h4[i].low, rates_h4[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_H4");
           }
         //-------------------------------------------------------------------------------------------------------------------------------
         MqlRates rates_h1[];
         ArraySetAsSeries(rates_h1,true);
         copied=CopyRates(symbol, PERIOD_H1, 0, 77, rates_h1);
         if(copied>0)
           {
            int size=fmin(copied, 77);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "HOUR_01", rates_h1[i].time, rates_h1[i].open, rates_h1[i].high, rates_h1[i].low, rates_h1[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_H1");
           }
         //-------------------------------------------------------------------------------------------------------------------------------

        } //for
      //--------------------------------------------------------------------------------------------------------------------
      //--------------------------------------------------------------------------------------------------------------------
      FileClose(nfile_handle);
     }
   else
     {
      Print("(TimeBreaker) Failed to get history data.");
     }


  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
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
//--- return value of prev_calculated for next call
   return(0);
  }

//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   string formattedNumber = DoubleToString(number, 5);
   StringReplace(formattedNumber, "00000000001", "");
   StringReplace(formattedNumber, "99999999999", "");

   return NormalizeDouble(StringToDouble(formattedNumber), digits);
  }

//+------------------------------------------------------------------+
string AppendSpaces(string inputString, int totalLength = 10)
  {

   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
     {
      return (inputString);
     }
   else
     {
      int spacesToAdd = totalLength - currentLength;
      string spaces = "";
      for(int index = 1; index <= spacesToAdd; index++)
        {
         spaces+= " ";
        }

      return (spaces + inputString);
     }
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


//+------------------------------------------------------------------+
// Hàm tính toán Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
   double deviation = 1.8; // Độ lệch chuẩn cho Bollinger Bands
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
      upper[i]  = format_double(upper_i, digits);
      lower[i]  = format_double(lower_i, digits);
     }
  }
//+------------------------------------------------------------------+
