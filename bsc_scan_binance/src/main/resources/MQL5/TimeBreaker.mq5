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

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

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
   string forex_main = "_XAUUSD_XAGUSD_US30_NAS100_EURUSD_USDJPY_GBPUSD_GBPJPY_USDCHF_NZDUSD_";
   MqlDateTime dt_struct;
   datetime dtSer=TimeToStruct(TimeLocal(), dt_struct);
   int cur_minu = (int)dt_struct.min;
   double mod5 = MathMod(cur_minu, 2);

   FileDelete("Data//ForexM.csv");
   int nfile_handle = FileOpen("Data//ForexM.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "");

      string arr_symbol[] = {"XAUUSD", "XAGUSD", "BTCUSD", "US30.cash", "US100.cash", "EU50.cash", "GER40.cash", "UK100.cash", "USOIL.cash", "AUS200.cash",
                             "ETHUSD", "DOGEUSD", "FRA40.cash", "SPN35.cash",
                             "DOTUSD", "ADAUSD", "XRPUSD", "DASHUSD", "LTCUSD",
                             "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
                             "CADJPY", "CHFJPY",
                             "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                             "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
                             "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                             "USDCAD", "USDCHF", "USDCZK", "USDSEK", "USDJPY"
                            };


      Comment("-----------------------------TimeBreaker (Symbol):"+ Symbol());

      int copied;
      int s_size = ArraySize(arr_symbol);
      for(int index=0; index < s_size; index++)
        {
         //---------------------------------------------
         //string symbol = StringReplace(arr_symbol[index], ".cash", "");
         string symbol = arr_symbol[index];
         //---------------------------------------------
         //if(mod5 == 1)
           {

            //---------------------------------------------
            MqlRates rates_h1[];
            ArraySetAsSeries(rates_h1,true);
            copied=CopyRates(symbol, PERIOD_H1, 0, 55, rates_h1);
            if(copied>0)
              {
               int size=fmin(copied, 55);
               for(int i=0; i<size; i++)
                 {
                  FileWrite(nfile_handle, symbol, "HOUR_01", rates_h1[i].time, rates_h1[i].open, rates_h1[i].high, rates_h1[i].low, rates_h1[i].close);
                 }
              }
            else
              {
               FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_H1");
              }
            //---------------------------------------------
            MqlRates rates_15[];
            ArraySetAsSeries(rates_15,true);
            copied=CopyRates(symbol, PERIOD_M15, 0, 55, rates_15);
            if(copied>0)
              {
               int size=fmin(copied, 55);
               for(int i=0; i<size; i++)
                 {
                  FileWrite(nfile_handle, symbol, "MINUTE_15", rates_15[i].time, rates_15[i].open, rates_15[i].high, rates_15[i].low, rates_15[i].close);
                 }
              }
            else
              {
               FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_M15");
              }
            //---------------------------------------------
            MqlRates rates_05[];
            ArraySetAsSeries(rates_05,true);
            copied=CopyRates(symbol, PERIOD_M5, 0, 55, rates_05);
            if(copied>0)
              {
               int size=fmin(copied, 55);
               for(int i=0; i<size; i++)
                 {
                  FileWrite(nfile_handle, symbol, "MINUTE_5", rates_05[i].time, rates_05[i].open, rates_05[i].high, rates_05[i].low, rates_05[i].close);
                 }
              }
            else
              {
               FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_M5");
              }
            //---------------------------------------------
           } //mod5

        } //for
      //--------------------------------------------------------------------------------------------------------------------

      //--------------------------------------------------------------------------------------------------------------------
      FileClose(nfile_handle);
     }
   else
     {
      Print("(Data2Csv) Failed to get history data.");
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