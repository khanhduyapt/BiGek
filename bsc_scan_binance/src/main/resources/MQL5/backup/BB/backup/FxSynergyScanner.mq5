//+------------------------------------------------------------------+
//|                                             FxSynergyScanner.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#include "..\Scripts\utils.mq5"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
//---
   return(INIT_SUCCEEDED);
  }



//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   SYMBOL_ALLOW_TRADE_BY_TREND_FOLLOWING_STRATEGY = "";

   string tab = "\t";
   string newline = "\n";

   string log_msg_allow_trade = "";
   string log_msg_h4_eq_h1 = "";
   string log_msg_others = "";

   string TREND_FOLLOWING_STRATEGY = "TREND";
   string RESISTANCE_STRATEGY = "RESIS";

   FileDelete("TradingToday.csv");
   int nfile_history = FileOpen("TradingToday.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_history != INVALID_HANDLE)
     {
      FileWrite(nfile_history
                , AppendSpaces("symbol")
                , AppendSpaces("strategy")
                , AppendSpaces("macd_h4")
                , AppendSpaces("hi_h1_20_1")
                , AppendSpaces("mi_h1_20_0")
                , AppendSpaces("lo_h1_20_1")
                , AppendSpaces("amp"));

      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         double cur_price = SymbolInfoDouble(symbol, SYMBOL_BID);
         //------------------------
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

         double m15_lo_prices[10];
         double m15_hi_prices[10];
         for(int i = 0; i < 10; i++)
           {
            m15_lo_prices[i] = iLow(symbol, PERIOD_M15, i);
            m15_hi_prices[i] = iHigh(symbol, PERIOD_M15, i);
           }
         //------------------------
         string profit = "";
         int total_orders = 0;
         double total_profit = 0;
         CountOrders(symbol, total_orders, total_profit);
         if(total_orders > 0)
           {
            profit = "Profit: " + (string)total_profit + "/" + (string)total_orders;
           }
         profit = AppendSpaces(profit, 20);

         //------------------------

         string heiken_h4 = get_trend_by_heiken(symbol, PERIOD_H4, 0);
         string trend_heiken = AppendSpaces("(Heiken)");
         trend_heiken += AppendSpaces("H4: " + heiken_h4);

         //------------------------

         string macd_h4 = get_trend_by_macd(symbol, h4_close_prices);
         string macd_h1 = get_trend_by_macd(symbol, h1_close_prices);
         string macd_15 = get_trend_by_macd(symbol, m15_close_prices);

         string trend_macd = AppendSpaces("(Macd)");
         trend_macd += AppendSpaces("15: " + macd_15);
         trend_macd += AppendSpaces("H1: " + macd_h1);
         trend_macd += AppendSpaces("H4: " + macd_h4);

         //------------------------
         double m15_ma_20 = CalculateMA(m15_close_prices, 20);

         double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
         CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
         double hi_h1_20_1 = format_double(upper_h1_20_1[0], digits);
         double mi_h1_20_0 = format_double(middle_h1_20_1[0], digits);
         double lo_h1_20_1 = format_double(lower_h1_20_1[0], digits);
         double amp = format_double(MathAbs(hi_h1_20_1 - mi_h1_20_0), digits);

         string str_count_hi_lo = "";
         for(int i = 10; i >= 2; i--)
           {
            string type = "";
            double h1_20_i = 0;
            if(mi_h1_20_0 < cur_price)
              {
               type = "(hi)";
               h1_20_i = mi_h1_20_0 + (amp*i);
              }
            else
              {
               type = "(lo)";
               h1_20_i = mi_h1_20_0 - (amp*i);
              }

            int count_hi_h1_20_i = CountPricesInRange(m15_lo_prices, m15_hi_prices, h1_20_i);
            if(count_hi_h1_20_i > 3)
              {
               str_count_hi_lo += type + " h1(20, " + (string)i + ")" + (string)count_hi_h1_20_i + "    ";
              }
           }


         //-------------------------------------------------------------------
         //TREND_FOLLOWING_STRATEGY
         //-------------------------------------------------------------------
         bool allow_trading = false;
         string trading_candidate = "";
         if((macd_h4 == macd_h1))// || ((macd_h4 == heiken_h4) && (macd_h4 == heiken_h1))
           {
            if(((macd_h4 == TREND_BUY) || (macd_h4 == TREND_SEL)) && (lo_h1_20_1 < m15_ma_20) && (m15_ma_20 < hi_h1_20_1))
              {
               allow_trading = true;
               trading_candidate = AppendSpaces(macd_h4, 5);
              }

            if((macd_h4 == TREND_BUY) && (lo_h1_20_1 < m15_ma_20) && (m15_ma_20 < mi_h1_20_0)) // && (heiken_h4 == TREND_BUY)
              {
               allow_trading = true;
               trading_candidate += "(Waiting)";
              }

            if((macd_h4 == TREND_SEL) && (hi_h1_20_1 > m15_ma_20) && (m15_ma_20 > mi_h1_20_0)) // && (heiken_h4 == TREND_SEL)
              {
               allow_trading = true;
               trading_candidate += "(Waiting)";
              }

            if(allow_trading)
              {
               SYMBOL_ALLOW_TRADE_BY_TREND_FOLLOWING_STRATEGY += getType(macd_h4) + symbol + "; ";
               FileWrite(nfile_history
                         , symbol
                         , TREND_FOLLOWING_STRATEGY
                         , macd_h4
                         , hi_h1_20_1
                         , mi_h1_20_0
                         , lo_h1_20_1
                         , amp);
              }
           }
         trading_candidate = AppendSpaces(trading_candidate, 15);
         //-------------------------------------------------------------------
         //RESISTANCE_STRATEGY
         //-------------------------------------------------------------------
         if(allow_trading == false)
           {
            if((m15_ma_20 < hi_h1_20_1) || (hi_h1_20_1 < m15_ma_20))
              {
               // Waiting sell
               if(m15_ma_20 > hi_h1_20_1)
                 {

                 }

               //Waiting buy
               if(m15_ma_20 < hi_h1_20_1)
                 {

                 }
              }
           }


         //-----------------------------------------------------------------------------
         string log_msg = "";
         log_msg += AppendSpaces(symbol);
         log_msg += AppendSpaces(format_double_to_string(cur_price, digits));
         log_msg += trend_heiken + tab;
         log_msg += trend_macd + tab;
         log_msg += profit + tab;
         log_msg += trading_candidate + tab;
         log_msg += "   https://www.tradingview.com/chart/r46Q5U5a/?symbol=" + AppendSpaces(symbol);
         log_msg += tab + str_count_hi_lo;
         log_msg += newline;

         if(allow_trading)
           {
            log_msg_allow_trade += log_msg;
           }
         else
            if(macd_h4 == macd_h1)
              {
               log_msg_h4_eq_h1 += log_msg;
              }
            else
              {
               log_msg_others += log_msg;
              }

        } // for total_fx_size

      FileClose(nfile_history);
     }


   WriteToLog(log_msg_allow_trade + newline + newline + newline + log_msg_h4_eq_h1 + newline + newline + newline + log_msg_others);

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
