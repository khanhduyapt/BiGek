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

   FileDelete("Data//TimeBreaker.csv");
   int nfile_handle = FileOpen("Data//TimeBreaker.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "");

      string arr_symbol[] = {"DX.f", "XAUUSD", "XAGUSD", "USOIL.cash", 
                             "US30.cash", "US100.cash", 
                             //"EU50.cash", "GER40.cash", "UK100.cash", "AUS200.cash", "FRA40.cash", "SPN35.cash", "NATGAS.f", "ERBN.f",

                             "BTCUSD", 
                             //"ETHUSD", "DOGEUSD", "DASHUSD", "ADAUSD", "DOTUSD", "LTCUSD", "XRPUSD",

                             "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
                             "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                             "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
                             "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                             "USDCAD", "USDCHF", "USDJPY", "CADJPY", "CHFJPY", "CADCHF"
                            };


      Comment("-----------------------------TimeBreaker (Symbol):"+ Symbol());

      int copied;
      int s_size = ArraySize(arr_symbol);
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

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
