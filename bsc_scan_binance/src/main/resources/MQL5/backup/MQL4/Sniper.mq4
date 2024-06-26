//+------------------------------------------------------------------+
//|                                                       Sniper.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string INDI_NAME = "[CENT]";
double dbRiskRatio = 0.01;    // Rủi ro 1%
double INIT_EQUITY = 10000.0; // Vốn đầu tư

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string LOCK_SEL = "_LoS_";
string LOCK_BUY = "_LoB_";
datetime last_check_time = TimeCurrent();
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
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   double amp_w1, amp_d1, amp_h4;
   GetAmpAvg(Symbol(), amp_w1, amp_d1, amp_h4);
   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(Symbol(), amp_d1, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + Symbol();

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1);

   str_comments += "    Macd(H4): " + (string) trend_by_macd_h4;
   str_comments += "    Macd(D1): " + (string) trend_mac_vs_signal_d1;

//if(IS_DEBUG_MODE == false)
     {
      str_comments += "    Vol: " + volume_bt + " lot";
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

   return str_comments;
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   OnTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string TRADER = "(Cent)";

   int NUMBER_OF_TRADE = 20;
   string trend_w3 = get_trend_by_stoc2(Symbol(), PERIOD_W1, 3, 2, 3, 0);
   string trend_w5 = get_trend_by_stoc2(Symbol(), PERIOD_W1, 5, 3, 3, 0);
   string trend_d10 = get_trend_by_ma(Symbol(), PERIOD_D1, 10, 1);

   string symbol = Symbol();
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
   double init_volume = calc_volume_by_amp(symbol, amp_d1, calcRisk());

   string trend_h4_ma0710 = "";
   string trend_h4_ma1020 = "";
   string trend_h4_ma2050 = "";
   string trend_h4_C1ma10 = "";
   string trend_h4_ma50d1 = "";
   bool is_insign_h4 = false;
   get_trend_by_ma_seq71020_steadily(symbol, PERIOD_H4, trend_h4_ma0710, trend_h4_ma1020, trend_h4_ma2050, trend_h4_C1ma10, trend_h4_ma50d1, is_insign_h4);

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   string trend_init = "";
   if(trend_w3==trend_w5 && trend_w5==trend_d10 && trend_w5==trend_h4_ma2050 && trend_h4_ma2050 == trend_by_macd_h4)
      trend_init = trend_h4_ma2050;

   string str_count = OpenTrade_StandardVolume(symbol, TRADER, amp_h4, trend_init, init_volume, true);

   string comment = GetComments();
   string balance = format_double_to_string(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   string profit  = format_double_to_string(AccountInfoDouble(ACCOUNT_PROFIT), 2);

   Comment(TRADER + comment
           + "    balance:" + balance
           + "    profit:" + profit
           + "    " + str_count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_timer_5minus()
  {
   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_check_time;
   if(timeGap >= 5 * 60)
     {
      last_check_time = TimeCurrent();
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OpenTrade_StandardVolume(string symbol, string TRADER, double AMP_DCA, string trend_init, double init_volume = 0.01, bool not_allow_against_main_trend=true)
  {
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   int slippage = (int)MathAbs(ask-bid);
   int NUMBER_OF_TRADE = 100;


   string keys_all = "";
   string keys_locks_sel = "";
   string keys_locks_buy = "";
   for(int i=OrdersTotal()-1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(Symbol()) == toLower(OrderSymbol()))
            if(is_same_symbol(TRADER, OrderComment()))
              {
               keys_all += create_ticket_key(OrderTicket());

               if(StringFind(toLower(OrderComment()), toLower(LOCK_BUY)) >= 0)
                  keys_locks_buy += create_ticket_key(OrderTicket()) + OrderComment() + ";";

               if(StringFind(toLower(OrderComment()), toLower(LOCK_SEL)) >= 0)
                  keys_locks_sel += create_ticket_key(OrderTicket()) + OrderComment() + ";";
              }

//-----------------------------------------------------------------------------
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
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ");
         break;
        }

      double cur_profit = OrderProfit() + OrderSwap() + OrderCommission();
      double price_sell_off = OrderType() == OP_BUY ? OrderOpenPrice() + 3 : OrderOpenPrice() - 3;

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

      if(OrderType() == OP_BUY)
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


      if(OrderType() == OP_SELL)
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
            min_openprice_sel = OrderOpenPrice();
        }
     }

   string result = ""
                   + "    iVol: " + (string)init_volume
                   + "    amp: " + (string)AMP_DCA
                   + "    trend_init: " + trend_init
                   + "    buy:" + (string)count_possion_buy
                   + "    sel:" + (string)count_possion_sel;

   if(!passes_timer_5minus())
      return result;
//-----------------------------------------------------------------------------
   if(count_possion_buy == 0 && trend_init == TREND_BUY)
     {
      int ticket = OrderSend(symbol,OP_BUY, init_volume, ask, 0, 0.0, ask + AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1), 0, 0, clrBlack);
      if(ticket > 0)
         Print("BUY order opened.");
     }

   if(count_possion_sel == 0 && trend_init == TREND_SEL)
     {
      int ticket = OrderSend(symbol,OP_SELL, init_volume, bid, 0, 0.0, bid - AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel+1), 0, 0, clrBlack);
      if(ticket > 0)
         Print("SEL order opened.");
     }
//-----------------------------------------------------------------------------
   if(trend_init == TREND_BUY && count_possion_buy > 0 && count_possion_buy < NUMBER_OF_TRADE && (ask < last_entry_buy - AMP_DCA))
     {
      double amp_tp = MathMax(AMP_DCA*2, MathAbs(first_entry_buy - last_entry_buy)*0.618);
      double tp_buy = NormalizeDouble(ask + amp_tp, digits);

      count_possion_buy += 1;
      double volume = init_volume; //get_value_by_fibo_1618(init_volume, count_possion_buy, 2);

      bool longExecuted = OrderSend(symbol,OP_BUY, volume, ask, slippage, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy), 0, 0, clrBlack);
      if(longExecuted)
         ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
     }

   if(trend_init == TREND_SEL && count_possion_sel > 0 && count_possion_sel < NUMBER_OF_TRADE && (bid > last_entry_sel + AMP_DCA))
     {
      double amp_tp = MathMax(AMP_DCA*2, MathAbs(last_entry_sel - first_entry_sel)*0.618);
      double tp_sel = NormalizeDouble(bid - amp_tp, digits);

      count_possion_sel += 1;
      double volume = init_volume; //get_value_by_fibo_1618(init_volume, count_possion_sel, 2);
      bool shortExecuted = OrderSend(symbol,OP_SELL, volume, bid, slippage, 0.0, tp_sel, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel), 0, 0, clrBlack);
      if(shortExecuted)
         ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
     }
//-----------------------------------------------------------------------------
   if(not_allow_against_main_trend)
     {
      string key_group_buy = create_ticket_key(first_ticket_buy);
      string key_group_sel = create_ticket_key(first_ticket_sel);

      bool stoc_h4_allow_buy_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3);
      bool stoc_h4_allow_sel_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3);

      if(trend_init == TREND_BUY && stoc_h4_allow_sel_now == false && (key_group_sel != "" && is_same_symbol(keys_locks_sel, key_group_sel) == false))
        {
         trend_shift_implement(symbol, TREND_BUY, total_profit_sel, AMP_DCA, TRADER, total_volume_sel, key_group_sel);
        }

      if(trend_init == TREND_SEL && stoc_h4_allow_buy_now == false && (key_group_buy != "" && is_same_symbol(keys_locks_buy, key_group_buy) == false))
        {
         trend_shift_implement(symbol, TREND_SEL, total_profit_buy, AMP_DCA, TRADER, total_volume_buy, key_group_buy);
        }
     }
//-----------------------------------------------------------------------------
   return result;
//-----------------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trend_shift_implement(string symbol, string NEW_TREND, double total_loss, double AMP_TP_DCA, string TRADER, double volume_traded, string key_group)
  {
//if(is_allow_trend_shift(symbol, NEW_TREND))
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double volume_balance = MathMax(volume_traded, calc_volume_by_amp(symbol, AMP_TP_DCA, MathAbs(total_loss))*2);

      if(NEW_TREND == TREND_BUY)
        {
         int ticket = OrderSend(symbol,OP_BUY, volume_balance, ask, 0, 0.0, ask + AMP_TP_DCA, LOCK_SEL + TRADER + key_group, 0, 0, clrBlack);
         if(ticket > 0)
           {
            Sleep(5000);
            ClosePosition(symbol, TREND_SEL, TRADER);

            //create_lable(LOCK_SEL + TRADER + time2string(iTime(symbol, PERIOD_H4, 1)), iTime(symbol, PERIOD_H4, 1), ask + AMP_TP_DCA, LOCK_SEL + TRADER + (string) volume_balance);
           }
        }

      if(NEW_TREND == TREND_SEL)
        {
         int ticket = OrderSend(symbol,OP_SELL, volume_balance, bid, 0, 0.0, bid - AMP_TP_DCA, LOCK_BUY + TRADER + key_group);
         if(ticket > 0)
           {
            Sleep(5000);
            ClosePosition(symbol, TREND_BUY, TRADER);

            //create_lable(LOCK_BUY + TRADER + time2string(iTime(symbol, PERIOD_H4, 1)), iTime(symbol, PERIOD_H4, 1), bid + AMP_TP_DCA, LOCK_BUY + TRADER + (string) volume_balance);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ExceptLockKey(string symbol, string TRADING_TREND, double tp_price, string KEY_TO_CLOSE)
  {
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

                        int ross=0, demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp_price,0,clrBlue);
                           demm++;
                           Sleep(100);
                          }
                       }
        }
     } //for
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string TRADING_TREND, string KEY_TO_CLOSE)
  {
   string msg = "";
   double profit = 0.0;


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

   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
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

//SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
   return;
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
double get_value_by_fibo_1618(double init, int trade_no, int digits)
  {
   double fibo = 1.618;
   double vol = init;
   for(int i = 2; i <= trade_no; i++)
     {
      vol = vol*fibo;
     }

   return NormalizeDouble(vol, digits);
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
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fun_Error(int Error)                        // Function of processing errors
  {
   switch(Error)
     {
      // Not crucial errors
      case  4:
         Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 135:
         Alert("Price changed. Trying once again..");
         RefreshRates();                        // Refresh rates
         return(1);                             // Exit the function
      case 136:
         Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)           // Till a new tick
            Sleep(1);                           // Pause in the loop
         return(1);                             // Exit the function
      case 137:
         Alert("Broker is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 146:
         Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                            // Simple solution
         return(1);                             // Exit the function
      // Critical errors
      case  2:
         Alert("Common error.");
         return(0);                             // Exit the function
      case  5:
         Alert("Old terminal version.");
         return(0);                             // Exit the function
      case 64:
         Alert("Account blocked.");
         return(0);                             // Exit the function
      case 133:
         Alert("Trading forbidden.");
         return(0);                             // Exit the function
      case 134:
         Alert("Not enough money to execute operation.");
         return(0);                             // Exit the function
      default:
         Alert("Error occurred: ",Error); // Other variants
         return(0);                             // Exit the function
     }
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
   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && black_K >= red_D && (red_D <= 20 || black_K <= 20))
      return true;

   if(find_trend == TREND_SEL && black_K <= red_D && (red_D >= 80 || black_K >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero)
  {
   trend_by_macd = "___";
   trend_mac_vs_signal = "___";
   trend_mac_vs_zero = "___";

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
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
      return "0" + (string) trade_no;

   return (string) trade_no;
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
//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
   if(Period() == PERIOD_M5)
      return "M5";

   if(Period() == PERIOD_M15)
      return "M15";

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
string get_vntime()
  {
   string cpu = "";
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
