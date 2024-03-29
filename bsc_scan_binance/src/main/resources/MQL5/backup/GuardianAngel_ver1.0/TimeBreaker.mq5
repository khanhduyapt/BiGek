//+------------------------------------------------------------------+
//|                                                  TimeBreaker.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#include "utils.mq5"

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
//"EU50.cash", "GER40.cash", "UK100.cash", "AUS200.cash", "FRA40.cash", "SPN35.cash", "NATGAS.f", "ERBN.f", "US500.cash",
//"ETHUSD", "DOGEUSD", "DASHUSD", "ADAUSD", "DOTUSD", "LTCUSD", "XRPUSD",
   string arr_symbol[] = {"DX.f", "XAUUSD", "XAGUSD", "USOIL.cash",
                          "US30.cash", "US100.cash",
                          "BTCUSD",
                          "AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD",
                          "EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                          "GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD",
                          "NZDCAD", "NZDJPY", "NZDUSD",
                          "USDCAD", "USDJPY", "CADJPY"
                         };

//"AAPL", "AIRF", "AMZN", "BAC", "BAYGn", "DBKGn", "GOOG", "LVMH", "META", "MSFT", "NFLX", "NVDA", "PFE", "RACE", "TSLA", "VOWG_p", "WMT", "BABA", "T", "V", "ZM"
//string arr_stocks[] = {};
//string sAllSymbols[];
//ArrayCopy(sAllSymbols, arr_stocks, ArraySize(arr_stocks));
//ArrayCopy(sAllSymbols, arr_symbol, ArraySize(arr_symbol));
   int total_fx_stock_size = ArraySize(arr_symbol);
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
                , "current_price"
                , "hi_h1_20_1"
                , "mi_h1_20_0"
                , "lo_h1_20_1"
                , "amp_h1"
                , "signal_macd_h4"
                , "signal_macd_h1"
                , "signal_macd_15"
                , "todo"
                , "todo"
                , "d_close"
                , "d_today_low"
                , "d_today_hig"
                , "amp_min_d1"
                , "amp_avg_h4");

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

         //Get price data
         double current_price = SymbolInfoDouble(symbol, SYMBOL_BID);

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

         double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
         CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
         double hi_h1_20_1 = upper_h1_20_1[0];
         double mi_h1_20_0 = middle_h1_20_1[0];
         double lo_h1_20_1 = lower_h1_20_1[0];
         double amp_h1 = MathAbs(hi_h1_20_1 - mi_h1_20_0);

         int length = 50;
         double h4_close_prices[50];
         double h1_close_prices[50];
         double m15_close_prices[50];

         for(int i = length - 1; i >= 0; i--)
           {
            h4_close_prices[i] = iClose(symbol, PERIOD_H4, i);
            h1_close_prices[i] = iClose(symbol, PERIOD_H1, i);
            m15_close_prices[i] = iClose(symbol, PERIOD_M15, i);
           }

         double signal_macd_h4 = get_signal_macd(symbol, h4_close_prices);
         double signal_macd_h1 = get_signal_macd(symbol, h1_close_prices);
         double signal_macd_15 = get_signal_macd(symbol, m15_close_prices);

         FileWrite(nfile_w_pivot
                   , TimeToString(TimeCurrent(), TIME_DATE)
                   , symbol
                   , trend_w1
                   , format_double_to_string(w_close, digits)
                   , format_double_to_string(avg_amp_week, digits)
                   , format_double_to_string(current_price, digits)

                   , format_double_to_string(hi_h1_20_1, digits)
                   , format_double_to_string(mi_h1_20_0, digits)
                   , format_double_to_string(lo_h1_20_1, digits)
                   , format_double_to_string(amp_h1, digits)

                   , format_double_to_string(signal_macd_h4, digits)
                   , format_double_to_string(signal_macd_h1, digits)
                   , format_double_to_string(signal_macd_15, digits)
                   , format_double_to_string(0.0, digits)
                   , format_double_to_string(0.0, digits)

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
      //Print("(DailyPivot) Failed to get history data.");
     }
     
//
////--------------------------------------------------------------------------------------------------------------------
////--------------------------------------------------------------------------------------------------------------------
////--------------------------------------------------------------------------------------------------------------------
//   int s_size = ArraySize(arr_symbol);
//   FileDelete("Data//TimeBreaker.csv");
//   int nfile_handle = FileOpen("Data//TimeBreaker.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);
//
//   if(nfile_handle != INVALID_HANDLE)
//     {
//      FileWrite(nfile_handle, "");
//
//      int copied;
//
//      for(int index=0; index < s_size; index++)
//        {
//         //---------------------------------------------
//         //string symbol = StringReplace(arr_symbol[index], ".cash", "");
//         string symbol = arr_symbol[index];
//
//         //Get price data
//         double current_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
//         double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
//         double current_price = (current_bid + current_ask) / 2;
//         //-------------------------------------------------------------------------------------------------------------------------------
//         //-------------------------------------------------------------------------------------------------------------------------------
//         /*
//         MqlRates rates_w1[];
//         ArraySetAsSeries(rates_w1,true);
//         copied=CopyRates(symbol, PERIOD_W1, 0, 20, rates_w1);
//         if(copied>0)
//           {
//            int size=fmin(copied, 20);
//            for(int i=0; i<size; i++)
//              {
//               FileWrite(nfile_handle, symbol, "WEEK", rates_w1[i].time, rates_w1[i].open, rates_w1[i].high, rates_w1[i].low, rates_w1[i].close, current_price);
//              }
//           }
//         else
//           {
//            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_W1");
//           }
//         //-------------------------------------------------------------------------------------------------------------------------------
//
//         MqlRates rates_d1[];
//         ArraySetAsSeries(rates_d1,true);
//         copied=CopyRates(symbol, PERIOD_D1, 0, 55, rates_d1);
//         if(copied>0)
//           {
//            int size=fmin(copied, 55);
//            for(int i=0; i<size; i++)
//              {
//               FileWrite(nfile_handle, symbol, "DAY", rates_d1[i].time, rates_d1[i].open, rates_d1[i].high, rates_d1[i].low, rates_d1[i].close, current_price);
//              }
//           }
//         else
//           {
//            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_D1");
//           }
//         */
//         //-------------------------------------------------------------------------------------------------------------------------------
//         MqlRates rates_h4[];
//         ArraySetAsSeries(rates_h4,true);
//         copied=CopyRates(symbol, PERIOD_H4, 0, 55, rates_h4);
//         if(copied>0)
//           {
//            int size=fmin(copied, 55);
//            for(int i=0; i<size; i++)
//              {
//               FileWrite(nfile_handle, symbol, "HOUR_04", rates_h4[i].time, rates_h4[i].open, rates_h4[i].high, rates_h4[i].low, rates_h4[i].close, current_price);
//              }
//           }
//         else
//           {
//            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_H4");
//           }
//
//         //-------------------------------------------------------------------------------------------------------------------------------
//         MqlRates rates_h1[];
//         ArraySetAsSeries(rates_h1,true);
//         copied=CopyRates(symbol, PERIOD_H1, 0, 55, rates_h1);
//         if(copied>0)
//           {
//            int size=fmin(copied, 55);
//            for(int i=0; i<size; i++)
//              {
//               FileWrite(nfile_handle, symbol, "HOUR_01", rates_h1[i].time, rates_h1[i].open, rates_h1[i].high, rates_h1[i].low, rates_h1[i].close, current_price);
//              }
//           }
//         else
//           {
//            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_H1");
//           }
//
//         //-------------------------------------------------------------------------------------------------------------------------------
//
//        } //for
//      //--------------------------------------------------------------------------------------------------------------------
//      //--------------------------------------------------------------------------------------------------------------------
//      FileClose(nfile_handle);
//     }
//   else
//     {
//      //Print("(TimeBreaker) Failed to get history data.");
//     }


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
