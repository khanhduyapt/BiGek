//+------------------------------------------------------------------+
//|                                              SolomonSentinel.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;


double dbRiskRatio = 0.01; // Rủi ro 1%
double INIT_EQUITY = 20000.0; // Vốn đầu tư

string INDICES = "_USTEC_US30_US500_DE30_UK100_FR40_AUS200_BTCUSD_XAGUSD_";

string arr_main_symbol[] = {"DXY", "XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

string INDI_NAME = "Solomon";
string FILE_NAME_TRADINGLIST_LOG = "Solomon.log";

//Exness_Pro
string arr_symbol[] =
  {
   "XAUUSD"
//, "XAGUSD", "USOIL", "BTCUSD",
//"USTEC", "US30", "US500", "DE30", "UK100", "FR40", "AUS200",
//"AUDCHF", "AUDNZD", "AUDUSD",
//"AUDJPY", "CHFJPY", "EURJPY", "GBPJPY", "NZDJPY", "USDJPY",
//"EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURNZD", "EURUSD",
//"GBPCHF", "GBPNZD", "GBPUSD",
//"NZDCAD", "NZDUSD",
//"USDCAD", "USDCHF"
  };

string free_extended_overnight_fees[] =
  {
   "XAUUSD", "BTCUSD"
   , "AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY"
   , "AUDNZD", "EURCHF", "GBPJPY", "AUDCHF", "AUDJPY"
   , "EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD"
   , "GBPCHF", "GBPNZD"
   , "NZDJPY", "NZDCAD"
  };


string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string PREFIX_TRADE_PERIOD_MO = "Mn";
string PREFIX_TRADE_PERIOD_W1 = "W1";
string PREFIX_TRADE_PERIOD_D1 = "D1";
string PREFIX_TRADE_PERIOD_H4 = "H4";
string PREFIX_TRADE_PERIOD_H1 = "H1";
string PREFIX_TRADE_PERIOD_M5 = "M5";
string PREFIX_TRADE_PERIOD_M15 = "M15";

string MEMORY_STOPLOSS  = "@SL:";
string MEMORY_TICKET    = "@Ticket:";
string MEMORY_WATING    = "@TF:";
string STR_NEXT_ITEM    = "@NEXT@";

string FILE_TRADE_LIMIT          = "_no_delete_file_LimitTrade.log";
string FILE_NAME_OPEN_TRADE      = "_open_trade_today.txt";
string FILE_NAME_SEND_MSG        = "_send_msg_today.txt";
string FILE_NAME_ALERT_MSG       = "_alert_today.txt";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OPEN_TRADE    = "(OPEN_TRADE)";
string STOP_TRADE    = "(STOP_TRADE)";
string OPEN_ORDERS   = "(OPEN_ORDER)    ";
string STOP_LOSS     = "(STOP_LOSS)";
string AUTO_TRADE    = "(AUTO_TRADE)";

string MARKET_POSITION = "MK_";
string ORDER_POSITIONS = "OD_";
string KEY_CLOSE_POSITION = "(Solo)";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MAX_DCA = 5;
datetime LAST_OPEN_TRADE_TIME = TimeCurrent();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetExpertMagicNumber(20240320);

   Comment(GetComments());

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Comment(GetComments());

//if(IsMarketClose())
//   return;

   OpenTradeBy_AmpW1(_Symbol);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTradeBy_AmpW1(string symbol)
  {
   double amp_dca = get_amp_dca(symbol);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double best_tp_buy = 0, best_tp_sel = 0;
   double best_entry_buy = 0, best_entry_sel = 0;

   double max_volume_buy = 0, max_volume_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;

   int count_init_buy = 0;
   int count_init_sel = 0;

   int count_possion_buy = 0;
   int count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            total_profit += m_position.Profit() + m_position.Swap() + m_position.Commission();

            // --------------------------------------------------------
            if(StringFind(toLower(m_position.TypeDescription()), "buy") >= 0)
              {
               count_possion_buy += 1;
               total_profit_buy += m_position.Profit();

               total_volume_buy += m_position.Volume();
               if(max_volume_buy < m_position.Volume())
                  max_volume_buy = m_position.Volume();

               if(StringFind(toLower(m_position.TypeDescription()), "init") >= 0)
                  count_init_buy += 1;

               if(count_possion_buy == 1 || best_entry_buy > m_position.PriceOpen())
                 {
                  best_tp_buy = m_position.TakeProfit();
                  best_entry_buy = m_position.PriceOpen();
                 }
              }

            if(StringFind(toLower(m_position.TypeDescription()), "sel") >= 0)
              {
               count_possion_sel += 1;
               total_profit_sel += m_position.Profit();

               total_volume_sel += m_position.Volume();
               if(max_volume_sel < m_position.Volume())
                  max_volume_sel = m_position.Volume();

               if(StringFind(toLower(m_position.TypeDescription()), "init") >= 0)
                  count_init_sel += 1;

               if(count_possion_sel == 1 || best_entry_sel < m_position.PriceOpen())
                 {
                  best_tp_sel = m_position.TakeProfit();
                  best_entry_sel = m_position.PriceOpen();
                 }
              }
           }
        }
     } //for


   int count_order_buy = 0, count_order_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_order.Symbol())))  //&& (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            if(StringFind(toLower(m_order.TypeDescription()), "buy") >= 0)
              {
               count_order_buy += 1;
              }

            if(StringFind(toLower(m_order.TypeDescription()), "sel") >= 0)
              {
               count_order_sel += 1;
              }
           }
        }
     }


//------------------------------------------------------------------
   double risk = calcRisk();
   CandleData arr_heiken_h4[];
   get_arr_heiken(symbol, PERIOD_H4, arr_heiken_h4);
   CandleData arr_heiken_d1[];
   get_arr_heiken(symbol, PERIOD_D1, arr_heiken_d1);
   string trend_w1 = get_trend_by_stoc2(symbol, PERIOD_W1, 3, 3, 3, 0);
   string trend_d10 = get_trend_by_ma(symbol, PERIOD_D1, 10, 1);
   string trend_h4 = get_trend_by_stoc2(symbol, PERIOD_H4, 3, 3, 3, 0);

   double amp_buy_moved = (best_entry_buy - price);
   double amp_sel_moved = (price - best_entry_sel);
//------------------------------------------------------------------
   double default_volume = calc_volume_by_amp(symbol, amp_dca, risk);


   bool wd_allow_trade = (trend_d10 == trend_w1);
   if(wd_allow_trade == false)
      wd_allow_trade = is_allow_trade_now_by_stoc(symbol, PERIOD_D1, trend_w1);
   if(wd_allow_trade == false)
      wd_allow_trade = trend_w1 == get_trend_by_stoc853_ma7(symbol, PERIOD_D1);
//------------------------------------------------------------------
   if(wd_allow_trade)
     {
      if(trend_w1 == TREND_BUY)
         ClosePosition_TakeProfit(symbol, TREND_SEL, KEY_CLOSE_POSITION);

      if(trend_w1 == TREND_SEL)
         ClosePosition_TakeProfit(symbol, TREND_BUY, KEY_CLOSE_POSITION);
     }

   if(count_order_sel > 0 && count_possion_sel == 0)
      CloseOrders(symbol, TREND_SEL);

   if(count_order_buy > 0 && count_possion_buy == 0)
      CloseOrders(symbol, TREND_BUY);
//------------------------------------------------------------------
   bool is_hoding = false;
   if(LAST_OPEN_TRADE_TIME != iTime(symbol, PERIOD_H4, 0))
     {
      if(is_same_symbol(INDICES, symbol) && trend_w1 != TREND_BUY)
         return;

      string trend_h4_ma0710 = "";
      string trend_h4_ma1020 = "";
      string trend_h4_ma2050 = "";
      string trend_h4_C1ma10 = "";
      bool is_insign_h4 = false;
      get_trend_by_ma_seq71020_steadily(symbol, PERIOD_H4, trend_h4_ma0710, trend_h4_ma1020, trend_h4_ma2050, trend_h4_C1ma10, is_insign_h4);

      if(trend_h4 == trend_h4_ma0710 && trend_h4 == arr_heiken_h4[0].trend && trend_h4 == trend_w1 && wd_allow_trade)
        {
         double amp_w1;
         double amp_d1;
         double amp_h4;
         GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
         double tp_buy = NormalizeDouble(price + amp_h4, digits);
         double tp_sel = NormalizeDouble(price - amp_h4, digits);
         tp_buy = 0.0;
         tp_sel = 0.0;

         if(trend_w1 == trend_d10 && (trend_w1 == arr_heiken_d1[1].trend || trend_w1 == arr_heiken_d1[0].trend) &&
            arr_heiken_d1[1].count < 7 && (count_possion_buy + count_possion_sel <= 3))
           {
            is_hoding = true;

            if(is_has_memo_in_file(FILE_TRADE_LIMIT, PREFIX_TRADE_PERIOD_D1, symbol, trend_w1) == false)
              {
               if(Open_Market(symbol, trend_w1, default_volume, KEY_CLOSE_POSITION + "WD", 0.0))
                  add_memo_to_file(FILE_TRADE_LIMIT, PREFIX_TRADE_PERIOD_D1, symbol, trend_w1);
              }
           }



         if((count_possion_buy == 0 && count_order_buy == 0))
            if(trend_w1 == TREND_BUY && arr_heiken_h4[1].trend == TREND_BUY && arr_heiken_h4[0].trend == TREND_BUY)
               Open_Market(symbol, TREND_BUY, default_volume, KEY_CLOSE_POSITION + "No.1", tp_buy);

         if((count_possion_sel == 0 && count_order_sel == 0))
            if(trend_w1 == TREND_SEL && arr_heiken_h4[1].trend == TREND_SEL && arr_heiken_h4[0].trend == TREND_SEL)
               Open_Market(symbol, TREND_SEL, default_volume, KEY_CLOSE_POSITION + "No.1", tp_sel);



         if(trend_w1 == TREND_BUY && arr_heiken_h4[1].trend == TREND_BUY && arr_heiken_h4[0].trend == TREND_BUY)
            if((count_possion_buy > 0) && (count_possion_buy < MAX_DCA) && (amp_buy_moved > amp_dca))
              {
               int trade_no = count_possion_buy+1;
               double volume = calc_volume_by_amp(symbol, amp_dca, MathAbs(total_profit_buy) + risk);
               Open_Market(symbol, TREND_BUY, NormalizeDouble(volume, 2), KEY_CLOSE_POSITION + "No." + (string)(trade_no), 0.0);
              }

         if(trend_w1 == TREND_SEL && arr_heiken_h4[1].trend == TREND_SEL && arr_heiken_h4[0].trend == TREND_SEL)
            if((count_possion_sel > 0) && (count_possion_sel < MAX_DCA) && (amp_sel_moved > amp_dca))
              {
               int trade_no = count_possion_sel+1;
               double volume = calc_volume_by_amp(symbol, amp_dca, MathAbs(total_profit_sel) + risk);
               Open_Market(symbol, TREND_SEL, NormalizeDouble(volume, 2), KEY_CLOSE_POSITION + "No." + (string)(trade_no), 0.0);
              }

        }
     }

//------------------------------------------------------------------
   if(is_same_symbol(_Symbol, symbol) && wd_allow_trade)
     {
      double ma10d = iClose(symbol, Period(), 1);
      create_lable("FIND", TimeCurrent(), ma10d, "(W) " + trend_w1 + " (D10) " + trend_d10 + " c:" + (string) arr_heiken_d1[1].count);

      create_vertical_line(time2string(iTime(symbol, PERIOD_D1, 0)), iTime(symbol, PERIOD_D1, 0), clrBlack,  STYLE_DASHDOTDOT);
     }

   if(is_hoding == false && ((total_profit > risk) || (total_profit_buy > risk) || (total_profit_sel > risk)))
     {
      string trend_ma07 = get_trend_by_ma(symbol, PERIOD_H4, 7);

      if(total_profit > risk)
         if((total_profit_buy > total_profit_sel && (trend_ma07 != TREND_BUY || trend_h4 != TREND_BUY) && arr_heiken_h4[1].trend != TREND_BUY && arr_heiken_h4[0].trend != TREND_BUY) ||
            (total_profit_sel > total_profit_buy && (trend_ma07 != TREND_SEL || trend_h4 != TREND_SEL) && arr_heiken_h4[1].trend != TREND_SEL && arr_heiken_h4[0].trend != TREND_SEL))
           {
            create_lable(time2string(iTime(symbol, PERIOD_H4, 0)), iTime(symbol, PERIOD_H4, 0), price,
                         " P: " + (string) NormalizeDouble(total_profit, 1) + "$", total_profit > 0 ? TREND_BUY : TREND_SEL);

            ClosePosition(symbol, "", KEY_CLOSE_POSITION);
            return;
           }

      if(total_profit_buy > risk)
         if((trend_ma07 != TREND_BUY || trend_h4 != TREND_BUY) && arr_heiken_h4[1].trend != TREND_BUY && arr_heiken_h4[0].trend != TREND_BUY)
           {
            create_lable(time2string(iTime(symbol, PERIOD_H4, 0)), iTime(symbol, PERIOD_H4, 0), price,
                         " P: " + (string) NormalizeDouble(total_profit_buy, 1) + "$", total_profit_buy > 0 ? TREND_BUY : TREND_SEL);

            ClosePosition(symbol, TREND_BUY, KEY_CLOSE_POSITION);
            return;
           }

      if(total_profit_sel > risk)
         if((trend_ma07 != TREND_SEL || trend_h4 != TREND_SEL) && arr_heiken_h4[1].trend != TREND_SEL && arr_heiken_h4[0].trend != TREND_SEL)
           {
            create_lable(time2string(iTime(symbol, PERIOD_H4, 0)), iTime(symbol, PERIOD_H4, 0), price,
                         " P: " + (string) NormalizeDouble(total_profit_sel, 1) + "$", total_profit_sel > 0 ? TREND_BUY : TREND_SEL);

            ClosePosition(symbol, TREND_SEL, KEY_CLOSE_POSITION);
            return;
           }
     }
//------------------------------------------------------------------

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp(string symbol, string TRADING_TREND, double tp_price, string KEY_TO_CLOSE)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(KEY_TO_CLOSE == "" || (StringFind(toLower(m_position.Comment()), toLower(KEY_TO_CLOSE)) >= 0))
               if(StringFind(toLower(m_position.TypeDescription()), toLower(TRADING_TREND)) >= 0)
                  if(m_position.TakeProfit() != tp_price)
                     m_trade.PositionModify(m_position.Ticket(), m_position.StopLoss(), tp_price);
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Market(string symbol, string TRADING_TREND, double volume, string KEY_CLOSE, double tp_price)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double open1 = iOpen(symbol, PERIOD_H1, 1);
   double close1 = iClose(symbol, PERIOD_H1, 1);

   bool allow_trade_now = false;
   if(TRADING_TREND == TREND_BUY && (price <= MathMin(open1, close1)))
      allow_trade_now = true;
   if(TRADING_TREND == TREND_SEL && (price >= MathMax(open1, close1)))
      allow_trade_now = true;
   if(allow_trade_now == false)
      return false;

   if(LAST_OPEN_TRADE_TIME == iTime(symbol, PERIOD_H4, 0))
      return false;
   LAST_OPEN_TRADE_TIME = iTime(symbol, PERIOD_H4, 0);

   double sl_buy = price - get_amp_dca(symbol)*MAX_DCA;
   double sl_sel = price + get_amp_dca(symbol)*MAX_DCA;

   if(TRADING_TREND == TREND_BUY)
     {
      if(m_trade.Buy(volume,  symbol, 0.0, 0.0, tp_price, MARKET_POSITION + "BUY_" + KEY_CLOSE))
         return true;
     }

   if(TRADING_TREND == TREND_SEL)
     {
      if(m_trade.Sell(volume, symbol, 0.0, 0.0, tp_price, MARKET_POSITION + "SEL_" + KEY_CLOSE))
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_trade_no(int trade_no)
  {
   if(trade_no == 1)
      return 0.01;
   if(trade_no == 2)
      return 0.02;
   if(trade_no == 3)
      return 0.03;
   if(trade_no == 4)
      return 0.05;
   if(trade_no == 5)
      return 0.08;
   if(trade_no == 6)
      return 0.19;
   if(trade_no == 7)
      return 0.34;
   if(trade_no == 8)
      return 0.42;
   if(trade_no == 9)
      return 0.61;
   if(trade_no == 10)
      return 0.88;
   if(trade_no == 11)
      return 1.86;
   if(trade_no == 12)
      return 3.2;
   if(trade_no == 13)
      return 6.3;

   return 0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void Open_OrderLimit(string symbol, string TRADING_TREND, double volume, string KEY_CLOSE, double entry_price)
//  {
//   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
//
//   double sl = 0.0;
//   double tp = 0.0;
//   double amp_dca = get_amp_dca(symbol);
//
//   if(TRADING_TREND == TREND_BUY)
//     {
//      m_trade.BuyLimit(0.02, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_02" + KEY_CLOSE);
//      m_trade.BuyLimit(0.03, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_03" + KEY_CLOSE);
//      m_trade.BuyLimit(0.05, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_04" + KEY_CLOSE);
//      m_trade.BuyLimit(0.08, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_05" + KEY_CLOSE);
//      m_trade.BuyLimit(0.20, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_06" + KEY_CLOSE);
//      m_trade.BuyLimit(0.34, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_07" + KEY_CLOSE);
//      m_trade.BuyLimit(0.42, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_08" + KEY_CLOSE);
//      m_trade.BuyLimit(0.61, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_09" + KEY_CLOSE);
//      m_trade.BuyLimit(0.88, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_10" + KEY_CLOSE);
//      m_trade.BuyLimit(1.86, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_11" + KEY_CLOSE);
//      m_trade.BuyLimit(3.20, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_12" + KEY_CLOSE);
//      m_trade.BuyLimit(6.30, price + amp_dca*1, symbol, sl, price + amp_dca*1, 0, 0, ORDER_POSITIONS + "BUY_13" + KEY_CLOSE);
//     }
//
//   if(TRADING_TREND == TREND_SEL)
//     {
//      tp = price - amp_tp;
//      m_trade.SellLimit(volume, entry_price, symbol, sl, tp, 0, 0, ORDER_POSITIONS + "SEL_" + KEY_CLOSE);
//     }
//  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string trading_trend, string KEY_TO_CLOSE)
  {
   string msg = "";
   double profit = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(trading_trend == "" || (StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0))
               if(KEY_TO_CLOSE == "" || (StringFind(toLower(m_position.Comment()), toLower(KEY_TO_CLOSE)) >= 0))
                 {
                  msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                  profit += m_position.Profit();
                  m_trade.PositionClose(m_position.Ticket());
                 }
     } //for

   if(msg != "")
      SendTelegramMessage(symbol, STOP_TRADE, STOP_TRADE + " " + trading_trend + "  " + symbol + "   Total: " + (string) profit + "$ ");

   CloseOrders(symbol, trading_trend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition_TakeProfit(string symbol, string trading_trend, string KEY_CLOSE)
  {
   string msg = "";
   double profit = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0)
               if(KEY_CLOSE == "" || (StringFind(m_position.Comment(), KEY_CLOSE) >= 0))
                  if(m_position.Profit() > 1)
                    {
                     msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                     profit += m_position.Profit();
                     m_trade.PositionClose(m_position.Ticket());
                    }
     } //for

   if(msg != "")
      SendTelegramMessage(symbol, "TAKE_PROFIT", "(TAKE.PROFIT) " + AppendSpaces(symbol) + " (H4) " + " Total: " + (string) profit + "$ " + msg);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders(string symbol, string trading_trend)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
            if(StringFind(toLower(m_order.TypeDescription()), toLower(trading_trend)) >= 0)
              {
               m_trade.OrderDelete(m_order.Ticket());
              }
        }
     }
  }


//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

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
void get_trend_by_ma_seq71020_steadily(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string &trend_ma0710, string &trend_ma1020, string &trend_ma02050, string &trend_C1ma10, bool &insign_h4)
  {
   trend_ma0710 = "";
   trend_ma1020 = "";
   trend_ma02050 = "";
   trend_C1ma10 = "";

   int count = 0;
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }

   double ma07[5];
   double ma10[5];
   double ma20[5];
   for(int i = 0; i < 5; i++)
     {
      ma07[i] = cal_MA(closePrices, 7, i);
      ma10[i] = cal_MA(closePrices, 10, i);
      ma20[i] = cal_MA(closePrices, 20, i);
     }
   double ma50_0 = cal_MA(closePrices, 50, 0);
   double ma50_1 = cal_MA(closePrices, 50, 1);
   trend_ma02050 = ma20[0] > ma50_0 ? TREND_BUY : TREND_SEL;

   double avg_amp_h4 = get_amp_dca(symbol);
   double ma_min = MathMin(MathMin(MathMin(ma07[0], ma10[0]), ma20[0]), ma50_0);
   double ma_max = MathMax(MathMax(MathMax(ma07[0], ma10[0]), ma20[0]), ma50_0);
   insign_h4 = false;
   if(MathAbs(ma_max - ma_min) < avg_amp_h4*2)
      insign_h4 = true;

// Nếu có ít nhất một cặp giá trị không tăng dần, trả về ""
   string seq_buy_07 = TREND_BUY;
   string seq_buy_10 = TREND_BUY;
   string seq_buy_20 = TREND_BUY;
// Nếu có ít nhất một cặp giá trị không giảm dần, trả về ""
   string seq_sel_07 = TREND_SEL;
   string seq_sel_10 = TREND_SEL;
   string seq_sel_20 = TREND_SEL;

   for(int i = 0; i < 3; i++)
     {
      // BUY
      if(ma07[i] < ma07[i + 1])
         seq_buy_07 = "";
      if(ma10[i] < ma10[i + 1])
         seq_buy_10 = "";
      if(ma20[i] < ma20[i + 1])
         seq_buy_20 = "";

      //SEL
      if(ma07[i] > ma07[i + 1])
         seq_sel_07 = "";
      if(ma10[i] > ma10[i + 1])
         seq_sel_10 = "";
      if(ma20[i] > ma20[i + 1])
         seq_sel_20 = "";
     }
   string trend_ma07_vs10 = ma07[0] > ma10[0] ? TREND_BUY : TREND_SEL;
   string trend_ma10_vs20 = ma10[0] > ma20[0] ? TREND_BUY : TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10 == TREND_BUY && seq_buy_20 == TREND_BUY)
      trend_ma1020 = TREND_BUY;
   if(seq_buy_10 == TREND_BUY && trend_ma10_vs20 == TREND_BUY)
      trend_ma1020 = TREND_BUY;


   if(seq_sel_10 == TREND_SEL && seq_sel_20 == TREND_SEL)
      trend_ma1020 = TREND_SEL;

   if(seq_sel_10 == TREND_SEL && trend_ma10_vs20 == TREND_SEL)
      trend_ma1020 = TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10 == TREND_BUY && seq_buy_07 == TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(seq_buy_07 == TREND_BUY && trend_ma07_vs10 == TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(closePrices[2] > ma07[2] && closePrices[1] > ma07[1] &&
      closePrices[2] > ma10[2] && closePrices[1] > ma10[1])
      trend_ma0710 = TREND_BUY;

   if(seq_sel_10 == TREND_SEL && seq_sel_07 == TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(seq_sel_07 == TREND_SEL && trend_ma07_vs10 == TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(closePrices[2] < ma07[2] && closePrices[1] < ma07[1] &&
      closePrices[2] < ma10[2] && closePrices[1] < ma10[1])
      trend_ma0710 = TREND_SEL;


   if(closePrices[1] > ma10[1])
      trend_C1ma10 = TREND_BUY;

   if(closePrices[1] < ma10[1])
      trend_C1ma10 = TREND_SEL;

//----------------------------------------------------------------
//   if(TIMEFRAME == PERIOD_H4)
//     {
//      datetime time1 = iTime(symbol, TIMEFRAME, 1);
//      datetime time0 = iTime(symbol, TIMEFRAME, 0);
//      string drawtime = time2string(time1);
//
//      if(trend_ma02050 != "")
//         create_lable_trim("ma50" + drawtime, time1, ma50_1,  trend_ma02050  == TREND_BUY ? "50b": "50s",  trend_ma02050 == TREND_BUY ? clrBlue : clrRed, 5, 6, ANCHOR_CENTER);
//
//
//      create_line("ma20_1_0" + drawtime, time1, ma20[1], time0, ma20[0], clrBlack, STYLE_DASHDOTDOT, 1, false, false);
//      if(trend_ma1020 != "")
//         create_lable_trim("ma20" + drawtime, time1, ma20[1], trend_ma1020 == TREND_BUY ? "20b": "20s", trend_ma1020 == TREND_BUY ? clrBlue : clrRed, 5, 6, ANCHOR_CENTER);
//
//
//      create_line("ma10_1_0" + drawtime, time1, ma10[1], time0, ma10[0], clrBlack, STYLE_DOT, 1, false, false);
//      if(trend_C1ma10 != "")
//         create_lable_trim("ma10" + drawtime, time1, ma10[1],   trend_C1ma10 == TREND_BUY ? "10b": "10s",   trend_C1ma10 == TREND_BUY ? clrBlue : clrRed, 5, 6, ANCHOR_CENTER);
//     }


//   double close_d1 = iClose(symbol, PERIOD_D1, 1);
//   double close_d0_low = iLow(symbol, PERIOD_D1, 0);
//   double close_d0_hig = iHigh(symbol, PERIOD_D1, 0);
//   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
//
//   string d_prefix = "rule";//time2string(iTime(symbol, PERIOD_D1, 0));
//   datetime time = TimeCurrent() ;//+ (iTime(symbol, PERIOD_H4, 1) - iTime(symbol, PERIOD_H4, 2));
//   create_lable_trim("lc1" + d_prefix, time, close_d1, (string)NormalizeDouble(close_d1, digits), clrBlue, 5, 8, ANCHOR_CENTER);
//
//   create_lable_trim("lup" + d_prefix, time, close_d0_hig, (string)NormalizeDouble(close_d0_hig - close_d1, digits), clrBlue, 5, 8, ANCHOR_CENTER);
//   create_lable_trim("ldn" + d_prefix, time, close_d0_low, (string)NormalizeDouble(close_d1 - close_d0_low, digits), clrRed, 5, 8, ANCHOR_CENTER);
//
//   create_line("up" + d_prefix,        time, close_d1, time, close_d0_hig, clrBlue, STYLE_SOLID, 2, false, false);
//   create_line("dn" + d_prefix,        time, close_d1, time, close_d0_low, clrRed, STYLE_SOLID, 2, false, false);
//
//   create_lable_trim("aup" + d_prefix, time, close_d1 + avg_amp_h4, "+" + (string)NormalizeDouble(avg_amp_h4, digits), clrRed, 5, 8, ANCHOR_CENTER);
//   create_lable_trim("adn" + d_prefix, time, close_d1 - avg_amp_h4, "-" + (string)NormalizeDouble(avg_amp_h4, digits), clrRed, 5, 8, ANCHOR_CENTER);
//
//   create_vertical_line("v" + d_prefix, iTime(symbol, PERIOD_D1, 0), clrBlack,  STYLE_DASHDOTDOT);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPriceAmp()
  {
   string file_name = "AMP.txt";

   if(is_has_memo_in_file(file_name, PREFIX_TRADE_PERIOD_MO, "RE_CALC_MONLY", "AMP_WDH") == false)
     {
      int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

      if(fileHandle != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            string file_contents = symbol
                                   + "~" + "(W1)" + (string) CalculateAverageCandleHeight(PERIOD_W1, symbol, 120)
                                   + "~" + "(D1)" + (string) CalculateAverageCandleHeight(PERIOD_D1, symbol, 360)
                                   + "~" + "(H4)" + (string) CalculateAverageCandleHeight(PERIOD_H4, symbol, 720)
                                   + ";";

            FileWriteString(fileHandle, file_contents);
           }

         FileClose(fileHandle);
        }

      add_memo_to_file(file_name, PREFIX_TRADE_PERIOD_MO, "RE_CALC_MONLY", "AMP_WDH");
     }

// Mở tệp để đọc
   int file_handle = FileOpen(file_name, FILE_READ);
   if(file_handle == INVALID_HANDLE)
     {
      Print("Error opening file ", file_name);
      return CalculateAverageCandleHeight(PERIOD_W1, symbol, 12);
     }

// Duyệt qua từng dòng trong tệp
   string contents;
   while(!FileIsEnding(file_handle))
     {
      // Đọc mỗi dòng trong tệp
      contents = FileReadString(file_handle);

      ushort tab_delimiter = StringGetCharacter("~",0);
      ushort line_delimiter = StringGetCharacter(";",0);

      string lines[];
      StringSplit(contents, line_delimiter, lines);

      for(int i= 0; i<ArraySize(lines); i++)
        {
         string line = lines[i];
         if(is_same_symbol(line, symbol))
           {
            //Print(line);
            string tabs[];
            StringSplit(line, tab_delimiter, tabs);
            for(int j= 0; j<ArraySize(tabs); j++)
              {
               if(is_same_symbol(tabs[j], timeframe))
                 {
                  string amp = tabs[j];
                  StringReplace(amp, "(", "");
                  StringReplace(amp, timeframe, "");
                  StringReplace(amp, ")", "");
                  StringReplace(amp, " ", "");

                  double price_range = StringToDouble(amp);
                  FileClose(file_handle);

                  if(price_range > 0)
                     return price_range;
                 }
              }
           }
        }

     }

// Đóng tệp và trả về giá trị mặc định nếu không tìm thấy
   FileClose(file_handle);
   Print("GetPriceAmp not found for ", symbol, " ", timeframe);

   return CalculateAverageCandleHeight(PERIOD_W1, symbol, 12);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_amp_dca(string symbol)
  {
   if(is_same_symbol("XAU", symbol))
      return 10;

   double amp_w1;
   double amp_d1;
   double amp_h4;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   return amp_d1;
  }

////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//double get_amp_tp(string symbol)
//  {
////if(is_same_symbol("XAU", symbol))
////   return 5;
//
//   double amp_w1;
//   double amp_d1;
//   double amp_h4;
//   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
//
//   return 1;
//  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_in_note(string note)
  {
   if(StringFind(note, TREND_BUY) >= 0)
      return TREND_BUY;

   if(StringFind(note, TREND_SEL) >= 0)
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double amp_dca = get_amp_dca(_Symbol);

   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(_Symbol, amp_dca, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + _Symbol;

   str_comments += "    Vol: " + volume_bt + " lot";
   str_comments += "    Funds: " + (string) INIT_EQUITY + "$ / Risk: " + (string) risk + "$ / " + (string)(dbRiskRatio * 100) + "%    ";

//str_comments += "\n";
   double amp_w1;
   double amp_d1;
   double amp_h4;
   GetAmpAvg(_Symbol, amp_w1, amp_d1, amp_h4);
   str_comments += "    Avg(H4): " + (string) amp_h4;
   str_comments += "    Avg(D1): " + (string) amp_d1;
   str_comments += "    Avg(W1): " + (string) amp_w1;
   str_comments += "    Dca: " + (string) amp_dca;

   if(IsMarketClose())
      str_comments += "    MarketClose";
   else
      str_comments += "    Market Open";
   str_comments += "    " + get_profit_today();


   return str_comments;
  }


//+------------------------------------------------------------------+
bool IsMarketClose()
  {
   datetime currentGMTTime = TimeGMT();

   MqlDateTime dtw;
   TimeToStruct(currentGMTTime, dtw);
   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dtw.day_of_week;

   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
      return true; // It's the weekend

   int gmtOffset = 7;
   datetime vietnamTime = currentGMTTime + gmtOffset * 3600;

   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
   int currentHour = dt.hour;
   if(18 <= currentHour && currentHour <= 20)
      return true; //started US session, and strong news
   if(3 < currentHour && currentHour < 7)
      return true; //VietnamEarlyMorning

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trading_key(string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND)
  {
// "@TF:H4:BUY:XAUUSD;"

   string today = (string)iTime(symbol, PERIOD_D1, 0);
   StringReplace(today, " ", "");
   StringReplace(today, ":", "");
   StringReplace(today, ".", "");
   StringReplace(today, "000000", "");

   return today + MEMORY_WATING + PREFIX_TRADE_PERIOD_XX + ":" + TRADING_TREND + ":" + symbol + ";";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today = (string)time;
   StringReplace(today, " ", "");
   StringReplace(today, ":", "");
   StringReplace(today, ".", "");

   return today;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= candle_no + ma_index; i++)
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
double cal_MA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = cal_MA(closePrices, ma_index);
   return ma_value;
  }



//+------------------------------------------------------------------+
string get_prefix_trade_from_timeframe(ENUM_TIMEFRAMES period)
  {
   if(period == PERIOD_M5)
      return PREFIX_TRADE_PERIOD_M5;

   if(period == PERIOD_M15)
      return PREFIX_TRADE_PERIOD_M15;

   if(period ==  PERIOD_H1)
      return PREFIX_TRADE_PERIOD_H1;

   if(period ==  PERIOD_H4)
      return PREFIX_TRADE_PERIOD_H4;

   if(period ==  PERIOD_D1)
      return PREFIX_TRADE_PERIOD_D1;

   if(period ==  PERIOD_W1)
      return PREFIX_TRADE_PERIOD_W1;

   if(period ==  PERIOD_MN1)
      return PREFIX_TRADE_PERIOD_MO;

   return PREFIX_TRADE_PERIOD_H4;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_pre_timeframe(string PREFIX_TRADE_PERIOD)
  {
   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_W1)
      return PERIOD_D1;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_D1)
      return PERIOD_H4;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_H4)
      return PERIOD_H1;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_H1)
      return PERIOD_M15;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_M15)
      return PERIOD_M5;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_M5)
      return PERIOD_M5;

   return PERIOD_H1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_prefix_trade_from_comments(string comments)
  {
   string low_comments = toLower(comments);

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_W1)) >= 0)
      return PREFIX_TRADE_PERIOD_W1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
      return PREFIX_TRADE_PERIOD_D1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
      return PREFIX_TRADE_PERIOD_H4;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H1)) >= 0)
      return PREFIX_TRADE_PERIOD_H1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M15)) >= 0)
      return PREFIX_TRADE_PERIOD_M15;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M5)) >= 0)
      return PREFIX_TRADE_PERIOD_M5;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_cur_timeframe(string PREFIX_TRADE_PERIOD)
  {
   string TRADE_PERIOD = "";
   string low_comments =toLower(PREFIX_TRADE_PERIOD);

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_W1)) >= 0)
      return PERIOD_W1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
      return PERIOD_D1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
      return PERIOD_H4;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H1)) >= 0)
      return PERIOD_H1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M15)) >= 0)
      return PERIOD_M15;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M5)) >= 0)
      return PERIOD_M5;

   return PERIOD_H4;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_timeframe(string PREFIX_TRADE_PERIOD_XX)
  {
   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_W1)
      return PERIOD_W1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_D1)
      return PERIOD_D1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_H4)
      return PERIOD_H4;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_H1)
      return PERIOD_H1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_M15)
      return PERIOD_M15;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_M5)
      return PERIOD_M5;

   return PERIOD_D1;
  }


//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
   if(Period() == PERIOD_M5)
      return "M5";

   if(Period() ==  PERIOD_H1)
      return "H1";

   if(Period() ==  PERIOD_H4)
      return "H4";

   if(Period() ==  PERIOD_D1)
      return "D1";

   if(Period() ==  PERIOD_W1)
      return "W1";

   return "??";
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
//|                                                                  |
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

   return NormalizeDouble(roundedLotSize, 2);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_volume_by_amp(string symbol, double amp_trade, double risk)
  {
   return dblLotsRisk(symbol, amp_trade, risk);
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
   StringReplace(cpu, "i5-", "");

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES);
   StringReplace(str_date_time, (string)gmt_time.year + ".", "");
   string vntime = "(" + str_date_time + ")    " + cpu + "   " + INDI_NAME + "   ";
   StringReplace(vntime, "GuardianAngel", "");
   return vntime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY)
  {
   ENUM_TIMEFRAMES TIMEFRAME = get_timeframe(PREFIX_TRADE_PERIOD_XX);
   string date_time = (string)iTime(symbol, TIMEFRAME, 0);
   StringReplace(date_time, ":", "");

   string key = date_time + ":" + PREFIX_TRADE_PERIOD_XX + ":" + TRADING_TREND_KEY + ":" + symbol +";";
   StringReplace(key, " ", "_");
   StringReplace(key, ".", "");
   StringReplace(key, "::", ":");
   StringReplace(key, ":", ":");

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(PREFIX_TRADE_PERIOD_XX, symbol, TRADING_TREND_KEY);
   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void remove_memo_from_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY)
  {
   string file_contents = ReadFileContent(filename);

   string key_find = create_key(PREFIX_TRADE_PERIOD_XX, symbol, TRADING_TREND_KEY);
   bool has_value = StringFind(file_contents, key_find) >= 0;

   if(has_value)
     {
      StringReplace(file_contents, key_find, "");
      WriteFileContent(filename, file_contents);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY, string note_stoploss = "", ulong ticket = 0, string note = "")
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(PREFIX_TRADE_PERIOD_XX, symbol, TRADING_TREND_KEY);

   open_trade_today = open_trade_today + key;

   if(StringLen(note_stoploss) > 1 || note_stoploss != "")
     {
      open_trade_today += MEMORY_STOPLOSS + note_stoploss;
      open_trade_today += MEMORY_TICKET + (string) ticket;
     }

   if(note != "")
      open_trade_today += note;

   open_trade_today += STR_NEXT_ITEM;

   WriteFileContent(filename, open_trade_today);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteFileContent(string file_name, string content)
  {
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      string file_contents = CutString(content);

      FileWriteString(fileHandle, file_contents);
      FileClose(fileHandle);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int max_lengh = 100000;
   int originalLength = StringLen(originalString);
   if(originalLength > max_lengh)
     {
      int startIndex = originalLength - max_lengh;
      return StringSubstr(originalString, startIndex, max_lengh);
     }
   return originalString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadFileContent(string file_name)
  {
   string fileContent = "";
   int fileHandle = FileOpen(file_name, FILE_READ);

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



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_profit_today()
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

      string symbol  = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if(symbol == "")
        {
         continue;
        }

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

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

   double swap = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         swap += m_position.Swap();
        }
     } //for


   double starting_balance = current_balance - PL;
   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double loss = current_equity - starting_balance;

   string result = "    Swap:" + format_double_to_string(swap, 2) + "$";
   result += "    Profit Today:" + format_double_to_string(loss, 2) + "$";

   if(loss + INIT_EQUITY*0.1 < 0)
      result += STOP_TRADE;

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol, int length)
  {
   int count = 0;
   double totalHeight = 0.0;

   for(int i = 0; i < length; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      count += 1;
      totalHeight += candleHeight;
     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double averageHeight = NormalizeDouble(totalHeight / count, digits);

   return averageHeight;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og, string symbol_tg)
  {
   if(symbol_og == "" || symbol_og == "")
      return false;

   if(StringFind(toLower(symbol_og), toLower(symbol_tg)) >= 0)
      return true;

   if(StringFind(toLower(symbol_tg), toLower(symbol_og)) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string free_overnight(string symbol)
  {
   int free_size = ArraySize(free_extended_overnight_fees);
   for(int index = 0; index < free_size; index++)
     {
      string fre_symbol = free_extended_overnight_fees[index];
      if(is_same_symbol(fre_symbol, symbol))
         return " (Zf)";
     }

   return "";
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
string AppendSpaces(string inputString, int totalLength = 10, bool is_append_right = true)
  {
   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
      return (inputString);

   int spacesToAdd = totalLength - currentLength;
   string spaces = "";
   for(int index = 1; index <= spacesToAdd; index++)
      spaces+= " ";

   if(is_append_right)
      return (inputString + spaces);
   else
      return (spaces + inputString);

  }

//+------------------------------------------------------------------+
string format_double_to_string(double number, int digits = 5)
  {

   string numberString = (string) NormalizeDouble(number, digits);
   StringReplace(numberString, "000000000001", "");
   StringReplace(numberString, "999999999999", "9");
   StringReplace(numberString, "999999999998", "9");
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
void get_arr_candlestick(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15)
  {
   ArrayResize(candleArray, length+5);
   for(int index = length + 3; index >= 0; index--)
     {
      datetime          time  = iTime(symbol, TIME_FRAME, index);    // Thời gian
      double            open  = iOpen(symbol, TIME_FRAME, index);    // Giá mở
      double            high  = iHigh(symbol, TIME_FRAME, index);    // Giá cao
      double            low   = iLow(symbol, TIME_FRAME, index);      // Giá thấp
      double            close = iClose(symbol, TIME_FRAME, index);  // Giá đóng
      string            trend = "";
      if(open < close)
         trend = TREND_BUY;
      if(open > close)
         trend = TREND_SEL;

      CandleData candle(time, open, high, low, close, trend, 0);
      candleArray[index] = candle;
     }


   for(int index = length + 3; index >= 0; index--)
     {
      CandleData cancle_i = candleArray[index];

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(cancle_i.trend == candleArray[j].trend)
            count_trend += 1;
         else
            break;
        }

      candleArray[index].count = count_trend;
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15)
  {
   ArrayResize(candleArray, length+5);

   datetime pre_HaTime = iTime(symbol, TIME_FRAME, length+4);
   double pre_HaOpen = iOpen(symbol, TIME_FRAME, length+4);
   double pre_HaHigh = iHigh(symbol, TIME_FRAME, length+4);
   double pre_HaLow = iLow(symbol, TIME_FRAME, length+4);
   double pre_HaClose = iClose(symbol, TIME_FRAME, length+4);
   string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0);
   candleArray[length+4] = candle;

   for(int index = length + 3; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen  = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen, haClose), iHigh(symbol, TIME_FRAME, index));
      double haLow   = MathMin(MathMin(haOpen, haClose),  iLow(symbol, TIME_FRAME, index));

      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
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
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDojiHeikenAshi(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   double open = candleArray[candle_index].open;
   double high = candleArray[candle_index].high;
   double low = candleArray[candle_index].low;
   double close = candleArray[candle_index].close;


   double body = MathAbs(open - close) * 3;
   double shadow_hig = high - MathMax(open, close);
   double shadow_low = MathMin(open, close) - low;

   bool isDoji = (body <= shadow_hig) && (body <= shadow_low); // Kiểm tra thân nến có nhỏ hơn 50% dải bóng không

   return isDoji;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_candlestick(string symbol, ENUM_TIMEFRAMES TIME_FRAME, string TRADING_TREND)
  {
   double open  = iOpen(symbol,  TIME_FRAME, 1);
   double high  = iHigh(symbol,  TIME_FRAME, 1);
   double low   = iLow(symbol,   TIME_FRAME, 1);
   double close = iClose(symbol, TIME_FRAME, 1);

   double body = MathAbs(open - close);
   double shadow_hig = high - MathMax(open, close);
   double shadow_low = MathMin(open, close) - low;

   bool is_hammer = false;
   if(TRADING_TREND == TREND_SEL)
      is_hammer = (body*3 <= shadow_low);

   if(TRADING_TREND == TREND_BUY)
      is_hammer = (body*3 <= shadow_hig);

   if(is_hammer)
     {
      int count = 0;
      for(int i = 2; i <= 20; i++)
        {
         if(TRADING_TREND == TREND_BUY)
            if(close > iClose(symbol, TIME_FRAME, i))
               count += 1;

         if(TRADING_TREND == TREND_SEL)
            if(close < iClose(symbol, TIME_FRAME, i))
               count += 1;
        }

      if(count >= 15)
        {
         //color clrColor = TRADING_TREND == TREND_BUY ? clrBlue : clrRed;
         //string lbl_name = "hammer_" + get_prefix_trade_from_timeframe(TIME_FRAME) + time2string(iTime(symbol, TIME_FRAME, 1));
         //create_lable_trim(lbl_name, iTime(symbol, TIME_FRAME, 1), close, "Hammer", clrColor, 5, 8, ANCHOR_RIGHT);

         return true;
        }
     }

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string symbol, string trend, string message)
  {
   if(is_has_memo_in_file(FILE_NAME_ALERT_MSG, PREFIX_TRADE_PERIOD_H1, symbol, trend))
      return;
   add_memo_to_file(FILE_NAME_ALERT_MSG, PREFIX_TRADE_PERIOD_H1, symbol, trend);

   Alert(get_vntime(), message);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol, string trend, string message)
  {
   if(is_has_memo_in_file(FILE_NAME_SEND_MSG, PREFIX_TRADE_PERIOD_H4, symbol, trend))
      return;
   add_memo_to_file(FILE_NAME_SEND_MSG, PREFIX_TRADE_PERIOD_H4, symbol, trend);

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

//if(StringFind(message, "OPEN_TRADE") >= 0)
//  {
//   string str_count_trade = CountTrade(symbol);
//   bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
//   bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;
//
//   if(trend == TREND_BUY && has_position_buy)
//      return;
//
//   if(trend == TREND_SEL && has_position_sel)
//      return;
//
//   if(is_allow_send_msg_telegram(symbol, PERIOD_W1, 10, trend) == false)
//      return;
//  }

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   string str_cur_price = " price:" + (string) price;

   Alert(get_vntime(), message + str_cur_price);

   string new_message = get_vntime() + message + str_cur_price;

   StringReplace(new_message, " ", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, OPEN_TRADE, "");
   StringReplace(new_message, "_", "%20");
   StringReplace(new_message, " ", "%20");

   string base_url="https://api.telegram.org";
   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s", base_url, botToken, chatId_duydk, new_message);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout = 60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
      Alert("WebRequest Error:", GetLastError(), ", URL: ", url, ", Headers: ", headers, "   ", MB_ICONERROR);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const string            trading_trend="BUY"
)
  {
   color clr_color = trading_trend==TREND_BUY ? clrBlue : clrRed;
   TextCreate(0,name, 0, time_to, price, "        " + label, clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                string                  text="Text",              // the text itself
                const color             clr=clrRed,               // color
                const string            font="Arial",             // font
                const int               font_size=8,              // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,       // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__, ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetString(0,name,OBJPROP_FONT, font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(0,name,OBJPROP_ANGLE, angle);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0,name,OBJPROP_COLOR, clr);
   ObjectSetInteger(0,name,OBJPROP_BACK, back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED, selection);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER, z_order);
   return(true);
  }

//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool create_vertical_line(
   const string          name0="VLine",      // line name
   datetime              time=0,            // line time
   const color           clr=clrBlack,        // line color
   const ENUM_LINE_STYLE style=STYLE_DOT, // line style
   const int             width=1,           // line width
   const bool            back=true,        // in the background
   const bool            selection=false,    // highlight to move
   const bool            ray=false,          // line's continuation down
   const bool            hidden=true,      // hidden in the object list
   const long            z_order=0)         // priority for mouse click
  {
//string name = STR_RE_DRAW + name0;
   string name = name0;
   int sub_window=0;      // subwindow index

   if(!time)
      time=TimeGMT();

   ResetLastError();

   if(!ObjectCreate(0,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__, ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name,OBJPROP_RAY,ray);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
   ObjectSetInteger(0,name, OBJPROP_BACK, true);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_amp(string symbol, ENUM_TIMEFRAMES timeframe, int maLength = 55)
  {
   double lowest = 0.0, higest = 0.0;
   for(int i = 0; i <= maLength; i++)
     {
      double low = iLow(symbol, timeframe, i);
      double hig = iHigh(symbol, timeframe, i);

      if((i == 0) || (lowest > low))
         lowest = low;

      if((i == 0) || (higest < hig))
         higest = hig;
     }

   double amp_low_hig = MathAbs(higest - lowest) / 3.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(price > MathAbs(higest - amp_low_hig))
      return TREND_SEL;

   if(price < MathAbs(lowest + amp_low_hig))
      return TREND_BUY;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   return candleArray[candle_index].trend;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index,int candle_no = 1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close_1 = closePrices[candle_no];
   double ma = cal_MA(closePrices, ma_index, candle_no);

   if(close_1 > ma)
      return TREND_BUY;

   if(close_1 < ma)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 3, 3, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 5, 3, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 8, 5, 3))
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_BuyAtBottom_SellAtTop_by_iStochastic(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   int handle = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[1];
   double red_D = D[1];

   if(find_trend == TREND_BUY && black_K >= red_D && red_D <= 20)
      return true;
//if(find_trend == TREND_BUY && black_K >= red_D && (K[1] <= 20 || K[2] <= 20 || D[0] <= 20 || D[1] <= 20))
//   return true;

   if(find_trend == TREND_SEL && black_K <= red_D && red_D >= 80)
      return true;
//if(find_trend == TREND_SEL && black_K <= red_D && (K[1] >= 80 || K[2] >= 80 || D[0] >= 80 || D[1] >= 80))
//   return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc853_ma7(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_ma7 = get_trend_by_ma(symbol, timeframe, 7, 1);
   if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 8, 5, 3, 0))
      if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 5, 3, 3, 0))
         if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 3, 3, 3, 0))
            return trend_ma7;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol, ENUM_TIMEFRAMES timeframe, int inK = 13, int inD = 8, int inS = 5, int candle_no = 0)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K = K[candle_no];
   double red_D = D[candle_no];

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_10, int ma_index_20)
  {
   int maLength = MathMax(ma_index_10, ma_index_20) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_10_1 = cal_MA(closePrices, ma_index_10, 1);
   double ma_20_1 = cal_MA(closePrices, ma_index_20, 1);

   double ma_10_0 = cal_MA(closePrices, ma_index_10, 0);
   double ma_20_0 = cal_MA(closePrices, ma_index_20, 0);

   string trend_10_0 = ma_10_0 > ma_10_1 ? TREND_BUY : TREND_SEL;
   string trend_20_0 = ma_20_0 > ma_20_1 ? TREND_BUY : TREND_SEL;

   if(trend_10_0 == trend_20_0)
      return trend_20_0;

   if(ma_10_0 > ma_20_0 && ma_10_1 > ma_20_1)
      return TREND_BUY;

   if(ma_10_0 < ma_20_0 && ma_10_1 < ma_20_1)
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvg(string symbol, double &amp_w1, double &amp_d1, double &amp_h4)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 54.824;
      amp_d1 = 20.498;
      amp_h4 = 8.438;
      return;
     }
   if(is_same_symbol(symbol, "XAGUSD"))
     {
      amp_w1 = 1.327;
      amp_d1 = 0.469;
      amp_h4 = 0.19;
      return;
     }
   if(is_same_symbol(symbol, "USOIL"))
     {
      amp_w1 = 7.182;
      amp_d1 = 1.983;
      amp_h4 = 0.805;
      return;
     }
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      amp_w1 = 3570.59;
      amp_d1 = 1273.25;
      amp_h4 = 789.1;
      return;
     }
   if(is_same_symbol(symbol, "USTEC"))
     {
      amp_w1 = 664.39;
      amp_d1 = 199.95;
      amp_h4 = 81.16;
      return;
     }
   if(is_same_symbol(symbol, "US30"))
     {
      amp_w1 = 1066.8;
      amp_d1 = 308.8;
      amp_h4 = 119.5;
      return;
     }
   if(is_same_symbol(symbol, "US500"))
     {
      amp_w1 = 154.5;
      amp_d1 = 43.3;
      amp_h4 = 16.93;
      return;
     }
   if(is_same_symbol(symbol, "DE30"))
     {
      amp_w1 = 530.6;
      amp_d1 = 156.6;
      amp_h4 = 62.3;
      return;
     }
   if(is_same_symbol(symbol, "UK100"))
     {
      amp_w1 = 208.25;
      amp_d1 = 68.31;
      amp_h4 = 29.0;
      return;
     }
   if(is_same_symbol(symbol, "FR40"))
     {
      amp_w1 = 247.74;
      amp_d1 = 76.95;
      amp_h4 = 30.71;
      return;
     }
   if(is_same_symbol(symbol, "AUS200"))
     {
      amp_w1 = 204.43;
      amp_d1 = 67.52;
      amp_h4 = 29.93;
      return;
     }
   if(is_same_symbol(symbol, "AUDCHF"))
     {
      amp_w1 = 0.01242;
      amp_d1 = 0.0042;
      amp_h4 = 0.00158;
      return;
     }
   if(is_same_symbol(symbol, "AUDNZD"))
     {
      amp_w1 = 0.01293;
      amp_d1 = 0.00481;
      amp_h4 = 0.00178;
      return;
     }
   if(is_same_symbol(symbol, "AUDUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00567;
      amp_h4 = 0.00218;
      return;
     }
   if(is_same_symbol(symbol, "AUDJPY"))
     {
      amp_w1 = 2.285;
      amp_d1 = 0.774;
      amp_h4 = 0.282;
      return;
     }
   if(is_same_symbol(symbol, "CHFJPY"))
     {
      amp_w1 = 2.911;
      amp_d1 = 1.107;
      amp_h4 = 0.458;
      return;
     }
   if(is_same_symbol(symbol, "EURJPY"))
     {
      amp_w1 = 3.166;
      amp_d1 = 1.101;
      amp_h4 = 0.434;
      return;
     }
   if(is_same_symbol(symbol, "GBPJPY"))
     {
      amp_w1 = 3.873;
      amp_d1 = 1.326;
      amp_h4 = 0.53;
      return;
     }
   if(is_same_symbol(symbol, "NZDJPY"))
     {
      amp_w1 = 2.034;
      amp_d1 = 0.704;
      amp_h4 = 0.272;
      return;
     }
   if(is_same_symbol(symbol, "USDJPY"))
     {
      amp_w1 = 3.044;
      amp_d1 = 1.072;
      amp_h4 = 0.427;
      return;
     }
   if(is_same_symbol(symbol, "EURAUD"))
     {
      amp_w1 = 0.02969;
      amp_d1 = 0.01072;
      amp_h4 = 0.00417;
      return;
     }
   if(is_same_symbol(symbol, "EURCAD"))
     {
      amp_w1 = 0.02146;
      amp_d1 = 0.00765;
      amp_h4 = 0.00284;
      return;
     }
   if(is_same_symbol(symbol, "EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00429;
      amp_h4 = 0.0018;
      return;
     }
   if(is_same_symbol(symbol, "EURGBP"))
     {
      amp_w1 = 0.01162;
      amp_d1 = 0.00356;
      amp_h4 = 0.00131;
      return;
     }
   if(is_same_symbol(symbol, "EURNZD"))
     {
      amp_w1 = 0.03185;
      amp_d1 = 0.01191;
      amp_h4 = 0.00478;
      return;
     }
   if(is_same_symbol(symbol, "EURUSD"))
     {
      amp_w1 = 0.01858;
      amp_d1 = 0.00624;
      amp_h4 = 0.00239;
      return;
     }
   if(is_same_symbol(symbol, "GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00601;
      amp_h4 = 0.00241;
      return;
     }
   if(is_same_symbol(symbol, "GBPNZD"))
     {
      amp_w1 = 0.03533;
      amp_d1 = 0.01304;
      amp_h4 = 0.00531;
      return;
     }
   if(is_same_symbol(symbol, "GBPUSD"))
     {
      amp_w1 = 0.02454;
      amp_d1 = 0.00811;
      amp_h4 = 0.00317;
      return;
     }
   if(is_same_symbol(symbol, "NZDCAD"))
     {
      amp_w1 = 0.01459;
      amp_d1 = 0.0055;
      amp_h4 = 0.00216;
      return;
     }
   if(is_same_symbol(symbol, "NZDUSD"))
     {
      amp_w1 = 0.0151;
      amp_d1 = 0.00524;
      amp_h4 = 0.0021;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      amp_w1 = 0.01943;
      amp_d1 = 0.00651;
      amp_h4 = 0.00252;
      return;
     }
   if(is_same_symbol(symbol, "USDCHF"))
     {
      amp_w1 = 0.017;
      amp_d1 = 0.00591;
      amp_h4 = 0.00235;
      return;
     }

   amp_w1 = CalculateAverageCandleHeight(PERIOD_W1, symbol, 15);
   amp_d1 = CalculateAverageCandleHeight(PERIOD_D1, symbol, 30);
   amp_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol, 60);

   SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &dic_amp_init_h4, double &dic_amp_init_d1)
  {
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.05;
      amp_w = 1357.35;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USOIL"))
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.10;
      amp_w = 2.75;
      dic_amp_init_h4 = 0.05;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "XAGUSD"))
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.06;
      amp_w = 0.63500;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "XAUUSD"))
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.03;
      amp_w = 27.83;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US500"))
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.05;
      amp_w = 60.00;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US100.cash") || is_same_symbol(symbol, "USTEC"))
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.05;
      amp_w = 274.5;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US30"))
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.05;
      amp_w = 438.76;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "UK100"))
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.05;
      amp_w = 95.38;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GER40"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "DE30"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "FRA40") || is_same_symbol(symbol, "FR40"))
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUS200"))
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
      amp_w = 93.59;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDJPY"))
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.100;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDUSD"))
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURAUD"))
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01365;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURGBP"))
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00497;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURUSD"))
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0080;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPUSD"))
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00795;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USDCHF"))
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00750;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USDJPY"))
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.4250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CADCHF"))
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CADJPY"))
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.0250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CHFJPY"))
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.365000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURJPY"))
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.43500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPJPY"))
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.61500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDJPY"))
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.90000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURCAD"))
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00945;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURCHF"))
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURNZD"))
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01585;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPAUD"))
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01575;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPCAD"))
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPCHF"))
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPNZD"))
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.016250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDCAD"))
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDCHF"))
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.005805;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDNZD"))
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00595;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDCAD"))
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.007200;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDCHF"))
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDUSD"))
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "DXY"))
     {
      i_top_price = 103.458;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.6995;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   i_top_price = iClose(symbol, PERIOD_W1, 1);
   dic_amp_init_d1 = 0.02;
   amp_w = CalculateAverageCandleHeight(PERIOD_W1, symbol, 50);
   dic_amp_init_h4 = 0.01;

   SendAlert(INDI_NAME, "SymbolData", " Get SymbolData:" + (string)symbol + "   i_top_price: " + (string)i_top_price + "   amp_w: " + (string)amp_w + "   dic_amp_init_h4: " + (string)dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
