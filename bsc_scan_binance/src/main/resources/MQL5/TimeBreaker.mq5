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

   string arr_stocks[] = {"AAPL", "AIRF", "AMZN", "BAC", "BAYGn", "DBKGn",
                          "GOOG", "LVMH", "META", "MSFT", "NFLX", "NVDA", "PFE", "RACE", "TSLA", "VOWG_p", "WMT", "BABA", "T", "V", "ZM"
                         };

   string sAllSymbols[];
   ArrayCopy(sAllSymbols, arr_stocks, ArraySize(arr_stocks));
   ArrayCopy(sAllSymbols, arr_symbol, ArraySize(arr_symbol));

//-------------------------------------------------------------------------------------------------------------------------------

   FileDelete("Data//DailyPivot.csv");
   int nfile_daily_pivot = FileOpen("Data//DailyPivot.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_daily_pivot != INVALID_HANDLE)
     {
      FileWrite(nfile_daily_pivot, "TimeCurrent", "symbol", "mid", "amp", "daily_open", "daily_close", "support1", "support2", "support3", "resistance1", "resistance2", "resistance3", "pivot", "trend_w1", "pre_week_mid", "this_week_mid");


      int total_fx_stock_size = ArraySize(sAllSymbols);

      for(int index = 0; index < total_fx_stock_size; index++)
        {
         string symbol = sAllSymbols[index];

         int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);     // number of decimal places
         //-------------------------------------------------------------------------------------------------------------------------------
         datetime daily_time = iTime(symbol, PERIOD_D1, 1);
         double daily_open   = iOpen(symbol, PERIOD_D1, 1);
         double daily_high   = iHigh(symbol, PERIOD_D1, 1);
         double daily_low    = iLow(symbol, PERIOD_D1, 1);
         double daily_close  = iClose(symbol, PERIOD_D1, 1);

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


         double pivot       = (daily_high + daily_low + daily_close) / 3;
         double support1    = (2 * pivot) - daily_high;
         double support2    = pivot - (daily_high - daily_low);
         double support3    = daily_low - 2 * (daily_high - pivot);
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



         mid                = format_double(mid, digits);
         amp                = format_double(amp, digits);
         pivot              = format_double(pivot, digits);
         support1           = format_double(support1, digits);
         support2           = format_double(support2, digits);
         support3           = format_double(support3, digits);
         resistance1        = format_double(resistance1, digits);
         resistance2        = format_double(resistance2, digits);
         resistance3        = format_double(resistance3, digits);

         double pre_week_open = iOpen(symbol, PERIOD_W1, 1);
         double pre_week_close = iClose(symbol, PERIOD_W1, 1);
         double pre_week_mid = format_double((pre_week_open + pre_week_close) / 2.0, digits);

         double this_week_open = iOpen(symbol, PERIOD_W1, 0);
         double this_week_close = iClose(symbol, PERIOD_W1, 0);
         double this_week_mid = format_double((this_week_open + this_week_close) / 2.0, digits);

         string trend_w1 = "BUY";
         if(pre_week_mid > this_week_mid)
           {
            trend_w1 = "SELL";
           }
         FileWrite(nfile_daily_pivot, TimeToString(TimeCurrent(), TIME_DATE), symbol, mid, amp, daily_open, daily_close, support1, support2, support3, resistance1, resistance2, resistance3, pivot, trend_w1, pre_week_mid, this_week_mid);
        } //for
      //--------------------------------------------------------------------------------------------------------------------

      FileClose(nfile_daily_pivot);
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
      Comment("-----------------------------TimeBreaker (Symbol):"+ Symbol());

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
         /*
         MqlRates rates_30[];
         ArraySetAsSeries(rates_30,true);
         copied=CopyRates(symbol, PERIOD_M30, 0, 55, rates_30);
         if(copied>0)
           {
            int size=fmin(copied, 55);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "MINUTE_30", rates_30[i].time, rates_30[i].open, rates_30[i].high, rates_30[i].low, rates_30[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_M30");
           }
           */
         //-------------------------------------------------------------------------------------------------------------------------------
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

//+------------------------------------------------------------------+
