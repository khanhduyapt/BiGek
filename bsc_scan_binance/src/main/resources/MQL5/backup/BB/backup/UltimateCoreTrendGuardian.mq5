//+------------------------------------------------------------------+
//|                                    UltimateCoreTrendGuardian.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\Scripts\utils.mq5"

string input BOT_NAME = "UltimateCoreTrendGuardian";
int input    EXPERT_MAGIC = 20231124;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteComment()
  {
   string symbol = _Symbol;

   double dbRiskRatio = 0.01;
   double INIT_EQUITY = 200.0; //Vốn ban đầu 200$
   double risk = format_double(dbRisk(dbRiskRatio, INIT_EQUITY), 2);

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


   string str_risk  =  "    P.Today:" + format_double_to_string(get_profit_today(), 2) +"$";
   str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
   str_risk += "    " + symbol;

   string trend_heiken = AppendSpaces("(Heiken)");
   trend_heiken += "15: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_M15, 0));
   trend_heiken += "H1: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H1, 0));
   trend_heiken += "H4: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H4, 0));

   string trend_macd = AppendSpaces("(Macd)");
   trend_macd += "15: "+ AppendSpaces(get_trend_by_macd(symbol, m15_close_prices));
   trend_macd += "H1: "+ AppendSpaces(get_trend_by_macd(symbol, h1_close_prices));
   trend_macd += "H4: "+ AppendSpaces(get_trend_by_macd(symbol, h4_close_prices));

   string comment = BOT_NAME + "   " + (string)GetVietnamTime() + "\n";
   comment += str_risk + "\n";
   comment += trend_heiken + "\n";
   comment += trend_macd + "\n";

   //comment += SYMBOL_ALLOW_TRADE_BY_TREND_FOLLOWING_STRATEGY;
   Comment(comment);

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   WriteComment();

//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1;  // PERIOD_M15 PERIOD_H1
// dbRiskRatio=0.01 <-> 1% tài khoản/1 lệnh.
   double dbRiskRatio = 0.01;
   double INIT_EQUITY = 200.0; //Vốn ban đầu 200$
   double risk = format_double(dbRisk(dbRiskRatio, INIT_EQUITY), 2);
//End ----------------------------------------------------------------
//
//   int count_candidate = 0;
//   string waiting_symbols = "(M15) ";
//   int total_fx_size = ArraySize(arr_symbol);
//   for(int index = 0; index < total_fx_size; index++)
//     {
//      string symbol = arr_symbol[index];
//      int totalOpenOrders = 0;
//      double totalProfit = 0;
//      CountOrders(symbol, totalOpenOrders, totalProfit);
//      if(totalOpenOrders > 0)
//        {
//         continue;
//        }
//      //--------------------------------------------------------
//      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
//      double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
//      CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
//
//      double hi_h1_20_1 = upper_h1_20_1[0];
//      double mi_h1_20_1 = middle_h1_20_1[0];
//      double lo_h1_20_1 = lower_h1_20_1[0];
//
//      string trend = check_ma_and_heiken_conditon(symbol, hi_h1_20_1, mi_h1_20_1, lo_h1_20_1);
//
//      if(trend != "")
//        {
//         count_candidate += 1;
//         waiting_symbols += "(" + trend + ")" + symbol+ "; ";
//
//         // dbRiskRatio=0.01 <-> 1% tài khoản/1 lệnh.
//         double dbAmp = MathAbs(hi_h1_20_1 - mi_h1_20_1);
//         double lot_size = dblLotsRisk(symbol, dbAmp, risk);
//
//         if(trend == "BUY")
//           {
//            m_trade.Buy(lot_size, symbol, (lo_h1_20_1 - dbAmp), 0.0, NormalizeDouble(hi_h1_20_1, digits), "BUY_1");
//            m_trade.BuyLimit(lot_size, NormalizeDouble(lo_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mi_h1_20_1, digits), 0, 0, "BUY_2");
//            m_trade.BuyLimit(lot_size, NormalizeDouble(lo_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mi_h1_20_1, digits), 0, 0, "BUY_3");
//           }
//
//         if(trend == "SELL")
//           {
//            m_trade.Sell(lot_size, symbol, 0.0, (hi_h1_20_1 + dbAmp), lo_h1_20_1, "SELL_1");
//            m_trade.SellLimit(lot_size, NormalizeDouble(hi_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mi_h1_20_1, digits), 0, 0, "SELL_2");
//            m_trade.SellLimit(lot_size, NormalizeDouble(hi_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mi_h1_20_1, digits), 0, 0, "SELL_3");
//           }
//        }
//     }


  }
//+------------------------------------------------------------------+
string check_ma_and_heiken_conditon(string symbol, double hi_h1_20_1, double mi_h1_20_1, double lo_h1_20_1)
  {
   int maLength = 50;
   double closePrices[50];
   for(int i = 0; i < maLength; i++)
     {
      closePrices[i] = iClose(symbol, PERIOD_M15, i);
     }

   double ma_20 = CalculateMA(closePrices, 20);
   double ma_50 = CalculateMA(closePrices, 50);
   double cur_price = SymbolInfoDouble(symbol, SYMBOL_BID);
   bool is_uptren_heiken_0 = is_uptren_heiken_0(symbol);

   if((cur_price < mi_h1_20_1) && (is_uptren_heiken_0 == true) && (lo_h1_20_1 < ma_50) && (ma_50 < ma_20) && (ma_20 < mi_h1_20_1))
     {
      return "BUY";
     }

   if((cur_price > mi_h1_20_1) && (is_uptren_heiken_0 == false) && (hi_h1_20_1 > ma_50) && (ma_50 > ma_20) && (ma_20 > mi_h1_20_1))
     {
      return "SELL";
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_uptren_heiken_0(string symbol)
  {
   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(symbol, PERIOD_M15, 0, haOpen0, haClose0, haHigh0, haLow0);
   bool is_uptren_heiken0 = (haOpen0 < haClose0);

   return is_uptren_heiken0;
  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(30);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
