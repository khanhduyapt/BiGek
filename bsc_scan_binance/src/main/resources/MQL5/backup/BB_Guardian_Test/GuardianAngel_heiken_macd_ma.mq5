//+------------------------------------------------------------------+
//|                                                GuardianAngel.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

string input BOT_NAME = "GuardianAngel_Test";
int input    EXPERT_MAGIC = 20231201;

double input dbRiskRatio = 0.01; // Rủi ro 1%
double input INIT_EQUITY = 10000.0; // Vốn ban đầu 200$

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string symbol = _Symbol;


   bool ALLOW_TRADE = true;
   double total_profit = get_profit_today();
   double loss_percent = MathAbs(total_profit / INIT_EQUITY);
   string profit_today = "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$ "
                         + format_double_to_string(loss_percent * 100, 2) + "%";
   if(loss_percent > 0.15)
     {
      //ALLOW_TRADE = false;
     }


   if(IsMarketClose())
     {
      ALLOW_TRADE = false;

      string message = get_vntime() + "(" + BOT_NAME + ") Market Close (Sat, Sun, 3 <= Vn.Hour <= 7).";
      message += profit_today;
      if(ALLOW_TRADE == false)
         message += " STOP ";
      Comment(message);

      return;
     }

   double risk_per_trade = calcRiskPerTrade();
   string str_risk  =  profit_today;
   str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk_per_trade + "$";
   if(ALLOW_TRADE == false)
      str_risk += " STOP ";
   str_risk += "    " + _Symbol + " (" + GetTrendByPricePosition(_Symbol) + ")";


   int length = 55;
   double close_prices_h4[55];
   double close_prices_h1[55];
   double close_prices_15[55];
   for(int i = length - 1; i >= 0; i--)
     {
      close_prices_h4[i] = iClose(symbol, PERIOD_H4, i); // PERIOD_H4
      close_prices_h1[i] = iClose(symbol, PERIOD_H1, i); // PERIOD_H1
      close_prices_15[i] = iClose(symbol, PERIOD_M15, i);// PERIOD_M15
     }

//string trend_heiken_h4 = get_trend_by_heiken(symbol, PERIOD_H4, 0);
//string trend_heiken_h1 = get_trend_by_heiken(symbol, PERIOD_H1, 0);
//string trend_heiken = AppendSpaces("(Heiken)");
//trend_heiken += "15: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_M15, 0));
//trend_heiken += "H1: "+ AppendSpaces(trend_heiken_h1);
//trend_heiken += "H4: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H4, 0));

   string trend_macd_h4 = get_trend_by_macd(symbol, close_prices_15);
   string trend_macd_h1 = get_trend_by_macd(symbol, close_prices_h1);
   string trend_macd_15 = get_trend_by_macd(symbol, close_prices_h4);

   string trend_macd = AppendSpaces("(Macd)");
   trend_macd += "15: "+ AppendSpaces(trend_macd_15);
   trend_macd += "H1: "+ AppendSpaces(trend_macd_h1);
   trend_macd += "H4: "+ AppendSpaces(trend_macd_h4);

   string comment = get_vntime() + " (" + BOT_NAME + ") Market Open " + str_risk + "\n";
   comment += str_risk + "\n";
//comment += trend_heiken + "\n";
   comment += trend_macd + "\n";
   Comment(comment);




//CleanTrade(symbol);
//OpenTrade_Ma10_20_50(symbol);
//OpenTrade_Heiken(symbol);
//OpenTrade_M15(symbol);
//TrailingStop();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade_M15(string find_trend, string symbol)
  {
   double risk_per_trade = calcRiskPerTrade();

   int count = 0;
   string lowcase_symbol = toLower(symbol);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      if(lowcase_symbol == order_symbol)
        {
         count = count + 1;
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         count = count + 1;
        }
     }

   if(count > 0)
     {
      return;
     }

   int length = 55;
   double close_prices_15[55];
   for(int i = length - 1; i >= 0; i--)
     {
      close_prices_15[i] = iClose(symbol, PERIOD_M15, i);// PERIOD_M15
     }

   /*
   H4: ma10 -> ma20 -> ma50
   H1: ma10 -> ma20 -> ma50
   15: Có tổ hợp 3 cây nến chứa được cả ma10, ma 20, ma50
       Đóng cửa trên ma50

   Limit1: ma50, Limit2: Đóng cửa thấp nhất của 3 cây nến, Lệnh 3: mua luôn khi phát hiện.
   SL: 1% tài khoản cho 1 lệnh. Tại điểm thấp nhất của 10 cây nến + 1/2 cây nến trung bình.
   */

   double sub_close_10c_m15[];
   ArrayResize(sub_close_10c_m15, 10);
   for(int i = 0; i < 10; i++)
     {
      sub_close_10c_m15[i] = close_prices_15[i];
     }

   double sub_close_3c_m15[];
   ArrayResize(sub_close_3c_m15, 3);
   for(int i = 0; i < 3; i++)
     {
      sub_close_3c_m15[i] = close_prices_15[i];
     }

// Tính toán giá trị MA(10), MA(20), và MA(50)
   double ma10_of_m15 = CalculateMA(close_prices_15, 10);
   double ma20_of_m15 = CalculateMA(close_prices_15, 20);
   double ma50_of_m15 = CalculateMA(close_prices_15, 50);

   double avg_heigh = CalculateAverageCandleHeight(PERIOD_M15, symbol);
   double min_price = FindMinPrice(sub_close_3c_m15) - avg_heigh;
   double max_price = FindMaxPrice(sub_close_3c_m15) + avg_heigh;
   double close_price = close_prices_15[1];

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
// Tất cả các giá trị nằm trong khoảng giá.

   if(min_price <= ma10_of_m15 && ma10_of_m15 <= max_price
      && min_price <= ma20_of_m15 && ma20_of_m15 <= max_price
      && min_price <= ma50_of_m15 && ma50_of_m15 <= max_price)
     {

      if(close_price >= ma50_of_m15)
        {
         double amp_sl = NormalizeDouble(MathAbs(price - min_price), digits);
         double volume = dblLotsRisk(symbol, amp_sl, risk_per_trade);
         double price_tp = price + (amp_sl * 2);

         if(m_trade.Buy(volume, symbol, 0.0, min_price, price_tp, "BUY_1"))
           {
            //m_trade.BuyLimit(volume, ma50_of_m15, symbol, min_price, price_tp, 0, 0, "BUY_2");
            //m_trade.BuyLimit(volume, min_price + avg_heigh, symbol, min_price, price_tp, 0, 0, "BUY_3");

            Alert(get_vntime(), "  BUY: ", symbol, "   price: ", price, "    vol:", volume);
           }
        }

      if(close_price <= ma50_of_m15)
        {
         double amp_sl = NormalizeDouble(MathAbs(max_price - price), digits);
         double volume = dblLotsRisk(symbol, amp_sl, risk_per_trade);
         double price_tp = price - (amp_sl * 2);

         if(m_trade.Sell(volume, symbol, 0.0, max_price, price_tp, "SELL_1"))
           {
            //m_trade.SellLimit(volume, ma50_of_m15, symbol, max_price, price_tp, 0, 0, "SELL_2");
            //m_trade.SellLimit(volume, max_price - avg_heigh, symbol, max_price, price_tp, 0, 0, "SELL_3");

            Alert(get_vntime(), " SELL: ", symbol, "   price: ", price, "    vol:", volume);
           }
        }
     }
  }

//+------------------------------------------------------------------+
void OpenTrade_Heiken(string symbol)
  {
   double risk_per_trade = calcRiskPerTrade();

   bool ALLOW_TRADE = true;
   double total_profit = get_profit_today();
   double loss_percent = MathAbs(total_profit / INIT_EQUITY);
   string profit_today = "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$ "
                         + format_double_to_string(loss_percent * 100, 2) + "%";
   if(loss_percent > 0.15)
     {
      //ALLOW_TRADE = false;
     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
   if(IsMarketClose())
     {
      ALLOW_TRADE = false;

      string message = get_vntime() + "(" + BOT_NAME + ") Market Close (Sat, Sun, 3 <= Vn.Hour <= 7).";
      message += profit_today;
      if(ALLOW_TRADE == false)
         message += " STOP ";
      Comment(message);

      return;
     }

   int count = 0;
   string lowcase_symbol = toLower(symbol);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      if(lowcase_symbol == order_symbol)
        {
         count = count + 1;
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         count = count + 1;
        }
     }

   if(count > 0)
     {
      return;
     }

   int length = 55;
   double close_prices_h4[55];
   double close_prices_h1[55];
   double close_prices_15[55];
   for(int i = length - 1; i >= 0; i--)
     {
      close_prices_h4[i] = iClose(symbol, PERIOD_H4, i); // PERIOD_H4
      close_prices_h1[i] = iClose(symbol, PERIOD_H1, i); // PERIOD_H1
      close_prices_15[i] = iClose(symbol, PERIOD_M15, i);// PERIOD_M15
     }


   string str_risk  =  profit_today;
   str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk_per_trade + "$";
   if(ALLOW_TRADE == false)
      str_risk += " STOP ";
   str_risk += "    " + _Symbol + " (" + GetTrendByPricePosition(_Symbol) + ")";

   string trend_heiken_h4 = get_trend_by_heiken(symbol, PERIOD_H4, 0);
   string trend_heiken_h1 = get_trend_by_heiken(symbol, PERIOD_H1, 0);

   string trend_heiken = AppendSpaces("(Heiken)");
   trend_heiken += "15: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_M15, 0));
   trend_heiken += "H1: "+ AppendSpaces(trend_heiken_h1);
   trend_heiken += "H4: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H4, 0));

   string trend_macd = AppendSpaces("(Macd)");
   trend_macd += "15: "+ AppendSpaces(get_trend_by_macd(symbol, close_prices_15));
   trend_macd += "H1: "+ AppendSpaces(trend_heiken_h1);
   trend_macd += "H4: "+ AppendSpaces(trend_heiken_h4);

   string comment = get_vntime() + " (" + BOT_NAME + ") Market Open " + str_risk + "\n";
   comment += str_risk + "\n";
   comment += trend_heiken + "\n";
   comment += trend_macd + "\n";

   Comment(comment);

   /*
   H4: ma10 -> ma20 -> ma50
   H1: ma10 -> ma20 -> ma50
   15: Có tổ hợp 3 cây nến chứa được cả ma10, ma 20, ma50
       Đóng cửa trên ma50

   Limit1: ma50, Limit2: Đóng cửa thấp nhất của 3 cây nến, Lệnh 3: mua luôn khi phát hiện.
   SL: 1% tài khoản cho 1 lệnh. Tại điểm thấp nhất của 10 cây nến + 1/2 cây nến trung bình.
   */

   if(trend_heiken_h4 == trend_heiken_h4)
     {
      double sub_close_10c_m15[];
      ArrayResize(sub_close_10c_m15, 10);
      for(int i = 0; i < 10; i++)
        {
         sub_close_10c_m15[i] = close_prices_15[i];
        }

      double sub_close_3c_m15[];
      ArrayResize(sub_close_3c_m15, 3);
      for(int i = 0; i < 3; i++)
        {
         sub_close_3c_m15[i] = close_prices_15[i];
        }

      // Tính toán giá trị MA(10), MA(20), và MA(50)
      double ma10_of_m15 = CalculateMA(close_prices_15, 10);
      double ma20_of_m15 = CalculateMA(close_prices_15, 20);
      double ma50_of_m15 = CalculateMA(close_prices_15, 50);

      double avg_heigh = CalculateAverageCandleHeight(PERIOD_M15, symbol);
      double min_price = FindMinPrice(sub_close_3c_m15) - avg_heigh;
      double max_price = FindMaxPrice(sub_close_3c_m15) + avg_heigh;
      double close_price = close_prices_15[1];

      // Tất cả các giá trị nằm trong khoảng giá.
      if((trend_heiken_h4 == TREND_BUY && close_price >= ma50_of_m15)
         || (trend_heiken_h4 == TREND_SEL && close_price <= ma50_of_m15))
        {
         if(min_price <= ma10_of_m15 && ma10_of_m15 <= max_price
            && min_price <= ma20_of_m15 && ma20_of_m15 <= max_price
            && min_price <= ma50_of_m15 && ma50_of_m15 <= max_price)
           {

            if(trend_heiken_h4 == TREND_BUY)
              {
               double amp_sl = NormalizeDouble(MathAbs(price - min_price), digits);
               double volume = dblLotsRisk(symbol, amp_sl, risk_per_trade);
               double price_tp = price + (amp_sl * 2);

               if(m_trade.Buy(volume, symbol, 0.0, min_price, price_tp, "BUY_1"))
                 {
                  m_trade.BuyLimit(volume, ma50_of_m15, symbol, min_price, price_tp, 0, 0, "BUY_2");
                  m_trade.BuyLimit(volume, min_price + avg_heigh, symbol, min_price, price_tp, 0, 0, "BUY_3");

                  Alert(get_vntime(), "  BUY: ", symbol, "   price: ", price, "    vol:", volume);
                 }
              }

            if(trend_heiken_h4 == TREND_SEL)
              {
               double amp_sl = NormalizeDouble(MathAbs(max_price - price), digits);
               double volume = dblLotsRisk(symbol, amp_sl, risk_per_trade);
               double price_tp = price - (amp_sl * 2);

               if(m_trade.Sell(volume, symbol, 0.0, max_price, price_tp, "SELL_1"))
                 {
                  m_trade.SellLimit(volume, ma50_of_m15, symbol, max_price, price_tp, 0, 0, "SELL_2");
                  m_trade.SellLimit(volume, max_price - avg_heigh, symbol, max_price, price_tp, 0, 0, "SELL_3");

                  Alert(get_vntime(), " SELL: ", symbol, "   price: ", price, "    vol:", volume);
                 }

              }

           }
        }

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade_Ma10_20_50(string symbol)
  {
   double risk_per_trade = calcRiskPerTrade();

   bool ALLOW_TRADE = true;
   double total_profit = get_profit_today();
   double loss_percent = MathAbs(total_profit / INIT_EQUITY);
   string profit_today = "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$ "
                         + format_double_to_string(loss_percent * 100, 2) + "%";
   if(loss_percent > 0.15)
     {
      //ALLOW_TRADE = false;
     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
   if(IsMarketClose())
     {
      ALLOW_TRADE = false;

      string message = get_vntime() + "(" + BOT_NAME + ") Market Close (Sat, Sun, 3 <= Vn.Hour <= 7).";
      message += profit_today;
      if(ALLOW_TRADE == false)
         message += " STOP ";
      Comment(message);

      return;
     }

   int count = 0;
   string lowcase_symbol = toLower(symbol);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      if(lowcase_symbol == order_symbol)
        {
         count = count + 1;
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         count = count + 1;
        }
     }

   if(count > 0)
     {
      return;
     }

   int length = 55;
   double close_prices_h4[55];
   double close_prices_h1[55];
   double close_prices_15[55];
   for(int i = length - 1; i >= 0; i--)
     {
      close_prices_h4[i] = iClose(symbol, PERIOD_H4, i); // PERIOD_H4
      close_prices_h1[i] = iClose(symbol, PERIOD_H1, i); // PERIOD_H1
      close_prices_15[i] = iClose(symbol, PERIOD_M15, i);// PERIOD_M15
     }


   string str_risk  =  profit_today;
   str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk_per_trade + "$";
   if(ALLOW_TRADE == false)
      str_risk += " STOP ";
   str_risk += "    " + _Symbol + " (" + GetTrendByPricePosition(_Symbol) + ")";

   string trend_heiken = AppendSpaces("(Heiken)");
   trend_heiken += "15: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_M15, 0));
   trend_heiken += "H1: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H1, 0));
   trend_heiken += "H4: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H4, 0));

   string trend_macd = AppendSpaces("(Macd)");
   trend_macd += "15: "+ AppendSpaces(get_trend_by_macd(symbol, close_prices_15));
   trend_macd += "H1: "+ AppendSpaces(get_trend_by_macd(symbol, close_prices_h1));
   trend_macd += "H4: "+ AppendSpaces(get_trend_by_macd(symbol, close_prices_h4));

   string comment = get_vntime() + " (" + BOT_NAME + ") Market Open " + str_risk + "\n";
   comment += str_risk + "\n";
   comment += trend_heiken + "\n";
   comment += trend_macd + "\n";

   Comment(comment);

   /*
   H4: ma10 -> ma20 -> ma50
   H1: ma10 -> ma20 -> ma50
   15: Có tổ hợp 3 cây nến chứa được cả ma10, ma 20, ma50
       Đóng cửa trên ma50

   Limit1: ma50, Limit2: Đóng cửa thấp nhất của 3 cây nến, Lệnh 3: mua luôn khi phát hiện.
   SL: 1% tài khoản cho 1 lệnh. Tại điểm thấp nhất của 10 cây nến + 1/2 cây nến trung bình.
   */
   string trend_h4 = checkMovingAverages(close_prices_h4);
   if(trend_h4 != "")
     {
      string trend_h1 = checkMovingAverages(close_prices_h1);
      if(trend_h4 == trend_h1)
        {
         double sub_close_10c_m15[];
         ArrayResize(sub_close_10c_m15, 10);
         for(int i = 0; i < 10; i++)
           {
            sub_close_10c_m15[i] = close_prices_15[i];
           }

         double sub_close_3c_m15[];
         ArrayResize(sub_close_3c_m15, 3);
         for(int i = 0; i < 3; i++)
           {
            sub_close_3c_m15[i] = close_prices_15[i];
           }

         // Tính toán giá trị MA(10), MA(20), và MA(50)
         double ma10_of_m15 = CalculateMA(close_prices_15, 10);
         double ma20_of_m15 = CalculateMA(close_prices_15, 20);
         double ma50_of_m15 = CalculateMA(close_prices_15, 50);

         double avg_heigh = CalculateAverageCandleHeight(PERIOD_M15, symbol);
         double min_price = FindMinPrice(sub_close_3c_m15) - avg_heigh;
         double max_price = FindMaxPrice(sub_close_3c_m15) + avg_heigh;
         double close_price = close_prices_15[1];

         // Tất cả các giá trị nằm trong khoảng giá.
         if((trend_h4 == TREND_BUY && close_price >= ma50_of_m15)
            || (trend_h4 == TREND_SEL && close_price <= ma50_of_m15))
           {
            if(min_price <= ma10_of_m15 && ma10_of_m15 <= max_price
               && min_price <= ma20_of_m15 && ma20_of_m15 <= max_price
               && min_price <= ma50_of_m15 && ma50_of_m15 <= max_price)
              {

               if(trend_h4 == TREND_BUY)
                 {
                  double amp_sl = NormalizeDouble(MathAbs(price - min_price), digits);
                  double volume = dblLotsRisk(symbol, amp_sl, risk_per_trade);
                  double price_tp = price + (amp_sl * 2);

                  if(m_trade.Buy(volume, symbol, 0.0, min_price, price_tp, "BUY_1"))
                    {
                     m_trade.BuyLimit(volume, ma50_of_m15, symbol, min_price, price_tp, 0, 0, "BUY_2");
                     m_trade.BuyLimit(volume, min_price + avg_heigh, symbol, min_price, price_tp, 0, 0, "BUY_3");

                     Alert(get_vntime(), "  BUY: ", symbol, "   price: ", price, "    vol:", volume);
                    }
                 }

               if(trend_h4 == TREND_SEL)
                 {
                  double amp_sl = NormalizeDouble(MathAbs(max_price - price), digits);
                  double volume = dblLotsRisk(symbol, amp_sl, risk_per_trade);
                  double price_tp = price - (amp_sl * 2);

                  if(m_trade.Sell(volume, symbol, 0.0, max_price, price_tp, "SELL_1"))
                    {
                     m_trade.SellLimit(volume, ma50_of_m15, symbol, max_price, price_tp, 0, 0, "SELL_2");
                     m_trade.SellLimit(volume, max_price - avg_heigh, symbol, max_price, price_tp, 0, 0, "SELL_3");

                     Alert(get_vntime(), " SELL: ", symbol, "   price: ", price, "    vol:", volume);
                    }

                 }

              }
           }
        }
     }
  }


//---------------Training Stop: 1R, TP: 2R hoặc BB của H4;-------------------------------
void TrailingStop()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         double profit = m_position.Profit();
         double risk_per_trade = calcRiskPerTrade();
         // ---------------------------------------------------------------------
         int length = 55;
         double close_prices_15[55];
         for(int i = length - 1; i >= 0; i--)
           {
            close_prices_15[i] = iClose(m_position.Symbol(), PERIOD_M15, i);// PERIOD_M15
           }
         double ma20_of_m15 = CalculateMA(close_prices_15, 20);
         double close_price = close_prices_15[1];
         if(m_position.Type()  == POSITION_TYPE_BUY)
           {
            if(ma20_of_m15 < close_price)
              {
               m_trade.PositionClose(m_position.Ticket());
              }
           }
         if(m_position.Type()  == POSITION_TYPE_SELL)
           {
            if(ma20_of_m15 > close_price)
              {
               m_trade.PositionClose(m_position.Ticket());
              }
           }
         // ---------------------------------------------------------------------
         if(profit > risk_per_trade)
           {
            if(m_position.Type()  == POSITION_TYPE_BUY)
              {
               m_trade.PositionModify(m_position.Ticket(), m_position.PriceOpen(), m_position.TakeProfit());
              }

            if(m_position.Type()  == POSITION_TYPE_SELL)
              {
               m_trade.PositionModify(m_position.Ticket(), m_position.PriceOpen(), m_position.TakeProfit());
              }
           }
        }
     } //for
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanTrade(string symbol)
  {
   double total_profit = 0;
   int count_possion = 0;
   string possion_comments = "";
   string order_comments = "";
   string type = "";

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         string trading_symbol = toLower(m_position.Symbol());
         if(toLower(symbol) == trading_symbol)
           {
            count_possion += 1;
            total_profit += m_position.Profit();
            type = m_position.TypeDescription();
            possion_comments += m_position.Comment() + "; ";
           }
        }
     } //for

   int count_orders = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            count_orders += 1;
            order_comments += m_order.Comment() + "; ";
           }
        }
     }

   if(count_possion + count_orders > 0)
     {
      //Alert(TimeGMT(), "Opening: ", type, "    ", symbol, "    possion_comments: ", possion_comments, "    order_comments: ", order_comments);
     }

//-------------------------------------------------------------------------
// Trường hợp: Tất cả các lệnh LIMIT được mở & không thua -> đóng tất cả lệnh, đánh hòa.
   if((total_profit > 0) && (count_orders == 0))
     {
      ClosePosition(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp: các lệnh đang mở được đóng (do TP, hoặc đóng bằng tay) -> thì đóng tất cả các lệnh Orders
   if((count_possion == 0) && (count_orders > 0))
     {
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BUY_3/SELL_3 được đóng -> đóng tất cả Positions(No.1, No.2) & Orders
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BUY_3") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "SELL_3") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BUY_2/SELL_2 được đóng -> đóng tất cả Positions(No.1) & Orders(Mo.3)
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BUY_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "SELL_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double calcRiskPerTrade()
  {
   double risk_per_trade = format_double(calcRisk(dbRiskRatio, INIT_EQUITY), 2);
   risk_per_trade = 2.0; // USD

   return risk_per_trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string checkMovingAverages(double& close_prices[])
  {
   if(ArraySize(close_prices) < 50)
     {
      return false;
     }

// Tính toán giá trị MA(10), MA(20), và MA(50)
   double ma10 = CalculateMA(close_prices, 10);
   double ma20 = CalculateMA(close_prices, 20);
   double ma50 = CalculateMA(close_prices, 50);

// Kiểm tra điều kiện
   if((ma10 > ma20) && (ma20 > ma50))
     {
      return TREND_BUY;
     }

   if((ma10 < ma20) && (ma20 < ma50))
     {
      return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 10; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      totalHeight += candleHeight;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / 10.0;

   return averageHeight;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLowestLowCandleM1(string symbol, int length)
  {
   double lowestLow = iLow(symbol, PERIOD_M1, 0);

   for(int i = 1; i < length; i++)
     {
      double low = iLow(symbol, PERIOD_M1, i);
      if(low < lowestLow)
         lowestLow = low;
     }

   return lowestLow;
  }

// Hàm lấy giá cao nhất của 50 cây nến 1 phút
double GetHighestHighCandleM1(string symbol, int length)
  {
   double highestHigh = iHigh(symbol, PERIOD_M1, 0);

   for(int i = 1; i < length; i++)
     {
      double high = iHigh(symbol, PERIOD_M1, i);
      if(high > highestHigh)
         highestHigh = high;
     }

   return highestHigh;
  }

//+------------------------------------------------------------------+
string GetTrendByPricePosition(string symbol)
  {
   int maLength = 120;
   double closePrices[120];
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, PERIOD_M1, i);
     }
   double higestClose = FindMaxPrice(closePrices);
   double lowestClose = FindMinPrice(closePrices);
   double currentPrice = iClose(symbol, PERIOD_M1, 0);

   double range = higestClose - lowestClose;
   double upperThreshold = higestClose - (range / 2);
   double lowerThreshold = lowestClose + (range / 2);

   if(currentPrice < lowerThreshold)
      return "B";
   else
      if(currentPrice > upperThreshold)
         return "S";
      else
         return "";
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindMinPrice(const double& prices[])
  {
   double minPrice = prices[0];

   for(int i = 1; i < ArraySize(prices); ++i)
     {
      if(prices[i] < minPrice)
        {
         minPrice = prices[i];
        }
     }

   return minPrice;
  }

// Function to find the maximum value in an array
double FindMaxPrice(const double& prices[])
  {
   double maxPrice = prices[0];

   for(int i = 1; i < ArraySize(prices); ++i)
     {
      if(prices[i] > maxPrice)
        {
         maxPrice = prices[i];
        }
     }

   return maxPrice;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA(double& prices[], int period)
  {
   double ma = 0.0;

// Tính tổng của giá đóng cửa của period nến gần nhất
   for(int i = 0; i < period; i++)
     {
      ma += prices[i];
     }

// Chia tổng cho số lượng nến để tính trung bình
   ma /= period;

   return ma;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + " ";
   return vntime;
  }

//+------------------------------------------------------------------+
//https://www.babypips.com/tools/forex-market-hours
//+------------------------------------------------------------------+
bool IsMarketClose()
  {
// Lấy giờ hiện tại theo múi giờ GMT
   datetime currentGMTTime = TimeGMT();

// Get the day of the week
   MqlDateTime dtw;
   TimeToStruct(currentGMTTime, dtw);
   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dtw.day_of_week;

// Check if the current day is Saturday or Sunday
   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
     {
      return true; // It's the weekend
     }

//+-----------------------------------

// Chênh lệch giờ giữa GMT và múi giờ Việt Nam
   int gmtOffset = 7;
   datetime vietnamTime = currentGMTTime + gmtOffset * 3600;

   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
// Lấy giờ từ cấu trúc datetime
   int currentHour = dt.hour;
   if(3 <= currentHour && currentHour <= 7)
     {
      return true; //VietnamEarlyMorning
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk(double dbRiskRatio, double INIT_EQUITY)
  {
   double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

   double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;

   if(dbValueRisk > 200)
     {
      Alert("(", BOT_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than 200 per order. Too dangerous.");
      return 200;
     }
   return dbValueRisk;
  }
//+------------------------------------------------------------------+
// Calculate Max Lot Size based on Maximum Risk
//+------------------------------------------------------------------+
double dblLotsRisk(string symbol, double dbAmp, double dbRiskByUsd)
  {
   double dbLotsMinimum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double dbLotsMaximum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double dbLotsStep     = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double dbTickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize < 0.01)
      roundedLotSize = 0.01;

   return roundedLotSize;
  }
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            m_trade.PositionClose(m_position.Ticket());
           }
        }
     } //for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders(string symbol)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            m_trade.OrderDelete(m_order.Ticket());
           }
        }
     }
  }
//+------------------------------------------------------------------+


// Hàm tính toán Bollinger Bands
// double deviation = 2; // Độ lệch chuẩn cho Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits, double deviation = 2)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands

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
      upper[i] = format_double(upper_i, digits);
      lower[i] = format_double(lower_i, digits);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_profit_today()
  {
   MqlDateTime date_time;
   TimeToStruct(TimeGMT(), date_time);
   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;
   int row_count = 0;
// --------------------------------------------------------------------
// --------------------------------------------------------------------
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   HistorySelect(0, TimeGMT()); // today closed trades PL
   int orders = HistoryDealsTotal();

   double PL = 0.0;
   for(int i = orders - 1; i >= 0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         break;
        }

      string symbol  = HistoryDealGetString(ticket,   DEAL_SYMBOL);
      if(symbol == "")
        {
         continue;
        }

      double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
      if(profit != 0)  // If deal is trade exit with profit or loss
        {
         MqlDateTime deal_time;
         TimeToStruct(HistoryDealGetInteger(ticket, DEAL_TIME), deal_time);

         // If is today deal
         if(deal_time.day == current_day && deal_time.mon == current_month && deal_time.year == current_year)
           {
            PL += profit;
           }
         else
            break;
        }
     }

   double starting_balance = current_balance - PL;
   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double loss = current_equity - starting_balance;

   return loss;
  }

//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {

   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
string AppendSpaces(string inputString, int totalLength = 10, bool is_append_right = true)
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

      if(is_append_right)
        {
         return (inputString + spaces);
        }
      else
        {
         return (spaces + inputString);
        }

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(symbol, TIME_FRAME, candle_index, haOpen0, haClose0, haHigh0, haLow0);

   string result = "";
   if(haOpen0 < haClose0)
     {
      result = TREND_BUY;
     }
   else
     {
      result = TREND_SEL;
     }

   return result;
  }


// Hàm tính toán giá trị của nến Heiken Ashi
void CalculateHeikenAshi(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int index, double &haOpen, double &haClose, double &haHigh, double &haLow)
  {
// Lấy giá trị của nến trước đó
   double prevHaOpen = iOpen(symbol, TIME_FRAME, index + 1);
   double prevHaClose = iClose(symbol, TIME_FRAME, index + 1);
   double prevHaHigh = iHigh(symbol, TIME_FRAME, index + 1);
   double prevHaLow = iLow(symbol, TIME_FRAME, index + 1);

// Tính toán giá trị của nến Heiken Ashi
   haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
   haOpen = (prevHaOpen + prevHaClose) / 2.0;
   haHigh = MathMax(iOpen(symbol, TIME_FRAME, index), MathMax(haClose, prevHaHigh));
   haLow = MathMin(iOpen(symbol, TIME_FRAME, index), MathMin(haClose, prevHaLow));
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
string get_trend_by_macd(string symbol, double& closePrices[])
  {
//int maLength = 50;
//double closePrices[50];
//ENUM_TIMEFRAMES TIME_FRAME;
//for(int i = maLength - 1; i >= 0; i--)
//  {
//   closePrices[i] = iClose(symbol, TIME_FRAME, i);
//  }

   double macd[];
   double signalLine[];
   int shortTermPeriod = 3;
   int longTermPeriod = 6;
   int signalPeriod = 9;
   CalculateMACDandSignal(closePrices, shortTermPeriod, longTermPeriod, signalPeriod, macd, signalLine);

   string result = "";
   double signal = signalLine[0];
   if(signal > 0)
     {
      result = TREND_BUY;
     }
   else
     {
      result = TREND_SEL;
     }

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_signal_macd(string symbol, double& closePrices[])
  {

   double macd[];
   double signalLine[];
   int shortTermPeriod = 3;
   int longTermPeriod = 6;
   int signalPeriod = 9;
   CalculateMACDandSignal(closePrices, shortTermPeriod, longTermPeriod, signalPeriod, macd, signalLine);

   string result = "";
   double signal = signalLine[0];

   return signal;
  }

// Hàm tính toán MACD và Signal Line
void CalculateMACDandSignal(double& prices[], int shortTermPeriod, int longTermPeriod, int signalPeriod, double& macd[], double& signal[])
  {
// Tính toán EMA ngắn hạn và dài hạn
   double emaShort[];
   double emaLong[];

   CalculateEMA(prices, emaShort, shortTermPeriod);
   CalculateEMA(prices, emaLong, longTermPeriod);

// Tính toán MACD
   ArrayResize(macd, ArraySize(prices));

   for(int i = 0; i < ArraySize(prices); i++)
     {
      macd[i] = emaShort[i] - emaLong[i];
     }

// Tính toán Signal Line
   CalculateSMA(macd, signal, signalPeriod);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//string log_msg = AppendSpaces(symbol) + AppendSpaces(TimeframeToString(TIME_FRAME)) + "\n";
//double ema[];
//CalculateEMA(closePrices, ema, 9);
//for(int index = 0; index < ArraySize(ema); index++)
//  {
//   log_msg += AppendSpaces("Bar " + (string) index);
//   log_msg += "  ema9: " + AppendSpaces(format_double_to_string(ema[index])) + "\n";
//  }
//log_msg += "\n\n\n";

// Hàm tính toán EMA -> TEST OK
void CalculateEMA(double& prices[], double& ema[], int period)
  {
   int maLength = ArraySize(prices);
   double smoothingFactor = 2.0 / (period + 1);

   ArrayResize(ema, maLength);

   CalculateSMA(prices, ema, period);

   for(int i = maLength - period; i > 0; i--)
     {
      double currentPrice = prices[i];
      double previousEMA = ema[i - 1];
      ema[i] = format_double((currentPrice * smoothingFactor) + (previousEMA * (1-smoothingFactor)), 5);
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Hàm tính toán Simple Moving Average (SMA) -> TEST OK
//string log_msg = AppendSpaces(symbol) + AppendSpaces(TimeframeToString(TIME_FRAME)) + "\n";
//double sma[];
//CalculateSMA(closePrices, sma, 9);
//for(int index = 0; index < ArraySize(sma); index++)
//  {
//   log_msg += AppendSpaces("Bar " + (string) index);
//   log_msg += "  sma9: " + AppendSpaces(format_double_to_string(sma[index])) + "\n";
//  }
//log_msg += "\n\n\n
void CalculateSMA(double& prices[], double& sma[], int period)
  {
   int maLength = ArraySize(prices);
   ArrayResize(sma, maLength);
   for(int i = 0; i<maLength ; i++)
     {
      sma[i] = 0;
     }

   for(int i = 0; i < maLength - period; i++)
     {
      double sum = 0;
      for(int j = i; j < i + period; j++)
        {
         sum += prices[j];
        }
      sma[i] = sum / period;
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
