//+------------------------------------------------------------------+
//|                                                  StockMarket.mq5 |
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

   EventSetTimer(3600); //3600=60minutes;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|               StockMarket                                        |
//+------------------------------------------------------------------+
void OnTick(void)
  {
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   FileDelete("Data//Stocks.csv");
   int nfile_handle = FileOpen("Data//Stocks.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "");

      string arr_stocks[] = {"AAPL", "AIRF", "AMZN", "BAC", "BAYGn", "DBKGn",
            "GOOG", "LVMH", "META", "MSFT", "NFLX", "NVDA", "PFE", "RACE", "TSLA", "VOWG_p", "WMT"};

      Comment("-----------------------------StockMarket: (Symbol):" + Symbol());

      int stocks_copied;
      int stocks_size = ArraySize(arr_stocks);
      for(int index=0; index < stocks_size; index++)
        {

         //---------------------------------------------
         //string symbol = StringReplace(arr_stocks[index], ".cash", "");
         string symbol = arr_stocks[index];
         //---------------------------------------------
         MqlRates rates_month[];
         ArraySetAsSeries(rates_month,true);
         stocks_copied=CopyRates(symbol, PERIOD_MN1, 0, 10, rates_month);
         if(stocks_copied>0)
           {
            int size=fmin(stocks_copied, 10);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "MONTH", rates_month[i].time, rates_month[i].open, rates_month[i].high, rates_month[i].low, rates_month[i].close);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_MN1");
           }
         //---------------------------------------------
         MqlRates rates_w1[];
         ArraySetAsSeries(rates_w1,true);
         stocks_copied=CopyRates(symbol, PERIOD_W1, 0, 10, rates_w1);
         if(stocks_copied>0)
           {
            int size=fmin(stocks_copied, 10);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "WEEK", rates_w1[i].time, rates_w1[i].open, rates_w1[i].high, rates_w1[i].low, rates_w1[i].close);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_W1");
           }
         //---------------------------------------------
         MqlRates rates_d1[];
         ArraySetAsSeries(rates_d1,true);
         stocks_copied=CopyRates(symbol, PERIOD_D1, 0, 15, rates_d1);
         if(stocks_copied>0)
           {
            int size=fmin(stocks_copied, 55);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "DAY", rates_d1[i].time, rates_d1[i].open, rates_d1[i].high, rates_d1[i].low, rates_d1[i].close);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_D1");
           }
         //---------------------------------------------
         MqlRates rates_h4[];
         ArraySetAsSeries(rates_h4,true);
         stocks_copied=CopyRates(symbol, PERIOD_H4, 0, 15, rates_h4);
         if(stocks_copied>0)
           {
            int size=fmin(stocks_copied, 55);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "HOUR_04", rates_h4[i].time, rates_h4[i].open, rates_h4[i].high, rates_h4[i].low, rates_h4[i].close);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_H4");
           }
         //---------------------------------------------
         MqlRates rates_h1[];
         ArraySetAsSeries(rates_h1,true);
         stocks_copied=CopyRates(symbol, PERIOD_H1, 0, 15, rates_h1);
         if(stocks_copied>0)
           {
            int size=fmin(stocks_copied, 55);
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
         /*
         MqlRates rates_15[];
         ArraySetAsSeries(rates_15,true);
         stocks_copied=CopyRates(symbol, PERIOD_M15, 0, 55, rates_15);
         if(stocks_copied>0)
           {
            int size=fmin(stocks_copied, 55);
            for(int i=0; i<size; i++)
              {
               FileWrite(nfile_handle, symbol, "MINUTE_15", rates_15[i].time, rates_15[i].open, rates_15[i].high, rates_15[i].low, rates_15[i].close);
              }
           }
         else
           {
            FileWrite(nfile_handle, "NOT_FOUND", symbol, "PERIOD_M15");
           }
           */
         //---------------------------------------------

        } //for
      //--------------------------------------------------------------------------------------------------------------------
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
