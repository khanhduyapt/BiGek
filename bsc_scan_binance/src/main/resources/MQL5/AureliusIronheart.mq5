//+------------------------------------------------------------------+
//|                                            AureliusIronheart.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   return(INIT_SUCCEEDED);
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

   FileDelete("Data//AureliusIronheart.csv");
   int nfile_handle = FileOpen("Data//AureliusIronheart.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "");

      string arr_symbol[] = {"DX.f", "XAUUSD", "XAGUSD", "USOIL.cash",
                             "US30.cash", "US100.cash", "US500.cash",
                             //"EU50.cash", "GER40.cash", "UK100.cash", "AUS200.cash", "FRA40.cash", "SPN35.cash", "NATGAS.f", "ERBN.f",

                             "BTCUSD",
                             //"ETHUSD", "DOGEUSD", "DASHUSD", "ADAUSD", "DOTUSD", "LTCUSD", "XRPUSD",

                             "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
                             "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                             "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
                             "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                             "USDCAD", "USDCHF", "USDJPY", "CADJPY", "CHFJPY", "CADCHF"
                            };

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
         //-------------------------------------------------------------------------------------------------------------------------------
         MqlRates rates_5[];
         ArraySetAsSeries(rates_5,true);
         copied=CopyRates(symbol, PERIOD_M5, 0, 89, rates_5);
         if(copied>0)
           {
            int size=fmin(copied, 89);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "MINUTE_03", rates_5[i].time, rates_5[i].open, rates_5[i].high, rates_5[i].low, rates_5[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_M5");
           }
         //-------------------------------------------------------------------------------------------------------------------------------
         MqlRates rates_15[];
         ArraySetAsSeries(rates_15,true);
         copied=CopyRates(symbol, PERIOD_M15, 0, 89, rates_15);
         if(copied>0)
           {
            int size=fmin(copied, 89);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "MINUTE_15", rates_15[i].time, rates_15[i].open, rates_15[i].high, rates_15[i].low, rates_15[i].close, current_price);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_M15");
           }

         //-------------------------------------------------------------------------------------------------------------------------------
         //--------------------------------------------------------------------------------------------------------------------
         //--------------------------------------------------------------------------------------------------------------------
        } //for

      FileClose(nfile_handle);
     }
   else
     {
      //Print("(AureliusIronheart) Failed to get history data.");
     }


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

//+------------------------------------------------------------------+
