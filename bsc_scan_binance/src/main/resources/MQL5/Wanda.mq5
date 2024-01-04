//+------------------------------------------------------------------+
//|                                                        Wanda.mq5 |
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string INDI_NAME = "Wanda";
double dbRiskRatio = 0.1; // Rủi ro 10% = 100$/lệnh
double INIT_EQUITY = 1000.0; // Vốn đầu tư

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string arr_symbol[] = {"XAUUSD", "XAGUSD"
                       ,"BTCUSD"
                       ,"US30.cash", "US100.cash", "US500.cash", "USOIL.cash"
                       ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
                       ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
                       ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
                       ,"NZDCAD", "NZDJPY", "NZDUSD"
                       ,"USDCAD", "USDJPY", "CADJPY"
                       , "USDCHF", "CADCHF", "CHFJPY", "EURCHF", "GBPCHF", "AUDCHF", "NZDCHF"
                      };

string TRADE_PERIOD_W1 = "W1";
string TRADE_PERIOD_D1 = "D1";
string TRADE_PERIOD_H4 = "H4";
string TRADE_VECHAI_H1 = "H1";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TRADE_COUNT_ORDER = " Order";
string TRADE_COUNT_ORDER_B = TRADE_COUNT_ORDER + " (B):";
string TRADE_COUNT_ORDER_S = TRADE_COUNT_ORDER + " (S):";
string TRADE_COUNT_POSITION = " Position";
string TRADE_COUNT_POSITION_B = TRADE_COUNT_POSITION + " (B):";
string TRADE_COUNT_POSITION_S = TRADE_COUNT_POSITION + " (S):";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SendTelegramMessage(_Symbol, TREND_BUY, "HELLO_" + _Symbol);

   WriteNotifyToken();
   EventSetTimer(900); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
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
//Gold_Miner("XAUUSD");
   WriteNotifyToken();
  }

//+------------------------------------------------------------------+
void Gold_Miner(string symbol)
  {
   double risk_10_usd_per_trade_h1 = 10;

   ClosePositionByRisk(symbol, TRADE_VECHAI_H1, risk_10_usd_per_trade_h1);

//int candle_swith_trend = get_candle_switch_trend_stoch(symbol, PERIOD_H1, 9, 6, 3, 0);
//if(candle_swith_trend > 3)
//   return;

   string trend_h1_by_stoc_963 = get_trend_by_stoc963(symbol, PERIOD_H1);

   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, trend_h1_by_stoc_963, 3, 2, 3)== false)
      return;

   if(trend_h1_by_stoc_963 != get_trend_by_adx_dmi(symbol, PERIOD_H1, 9))
      return;

   if(is_must_exit_trade_by_stoch323(symbol, PERIOD_H1, trend_h1_by_stoc_963))
      return;

   if(trend_h1_by_stoc_963 != get_trend_by_stoc323(symbol, PERIOD_H4))
      return;

   if(trend_h1_by_stoc_963 != get_trend_by_stoc323(symbol, PERIOD_M15))
      return;

   if(trend_h1_by_stoc_963 != get_trend_by_vector_macd369(symbol, PERIOD_M15))
      return;

   bool sharks_same_direction = is_allow_trade_now_by_adx_dmi(symbol, PERIOD_M15, 9, trend_h1_by_stoc_963);
   if(sharks_same_direction == false)
      return;

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week);
   double week_amp = dic_amp_w;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int length = 15;
   double min_height = 0.0;
   double lowest = 0.0;
   double higest = 0.0;
   for(int i = 0; i < length; i++)
     {
      double lowPrice = iLow(symbol, PERIOD_H1, i);
      double higPrice = iHigh(symbol, PERIOD_H1, i);
      double candleHeight = MathAbs(higPrice - lowPrice);

      if((i == 0) || (min_height > candleHeight))
         min_height = candleHeight;

      if((i == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((i == 0) || (higest < higPrice))
         higest = higPrice;
     }

   double sl_buy = lowest - min_height;
   double sl_sel = higest + min_height;
   double tp_buy = price + week_amp;
   double tp_sel = price - week_amp;

   double amp_trade = min_height * 5;

   if(trend_h1_by_stoc_963 == TREND_BUY)
      amp_trade = MathAbs(price - sl_buy);
   if(trend_h1_by_stoc_963 == TREND_SEL)
      amp_trade = MathAbs(price - sl_sel);

   double volume = dblLotsRisk(symbol, amp_trade, risk_10_usd_per_trade_h1);

   if(is_open_trade_this_candle_h4(symbol, trend_h1_by_stoc_963) == false)
     {
      add_open_trade_this_candle_h4(symbol, trend_h1_by_stoc_963);

      if(trend_h1_by_stoc_963 == TREND_BUY)
        {
         m_trade.Buy(volume, symbol, 0.0, 0.0, tp_buy, TRADE_VECHAI_H1);
        }

      if(trend_h1_by_stoc_963 == TREND_SEL)
        {
         m_trade.Sell(volume, symbol, 0.0, 0.0, tp_sel, TRADE_VECHAI_H1);
        }
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol, string trend, string message)
  {
   if(is_open_trade_this_candle_h4("MSG_TO_TELEGRAM_" + symbol, trend))
      return;
   add_open_trade_this_candle_h4("MSG_TO_TELEGRAM_" + symbol, trend);

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

//string new_message = "Hello this is a test message from your MQL5 bot";
   string new_message = message;
   StringReplace(new_message, " ", "_");
   StringReplace(new_message, ":", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");

   string base_url="https://api.telegram.org";
   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s", base_url, botToken, chatId_duydk, new_message);

//Alert(url);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout = 60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
     {
      Alert("Error in WebRequest. Error code ", GetLastError(), ", URL: ", url, ", Headers: ", headers, "   ", MB_ICONERROR);
     }
   else
     {
      if(res==200)
        {
         //--- Successful
         //Alert("Successful, Result size %d byte.",ArraySize(result));
        }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void WriteNotifyToken()
  {
   double risk_per_trade = calcRisk();

   string week_swith_trend = "";
   string msg_open_trade_w1 = "";
   string msg_open_trade_d1 = "";
   string msg_open_trade_h4 = "";
   string msg_open_trade_h1 = "";
   string msg_open_trade_by_amp_10w = "";

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);


      string str_count_trade = CountTrade(symbol);
      if(str_count_trade != "" && StringFind(str_count_trade, TRADE_COUNT_POSITION) >= 0)
         Clean_Trade(symbol);

      bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
      bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
      bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
      bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

      //------------------------------------------------------------------
      double dic_top_price;
      double dic_amp_w;
      double dic_avg_candle_week;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week);
      double week_amp = dic_amp_w;

      double volume = dblLotsRisk(symbol, week_amp, risk_per_trade);
      string str_volume = " Vol: " + format_double_to_string(volume, 2) +  "/" + (string) risk_per_trade + "$";
      //------------------------------------------------------------------

      CandleData candle_heiken_h4;
      CountHeikenList(symbol, PERIOD_H4, 1, candle_heiken_h4);

      CandleData candle_heiken_h1;
      CountHeikenList(symbol, PERIOD_H1, 1, candle_heiken_h1);

      string trend_heiken_h1_1 = candle_heiken_h1.trend;
      string trend_heiken_h1_0 = get_trend_by_heiken(symbol, PERIOD_H1, 0);
      string trend_heiken_15_0 = get_trend_by_heiken(symbol, PERIOD_M15, 0);
      bool h1_m15_allow_trade = trend_heiken_h1_1 == trend_heiken_h1_0 && trend_heiken_h1_1 == trend_heiken_15_0;

      string trend_w1_by_stoc_323 = get_trend_by_stoc323(symbol, PERIOD_W1);
      string trend_d1_by_stoc_323 = get_trend_by_stoc323(symbol, PERIOD_D1);
      string trend_h4_by_stoc_323 = get_trend_by_stoc323(symbol, PERIOD_H4);


      bool w1_alow_trade_now = is_allow_trade_now_by_stoc(symbol, PERIOD_W1, trend_w1_by_stoc_323, 3, 2, 3)
                               || is_allow_trade_now_by_stoc(symbol, PERIOD_W1, trend_w1_by_stoc_323, 9, 6, 3);

      bool d1_alow_trade_now = is_allow_trade_now_by_stoc(symbol, PERIOD_D1, trend_w1_by_stoc_323, 3, 2, 3);
      bool h4_alow_trade_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, trend_w1_by_stoc_323, 3, 2, 3);

      bool w1_must_exit_trade = is_must_exit_trade_by_stoch323(symbol, PERIOD_W1, trend_w1_by_stoc_323);
      bool d1_must_exit_trade = is_must_exit_trade_by_stoch323(symbol, PERIOD_D1, trend_w1_by_stoc_323);
      bool h4_must_exit_trade = is_must_exit_trade_by_stoch323(symbol, PERIOD_H4, trend_w1_by_stoc_323);

      if(trend_w1_by_stoc_323 == trend_d1_by_stoc_323 && trend_w1_by_stoc_323 == trend_h4_by_stoc_323 && trend_w1_by_stoc_323 == trend_heiken_h1_1 && h1_m15_allow_trade)
        {
         if(w1_alow_trade_now && (d1_must_exit_trade == false) && (h4_must_exit_trade == false))
           {
            msg_open_trade_w1 += "  W1     " + AppendSpaces(trend_w1_by_stoc_323) + symbol + str_volume;
            string msg = " (OPEN_TRADE) W1: " + trend_w1_by_stoc_323 + "    " + symbol + str_volume;

            Notify_Open_Trade(symbol, trend_w1_by_stoc_323, msg);
            SendTelegramMessage(symbol, trend_w1_by_stoc_323, msg);
           }

         if(d1_alow_trade_now && (w1_must_exit_trade == false) && (h4_must_exit_trade == false))
           {
            msg_open_trade_d1 += "  D1     " + AppendSpaces(trend_w1_by_stoc_323) + symbol + str_volume;
            string msg = " (OPEN_TRADE) D1: " + trend_w1_by_stoc_323 + "    " + symbol + str_volume;

            Notify_Open_Trade(symbol, trend_w1_by_stoc_323, msg);
            SendTelegramMessage(symbol, trend_w1_by_stoc_323, msg);
           }

         if(h4_alow_trade_now && (w1_must_exit_trade == false) && (d1_must_exit_trade == false))
           {
            msg_open_trade_h4 += "  H4     " + AppendSpaces(trend_w1_by_stoc_323) + symbol + str_volume;
            string msg = " (OPEN_TRADE) H4: " + trend_w1_by_stoc_323 + "    " + symbol + str_volume;

            Notify_Open_Trade(symbol, trend_w1_by_stoc_323, msg);
            SendTelegramMessage(symbol, trend_w1_by_stoc_323, msg);
           }
        }

      string trend_by_amp_10_weeks = get_trend_by_amp(symbol, PERIOD_W1, 10);
      if(trend_by_amp_10_weeks != "")
        {
         string wdh4 = "";
         if(w1_alow_trade_now && trend_w1_by_stoc_323 == trend_by_amp_10_weeks)
            wdh4 += " W1 ";
         if(w1_alow_trade_now && trend_d1_by_stoc_323 == trend_by_amp_10_weeks)
            wdh4 += " D1 ";
         if(w1_alow_trade_now && trend_h4_by_stoc_323 == trend_by_amp_10_weeks)
            wdh4 += " H4 ";

         if(wdh4 != "")
           {
            msg_open_trade_by_amp_10w += "  10W  " + AppendSpaces(wdh4, 18) + AppendSpaces(trend_by_amp_10_weeks) + AppendSpaces(symbol, 15) + str_count_trade + "\n";

            string msg = " (OPEN_TRADE) 10W: " + trend_by_amp_10_weeks + "    " + symbol + str_volume + wdh4;

            if(str_count_trade == "")
              {
               Notify_Open_Trade(symbol, trend_by_amp_10_weeks, msg);
               SendTelegramMessage(symbol, trend_by_amp_10_weeks, msg);
              }
           }
        }



      int candle_switch_trend_w1_by_stoc323 = get_candle_switch_trend_stoch(symbol, PERIOD_W1, 3, 2, 3, 1);
      int candle_switch_trend_w1_by_stoc963 = get_candle_switch_trend_stoch(symbol, PERIOD_W1, 9, 6, 3, 0);

      if(candle_switch_trend_w1_by_stoc323 <= 1 || candle_switch_trend_w1_by_stoc963 <= 1)
        {
         string trend_w1_by_stoc_963 = get_trend_by_stoc963(symbol, PERIOD_W1);

         if(w1_alow_trade_now || d1_alow_trade_now || h4_alow_trade_now)
           {
            string star = "             ";
            if(trend_w1_by_stoc_963 == trend_w1_by_stoc_323)
               star = "***       ";
            if(candle_switch_trend_w1_by_stoc323 <= 1 && candle_switch_trend_w1_by_stoc963 <= 1 && trend_w1_by_stoc_963 == trend_w1_by_stoc_323)
               star = "****** ";

            if(w1_alow_trade_now)
              {
               star += "    W1";
              }
            if(d1_alow_trade_now)
              {
               star += "    D1";
              }
            if(h4_alow_trade_now)
              {
               star += "    H4";
              }

            if(symbol == _Symbol)
               week_swith_trend += "*";
            else
               week_swith_trend += "  ";


            if(candle_switch_trend_w1_by_stoc323 <= 1 && candle_switch_trend_w1_by_stoc963 <= 1)
               week_swith_trend += "  W      " + AppendSpaces(trend_w1_by_stoc_323 + "("+(string)candle_switch_trend_w1_by_stoc323+")");
            else
               if(candle_switch_trend_w1_by_stoc323 <= 1)
                  week_swith_trend += "  W3    " + AppendSpaces(trend_w1_by_stoc_323 + "("+(string)candle_switch_trend_w1_by_stoc323+")");
               else
                  if(candle_switch_trend_w1_by_stoc963 <= 1)
                     week_swith_trend += "  W9    " + AppendSpaces(trend_w1_by_stoc_963 + "("+(string)candle_switch_trend_w1_by_stoc963+")");


            week_swith_trend +=  AppendSpaces(symbol, 15) + star +  "    " + str_count_trade + "\n";
           }
        }
      //-------------------------------------------------------------------------
     }

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_avg_candle_week);
   double week_amp = dic_amp_w;
   string volume = (string) dblLotsRisk(_Symbol, week_amp, risk_per_trade);

   string range_price = "";
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double target_price = adjust_target_price(price, dic_top_price, dic_amp_w);
   if(price < target_price)
      range_price = format_double_to_string(target_price-dic_amp_w, digits) + "~" + format_double_to_string(target_price, digits);
   else
      range_price = format_double_to_string(target_price, digits) + "~" + format_double_to_string(target_price + dic_amp_w, digits);

   CandleData candle_heiken_h4;
   CountHeikenList(_Symbol, PERIOD_H4, 1, candle_heiken_h4);

   CandleData candle_heiken_h1;
   CountHeikenList(_Symbol, PERIOD_H1, 1, candle_heiken_h1);

   string str_comments = get_vntime() + "(" + INDI_NAME + ") " + _Symbol;
   str_comments += "   Heiken (H4) " + candle_heiken_h4.trend + "("+(string)candle_heiken_h4.count+")";

   str_comments += "   Macd (H4) " + get_candle_switch_trend_macd369(_Symbol, PERIOD_H4);
   str_comments += " (H1)" + get_candle_switch_trend_macd369(_Symbol, PERIOD_H1);

   str_comments += "   Stoc (H4) " + get_trend_by_stoc323(_Symbol, PERIOD_H4);
   str_comments += " (H1)" + get_trend_by_stoc323(_Symbol, PERIOD_H1);

   str_comments += "   Amp(W): " + (string) dic_amp_w + " ~ " + (string) dic_amp_w + "  CandleWeek: " + (string) dic_avg_candle_week + "    Range: " + range_price + "$";
   str_comments += "   Adx: " + get_candle_switch_trend_adx(_Symbol,PERIOD_CURRENT,9);

   str_comments += "   Vol: " + volume + "/" + (string) risk_per_trade + "$/" + (string)(dbRiskRatio * 100) + "% ";


   if(msg_open_trade_by_amp_10w != "")
      str_comments += "\n\n\n" + msg_open_trade_by_amp_10w;

   if(msg_open_trade_w1 != "")
      str_comments += "\n\n\n" + msg_open_trade_w1;

   if(msg_open_trade_d1 != "")
      str_comments += "\n\n\n" + msg_open_trade_d1;

   if(msg_open_trade_h4 != "")
      str_comments += "\n\n\n" + msg_open_trade_h4;

   if(msg_open_trade_h1 != "")
      str_comments += "\n\n\n" + msg_open_trade_h1;

   if(week_swith_trend != "")
      str_comments += "\n\n\n" + week_swith_trend;

   Comment(str_comments);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Clean_Trade(string symbol)
  {
   double risk_per_trade = calcRisk();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();
            long type = m_position.Type();

            double sl = m_position.StopLoss();
            double tp = m_position.TakeProfit();
            double price_open = m_position.PriceOpen();

            double profit = m_position.Profit();
            string comments = m_position.Comment();

            bool has_profit = (profit > 0);

            string TRADING_TREND = get_trading_trend(type);

            string TRADE_PERIOD = get_trade_period(comments);

            // -------------------------TRAILING_STOP------------------------------
            if(profit > risk_per_trade)
              {
               double dic_top_price;
               double dic_amp_w;
               double dic_avg_candle_week;
               GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week);
               double week_amp = dic_amp_w;

               double price = SymbolInfoDouble(symbol, SYMBOL_BID);

               if(type == POSITION_TYPE_BUY && (price - price_open > week_amp) && (sl != price_open))
                 {
                  m_trade.PositionModify(ticket, price_open, tp);
                  Alert("TRAILING_STOP   (BUY): ", symbol);
                 }
               if(type == POSITION_TYPE_SELL && (price_open - price > week_amp) && (sl != price_open))
                 {
                  m_trade.PositionModify(ticket, price_open, tp);
                  Alert("TRAILING_STOP   (SEL): ", symbol);
                 }
              }
            // -------------------------TRAILING_STOP------------------------------

            // ---------------------------STOP_LOSS--------------------------------
            if(TRADE_PERIOD != "" && TRADING_TREND != "" && profit + risk_per_trade < 0)
              {
               Alert(get_vntime(), "   (STOP_LOSS) ", TRADING_TREND, "    ", symbol, "    Profit: " + (string)profit + "$");
              }
            // ---------------------------STOP_LOSS--------------------------------

            if(tp > 0)
               continue; // Đặt TP thì tự đóng bằng tay

            if(has_profit && TRADE_PERIOD != "" && TRADING_TREND != "" && (is_open_trade_this_candle_h4(symbol, TRADING_TREND) == false))
              {
               if(TRADE_PERIOD == TRADE_PERIOD_H4 && is_must_exit_trade_by_stoch323(symbol, PERIOD_H4, TRADING_TREND))
                 {
                  m_trade.PositionClose(ticket);
                  SendTelegramMessage(symbol, TRADING_TREND, "CLOSE_" + TRADING_TREND + "_" + symbol + "_Profit_"+ (string)profit);
                 }

               if(TRADE_PERIOD == TRADE_PERIOD_D1 && is_must_exit_trade_by_stoch323(symbol, PERIOD_D1, TRADING_TREND))
                 {
                  m_trade.PositionClose(ticket);
                  SendTelegramMessage(symbol, TRADING_TREND, "CLOSE_" + TRADING_TREND + "_" + symbol + "_Profit_"+ (string)profit);
                 }

               if(TRADE_PERIOD == TRADE_PERIOD_W1 && is_must_exit_trade_by_stoch323(symbol, PERIOD_W1, TRADING_TREND))
                 {
                  m_trade.PositionClose(ticket);
                  SendTelegramMessage(symbol, TRADING_TREND, "CLOSE_" + TRADING_TREND + "_" + symbol + "_Profit_"+ (string)profit);
                 }

               string trend_w1_by_stoc_323 = get_trend_by_stoc323(symbol, PERIOD_W1);
               if(trend_w1_by_stoc_323 != TRADING_TREND)
                 {
                  Alert(get_vntime(), "   (TREND_W1_REVERSE)   CLOSE: " + TRADING_TREND + "    " + symbol);
                 }
              }

            // --------------------------------------------------------
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trading_trend(long type)
  {
   if(type == POSITION_TYPE_BUY)
      return TREND_BUY;

   if(type == POSITION_TYPE_SELL)
      return TREND_SEL;

   if(type == ORDER_TYPE_BUY_LIMIT)
      return TREND_BUY;

   if(type == ORDER_TYPE_SELL_LIMIT)
      return TREND_SEL;

   return (string) type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trade_period(string comments)
  {
   string TRADE_PERIOD = "";
   if(StringFind(toLower(comments), toLower(TRADE_PERIOD_W1)) >= 0)
      TRADE_PERIOD = TRADE_PERIOD_W1;
   else
      if(StringFind(toLower(comments), toLower(TRADE_PERIOD_D1)) >= 0)
         TRADE_PERIOD = TRADE_PERIOD_D1;
      else
         if(StringFind(toLower(comments), toLower(TRADE_PERIOD_H4)) >= 0)
            TRADE_PERIOD = TRADE_PERIOD_H4;
         else
            if(StringFind(toLower(comments), toLower(TRADE_VECHAI_H1)) >= 0)
               TRADE_PERIOD = TRADE_VECHAI_H1;


   return TRADE_PERIOD;
  }

//+------------------------------------------------------------------+
void ClosePositionByRisk(string symbol, string TRADE_PERIOD, double stop_loss_by_risk)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            string cur_trade_period = get_trade_period(PositionGetString(POSITION_COMMENT));

            if(cur_trade_period == TRADE_PERIOD)
               if(stop_loss_by_risk + m_position.Profit() < 0)
                  m_trade.PositionClose(m_position.Ticket());
           }
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string trading_trend, string TRADE_PERIOD)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            long type = PositionGetInteger(POSITION_TYPE);
            if(trading_trend == TREND_BUY && type == POSITION_TYPE_SELL)
               continue;
            if(trading_trend == TREND_SEL && type == POSITION_TYPE_BUY)
               continue;

            string cur_trade_period = get_trade_period(PositionGetString(POSITION_COMMENT));

            if(cur_trade_period == TRADE_PERIOD)
               m_trade.PositionClose(m_position.Ticket());
           }
        }
     } //for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders(string symbol, string trading_trend, string TRADE_PERIOD)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            if(trading_trend == "" && TRADE_PERIOD == "")
               m_trade.OrderDelete(m_order.Ticket());

            long type = OrderGetInteger(ORDER_TYPE);
            if(trading_trend == TREND_BUY && type == ORDER_TYPE_SELL_LIMIT)
               continue;
            if(trading_trend == TREND_SEL && type == ORDER_TYPE_BUY_LIMIT)
               continue;

            string cur_trade_period = get_trade_period(OrderGetString(ORDER_COMMENT));

            if(cur_trade_period == TRADE_PERIOD)
               m_trade.OrderDelete(m_order.Ticket());
           }
        }
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trade_by_candle_h4_and_bb(string symbol, string find_trend)
  {
   bool has_trade = false;

   if(find_trend == "")
      return "";

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 1);
   double mi_h4_20_0 = middle_h4[0];
   double amp_h4 = MathAbs(upper_h4[0] - middle_h4[0]);

   double hi_h4_20_1 = mi_h4_20_0 + amp_h4;
   double lo_h4_20_1 = mi_h4_20_0 - amp_h4;

   int maLength = 55;
   double close_prices_m15[];
   ArrayResize(close_prices_m15, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      close_prices_m15[i] = iClose(symbol, PERIOD_M15, i);
     }

   double ma10_M15 = CalculateMA(close_prices_m15, 10, 1);
   double ma20_M15 = CalculateMA(close_prices_m15, 20, 1);
   double ma50_M15 = CalculateMA(close_prices_m15, 50, 1);

   bool buy_cond = (find_trend == TREND_BUY) && (ma10_M15 > ma20_M15) && (ma20_M15 > ma50_M15) && (lo_h4_20_1 < price) && (price < hi_h4_20_1);
   bool sel_cond = (find_trend == TREND_SEL) && (ma10_M15 < ma20_M15) && (ma20_M15 < ma50_M15) && (lo_h4_20_1 < price) && (price < hi_h4_20_1);

   if(buy_cond || sel_cond)
     {
      string trend_stoch323 = get_trend_by_stoc323(symbol, PERIOD_M15);

      if(buy_cond && (trend_stoch323 == TREND_BUY)
         && is_allow_trade_now_by_stoc(symbol,PERIOD_M15, TREND_BUY, 3, 2, 3)
         && is_allow_trade_now_by_stoc(symbol,PERIOD_H1,  TREND_BUY, 3, 2, 3)
         && is_allow_trade_now_by_stoc(symbol,PERIOD_H4,  TREND_BUY, 3, 2, 3))
        {
         has_trade = true;

         //m_trade.Buy(volume1, symbol, 0.0, price - amp_d1, price + amp_d1, "M15_BUY");

         Notify_Open_Trade(symbol, TREND_BUY, "  M15_BUY : " + symbol);

         return "  M15_BUY : " + symbol;
        }

      if(sel_cond && (trend_stoch323 == TREND_SEL)
         && is_allow_trade_now_by_stoc(symbol,PERIOD_M15, TREND_SEL, 3, 2, 3)
         && is_allow_trade_now_by_stoc(symbol,PERIOD_H1,  TREND_SEL, 3, 2, 3)
         && is_allow_trade_now_by_stoc(symbol,PERIOD_H4,  TREND_SEL, 3, 2, 3))
        {
         has_trade = true;

         //m_trade.Sell(volume, symbol, 0.0, price + amp_d1, price - amp_d1, "M15_SELL");

         Notify_Open_Trade(symbol, TREND_SEL, "  M15_SELL : " + symbol);

         return "  M15_SELL: " + symbol;
        }
     }

   return "";
  }


//+------------------------------------------------------------------+
string CountTrade(string symbol)
  {
   int ord_buy = 0;
   int ord_sel = 0;
   int pos_buy = 0;
   int pos_sel = 0;

   int count_possion = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_position.Symbol()))) // && (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            long type = PositionGetInteger(POSITION_TYPE);
            if(type == POSITION_TYPE_BUY)
               pos_buy += 1;

            if(type == POSITION_TYPE_SELL)
               pos_sel += 1;
           }
        }
     } //for

   int count_orders = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_order.Symbol())))  //&& (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            long type = OrderGetInteger(ORDER_TYPE);
            if(type == ORDER_TYPE_BUY_LIMIT)
               ord_buy += 1;

            if(type == ORDER_TYPE_SELL_LIMIT)
               ord_sel += 1;
           }
        }
     }

   string result = "";

   if(ord_buy > 0)
      result += TRADE_COUNT_ORDER_B + (string)ord_buy;

   if(ord_sel > 0)
      result += TRADE_COUNT_ORDER_S + (string)ord_sel;

   if(pos_buy > 0)
      result += TRADE_COUNT_POSITION_B + (string)pos_buy;

   if(pos_sel > 0)
      result += TRADE_COUNT_POSITION_S + (string)pos_sel;

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify_Open_Trade(string symbol, string trend, string message)
  {
   if(is_open_trade_this_candle_h4(symbol, trend))
      return;

   add_open_trade_this_candle_h4(symbol, trend);

   Alert(get_vntime(), " ", message);
  }

//+------------------------------------------------------------------+
void close_trade_when_market_close()
  {
   bool is_close_if_has_profit = false;
   bool is_close_trade_today = false;

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;

   if(current_gmt_hour >= 20)
      is_close_if_has_profit = true;
   if(current_gmt_hour >= 22)
      is_close_trade_today = true;

   int count_possion = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(is_close_trade_today)
            m_trade.PositionClose(m_position.Ticket());

         if(is_close_if_has_profit && m_position.Profit()>0)
            m_trade.PositionClose(m_position.Ticket());
        }
     } //for

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CalculatePivot(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_AMP_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = calc_avg_amp_week(symbol, TIME_FRAME, 50);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }


//+------------------------------------------------------------------+
void CalculateAvgCandleHeigh(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_CANDLE_HEIGH_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = CalculateAverageCandleHeight(TIME_FRAME, symbol);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }

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

// Chuyển đổi giờ hiện tại sang giờ Việt Nam
   datetime vietnamTime = currentGMTTime + gmtOffset * 3600;

// Chuyển giờ sang cấu trúc datetime
   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);

// Lấy giờ từ cấu trúc datetime
   int currentHour = dt.hour;

// Kiểm tra xem giờ hiện tại có nằm trong khoảng từ 3 giờ sáng đến 6 giờ sáng không
   if(3 < currentHour && currentHour < 7)
     {
      return true; //VietnamEarlyMorning
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
double CalculateATR14(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int period = 14;
   double atr = 0.0;

// Lấy độ biến động (true range) của các nến
   for(int i = 1; i <= period; i++)
     {
      double high = iHigh(symbol, timeframe, i);
      double low = iLow(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i - 1);

      // Tính toán true range của nến
      double trueRange = MathMax(high - low, MathMax(MathAbs(high - close), MathAbs(low - close)));

      // Cộng dồn true range
      atr += trueRange;
     }


   atr /= period;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return NormalizeDouble(atr, digits);
  }
//+------------------------------------------------------------------

// Hàm tính toán Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits, double deviation = 2)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
// double deviation = 2; // Độ lệch chuẩn cho Bollinger Bands
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



// Hàm tính giá trị tối đa và tối thiểu của 50 cây nến gần nhất
void CalculateMaxMinPrices(string symbol, ENUM_TIMEFRAMES timeframe, double &maxPrice, double &minPrice)
  {
   maxPrice = -DBL_MAX; // Khởi tạo giá trị max với giá trị nhỏ nhất
   minPrice = DBL_MAX; // Khởi tạo giá trị min với giá trị lớn nhất

   int candlesToCheck = 50; // Số cây nến cần xem xét

   for(int i = 0; i < candlesToCheck; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i); // Giá cao nhất của cây nến
      double lowPrice = iLow(symbol, timeframe, i); // Giá thấp nhất của cây nến

      // Tìm giá trị max và min
      if(highPrice > maxPrice)
         maxPrice = highPrice;

      if(lowPrice < minPrice)
         minPrice = lowPrice;
     }
  }

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

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + "   (GMT: " + (string) current_gmt_hour + "h) ";
   return vntime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_of_week(const int index)
  {
   string daysOfWeek[7];

   daysOfWeek[0] = "Sun";   // Sunday
   daysOfWeek[1] = "Mon";   // Monday
   daysOfWeek[2] = "Tue";   // Tuesday
   daysOfWeek[3] = "Wed";   // Wednesday
   daysOfWeek[4] = "Thu";   // Thursday
   daysOfWeek[5] = "Fri";   // Friday
   daysOfWeek[6] = "Sat";   // Saturday

   if((1 <= index) && (index <= 5))
     {
      return daysOfWeek[index];
     }
   if(index <= 0)
     {
      return daysOfWeek[5+index];
     }

   return "d" + (string)index;
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color get_line_color(double open_price, double close_price)
  {
   color candle_color = clrDarkGreen;
   if(open_price > close_price)
     {
      candle_color = clrFireBrick;
     }

   return candle_color;
  }
//+------------------------------------------------------------------+
string date_time_to_string(const MqlDateTime &deal_time)
  {
   string result = "";//(string)deal_time.year;
   if(deal_time.mon < 10)
     {
      result += "0" + (string)deal_time.mon ;
     }
   else
     {
      result += (string)deal_time.mon ;
     }
   if(deal_time.day < 10)
     {
      result += "0" + (string)deal_time.day ;
     }
   else
     {
      result += (string)deal_time.day;
     }


   return result;
  }

//+------------------------------------------------------------------+
double adjust_target_price(double ma10, double dic_top_price, double week_amp)
  {
   double target_price = dic_top_price;

   if(ma10 < dic_top_price)
     {
      // Nếu ma10 nhỏ hơn dic_top_price, giảm target_price cho đến khi nào nó nhỏ hơn ma10
      while(target_price - week_amp >= ma10)
        {
         target_price -= week_amp;
        }
     }
   else
     {
      // Nếu ma10 lớn hơn dic_top_price, tăng target_price cho đến khi nào nó lớn hơn ma10
      while(target_price + week_amp <= ma10)
        {
         target_price += week_amp;
        }
     }

// Kết quả cuối cùng
   return target_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w_2, double &avg_candle_week)
  {
   double amp_w = 0;

   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      amp_w = 1060.00;
      amp_w_2 = 1357.35;
      avg_candle_week = 3697.32;
      return;
     }

   if(symbol == "USOIL.cash")
     {
      i_top_price = 120.000;
      amp_w = 2.50000;
      amp_w_2 = 2.75;
      avg_candle_week = 5.606;
      return;
     }

   if(symbol == "XAGUSD")
     {
      i_top_price = 25.650;
      amp_w = 0.63500;
      amp_w_2 = 0.666;
      avg_candle_week = 1.396;
      return;
     }

   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      amp_w = 22.9500;
      amp_w_2 = 27.83;
      avg_candle_week = 65.93;
      return;
     }

   if(symbol == "US500.cash")
     {
      i_top_price = 4785;
      amp_w = 60.00;
      amp_w_2 = 60.00;
      avg_candle_week = 593.00;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 16950;
      amp_w = 271.500;
      amp_w_2 = 274.5;
      avg_candle_week = 503.15;
      return;
     }

   if(symbol == "US30.cash")
     {
      i_top_price = 38100;
      amp_w = 388.350;
      amp_w_2 = 438.76;
      avg_candle_week = 818.86;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.5000;
      amp_w = 1.07795;
      amp_w_2 = 1.100;
      avg_candle_week = 2.097;
      return;
     }

   if(symbol == "AUDUSD")
     {
      i_top_price = 0.7210;
      amp_w = 0.0075;
      amp_w_2 = 0.0075;
      avg_candle_week = 0.01481;
      return;
     }
   if(symbol == "EURAUD")
     {
      i_top_price = 1.71850;
      amp_w = 0.01365;
      amp_w_2 = 0.01365;
      avg_candle_week = 0.02593;
      return;
     }

   if(symbol == "EURGBP")
     {
      i_top_price = 0.9010;
      amp_w = 0.00455;
      amp_w_2 = 0.00497;
      avg_candle_week = 0.00816;
      return;
     }

   if(symbol == "EURUSD")
     {
      i_top_price = 1.12465;
      amp_w = 0.00790;
      amp_w_2 = 0.0080;
      avg_candle_week = 0.01773;
      return;
     }

   if(symbol == "GBPUSD")
     {
      i_top_price = 1.315250;
      amp_w = 0.01085;
      amp_w_2 = 0.01085;
      avg_candle_week = 0.02180;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.38950;
      amp_w = 0.00795;
      amp_w_2 = 0.00795;
      avg_candle_week = 0.01907;
      return;
     }

   if(symbol == "USDCHF")
     {
      i_top_price = 0.93865;
      amp_w = 0.00715;
      amp_w_2 = 0.00750;
      avg_candle_week = 0.01586;
      return;
     }

   if(symbol == "USDJPY")
     {
      i_top_price = 154.525;
      amp_w = 1.29500;
      amp_w_2 = 1.4250;
      avg_candle_week = 3.240;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.702850;
      amp_w = 0.00500;
      amp_w_2 = 0.00515;
      avg_candle_week = 0.00894;
      return;
     }

   if(symbol == "CADJPY")
     {
      i_top_price = 111.635;
      amp_w = 1.00000;
      amp_w_2 = 1.0250;
      avg_candle_week = 2.298;
      return;
     }

   if(symbol == "CHFJPY")
     {
      i_top_price = 170.450;
      amp_w = 1.45000;
      amp_w_2 = 1.365000;
      avg_candle_week = 3.451;
      return;
     }

   if(symbol == "EURJPY")
     {
      i_top_price = 162.565;
      amp_w = 1.39000;
      amp_w_2 = 1.43500;
      avg_candle_week = 3.31;
      return;
     }

   if(symbol == "GBPJPY")
     {
      i_top_price = 188.405;
      amp_w = 1.61500;
      amp_w_2 = 1.61500;
      avg_candle_week = 3.973;
      return;
     }

   if(symbol == "NZDJPY")
     {
      i_top_price = 90.435;
      amp_w = 0.90000;
      amp_w_2 = 0.90000;
      avg_candle_week = 1.946;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.5015;
      amp_w = 0.00945;
      amp_w_2 = 0.00945;
      avg_candle_week = 0.01895;
      return;
     }

   if(symbol == "EURCHF")
     {
      i_top_price = 0.96800;
      amp_w = 0.00455;
      amp_w_2 = 0.00515;
      avg_candle_week = 0.01156;
      return;
     }

   if(symbol == "EURNZD")
     {
      i_top_price = 1.89155;
      amp_w = 0.01585;
      amp_w_2 = 0.01585;
      avg_candle_week = 0.02848;
      return;
     }

   if(symbol == "GBPAUD")
     {
      i_top_price = 1.9905;
      amp_w = 0.01575;
      amp_w_2 = 0.01575;
      avg_candle_week = 0.02700;
      return;
     }

   if(symbol == "GBPCAD")
     {
      i_top_price = 1.6885;
      amp_w = 0.01210;
      amp_w_2 = 0.01210;
      avg_candle_week = 0.02005;
      return;
     }

   if(symbol == "GBPCHF")
     {
      i_top_price = 1.11485;
      amp_w = 0.00685;
      amp_w_2 = 0.0085;
      avg_candle_week = 0.01625;
      return;
     }

   if(symbol == "GBPNZD")
     {
      i_top_price = 2.09325;
      amp_w = 0.01700;
      amp_w_2 = 0.016250;
      avg_candle_week = 0.02895;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.90385;
      amp_w = 0.00735;
      amp_w_2 = 0.0075;
      avg_candle_week = 0.01345;
      return;
     }

   if(symbol == "AUDCHF")
     {
      i_top_price = 0.654500;
      amp_w = 0.00545;
      amp_w_2 = 0.005805;
      avg_candle_week = 0.01076;
      return;
     }

   if(symbol == "AUDNZD")
     {
      i_top_price = 1.09385;
      amp_w = 0.00595;
      amp_w_2 = 0.00595;
      avg_candle_week = 0.01017;
      return;
     }

   if(symbol == "NZDCAD")
     {
      i_top_price = 0.84135;
      amp_w = 0.007200;
      amp_w_2 = 0.007200;
      avg_candle_week = 0.01275;
      return;
     }

   if(symbol == "NZDCHF")
     {
      i_top_price = 0.548615;
      amp_w = 0.00515;
      amp_w_2 = 0.00515;
      avg_candle_week = 0.00988;
      return;
     }

   if(symbol == "NZDUSD")
     {
      i_top_price = 0.6275;
      amp_w = 0.00670;
      amp_w_2 = 0.00660;
      avg_candle_week = 0.01388;
      return;
     }


   i_top_price = iClose(symbol, PERIOD_W1, 1);
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   amp_w_2 = amp_w;
   avg_candle_week = CalculateAverageCandleHeight(PERIOD_W1, symbol);

   Alert(" Add Symbol Data:",  symbol, " amp_w:", amp_w, " i_top_price:", i_top_price, " avg_candle_week:", avg_candle_week);
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 50; i++)
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
//+------------------------------------------------------------------+
double CalculateMA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= ma_index; i++)
     {
      count += 1;
      ma += closePrices[i];
     }
   ma /= count;

   return ma;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = CalculateMA(closePrices, ma_index);
   return ma_value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk()
  {
   double dbValueRisk = INIT_EQUITY * dbRiskRatio;

   if(dbValueRisk > 200)
     {
      Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than 200 per order. Too dangerous.");
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

//+------------------------------------------------------------------+
void ObjectsDeleteAll()
  {
   int totalObjects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol,  TIMEFRAME, week_index);
   double week_low = iLow(symbol,   TIMEFRAME, week_index);
   double week_clo = iClose(symbol, TIMEFRAME, week_index);

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
string format_double_to_string(double number, int digits = 5)
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
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_amp_week(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_week_amp(symbol, TIMEFRAME, index);
     }
   double week_amp = total_amp / size;

   return week_amp;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_amp(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int length)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week);
   double week_amp = dic_amp_w;

   double lowest = 0.0;
   double higest = 0.0;
   for(int i = 0; i < length; i++)
     {
      double lowPrice = iLow(symbol, TIMEFRAME, i);
      double higPrice = iHigh(symbol, TIMEFRAME, i);

      if((i == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((i == 0) || (higest < higPrice))
         higest = higPrice;
     }

   double amp_10_weeks = MathAbs(higest - lowest);
   if((amp_10_weeks / week_amp) >= 5)
     {
      if((MathAbs(price - lowest)/ week_amp) >= 4)
         return TREND_SEL;

      if((MathAbs(higest - price)/ week_amp) >= 4)
         return TREND_BUY;
     }

   return "";
  }

// Định nghĩa lớp CandleData
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend;
   int               count;
   // Default constructor
                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend = "";
      count = 0;
     }
                     CandleData(datetime t, double o, double h, double l, double c, string c_trend, int count_c1)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend = c_trend;
      count = count_c1;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountHeikenList(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_no, CandleData &candle_heiken)
  {
   CandleData candleArray[55];

   datetime pre_HaTime = iTime(symbol, TIME_FRAME, 54);
   double pre_HaOpen = iOpen(symbol, TIME_FRAME, 54);
   double pre_HaHigh = iHigh(symbol, TIME_FRAME, 54);
   double pre_HaLow = iLow(symbol, TIME_FRAME, 54);
   double pre_HaClose = iClose(symbol, TIME_FRAME, 54);
   string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0);
   candleArray[54] = candle;

   for(int index = 53; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh = MathMax(iOpen(symbol, TIME_FRAME, index), MathMax(haClose, pre_cancle.high));
      double haLow = MathMin(iOpen(symbol, TIME_FRAME, index), MathMin(haClose, pre_cancle.low));

      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_trend = 1;
      for(int j = index+1; j < 50; j++)
        {
         if(haTrend == pre_candle_trend && haTrend == candleArray[j].trend)
           {
            count_trend += 1;
           }
         else
           {
            break;
           }
        }

      CandleData candle(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle;
     }

   candle_heiken = candleArray[candle_no];
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
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(double& prices[], int period, int candle_no)
  {
   int maLength = ArraySize(prices);
   double smoothingFactor = 2.0 / (period + 1);

   double ema[];
   ArrayResize(ema, maLength);

   ema[maLength - 1] = prices[maLength - 1];

   for(int i = maLength - 2; i >= 0; i--)
     {
      double currentPrice = prices[i];
      double previousEMA = ema[i + 1];
      ema[i] = format_double((currentPrice * smoothingFactor) + (previousEMA * (1-smoothingFactor)), 5);
     }

   return ema[candle_no];
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
bool allow_trade_by_amp_50candle(string symbol, string find_trend)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int count_candle = 0;
   int length_55 = 55;
   double close_prices_d1[];
   ArrayResize(close_prices_d1, length_55);
   for(int i = length_55 - 1; i >= 0; i--)
     {
      double temp_close = iClose(symbol, PERIOD_D1, i);
      if(temp_close > 0)
         count_candle += 1;

      close_prices_d1[i] = temp_close;
     }
   if(count_candle < 50)
      return false;

   double close_d1_c1 = close_prices_d1[1];

   double min_close_d1 = FindMinPrice(close_prices_d1);
   double max_close_d1 = FindMaxPrice(close_prices_d1);
   double amp_1_3 = MathAbs(max_close_d1 - min_close_d1) / 3;

   double sel_area = max_close_d1 - amp_1_3;
   double buy_area = min_close_d1 + amp_1_3;

   if(find_trend == TREND_BUY && price <= buy_area)
      return true;

   if(find_trend == TREND_SEL && price >= sel_area)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Function to read content from the file open_trade_today.txt
string ReadFileContent()
  {
   string fileContent = "";
   int fileHandle = FileOpen("open_trade_today.txt", FILE_READ);

   if(fileHandle != INVALID_HANDLE)
     {
      ulong fileSize = FileSize(fileHandle);
      if(fileSize > 0)
        {
         fileContent = FileReadString(fileHandle);
        }

      FileClose(fileHandle);
     }

   return fileContent;
  }

// Function to write content to the file open_trade_today.txt
void WriteFileContent(string content)
  {
   int fileHandle = FileOpen("open_trade_today.txt", FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      FileWriteString(fileHandle, content);
      FileClose(fileHandle);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int originalLength = StringLen(originalString);
   if(originalLength > 1000)
     {
      int startIndex = originalLength - 1000;
      return StringSubstr(originalString, startIndex, 1000);
     }
   return originalString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string symbol, string trend)
  {
   string date_time = (string)iTime(symbol, PERIOD_H4, 0);
   StringReplace(date_time, ":00:00", "h");

   return date_time + ":" + trend + ":" + symbol +";";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_open_trade_this_candle_h4(string symbol, string trend)
  {
   string open_trade_today = ReadFileContent();
//Alert(open_trade_today);
   string key = create_key(symbol, trend);

   open_trade_today = open_trade_today + key;
   open_trade_today = CutString(open_trade_today);

   WriteFileContent(open_trade_today);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_open_trade_this_candle_h4(string symbol, string trend)
  {
   string open_trade_today = ReadFileContent();

   string key = create_key(symbol, trend);

   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_macd369(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 1, 0, 50, m_buff_MACD_signal);

   double m_signal_current  = m_buff_MACD_signal[0];
   int count = 1;

   for(int i = 1; i < ArraySize(m_buff_MACD_signal) - 1; i++)
     {
      double m_signal  = m_buff_MACD_signal[i];

      if(m_signal_current > 0)
        {
         if(m_signal > 0)
            count += 1;
         else
            break;
        }

      if(m_signal_current < 0)
        {
         if(m_signal < 0)
            count += 1;
         else
            break;
        }
     }


   return (m_signal_current > 0 ? TREND_BUY : TREND_SEL) + "(" + (string) count + ")";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_heiken(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   CandleData candle_heiken;
   CountHeikenList(symbol, timeframe, 1, candle_heiken);

   return candle_heiken.trend + "("+(string) candle_heiken.count+")" ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_adx_dmi(string symbol, ENUM_TIMEFRAMES timeframe, int ma_period, string find_trend)
  {
   double    ExtADXBuffer[];  // ADx
   double    ExtPDIBuffer[];  // DI+
   double    ExtNDIBuffer[];  // DI-

   ArraySetAsSeries(ExtADXBuffer, true);
   ArraySetAsSeries(ExtPDIBuffer, true);
   ArraySetAsSeries(ExtNDIBuffer, true);

   int adx_handle = iADX(symbol, timeframe, ma_period);

   if(adx_handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iADXWilder indicator for the symbol %s/%s, error code %d",
                  symbol,
                  EnumToString(timeframe),
                  GetLastError());
      //--- the indicator is stopped early
      return false;
     }

   if(CopyBuffer(adx_handle,0,0,5,ExtADXBuffer)>=0
      && CopyBuffer(adx_handle,1,0,5,ExtPDIBuffer)>=0
      && CopyBuffer(adx_handle,2,0,5,ExtNDIBuffer)>=0)
     {

      if(find_trend == TREND_BUY)
        {
         double buy_0 = ExtPDIBuffer[0];
         double buy_1 = ExtPDIBuffer[1];
         if(buy_0 > buy_1)
           {
            return true;
           }
        }

      if(find_trend == TREND_SEL)
        {
         double sel_0 = ExtNDIBuffer[0];
         double sel_1 = ExtNDIBuffer[1];
         if(sel_0 > sel_1)
           {
            return true;
           }
        }
     }


   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_adx_dmi(string symbol, ENUM_TIMEFRAMES timeframe, int ma_period)
  {
   double    ExtADXBuffer[];  // ADx
   double    ExtPDIBuffer[];  // DI+
   double    ExtNDIBuffer[];  // DI-

   ArraySetAsSeries(ExtADXBuffer, true);
   ArraySetAsSeries(ExtPDIBuffer, true);
   ArraySetAsSeries(ExtNDIBuffer, true);

   int adx_handle = iADX(symbol, timeframe, ma_period);

   if(adx_handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iADXWilder indicator for the symbol %s/%s, error code %d",
                  symbol,
                  EnumToString(timeframe),
                  GetLastError());
      //--- the indicator is stopped early
      return "";
     }

   if(CopyBuffer(adx_handle,0,0,5,ExtADXBuffer)>=0
      && CopyBuffer(adx_handle,1,0,5,ExtPDIBuffer)>=0
      && CopyBuffer(adx_handle,2,0,5,ExtNDIBuffer)>=0)
     {
      if(ExtPDIBuffer[0] > ExtNDIBuffer[0] && ExtPDIBuffer[1] > ExtNDIBuffer[1])
        {
         return TREND_BUY;
        }

      if(ExtPDIBuffer[0] < ExtNDIBuffer[0] && ExtPDIBuffer[1] < ExtNDIBuffer[1])
        {
         return TREND_SEL;
        }
     }

   return "";
  }

//+------------------------------------------------------------------+
string get_candle_switch_trend_adx(string symbol, ENUM_TIMEFRAMES timeframe, int ma_period)
  {
   double    ExtADXBuffer[];  // ADx
   double    ExtPDIBuffer[];  // DI+
   double    ExtNDIBuffer[];  // DI-

   ArraySetAsSeries(ExtADXBuffer, true);
   ArraySetAsSeries(ExtPDIBuffer, true);
   ArraySetAsSeries(ExtNDIBuffer, true);

   int adx_handle = iADX(symbol, timeframe, ma_period);

   if(adx_handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iADXWilder indicator for the symbol %s/%s, error code %d",
                  symbol,
                  EnumToString(timeframe),
                  GetLastError());
      //--- the indicator is stopped early
      return(string) INIT_FAILED;
     }

   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   string trend = "";
   string str_adx = "";
   if(CopyBuffer(adx_handle,0,0,50,ExtADXBuffer)>=0
      && CopyBuffer(adx_handle,1,0,50,ExtPDIBuffer)>=0
      && CopyBuffer(adx_handle,2,0,50,ExtNDIBuffer)>=0)
     {
      str_adx = "   Adx: " + format_double_to_string(ExtADXBuffer[0], 2) + "   Dm+: " + format_double_to_string(ExtPDIBuffer[0], 2) + "   Dm-: " + format_double_to_string(ExtNDIBuffer[0], 2);

      if(ExtPDIBuffer[1] > ExtNDIBuffer[1])
        {
         trend = TREND_BUY;
         for(int i = 1; i < ArraySize(ExtADXBuffer) - 1; i++)
           {
            if(ExtPDIBuffer[i] < ExtNDIBuffer[i])
              {
               // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
               x = i;
               break;
              }
           }

        }
      else
        {
         trend = TREND_SEL;
         for(int i = 1; i < ArraySize(ExtADXBuffer) - 1; i++)
           {
            if(ExtPDIBuffer[i] > ExtNDIBuffer[i])
              {
               // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
               x = i;
               break;
              }
           }

        }

     }


   if(x != -1)
      return trend + "("+(string) x+")" ;// + str_adx;
   else
      return trend + "(5x)" ;//  + str_adx;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing, int candle_no)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return 50;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,50,K);
   CopyBuffer(handle_iStochastic,1,0,50,D);

   double black_K = K[candle_no];
   double red_D = D[candle_no];

// Tìm vị trí x thỏa mãn điều kiện
   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   for(int i = candle_no; i < ArraySize(K) - 1; i++)
     {
      if((K[i] < D[i] && K[i + 1] > D[i + 1])
         || (K[i] > D[i] && K[i + 1] < D[i + 1]))
        {
         // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
         x = i;
         break;
        }
     }

   if(x != -1)
     {
      return x;
     }
   else
     {
      return 50;
     }
  }

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


//+------------------------------------------------------------------+
string get_trend_by_vector_macd369(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return "____";
     }

   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_signal,true);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double m_signal_0 = m_buff_MACD_signal[0];
   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[2];
//-------------------------------------------------
   if((m_signal_0 >= m_signal_1) && (m_signal_1 >= m_signal_2))
      return TREND_BUY;

   if((m_signal_0 <= m_signal_1) && (m_signal_1 <= m_signal_2))
      return TREND_SEL;

   return "____";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd369(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_signal);

   double m_macd_current    = m_buff_MACD_main[0];
   double m_signal_current  = m_buff_MACD_signal[0];

//double m_macd_previous   = m_buff_MACD_main[1];
//double m_signal_previous = m_buff_MACD_signal[1];
//int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   return (m_signal_current > 0 ? TREND_BUY : TREND_SEL);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch323(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend)
  {
   int periodK = 3; // %K
   int periodD = 2; // %D
   int slowing = 3; // Slowing

   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if((find_trend == TREND_BUY) && (black_K > 80) && (red_D > 80))
      return true;

   if((find_trend == TREND_SEL) && (black_K < 20) && (red_D < 20))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc323(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string stoch = "";

   int periodK = 3; // %K
   int periodD = 2; // %D
   int slowing = 3; // Slowing

   string indicatorPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Indicators\\Examples\\Stochastic.mq5";

   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
     {
      stoch += " Error in iStochastic. Error code: " + (string)GetLastError();
      return stoch;
     }

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);

   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double blackK_0 = K[0];
   double redD_0 = D[0];

   double blackK_1 = K[1];
   double redD_1 = D[1];

   if(blackK_0 >= 80 || redD_0 >= 80 || blackK_0 <= 20 || redD_0 <= 20)
     {
      if(redD_0 < blackK_0)
        {
         return TREND_BUY ;
        }

      if(redD_0 > blackK_0)
        {
         return TREND_SEL;
        }
     }

   if(redD_1 < blackK_1 && redD_0 < blackK_0)
     {
      return TREND_BUY ;
     }

   if(redD_1 > blackK_1 && redD_0 > blackK_0)
     {
      return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc963(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int periodK = 9; // %K
   int periodD = 6; // %D
   int slowing = 3; // Slowing

   string indicatorPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Indicators\\Examples\\Stochastic.mq5";

   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
     {
      return "";
     }

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);

   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);
   double blackK = K[0];
   double redD = D[0];

   string trend_stoch = "";
   if(redD < blackK)
     {
      return TREND_BUY ;
     }

   if(redD > blackK)
     {
      return TREND_SEL;
     }

   return "";
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string trend, int periodK, int periodD, int slowing)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K = K[1];
   double red_D = D[1];

   if(trend == TREND_BUY && (black_K <= 20 && red_D <= 20))
      return true;

   if(trend == TREND_SEL && (black_K >= 80 && red_D >= 80))
      return true;

   return false;
  }
//+------------------------------------------------------------------+
