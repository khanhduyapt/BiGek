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

string INDI_NAME = "GuardianAngel";
double dbRiskRatio = 0.02; // Rủi ro 10% = 100$/lệnh
double INIT_EQUITY = 50.0; // Vốn đầu tư

string arr_symbol[] =
  {
   "XAUUSD", "XAGUSD", "USOIL.cash", "BTCUSD",
   "US100.cash", "US30.cash", "US500.cash", "GER40.cash", "UK100.cash", "FRA40.cash", "AUS200.cash",
   "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
   "CADCHF", "CADJPY", "CHFJPY",
   "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
   "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
   "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
   "USDCAD", "USDCHF", "USDJPY"
  };

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string PREFIX_TRADE_PERIOD_W1 = "W1";
string PREFIX_TRADE_PERIOD_D1 = "D1";
string PREFIX_TRADE_PERIOD_H4 = "H4";
string PREFIX_TRADE_VECHAI_H1 = "H1";
string PREFIX_TRADE_VECHAI_M15 = "M15";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      SetSL(symbol);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSL(string symbol)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
            double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);

            ulong ticket = m_position.Ticket();
            double sl = m_position.StopLoss();
            double tp = m_position.TakeProfit();
            double price_open = m_position.PriceOpen();
            double profit = m_position.Profit();
            string comments = m_position.Comment();

            string TRADING_TREND = "";
            if(toLower(m_position.TypeDescription()) == toLower(TREND_BUY))
               TRADING_TREND = TREND_BUY;

            if(toLower(m_position.TypeDescription()) == toLower(TREND_SEL))
               TRADING_TREND = TREND_SEL;

            ENUM_TIMEFRAMES TRADE_PERIOD = get_period(comments);

            if(sl == 0)
              {
               double lowest = 0.0;
               double higest = 0.0;
               for(int i = 1; i <= 15; i++)
                 {
                  double lowPrice = iLow(symbol,  TRADE_PERIOD, i);
                  double higPrice = iHigh(symbol, TRADE_PERIOD, i);

                  if((i == 1) || (lowest > lowPrice))
                     lowest = lowPrice;

                  if((i == 1) || (higest < higPrice))
                     higest = higPrice;
                 }


               if(TRADING_TREND == TREND_BUY)
                 {
                  double amp_sl = (price - lowest);
                  double sl_new = price_open - amp_sl;
                  if(sl_new < price)
                    {
                     m_trade.PositionModify(ticket, NormalizeDouble(sl_new, digits), tp);
                     Alert(get_vntime(), "   INIT   SL   (BUY) : ", symbol, "   sl_new: ", (string)sl_new);
                    }
                 }

               if(TRADING_TREND == TREND_SEL)
                 {
                  double amp_sl = (higest - price);
                  double sl_new = price_open + amp_sl;

                  if(sl_new > price)
                    {
                     m_trade.PositionModify(ticket, NormalizeDouble(sl_new, digits), tp);
                     Alert(get_vntime(), "   INIT   SL   (SELL): ", symbol, "   sl_new: ", (string)sl_new);
                    }
                 }
              }


            if(sl > 0)
              {
               double amp_trade = get_amp_trade(symbol, PERIOD_CURRENT);

               double haOpen1, haClose1, haHigh1, haLow1;
               CalculateHeikenAshi(symbol, TRADE_PERIOD, 1, haOpen1, haClose1, haHigh1, haLow1);

               double haOpen2, haClose2, haHigh2, haLow2;
               CalculateHeikenAshi(symbol, TRADE_PERIOD, 2, haOpen2, haClose2, haHigh2, haLow2);

               if(TRADING_TREND == TREND_BUY)
                 {
                  double sl_by_amp = price_open - amp_trade;
                  if(haClose1 <= sl_by_amp && haClose2 <= sl_by_amp)
                    {
                     Alert(get_vntime(), "  STOP_LOSS  (BUY)  ", symbol, "   Profit: ", profit, "$");
                    }
                 }

               if(TRADING_TREND == TREND_SEL)
                 {
                  double sl_by_amp = price_open + amp_trade;
                  if(haClose1 >= sl_by_amp && haClose2 >= sl_by_amp)
                    {
                     Alert(get_vntime(), "  STOP_LOSS  (SELL) ", symbol, "   Profit: ", profit, "$");
                    }
                 }

              }

           }
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_amp_trade(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double amp_trade = week_amp / 2;
   if(TIMEFRAME == PERIOD_H4)
      amp_trade = week_amp / 4;
   if(TIMEFRAME == PERIOD_H1 || TIMEFRAME == PERIOD_M15)
      amp_trade = week_amp / 8;

   return amp_trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_period(string comments)
  {
   string TRADE_PERIOD = "";
   string low_comments =toLower(comments);

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_W1)) >= 0)
      return PERIOD_W1;
   else
      if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
         return PERIOD_D1;
      else
         if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
            return PERIOD_H4;
         else
            if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_H1)) >= 0)
               return PERIOD_H1;
            else
               if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_M15)) >= 0)
                  return PERIOD_M15;


   return PERIOD_M15;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk()
  {
   double dbValueRisk = INIT_EQUITY * dbRiskRatio;
   double max_risk = INIT_EQUITY*0.1;
   if(dbValueRisk > max_risk)
     {
      Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than " + (string) max_risk + " per order. Too dangerous.");
      return max_risk;
     }

   return dbValueRisk;
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
string get_vntime()
  {
   string cpu = "";
   string inputString = TerminalInfoString(TERMINAL_CPU_NAME);
   string startString = "Core ";
   string endString = " @";
   int startIndex = StringFind(inputString, startString) + 5;
   int endIndex = StringFind(inputString, endString);
   if(startIndex != -1 && endIndex != -1)
     {
      cpu = StringSubstr(inputString, startIndex, endIndex - startIndex);
     }
   StringReplace(cpu, "i5-", "");

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + "   (GMT: " + current_gmt_hour + "h) ";
   return vntime;
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
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &avg_candle_week, double &dic_amp_init_d1)
  {
   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.1;
      amp_w = 1357.35;
      avg_candle_week = 3697.32;
      return;
     }

   if(symbol == "USOIL.cash")
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.08;
      amp_w = 2.75;
      avg_candle_week = 5.606;
      return;
     }

   if(symbol == "XAGUSD")
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.07;
      amp_w = 0.63500;
      avg_candle_week = 1.396;
      return;
     }

   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.033;
      amp_w = 27.83;
      avg_candle_week = 65.93;
      return;
     }

   if(symbol == "US500.cash")
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.035;
      amp_w = 60.00;
      avg_candle_week = 593.00;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.07;
      amp_w = 274.5;
      avg_candle_week = 503.15;
      return;
     }

   if(symbol == "US30.cash")
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.04;
      amp_w = 438.76;
      avg_candle_week = 818.86;
      return;
     }

   if(symbol == "UK100.cash")
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.033;
      amp_w = 95.38;
      avg_candle_week = 946.88;
      return;
     }

   if(symbol == "GER40.cash")
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.045;
      amp_w = 222.45;
      avg_candle_week = 2205.075;
      return;
     }

   if(symbol == "FRA40.cash")
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 160;
      amp_w = 117.6866;
      avg_candle_week = 1145.95;
      return;
     }

   if(symbol == "AUS200.cash")
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 236.5;
      amp_w = 93.59;
      avg_candle_week = 932.99;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.025;
      amp_w = 1.100;
      avg_candle_week = 2.097;
      return;
     }

   if(symbol == "AUDUSD")
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03  ;
      amp_w = 0.0075;
      avg_candle_week = 0.01481;
      return;
     }

   if(symbol == "EURAUD")
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 0.01365;
      avg_candle_week = 0.02593;
      return;
     }

   if(symbol == "EURGBP")
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.01  ;
      amp_w = 0.00497;
      avg_candle_week = 0.00816;
      return;
     }

   if(symbol == "EURUSD")
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02 ;
      amp_w = 0.0080;
      avg_candle_week = 0.01773;
      return;
     }

   if(symbol == "GBPUSD")
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      avg_candle_week = 0.02180;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.015;
      amp_w = 0.00795;
      avg_candle_week = 0.01907;
      return;
     }

   if(symbol == "USDCHF")
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.03  ;
      amp_w = 0.00750;
      avg_candle_week = 0.01586;
      return;
     }

   if(symbol == "USDJPY")
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.025 ;
      amp_w = 1.4250;
      avg_candle_week = 3.240;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 0.00515;
      avg_candle_week = 0.00894;
      return;
     }

   if(symbol == "CADJPY")
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 1.0250;
      avg_candle_week = 2.298;
      return;
     }

   if(symbol == "CHFJPY")
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.023  ;
      amp_w = 1.365000;
      avg_candle_week = 3.451;
      return;
     }

   if(symbol == "EURJPY")
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 1.43500;
      avg_candle_week = 3.31;
      return;
     }

   if(symbol == "GBPJPY")
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 1.61500;
      avg_candle_week = 3.973;
      return;
     }

   if(symbol == "NZDJPY")
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.03  ;
      amp_w = 0.90000;
      avg_candle_week = 1.946;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 0.00945;
      avg_candle_week = 0.01895;
      return;
     }

   if(symbol == "EURCHF")
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      avg_candle_week = 0.01156;
      return;
     }

   if(symbol == "EURNZD")
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02 ;
      amp_w = 0.01585;
      avg_candle_week = 0.02848;
      return;
     }

   if(symbol == "GBPAUD")
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.025;
      amp_w = 0.01575;
      avg_candle_week = 0.02700;
      return;
     }

   if(symbol == "GBPCAD")
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      avg_candle_week = 0.02005;
      return;
     }

   if(symbol == "GBPCHF")
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.015  ;
      amp_w = 0.0085;
      avg_candle_week = 0.01625;
      return;
     }

   if(symbol == "GBPNZD")
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 0.016250;
      avg_candle_week = 0.02895;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.015  ;
      amp_w = 0.0075;
      avg_candle_week = 0.01345;
      return;
     }

   if(symbol == "AUDCHF")
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.03 ;
      amp_w = 0.005805;
      avg_candle_week = 0.01076;
      return;
     }

   if(symbol == "AUDNZD")
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.015 ;
      amp_w = 0.00595;
      avg_candle_week = 0.01017;
      return;
     }

   if(symbol == "NZDCAD")
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02  ;
      amp_w = 0.007200;
      avg_candle_week = 0.01275;
      return;
     }

   if(symbol == "NZDCHF")
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.025  ;
      amp_w = 0.00515;
      avg_candle_week = 0.00988;
      return;
     }

   if(symbol == "NZDUSD")
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      avg_candle_week = 0.01388;
      return;
     }


   i_top_price = iClose(symbol, PERIOD_W1, 1);
   dic_amp_init_d1 = 0.02;
   amp_w = MathAbs(iHigh(symbol, PERIOD_W1, 1) - iLow(symbol, PERIOD_W1, 1));
   avg_candle_week = amp_w;

   return;
  }
//+------------------------------------------------------------------+
