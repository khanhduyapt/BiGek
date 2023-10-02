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
                          "US30.cash", "US100.cash",
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
      FileWrite(nfile_w_pivot, "TimeCurrent", "symbol", "pre_week_closed", "amp", "w_open", "w_close", "w_s1", "w_s2", "d_today_low", "w_r1", "w_r2", "d_today_hig", "amp_min_d1", "trend_w1", "d_close", "amp_avg_h4");


      int total_fx_stock_size = ArraySize(arr_symbol);

      for(int index = 0; index < total_fx_stock_size; index++)
        {
         string symbol = arr_symbol[index];

         int      digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places
         //-------------------------------------------------------------------------------------------------------------------------------
         datetime w_time  = iTime(symbol, PERIOD_W1, 1);
         double   w_open  = iOpen(symbol, PERIOD_W1, 1);
         double   w_high  = iHigh(symbol, PERIOD_W1, 1);
         double   w_low   = iLow(symbol, PERIOD_W1, 1);
         double   w_close = iClose(symbol, PERIOD_W1, 1);

         double mid = w_close - w_open;
         color candle_color = clrBlue;
         if(w_open > w_close)
           {
            candle_color = clrRed;
            mid = w_open - w_close;
           }

         mid = (mid / 2);

         if(w_open > w_close)
           {
            mid = w_close + mid;
           }
         else
           {
            mid = w_open + mid;
           }


         double pivot   = (w_high + w_low + w_close) / 3;
         double w_s1    = (2 * pivot) - w_high;
         double w_s2    = pivot - (w_high - w_low);
         double w_s3    = w_low - 2 * (w_high - pivot);
         double w_r1    = (2 * pivot) - w_low;
         double w_r2    = pivot + (w_high - w_low);
         double w_r3    = w_high + 2 * (pivot - w_low);

         double amp = MathAbs(w_s3 - w_s2) + MathAbs(w_s2 - w_s1) + MathAbs(w_s1 - pivot) + MathAbs(pivot - w_r1) + MathAbs(w_r1 - w_r2) + MathAbs(w_r2 - w_r3);
         amp = amp / 6;

         double pre_week_close = iClose(symbol, PERIOD_W1, 1);


         w_s1 = pre_week_close - amp;
         w_s2 = w_s1 - amp;
         w_s3 = w_s2 - amp;

         w_r1 = pre_week_close + amp;
         w_r2 = w_r1 + amp;
         w_r3 = w_r2 + amp;



         mid         = format_double(mid, digits);
         amp         = format_double(amp, digits);
         pivot       = format_double(pivot, digits);
         w_s1        = format_double(w_s1, digits);
         w_s2        = format_double(w_s2, digits);
         w_s3        = format_double(w_s3, digits);
         w_r1        = format_double(w_r1, digits);
         w_r2        = format_double(w_r2, digits);
         w_r3        = format_double(w_r3, digits);

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
         double total_amp_daily = 0.0;
         double amp_min_d1 = (w_high - w_low);
         for(int index = 1; index <= total_candle; index ++)
           {
            double   tmp_hig         = iHigh(symbol, PERIOD_H4, index);
            double   tmp_low         = iLow(symbol, PERIOD_H4, index);
            total_amp_daily += (tmp_hig - tmp_low);


            double d_tmp_low  = iLow(symbol, PERIOD_D1, index);
            double d_tmp_hig  = iHigh(symbol, PERIOD_D1, index);
            if(amp_min_d1 > (d_tmp_hig - d_tmp_low))
              {
               amp_min_d1 = (d_tmp_hig - d_tmp_low);
              }
           }
         double amp_avg_h4 = format_double(total_amp_daily / total_candle, digits);

         FileWrite(nfile_w_pivot, TimeToString(TimeCurrent(), TIME_DATE), symbol
                   , format_double_to_string(pre_week_close, digits)
                   , format_double_to_string(amp, digits)
                   , format_double_to_string(w_open, digits)
                   , format_double_to_string(w_close, digits)
                   , format_double_to_string(w_s1, digits)
                   , format_double_to_string(w_s2, digits)
                   , format_double_to_string(d_today_low, digits)
                   , format_double_to_string(w_r1, digits)
                   , format_double_to_string(w_r2, digits)
                   , format_double_to_string(d_today_hig, digits)
                   , format_double_to_string(amp_min_d1, digits)
                   , trend_w1
                   , format_double_to_string(d_close, digits)
                   , format_double_to_string(amp_avg_h4, digits));

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
         copied=CopyRates(symbol, PERIOD_D1, 0, 89, rates_d1);
         if(copied>0)
           {
            int size=fmin(copied, 89);
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
         copied=CopyRates(symbol, PERIOD_H4, 0, 89, rates_h4);
         if(copied>0)
           {
            int size=fmin(copied, 89);
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
         copied=CopyRates(symbol, PERIOD_H1, 0, 89, rates_h1);
         if(copied>0)
           {
            int size=fmin(copied, 89);
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
