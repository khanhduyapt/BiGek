//+------------------------------------------------------------------+
//|                                                      Solomon.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


double dbRiskRatio = 0.005; // Rủi ro 1%
double INIT_EQUITY = 1000.0; // Vốn đầu tư

string INDICES = "_USTEC_US30_US500_DE30_UK100_FR40_AUS200_BTCUSD_XAGUSD_";

string arr_main_symbol[] = {"DXY", "XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

string INDI_NAME = "Solomon";
string FILE_NAME_TRADINGLIST_LOG = "Solomon.log";

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

//string MARKET_POSITION = "MK_";
string ORDER_POSITIONS = "OD_";

string LOCK_SEL = "_LoS_";
string LOCK_BUY = "_LoB_";
string STR_RE_DRAW = "_DRAW_";
//+------------------------------------------------------------------+
string TREND_LOSING  = "";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TRADER_ASHOK_V20 = "(Ashok.2.0)";
string TRADER_ASHOK_V30 = "(Ashok.3.0)";
string TRADER_CLEOP_V03 = "(Cleop.0.3)";
string TRADER_CLEOP_V05 = "(Cleop.0.5)";
string TRADER_CLEOP_V10 = "(Cleop.1.0)";
string TRADER_CLEOP_V15 = "(Cleop.1.5)";
string TRADER_CLEOP_V20 = "(Cleop.2.0)";
string TRADER_CLEOP_V25 = "(Cleop.2.5)";
string TRADER_MAHUA_V05 = "(MaHua.0.5)";
string TRADER_MAHUA_V10 = "(MaHua.1.0)";
string TRADER_MAHUA_V15 = "(MaHua.1.5)";
string TRADER_MAHUA_V20 = "(MaHua.2.0)";
string TRADER_MAHUA_V25 = "(MaHua.2.5)";
string TRADER_AKHEN_V05 = "(Akhen.0.5)";
string TRADER_AKHEN_V10 = "(Akhen.1.0)";
string TRADER_AKHEN_V15 = "(Akhen.1.5)";
string TRADER_AKHEN_V20 = "(Akhen.2.0)";
string TRADER_AKHEN_V25 = "(Akhen.2.5)";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TRADER_SOLOMON = "(Solomon)";
//+------------------------------------------------------------------+
int MAX_DCA = 5;
datetime TIME_OF_ONE_H4_CANDLE = 14400;

// Biến lưu thời gian mở lệnh cuối cùng
datetime last_order_open_time = TimeCurrent();
datetime last_open_trade_time = TimeCurrent();
datetime last_trend_shift_time = TimeCurrent();

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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

   OpenTradeSolomon(_Symbol);

   create_vertical_line(time2string(iTime(_Symbol, PERIOD_W1, 0)), iTime(_Symbol, PERIOD_W1, 0), clrBlack,  STYLE_DASHDOTDOT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTradeSolomon(string symbol)
  {
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   string trend_w3 = get_trend_by_stoc2(symbol, PERIOD_W1, 3, 2, 3, 0);
   string trend_w5 = get_trend_by_stoc2(symbol, PERIOD_W1, 5, 3, 3, 0);


   string trend_d10 = get_trend_by_ma(symbol, PERIOD_D1, 10, 1);
   string trend_h4_stoc1327 = get_trend_by_stoc132_ma7(symbol, PERIOD_H4);
   string trend_h4_stoc8532 = get_trend_by_stoc82_ma7(symbol, PERIOD_H4);

   bool stoc_h4_allow_buy_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3);
   bool stoc_h4_allow_sel_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3);

   string trend_h4_ma0710 = "";
   string trend_h4_ma1020 = "";
   string trend_h4_ma2050 = "";
   string trend_h4_C1ma10 = "";
   string trend_h4_ma50d1 = "";
   bool is_insign_h4 = false;
   get_trend_by_ma_seq71020_steadily(symbol, PERIOD_H4, trend_h4_ma0710, trend_h4_ma1020, trend_h4_ma2050, trend_h4_C1ma10, trend_h4_ma50d1, is_insign_h4);

//string trend_h4_stoc323 = get_trend_by_stoc2(symbol, PERIOD_H4, 3, 2, 3, 0);
//   bool must_exit_323 = is_must_exit_trade_by_stoch_extrema(symbol, PERIOD_H4, trend_h4_ma2050, 3, 2, 3);
//     {
//      // 1: Siêu phẩm, đánh từ 20k -> 48k, sụt giảm dưới 5%.
//      bool not_allow_against_main_trend = false;
//      if(trend_h4_ma2050 == trend_h4_ma1020 && trend_h4_ma2050 == trend_h4_ma0710)
//         not_allow_against_main_trend = true;
//
//      if((trend_h4_ma2050 == trend_w3 && trend_h4_ma2050 == trend_w5) && trend_h4_ma2050 == trend_d10 && must_exit_323 == false) //&& trend_h4_ma2050 == trend_h4_stoc323
//        {
//         OpenTrade_StandardVolume(symbol, TRADER_CLEOP_V05,  5, trend_h4_ma2050, 0.10, not_allow_against_main_trend);
//         OpenTrade_StandardVolume(symbol, TRADER_CLEOP_V10, 10, trend_h4_ma2050, 0.10, not_allow_against_main_trend);
//        }
//
//      //2 :20k -> 38k tăng ổn định
//      if((trend_h4_ma2050 == trend_w3 && trend_h4_ma2050 == trend_w5) && trend_h4_ma2050 == trend_d10 && must_exit_323 == false) // && trend_h4_ma2050 == trend_h4_stoc323
//         OpenTrade_StandardVolume(symbol, TRADER_CLEOP_V03, 3, trend_h4_ma2050, 0.1, not_allow_against_main_trend);
//
//      //      //3: 20, 40, 20 (20k danh len 45k)
//      //      OpenTrade_Only1Side(symbol, TRADER_ASHOK_V20, amp_d1,        trend_h4_ma50d1, 0.01, true);
//      //      OpenTrade_Only1Side(symbol, TRADER_ASHOK_V30, amp_d1+amp_h4, trend_h4_ma50d1, 0.01, true);
//      //
//      //
//      //
//      //      OpenTrade_DCASH(symbol, 10, trend_h4_ma1020);
//
//
//
//      string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
//      get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);
//      if((trend_by_macd_h4 == trend_w3 && trend_by_macd_h4 == trend_w5) && trend_by_macd_h4 == trend_d10)
//        {
//         OpenTrade_StandardVolume(symbol, TRADER_MAHUA_V05,  5, trend_by_macd_h4, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_MAHUA_V10, 10, trend_by_macd_h4, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_MAHUA_V15, 15, trend_by_macd_h4, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_MAHUA_V20, 20, trend_by_macd_h4, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_MAHUA_V25, 25, trend_by_macd_h4, 0.10, true);
//        }
//
//
//      string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "";
//      get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1);
//      if((trend_mac_vs_zero_d1 == trend_w3 && trend_mac_vs_zero_d1 == trend_w5) && trend_mac_vs_zero_d1 == trend_d10)
//        {
//         OpenTrade_StandardVolume(symbol, TRADER_AKHEN_V05,  5, trend_mac_vs_zero_d1, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_AKHEN_V10, 10, trend_mac_vs_zero_d1, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_AKHEN_V15, 15, trend_mac_vs_zero_d1, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_AKHEN_V20, 20, trend_mac_vs_zero_d1, 0.10, true);
//         OpenTrade_StandardVolume(symbol, TRADER_AKHEN_V25, 25, trend_mac_vs_zero_d1, 0.10, true);
//        }
//
//     }

   OpenTrade_StandardVolume(symbol, TRADER_MAHUA_V05,  3, TREND_BUY, 0.10, true);
   OpenTrade_StandardVolume(symbol, TRADER_AKHEN_V05,  3, TREND_SEL, 0.10, true);
  }


//+------------------------------------------------------------------+
//|not_allow_against_main_trend = False <-> DCA đến chết             |
//+------------------------------------------------------------------+
void OpenTrade_StandardVolume(string symbol, string TRADER, double AMP_DCA, string trend_init, double init_volume = 0.01, bool not_allow_against_main_trend=true)
  {
   if(trend_init == "")
      return;

   if(is_same_symbol(INDICES, symbol) && trend_init != TREND_BUY)
      return;

   int NUMBER_OF_TRADE = 100;
   double AMP_TP_DCA = AMP_DCA*2;

   double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   string keys_all = "";
   string keys_locks_sel = "";
   string keys_locks_buy = "";
   for(int i=OrdersTotal()-1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(TRADER, OrderComment()))
              {
               keys_all += create_ticket_key(OrderTicket());

               if(StringFind(toLower(OrderComment()), toLower(LOCK_BUY)) >= 0)
                  keys_locks_buy += create_ticket_key(OrderTicket()) + OrderComment() + ";";

               if(StringFind(toLower(OrderComment()), toLower(LOCK_SEL)) >= 0)
                  keys_locks_sel += create_ticket_key(OrderTicket()) + OrderComment() + ";";
              }

   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;
   double max_openprice_buy = 0, min_openprice_sel = 10000000;
   double cur_tp_buy = 0, cur_tp_sel = 0;

   ulong first_ticket_buy = 0, first_ticket_sel = 0;
   datetime first_open_time_buy = 0, first_open_time_sel = 0;
   double first_entry_buy = 0, first_entry_sel = 0;

   double last_entry_buy = 0, last_entry_sel = 0;
   int last_ticket_buy = 0, last_ticket_sel = 0;
   string last_comment_buy = "", last_comment_sel = "";

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            if(is_same_symbol(TRADER, OrderComment()) == false)
               continue;

            double cur_profit = OrderProfit() + OrderSwap() + OrderCommission();
            string TRADING_TREND = OrderType() == OP_BUY ? TREND_BUY : TREND_SEL;
            double price_sell_off = is_same_symbol(TRADING_TREND, TREND_BUY) ? OrderOpenPrice() + 3 : OrderOpenPrice() - 3;


            //if(is_same_symbol(OrderComment(), "01"))
            //   create_lable(time2string(OrderOpenTime()), TimeCurrent(), OrderTakeProfit(), "(TP)(" +get_trend_nm(TRADING_TREND) + ") " + TRADER);

            string bilock_ticket = OrderComment();
            string key = create_ticket_key(OrderTicket());
            if(is_same_symbol(bilock_ticket, LOCK_BUY) || is_same_symbol(bilock_ticket, LOCK_SEL))
              {
               StringReplace(bilock_ticket, TRADER,   "");
               StringReplace(bilock_ticket, LOCK_BUY, "");
               StringReplace(bilock_ticket, LOCK_SEL, "");

               if(keys_all == "" || is_same_symbol(keys_all, key) == false)
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_sell_off,0,Green))
                     Print("OrderModify error ",GetLastError());
              }

            if(is_same_symbol(OrderComment(), LOCK_BUY) || is_same_symbol(OrderComment(), LOCK_SEL))
               continue;

            if(TRADING_TREND == TREND_BUY)
              {
               count_possion_buy += 1;
               total_profit_buy += cur_profit;
               total_volume_buy += OrderLots();

               if(last_ticket_buy < OrderTicket())
                 {
                  cur_tp_buy = OrderTakeProfit();
                  last_entry_buy = OrderOpenPrice();
                  last_ticket_buy = OrderTicket();
                  last_comment_buy = OrderComment();
                 }

               if(is_same_symbol(OrderComment(), "01"))
                 {
                  first_ticket_buy = OrderTicket();
                  first_open_time_buy = OrderOpenTime();
                  first_entry_buy = OrderOpenPrice();
                 }

               if(max_openprice_buy < OrderOpenPrice())
                  max_openprice_buy = OrderOpenPrice();
              }

            if(TRADING_TREND == TREND_SEL)
              {
               count_possion_sel += 1;
               total_profit_sel += cur_profit;
               total_volume_sel += OrderLots();

               if(last_ticket_sel < OrderTicket())
                 {
                  cur_tp_sel = OrderTakeProfit();
                  last_entry_sel = OrderOpenPrice();
                  last_ticket_sel = OrderTicket();
                  last_comment_sel = OrderComment();
                 }

               if(is_same_symbol(OrderComment(), "01"))
                 {
                  first_ticket_sel = OrderTicket();
                  first_open_time_sel = OrderOpenTime();
                  first_entry_sel = OrderOpenPrice();
                 }

               if(min_openprice_sel > OrderOpenPrice())
                  min_openprice_sel =OrderOpenPrice();
              }
           }
        }
     } //for
//---------------------------------------------------------------------------
   string trend_ma0710 = get_trend_by_maX_maY(symbol, PERIOD_H4, 7, 10);
   bool stoc_h4_allow_buy_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3);
   bool stoc_h4_allow_sel_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3);

   if((stoc_h4_allow_sel_now && total_profit_buy > 0) || (keys_locks_buy == "" && count_possion_buy == 0))
      ClosePosition(symbol, TREND_BUY, TRADER);

   if((stoc_h4_allow_buy_now && total_profit_sel > 0) || (keys_locks_sel == "" && count_possion_sel == 0))
      ClosePosition(symbol, TREND_SEL, TRADER);
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   if(count_possion_buy == 0 && trend_init == TREND_BUY)
     {
      int ticket = OrderSend(symbol,OP_BUY, init_volume, ASK, 0, 0.0, ASK + AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1));
      if(ticket > 0)
         Print("BUY order opened.");
     }

   if(count_possion_sel == 0 && trend_init == TREND_SEL)
     {
      int ticket = OrderSend(symbol,OP_SELL, init_volume, BID, 0, 0.0, BID - AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel+1));
      if(ticket > 0)
         Print("SEL order opened.");
     }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

   if(count_possion_buy > 0 && count_possion_buy < NUMBER_OF_TRADE && (ASK < last_entry_buy - AMP_DCA))
     {
      double amp_tp = MathMax(AMP_TP_DCA, MathAbs(first_entry_buy - last_entry_buy)*0.618);
      double tp_buy = NormalizeDouble(ASK + amp_tp, digits);

      count_possion_buy += 1;
      int ticket = OrderSend(symbol,OP_BUY, init_volume, ASK, 0, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy));
      if(ticket > 0)
         ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
     }


   if(count_possion_sel > 0 && count_possion_sel < NUMBER_OF_TRADE && (BID > last_entry_sel + AMP_DCA))
     {
      double amp_tp = MathMax(AMP_TP_DCA, MathAbs(last_entry_sel - first_entry_sel)*0.618);
      double tp_sel = NormalizeDouble(BID - amp_tp, digits);

      count_possion_sel += 1;

      int ticket = OrderSend(symbol,OP_SELL, init_volume, BID, 0, 0.0, tp_sel, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel));
      if(ticket > 0)
         ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
     }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   string key_group_buy = create_ticket_key(first_ticket_buy);
   string key_group_sel = create_ticket_key(first_ticket_sel);

   if(trend_init == TREND_BUY && stoc_h4_allow_sel_now == false && not_allow_against_main_trend && (key_group_sel != "" && is_same_symbol(keys_locks_sel, key_group_sel) == false))
     {
      trend_shift_implement(symbol, TREND_BUY, total_profit_sel, AMP_TP_DCA, TRADER, total_volume_sel, key_group_sel);
     }

   if(trend_init == TREND_SEL && stoc_h4_allow_buy_now == false && not_allow_against_main_trend && (key_group_buy != "" && is_same_symbol(keys_locks_buy, key_group_buy) == false))
     {
      trend_shift_implement(symbol, TREND_SEL, total_profit_buy, AMP_TP_DCA, TRADER, total_volume_buy, key_group_buy);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trend_shift_implement(string symbol, string NEW_TREND, double total_loss, double AMP_TP_DCA, string TRADER, double volume_traded, string key_group)
  {
   if(is_allow_trend_shift(symbol, NEW_TREND))
     {
      double price = SymbolInfoDouble(symbol, SYMBOL_BID);
      double volume_balance = MathMax(volume_traded, calc_volume_by_amp(symbol, AMP_TP_DCA, MathAbs(total_loss))*2);

      if(NEW_TREND == TREND_BUY)
        {
         int ticket = OrderSend(symbol,OP_BUY, volume_balance, price, 0, 0.0, price + AMP_TP_DCA, LOCK_SEL + TRADER + key_group);
         if(ticket > 0)
           {
            Sleep(5000);
            ClosePosition(symbol, TREND_SEL, TRADER);

            create_lable(LOCK_SEL + TRADER + time2string(iTime(symbol, PERIOD_H4, 1)), iTime(symbol, PERIOD_H4, 1), price + AMP_TP_DCA, LOCK_SEL + TRADER + (string) volume_balance);
           }
        }

      if(NEW_TREND == TREND_SEL)
        {
         int ticket = OrderSend(symbol,OP_SELL, volume_balance, price, 0, 0.0, price - AMP_TP_DCA, LOCK_BUY + TRADER + key_group);
         if(ticket > 0)
           {
            Sleep(5000);
            ClosePosition(symbol, TREND_BUY, TRADER);

            create_lable(LOCK_BUY + TRADER + time2string(iTime(symbol, PERIOD_H4, 1)), iTime(symbol, PERIOD_H4, 1), price + AMP_TP_DCA, LOCK_BUY + TRADER + (string) volume_balance);
           }
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string TRADING_TREND, string KEY_TO_CLOSE)
  {
   string msg = "";
   double profit = 0.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(TRADING_TREND == "" || (StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0))
               if(KEY_TO_CLOSE == "" || (StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0))
                 {
                  //create_lable(time2string(OrderOpenPrice())
                  //             , OrderOpenPrice()
                  //             , OrderOpenPrice() - amp_d1
                  //             , " Pg: " + (string) NormalizeDouble(OrderProfit(), 1) + "$", OrderProfit() > 0 ? TREND_BUY : TREND_SEL);

                  msg += (string)OrderTicket() + ": " + (string) OrderProfit() + "$";
                  profit += OrderProfit();

                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                     Print("OrderClose error ",GetLastError());
                 }
     } //for

   if(msg != "")
      SendTelegramMessage(symbol, STOP_TRADE, STOP_TRADE + " " + TRADING_TREND + "  " + symbol + "   Total: " + (string) profit + "$ ");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition_TakeProfit(string symbol, string TRADING_TREND, string KEY_CLOSE)
  {
   string msg = "";
   double profit = 0.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
               if(KEY_CLOSE == "" || (StringFind(OrderComment(), KEY_CLOSE) >= 0))
                  if(OrderProfit() > 1)
                    {
                     //create_lable(time2string(OrderOpenPrice())
                     //             , OrderOpenPrice()
                     //             , OrderOpenPrice() - amp_d1
                     //             , " P1: " + (string) NormalizeDouble(OrderProfit(), 1) + "$", OrderProfit() > 0 ? TREND_BUY : TREND_SEL);

                     msg += (string)OrderTicket() + ": " + (string) OrderProfit() + "$";
                     profit += OrderProfit();

                     if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                        Print("OrderClose error ",GetLastError());
                    }
     } //for

   if(msg != "")
      SendTelegramMessage(symbol, "TAKE_PROFIT", "(TAKE.PROFIT) " + AppendSpaces(symbol) + " (H4) " + " Total: " + (string) profit + "$ " + msg);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ExceptLockKey(string symbol, string TRADING_TREND, double tp_price, string KEY_TO_CLOSE)
  {
   Sleep(1000);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderTakeProfit() != tp_price)
                     if(is_same_symbol(OrderComment(), LOCK_BUY) == false && is_same_symbol(OrderComment(), LOCK_SEL) == false)
                       {
                        double new_sl = OrderStopLoss();
                        double new_tp = OrderTakeProfit();
                        if(is_same_symbol(TRADING_TREND, TREND_BUY))
                          {
                           if(tp_price > OrderOpenPrice())
                              new_tp = tp_price;
                           else
                              new_sl = tp_price;
                          }

                        if(is_same_symbol(TRADING_TREND, TREND_SEL))
                          {
                           if(tp_price < OrderOpenPrice())
                              new_tp = tp_price;
                           else
                              new_sl = tp_price;
                          }

                        int ross = 0;
                        int demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(),OrderOpenPrice(),new_sl,new_tp,0,clrNONE);
                           demm++;
                           Sleep(1000);
                          }

                        int loi = GetLastError();
                        if(loi!=0 && loi !=1)
                           Print("Error"+(string)loi);

                       }
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
      return "0" + (string) trade_no;

   return (string) trade_no;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_ticket_key(ulong ticket)
  {
   string key = "";

   if(ticket > 0)
      key = "(" + (string)(ticket)+ ")";

   return key;
  }

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
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_ma_seq71020_steadily(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string &trend_ma0710, string &trend_ma1020, string &trend_ma02050, string &trend_C1ma10, string &trend_h4_ma50d1, bool &insign_h4)
  {
   trend_ma0710 = "";
   trend_ma1020 = "";
   trend_ma02050 = "";
   trend_C1ma10 = "";
   trend_h4_ma50d1 = "";

   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);


   int count = 0;
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }

   double ma07[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   double ma10[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   double ma20[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   for(int i = 0; i < 5; i++)
     {
      ma07[i] = cal_MA(closePrices, 7, i);
      ma10[i] = cal_MA(closePrices, 10, i);
      ma20[i] = cal_MA(closePrices, 20, i);
     }
   double ma50_0 = cal_MA(closePrices, 50, 0);
   double ma50_1 = cal_MA(closePrices, 50, 1);
   trend_ma02050 = (ma20[1] > ma50_0) && (ma20[0] > ma50_0) ? TREND_BUY : TREND_SEL;

   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ma50_0+amp_d1 < price)
      trend_h4_ma50d1 = TREND_SEL;
   if(ma50_0-amp_d1 > price)
      trend_h4_ma50d1 = TREND_BUY;

   double ma_min = MathMin(MathMin(MathMin(ma07[0], ma10[0]), ma20[0]), ma50_0);
   double ma_max = MathMax(MathMax(MathMax(ma07[0], ma10[0]), ma20[0]), ma50_0);
   insign_h4 = false;
   if(MathAbs(ma_max - ma_min) < amp_h4*2)
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
string GetComments()
  {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double amp_w1;
   double amp_d1;
   double amp_h4;
   GetAmpAvg(_Symbol, amp_w1, amp_d1, amp_h4);

   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(_Symbol, amp_d1, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + _Symbol;

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(_Symbol, PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "";
   get_trend_by_macd_and_signal_vs_zero(_Symbol, PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1);

   str_comments += "    Macd(H4): " + (string) trend_by_macd_h4;
   str_comments += "    Macd(D1): " + (string) trend_mac_vs_signal_d1;

//if(IS_DEBUG_MODE == false)
     {
      str_comments += "    Vol(D1): " + volume_bt + " lot";
      str_comments += "    Funds: " + (string) INIT_EQUITY + "$ / Risk: " + (string) risk + "$ / " + (string)(dbRiskRatio * 100) + "%    ";

      //str_comments += "\n";
      str_comments += "    Avg(H4): " + (string) amp_h4;
      str_comments += "    Avg(D1): " + (string) amp_d1;
      str_comments += "    Avg(W1): " + (string) amp_w1;
     }

   if(IsMarketClose())
      str_comments += "    MarketClose";
   else
      str_comments += "    Market Open";
   str_comments += "    " + get_profit_today();


   return str_comments;
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
string get_trend_nm(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return "B";

   if(is_same_symbol(TREND, TREND_SEL))
      return "S";

   return "";
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
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const string            TRADING_TREND="BUY",
   const bool              trim_text = true
)
  {
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : clrRed;
   TextCreate(0,name, 0, time_to, price, trim_text ? label : "        " + label, clr_color);
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

      CandleData candle_i(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle_i;
     }
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
//string inputString = TerminalInfoString(TERMINAL_CPU_NAME);
//string startString = "Core ";
//string endString = " @";
//int startIndex = StringFind(inputString, startString) + 5;
//int endIndex = StringFind(inputString, endString);
//if(startIndex != -1 && endIndex != -1)
//  {
//   cpu = StringSubstr(inputString, startIndex, endIndex - startIndex);
//  }
//StringReplace(cpu, "i5-", "");

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
   int max_lengh = 1000;
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
//   MqlDateTime date_time;
//   TimeToStruct(TimeCurrent(), date_time);
//   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;
//   int row_count = 0;
//// --------------------------------------------------------------------
//// --------------------------------------------------------------------
//   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
//   HistorySelect(0, TimeCurrent()); // today closed trades PL
//   int orders = HistoryDealsTotal();
//
//   double PL = 0.0;
//   for(int i = orders - 1; i >= 0; i--)
//     {
//      ulong ticket=HistoryDealGetTicket(i);
//      if(ticket==0)
//        {
//         break;
//        }
//
//      string symbol  = HistoryDealGetString(ticket, DEAL_SYMBOL);
//      if(symbol == "")
//        {
//         continue;
//        }
//
//      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
//
//      if(profit != 0)  // If deal is trade exit with profit or loss
//        {
//         MqlDateTime deal_time;
//         TimeToStruct(HistoryDealGetInteger(ticket, DEAL_TIME), deal_time);
//
//         // If is today deal
//         if(deal_time.day == current_day && deal_time.mon == current_month && deal_time.year == current_year)
//           {
//            PL += profit;
//           }
//         else
//            break;
//        }
//     }
//
//   double swap = 0.0;
//   for(int i = OrdersTotal() - 1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//        {
//         swap += OrderSwap();
//        }
//     } //for
//
//
//   double starting_balance = current_balance - PL;
//   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
//   double loss = current_equity - starting_balance;
//
//   string result = "    Swap:" + format_double_to_string(swap, 2) + "$";
//   result += "    Profit Today:" + format_double_to_string(loss, 2) + "$";
//
//   if(loss + INIT_EQUITY*0.1 < 0)
//      result += STOP_TRADE;
//
//   return result;
   return "TODO: get_profit_today";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvg(string symbol, double &amp_w1, double &amp_d1, double &amp_h4)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 50;
      amp_d1 = 20;
      amp_h4 = 8;
      return;
     }
   if(is_same_symbol(symbol, "XAGUSD"))
     {
      amp_w1 = 1.3;
      amp_d1 = 0.45;
      amp_h4 = 0.2;
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
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";

   double macd_0=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double macd_1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double sign_0=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   double sign_1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_by_macd = TREND_BUY;

   if(macd_0 <= 0 && sign_0 <= 0)
      trend_by_macd = TREND_SEL;

   if(macd_0 > sign_0 && macd_1 > sign_1 && macd_0 > macd_1)
      trend_mac_vs_signal = TREND_BUY;

   if(macd_0 < sign_0 && macd_1 < sign_1 && macd_0 < macd_1)
      trend_mac_vs_signal = TREND_SEL;

   if(macd_0 > 0)
      trend_mac_vs_zero = TREND_BUY;

   if(macd_0 < 0)
      trend_mac_vs_zero = TREND_SEL;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trend_shift(string symbol, string NEW_TREND)
  {
// (1: Thời gian giữa các lệnh:
//    1-1: 12 tiếng: 20k-> 110k
//    1-2:  4 tiếng: 20k-> 107.7k
//    1-3:  1 tiếng: 20k-> 109.5k
// (2: Trả về luôn) 20k-> 144k, sụt giảm tài khoản từ 30k về 6k, vô cùng nguy hiểm.

// Yêu cầu mỗi lần chuyển trạng thái từ Buy<->Sell:
// Cần chờ tối thiểu 1 giờ sau mỗi lần chuyển đổi để tránh tạo GAP sụt giảm tài khoản.
   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_trend_shift_time;
   if(timeGap >= 1 * 60 * 60)
      pass_time_check = true;
   else
      return false;

// (3: iStochastic) 20k-> 110k
   if(pass_time_check)
     {
      double K138_0 = iStochastic(symbol,PERIOD_H4,13,8,5,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
      double D138_0 = iStochastic(symbol,PERIOD_H4,13,8,5,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

      if(NEW_TREND == TREND_BUY && (K138_0 < 80 || D138_0 < 80))
        {
         last_trend_shift_time = currentTime;
         return true;
        }

      if(NEW_TREND == TREND_SEL && (K138_0 > 20 || D138_0 > 20))
        {
         last_trend_shift_time = currentTime;
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol, ENUM_TIMEFRAMES timeframe, int inK = 13, int inD = 8, int inS = 5, int candle_no = 0)
  {
   double M_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double M_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  1);// 1st bar
   double S_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
   double S_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,1);// 1st bar

   double black_K = M_0;
   double red_D = S_0;

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double red_D = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && black_K >= red_D && (red_D <= 20 || black_K <= 20))
      return true;

   if(find_trend == TREND_SEL && black_K <= red_D && (red_D >= 80 || black_K >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch_extrema(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && ((black_K >= 80 && red_D >= 80) || (black_K < red_D)))
      return true;

   if(find_trend == TREND_SEL && ((black_K <= 20 && red_D <= 20) || (black_K > red_D)))
      return true;

   if(timeframe >= PERIOD_D1)
     {
      if(find_trend == TREND_BUY && (black_K >= 70 || red_D >= 70))
         return true;

      if(find_trend == TREND_SEL && (black_K <= 30 || red_D <= 30))
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+

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
string get_trend_by_stoc132_ma7(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_ma7 = get_trend_by_ma(symbol, timeframe, 3, 1);
   if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 3, 2, 3, 0))
      if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 13, 8, 5, 0))
         return trend_ma7;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc82_ma7(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_ma7 = get_trend_by_ma(symbol, timeframe, 7, 1);
   if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 3, 2, 3, 0))
      if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 8, 5, 3, 0))
         return trend_ma7;
   return "";
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
