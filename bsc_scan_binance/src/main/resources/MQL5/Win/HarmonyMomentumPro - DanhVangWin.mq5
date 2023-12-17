//+------------------------------------------------------------------+
//|                                           HarmonyMomentumPro.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

string input BOT_NAME = "HarmonyMomentumPro";
int input    EXPERT_MAGIC = 20231213;

double dbRiskRatio = 0.01; // Rủi ro 0.01 = 1%
double INIT_EQUITY = 2000.0; // Vốn ban đầu

string POSITON_TRARE = "POSI_";

string TREND_BUY = "BUY";
string TREND_SEL = "SEL";

string MAC_POSITION_BUY = "MAC_POSITION_BUY";
string MAC_POSITION_SEL = "MAC_POSITION_SEL";

string STOC_TP_BUY_OPEN_SEL = "STOC_TP_BUY_OPEN_SEL";
string STOC_TP_SEL_OPEN_BUY = "STOC_TP_SEL_OPEN_BUY";

string str_line = "";
string PRIFIX_SEQ_MACD = "SEQ_";

// "USDCHF", "USDJPY", "EURJPY", "EURCAD", "EURUSD", "GBPUSD", "EURGBP"
string arr_symbol[] =
  {
   "XAUUSD", "XAGUSD"
   ,"BTCUSD", "ETHUSD"
   ,"US30.cash", "US100.cash", "USOIL.cash"

   ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
   ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
   ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
   ,"NZDCAD", "NZDJPY", "NZDUSD"
   ,"USDCAD", "USDJPY", "CADJPY", "USDCHF"

//"XAUUSD"
  };

//+------------------------------------------------------------------+
int OnInit()
  {
   for(int index = 1; index <= 10000; index++)
      str_line += "_";

   OnTimer();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);

// printf(BOT_NAME + " initialized ");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//DrawBB();

//------------------------------------------------------------------
   double risk = format_double(dbRisk(), 2);
   iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
   iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);

   CandleData candle_heiken_h4_c1;
   CountHeikenList(_Symbol, PERIOD_H4, 1, candle_heiken_h4_c1);

   string trend_tocd = "    TocD(" + trend_by_stoc_80_20(_Symbol, PERIOD_CURRENT) + ")";

   string note_macd_w1 = "    W1(" + trend_by_macd_week(_Symbol) + ")";
   string note_macd_d1 = "    D1(" + trend_by_macd(_Symbol, PERIOD_D1, 0) + ")";
   string note_macd_h4 = "    (MACD) H4(" + trend_by_macd(_Symbol, PERIOD_H4, 1) + ")";
   string note_heiken_h4 = "    (Heiken) H4(" + candle_heiken_h4_c1.trend + ")" + (candle_heiken_h4_c1.count > 10 ? (string) candle_heiken_h4_c1.count : "0" + (string) candle_heiken_h4_c1.count);

   string trend_macd = _Symbol + note_macd_w1 + note_macd_d1 + note_macd_h4 + note_heiken_h4;

   if(IsMarketClose())
     {
      string message = get_vntime() + "(BB_Guardian) Market Close (Sat, Sun, 3 < Vn.Hour < 7).";
      message += "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$"  + trend_tocd;

      Comment(trend_macd + "\n" + message);
      return;
     }
   else
     {
      string str_risk  =  "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";
      str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
      str_risk += "    " + _Symbol;
      string comment = get_vntime() + " (BB_Guardian) Market Open " + str_risk + trend_tocd;
      Comment(trend_macd + "\n" + comment);
     }
//------------------------------------------------------------------

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];

      double price = SymbolInfoDouble(symbol, SYMBOL_BID);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      int maLength = 50;
      double low_d1[];
      double hig_d1[];
      double close_d1[];
      double close_h4[];

      int count_d = 0;
      double total_amp_d = 0;
      ArrayResize(low_d1, maLength);
      ArrayResize(hig_d1, maLength);
      ArrayResize(close_d1, maLength);
      ArrayResize(close_h4, maLength);
      for(int i = maLength - 1; i >= 0; i--)
        {
         double low = iLow(symbol, PERIOD_D1, i);
         double hig = iHigh(symbol, PERIOD_D1, i);
         double amp = MathAbs(hig - low);
         low_d1[i] = low;
         hig_d1[i] = hig;
         close_d1[i] = iClose(symbol, PERIOD_D1, i);
         close_h4[i] = iClose(symbol, PERIOD_H4, i);

         if(amp > 0)
           {
            count_d += 1;
            total_amp_d += amp;
           }
        }

      double min_50h4_candle = FindMinPrice(close_h4);
      double max_50h4_candle = FindMaxPrice(close_h4);

      double atr_14d = CalculateATR14(symbol, PERIOD_D1);
      double min_50d = FindMinPrice(low_d1) + atr_14d;
      double max_50d = FindMaxPrice(hig_d1) - atr_14d;

      double d1_ma10 = CalculateMA(close_d1, 10, 1);
      double pre_close_d = close_d1[1];
      string trend_ma10d = (pre_close_d > d1_ma10) ? TREND_BUY : TREND_SEL;
      double amp_avg_d1 = NormalizeDouble(total_amp_d / count_d, digits);
      double amp_d1_and_atr = amp_avg_d1 + atr_14d;
      //------------------------------------------------------------------
      CandleData candle_heiken_h4_c1;
      CountHeikenList(symbol, PERIOD_H4, 1, candle_heiken_h4_c1);

      CandleData candle_heiken_d1_c1;
      CountHeikenList(symbol, PERIOD_D1, 1, candle_heiken_d1_c1);
      //------------------------------------------------------------------
      string note = "";


      int count_macd = candle_heiken_h4_c1.count;
      bool count_macd_allow_trade = (2 <= candle_heiken_h4_c1.count) && (candle_heiken_h4_c1.count <= 5);

      bool amp_allow_tp = ((min_50d + amp_d1_and_atr) < price) && (price < (max_50d - amp_d1_and_atr));

      double ma_20_h4_1 = CalculateMA_XX(symbol, PERIOD_H4, 20, 1);
      double ma_20_h4_2 = CalculateMA_XX(symbol, PERIOD_H4, 20, 2);

      string trend_vector_20_h4 = ma_20_h4_1 > ma_20_h4_2 ? TREND_BUY : TREND_SEL;
      string trend_vector_signal_of_macd_h4 = trend_vector_signal(symbol, PERIOD_H4);
      string trend_stock_back_vs_red_h4 = trend_by_stoc_black_vs_red(symbol, PERIOD_H4);
      string trend_stock_back_vs_red_d1 = trend_by_stoc_black_vs_red(symbol, PERIOD_D1);
      string trend_ma20_vs_heiken_c1 = candle_heiken_h4_c1.close > ma_20_h4_1 ? TREND_BUY : TREND_SEL;
      string trend_heiken_h4_1 = candle_heiken_h4_c1.trend;
      string trend_heiken_d1_1 = candle_heiken_d1_c1.trend;

      bool allow_trade = false;
      if(amp_allow_tp
         //&& count_macd_allow_trade
         //&& (trend_ma10d == TREND_BUY)
         && (trend_heiken_h4_1 == TREND_BUY)
         && (trend_heiken_d1_1 == TREND_BUY)
         && (trend_vector_20_h4 == TREND_BUY)
         && (trend_ma20_vs_heiken_c1 == TREND_BUY)
         && (trend_vector_signal_of_macd_h4 == TREND_BUY)
         && (trend_stock_back_vs_red_h4 == TREND_BUY)
         //&& (trend_stock_back_vs_red_d1 == TREND_BUY)
        )
        {
         allow_trade = true;
         note = "hei";
        }

      if(amp_allow_tp
         //&& count_macd_allow_trade
         //&& (trend_ma10d == TREND_SEL)
         && (trend_heiken_h4_1 == TREND_SEL)
         && (trend_heiken_d1_1 == TREND_SEL)
         && (trend_vector_20_h4 == TREND_SEL)
         && (trend_ma20_vs_heiken_c1 == TREND_SEL)
         && (trend_vector_signal_of_macd_h4 == TREND_SEL)
         && (trend_stock_back_vs_red_h4 == TREND_SEL)
         //&& (trend_stock_back_vs_red_d1 == TREND_SEL)
        )
        {
         allow_trade = true;
         note = "hei";
        }

      //------------------------------------------------------------------
      //------------------------------------------------------------------
      int count = 0;
      string lowcase_symbol = toLower(symbol);
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         string order_symbol = OrderGetString(ORDER_SYMBOL);
         string order_comment = OrderGetString(ORDER_COMMENT);

         if(is_trading_symbol(symbol, order_symbol, order_comment, PRIFIX_SEQ_MACD))
            count = count + 1;
        }

      int count_pos = 0;
      ulong max_ticket = 0;
      double total_profit = 0;
      double init_volume = 0.01;
      string trade_trend = "";
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         string pos_symbol = PositionGetSymbol(i);
         string pos_comment = PositionGetString(POSITION_COMMENT);

         if(is_trading_symbol(symbol, pos_symbol, pos_comment, PRIFIX_SEQ_MACD))
           {
            count_pos += 1;
            count = count + 1;
            //----------------------------------------------------------------------------
            ulong ticket = PositionGetTicket(i);
            double cur_profit = PositionGetDouble(POSITION_PROFIT);
            string pos_comments = PositionGetString(POSITION_COMMENT);
            trade_trend = get_trade_type(pos_comment);
            double profit = PositionGetDouble(POSITION_PROFIT);
            total_profit += profit;
            if(count_pos == 1)
               init_volume = PositionGetDouble(POSITION_VOLUME);
            //----------------------------------------------------------------------------
            if(max_ticket < ticket)
               max_ticket = ticket;
            //----------------------------------------------------------------------------
            if((trend_ma20_vs_heiken_c1 != trade_trend) && (trend_heiken_h4_1 != trade_trend))
               m_trade.PositionClose(ticket);
           }
        }

      //-----------------------------------------------------------------------------------------------
      if(allow_trade && ((count == 0) ||  is_trade_exceeded_hours(max_ticket, 12)))
        {
         bool has_trade = false;
         note = (string)(count + 1) + note;

         double avg_amp_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol);

         double volume = dblLotsRisk(symbol, avg_amp_h4, dbRisk());
         if(count > 0)
            volume = init_volume;

         if(has_trade == false)
            has_trade = trade_10_20_50(PERIOD_M5, PRIFIX_SEQ_MACD + "05", symbol, volume, trend_heiken_h4_1, amp_d1_and_atr, avg_amp_h4, note);

         if(has_trade == false)
            has_trade = trade_10_20_50(PERIOD_M10, PRIFIX_SEQ_MACD + "10", symbol, volume, trend_heiken_h4_1, amp_d1_and_atr, avg_amp_h4, note);

         if(has_trade == false)
            has_trade = trade_10_20_50(PERIOD_M15, PRIFIX_SEQ_MACD + "15", symbol, volume, trend_heiken_h4_1, amp_d1_and_atr, avg_amp_h4, note);
        }

      return;


      /*
            string trend_macd_h4 = trend_by_macd(symbol, PERIOD_H4, 1);

            //-----------------------------------------------------------------------------------------------
            bool prepare_tp_d1 = false;
            int handle_iStoch_D = iStochastic(symbol, PERIOD_D1, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
            if(handle_iStoch_D != INVALID_HANDLE)
              {
               double K[],D[];
               ArraySetAsSeries(K, true);
               ArraySetAsSeries(D, true);

               CopyBuffer(handle_iStoch_D,0,0,10,K);
               CopyBuffer(handle_iStoch_D,1,0,10,D);
               double black_K = K[0];
               double red_D = D[0];

               if((count > 0) && (total_profit > risk))
                 {
                  if((trade_trend == TREND_BUY) && (black_K < 20) && (black_K > red_D))
                     prepare_tp_d1 = true;

                  if((trade_trend == TREND_SEL) && (black_K < 80) && (black_K < red_D))
                     prepare_tp_d1 = true;
                 }
              }


            bool stoch_h4_allow_trade = false;
            if(total_profit > 0)
              {
               int handle_iStoch_H4 = iStochastic(symbol, PERIOD_H4, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
               if(handle_iStoch_H4 != INVALID_HANDLE)
                 {
                  double K[],D[];
                  ArraySetAsSeries(K, true);
                  ArraySetAsSeries(D, true);

                  CopyBuffer(handle_iStoch_H4,0,0,10,K);
                  CopyBuffer(handle_iStoch_H4,1,0,10,D);
                  double black_K = K[1];
                  double red_D = D[1];

                  if((trend_macd_d1 == TREND_BUY) && (red_D < black_K) && (black_K <= 20))
                     stoch_h4_allow_trade = true;

                  if((trend_macd_d1 == TREND_SEL) && (80 <= black_K) && (black_K < red_D))
                     stoch_h4_allow_trade = true;
                 }
              }
            //-----------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------
            if(count > 1)
               move_to_best_sl(symbol, PRIFIX_SEQ_MACD);

            if(prepare_tp_d1)
               move_to_best_tp(symbol, PRIFIX_SEQ_MACD);


            //if((stoch_h4_allow_trade && (count == 0)) || (stoch_h4_allow_trade && (total_profit > 0) && is_trade_exceeded_hours(max_ticket, 12)))
            if(allow_trade && ((count == 0) ||  is_trade_exceeded_hours(max_ticket, 12)))
              {
               bool has_trade = false;
               note = (string)(count + 1) + note;

               double volume = dblLotsRisk(symbol, amp_d1_and_atr, dbRisk());
               if(count > 0)
                  volume = init_volume;

               if(has_trade == false)
                  has_trade = trade_10_20_50(PERIOD_M5, PRIFIX_SEQ_MACD + "05", symbol, volume, trend_macd_d1, amp_d1_and_atr, amp_d1_and_atr, note);

               if(has_trade == false)
                  has_trade = trade_10_20_50(PERIOD_M10, PRIFIX_SEQ_MACD + "10", symbol, volume, trend_macd_d1, amp_d1_and_atr, amp_d1_and_atr, note);

               if(has_trade == false)
                  has_trade = trade_10_20_50(PERIOD_M15, PRIFIX_SEQ_MACD + "15", symbol, volume, trend_macd_d1, amp_d1_and_atr, amp_d1_and_atr, note);
              }
           }
           */
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool trade_10_20_50(ENUM_TIMEFRAMES TIME_FRAME, string prifix, string symbol, double volume, string find_trend, double amp_sl, double amp_tp, string note)
  {
   bool has_trade = false;

   if(find_trend == "")
      return false;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double sl_buy = price - amp_sl;
   double tp_buy = price + amp_tp;

   double sl_sell = price + amp_sl;
   double tp_sell = price - amp_tp;

   int maLength = 55;
   double close_prices_m15[];
   ArrayResize(close_prices_m15, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      close_prices_m15[i] = iClose(symbol, TIME_FRAME, i);
     }

   double ma10 = CalculateMA(close_prices_m15, 10, 1);
   double ma20 = CalculateMA(close_prices_m15, 20, 1);
   double ma50 = CalculateMA(close_prices_m15, 50, 1);
   double close_c1 = close_prices_m15[1];

   bool buy_cond = (close_c1 < ma50) && (close_c1 > ma10) && (find_trend == TREND_BUY);
   bool sel_cond = (close_c1 > ma50) && (close_c1 < ma10) && (find_trend == TREND_SEL);

   if(buy_cond)
     {
      has_trade = true;

      m_trade.Buy(volume, symbol, 0.0, sl_buy, tp_buy, prifix + "_" + TREND_BUY + "_" + note);

      Alert(get_vntime(), "(SEQ)" + prifix + "_BUY : ", symbol);
     }

   if(sel_cond)
     {
      has_trade = true;

      m_trade.Sell(volume, symbol, 0.0, sl_sell, tp_sell, prifix + "_" + TREND_SEL + "_" + note);

      Alert(get_vntime(), "(SEQ)" + prifix + "_SELL : ", symbol);
     }

   return has_trade;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string trend_by_stoc_80_20(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int periodK = 5; // %K
   int periodD = 3; // %D
   int slowing = 3; // Slowing

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
   double black_K = K[1];
   double red_D = D[1];
   double pre_Red_D = D[2];

   if((black_K > 80) || (red_D > 80))
     {
      return TREND_SEL;
     }

   if((black_K < 20) || (red_D < 20))
     {
      return TREND_BUY;
     }

   return "";
  }

//+------------------------------------------------------------------+
string trend_by_stoc_black_vs_red(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string stoch = "";

   int periodK = 5; // %K
   int periodD = 3; // %D
   int slowing = 3; // Slowing

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
   double black_K = K[1];
   double red_D = D[1];
//double pre_Red_D = D[2];

   if((black_K > red_D))  //&& (red_D > pre_Red_D)
     {
      return TREND_BUY;
     }

   if((black_K < red_D)) //&& (red_D < pre_Red_D)
     {
      return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Evil_Trade(string symbol, string find_trend, string note)
  {
   double risk = format_double(dbRisk(), 2);
   double volume1 = 0.01;
   double volume2 = 0.02;
   double volume3 = 0.04;
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1;  // PERIOD_M15 PERIOD_H1
//End ----------------------------------------------------------------

   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
//------------------------------------------------------------------

   Clean_BB_Trade(symbol);

   int count = 0;
   string lowcase_symbol = toLower(symbol);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      string ord_comment = OrderGetString(ORDER_COMMENT);

      if((lowcase_symbol == order_symbol) && (StringFind(ord_comment, "BB_") >= 0))
        {
         count = count + 1;
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);
      string pos_comment = PositionGetString(POSITION_COMMENT);

      if((lowcase_symbol == trading_symbol) && (StringFind(pos_comment, "BB_") >= 0))
        {
         count = count + 1;
        }
     }

   if(count == 0)
     {
      double upper_h1_20_1[], middl_h1_20_1[], lower_h1_20_1[];
      CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_1, middl_h1_20_1, lower_h1_20_1, digits, 1);
      double hi_h1_20_1 = upper_h1_20_1[0];
      double mi_h1_20_0 = middl_h1_20_1[0];
      double lo_h1_20_1 = lower_h1_20_1[0];

      double amp_h1 = MathAbs(hi_h1_20_1 - mi_h1_20_0);
      double avg_amp_h1 = CalculateAverageCandleHeight(PERIOD_H1, symbol);
      if(amp_h1 < avg_amp_h1)
         return;

      double upper_h4[], middle_h4[], lower_h4[];
      CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
      double hi_h4_20_2 = upper_h4[0];
      double lo_h4_20_2 = lower_h4[0];

      double hi_h1_20_2 = hi_h1_20_1 + amp_h1;
      double hi_h1_20_3 = hi_h1_20_2 + amp_h1;
      double hi_h1_20_4 = hi_h1_20_3 + amp_h1;
      double hi_h1_20_5 = hi_h1_20_4 + amp_h1;

      double lo_h1_20_2 = lo_h1_20_1 - amp_h1;
      double lo_h1_20_3 = lo_h1_20_2 - amp_h1;
      double lo_h1_20_4 = lo_h1_20_3 - amp_h1;
      double lo_h1_20_5 = lo_h1_20_4 - amp_h1;


      double price = SymbolInfoDouble(symbol, SYMBOL_BID);

      string type = "";
      bool buy_cond = false;


      if((buy_cond == false) && (StringFind(find_trend, TREND_BUY) >=0) && (price < lo_h1_20_2) && (lo_h1_20_2 < lo_h4_20_2))
        {
         buy_cond = true;
         type = "b2.";
        }
      if((buy_cond == false) && (StringFind(find_trend, TREND_BUY) >=0) && (price < lo_h1_20_3) && (lo_h1_20_3 < lo_h4_20_2))
        {
         buy_cond = true;
         type = "b3.";
        }

      bool sel_cond = false;

      if((sel_cond == false) && (StringFind(find_trend, TREND_SEL) >=0) && (price > hi_h1_20_2) && (hi_h1_20_2 > hi_h4_20_2))
        {
         sel_cond = true;
         type = "s2.";
        }

      if((sel_cond == false) && (StringFind(find_trend, TREND_SEL) >=0) && (price > hi_h1_20_3) && (hi_h1_20_3 > hi_h4_20_2))
        {
         sel_cond = true;
         type = "s3.";
        }

      if(buy_cond || sel_cond)
        {
         double amp_discarded = amp_h1*0.1;
         double volume = dblLotsRisk(symbol, amp_h1, risk);
         volume1 = volume;
         volume2 = volume1 * 2;
         volume3 = volume2 * 2;

         //------------------------------------------
         if(buy_cond)
           {
            double tp_buy_1 = price + amp_h1 - amp_discarded;
            double entry_buy_2 = NormalizeDouble(price - amp_h1*2, digits);
            double entry_buy_3 = NormalizeDouble(price - amp_h1*3, digits);
            double sl_buy = NormalizeDouble(price - amp_h1*4, digits);

            m_trade.Buy(volume1, symbol, 0.0, sl_buy, tp_buy_1, type + note + ".EV_BB_BUY_1");
            m_trade.BuyLimit(volume2, entry_buy_2, symbol, sl_buy, price, 0, 0, type + note + ".EV_BB_BUY_2");
            m_trade.BuyLimit(volume3, entry_buy_3, symbol, sl_buy, entry_buy_2, 0, 0, type + note + ".EV_BB_BUY_3");

            Alert(get_vntime(), "  EV_BB_BUY: ", symbol);
           }
         //------------------------------------------
         if(sel_cond)
           {
            double tp_sel_1 = price - amp_h1 + amp_discarded;
            double entry_sel_2 = NormalizeDouble(price + amp_h1*2, digits);
            double entry_sel_3 = NormalizeDouble(price + amp_h1*3, digits);
            double sl_sel = NormalizeDouble(price + amp_h1*4, digits);

            m_trade.Sell(volume1, symbol, 0.0, sl_sel, tp_sel_1, type + note + ".EV_BB_SELL_1");
            m_trade.SellLimit(volume2, entry_sel_2, symbol, sl_sel, price, 0, 0, type + note + ".EV_BB_SELL_2");
            m_trade.SellLimit(volume3, entry_sel_3, symbol, sl_sel, entry_sel_2, 0, 0, type + note + ".EV_BB_SELL_3");

            Alert(get_vntime(), "  EV_BB_SELL: ", symbol);
           }
         //------------------------------------------
        }

     }

  }


//+------------------------------------------------------------------+
void trade_by_h4(string symbol)
  {
   double risk = format_double(dbRisk(), 2);
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double avg_amp_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol);
   double avg_amp_d = CalculateAverageCandleHeight(PERIOD_D1, symbol);

   double atr_14d = CalculateATR14(symbol, PERIOD_D1);
   double amp_d1_and_atr = avg_amp_d + atr_14d;

   if(amp_d1_and_atr <= 0)
      return;


   CandleData candle_heiken_h4_c1;
   CountHeikenList(symbol, PERIOD_H4, 1, candle_heiken_h4_c1);

   CandleData candle_heiken_d1_c1;
   CountHeikenList(symbol, PERIOD_D1, 1, candle_heiken_d1_c1);

   string waitting_symbol = "";
   bool is_market_close = IsMarketClose();


   int maLength = 50;
   double low_d1[];
   double hig_d1[];
   double close_d1[];

   ArrayResize(low_d1, maLength);
   ArrayResize(hig_d1, maLength);
   ArrayResize(close_d1, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      low_d1[i] = iLow(symbol, PERIOD_D1, i);
      hig_d1[i] = iHigh(symbol, PERIOD_D1, i);
      close_d1[i] = iLow(symbol, PERIOD_D1, i);
     }

   double min_50d = FindMinPrice(low_d1) + avg_amp_h4;
   double max_50d = FindMaxPrice(hig_d1) - avg_amp_h4;
   double d1_ma10 = CalculateMA(close_d1, 10, 1);

   double pre_close_d = iClose(symbol, PERIOD_D1, 1);
   string trend_ma10_d1 = pre_close_d > d1_ma10 ? TREND_BUY: TREND_SEL;

   double close_w = iClose(symbol, PERIOD_D1, 1);

   string str_heiken = "";
   string heiken_h4_0 = get_trend_by_heiken(symbol, PERIOD_H4, 0);
   string heiken_h4_1 = candle_heiken_h4_c1.trend;
   int count_h4_c1 = candle_heiken_h4_c1.count;

   string heiken_d0 = get_trend_by_heiken(symbol, PERIOD_D1, 0);
   string heiken_d1 = get_trend_by_heiken(symbol, PERIOD_D1, 1);

   str_heiken += "    ma10_d1: "   + trend_ma10_d1;
   str_heiken += "    heiken_d1: " + heiken_d1;
   str_heiken += "    heiken_d0: " + heiken_d0;

   str_heiken += "    heiken_h4: " + heiken_h4_1;
   str_heiken += " " + (string) count_h4_c1;
   str_heiken += "    heiken_h0: " + heiken_h4_0;
//------------------------------------------------------------------
   if(is_market_close)
     {
      string message = get_vntime() + "(BB_Guardian) Market Close (Sat, Sun, 3 < Vn.Hour < 7).";
      message += "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$\n";
      message += str_heiken;

      Comment(message);
      return;
     }
   else
     {
      string str_risk  =  "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";
      str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
      str_risk += "    " + _Symbol;
      string comment = get_vntime() + " (BB_Guardian) Market Open " + str_risk + get_volume_cur_symbol() + "   " + waitting_symbol  + "\n";
      comment += str_heiken;

      Comment(comment);
     }
//------------------------------------------------------------------
   string macd_d1 = trend_by_macd(symbol, PERIOD_D1, 0);
   string stoc_d1 = action_by_stoc(symbol, PERIOD_D1);
   string stoc_h4 = action_by_stoc(symbol, PERIOD_H4);
   string stoc_h1 = action_by_stoc(symbol, PERIOD_H1);

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
   int total_trade = 0;
   string lowcase_symbol = toLower(symbol);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(StringFind(OrderGetString(ORDER_COMMENT), "EV_BB_") >= 0)
         continue;

      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);
      if(lowcase_symbol == order_symbol)
        {
         total_trade = total_trade + 1;
        }
     }

   double profit = 0;
   int possion_count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string pos_comments = PositionGetString(POSITION_COMMENT);

      if(StringFind(pos_comments, "EV_BB_") >= 0)
         continue;

      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         ulong ticket = PositionGetTicket(i);
         double cur_profit = PositionGetDouble(POSITION_PROFIT);

         // --------------------------------------------------------
         total_trade = total_trade + 1;
         possion_count += 1;
         profit += cur_profit;
         // --------------------------------------------------------

         string trade_trend = "";
         if(StringFind(pos_comments, TREND_BUY) >= 0)
            trade_trend = TREND_BUY;
         if(StringFind(pos_comments, TREND_SEL) >= 0)
            trade_trend = TREND_SEL;
         // --------------------------------------------------------
         bool is_position_trade = false;
         if(StringFind(pos_comments, POSITON_TRARE) >= 0)
            is_position_trade = true;
         // --------------------------------------------------------
         double price_sl = PositionGetDouble(POSITION_SL);
         double price_tp = PositionGetDouble(POSITION_TP);
         if((trade_trend == TREND_BUY) && (price_tp != max_50d))
           {
            m_trade.PositionModify(ticket, price_sl, max_50d);
           }

         if((trade_trend == TREND_SEL) && (price_tp != min_50d))
           {
            m_trade.PositionModify(ticket, price_sl, min_50d);
           }
         //-------------------------------------------------------
         if(profit < 0)
           {
            if((heiken_h4_1 != trade_trend) && (heiken_h4_0 != trade_trend))
              {
               datetime current_time = TimeCurrent();
               datetime open_time = (datetime) PositionGetInteger(POSITION_TIME);
               if(current_time - open_time > 48 * 60*60)   // đổi thành giây (8 * 60 * 60)
                 {
                  m_trade.PositionClose(ticket);
                  Alert("Đóng lệnh âm sau 2 ngày. ", symbol, "   Profit: ", profit);
                 }
              }
           }

         //------------normal_trade------------
         if(is_position_trade == false)
           {
            if((heiken_h4_1 != trade_trend) && (heiken_h4_0 != trade_trend) && (trade_trend != stoc_h4) && (trade_trend != stoc_h1))
              {
               m_trade.PositionClose(ticket);
              }

            if(trade_trend != stoc_h4)
              {
               double ma_50_m5 = CalculateMA_XX(symbol, PERIOD_M5, 50, 1);
               if(trade_trend == TREND_BUY && price > ma_50_m5)
                 {
                  m_trade.PositionClose(ticket);
                  return;
                 }
              }
           }

         //---------TRAILING_STOP----------
         if(profit > risk/3)
           {
            //------------position_trade---------------------------
            if(is_position_trade)
              {
               if((macd_d1 == TREND_BUY || macd_d1 == TREND_SEL) && (macd_d1 != trade_trend))
                  m_trade.PositionClose(ticket);
              }
            //-------------------------------------------------------
            double price_sl = PositionGetDouble(POSITION_SL);
            double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
            if(price_open != price_sl)
              {
               double amp_moved = MathAbs(pre_close_d - price_sl);
               int num = int(MathRound(amp_moved / amp_d1_and_atr));
               if(num >= 1)
                 {
                  double sl_buy_new = pre_close_d - avg_amp_d;
                  double sl_sel_new = pre_close_d + avg_amp_d;

                  if(profit > risk)
                    {
                     if(sl_buy_new > price_open)
                        sl_buy_new = price_open;

                     if(sl_sel_new < price_open)
                        sl_sel_new = price_open;
                    }

                  if((StringFind(pos_comments, TREND_BUY) >= 0) && (price_sl < sl_buy_new))
                    {
                     m_trade.PositionModify(ticket, sl_buy_new, max_50d + avg_amp_d);
                    }

                  if((StringFind(pos_comments, TREND_SEL) >= 0) && (price_sl > sl_sel_new))
                    {
                     m_trade.PositionModify(ticket, sl_sel_new, min_50d - avg_amp_d);
                    }

                  Alert(get_vntime(), "(TRAILING_STOP) : ", symbol, "   ", pos_comments);
                 }
              }
           }
         //---------TRAILING_STOP----------
        }
     } //for

   if((total_trade > 0) && (possion_count == 0))
      CloseOrders(symbol);
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------

//TREND_BUY
//TREND_SEL
//MAC_POSITION_BUY
//MAC_POSITION_SEL
//STOC_TP_BUY_OPEN_SEL
//STOC_TP_SEL_OPEN_BUY

   string note = "";
   string tren_action = "";
   string evil_action = "";
   if(macd_d1 == MAC_POSITION_BUY)
     {
      tren_action = TREND_BUY;
      note = POSITON_TRARE + "D" + TREND_BUY;
     }
   if(tren_action == "" && macd_d1 == stoc_d1 && macd_d1 == stoc_h4 && macd_d1 == stoc_h1)
     {
      tren_action = TREND_BUY;
      note = "H" + TREND_BUY;
     }

   if(tren_action == "")
     {
      if(macd_d1 == TREND_BUY && stoc_d1 == TREND_SEL)
        {
         evil_action = TREND_SEL;
         note = "EV";
        }
      if(macd_d1 == TREND_SEL && stoc_d1 == TREND_BUY)
        {
         evil_action = TREND_BUY;
         note = "EV";
        }

      if(evil_action == stoc_h4 && evil_action == stoc_h1)
        {
         Evil_Trade(symbol, evil_action, "sD=41");
        }
     }
//---------------------------------------------------
   if(tren_action != "")
     {
      //----------------------------------------------------------------------------
      if(total_trade == 0 && allow_trade_by_candle(symbol, heiken_h4_1, PERIOD_W1, 25))
        {
         bool has_trade = false;

         if(has_trade == false)
            has_trade = trade_x1_10_20_50(PERIOD_M5, "05", symbol, heiken_h4_1, amp_d1_and_atr, avg_amp_h4, str_heiken, min_50d, max_50d);

         if(has_trade == false)
            has_trade = trade_x1_10_20_50(PERIOD_M10, "10", symbol, heiken_h4_1, amp_d1_and_atr, avg_amp_h4, str_heiken, min_50d, max_50d);

         if(has_trade == false)
            has_trade = trade_x1_10_20_50(PERIOD_M12, "12", symbol, heiken_h4_1, amp_d1_and_atr, avg_amp_h4, str_heiken, min_50d, max_50d);

         if(has_trade == false)
            has_trade = trade_x1_10_20_50(PERIOD_M15, "15", symbol, heiken_h4_1, amp_d1_and_atr, avg_amp_h4, str_heiken, min_50d, max_50d);
        }
     }
//---------------------------------------------------
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool trade_x1_10_20_50(ENUM_TIMEFRAMES TIME_FRAME, string prifix, string symbol, string ref_trend, double amp_d1_and_atr, double avg_amp_d, string note,double min_50d,double max_50d)
  {
   bool has_trade = false;

   if(ref_trend == "")
      return has_trade;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   int maLength = 55;
   double close_prices_xx[];
   ArrayResize(close_prices_xx, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      close_prices_xx[i] = iClose(symbol, TIME_FRAME, i);
     }

   double ma10 = CalculateMA(close_prices_xx, 10, 0);
   double ma20 = CalculateMA(close_prices_xx, 20, 0);
   double ma50 = CalculateMA(close_prices_xx, 50, 0);

   bool buy_cond = (ref_trend == TREND_BUY) && (price > ma10) && (price > ma20) && (price > ma50) && (price + avg_amp_d < max_50d);
   bool sel_cond = (ref_trend == TREND_SEL) && (price < ma10) && (price < ma20) && (price < ma50) && (price - avg_amp_d > min_50d);

   if(buy_cond || sel_cond)
     {
      double low_h1[];
      double hig_h1[];
      ArrayResize(low_h1, maLength);
      ArrayResize(hig_h1, maLength);
      for(int i = maLength - 1; i >= 0; i--)
        {
         low_h1[i] = iLow(symbol, PERIOD_H1, i);
         hig_h1[i] = iHigh(symbol, PERIOD_H1, i);
        }
      double en_buy_h1 = FindMinPrice(low_h1);
      if(en_buy_h1 > price - avg_amp_d)
         en_buy_h1 = NormalizeDouble(price - avg_amp_d, digits);

      double en_sel_h1 = FindMaxPrice(hig_h1);
      if(en_sel_h1 < price + avg_amp_d)
         en_sel_h1 = NormalizeDouble(price + avg_amp_d, digits);

      double amp_drop_1 = NormalizeDouble(amp_d1_and_atr * 0.1, digits);

      double volume = dblLotsRisk(symbol, amp_d1_and_atr, dbRisk());
      double sl_buy = NormalizeDouble(price - amp_d1_and_atr, digits);
      double tp_buy = max_50d;

      double sl_sell = NormalizeDouble(price + amp_d1_and_atr, digits);
      double tp_sell = min_50d;

      string short_note = get_short_note(note);

      //------------------------------------------
      if(buy_cond)
        {
         has_trade = true;

         m_trade.Buy(volume, symbol, 0.0, sl_buy, tp_buy, short_note + prifix + "_01_" + TREND_BUY);

         m_trade.BuyLimit(volume, en_buy_h1, symbol, sl_buy - amp_drop_1, tp_buy - amp_drop_1, 0, 0, short_note + prifix + "_02_" + TREND_BUY);

         Alert(get_vntime(), "  BUY: ", symbol, "  Price:", price, "   note: ", note, "   short_note: ", short_note);
        }
      //------------------------------------------
      if(sel_cond)
        {
         has_trade = true;

         m_trade.Sell(volume, symbol, 0.0, sl_sell, tp_sell, short_note + prifix + "_01_" + TREND_SEL);

         m_trade.SellLimit(volume, en_sel_h1, symbol, sl_sell + amp_drop_1, tp_sell + amp_drop_1, 0, 0, short_note + prifix + "_02_" + TREND_SEL);

         Alert(get_vntime(), "  SELL: ", symbol, "  Price:", price, "   note: ", note, "   short_note: ", short_note);
        }
      //------------------------------------------
     }

   return has_trade;
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
string get_short_note(string note)
  {
   string short_note = note;
   StringReplace(short_note, "ma10_w1", "w");
   StringReplace(short_note, "heiken_w1", "");
   StringReplace(short_note, "heiken_w0", "");

   StringReplace(short_note, "ma10_d1", "d");
   StringReplace(short_note, "heiken_d1", "");
   StringReplace(short_note, "heiken_d0", "");

   StringReplace(short_note, "heiken_h4", "_h");
   StringReplace(short_note, "heiken_h0", "");

   StringReplace(short_note, "BUY", "B");
   StringReplace(short_note, "SELL", "S");
   StringReplace(short_note, ":", "");
   StringReplace(short_note, " ", "");

   short_note = "(" + short_note + ")";

   return short_note;
  }
//+------------------------------------------------------------------+

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
void Clean_BB_Trade(string symbol)
  {
   double total_profit = 0;
   string possion_comments = "";
   string order_comments = "";
   string type = "";
   string lowcase_symbol = toLower(symbol);

   int count_possion = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = toLower(PositionGetSymbol(i));
      string trading_comment = PositionGetString(POSITION_COMMENT);

      if((lowcase_symbol == trading_symbol) && (StringFind(trading_comment, "BB_") >= 0))
        {
         count_possion += 1;
        }
     }

   int count_orders = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      string order_comment = OrderGetString(ORDER_COMMENT);
      string order_symbol = toLower(OrderGetString(ORDER_SYMBOL));

      if((lowcase_symbol == order_symbol) && (StringFind(order_comment, "BB_") >= 0))
        {
         count_orders += 1;
        }
     }
//-------------------------------------------------------------------------
// đóng 1 lệnh là đóng cả 3 lệnh.
   int total_trade = count_possion + count_orders;
   if(((1 <= total_trade) && (total_trade < 3)) || (total_profit > dbRisk()))
     {

      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         string trading_symbol = toLower(PositionGetSymbol(i));
         string trading_comment = PositionGetString(POSITION_COMMENT);
         ulong ticket = PositionGetTicket(i);
         if((lowcase_symbol == trading_symbol) && (StringFind(trading_comment, "BB_") >= 0))
           {
            m_trade.PositionClose(ticket);
           }
        }

      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong orderTicket = OrderGetTicket(i);
         string order_symbol = toLower(OrderGetString(ORDER_SYMBOL));
         string order_comment = OrderGetString(ORDER_COMMENT);

         if((lowcase_symbol == order_symbol) && (StringFind(order_comment, "BB_") >= 0))
           {
            m_trade.OrderDelete(orderTicket);
           }
        }

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
   string trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, trend, 0);
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
         if(haTrend == candleArray[j].trend)
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
//|                                                                  |
//+------------------------------------------------------------------+
string trend_by_macd_week(string symbol)
  {
   int m_handle_macd = iMACD(symbol, PERIOD_W1, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return "";
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_signal);

   double main_black    = m_buff_MACD_main[0];
   double signal_red    = m_buff_MACD_main[0];
//-------------------------------------------------
   if(main_black > signal_red)
      return TREND_BUY;

   if(main_black < signal_red)
      return TREND_SEL;

   if(main_black > 0)
      return TREND_BUY;

   if(main_black < 0)
      return TREND_SEL;

   return signal_red > 0? TREND_BUY : TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string trend_vector_signal(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_signal,true);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[2];
   double m_signal_3 = m_buff_MACD_signal[3];
//-------------------------------------------------
   if((m_signal_1 > m_signal_2) && (m_signal_2 > m_signal_3))
     {
      return TREND_BUY;
     }
//-------------------------------------------------
   if((m_signal_1 < m_signal_2) && (m_signal_2 < m_signal_3))
     {
      return TREND_SEL;
     }
//-------------------------------------------------
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string trend_by_macd(string symbol, ENUM_TIMEFRAMES timeframe, int candle_no)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_signal,true);
   CopyBuffer(m_handle_macd, 1, 0, candle_no + 5, m_buff_MACD_signal);

   double m_signal_x = m_buff_MACD_signal[candle_no];
//-------------------------------------------------
   if(m_signal_x > 0)
     {
      return TREND_BUY;
     }
//-------------------------------------------------
   if(m_signal_x < 0)
     {
      return TREND_SEL;
     }
//-------------------------------------------------
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string switch_trend_by_macd(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_signal,true);
   CopyBuffer(m_handle_macd, 1, 0, 10, m_buff_MACD_signal);

   double m_signal_previou_1 = m_buff_MACD_signal[1];
   double m_signal_previou_2 = m_buff_MACD_signal[2];
//-------------------------------------------------
   if((m_signal_previou_1 > 0) && (0 > m_signal_previou_2))
     {
      return TREND_BUY;
     }
//-------------------------------------------------
   if((m_signal_previou_1 < 0) && (0 < m_signal_previou_2))
     {
      return TREND_SEL;
     }
//-------------------------------------------------
   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string find_buy_sell_by_macd_black_and_signal_red(string symbol, ENUM_TIMEFRAMES timeframe)
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
   double m_macd_previous    = m_buff_MACD_main[1];

   double m_signal_current  = m_buff_MACD_signal[0];
   double m_signal_previous = m_buff_MACD_signal[1];
//-------------------------------------------------
   string find_trend = "";
   if(m_signal_current > 0 && m_signal_previous > 0)
     {
      find_trend += TREND_BUY;
     }
   if(m_signal_current > 0 && m_signal_previous < 0)
     {
      find_trend += TREND_BUY;
     }
//-------------------------------------------------
   if(m_signal_current < 0 && m_signal_previous < 0)
     {
      find_trend += TREND_SEL;
     }
   if(m_signal_current < 0 && m_signal_previous > 0)
     {
      find_trend += TREND_SEL;
     }
//-------------------------------------------------
   if(m_signal_current < 0 && m_signal_previous < m_macd_current && m_signal_previous < m_macd_current)
     {
      find_trend += TREND_BUY; // cho phép bắt đáy khi đánh theo BB
     }

   if(m_signal_current > 0 && m_signal_previous > m_macd_current && m_signal_previous > m_macd_current)
     {
      find_trend += TREND_SEL; // cho phép bắt đỉnh khi đánh theo BB
     }
//-------------------------------------------------
   if(m_macd_previous < 0 && m_signal_previous < m_macd_current && m_signal_previous < m_macd_current)
     {
      find_trend += TREND_BUY; // cho phép bắt đáy khi đánh theo BB
     }

   if(m_macd_previous > 0 && m_signal_previous > m_macd_current && m_signal_previous > m_macd_current)
     {
      find_trend += TREND_SEL; // cho phép bắt đỉnh khi đánh theo BB
     }
//-------------------------------------------------
   return find_trend;
  }

//+------------------------------------------------------------------+
string trend_by_vector_macd(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_signal,true);
   CopyBuffer(m_handle_macd, 1, 0, 10, m_buff_MACD_signal);
   double m_signal_pre_1 = m_buff_MACD_signal[1];
   double m_signal_pre_2 = m_buff_MACD_signal[2];

//-------------------------------------------------
   if(m_signal_pre_1 > m_signal_pre_2)
     {
      return TREND_BUY;
     }

   if(m_signal_pre_1 < m_signal_pre_2)
     {
      return TREND_SEL;
     }

   return "";
  }
//+------------------------------------------------------------------+
string action_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string stoch = "";

   int periodK = 5; // %K
   int periodD = 3; // %D
   int slowing = 3; // Slowing

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
   if(redD < blackK && blackK < 60)
     {
      return TREND_BUY;
     }

   if(redD > blackK && blackK > 60)
     {
      return TREND_SEL;
     }

   if(blackK <= 20 || redD <= 20)
     {
      return STOC_TP_SEL_OPEN_BUY;
     }

   if(blackK >= 80 || redD >= 80)
     {
      return STOC_TP_BUY_OPEN_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
string get_vntime()
  {
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;
   string gmt = " (GMT: " + ((current_gmt_hour < 10) ? "0" + (string) current_gmt_hour : (string) current_gmt_hour) + "h) ";

   datetime vietnamTime = TimeCurrent() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + gmt;
   return vntime;
  }

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
double CalculateMA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

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
//|                                                                  |
//+------------------------------------------------------------------+
double dbRisk()
  {
//double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
//                                  AccountInfoDouble(ACCOUNT_BALANCE)),
//                             AccountInfoDouble(ACCOUNT_MARGIN_FREE));
//double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;
   double dbValueRisk = INIT_EQUITY * dbRiskRatio;


   return format_double(dbValueRisk, 2);
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

   if((dbTickSize>0) && (dbLotsStep > 0))
     {
      double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
      if(dbLossOrder > 0)
        {
         double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
         double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
         double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

         if(roundedLotSize < 0.01)
            roundedLotSize = 0.01;

         return roundedLotSize;
        }
     }

   return 0.01;
  }
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+

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
   TimeToStruct(TimeCurrent(), date_time);
   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;
   int row_count = 0;
// --------------------------------------------------------------------
// --------------------------------------------------------------------
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   HistorySelect(0, TimeCurrent()); // today closed trades PL
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

// Hàm để lấy dữ liệu từ Dictionary
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &lot_size_per_500usd)
  {
   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      amp_w = 1060.00;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "DX")
     {
      i_top_price = 106.8;
      amp_w = 0.69500;
      lot_size_per_500usd = 7.00;
      return;
     }
   if(symbol == "USOIL.cash")
     {
      i_top_price = 99.85;
      amp_w = 2.50000;
      lot_size_per_500usd = 1.75;
      return;
     }
   if(symbol == "XAGUSD")
     {
      i_top_price = 28.380;
      amp_w = 0.63500;
      lot_size_per_500usd = 0.15;
      return;
     }
   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      amp_w = 22.9500;
      lot_size_per_500usd = 0.20;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 15920;
      amp_w = 271.500;
      lot_size_per_500usd = 1.75;
      return;
     }
   if(symbol == "US30.cash")
     {
      i_top_price = 35700;
      amp_w = 388.350;
      lot_size_per_500usd = 1.00;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.6500;
      amp_w = 1.07795;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "AUDUSD")
     {
      i_top_price = 0.72000;
      amp_w = 0.00765;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "EURAUD")
     {
      i_top_price = 1.73000;
      amp_w = 0.01375;
      lot_size_per_500usd = 0.50;
      return;
     }
   if(symbol == "EURGBP")
     {
      i_top_price = 0.90265;
      amp_w = 0.00455;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "EURUSD")
     {
      i_top_price = 1.12500;
      amp_w = 0.00790;
      lot_size_per_500usd = 0.60;
      return;
     }
   if(symbol == "GBPUSD")
     {
      i_top_price = 1.31365;
      amp_w = 0.01085;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.40775;
      amp_w = 0.00795;
      lot_size_per_500usd = 0.85;
      return;
     }
   if(symbol == "USDCHF")
     {
      i_top_price = 0.94235;
      amp_w = 0.00715;
      lot_size_per_500usd = 0.60;
      return;
     }
   if(symbol == "USDJPY")
     {
      i_top_price = 154.395;
      amp_w = 1.29500;
      lot_size_per_500usd = 0.50;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.70200;
      amp_w = 0.00500;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "CADJPY")
     {
      i_top_price = 112.000;
      amp_w = 1.00000;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "CHFJPY")
     {
      i_top_price = 169.320;
      amp_w = 1.41000;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "EURJPY")
     {
      i_top_price = 162.065;
      amp_w = 1.39000;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "GBPJPY")
     {
      i_top_price = 188.115;
      amp_w = 1.61500;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "NZDJPY")
     {
      i_top_price = 90.7000;
      amp_w = 0.90000;
      lot_size_per_500usd = 0.70;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.51938;
      amp_w = 0.00945;
      lot_size_per_500usd = 0.70;
      return;
     }
   if(symbol == "EURCHF")
     {
      i_top_price = 1.01016;
      amp_w = 0.00455;
      lot_size_per_500usd = 1.00;
      return;
     }
   if(symbol == "EURNZD")
     {
      i_top_price = 1.89388;
      amp_w = 0.01585;
      lot_size_per_500usd = 0.50;
      return;
     }
   if(symbol == "GBPAUD")
     {
      i_top_price = 2.02830;
      amp_w = 0.01605;
      lot_size_per_500usd = 0.45;
      return;
     }
   if(symbol == "GBPCAD")
     {
      i_top_price = 1.75620;
      amp_w = 0.01210;
      lot_size_per_500usd = 0.55;
      return;
     }
   if(symbol == "GBPCHF")
     {
      i_top_price = 1.16955;
      amp_w = 0.00685;
      lot_size_per_500usd = 0.65;
      return;
     }
   if(symbol == "GBPNZD")
     {
      i_top_price = 2.18685;
      amp_w = 0.01705;
      lot_size_per_500usd = 0.45;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.94763;
      amp_w = 0.00735;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "AUDCHF")
     {
      i_top_price = 0.65518;
      amp_w = 0.00545;
      lot_size_per_500usd = 0.85;
      return;
     }
   if(symbol == "AUDNZD")
     {
      i_top_price = 1.11568;
      amp_w = 0.00595;
      lot_size_per_500usd = 1.25;
      return;
     }
   if(symbol == "NZDCAD")
     {
      i_top_price = 0.87860;
      amp_w = 0.00725;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "NZDCHF")
     {
      i_top_price = 0.58565;
      amp_w = 0.00515;
      lot_size_per_500usd = 0.90;
      return;
     }
   if(symbol == "NZDUSD")
     {
      i_top_price = 0.65315;
      amp_w = 0.00670;
      lot_size_per_500usd = 0.70;
      return;
     }


   i_top_price = iClose(symbol, PERIOD_W1, 1);
   amp_w =  calc_avg_amp_week(symbol, 20);
   lot_size_per_500usd = 0;

//Alert(" Add Symbol Data:",  symbol, " amp:", amp_w);
   return;

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double CalcMaxCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   int length = 50;
   double max_height = 0.0;

   for(int i = 0; i < length; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = MathAbs(highPrice - lowPrice);

      if(max_height < candleHeight)
         max_height = candleHeight;
     }

   return max_height;
  }

//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;
   int length = 50;
// Tính tổng chiều cao của 10 cây nến M1
   int count = 0;
   for(int i = 0; i < length; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      if(highPrice <= 0.0)
         continue;

      double lowPrice = iLow(symbol, timeframe, i);
      if(lowPrice <= 0.0)
         continue;

      double candleHeight = highPrice - lowPrice;

      if(candleHeight > 0)
        {
         totalHeight += candleHeight;
         count += 1;
        }
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / count;

   return format_double(averageHeight, 5);
  }

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
string get_volume_cur_symbol()
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_lot_size;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_lot_size);
   double week_amp = dic_amp_w;
   double risk_per_trade = dbRisk();
   string volume = " Vol: " + format_double_to_string(dblLotsRisk(_Symbol, week_amp, risk_per_trade), 2) + "    ";

   return volume;
  }
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool allow_trade_by_candle(string symbol, string find_trend, ENUM_TIMEFRAMES timeframe, int mum_of_candles)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int count_candle = 0;
   double close_prices_d1[];
   ArrayResize(close_prices_d1, mum_of_candles);
   for(int i = mum_of_candles - 1; i >= 0; i--)
     {
      double temp_close = iClose(symbol, timeframe, i);
      if(temp_close > 0)
         count_candle += 1;

      close_prices_d1[i] = temp_close;
     }

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
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, "        " + format_double_to_string(price, digits), clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, "        " + label, clr_color);
  }

//+------------------------------------------------------------------+
void create_lable_trim(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, label, clr_color, "Arial", 8, 0.0, ANCHOR_CENTER);
  }

//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                string                  text="Text",              // the text itself
                const color             clr=clrRed,               // color
                const string            font="Arial",             // font
                const int               font_size=8,             // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,     // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,             // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
//ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text

   ObjectSetString(chart_ID,name,OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE, angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR, anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR, clr);

//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, back);

//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, selection);

   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, selection);

//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, hidden);

//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, z_order);
//--- successful execution

   return(true);
  }
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const bool              ray_left = false,
   const bool              ray_right = true,
   const bool              is_solid_line = false
)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
     }
   else
     {
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

//create_lable(name, time_to, price, clr_color, digits);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void DrawBB()
  {
//ObjectsDeleteAll();

   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   datetime label_postion = iTime(symbol, PERIOD_CURRENT, 0);

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
   CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
   double hi_h1_20_1 = upper_h1_20_1[0];
   double mi_h1_20_0 = middle_h1_20_1[0];
   double lo_h1_20_1 = lower_h1_20_1[0];

   double amp_h1 = MathAbs(hi_h1_20_1 - mi_h1_20_0);

   string str_stop = "          H1(00)";
   double avg_amp_h1 = CalculateAverageCandleHeight(PERIOD_H1, symbol);
   if(amp_h1 < avg_amp_h1)
      str_stop = " STOP_BY_AMP ";


   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
   double hi_h4_20_2 = upper_h4[0];
   double lo_h4_20_2 = lower_h4  [0];

//TextCreate(0, "Hi_H4(20, 2)", 0, label_postion, hi_h4_20_2, "H4(+2)______________" + str_line, clrRed, "Arial", 8, 0)
   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, "H4(+2)______________" + str_line, clrRed, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, "H4(-2)______________" + str_line, clrRed, digits);

   create_lable_trim("lbl_mi_h1_20_0", label_postion, mi_h1_20_0, str_stop + "" + str_line, clrRed, digits);

   ObjectSetInteger(0, "mi_h1_20_0", OBJPROP_STYLE, STYLE_DASH);
   for(int i = 1; i<=5; i++)
     {
      bool is_solid = false;
      bool is_ray_left = (i==2) ? true : false;
      color line_color = clrBlack;
      if(i == 1)
         line_color = clrDimGray;
      if(i == 2)
         line_color = clrBlue;
      if(i == 3)
         line_color = clrMediumSeaGreen;
      if(i == 4)
         line_color = clrBlack;
      if(i == 5)
         line_color = clrRed;
      double hi_h1_20_i = mi_h1_20_0 + (i*amp_h1);
      double lo_h1_20_i = mi_h1_20_0 - (i*amp_h1);

      create_lable_trim("lbl_hi_h1_20_" + (string)i, label_postion, hi_h1_20_i, "          H1(+" + (string)i + ")" + str_line, line_color, digits);
      create_lable_trim("lbl_lo_h1_20_" + (string)i, label_postion, lo_h1_20_i, "          H1(-" + (string)i + ")" + str_line, line_color, digits);
     }
  }
//+------------------------------------------------------------------+
string get_trade_type(string comment)
  {
   string trade_trend = "";
   if((StringFind(comment, TREND_BUY) >= 0) || (StringFind(toLower(comment), "buy") >= 0))
      trade_trend = TREND_BUY;
   if((StringFind(comment, TREND_SEL) >= 0) || (StringFind(toLower(comment), "sel") >= 0))
      trade_trend = TREND_SEL;

   return trade_trend;
  }
//+------------------------------------------------------------------+
bool is_trading_symbol(string symbol, string trading_symbol, string comment, string prifix)
  {
   string lowcase_symbol = toLower(symbol);
   string lowcase_trading_symbol = toLower(trading_symbol);

   string lowcase_comment = toLower(comment);
   string lowcase_prifix = toLower(prifix);

   if((lowcase_symbol == lowcase_trading_symbol) && (StringFind(lowcase_comment, lowcase_prifix) >= 0))
     {
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//Không có lệnh thì cũng coi là true
bool is_trade_exceeded_hours(ulong max_ticket, int hours)
  {
   datetime current_time = TimeCurrent();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong cur_ticket = PositionGetTicket(i);
      if(cur_ticket == max_ticket)
        {
         datetime open_time = (datetime) PositionGetInteger(POSITION_TIME);
         if((current_time - open_time) < (hours * 3600))   // đổi thành giây (hours * 60*60)
            return false;
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//bool isOrderCurrentlyOpen = IsOrderOpen(ticketToCheck);
// Kiểm tra xem một lệnh có đang mở hay không
bool IsPositionOpening(int ticket)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong cur_ticket = PositionGetTicket(i);
      if(cur_ticket == ticket)
        {
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
void move_to_best_sl(string symbol, string prifix)
  {
   double best_sl_buy = 0;
   double best_sl_sel = 1000000;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string pos_symbol = PositionGetSymbol(i);
      string pos_comment = PositionGetString(POSITION_COMMENT);

      if(is_trading_symbol(symbol, pos_symbol, pos_comment, prifix))
        {
         double SL = PositionGetDouble(POSITION_SL);
         string trade_trend = get_trade_type(pos_comment);

         if((trade_trend == TREND_BUY) && (SL > 0) && (best_sl_buy < SL))
           {
            best_sl_buy = SL;
           }

         if((trade_trend == TREND_SEL) && (SL > 0) && (SL < best_sl_sel))
           {
            best_sl_sel = SL;
           }
        }

      //----------------------------------------------------------------------------

      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         string pos_symbol = PositionGetSymbol(i);
         string pos_comment = PositionGetString(POSITION_COMMENT);

         if(is_trading_symbol(symbol, pos_symbol, pos_comment, prifix))
           {
            //----------------------------------------------------------------------------
            string trade_trend = get_trade_type(pos_comment);
            double SL = PositionGetDouble(POSITION_SL);
            double TP = PositionGetDouble(POSITION_TP);

            if((trade_trend == TREND_BUY) && (SL < best_sl_buy))
              {
               m_trade.PositionModify(ticket, best_sl_buy, TP);
              }

            if((trade_trend == TREND_SEL) && (SL > best_sl_sel))
              {
               m_trade.PositionModify(ticket, best_sl_sel, TP);
              }
            //----------------------------------------------------------------------------
           }
        }

     }
  }
//+------------------------------------------------------------------+
//Di chuyển hết SL về giá vào lệnh nếu có thể, hoặc atr(m5)
//Đặt tp là giá đóng cửa cao nhất của 50 nến m5
void move_to_best_tp(string symbol, string prifix)
  {
   int maLength = 55;
   double close_prices_05[];
   ArrayResize(close_prices_05, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      close_prices_05[i] = iClose(symbol, PERIOD_M5, i);
     }
   double min_close_m5 = FindMinPrice(close_prices_05);
   double max_close_m5 = FindMaxPrice(close_prices_05);
   double amp_m5 = (max_close_m5 - min_close_m5);
   double amp_drop = amp_m5*0.2;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
//----------------------------------------------------------------------------
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      string pos_symbol = PositionGetSymbol(i);
      string pos_comment = PositionGetString(POSITION_COMMENT);

      if(is_trading_symbol(symbol, pos_symbol, pos_comment, prifix))
        {
         //----------------------------------------------------------------------------
         string trade_trend = get_trade_type(pos_comment);
         double SL = PositionGetDouble(POSITION_SL);
         double TP = PositionGetDouble(POSITION_TP);

         if((trade_trend == TREND_BUY) && (SL < min_close_m5) && (min_close_m5 < price - amp_drop) && (price + amp_drop < max_close_m5))
           {
            m_trade.PositionModify(ticket, min_close_m5, max_close_m5 + amp_drop);
           }

         if((trade_trend == TREND_SEL) && (SL > max_close_m5) && (max_close_m5 > price + amp_drop) && (price - amp_drop > min_close_m5))
           {
            m_trade.PositionModify(ticket, max_close_m5, min_close_m5 - amp_drop);
           }
         //----------------------------------------------------------------------------
        }
     }
  }

//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int ma_index)
  {
   double ma = CalculateMA_XX(symbol, TIMEFRAME, ma_index, 1);
   double close_c1 = iClose(symbol, TIMEFRAME, 1);

   return close_c1 > ma ? TREND_BUY : TREND_SEL;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/*
//----------------------------------------------------------------------------
double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
double price_sl = PositionGetDouble(POSITION_SL);
double price_tp = PositionGetDouble(POSITION_TP);
if(price_open != price_sl)
  {
   double price_sl = PositionGetDouble(POSITION_SL);
   double price_open = PositionGetDouble(POSITION_PRICE_OPEN);

   double amp_moved = MathAbs(price - price_open);
   int num = int(MathRound(amp_moved / amp_d1_and_atr));
   if(num >= 1)
     {
      double sl_buy_new = price - amp_d1_and_atr;
      double sl_sel_new = price + amp_d1_and_atr;

      if((StringFind(pos_comments, TREND_BUY) >= 0) && (price_sl < sl_buy_new))
        {
         m_trade.PositionModify(ticket, sl_buy_new, max_50d + amp_avg_d1);
        }

      if((StringFind(pos_comments, TREND_SEL) >= 0) && (price_sl > sl_sel_new))
        {
         m_trade.PositionModify(ticket, sl_sel_new, min_50d - amp_avg_d1);
        }

      Alert(get_vntime(), "(TRAILING_STOP) : ", symbol, "   ", pos_comments);
     }
  }
//----------------------------------------------------------------------------
*/

//trend_by_stoc_dk(symbol, PERIOD_CURRENT);

// Thắng nhưng ít kèo
//trend_by_macd(symbol, PERIOD_H4);
//string trend_stoc_d = trend_by_stoc_dk(symbol, PERIOD_D1);
//string trend_stoc_h4 = trend_by_stoc_dk(symbol, PERIOD_H4);
//if(trend_stoc_d == trend_stoc_h4)
//   Evil_Trade(symbol, trend_stoc_d, "sD=s4");

// Thua cháy
//string trend_stoc_h4 = trend_by_stoc_dk(symbol, PERIOD_H4);
//string trend_stoc_h1 = trend_by_stoc_dk(symbol, PERIOD_H1);
//if(trend_stoc_h4 == trend_stoc_h1)
//   Evil_Trade(symbol, trend_stoc_h4);

// Thua cháy
//string trend_stoc_h4 = trend_by_stoc_dk(symbol, PERIOD_H4);
//Evil_Trade(symbol, trend_stoc_h4);

// Không vào được lệnh, không có kèo
//string trend_stoc_h4 = trend_by_stoc_dk(symbol, PERIOD_H4);
//string trend_macd_h4 = trend_by_macd(symbol, PERIOD_H4);
//if(trend_stoc_h4 == trend_macd_h4)
//   Evil_Trade(symbol, trend_macd_h4, "s4=m4");

// sai, không sử dụng vector được.
//string trend_vector_macd_h4 = trend_by_vector_macd(symbol, PERIOD_H4);
//Evil_Trade(symbol, trend_vector_macd_h4);

// Thắng 100%, cần kiểm chứng lại vì ít kèo.
//string trend_macd_h4 = trend_by_macd(symbol, PERIOD_H4);
//Evil_Trade(symbol, trend_macd_h4);

// Thắng 100%, cần kiểm chứng lại vì ít kèo.
//trend_by_stoc_dk(symbol, PERIOD_CURRENT);
//string trend_allow_by_macd = find_buy_sell_by_macd_black_and_signal_red(symbol, PERIOD_H4);
//Evil_Trade(symbol, trend_allow_by_macd, "ma=cd");

//+------------------------------------------------------------------+
