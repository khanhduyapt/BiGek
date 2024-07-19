//+------------------------------------------------------------------+
//|                                               OpenTrade_X100.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//-----------------------------------------------------------------------------
int    NUMBER_OF_TRADER = 10;
double INIT_EQUITY      = 500.0;    // Vốn đầu tư
double INIT_VOLUME      = 0.01;     // Lot
double dbRiskRatio      = 0.01;     // Rủi ro 1%
double FIXED_SL_AMP     = 10;
double NEXT_10PER_AMP   = FIXED_SL_AMP/2;
double MAX_PERCENT_POTENTIAL_LOSS = 30; // 30%
double INIT_CLOSE_W1    = 2295;
double AMP_DC           = 3;
double AMP_TP           = 25;
string VER = "V240705";
string INDI_NAME = VER;
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
//-----------------------------------------------------------------------------
#define BtnD10                   "BtnD10_"
#define BtnNoticeH4Ma10          "BtnNoticeH4Ma10_"
#define BtnTradeNow10D           "TRADE_NOW_10D"
#define BtnTPCurSymbol           "BtnTPCurSymbol"
#define BtnResetCond10per        "BtnResetCond10per"
#define BtnCondH4Price           "BtnCondH4Price"
#define BtnCondH4Stoch8020       "BtnCondH4Stoch8020"
#define BtnCondH1Heiken          "BtnCondH1Heiken"
#define BtnCondH1Stoch8020       "BtnCondH1Stoch8020"
#define BtnCond15Seq125          "BtnCond15Seq125"
#define BtnCond15Stoch8020       "BtnCond15Stoch8020"
#define BtnCond05Seq125          "BtnCond05Seq125"
#define BtnCond05Stoch8020       "BtnCond05Stoch8020"
#define BtnCond01Seq125          "BtnCond01Seq125"
#define BtnCond01Stoch8020       "BtnCond01Stoch8020"
//-----------------------------------------------------------------------------
#define BtnSolveNegative         "BtnSolveNegative"
#define BtnPaddingTrade          "BtnPaddingTrade"
#define BtnTradeWithStopLoss     "BtnTradeWithStopLoss"
#define BtnClosePositiveOrders   "BtnClosePositiveOrders"
#define BtnNewCycleBuy           "NewCycleBuy"
#define BtnNewCycleSel           "NewCycleSel"
#define BtnCloseProfitBuy        "BtnCloseProfitBuy"
#define BtnCloseProfitSel        "BtnCloseProfitSel"
#define BtnWaitBuy10Per          "BtnWaitBuy10Per"
#define BtnWaitSel10Per          "BtnWaitSel10Per"
#define BtnBuyNow1Per            "BtnBuyNow1Per"
#define BtnSelNow1Per            "BtnSelNow1Per"
#define BtnSetEntryBuy           "BtnSetEntryBuy"
#define BtnSetEntrySel           "BtnSetEntrySel"
#define BtnDeHedging             "BtnDeHedging"
#define BtnHedgSel2Buy           "BtnHedgSel2Buy"
#define BtnHedgBuy2Sel           "BtnHedgBuy2Sel"
//-----------------------------------------------------------------------------
#define START_TRADE_LINE         "START_TRADE"
bool CondH4Price     = true;
bool CondH4Stoch8020 = true;
bool CondH1Heiken    = true;
bool CondH1Stoch8020 = true;
bool Cond15Seq125    = true;
bool Cond15Stoch8020 = true;
bool Cond05Seq125    = true;
bool Cond05Stoch8020 = true;
bool Cond01Seq125    = true;
bool Cond01Stoch8020 = true;
//-----------------------------------------------------------------------------
bool IS_WAITTING_10PER_BUY = false;
bool IS_WAITTING_10PER_SEL = false;
bool IS_CONTINUE_TRADING_CYCLE_BUY = false;
bool IS_CONTINUE_TRADING_CYCLE_SEL = false;
double PRICE_START_TRADE = 0.0;
double amp_d7            = 0;
double avg_candle_w1     = 0;
double LOWEST_OF_7_DAYS  = 0;
double CENTER_OF_3_DAYS  = 0;
double HIGEST_OF_7_DAYS  = 0;
//-----------------------------------------------------------------------------
double store = 0.0;
bool   DEBUG_MODE = true;
string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string MASK_HEDG = "(HG)";
string MASK_ROOT = "(RO)";
string MASK_EXIT = "(EX)";
string MASK_MANUAL = "(ML)";
string MASK_10PER = "(HS)";
string MASK_D10  = "(D.X)";
string MASK_TREND_TRANSFER = "(T.F)";
string LOCK = "(Lock)";
datetime global_last_open_time = 0;
datetime last_trend_shift_time = TimeCurrent();
string str_buy = "";
string str_sel = "";
double max_drawdown = 0, max_amp = 0;
string max_draw_day = "", max_amp_day = "";
double global_bot_vol_buy = 0, global_bot_vol_sel = 0;
double global_tvol_buy = 0, global_tvol_sel = 0;
double global_max_vol_buy = 0, global_max_vol_sel = 0;
double global_max_count_buy = 0, global_max_count_sel = 0;
double global_min_entry_buy = 0, global_min_entry_sel = 0;
double global_max_entry_buy = 0, global_max_entry_sel = 0;
double global_tprofit_buy = 0, global_tprofit_sel = 0;
double global_potential_profit_buy = 0, global_potential_profit_sel = 0;
double global_min_close_heiken = 0, global_max_close_heiken = 0;
double total_best_potential_profit_buy = 0, total_best_potential_profit_sel = 0;
double global_range_min = 0, global_range_max = 0;
double MAXIMUM_DOUBLE = 999999999;
double global_min_exit_price = MAXIMUM_DOUBLE, global_max_exit_price = 0, global_profit_positive_orders = 0, GLOBAL_POTENTIAL_LOSS = 0;
int global_bot_count_buy = 0, global_bot_count_sel = 0, count_closed_today = 0;
int global_tcount_buy = 0, global_tcount_sel = 0;
int global_bot_count_manual_buy = 0, global_bot_count_manual_sel = 0, global_10percent_count_buy, global_10percent_count_sel = 0;
double global_10percent_min_open_price = 0, global_10percent_max_open_price = 0;
double global_min_entry_manual_buy = 0, global_max_entry_manual_sel = 0;
int global_bot_count_hedg_buy = 0, global_bot_count_hedg_sel = 0;
double global_tvol_hedging_buy = 0, global_tvol_hedging_sel = 0;
int global_bot_count_exit_order = 0, global_bot_count_tp_eq_en_buy = 0, global_bot_count_tp_eq_en_sel = 0;
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
string FILE_NAME_AUTO_TRADE = "_auto_trade_today.txt";
datetime ALERT_MSG_TIME = 0;
datetime TIME_OF_ONE_H1_CANDLE = 3600;
datetime TIME_OF_ONE_H4_CANDLE = 14400;
datetime TIME_OF_ONE_D1_CANDLE = 14400;
datetime TIME_OF_ONE_W1_CANDLE = 14400;
string lable_profit_buy = "", lable_profit_sel = "", lableBtnPaddingTrade = "", lable_profit_positive_orders = "";
int DEFAULT_WAITING_DCA_IN_MINUS = 30, BUTTON_HEIGH = 20;
int MINUTES_BETWEEN_ORDER = 10;
string arr_largest_negative_trader_name[100];
double arr_largest_negative_trader_amount[100];
string INIT_TREND_TODAY = "";
//1.01, 1.03, 1.07, 1.09, 1.1, 1.13, 1.17, 1.19, 1.23, 1.29, 1.31 và 1.37
//double FIBO_1382 = 1.382;
double FIBO_1618 = 1.618;
double FIBO_2618 = 2.618;
string global_comment = "";
// first dimension  : order rows
// second dimension :
int MAX_ROW = 100;
double   Orders[200][10];
int _OrderTicket     = 0;
int _OrderType       = 1;
int _OrderLots       = 2;
int _OrderOpenPrice  = 3;
int _OrderStopLoss   = 4;
int _OrderTakeProfit = 5;
int _OrderProfit     = 6;
int _PotentialProfit = 7;
datetime OrdersOpenTime[200];
string   OrdersComment [200];
bool isDragging = false;
double INIT_START_PRICE = 0.0;
//+------------------------------------------------------------------+
string globalArrFlashSymbols[];
string trend_over_bs_by_stoc_w1 = "_";
string trend_over_bs_by_stoc_d1 = "_";
string trend_over_bs_by_stoc_h4 = "_";
string trend_over_bs_by_stoc_h1 = "_";
string trend_over_bs_by_stoc_15 = "_";
string trend_over_bs_by_stoc_05 = "_";
string trend_over_bs_by_stoc_01 = "_";
string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "", trend_vector_macd_h4 = "", trend_vector_signal_h4 = "", trend_macd_note_h4="";
string trend_by_macd_h1 = "", trend_mac_vs_signal_h1 = "", trend_mac_vs_zero_h1 = "", trend_vector_macd_h1 = "", trend_vector_signal_h1 = "", trend_macd_note_h1="";
string trend_by_macd_cu = "", trend_mac_vs_signal_cu = "", trend_mac_vs_zero_cu = "", trend_vector_macd_cu = "", trend_vector_signal_cu = "", trend_macd_note_cu="";
string trend_week_by_time = "", trend_today_by_time = "", trend_by_ma10_d1 = "", trend_by_ma10_h4 = "", trend_by_ma10_h1 = "";
string trend_by_seq102050_h4 = "", trend_by_seq102050_h1 = "", trend_by_seq102050_15 = "", trend_by_seq102050_05 = "", trend_by_seq102050_01 = "";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend_heiken;
   int               count_heiken;
   double            ma10;
   string            trend_by_ma10;
   int               count_ma10;
   string            trend_vector_ma10;

                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend_heiken = "";
      count_heiken = 0;
      ma10 = 0;
      trend_by_ma10 = "";
      count_ma10 = 0;
      trend_vector_ma10 = "";

     }
                     CandleData(datetime t, double o, double h, double l, double c, string trend_heiken_, int count_heiken_,
              double ma10_, string trend_by_ma10_, int count_ma10_, string trend_vector_ma10_)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend_heiken = trend_heiken_;
      count_heiken = count_heiken_;
      ma10 = ma10_;
      trend_by_ma10 = trend_by_ma10_;
      count_ma10 = count_ma10_;
      trend_vector_ma10 = trend_vector_ma10_;
     }
  };
CandleData arrHeiken_w1[];
CandleData arrHeiken_d1[];
CandleData arrHeiken_h4[];
CandleData arrHeiken_h1[];
CandleData arrHeiken_m5[];
CandleData arrHeiken_m1[];
string free_extended_overnight_fees[] =
  {
   "XAUUSD"
   ,"AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD"
   , "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
   , "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD"
   , "NZDCAD", "NZDJPY", "NZDUSD"
   , "USDCAD", "USDCHF", "USDJPY", "USOIL"
  };
//+------------------------------------------------------------------+
//| OpenTrade_X100                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//WriteAvgAmpToFile();
   string symbol = Symbol();

   InitGlobalArrHeiken(symbol);
   Draw_Buttons_Trend(symbol);
   Draw_Notice_Ma10D();
   Draw_Heiken(symbol);

   if(is_same_symbol(symbol, "XAU"))
     {
      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

      INIT_EQUITY = AccountInfoDouble(ACCOUNT_BALANCE);
      INIT_VOLUME = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, INIT_EQUITY*0.01);

      loadAutoTrade();

      init_amp_dca(symbol);
      init_trade_cond_10precent();
      Protect_Account(symbol);

      Draw_Buttons();
      Draw_Lines(symbol);
      Draw_NextDca();
     }

   DeleteArrowObjects();
   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string symbol = Symbol();

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   create_trend_line("cur_price", TimeCurrent() - TIME_OF_ONE_H4_CANDLE, cur_price, TimeCurrent(), cur_price, clrBlack, STYLE_DOT, 1, true, true);

   Add_Flashing_Color();
   Auto_SL_TP();
//-------------------------------------------------------------------------------
   MqlDateTime time_struct;
   TimeToStruct(TimeCurrent(), time_struct);
   int cur_minus = time_struct.min;
   int pre_check_minus = -1;
   if(GlobalVariableCheck("timer_one_minu"))
      pre_check_minus = (int)GlobalVariableGet("timer_one_minu");
   GlobalVariableSet("timer_one_minu", cur_minus);
   if(pre_check_minus == cur_minus)
      return;
//-------------------------------------------------------------------------------
   if(is_same_symbol(symbol, "XAU"))
      OpenTrade(symbol);

   Auto_SL_TP();
   Draw_Notice_Ma10D();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade(string symbol)
  {
   if(is_same_symbol(symbol, "XAU"))
     {
      InitOrderArr(symbol);
      Protect_Account(symbol);
      Solve_Negative(symbol, false);

      string trader_name = create_trader_name();
      OpenTrade_X100(symbol, trader_name);
     }

   Draw_Buttons();
   Draw_NextDca();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Auto_SL_TP()
  {
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   double risk_1p = risk_1_Percent_Account_Balance()*3;
   double risk_10 = risk_10_Percent_Account_Balance();

   string arrLimitSymbols[];
   string str_opening_symbols = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         string symbol = OrderSymbol();
         string comment = OrderComment();
         double temp_profit = OrderProfit() + OrderSwap() + OrderCommission();

         bool is_1_percent_loss = (risk_1p + temp_profit < 0);
         bool is_10_percent_loss = (risk_10 + temp_profit < 0);
         bool is_10_percent_profit = (temp_profit > risk_10);

         if((OrderType() == OP_BUY) || (OrderType() == OP_SELL))
            str_opening_symbols += "_" + OrderSymbol();

         if((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT))
           {
            int num_symbols = ArraySize(arrLimitSymbols);
            ArrayResize(arrLimitSymbols, num_symbols+1);
            arrLimitSymbols[num_symbols] = OrderSymbol();
           }

         if(MathAbs(temp_profit) > risk_1p)
           {
            string msg = symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";

            CandleData tempHeiken_d1[];
            get_arr_heiken(symbol, PERIOD_D1, tempHeiken_d1, 15, true);

            CandleData tempHeiken_h4[];
            get_arr_heiken(symbol, PERIOD_H4, tempHeiken_h4, 15, true);

            if(is_1_percent_loss)
              {
               if((OrderType() == OP_BUY) &&
                  (tempHeiken_d1[0].trend_by_ma10 == TREND_SEL) &&
                  (tempHeiken_h4[1].trend_by_ma10 == TREND_SEL) &&
                  (tempHeiken_h4[0].trend_heiken == TREND_SEL))
                 {
                  ClosePosition(symbol, OP_BUY, TREND_BUY);
                  SendTelegramMessage(symbol, "STOP_BUY_BY_MA10", "STOP_BUY_BY_MA10: " + msg, true);
                  return;
                 }

               if((OrderType() == OP_SELL) &&
                  (tempHeiken_d1[0].trend_by_ma10 == TREND_BUY) &&
                  (tempHeiken_h4[1].trend_by_ma10 == TREND_BUY) &&
                  (tempHeiken_h4[0].trend_heiken == TREND_BUY))
                 {
                  ClosePosition(symbol, OP_SELL, TREND_SEL);
                  SendTelegramMessage(symbol, "STOP_SEL_BY_MA10", "STOP_SEL_BY_MA10: " + msg, true);
                  return;
                 }
              }

            if(is_10_percent_loss || is_10_percent_profit)
              {
               CandleData tempHeiken_h1[];
               get_arr_heiken(symbol, PERIOD_H1, tempHeiken_h1, 15, true);

               bool stop_buy_by_heiken = (tempHeiken_h4[0].trend_heiken == TREND_SEL && tempHeiken_h1[0].trend_heiken == TREND_SEL);
               bool stop_sel_by_heiken = (tempHeiken_h4[0].trend_heiken == TREND_BUY && tempHeiken_h1[0].trend_heiken == TREND_BUY);

               if((OrderType() == OP_BUY) && stop_buy_by_heiken)
                 {
                  ClosePosition(symbol, OP_BUY, comment);
                  SendTelegramMessage(symbol, "STOP_LOSS", (is_10_percent_loss ? "STOP_LOSS" : "TAKE_PROFIT") + msg, true);
                  return;
                 }

               if(OrderType() == OP_SELL && stop_sel_by_heiken)
                 {
                  ClosePosition(symbol, OP_SELL, comment);
                  SendTelegramMessage(symbol, "STOP_LOSS", (is_10_percent_loss ? "STOP_LOSS" : "TAKE_PROFIT") + msg, true);
                  return;
                 }
              }

            if(is_10_percent_profit)
              {
               double amp_w1, amp_d1, amp_h4, amp_grid_L100;
               GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

               double price = SymbolInfoDouble(symbol, SYMBOL_BID);
               double amp_move = (amp_grid_L100 > 0 && amp_h4 > 0) ? MathMin(amp_h4, amp_grid_L100) : amp_h4;

               bool allow_trailing_stop = (amp_move > 0)
                                          && (OrderOpenPrice() - amp_move < OrderStopLoss())
                                          && (OrderStopLoss() < OrderOpenPrice() + amp_move);

               if(allow_trailing_stop)
                 {
                  int demm = 1;
                  while(demm < 10)
                    {
                     double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
                     double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
                     price = (OrderType() == OP_BUY) ? ASK : (OrderType() == OP_SELL) ? BID : NormalizeDouble((ASK+BID/2), Digits);

                     if(OrderModify(OrderTicket(),price,OrderOpenPrice(), OrderTakeProfit(),0))
                        return;

                     demm++;
                     Sleep(100);
                    }
                 }
              }

           }
        }

//Alert("Close Limit: " + str_opening_symbols);
   if(str_opening_symbols != "")
      for(int index = 0; index < ArraySize(arrLimitSymbols); index++)
        {
         string symbol = arrLimitSymbols[index];
         if(is_same_symbol(str_opening_symbols, symbol) == false)
           {
            if(ClosePosition(symbol, OP_BUYLIMIT, TREND_BUY))
               printf("Close OP_BUYLIMIT: " + symbol);

            if(ClosePosition(symbol, OP_SELLLIMIT, TREND_SEL))
               printf("Close OP_SELLLIMIT: " + symbol);
           }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Notice_Ma10D()
  {
   int x = 5;
   int y = 5;
   int btn_width = 150;
   int btn_heigh = 20;

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

   string STR_SYMBOLS_OPENING = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), STR_SYMBOLS_OPENING) == false)
            STR_SYMBOLS_OPENING += OrderSymbol();
     } //for

   int count = 0;
   string master_msg = "";
   string prefix_msg = "";
   string arrNoticeSymbols[];
   string strNoticeSymbols = "";
   ArrayResize(globalArrFlashSymbols, 0);
   for(int index = 0; index < ArraySize(free_extended_overnight_fees); index++)
     {
      string symbol = free_extended_overnight_fees[index];

      CandleData temp_array_W1[];
      get_arr_heiken(symbol, PERIOD_W1, temp_array_W1);

      CandleData temp_array_D1[];
      get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 21, true);

      CandleData temp_array_H4[];
      get_arr_heiken(symbol, PERIOD_H4, temp_array_H4, 15, true);

      CandleData temp_array_H1[];
      get_arr_heiken(symbol, PERIOD_H1, temp_array_H1, 15, true);

      int count_d10 = temp_array_D1[0].count_ma10;
      string trend_ma10_d1 = temp_array_D1[0].trend_by_ma10;

      bool pass_count_cond_d10 = count_d10 <= 3;
      bool pass_day_h4_h1_cond = (trend_ma10_d1 == temp_array_D1[0].trend_vector_ma10 || trend_ma10_d1 == temp_array_D1[0].trend_heiken)
                                 && (trend_ma10_d1 == temp_array_H4[0].trend_vector_ma10)
                                 && (trend_ma10_d1 == temp_array_H4[0].trend_heiken)
                                 && (trend_ma10_d1 == temp_array_H1[0].trend_heiken)
                                 && (temp_array_H4[0].count_heiken <= 3 || temp_array_H4[0].count_ma10 <= 3);

      string lblWeek = "";
      if(trend_ma10_d1 == temp_array_W1[0].trend_by_ma10 && trend_ma10_d1 == temp_array_W1[0].trend_heiken)
        {
         lblWeek = "W." + getShortName(temp_array_W1[0].trend_by_ma10) + (string)temp_array_W1[0].count_ma10 + " " ;

         if(pass_day_h4_h1_cond)
           {
            int num_symbols = ArraySize(arrNoticeSymbols);
            ArrayResize(arrNoticeSymbols, num_symbols+1);

            strNoticeSymbols += symbol + ".";
            arrNoticeSymbols[num_symbols] = "WDH." + trend_ma10_d1 + " D" + append1Zero(count_d10) + "~" + symbol;
           }
        }

      if(pass_count_cond_d10 && pass_day_h4_h1_cond)
        {
         int num_symbols = ArraySize(arrNoticeSymbols);
         ArrayResize(arrNoticeSymbols, num_symbols+1);

         strNoticeSymbols += symbol + ".";
         arrNoticeSymbols[num_symbols] = "D3H." + trend_ma10_d1 + " D" + append1Zero(count_d10) + "~" + symbol;
        }

      double total_profit = 0;
      if(is_same_symbol(symbol, STR_SYMBOLS_OPENING))
        {
         for(int i = OrdersTotal() - 1; i >= 0; i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
               if(is_same_symbol(OrderSymbol(), symbol))
                  total_profit += OrderProfit() + OrderSwap() + OrderCommission();
           }
        }

      string lable = lblWeek + symbol + " " + getShortName(trend_ma10_d1) + "" + append1Zero(count_d10);
      if(MathAbs(total_profit) > 0)
         lable += " $" + (string)(int)total_profit + "";

      bool is_cur_tab = is_same_symbol(lable, ChartSymbol(0));
      color clrBackground = (count_d10 <= 3) && (trend_ma10_d1 == temp_array_H4[0].trend_heiken) ? clrLightGreen : clrLightGray;
      color clrText = total_profit > 0 ? clrBlue : total_profit == 0 ? clrBlack : clrFireBrick;

      btn_heigh = index == 0 ? 50 : 20;
      if(index == 12)
        {count = 0; x = 160; y = 35; btn_heigh = 20;}

      int sub_window = 3;
      createButton(BtnD10 + symbol, lable, x + (btn_width + 5)*count, is_cur_tab && (index > 0) ? y - 3 : y, btn_width, (index == 0) ? btn_heigh : is_cur_tab ? btn_heigh+5 : btn_heigh, clrText, is_cur_tab ? clrPaleTurquoise : clrBackground, 7, sub_window);

      if(is_same_symbol(symbol, STR_SYMBOLS_OPENING))
         createButton("_" + symbol, "", x + (btn_width + 5)*count, y + (is_cur_tab ? 3 : 0) + btn_heigh, btn_width, 5, clrBlack, clrLightGreen, 8, sub_window);

      count += 1;
      if(pass_count_cond_d10 || lblWeek != "")
         ObjectSetString(0, BtnD10 + symbol, OBJPROP_FONT, "Arial Bold");

      double vol = 0;
      if(is_cur_tab)
        {
         InitOrderArr(Symbol());
         Comment(GetComments());
         ObjectSetString(0, BtnD10 + symbol, OBJPROP_FONT, "Arial");

         double min_7d = 0;
         double max_7d = 0;
         for(int i = 0; i < 7; i++)
           {
            if(i==0 || min_7d > temp_array_D1[i].low)
               min_7d = temp_array_D1[i].low;

            if(i==0 || max_7d < temp_array_D1[i].high)
               max_7d = temp_array_D1[i].high;
           }
         min_7d -= amp_h4;
         max_7d += amp_h4;

         double min_21d = 0;
         double max_21d = 0;
         for(int i = 0; i < ArraySize(temp_array_D1); i++)
           {
            if(i==0 || min_21d > temp_array_D1[i].low)
               min_21d = temp_array_D1[i].low;

            if(i==0 || max_21d < temp_array_D1[i].high)
               max_21d = temp_array_D1[i].high;
           }

         double amp_sl =  trend_ma10_d1 == TREND_BUY ? (Bid - min_7d) : (max_7d - Ask);
         double amp_tp =  trend_ma10_d1 == TREND_BUY ? (max_21d - Ask) : (Bid - min_21d);
         double risk_10 = risk_10_Percent_Account_Balance();
         vol = calc_volume_by_amp(symbol, amp_sl, risk_10);

         color clrD10 = temp_array_D1[0].trend_by_ma10 == TREND_BUY ?clrBlue : clrRed;
         double sl = trend_ma10_d1 == TREND_BUY ? min_7d : max_7d;
         double tp = trend_ma10_d1 == TREND_BUY ? max_21d : min_21d;
         string rr_d1 = "1:" + (string)NormalizeDouble(amp_tp/amp_sl, 1) + " ";

         datetime timeW0 = iTime(symbol, PERIOD_W1, 0);
         create_trend_line("SL", timeW0, sl, TimeCurrent()+TIME_OF_ONE_H4_CANDLE, sl, clrBlack);
         create_trend_line("TP", timeW0, tp, TimeCurrent()+TIME_OF_ONE_H4_CANDLE, tp, clrBlack);
         create_trend_line("Ma10D", timeW0, temp_array_D1[0].ma10, TimeCurrent()+TIME_OF_ONE_H4_CANDLE, temp_array_D1[0].ma10, clrD10);
         create_lable_simple("VECTOR_10D", " VecD10: " + getShortName(temp_array_D1[0].trend_vector_ma10) + "", temp_array_D1[0].ma10, clrD10);

         int x_btn, y_btn;
         if(is_main_control_screen() && ChartTimePriceToXY(0, 0, TimeCurrent(), sl, x_btn, y_btn))
           {
            string str_trade_by_ma10 = "(SL) " + trend_ma10_d1 + " " + symbol + " 10%(" + (string)(int) risk_10 + "$)" + format_double_to_string(vol, 2) + " " + rr_d1;
            createButton(BtnTradeNow10D, str_trade_by_ma10, x_btn + 10, y_btn-11, 250, 20, trend_ma10_d1 == TREND_BUY ? clrBlue : clrFireBrick, clrWhite, 6);
           }

         if(total_profit > 0 && total_profit > minProfit())
            if(is_main_control_screen() && ChartTimePriceToXY(0, 0, TimeCurrent(), tp, x_btn, y_btn))
               createButton(BtnTPCurSymbol, "(TP) " + symbol + " " + (string)(int)total_profit + "$", x_btn + 90, y_btn-11, 130, 20,  clrBlue, clrWhite, 7);
        }


      // Send Message
      if(pass_count_cond_d10 || pass_day_h4_h1_cond)
        {
         if(trend_ma10_d1 == temp_array_H4[0].trend_heiken)
           {
            int num_symbols = ArraySize(globalArrFlashSymbols);
            ArrayResize(globalArrFlashSymbols, num_symbols+1);
            globalArrFlashSymbols[num_symbols] = BtnD10 + symbol;
           }

         prefix_msg = symbol + " " + trend_ma10_d1 + "D(" + (string)count_d10 + ")";
         string msg = "";
         if(trend_ma10_d1 == temp_array_H4[0].trend_heiken && trend_ma10_d1 == temp_array_H1[0].trend_heiken)
           {
            if(temp_array_H4[0].count_ma10 <= 3)
               msg += " by: count_ma10_H4(" + (string)temp_array_H4[0].count_ma10 + ")\n";

            if(temp_array_H4[0].count_heiken <= 3)
               msg += " by: count_heiken_H4(" + (string)temp_array_H4[0].count_heiken + ")\n";

            if(temp_array_H1[0].count_ma10 <= 3)
               msg += " by: count_ma10_H1(" + (string)temp_array_H1[0].count_ma10 + ")\n";
           }

         if(msg != "")
            master_msg += prefix_msg + "\n" +  msg;
        }
     }

   if(master_msg != "")
      SendTelegramMessage("D10", "OPEN_TRADE", master_msg, false);


   for(int index = 0; index < ArraySize(free_extended_overnight_fees); index++)
     {
      string symbol = free_extended_overnight_fees[index];
      ObjectDelete(0, BtnNoticeH4Ma10 + symbol);
     }
   int x_max = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   for(int index = 0; index < ArraySize(arrNoticeSymbols); index++)
     {
      string strLable = arrNoticeSymbols[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, TREND_BUY) ? clrBlue : clrFireBrick;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : clrWhite;
      createButton(BtnNoticeH4Ma10 + symbol, strLable, x_max-166, 80+index*25, 160, 20, clrText, clrBg, 7);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitGlobalArrHeiken(string symbol)
  {
   trend_over_bs_by_stoc_w1 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_W1);
   trend_over_bs_by_stoc_d1 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_D1);
   trend_over_bs_by_stoc_h4 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_H4);
   trend_over_bs_by_stoc_h1 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_H1);
   trend_over_bs_by_stoc_15 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_M15);
   trend_over_bs_by_stoc_05 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_M5);
   trend_over_bs_by_stoc_01 = get_trend_when_overbought_or_oversold_by_stoc(symbol, PERIOD_M1);

   trend_by_seq102050_h4 = get_trend_by_ma10_20_50(symbol, PERIOD_H4);
   trend_by_seq102050_h1 = get_trend_by_ma10_20_50(symbol, PERIOD_H1);
   trend_by_seq102050_15 = get_trend_by_ma10_20_50(symbol, PERIOD_M15);
   trend_by_seq102050_05 = get_trend_by_ma10_20_50(symbol, PERIOD_M5);
   trend_by_seq102050_01 = get_trend_by_ma10_20_50(symbol, PERIOD_M1);

   get_arr_heiken(symbol, PERIOD_W1, arrHeiken_w1);
   get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 60, true);
   get_arr_heiken(symbol, PERIOD_H4, arrHeiken_h4, 20, true);
   get_arr_heiken(symbol, PERIOD_H1, arrHeiken_h1, 20, true);
   get_arr_heiken(symbol, PERIOD_M5, arrHeiken_m5);
   get_arr_heiken(symbol, PERIOD_M1, arrHeiken_m1);

   trend_by_ma10_d1 = arrHeiken_d1[0].trend_by_ma10;
   trend_by_ma10_h4 = arrHeiken_h4[0].trend_by_ma10;
   trend_by_ma10_h1 = arrHeiken_h1[0].trend_by_ma10;

   trend_week_by_time = getTrendByLowHigTimes(symbol, iTime(symbol, PERIOD_W1, 0), TimeCurrent(), PERIOD_H4);
   trend_today_by_time = getTrendByLowHigTimes(symbol, iTime(symbol, PERIOD_D1, 0), TimeCurrent(), PERIOD_H1);

   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4,      trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4, trend_vector_macd_h4, trend_vector_signal_h4, trend_macd_note_h4);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H1,      trend_by_macd_h1, trend_mac_vs_signal_h1, trend_mac_vs_zero_h1, trend_vector_macd_h1, trend_vector_signal_h1, trend_macd_note_h1);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_CURRENT, trend_by_macd_cu, trend_mac_vs_signal_cu, trend_mac_vs_zero_cu, trend_vector_macd_cu, trend_vector_signal_cu, trend_macd_note_cu);

   INIT_TREND_TODAY = trend_mac_vs_zero_h4;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitOrderArr(string symbol)
  {
   if(is_same_symbol(symbol, "XAU") == false)
      return;

   InitGlobalArrHeiken(symbol);
//----------------------------------------------------------------------
   global_min_close_heiken = 0;
   global_max_close_heiken = 0;
   for(int i = 0; i < ArraySize(arrHeiken_m5); i++)
     {
      double close = arrHeiken_m5[i].close;
      if(i==0 || global_min_close_heiken > close)
         global_min_close_heiken = close;
      if(i==0 || global_max_close_heiken < close)
         global_max_close_heiken = close;
     }
   for(int i = 0; i < ArraySize(arrHeiken_h1); i++)
     {
      double close = arrHeiken_h1[i].close;
      if(i==0 || global_min_close_heiken > close)
         global_min_close_heiken = close;
      if(i==0 || global_max_close_heiken < close)
         global_max_close_heiken = close;
     }
//----------------------------------------------------------------------
   for(int order_idx = 0; order_idx < MAX_ROW; order_idx ++)
     {
      Orders[order_idx][_OrderTicket]      = 0;
      Orders[order_idx][_OrderType]        =-1;
      Orders[order_idx][_OrderLots]        = 0;
      Orders[order_idx][_OrderOpenPrice]   = 0;
      Orders[order_idx][_OrderStopLoss]    = 0;
      Orders[order_idx][_OrderTakeProfit]  = 0;
      Orders[order_idx][_OrderProfit]      = 0;
      Orders[order_idx][_PotentialProfit]  = 0;

      OrdersOpenTime[order_idx]            = 0;
      OrdersComment [order_idx]            = "";
     }

   int last_ticket_buy = 0, last_ticket_sel = 0;
   int count_possion_buy = 0, count_possion_sel = 0;
   double total_volume_buy = 0.0, total_volume_sel = 0.0;
   double total_profit_buy = 0.0, total_profit_sel = 0.0;
   string last_comment_buy = "", last_comment_sel = "";

   int order_idx=0;

   global_range_min = MAXIMUM_DOUBLE;
   global_range_max = 0;
   global_bot_vol_buy = 0;
   global_bot_vol_sel = 0;
   global_tvol_buy = 0;
   global_tvol_sel = 0;
   global_bot_count_buy = 0;
   global_bot_count_sel = 0;
   global_tcount_buy = 0;
   global_tcount_sel = 0;
   global_tprofit_buy = 0;
   global_tprofit_sel = 0;
   global_bot_count_hedg_buy = 0;
   global_bot_count_hedg_sel = 0;
   global_tvol_hedging_buy = 0;
   global_tvol_hedging_sel = 0;
   global_bot_count_exit_order = 0;
   global_bot_count_manual_buy = 0;
   global_bot_count_manual_sel = 0;
   global_10percent_count_buy = 0;
   global_10percent_count_sel = 0;
   global_10percent_min_open_price = 0;
   global_10percent_max_open_price = 0;
   global_min_entry_manual_buy = 0;
   global_max_entry_manual_sel = 0;
   global_bot_count_tp_eq_en_buy = 0;
   global_bot_count_tp_eq_en_sel = 0;
   global_min_entry_buy = MAXIMUM_DOUBLE;
   global_max_entry_buy = 0;
   global_min_entry_sel = MAXIMUM_DOUBLE;
   global_max_entry_sel = 0;
   global_potential_profit_buy = 0;
   global_potential_profit_sel = 0;
   total_best_potential_profit_buy = 0;
   total_best_potential_profit_sel = 0;
   int max_count = 0;
   string msg_stoploss = "";
   double global_profit_buy = 0, global_profit_sel = 0;
   double potential_profit_buy = 0, potential_profit_sel = 0;
   GLOBAL_POTENTIAL_LOSS = 0;
   global_profit_positive_orders = 0;
   int count_profit_positive_orders_buy = 0, count_profit_positive_orders_sel = 0;

   double risk = risk_1_Percent_Account_Balance();
   double min_profit = minProfit();
   double risk_10 = risk_10_Percent_Account_Balance();

   double EQUITY  = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   bool is_10_percent_loss = (BALANCE*0.1 + ACC_PROFIT < 0);

   double best_tp_buy = get_tp_best(symbol, TREND_BUY);
   double best_tp_sel = get_tp_best(symbol, TREND_SEL);

   bool stoploss_buy_by_heiken = is_stoploss_buy_by_heiken_h4h1();
   bool stoploss_buy_by_macd = is_stoploss_buy_by_macd();
   if(stoploss_buy_by_heiken || stoploss_buy_by_macd)
     {
      IS_WAITTING_10PER_BUY = false;
      IS_CONTINUE_TRADING_CYCLE_BUY = false;
      saveAutoTrade();
     }

   bool stoploss_sel_by_heiken = is_stoploss_sel_by_heiken_h4h1();
   bool stoploss_sell_by_macd = is_stoploss_sell_by_macd();
   if(stoploss_buy_by_heiken || stoploss_buy_by_macd)
     {
      IS_WAITTING_10PER_SEL = false;
      IS_CONTINUE_TRADING_CYCLE_SEL = false;
      saveAutoTrade();
     }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            string comment = OrderComment();
            double temp_profit = OrderProfit() + OrderSwap() + OrderCommission();

            double potentialProfit = calcPotentialTradeProfit(symbol, OrderType(), OrderOpenPrice(), OrderTakeProfit(), OrderLots());

            double temp_sl = 0;
            if(OrderType() == OP_BUY)
              {
               temp_sl = OrderOpenPrice() - FIXED_SL_AMP;
               total_best_potential_profit_buy += calcPotentialTradeProfit(Symbol(), OrderType(), OrderOpenPrice(), best_tp_buy, OrderLots());
              }

            if(OrderType() == OP_SELL)
              {
               temp_sl = OrderOpenPrice() + FIXED_SL_AMP;
               total_best_potential_profit_sel += calcPotentialTradeProfit(Symbol(), OrderType(), OrderOpenPrice(), best_tp_sel, OrderLots());
              }

            double potential_loss = 0;
            if(temp_sl > 0)
               potential_loss = calcPotentialTradeProfit(symbol, OrderType(), OrderOpenPrice(), temp_sl, OrderLots());

            GLOBAL_POTENTIAL_LOSS += potential_loss;

            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double cur_price = (bid+ask)/2;
            //-----------------------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------------------
            if(is_10_percent_loss)
              {
               string msg = "StopLoss: " + symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";

               if((OrderType() == OP_BUY) && stoploss_buy_by_heiken)
                 {
                  printf(msg);
                  ClosePosition(symbol, OP_BUY, comment);
                  SendTelegramMessage(symbol, TREND_BUY, msg, true);
                  return;
                 }

               if(OrderType() == OP_SELL && stoploss_sel_by_heiken)
                 {
                  printf(msg);
                  ClosePosition(symbol, OP_SELL, comment);
                  SendTelegramMessage(symbol, TREND_SEL, msg, true);
                  return;

                 }
              }
            //-----------------------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------------------
            if(temp_profit > risk_10)
              {
               string msg = "TakeProfit: " + symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";

               if((OrderType() == OP_BUY) && stoploss_buy_by_heiken)
                 {
                  IS_CONTINUE_TRADING_CYCLE_BUY = false;
                  saveAutoTrade();
                  ClosePosition(symbol, OP_BUY, comment);
                  SendTelegramMessage(symbol, TREND_BUY, msg + " TP_BY_HEIKEN", true);
                 }

               if((OrderType() == OP_SELL) && stoploss_sel_by_heiken)
                 {
                  IS_CONTINUE_TRADING_CYCLE_SEL = false;
                  saveAutoTrade();
                  ClosePosition(symbol, OP_SELL, comment);
                  SendTelegramMessage(symbol, TREND_SEL, msg + " TP_BY_HEIKEN", true);
                 }
              }
            //-----------------------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------------------
            if(OrderType() == OP_BUY)
              {
               global_tcount_buy += 1;
               global_tvol_buy += OrderLots();
               global_tprofit_buy += temp_profit;
               global_potential_profit_buy += potentialProfit;

               if(global_min_entry_buy > OrderOpenPrice())
                  global_min_entry_buy = OrderOpenPrice();

               if(global_max_entry_buy < OrderOpenPrice())
                  global_max_entry_buy = OrderOpenPrice();
              }

            if(OrderType() == OP_SELL)
              {
               global_tcount_sel += 1;
               global_tvol_sel += OrderLots();
               global_tprofit_sel += temp_profit;
               global_potential_profit_sel += potentialProfit;

               if(global_min_entry_sel > OrderOpenPrice())
                  global_min_entry_sel = OrderOpenPrice();

               if(global_max_entry_sel < OrderOpenPrice())
                  global_max_entry_sel = OrderOpenPrice();
              }

            //if(OrderTakeProfit()-1 <= OrderOpenPrice() && OrderOpenPrice() <= OrderTakeProfit()+1)
            if(OrderTakeProfit() > 0)
              {
               if(OrderType() == OP_BUY)
                  global_bot_count_tp_eq_en_buy += 1;

               if(OrderType() == OP_SELL)
                  global_bot_count_tp_eq_en_sel += 1;
              }

            if(OrderProfit() > 1)
              {
               global_profit_positive_orders += OrderProfit();
               if(OrderType() == OP_BUY)
                  count_profit_positive_orders_buy += 1;

               if(OrderType() == OP_SELL)
                  count_profit_positive_orders_sel += 1;
              }

            if(is_same_symbol(comment, MASK_HEDG))
              {
               if(OrderType() == OP_BUY)
                 {
                  global_bot_count_hedg_buy += 1;
                  global_tvol_hedging_buy += OrderLots();
                 }

               if(OrderType() == OP_SELL)
                 {
                  global_bot_count_hedg_sel += 1;
                  global_tvol_hedging_sel += OrderLots();
                 }
              }

            if(is_same_symbol(comment, MASK_EXIT))
              {
               global_bot_count_exit_order += 1;
               if(global_min_exit_price > OrderOpenPrice())
                  global_min_exit_price = OrderOpenPrice();
               if(global_max_exit_price < OrderOpenPrice())
                  global_max_exit_price = OrderOpenPrice();
              }

            if(is_same_symbol(comment, MASK_10PER))
              {
               if(OrderType() == OP_BUY)
                  global_10percent_count_buy += 1;

               if(OrderType() == OP_SELL)
                  global_10percent_count_sel += 1;

               if(global_10percent_min_open_price > OrderOpenPrice())
                  global_10percent_min_open_price = OrderOpenPrice();

               if(global_10percent_max_open_price < OrderOpenPrice())
                  global_10percent_max_open_price = OrderOpenPrice();

               bool must_sl = false;
               if((OrderType() == OP_BUY)  && (cur_price < OrderOpenPrice() - FIXED_SL_AMP))
                  must_sl = true;

               if((OrderType() == OP_SELL) && (cur_price > OrderOpenPrice() + FIXED_SL_AMP))
                  must_sl = true;

               if(must_sl)
                 {
                  msg_stoploss += "(MUST)SL: " + symbol + (string)OrderTicket() + "   p: " + (string)temp_profit + "$\n" ;
                 }
              }

            if(is_manual_trade(comment))
              {
               if(OrderType() == OP_BUY)
                 {
                  if(global_bot_count_manual_buy == 0 || global_min_entry_manual_buy > OrderOpenPrice())
                     global_min_entry_manual_buy = OrderOpenPrice();

                  global_bot_count_manual_buy += 1;
                 }

               if(OrderType() == OP_SELL)
                 {
                  if(global_bot_count_manual_sel == 0 || global_max_entry_manual_sel < OrderOpenPrice())
                     global_max_entry_manual_sel = OrderOpenPrice();

                  global_bot_count_manual_sel += 1;
                 }
              }

            global_range_min = MathMin(global_range_min, MathMin(OrderOpenPrice(), OrderTakeProfit()));
            global_range_max = MathMax(global_range_max, MathMax(OrderOpenPrice(), OrderTakeProfit()));
            //-----------------------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------------------
            //-----------------------------------------------------------------------------------------------------------
            //if(is_same_symbol(comment, BOT_SHORT_NM))
              {
               Orders[order_idx][_OrderTicket]      = OrderTicket();
               Orders[order_idx][_OrderType]        = OrderType();
               Orders[order_idx][_OrderLots]        = OrderLots();
               Orders[order_idx][_OrderOpenPrice]   = OrderOpenPrice();
               Orders[order_idx][_OrderStopLoss]    = OrderStopLoss();
               Orders[order_idx][_OrderTakeProfit]  = OrderTakeProfit();
               Orders[order_idx][_OrderProfit]      = temp_profit;
               Orders[order_idx][_PotentialProfit]  = potentialProfit;

               OrdersOpenTime[order_idx]            = OrderOpenTime();
               OrdersComment [order_idx]            = OrderComment();
               order_idx += 1;
               //---------------------------------------------------------------------
               if(OrderType() == OP_BUY)
                 {
                  if(is_same_symbol(comment, MASK_HEDG) == false)
                    {
                     count_possion_buy += 1;
                     total_volume_buy += OrderLots();
                     total_profit_buy += temp_profit;
                    }

                  if(last_ticket_buy == 0 || last_ticket_buy < OrderTicket())
                    {
                     last_ticket_buy = OrderTicket();
                     last_comment_buy = comment;
                    }

                  global_bot_count_buy += 1;
                  global_bot_vol_buy += OrderLots();
                  global_profit_buy += temp_profit;
                  potential_profit_buy += potentialProfit;
                 }
               //---------------------------------------------------------------------
               if(OrderType() == OP_SELL)
                 {
                  if(is_same_symbol(comment, MASK_HEDG) == false)
                    {
                     count_possion_sel += 1;
                     total_volume_sel += OrderLots();
                     total_profit_sel += temp_profit;
                    }

                  if(last_ticket_sel == 0 || last_ticket_sel < OrderTicket())
                    {
                     last_ticket_sel = OrderTicket();
                     last_comment_sel = comment;
                    }

                  global_bot_count_sel += 1;
                  global_bot_vol_sel += OrderLots();
                  global_profit_sel += temp_profit;
                  potential_profit_sel += potentialProfit;
                 }
               //---------------------------------------------------------------------
              }
           }
     }

   if(msg_stoploss != "")
      SendTelegramMessage(symbol, "SL", msg_stoploss, false);

   lable_profit_positive_orders = "TP: " +
                                  "B" + (string) count_profit_positive_orders_buy + " " +
                                  "S" + (string) count_profit_positive_orders_sel + " " +
                                  "(" + (string)(global_profit_positive_orders > risk*0.1 ? format_double_to_string(global_profit_positive_orders, 1) : "0.0") + "$)";

   bool is_main_screen = is_main_control_screen();


   lable_profit_buy = "";
   if(global_bot_count_buy > 0 || (is_main_screen && global_tcount_buy > 0))
     {
      lable_profit_buy = "(B" + (string) global_bot_count_buy + ") "
                         + AppendSpaces(format_double_to_string(global_profit_buy, 1) + " ", 8, false)
                         + "Est: " + format_double_to_string(potential_profit_buy, 1) + "("
                         + format_double_to_string(potential_profit_buy/INIT_EQUITY * 100, 1) + "%)";

      if(is_main_screen)
         lable_profit_buy = "(B" + (string) global_tcount_buy + ") "
                            + AppendSpaces(format_double_to_string(global_tprofit_buy, 1) + " ", 8, false)
                            + "Est: " + format_double_to_string(global_potential_profit_buy, 1) + "("
                            + format_double_to_string(global_potential_profit_buy/INIT_EQUITY * 100, 1) + "%)";
     }

   lable_profit_sel = "";
   if(global_bot_count_sel > 0 || (is_main_screen && global_tcount_sel > 0))
     {
      lable_profit_sel = "(S" + (string) global_bot_count_sel + ") "
                         + AppendSpaces(format_double_to_string(global_profit_sel, 1) + " ", 8, false)
                         + "Est: " + format_double_to_string(potential_profit_sel, 1) + "("
                         + format_double_to_string(potential_profit_sel/INIT_EQUITY * 100, 1) + "%)";

      if(is_main_screen)
         lable_profit_sel = "(S" + (string) global_tcount_sel + ") "
                            + AppendSpaces(format_double_to_string(global_tprofit_sel, 1) + " ", 8, false)
                            + "Est: " + format_double_to_string(global_potential_profit_sel, 1) + "("
                            + format_double_to_string(global_potential_profit_sel/INIT_EQUITY * 100, 1) + "%)";
     }

   global_comment = "";
   if(MathAbs(total_profit_buy) > 0)
     {
      if(!is_main_screen)
         global_comment +=  AppendSpaces(create_trader_name(), 8)
                            + " Buy: " + Append(count_possion_buy, 2) + "L" + AppendSpaces(format_double_to_string(total_volume_buy, 2), 6, false) + " lot.\n";

      if(is_main_screen)
         global_comment +=  AppendSpaces("ALL", 8)
                            + " Buy: " + Append(global_tcount_buy, 2) + "L"
                            + "    Amp: " + format_double_to_string(global_max_entry_buy - global_min_entry_buy, Digits-1)
                            + "    Vol: " + AppendSpaces(format_double_to_string(global_tvol_buy, 2), 6, false) + " lot.\n";
     }

   if(MathAbs(total_profit_sel) > 0)
     {
      if(!is_main_screen)
         global_comment += AppendSpaces(create_trader_name(), 8)
                           + " Sell: " + Append(count_possion_sel, 2) + "L" + AppendSpaces(format_double_to_string(total_volume_sel, 2), 6, false) + " lot.\n";

      if(is_main_screen)
         global_comment +=  AppendSpaces("ALL", 8)
                            + " Sell: " + Append(global_tcount_sel, 2) + "L"
                            + "    Amp: " + format_double_to_string(global_max_entry_sel - global_min_entry_sel, Digits-1)
                            + "    Vol: " + AppendSpaces(format_double_to_string(global_tvol_sel, 2), 6, false) + " lot.\n";
     }

   if(max_count < count_possion_buy)
      max_count = count_possion_buy;
   if(max_count < count_possion_sel)
      max_count = count_possion_sel;
   if(max_amp < global_max_entry_buy - global_min_entry_buy)
     {
      max_amp = global_max_entry_buy - global_min_entry_buy;
      max_amp_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }
   if(max_amp < global_max_entry_sel - global_min_entry_sel)
     {
      max_amp = global_max_entry_sel - global_min_entry_sel;
      max_amp_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }

   if(ACC_PROFIT < max_drawdown)
     {
      max_drawdown = ACC_PROFIT;
      max_draw_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }

   string comment = GetComments();
   if(comment != "")
     {
      comment = comment
                + "    Vol (B-S): " + format_double_to_string(NormalizeDouble(global_tvol_buy - global_tvol_sel, 2), 2)
                + "    L: " + (string)OrdersTotal() + "    Ex: " + (string) global_bot_count_exit_order
                + "    Balance:" + format_double_to_string(BALANCE/100, 2) + " (x" + format_double_to_string((BALANCE/INIT_EQUITY), 2)+ ")"
                + "    Profit:" + get_acc_profit_percent();

      comment += "\n\n";
     }
   Comment(comment + global_comment);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double tp_buy = get_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);
   double tp_sel = get_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
   create_trend_line("TP_BUY", iTime(symbol, PERIOD_W1, 0), tp_buy, TimeCurrent(), tp_buy, clrBlue, STYLE_DOT, 1, false, false);
   create_trend_line("TP_SEL", iTime(symbol, PERIOD_W1, 0), tp_sel, TimeCurrent(), tp_sel, clrBlue, STYLE_DOT, 1, false, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade_X100(string symbol, string TRADER)
  {
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   int slippage = (int)MathAbs(ask-bid);
//-------------------------------------------------------------------------------------------------
   if(is_main_control_screen())
     {
      double close_d1 = iClose(symbol, PERIOD_D1, 1);

      ObjectDelete(0, "ML_BUY");

      double append_vol_buy = 0;
      if(global_bot_count_manual_buy > 0)
        {
         double amp_moved = global_min_entry_manual_buy - ask;
         //if(amp_moved > 0)
           {
            append_vol_buy = NormalizeDouble(INIT_VOLUME*(amp_moved/AMP_DC), 2);
            string lable_buy = format_double_to_string(INIT_VOLUME, 2) + "lot  "
                               + format_double_to_string(append_vol_buy, 2) + "lot  "
                               + format_double_to_string(amp_moved, Digits-1) + "mov";

            if(Period() < PERIOD_H1)
               create_lable("ML_BUY", TimeCurrent(), close_d1, lable_buy, "", true, 6);
           }
        }

      ObjectDelete(0, "ML_SEL");
      double append_vol_sel = 0;
      if(global_bot_count_manual_sel > 0)
        {
         double amp_moved = bid - global_max_entry_manual_sel;
         //if(amp_moved > 0)
           {
            append_vol_sel = NormalizeDouble(INIT_VOLUME*(amp_moved/AMP_DC), 2);
            string lable_sel = format_double_to_string(INIT_VOLUME, 2) + "lot  "
                               + format_double_to_string(append_vol_sel, 2) + "lot  "
                               + format_double_to_string(amp_moved, Digits-1) + "mov";

            if(Period() < PERIOD_H1)
               create_lable("ML_SEL", TimeCurrent(), close_d1, lable_sel, "", true, 6);
           }
        }
      //-------------------------------------------------------------------------------------------------
      if(IS_CONTINUE_TRADING_CYCLE_BUY || IS_CONTINUE_TRADING_CYCLE_SEL)
        {
         if(IS_CONTINUE_TRADING_CYCLE_BUY && (global_bot_count_manual_buy == 0))
            if(is_same_symbol(trend_over_bs_by_stoc_h1, TREND_BUY) &&
               is_same_symbol(trend_over_bs_by_stoc_01, TREND_BUY))
              {
               string comment = "at." + MASK_MANUAL + create_comment(create_trader_name(), TREND_BUY, global_bot_count_manual_buy+1);

               bool exit_ok = Open_Position(symbol, OP_BUY, INIT_VOLUME, 0.0, 0.0, comment);
               if(exit_ok)
                 {
                  IS_CONTINUE_TRADING_CYCLE_BUY = true;
                  IS_CONTINUE_TRADING_CYCLE_SEL = false;
                  saveAutoTrade();

                  SendTelegramMessage(symbol, "AUTO_BUY", "AUTO_BUY ("+MASK_MANUAL+")" + symbol + " " + comment, false);
                 }
              }

         if(IS_CONTINUE_TRADING_CYCLE_SEL && (global_bot_count_manual_sel == 0))
            if(is_same_symbol(trend_over_bs_by_stoc_h1, TREND_SEL) &&
               is_same_symbol(trend_over_bs_by_stoc_01, TREND_SEL))
              {
               string comment = "at." + MASK_MANUAL + create_comment(create_trader_name(), TREND_SEL, global_bot_count_manual_sel+1);

               bool exit_ok = Open_Position(symbol, OP_SELL, INIT_VOLUME, 0.0, 0.0, comment);
               if(exit_ok)
                 {
                  IS_CONTINUE_TRADING_CYCLE_BUY = false;
                  IS_CONTINUE_TRADING_CYCLE_SEL = true;
                  saveAutoTrade();

                  SendTelegramMessage(symbol, "AUTO_SEL", "AUTO_SEL ("+MASK_MANUAL+")" + symbol + " " + comment, false);
                 }
              }
        }
      //-------------------------------------------------------------------------------------------------
      if(global_bot_count_manual_buy + global_bot_count_manual_sel > 0)
        {
         if(IS_CONTINUE_TRADING_CYCLE_BUY && global_bot_count_manual_buy > 0 &&
            global_bot_count_manual_buy > 0 && global_min_entry_manual_buy-AMP_DC > ask)
           {
            if(arrHeiken_m1[0].trend_heiken == TREND_BUY && is_same_symbol(trend_over_bs_by_stoc_01, TREND_BUY))
              {
               string comment = MASK_MANUAL + create_comment(create_trader_name(), TREND_BUY, global_bot_count_manual_buy+1);

               bool exit_ok = Open_Position(symbol, OP_BUY, MathMax(INIT_VOLUME, append_vol_buy), 0.0, 0.0, comment);
               if(exit_ok)
                  printf("("+MASK_MANUAL+")" + symbol + " " + comment);
              }
           }

         if(IS_CONTINUE_TRADING_CYCLE_SEL && global_bot_count_manual_sel > 0 &&
            global_bot_count_manual_sel > 0 && global_max_entry_manual_sel+AMP_DC < bid)
           {
            if(arrHeiken_m1[0].trend_heiken == TREND_SEL && is_same_symbol(trend_over_bs_by_stoc_01, TREND_SEL))
              {
               string comment = MASK_MANUAL + create_comment(create_trader_name(), TREND_SEL, global_bot_count_manual_sel+1);

               bool exit_ok = Open_Position(symbol, OP_SELL, MathMax(INIT_VOLUME, append_vol_sel), 0.0, 0.0, comment);
               if(exit_ok)
                  printf("("+MASK_MANUAL+")" + symbol + " " + comment);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_play_for_exit_trade()
  {
   return ((global_bot_count_hedg_buy+global_bot_count_hedg_sel > 0) || (global_bot_count_exit_order > 0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Protect_Account(string symbol)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   if(ACC_PROFIT > risk_1_Percent_Account_Balance() && is_play_for_exit_trade())
      ClosePositivePosition(symbol, "");

   bool is_20_percent_loss = (BALANCE*0.2 + ACC_PROFIT < 0);
   if(is_20_percent_loss)
     {
      IS_WAITTING_10PER_BUY = false;
      IS_WAITTING_10PER_SEL = false;

      IS_CONTINUE_TRADING_CYCLE_BUY = false;
      IS_CONTINUE_TRADING_CYCLE_SEL = false;
     }

   if(global_bot_count_hedg_buy + global_bot_count_hedg_sel == 0)
      if(is_20_percent_loss && is_main_control_screen())
        {
         do_hedging(symbol);
         SendTelegramMessage(symbol, "HEDGING", "(HEDGING) ACC_PROFIT:" + (string)(int)ACC_PROFIT + "$, POTENTIAL_LOSS:" + (string)(int)GLOBAL_POTENTIAL_LOSS + "$", false);
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_hedging(string symbol)
  {
   global_bot_count_hedg_buy = 0;
   global_bot_count_hedg_sel = 0;
   double total_vol_buy = 0, total_vol_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            if(OrderType() == OP_BUY)
              {
               total_vol_buy += OrderLots();
               if(is_same_symbol(OrderComment(), MASK_HEDG))
                  global_bot_count_hedg_buy += 1;
              }

            if(OrderType() == OP_SELL)
              {
               total_vol_sel += OrderLots();
               if(is_same_symbol(OrderComment(), MASK_HEDG))
                  global_bot_count_hedg_sel += 1;
              }
           }

   if(MathAbs(total_vol_buy - total_vol_sel) > 0.01)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int OP_TYPE = total_vol_buy > total_vol_sel ? OP_SELL : OP_BUY;
      int count = (int)(total_vol_buy > total_vol_sel ? global_bot_count_hedg_sel : global_bot_count_hedg_buy) + 1;
      string TREND_TYPE = total_vol_buy > total_vol_sel ? TREND_SEL : TREND_BUY;

      double hedg_volume = MathAbs(total_vol_buy - total_vol_sel) - 0.01;
      string hedg_comment = create_comment(MASK_HEDG, TREND_TYPE, count);
      bool hedging_ok = Open_Position(symbol, OP_TYPE, hedg_volume, 0.0, 0.0, hedg_comment);
      if(hedging_ok)
        {
         hedg_comment = create_comment(MASK_HEDG, TREND_TYPE, 0);
         hedging_ok = Open_Position(symbol, OP_TYPE, 0.01, 0.0, 0.0, hedg_comment);

         SendTelegramMessage(symbol, MASK_HEDG, "hedging_ok: " + symbol + "    " + (string)hedg_volume + "lot.", false);
        }
     }
  }
//+------------------------------------------------------------------+
//| BtnDeHedging                                                     |
//+------------------------------------------------------------------+
void De_Hedging(bool de_hg_now)
  {
   if(de_hg_now == false)
     {
      // Nếu không phải tự ấn button thì một tiếng giải Hedging 1 lần:
      MqlDateTime time_struct;
      TimeToStruct(TimeCurrent(), time_struct);
      int cur_hedging_time = time_struct.hour;

      int de_hedging_time = -1;
      if(GlobalVariableCheck("de_hedging_time"))
         de_hedging_time = (int)GlobalVariableGet("de_hedging_time");
      GlobalVariableSet("de_hedging_time", cur_hedging_time);

      if(de_hedging_time == cur_hedging_time)
         return;

      //Alert(get_vntime() + " (Auto_De_Hedging_H1)  pre:" + (string)de_hedging_time + "    cur:" + (string)cur_hedging_time);
     }

   if(global_bot_count_hedg_buy+global_bot_count_hedg_sel > 0)
     {
      if(global_bot_count_hedg_buy > 0 && arrHeiken_h4[0].trend_heiken == TREND_SEL && arrHeiken_h1[0].trend_heiken == TREND_SEL)
        {
         for(int i=1; i <= global_bot_count_hedg_buy; i++)
           {
            string hedg_comment = create_comment(MASK_HEDG, TREND_BUY, i);
            bool ok = ModifyTp_ToEntry(Symbol(), 1, hedg_comment);
            if(ok)
               Alert("Auto_De_Hedging " + Symbol() + "    " + (string) TimeCurrent() + "    " + hedg_comment);
           }
        }

      if(global_bot_count_hedg_sel > 0 && arrHeiken_h4[0].trend_heiken == TREND_BUY && arrHeiken_h1[0].trend_heiken == TREND_BUY)
        {
         for(int i=1; i <= global_bot_count_hedg_sel; i++)
           {
            string hedg_comment = create_comment(MASK_HEDG, TREND_SEL, i);
            bool ok = ModifyTp_ToEntry(Symbol(), 1, hedg_comment);
            if(ok)
               Alert("Auto_De_Hedging " + Symbol() + "    " + (string) TimeCurrent() + "    " + hedg_comment);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol, int OP_TYPE, double volume, double sl, double tp, string comment, double priceLimit=0)
  {
   int nextticket= 0, demm = 1;
   while(nextticket<=0 && demm < 12)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int slippage = (int)MathAbs(ask-bid);
      double price = NormalizeDouble((bid + ask)/2, Digits);

      if(OP_TYPE == OP_BUY)
         price = ask;
      if(OP_TYPE == OP_SELL)
         price = bid;
      if((OP_TYPE == OP_BUYLIMIT || OP_TYPE == OP_SELLLIMIT) && priceLimit > 0)
         price = priceLimit;

      nextticket = OrderSend(symbol, OP_TYPE, volume, price, slippage, sl, tp, comment, 0, 0, clrBlue);
      if(nextticket > 0)
         return true;

      demm++;
      Sleep(100); //milliseconds
     }

   return false;
  }
//+------------------------------------------------------------------+
//|BtnSolveNegative                                                  |
//+------------------------------------------------------------------+
void Solve_Negative(string symbol, bool trade_now)
  {
   if(is_main_control_screen() == false)
      return;

   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

   string TREND = (ask+bid)/2 < CENTER_OF_3_DAYS ? TREND_BUY : TREND_SEL;
   double draw_price = iClose(symbol, PERIOD_M5, 1);
   double tp_price = TREND == TREND_BUY ? ask + FIXED_SL_AMP : bid - FIXED_SL_AMP;

   double vol_balance = calc_volume_by_amp(symbol, FIXED_SL_AMP, MathAbs(ACC_PROFIT));

   lableBtnPaddingTrade = "(" + (string) global_bot_count_exit_order + ") "
                          + " " + AppendSpaces(format_double_to_string(vol_balance, 2), 4, false)
                          + "/" + (string)(int)FIXED_SL_AMP
                          + "/"+ format_double_to_string((int)ACC_PROFIT, 1)+"$"
                          + "(SL"+ format_double_to_string(GLOBAL_POTENTIAL_LOSS/BALANCE * 100, 1) + "%)";

   color clrText = clrLightGray;
     {
      bool allow_notify_padding_trade = (INIT_TREND_TODAY == TREND_BUY && TREND == TREND_BUY && global_min_exit_price - FIXED_SL_AMP > bid) ||
                                        (INIT_TREND_TODAY == TREND_BUY && TREND == TREND_SEL && global_max_exit_price + FIXED_SL_AMP < ask);
      if(allow_notify_padding_trade)
        {
         clrText = clrFireBrick;

         ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0,BtnPaddingTrade, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_COLOR, clrText);

         ObjectSetInteger(0,"tp_padding_trade", OBJPROP_FONTSIZE, 9);
         ObjectSetString(0,"tp_padding_trade", OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0,"tp_padding_trade", OBJPROP_COLOR, clrText);
        }
     }

   if(global_bot_count_exit_order == 0)
      clrText = clrLightGray;

   if(trade_now && global_bot_count_exit_order == 0)
     {
      string msg = " " + symbol + " " + lableBtnPaddingTrade + "?\n";
      if(MathAbs(global_bot_vol_buy - global_bot_vol_sel) > INIT_VOLUME)
        {
         vol_balance = NormalizeDouble(MathAbs(global_bot_vol_buy - global_bot_vol_sel), 2);
         double potentialProfit = calcPotentialTradeProfit(symbol, OP_BUY, ask, ask + FIXED_SL_AMP, vol_balance);
         msg = MASK_HEDG + " " + symbol + " " + (string) vol_balance + " solve: " + format_double_to_string(potentialProfit, 1) + "$?\n";
        }
      vol_balance =0.01;

      string all_trend = getTrendFiltering(Symbol());

      msg += " MACD(H4): " + INIT_TREND_TODAY + " (B-S): "+(string)NormalizeDouble(global_bot_vol_buy - global_bot_vol_sel, 2)+ " lot.\n";
      msg += all_trend + "\n\n";
      msg += "    (YES) BUY "+(string)vol_balance+" lot "+(INIT_TREND_TODAY == TREND_BUY ? "= MACD(H4)" : "")+"\n";
      msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, TREND_BUY) + "\n";
      msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, TREND_BUY) + "\n";
      msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, TREND_BUY) + "\n";
      msg += "    (NO) SELL "+(string)vol_balance+" lot "+(INIT_TREND_TODAY == TREND_SEL ? "= MACD(H4)" : "")+"\n";
      msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, TREND_SEL) + "\n";
      msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, TREND_SEL) + "\n";
      msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, TREND_SEL) + "\n";

      msg += "    (Cancel): Exit";

      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);

      int OP_TYPE = -1;
      string selected_trend = "";

      if(result == IDYES)
        {
         if(is_same_symbol(all_trend, TREND_BUY) == false)
           {
            Alert("(NOT_ALLOW_BUY) ALL_TREND :" + all_trend);
            return;
           }

         OP_TYPE = OP_BUY;
         selected_trend = TREND_BUY;
         tp_price = ask + FIXED_SL_AMP;
        }
      if(result == IDNO)
        {
         if(is_same_symbol(all_trend, TREND_SEL) == false)
           {
            Alert("(NOT_ALLOW_SELL) ALL_TREND :" + all_trend);
            return;
           }

         OP_TYPE = OP_SELL;
         selected_trend = TREND_SEL;
         tp_price = bid - FIXED_SL_AMP;
        }

      if(OP_TYPE != -1 && selected_trend != "")
        {
         string comment = MASK_EXIT + create_comment(create_trader_name(), selected_trend, global_bot_count_exit_order+1);

         bool exit_ok = Open_Position(symbol, OP_TYPE, vol_balance, 0.0, 0.0, comment);
         if(exit_ok)
            printf("exit_ok");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_main_control_screen()
  {
   int screen_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   bool draw_common_btn = screen_width < (140 + 215 + 375) ? false : true; // 1646, 1216 > 800
   return draw_common_btn;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Add_Flashing_Color()
  {
   string symbol = Symbol();

   MqlDateTime vietnamDateTime;
   TimeToStruct(TimeCurrent(), vietnamDateTime);
   int cur_sec = vietnamDateTime.sec;
   color flashColor = MathMod(cur_sec, 2) == 1 ? clrBlue : clrFireBrick;
   color clrBackground = MathMod(cur_sec, 2) == 1 ? clrLightGreen : clrLightGray;

   if(is_same_symbol(lable_profit_buy, "Wait"))
      ObjectSetInteger(0, BtnCloseProfitBuy, OBJPROP_COLOR, flashColor);
   if(is_same_symbol(lable_profit_sel, "Wait"))
      ObjectSetInteger(0, BtnCloseProfitSel, OBJPROP_COLOR, flashColor);

   if(trend_by_seq102050_h4 != "")
      ObjectSetInteger(0, "Seq.H4", OBJPROP_BGCOLOR, clrBackground);
   if(trend_by_seq102050_h1 != "")
      ObjectSetInteger(0, "Seq.H1", OBJPROP_BGCOLOR, clrBackground);


   if(arrHeiken_d1[0].count_ma10 <= 1)
      ObjectSetInteger(0, "Ma10D1", OBJPROP_BGCOLOR, clrBackground);
   if(arrHeiken_h4[0].count_ma10 <= 2)
      ObjectSetInteger(0, "Ma10H4", OBJPROP_BGCOLOR, clrBackground);
   if(arrHeiken_h1[0].count_ma10 <= 3)
      ObjectSetInteger(0, "Ma10H1", OBJPROP_BGCOLOR, clrBackground);


   if(arrHeiken_d1[0].count_heiken <= 1)
      ObjectSetInteger(0, "HeiD1[0]", OBJPROP_BGCOLOR, clrBackground);
   if(arrHeiken_h4[0].count_heiken <= 2)
      ObjectSetInteger(0, "HeiH4[0]", OBJPROP_BGCOLOR, clrBackground);
   if(arrHeiken_h1[0].count_heiken <= 3)
      ObjectSetInteger(0, "HeiH1[0]", OBJPROP_BGCOLOR, clrBackground);

   if(trend_macd_note_h4 != "")
      ObjectSetInteger(0, "Mac.Zer.H4", OBJPROP_BGCOLOR, clrBackground);
   if(trend_macd_note_h1 != "")
      ObjectSetInteger(0, "Mac.Zer.H1", OBJPROP_BGCOLOR, clrBackground);
   if(trend_macd_note_cu != "")
      ObjectSetInteger(0, "Mac.Zer.CU", OBJPROP_BGCOLOR, clrBackground);

   if(is_same_symbol(trend_by_seq102050_15, trend_by_ma10_d1))
      ObjectSetInteger(0, BtnCond15Seq125, OBJPROP_BGCOLOR, clrBackground);
   if(is_same_symbol(trend_by_seq102050_05, trend_by_ma10_d1))
      ObjectSetInteger(0, BtnCond05Seq125, OBJPROP_BGCOLOR, clrBackground);
   if(is_same_symbol(trend_by_seq102050_01, trend_by_ma10_d1))
      ObjectSetInteger(0, BtnCond01Seq125, OBJPROP_BGCOLOR, clrBackground);

   if(is_same_symbol(lableBtnPaddingTrade, "Wait_SL"))
      ObjectSetInteger(0, BtnSolveNegative, OBJPROP_BGCOLOR, clrBackground);

   if(trend_by_ma10_d1 == trend_by_ma10_h1 && trend_by_ma10_d1 != "")
     {
      color clrColor = trend_by_ma10_d1 == TREND_BUY ? clrAliceBlue : trend_by_ma10_d1 == TREND_SEL ? C'235,235,235' : clrNONE;
      color clrFlash = MathMod(cur_sec, 2) == 1 ? clrColor : clrNONE;
      string candle_name = "hei_d_" + appendZero100(0);

      if(trend_by_ma10_d1 == trend_today_by_time)
         ObjectSetInteger(0, candle_name, OBJPROP_COLOR, clrFlash);
     }

   for(int index = 0; index < ArraySize(globalArrFlashSymbols); index++)
     {
      string btnName = globalArrFlashSymbols[index];
      ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, clrBackground);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons_Trend(string symbol)
  {
//int x_btn, y;
//if(is_main_control_screen() && ChartTimePriceToXY(0, 0, iTime(symbol, PERIOD_CURRENT, 0), Bid, x_btn, y))
     {
      int x_max = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS)) - 70;
      int y_start = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 25;

      int y_row_0 = y_start - 20*6 - 5*1;
      int y_row_1 = y_start - 20*5 + 5*0;
      int y_row_2 = y_start - 20*4 + 5*1;
      int y_row_3 = y_start - 20*3 + 5*2;
      int y_row_4 = y_start - 20*2 + 5*3;
      int y_row_5 = y_start - 20*1 + 5*4;

      string lblStocW1 = getShortStoc(trend_over_bs_by_stoc_w1);
      string lblStocD1 = getShortStoc(trend_over_bs_by_stoc_d1);
      string lblStocH4 = getShortStoc(trend_over_bs_by_stoc_h4);
      string lblStocH1 = getShortStoc(trend_over_bs_by_stoc_h1);

      createButton("Ma10",     "Ma10", x_max - 65*3 + 18, y_row_0, 45, 20, clrBlack, clrWhite, 7);
      createButton("Ma10D1",   "D1 " + getShortName(arrHeiken_d1[0].trend_by_ma10) + ":" + (string)arrHeiken_d1[0].count_ma10,  x_max - 65*2, y_row_0, 63, 20, trend_by_ma10_d1 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
      createButton("Ma10H4",   "H4 " + getShortName(arrHeiken_h4[0].trend_by_ma10) + ":" + (string)arrHeiken_h4[0].count_ma10,  x_max - 65*1, y_row_0, 63, 20, trend_by_ma10_h4 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
      createButton("Ma10H1",   "H1 " + getShortName(arrHeiken_h1[0].trend_by_ma10) + ":" + (string)arrHeiken_h1[0].count_ma10,  x_max - 65*0, y_row_0, 63, 20, trend_by_ma10_h1 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
      ObjectSetString(0, "Ma10D1", OBJPROP_FONT, "Arial Bold");

      createButton("HeiW1[0]", "W1 " + getShortName(arrHeiken_w1[0].trend_heiken) + ":" + (string)arrHeiken_w1[0].count_heiken, x_max - 65*3, y_row_1, 63, 20, arrHeiken_w1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
      createButton("HeiD1[0]", "D1 " + getShortName(arrHeiken_d1[0].trend_heiken) + ":" + (string)arrHeiken_d1[0].count_heiken, x_max - 65*2, y_row_1, 63, 20, arrHeiken_d1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
      createButton("HeiH4[0]", "H4 " + getShortName(arrHeiken_h4[0].trend_heiken) + ":" + (string)arrHeiken_h4[0].count_heiken, x_max - 65*1, y_row_1, 63, 20, arrHeiken_h4[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
      createButton("HeiH1[0]", "H1 " + getShortName(arrHeiken_h1[0].trend_heiken) + ":" + (string)arrHeiken_h1[0].count_heiken, x_max - 65*0, y_row_1, 63, 20, arrHeiken_h1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);

      createButton("Seq.H4",     createLable("SeqH4", trend_by_seq102050_h4),         x_max - 65*4, y_row_2, 63, 20, getColorByTrend(trend_by_seq102050_h4,   clrBlack), clrWhite,     7);
      createButton("Mac.Zer.H4", createLable("ZeoH4", trend_mac_vs_zero_h4),          x_max - 65*3, y_row_2, 63, 20, getColorByTrend(trend_mac_vs_zero_h4,    clrBlack), clrGainsboro, 7);
      createButton("Mac.Sig.H4", createLable("MacH4", trend_mac_vs_signal_h4),        x_max - 65*2, y_row_2, 63, 20, getColorByTrend(trend_mac_vs_signal_h4,  clrBlack), clrGainsboro, 7);
      createButton("Vec.Mac.H4", createLable("HisH4", trend_vector_macd_h4),          x_max - 65*1, y_row_2, 63, 20, getColorByTrend(trend_vector_macd_h4,    clrBlack), clrGainsboro, 7);
      createButton("Vec.Sig.H4", createLable("SigH4", trend_vector_signal_h4),        x_max - 65*0, y_row_2, 63, 20, getColorByTrend(trend_vector_signal_h4,  clrBlack), clrGainsboro, 7);

      createButton("Seq.H1",     createLable("SeqH1", trend_by_seq102050_h1),         x_max - 65*4, y_row_3, 63, 20, getColorByTrend(trend_by_seq102050_h1,   clrBlack), clrWhite,     7);
      createButton("Mac.Zer.H1", createLable("ZeoH1", trend_mac_vs_zero_h1),          x_max - 65*3, y_row_3, 63, 20, getColorByTrend(trend_mac_vs_zero_h1,    clrBlack), clrGainsboro, 7);
      createButton("Mac.Sig.H1", createLable("MacH1", trend_mac_vs_signal_h1),        x_max - 65*2, y_row_3, 63, 20, getColorByTrend(trend_mac_vs_signal_h1,  clrBlack), clrGainsboro, 7);
      createButton("Vec.Mac.H1", createLable("HisH1", trend_vector_macd_h1),          x_max - 65*1, y_row_3, 63, 20, getColorByTrend(trend_vector_macd_h1,    clrBlack), clrGainsboro, 7);
      createButton("Vec.Sig.H1", createLable("SigH1", trend_vector_signal_h1),        x_max - 65*0, y_row_3, 63, 20, getColorByTrend(trend_vector_signal_h1,  clrBlack), clrGainsboro, 7);

      if(Period() != PERIOD_H4 && Period() != PERIOD_H1)
        {
         string tf = get_current_timeframe();
         createButton("Mac.Zer.CU", createLable("Zero" + tf, trend_mac_vs_zero_cu),   x_max - 65*3, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_zero_cu,   clrBlack), clrGainsboro, 7);
         createButton("Mac.Sig.CU", createLable("Mac." + tf, trend_mac_vs_signal_cu), x_max - 65*2, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_signal_cu,  clrBlack), clrGainsboro, 7);
         createButton("Vec.Mac.CU", createLable("His." + tf, trend_vector_macd_cu),   x_max - 65*1, y_row_4, 63, 20, getColorByTrend(trend_vector_macd_cu,    clrBlack), clrGainsboro, 7);
         createButton("Vec.Sig.CU", createLable("Sig." + tf, trend_vector_signal_cu), x_max - 65*0, y_row_4, 63, 20, getColorByTrend(trend_vector_signal_cu,  clrBlack), clrGainsboro, 7);
        }
      else
        {
         ObjectDelete(0, "Mac.Zer.CU");
         ObjectDelete(0, "Mac.Sig.CU");
         ObjectDelete(0, "Vec.Mac.CU");
         ObjectDelete(0, "Vec.Sig.CU");
        }

      createButton("Stoc",  "Stoc",                        x_max - 65*4 + 23, y_row_5, 40, 20, clrBlack, clrWhite, 7);
      createButton("TocW1", createLable2("W1", lblStocW1), x_max - 65*3, y_row_5, 63, 20, is_same_symbol(lblStocW1, "20") ? clrBlue: is_same_symbol(lblStocW1, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
      createButton("TocD1", createLable2("D1", lblStocD1), x_max - 65*2, y_row_5, 63, 20, is_same_symbol(lblStocD1, "20") ? clrBlue: is_same_symbol(lblStocD1, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
      createButton("TocH4", createLable2("H4", lblStocH4), x_max - 65*1, y_row_5, 63, 20, is_same_symbol(lblStocH4, "20") ? clrBlue: is_same_symbol(lblStocH4, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
      createButton("TocH1", createLable2("H1", lblStocH1), x_max - 65*0, y_row_5, 63, 20, is_same_symbol(lblStocH1, "20") ? clrBlue: is_same_symbol(lblStocH1, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons()
  {
   return;
   string symbol = Symbol();
   if(is_same_symbol(symbol, "XAU") == false)
      return;

   loadAutoTrade();

   bool draw_common_btn = is_main_control_screen();

   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double cur_price = NormalizeDouble((bid+ask)/2, Digits);

   color clrActiveBtn = clrLightGreen;
   int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 25;
   int y_row_1 = y_ref_btn - 50;
   int y_row_2 = y_ref_btn - 25;
   int y_row_3 = y_ref_btn - 00;


   bool is_exit_trade = is_play_for_exit_trade();
   string mask_exit_trade = is_exit_trade ? " ^Ex^" : "";

   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   bool is_10_percent_loss = (BALANCE*0.1 + ACC_PROFIT < 0);

   color clrHasProfit = is_same_symbol(lable_profit_positive_orders, "B0") &&
                        is_same_symbol(lable_profit_positive_orders, "S0")
                        ? clrLightGray : clrActiveBtn;

   if(draw_common_btn)
      createButton(BtnClosePositiveOrders, lable_profit_positive_orders, 10, y_row_1, 140, BUTTON_HEIGH, clrBlack, clrHasProfit, 7);

   int widthBtnProfit = 215;
   int widthBtnAutoTrade = 140;
   if(draw_common_btn == false)
     {
      widthBtnProfit = 185;
      widthBtnAutoTrade = 120;
     }

   color clrNewCycleColorBuy = IS_CONTINUE_TRADING_CYCLE_BUY ? clrActiveBtn : clrLightGray;
   color clrNewCycleColorSel = IS_CONTINUE_TRADING_CYCLE_SEL ? clrActiveBtn : clrLightGray;

   string lableBuy = "DC1% BUY " + (string)(global_bot_count_manual_buy > 0 ? format_double_to_string(global_min_entry_manual_buy-AMP_DC, Digits-1) : "");
   string lableSel = "DC1% SEL " + (string)(global_bot_count_manual_sel > 0 ? format_double_to_string(global_max_entry_manual_sel+AMP_DC, Digits-1) : "");

   bool d1_allow_buy = (trend_by_ma10_d1 == TREND_BUY) && (trend_by_ma10_h1 == TREND_BUY) && (arrHeiken_h4[0].trend_heiken == TREND_BUY);
   bool d1_allow_sel = (trend_by_ma10_d1 == TREND_SEL) && (trend_by_ma10_h1 == TREND_SEL) && (arrHeiken_h4[0].trend_heiken == TREND_SEL);

   if(d1_allow_buy)
      createButton(BtnNewCycleBuy, lableBuy, 10, y_row_2, widthBtnAutoTrade, BUTTON_HEIGH, clrBlack, clrNewCycleColorBuy, 7);
   else
      ObjectDelete(0, BtnNewCycleBuy);

   if(d1_allow_sel)
      createButton(BtnNewCycleSel, lableSel, 10, y_row_3, widthBtnAutoTrade, BUTTON_HEIGH, clrBlack, clrNewCycleColorSel, 7);
   else
      ObjectDelete(0, BtnNewCycleSel);

   if(draw_common_btn)
      createButton(BtnSolveNegative, mask_exit_trade + lableBtnPaddingTrade, 155, y_row_1, widthBtnProfit, BUTTON_HEIGH, clrBlack, global_bot_count_exit_order > 0 ? clrActiveBtn : clrLightGray, 7);

   color lblColorProfitBuy = StringFind(lable_profit_buy, "-") > 0 ? clrFireBrick : clrBlue;
   color lblColorProfitSel = StringFind(lable_profit_sel, "-") > 0 ? clrFireBrick : clrBlue;

   string wait_trend_h4 = "";

   if(draw_common_btn)
     {
      if(d1_allow_buy || global_tcount_buy>0)
         createButton(BtnCloseProfitBuy, lable_profit_buy, 155, y_row_2, widthBtnProfit, BUTTON_HEIGH, lblColorProfitBuy, lable_profit_buy == "" ? (wait_trend_h4 != "") ? clrBlue : clrLightGray : clrLightSkyBlue, 7);
      else
         ObjectDelete(0, BtnCloseProfitBuy);

      if(d1_allow_sel || global_tcount_sel>0)
         createButton(BtnCloseProfitSel, lable_profit_sel, 155, y_row_3, widthBtnProfit, BUTTON_HEIGH, lblColorProfitSel, lable_profit_sel == "" ? (wait_trend_h4 != "") ? clrBlue : clrLightGray : clrSeashell, 7);
      else
         ObjectDelete(0, BtnCloseProfitSel);

      double close_d1 = iClose(symbol, PERIOD_D1, 1);

      double close_heiken_h4_0 = arrHeiken_h4[0].close;
      double close_heiken_h1_0 = arrHeiken_h1[0].close;

      double risk_10percent = INIT_EQUITY*0.1;
      double volume = calc_volume_by_amp(symbol, FIXED_SL_AMP, risk_10percent);

      bool notify_trade = is_reacts_with_close_d1(symbol);

      string lblTrade10percent =  "("+(string)(global_10percent_count_buy + global_10percent_count_sel) +")10% "
                                  + " (" + (string)(volume)
                                  + "/" + format_double_to_string(FIXED_SL_AMP, Digits - 1)
                                  + "/" + (string)((int) risk_10percent) + "$)";
      //-------------------------------------------------------------------------------------
      string lblCondH4Price          = "";
      string lblCondH4Stoch8020      = "";
      string lblCondH1Heiken         = "";
      string lblCondH1Stoch8020      = "";
      string lblCond15Seq125         = "";
      string lblCond15Stoch8020      = "";
      string lblCond05Seq125         = "";
      string lblCond05Stoch8020      = "";
      string lblCond01Seq125         = "";
      string lblCond01Stoch8020      = "";

      string main_trading_trend = "";
      bool allow_buy_now = false;
      if(trend_by_ma10_d1 == TREND_BUY)
        {
         allow_buy_now = true;
         main_trading_trend = TREND_BUY;

         if(is_same_symbol(allow_trade_now_by_price_closeH4_and_heikenM1(symbol, TREND_BUY), TREND_BUY))
            lblCondH4Price = "ok";
         else
            if(CondH4Price)
               allow_buy_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_h4, TREND_BUY))
            lblCondH4Stoch8020 = "20 ok";
         else
            if(CondH4Stoch8020)
               allow_buy_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_h1, TREND_BUY))
            lblCondH1Stoch8020 = "20 ok";
         else
            if(CondH1Stoch8020)
               allow_buy_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_15, TREND_BUY))
            lblCond15Stoch8020 = "20 ok";
         else
            if(Cond15Stoch8020)
               allow_buy_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_05, TREND_BUY))
            lblCond05Stoch8020 = "20 ok";
         else
            if(Cond05Stoch8020)
               allow_buy_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_01, TREND_BUY))
            lblCond01Stoch8020 = "20 ok";
         else
            if(Cond01Stoch8020)
               allow_buy_now = false;

         if(arrHeiken_h1[0].trend_heiken == TREND_BUY)
            lblCondH1Heiken = "ok";
         else
            if(CondH1Heiken)
               allow_buy_now = false;

         if(trend_by_seq102050_15 == TREND_BUY)
            lblCond15Seq125 = "ok";
         else
            if(Cond15Seq125)
               allow_buy_now = false;

         if(trend_by_seq102050_05 == TREND_BUY)
            lblCond05Seq125 = "ok";
         else
            if(Cond05Seq125)
               allow_buy_now = false;

         if(trend_by_seq102050_01 == TREND_BUY)
            lblCond01Seq125 = "ok";
         else
            if(Cond01Seq125)
               allow_buy_now = false;
        }
      //-------------------------------------------------------------------------------------
      bool allow_sel_now = false;
      if(trend_by_ma10_d1 == TREND_SEL)
        {
         allow_sel_now = true;
         main_trading_trend = TREND_SEL;

         if(is_same_symbol(allow_trade_now_by_price_closeH4_and_heikenM1(symbol, TREND_SEL), TREND_SEL))
            lblCondH4Price = "ok";
         else
            if(CondH4Price)
               allow_sel_now = false;


         if(is_same_symbol(trend_over_bs_by_stoc_h4, TREND_SEL))
            lblCondH4Stoch8020 = "80 ok";
         else
            if(CondH4Stoch8020)
               allow_sel_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_h1, TREND_SEL))
            lblCondH1Stoch8020 = "80 ok";
         else
            if(CondH1Stoch8020)
               allow_sel_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_15, TREND_SEL))
            lblCond15Stoch8020 = "80 ok";
         else
            if(Cond15Stoch8020)
               allow_sel_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_05, TREND_SEL))
            lblCond05Stoch8020 = "80 ok";
         else
            if(Cond05Stoch8020)
               allow_sel_now = false;

         if(is_same_symbol(trend_over_bs_by_stoc_01, TREND_SEL))
            lblCond01Stoch8020 = "80 ok";
         else
            if(Cond01Stoch8020)
               allow_sel_now = false;

         if(arrHeiken_h1[0].trend_heiken == TREND_SEL)
            lblCondH1Heiken = "ok";
         else
            if(CondH1Heiken)
               allow_sel_now = false;

         if(trend_by_seq102050_15 == TREND_SEL)
            lblCond15Seq125 = "ok";
         else
            if(Cond15Seq125)
               allow_sel_now = false;

         if(trend_by_seq102050_05 == TREND_SEL)
            lblCond05Seq125 = "ok";
         else
            if(Cond05Seq125)
               allow_sel_now = false;

         if(trend_by_seq102050_01 == TREND_SEL)
            lblCond01Seq125 = "ok";
         else
            if(Cond01Seq125)
               allow_sel_now = false;
        }
      //-------------------------------------------------------------------------------------
      if(IS_WAITTING_10PER_BUY && allow_buy_now)
        {
         if((global_10percent_count_buy == 0) || (global_10percent_min_open_price > 0 && global_10percent_min_open_price - NEXT_10PER_AMP > cur_price))
           {
            double min_buy_price = get_min_buy_price(symbol);

            if((min_buy_price == MAXIMUM_DOUBLE) || (min_buy_price - NEXT_10PER_AMP > bid))
              {
               double volume_buy = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, risk_10percent);
               string comment = create_comment(MASK_10PER, TREND_BUY, 1);
               double tp_price_buy = get_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);

               tp_price_buy = 0;
               bool exit_ok = Open_Position(Symbol(), OP_BUY, volume_buy, 0.0, tp_price_buy, comment);
               if(exit_ok)
                 {
                  IS_WAITTING_10PER_BUY = false;
                  SendTelegramMessage(symbol, TREND_BUY, "(ALERT_BUY)" + MASK_10PER + Symbol() + " " + comment + lblTrade10percent, false);
                 }
              }
           }
        }

      if(IS_WAITTING_10PER_SEL && allow_sel_now)
        {
         if((global_10percent_count_sel == 0) || (global_10percent_max_open_price > 0 && global_10percent_max_open_price + NEXT_10PER_AMP < cur_price))
           {
            double max_sel_price = get_max_sel_price(symbol);

            if((max_sel_price == 0) || (max_sel_price + NEXT_10PER_AMP < bid))
              {
               double volume_sel = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, risk_10percent);
               string comment = create_comment(MASK_10PER, TREND_SEL, 1);
               double tp_price_sel = get_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
               tp_price_sel = 0;

               bool exit_ok = Open_Position(Symbol(), OP_SELL, volume_sel, 0.0, tp_price_sel, comment);
               if(exit_ok)
                 {
                  IS_WAITTING_10PER_SEL = false;
                  Alert(MASK_10PER + Symbol() + " " + comment);

                  SendTelegramMessage(symbol, TREND_BUY, "(ALERT_SEL)" + MASK_10PER + Symbol() + " " + comment + lblTrade10percent, false);
                 }
              }
           }
        }
      //-------------------------------------------------------------------------------------
      int start_y_cond = 175;

      createButton(BtnResetCond10per, "(" + main_trading_trend + ") Reset Cond 10%",                            5, start_y_cond - 2,    195, 20, clrBlack, clrLightGray, 7);

      createButton(BtnCondH4Stoch8020, "(h4)Sto " + AppendSpaces(lblCondH4Stoch8020, 3, false),                 5, start_y_cond + 1*20,  90, 18, clrBlack, CondH4Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCondH1Stoch8020, "(h1)Sto " + AppendSpaces(lblCondH1Stoch8020, 3, false),                 5, start_y_cond + 2*20,  90, 18, clrBlack, CondH1Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond15Stoch8020, "(15)Sto " + AppendSpaces(lblCond15Stoch8020, 3, false),                 5, start_y_cond + 3*20,  90, 18, clrBlack, Cond15Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond05Stoch8020, "(05)Sto " + AppendSpaces(lblCond05Stoch8020, 3, false),                 5, start_y_cond + 4*20,  90, 18, clrBlack, Cond05Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond01Stoch8020, "(01)Sto " + AppendSpaces(lblCond01Stoch8020, 3, false),                 5, start_y_cond + 5*20,  90, 18, clrBlack, Cond01Stoch8020 ? clrActiveBtn : clrLightGray, 7);

      createButton(BtnCondH4Price, format_double_to_string(INIT_START_PRICE, Digits-1) + " " + lblCondH4Price,100, start_y_cond + 1*20, 100, 18, clrBlack, CondH4Price     ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCondH1Heiken, "(h1)Hei " + arrHeiken_h1[0].trend_heiken + " " + lblCondH1Heiken,        100, start_y_cond + 2*20, 100, 18, clrBlack, CondH1Heiken    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond15Seq125, "(15)" + createLable2("Seq", trend_by_seq102050_15) + " " + lblCond15Seq125,               100, start_y_cond + 3*20, 100, 18, clrBlack, Cond15Seq125    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond05Seq125, "(05)" + createLable2("Seq", trend_by_seq102050_05) + " " + lblCond05Seq125,               100, start_y_cond + 4*20, 100, 18, clrBlack, Cond05Seq125    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond01Seq125, "(01)" + createLable2("Seq", trend_by_seq102050_01) + " " + lblCond01Seq125,               100, start_y_cond + 5*20, 100, 18, clrBlack, Cond01Seq125    ? clrActiveBtn : clrLightGray, 7);
      //-------------------------------------------------------------------------------------
      //-------------------------------------------------------------------------------------
      createButton(BtnTradeWithStopLoss,lblTrade10percent, 375, y_row_1, 210, BUTTON_HEIGH, clrBlack,
                   (global_10percent_count_buy + global_10percent_count_sel) > 0 ? clrLightSkyBlue : (notify_trade ? clrYellowGreen : clrLightGray), 7);


      double volume_1percent = calc_volume_by_amp(symbol, FIXED_SL_AMP, INIT_EQUITY*0.01);
      if(d1_allow_buy)
        {
         createButton(BtnWaitBuy10Per, "("+(string) global_10percent_count_buy+")" + " WB10%", 375, y_row_2, 100, BUTTON_HEIGH, clrBlack, IS_WAITTING_10PER_BUY ? clrActiveBtn : global_10percent_count_buy > 0 ? clrLightSkyBlue : clrLightGray);
         createButton(BtnBuyNow1Per,   "("+(string) global_bot_count_manual_buy+") B1% " + format_double_to_string(volume_1percent, 2), 480, y_row_2, 105, BUTTON_HEIGH, clrBlack, global_bot_count_manual_buy == 0 ? clrLightGray : clrLightSkyBlue);
        }
      else
        {
         ObjectDelete(0, BtnWaitBuy10Per);
         ObjectDelete(0, BtnBuyNow1Per);
        }

      if(d1_allow_sel)
        {
         createButton(BtnWaitSel10Per, "("+(string) global_10percent_count_sel+")" + " WS10%", 375, y_row_3, 100, BUTTON_HEIGH, clrBlack, IS_WAITTING_10PER_SEL ? clrActiveBtn : global_10percent_count_sel > 0 ? clrSeashell     : clrLightGray);
         createButton(BtnSelNow1Per, "("+(string) global_bot_count_manual_sel+") S1% " + format_double_to_string(volume_1percent, 2), 480, y_row_3, 105, BUTTON_HEIGH, clrBlack, global_bot_count_manual_sel == 0 ? clrLightGray : clrSeashell);
        }
      else
        {
         ObjectDelete(0, BtnWaitSel10Per);
         ObjectDelete(0, BtnSelNow1Per);
        }

      if(global_bot_count_manual_buy >= 20)
        {
         ObjectSetString(0, BtnBuyNow1Per, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, BtnBuyNow1Per, OBJPROP_COLOR, clrFireBrick);
        }
      if(global_bot_count_manual_sel >= 20)
        {
         ObjectSetString(0, BtnSelNow1Per, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, BtnSelNow1Per, OBJPROP_COLOR, clrFireBrick);
        }

      if(d1_allow_buy)
         createButton(BtnHedgBuy2Sel, "(" + (string) global_bot_count_hedg_buy + ") hg B", 590, y_row_2, 70, BUTTON_HEIGH, clrBlack, (global_bot_count_hedg_buy == 0) ? clrLightGray : clrLightSkyBlue);
      else
         ObjectDelete(0, BtnHedgBuy2Sel);

      if(d1_allow_sel)
         createButton(BtnHedgSel2Buy, "(" + (string) global_bot_count_hedg_sel + ") hg S", 590, y_row_3, 70, BUTTON_HEIGH, clrBlack, (global_bot_count_hedg_sel == 0) ? clrLightGray : clrSeashell);
      else
         ObjectDelete(0, BtnHedgSel2Buy);

      int sizeBtnDeHedging = 7;
      string lblBtnDeHedging = "DeHg";
      color clrBtnDeHedging = clrLightGray;
      if(global_bot_count_hedg_buy > 0 && arrHeiken_h4[0].trend_heiken == TREND_SEL && arrHeiken_h1[0].trend_heiken == TREND_SEL)
        {
         De_Hedging(false);

         sizeBtnDeHedging = 6;
         clrBtnDeHedging = clrActiveBtn;
         lblBtnDeHedging += " " + (string) global_bot_count_hedg_buy + "B";
        }

      if(global_bot_count_hedg_sel > 0 && arrHeiken_h4[0].trend_heiken == TREND_BUY && arrHeiken_h1[0].trend_heiken == TREND_BUY)
        {
         De_Hedging(false);

         sizeBtnDeHedging = 6;
         clrBtnDeHedging = clrActiveBtn;
         lblBtnDeHedging += " " + (string) global_bot_count_hedg_sel + "S";
        }
      createButton(BtnDeHedging, lblBtnDeHedging, 590, y_row_1, 70, BUTTON_HEIGH, clrBlack, clrBtnDeHedging, sizeBtnDeHedging);

      //---------------------------------------------------------------------------

      datetime time_d0 = iTime(symbol, PERIOD_D1, 0);
      datetime time_d1 = iTime(symbol, PERIOD_D1, 1);
      double hig_d1 = iHigh(symbol,    PERIOD_D1, 1);
      double low_d1 = iLow(symbol,     PERIOD_D1, 1);
      double hig_d0 = iHigh(symbol,    PERIOD_D1, 0);
      double low_d0 = iLow(symbol,     PERIOD_D1, 0);
      color clrTrendD1 = cur_price > close_d1 ? clrBlue : clrRed;
      string strTrendD1 = cur_price > close_d1 ? TREND_BUY : TREND_SEL;

      create_trend_line("close_d1", time_d0, close_d1, TimeCurrent(), close_d1,  clrTrendD1, STYLE_SOLID, 2);

      create_lable("hig_d0", TimeCurrent(), hig_d0, "H " + format_double_to_string(hig_d0 - close_d1, Digits-1) + "" + (string)(" ("+format_double_to_string(hig_d0-low_d0, Digits-1)+")"), TREND_BUY, true, 6);
      create_lable("low_d0", TimeCurrent(), low_d0, "L " + format_double_to_string(close_d1 - low_d0, Digits-1) + "" + (string)(" ("+format_double_to_string(low_d0-hig_d0, Digits-1)+")"), TREND_SEL, true, 6);

      string strLable_trend_d1 = "                    " ;
      strLable_trend_d1 += format_double_to_string(cur_price - close_d1, Digits-1) + "";
      strLable_trend_d1 += " (Low +" + format_double_to_string((cur_price-low_d0), Digits-1);
      strLable_trend_d1 += "    Hig " + format_double_to_string((cur_price-hig_d0), Digits-1) + ")";
      strLable_trend_d1 += create_Cno();
      create_lable("No.", TimeCurrent(), NormalizeDouble((low_d0+hig_d0)/2, Digits-1), strLable_trend_d1, "", false, 8);


      create_vertical_line("now", TimeCurrent(), clrSilver, STYLE_SOLID);

      if(Period() < PERIOD_H4)
        {
         double open_w0 = iOpen(Symbol(), PERIOD_W1, 0);
         create_lable("open_w0", TimeCurrent(), open_w0,
                      (cur_price > open_w0 ? "Wo(+" : "Wo(-") + format_double_to_string(MathAbs(cur_price - open_w0), Digits-1) + ")",
                      cur_price > open_w0 ? TREND_BUY : TREND_SEL, true, 6);
        }
      else
        {
         ObjectDelete(0, "open_w0");
         ObjectDelete(0, "hig_d0");
         ObjectDelete(0, "low_d0");
         ObjectDelete(0, "low_d1");
         ObjectDelete(0, "hig_d1");
         ObjectDelete(0, "lbl_close_d1");
         ObjectDelete(0, "close_d1");
         ObjectDelete(0, "lbl_trend_d1");
         ObjectDelete(0, "line_hig_d0");
         ObjectDelete(0, "line_low_d0");
        }

      if(Period() == PERIOD_M1)
        {
         string cNo = create_Cno();
         create_lable("No", TimeCurrent(), cur_price, cNo, "");
         ObjectSetInteger(0,"No", OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0,"No", OBJPROP_TIMEFRAMES, OBJ_PERIOD_M1);
        }

      if(GlobalVariableCheck("MyHorizontalLinePrice"))
         INIT_START_PRICE = GlobalVariableGet("MyHorizontalLinePrice");
      ObjectCreate(0, START_TRADE_LINE, OBJ_HLINE, 0, Time[0], INIT_START_PRICE);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_WIDTH, Period() <= PERIOD_H1 ? 2 : 2);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_SELECTED, true);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_BACK, true);
     }
   else
      deleteIndicatorsWindows();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Lines(string symbol)
  {
   if(is_main_control_screen())
     {
      string prifix = "draw_";
      for(int col = 0; col < 91; col ++)
        {
         double low_di = iLow(symbol, PERIOD_D1, col);
         double close_di = iClose(symbol, PERIOD_D1, col);
         double hig_di = iHigh(symbol, PERIOD_D1, col);

         datetime time_di = iTime(symbol, PERIOD_D1, col);
         datetime time_di0 = col == 0 ? TimeCurrent() : iTime(symbol, PERIOD_D1, col-1);

         double close_di1 = iClose(symbol, PERIOD_D1, col+1);

         string trend_sl_buy = prifix + "d" + (string)(col+1) + "_sl_buy";
         string trend_sl_sel = prifix + "d" + (string)(col+1) + "_sl_sel";


         string trend_name = prifix + "open_d" + append1Zero(col);
         string trend_di = close_di > close_di1 ? TREND_BUY : TREND_SEL;
         color clrTrend = close_di > close_di1 ? clrBlue : clrRed;

         double price_sl_di_buy = close_di1 - FIXED_SL_AMP;
         double price_sl_di_sel = close_di1 + FIXED_SL_AMP;

         if(Period() <= PERIOD_H4)
            create_trend_line(trend_name, time_di, close_di1, time_di0, close_di1, clrTrend, STYLE_SOLID, col > 0 ? 2:1, false, false);
         else
            ObjectDelete(0, trend_name);

         if(col < ArraySize(arrHeiken_d1))
            GetHighestLowestM5Times(symbol, time_di, time_di0, col);
        }
      //---------------------------------------------------------------------------------------------------------
      for(int col = 0; col < 13; col ++)
        {
         datetime time_wi = iTime(symbol, PERIOD_W1, col);
         datetime time_wi0 = col == 0? TimeCurrent() : iTime(symbol, PERIOD_W1, col-1);
         string ver_name = prifix + "W" + append1Zero(col);
         string close_name_wi = prifix + "W." + append1Zero(col);
         double close_wi = iClose(symbol, PERIOD_W1, col);
         double close_wi1 = iClose(symbol, PERIOD_W1, col+1);
         color clrTrend = close_wi > close_wi1 ? clrBlue : clrRed;
         if(Period() < PERIOD_D1)
           {
            create_vertical_line(ver_name, time_wi, clrBlack, STYLE_SOLID, 1);
            create_trend_line(close_name_wi, time_wi, close_wi1, time_wi0, close_wi1, clrTrend, STYLE_SOLID, 2, false, false);
           }
         else
           {
            ObjectDelete(0, ver_name);
            ObjectDelete(0, close_name_wi);
           }
        }
      //---------------------------------------------------------------------------------------------------------
      for(int col = 0; col < 3; col ++)
        {
         datetime time_mni = iTime(symbol, PERIOD_MN1, col);
         string ver_mi = prifix + "MN" + append1Zero(col);
         datetime time_mni0 = col == 0 ? TimeCurrent() : iTime(symbol, PERIOD_MN1, col-1);
         string close_name_mni = prifix + "MN." + append1Zero(col);
         double close_mni = iClose(symbol, PERIOD_MN1, col);
         double close_mni1 = iClose(symbol, PERIOD_MN1, col+1);
         color clrTrend = close_mni > close_mni1 ? clrBlue : clrRed;

         if(Period() <= PERIOD_H4)
           {
            create_vertical_line(ver_mi, time_mni, clrBlack, STYLE_SOLID, 2);
            create_trend_line(close_name_mni, time_mni, close_mni1, time_mni0, close_mni1, clrTrend, STYLE_SOLID, 3, false, false);

            if(col == 1)
              {
               create_lable(prifix + "."+ close_name_mni, time_mni0, close_mni1, ver_mi + " (" + format_double_to_string(close_mni1, Digits-1) + ")", "", true, 6);
               create_trend_line(prifix + "MN_" + append1Zero(col), time_mni0, close_mni1, TimeCurrent(), close_mni1, clrTrend, STYLE_DASHDOTDOT, 1, false, false);
              }
           }
         else
           {
            ObjectDelete(0, ver_mi);
            ObjectDelete(0, close_name_mni);
           }
        }
      //-------------------------------------------------------------------------------------------------
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken(string symbol)
  {
   datetime time_1d = iTime(symbol, PERIOD_D1, 1) - iTime(symbol, PERIOD_D1, 2);
   datetime time_1w = iTime(symbol, PERIOD_W1, 1) - iTime(symbol, PERIOD_W1, 2);
   bool allow_draw = Period() <= PERIOD_H4;

   for(int i = 0; i < 100; i++)
     {
      string candle_name = "hei_d_" + appendZero100(i);
      ObjectDelete(0, candle_name);
     }

   if(Period() > PERIOD_H4)
      return;

   for(int i = 0; i < ArraySize(arrHeiken_d1) - 2; i++)
     {
      string candle_name = "hei_d_" + appendZero100(i);

      CandleData candle_i = arrHeiken_d1[i];
      string sub_name = "_" + (string)(i+1) + "_" + (string)i;
      datetime time_i1;

      double realOpen = iOpen(symbol, PERIOD_D1, i);
      datetime time_i2 = iTime(symbol, PERIOD_D1, i);
      if(i == 0)
         time_i1 = time_i2 + time_1d;
      else
         time_i1 = iTime(symbol, PERIOD_D1, i-1);

      double low = NormalizeDouble(iLow(symbol, PERIOD_D1, i), Digits-2);
      double hig = NormalizeDouble(iHigh(symbol, PERIOD_D1, i), Digits-2);

      string trend_by_time = getTrendByLowHigTimes(symbol, time_i2, time_i2+time_1d, PERIOD_H1);

      color clrColor = trend_by_time == TREND_BUY ? clrAliceBlue : trend_by_time == TREND_SEL ? C'235,235,235' : clrNONE;

      if(i == 0)
        {
         bool d1_h1_allow_trade = (trend_by_ma10_d1 == trend_by_time) && (trend_by_ma10_h1 == trend_by_time);

         if(d1_h1_allow_trade == false)
            clrColor = clrNONE;
        }

      create_filled_rectangle(candle_name, time_i2, low, time_i1, hig, clrColor, (i==0));
     }


   for(int i = 0; i < 1; i++)
     {
      datetime time_i2 = iTime(symbol, PERIOD_W1, i);
      datetime time_i1 = (i == 0) ? time_i2 + time_1w : iTime(symbol, PERIOD_W1, i-1);
      string trend_by_time = getTrendByLowHigTimes(symbol, time_i2, time_i2+time_1w, PERIOD_H4);

      double low = NormalizeDouble(iLow(symbol, PERIOD_W1, i), Digits-2);
      double hig = NormalizeDouble(iHigh(symbol, PERIOD_W1, i), Digits-2);

      string candle_name = "hei_w_" + append1Zero(i);
      color clrColor = trend_by_time == TREND_BUY ? clrAliceBlue : trend_by_time == TREND_SEL ? C'215,215,215' : clrNONE;

      create_filled_rectangle(candle_name, time_i2, low, time_i1, hig, clrColor, true, false);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_max_sel_price(string symbol)
  {
   double max_sel_price = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderType() == OP_SELL))
            if(max_sel_price < OrderOpenPrice())
               max_sel_price = OrderOpenPrice();

   return max_sel_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_min_buy_price(string symbol)
  {
   double min_buy_price = MAXIMUM_DOUBLE;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderType() == OP_BUY))
            if(min_buy_price > OrderOpenPrice())
               min_buy_price = OrderOpenPrice();

   return min_buy_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_NextDca()
  {
   return;
//-------------------------------------------------------------------------------------------------
   if(Period() < PERIOD_H4)
     {
      datetime TIME_CUR = TimeCurrent();

      double min_entry = MathMin(global_min_entry_buy, global_min_entry_sel);
      double max_entry = MathMax(global_max_entry_buy, global_max_entry_sel);

      create_trend_line("min_entry", TIME_CUR - TIME_OF_ONE_H4_CANDLE, min_entry, TIME_CUR, min_entry, clrGreenYellow, STYLE_SOLID, 1, true, true);
      create_trend_line("max_entry", TIME_CUR - TIME_OF_ONE_H4_CANDLE, max_entry, TIME_CUR, max_entry, clrGreenYellow, STYLE_SOLID, 1, true, true);

      if(global_bot_count_manual_buy > 0)
        {
         double next_buy_1per = min_entry - AMP_DC;
         next_buy_1per = get_best_entry_for_wait(TREND_BUY, next_buy_1per);

         create_trend_line("NEXT_B1%", TIME_CUR - TIME_OF_ONE_H4_CANDLE, next_buy_1per, TIME_CUR, next_buy_1per, clrBlue);
         //create_lable("NEXT.B1%", TIME_CUR, next_buy_1per, "Next B1% " + (string)(next_buy_1per), TREND_SEL, true, 5);
        }

      if(global_10percent_count_buy > 0)
        {
         create_trend_line("CURR_B10%", TIME_CUR - TIME_OF_ONE_H4_CANDLE, global_10percent_min_open_price, TIME_CUR, global_10percent_min_open_price, clrBlack);

         double next_buy_10per = min_entry - NEXT_10PER_AMP;
         next_buy_10per = get_best_entry_for_wait(TREND_BUY, next_buy_10per);

         create_trend_line("NEXT_B10%", TIME_CUR - TIME_OF_ONE_H4_CANDLE,  next_buy_10per, TIME_CUR, next_buy_10per, clrBlue, STYLE_SOLID, 1, true);
         create_lable("NEXT.B10%", TIME_CUR,                               next_buy_10per, "NEXT B10% " + (string)(next_buy_10per), TREND_SEL, true, 5);
        }
      //-------------------------------------------------------------------------------------------------
      if(global_bot_count_manual_sel > 0)
        {
         double next_sel_1per = max_entry + AMP_DC;
         next_sel_1per = get_best_entry_for_wait(TREND_SEL, next_sel_1per);

         create_trend_line("NEXT_S1%", TIME_CUR - TIME_OF_ONE_H4_CANDLE, next_sel_1per, TIME_CUR, next_sel_1per, clrRed);
         //create_lable("NEXT.S1%", TIME_CUR, next_sel_1per, "Next S1% " + (string)(next_sel_1per), TREND_SEL, true, 5);
        }

      if(global_10percent_count_sel > 0)
        {
         create_trend_line("CURR_S10%", TIME_CUR - TIME_OF_ONE_H4_CANDLE, global_10percent_max_open_price, TIME_CUR, global_10percent_max_open_price, clrBlack);

         double next_sel_10per = max_entry + NEXT_10PER_AMP;
         next_sel_10per = get_best_entry_for_wait(TREND_SEL, next_sel_10per);

         create_trend_line("NEXT_S10%", TIME_CUR - TIME_OF_ONE_H4_CANDLE,  next_sel_10per, TIME_CUR, next_sel_10per, clrRed,  STYLE_SOLID, 1, true);
         create_lable("NEXT.S10%", TIME_CUR,                               next_sel_10per, "NEXT S10% " + (string)(next_sel_10per), TREND_SEL, true, 5);
        }
     }
   else
     {
      ObjectDelete(0, "NEXT_B1%");
      ObjectDelete(0, "NEXT.B1%");

      ObjectDelete(0, "CURR_B10%");
      ObjectDelete(0, "NEXT_B10%");
      ObjectDelete(0, "NEXT.B10%");


      ObjectDelete(0, "NEXT_S1%");
      ObjectDelete(0, "NEXT.S1%");

      ObjectDelete(0, "CURR_S10%");
      ObjectDelete(0, "NEXT_S10%");
      ObjectDelete(0, "NEXT.S10%");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string RemoveCharsBeforeTilde(string str_input)
  {
   int tilde_pos = StringFind(str_input, "~");
   if(tilde_pos != -1)
      return StringSubstr(str_input, tilde_pos + 1);

   return str_input;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init_trade_cond_10precent()
  {
   if(GlobalVariableCheck("CondH4Price"))
      CondH4Price = GlobalVariableGet("CondH4Price");
   else
     {
      CondH4Price = true;
      GlobalVariableSet("CondH4Price", CondH4Price);
     }

   if(GlobalVariableCheck("CondH4Stoch8020"))
      CondH4Stoch8020 = GlobalVariableGet("CondH4Stoch8020");
   else
     {
      CondH4Stoch8020 = true;
      GlobalVariableSet("CondH4Stoch8020", CondH4Stoch8020);
     }

   if(GlobalVariableCheck("CondH1Heiken"))
      CondH1Heiken = GlobalVariableGet("CondH1Heiken");
   else
     {
      CondH1Heiken = true;
      GlobalVariableSet("CondH1Heiken", CondH1Heiken);
     }

   if(GlobalVariableCheck("CondH1Stoch8020"))
      CondH1Stoch8020 = GlobalVariableGet("CondH1Stoch8020");
   else
     {
      CondH1Stoch8020 = true;
      GlobalVariableSet("CondH1Stoch8020", CondH1Stoch8020);
     }

   if(GlobalVariableCheck("Cond15Seq125"))
      Cond15Seq125 = GlobalVariableGet("Cond15Seq125");
   else
     {
      Cond15Seq125 = true;
      GlobalVariableSet("Cond15Seq125", Cond15Seq125);
     }

   if(GlobalVariableCheck("Cond15Stoch8020"))
      Cond15Stoch8020 = GlobalVariableGet("Cond15Stoch8020");
   else
     {
      Cond15Stoch8020 = true;
      GlobalVariableSet("Cond15Stoch8020", Cond15Stoch8020);
     }

   if(GlobalVariableCheck("Cond05Seq125"))
      Cond05Seq125 = GlobalVariableGet("Cond05Seq125");
   else
     {
      Cond05Seq125 = true;
      GlobalVariableSet("Cond05Seq125", Cond05Seq125);
     }

   if(GlobalVariableCheck("Cond05Stoch8020"))
      Cond05Stoch8020 = GlobalVariableGet("Cond05Stoch8020");
   else
     {
      Cond05Stoch8020 = true;
      GlobalVariableSet("Cond05Stoch8020", Cond05Stoch8020);
     }

   if(GlobalVariableCheck("Cond01Seq125"))
      Cond01Seq125 = GlobalVariableGet("Cond01Seq125");
   else
     {
      Cond01Seq125 = true;
      GlobalVariableSet("Cond01Seq125", Cond01Seq125);
     }

   if(GlobalVariableCheck("Cond01Stoch8020"))
      Cond01Stoch8020 = GlobalVariableGet("Cond01Stoch8020");
   else
     {
      Cond01Stoch8020 = true;
      GlobalVariableSet("Cond01Stoch8020", Cond01Stoch8020);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string allow_trade_now_by_price_closeH4_and_heikenM1(string symbol, string find_trend)
  {
   double cur_price = iClose(symbol, PERIOD_M1, 0);

   if(find_trend == TREND_BUY)
     {
      bool pass_price_h4 = cur_price < INIT_START_PRICE && INIT_START_PRICE > 0;

      if(pass_price_h4)
        {
         if(arrHeiken_m1[0].trend_heiken == TREND_BUY)
            return TREND_BUY;
        }
     }
//------------------------------------------------
   if(find_trend == TREND_SEL)
     {
      bool pass_price_h4 = cur_price > INIT_START_PRICE && INIT_START_PRICE > 0;

      if(pass_price_h4)
        {
         if(arrHeiken_m1[0].trend_heiken == TREND_SEL)
            return TREND_SEL;
        }
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_reacts_with_close_d1(string symbol)
  {
   double close_d1 = iClose(symbol, PERIOD_D1, 1);

   if((iLow(symbol, PERIOD_H1, 1) < close_d1) && (close_d1 < iHigh(symbol, PERIOD_H1, 1)))
      return true;

   if((iLow(symbol, PERIOD_M15,1) < close_d1) && (close_d1 < iHigh(symbol, PERIOD_M15,1)))
      return true;

   if((iLow(symbol, PERIOD_H1, 0) < close_d1) && (close_d1 < iHigh(symbol, PERIOD_H1, 0)))
      return true;

   if((iLow(symbol, PERIOD_M15,0) < close_d1) && (close_d1 < iHigh(symbol, PERIOD_M15,0)))
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_stop_trading_by_potential_loss()
  {
   if(GLOBAL_POTENTIAL_LOSS == 0)
      return false;

   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   double per = MathAbs(GLOBAL_POTENTIAL_LOSS)/BALANCE * 100;
   if(per >= MAX_PERCENT_POTENTIAL_LOSS)
      return true;

   if(ACC_PROFIT < GLOBAL_POTENTIAL_LOSS)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendFiltering(string symbol)
  {
   string result = "";
   result += " Heiken_D1[0]: " + arrHeiken_d1[0].trend_heiken;
   result += "    Ma10[0]: " + trend_by_ma10_d1;
   result += "\n";

   result += " Heiken_H4[0]: " + arrHeiken_h4[0].trend_heiken;
   result += "    Ma10[0]: " + trend_by_ma10_h4;
   result += "    Macd H4: " + trend_mac_vs_signal_h4;
   result += "\n";

   result += " Heiken_H1[0]: " + arrHeiken_h1[0].trend_heiken;
   result += "    Ma10[0]: " + trend_by_ma10_h1;
   result += "    Macd H1: " + trend_mac_vs_signal_h1;
   result += "\n";

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetStartPrice(bool show_mesage=true)
  {
   double min_close_heiken_h4 = 0;
   double max_close_heiken_h4 = 0;

   for(int i = 0; i < ArraySize(arrHeiken_h4); i++)
     {
      double close = arrHeiken_h4[i].close;
      if(i==0 || min_close_heiken_h4 > close)
         min_close_heiken_h4 = close;

      if(i==0 || max_close_heiken_h4 < close)
         max_close_heiken_h4 = close;
     }

   if(trend_by_ma10_d1 == TREND_BUY)
     {
      INIT_START_PRICE = arrHeiken_d1[0].ma10; //min_close_heiken_h4;
      GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
      ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, INIT_START_PRICE);
      saveAutoTrade();
     }

   if(trend_by_ma10_d1 == TREND_SEL)
     {
      INIT_START_PRICE = arrHeiken_d1[0].ma10; //max_close_heiken_h4;
      GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
      ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, INIT_START_PRICE);
      saveAutoTrade();
     }

   if(is_stop_trading_by_potential_loss())
     {
      IS_WAITTING_10PER_BUY = false;
      IS_WAITTING_10PER_SEL = false;
      IS_CONTINUE_TRADING_CYCLE_BUY = false;
      IS_CONTINUE_TRADING_CYCLE_SEL = false;

      saveAutoTrade();

      double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
      if(show_mesage)
         Alert("(STOP_TRADE) By POTENTIAL_LOSS:" + (string)(int)GLOBAL_POTENTIAL_LOSS + "$ ("+ format_double_to_string(GLOBAL_POTENTIAL_LOSS/BALANCE*100, 1) + "%)");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenChartWindow(string buttonLabel)
  {
   for(int index = 0; index < ArraySize(free_extended_overnight_fees); index++)
     {
      string cur_symbol = free_extended_overnight_fees[index];

      if(is_same_symbol(buttonLabel, cur_symbol))
        {
         ENUM_TIMEFRAMES TIMEFRAME = PERIOD_D1;
         //if(is_same_symbol(buttonLabel, "H4"))
         //   TIMEFRAME = PERIOD_H4;
         //if(is_same_symbol(buttonLabel, "H1"))
         //   TIMEFRAME = PERIOD_H1;

         ChartOpen(cur_symbol, TIMEFRAME);

         int count_tap = 0;
         long chartID=ChartFirst();
         while(chartID >= 0)
           {
            long close_chart_id = chartID;
            string chartSymbol = ChartSymbol(close_chart_id);
            if(is_same_symbol(chartSymbol, cur_symbol) == false)
               ChartClose(close_chart_id);
            else
               count_tap += 1;

            if(count_tap > 1)
               ChartClose(close_chart_id);

            chartID = ChartNext(chartID);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,       // event ID
                  const long&   lparam,   // long type event parameter
                  const double& dparam,   // double type event parameter
                  const string& sparam    // string type event parameter
                 )
  {
   string symbol = Symbol();

   switch(id)
     {
      case CHARTEVENT_OBJECT_CLICK:
         if(sparam == START_TRADE_LINE)
           {
            isDragging = true;
            INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
            Print("CHARTEVENT_OBJECT_CLICK " + (string) INIT_START_PRICE);
            GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
           }
         else
            isDragging = false;

         break;

      case CHARTEVENT_OBJECT_DRAG:
         if(sparam == START_TRADE_LINE)
           {
            isDragging = false;
            INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
            Print("CHARTEVENT_OBJECT_DRAG " + (string) INIT_START_PRICE);
            GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
           }
         break;

      case CHARTEVENT_MOUSE_MOVE:
         if(isDragging)
           {
            double newPrice = NormalizeDouble(WindowPriceOnDropped(), Digits);
            if(newPrice > 0)
              {
               ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, newPrice);
               INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
               Print("CHARTEVENT_MOUSE_MOVE "  + (string) INIT_START_PRICE);
               GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
              }
           }
         break;
     }
//-------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnD10) || is_same_symbol(sparam, BtnNoticeH4Ma10))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel);
     }

   if(is_same_symbol(sparam, BtnTPCurSymbol))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, Symbol()) == false)
         return;

      string msg = buttonLabel + "?\n";
      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
         ClosePositivePosition(Symbol(), "");
     }

   if(is_same_symbol(sparam, BtnTradeNow10D))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, Symbol()) == false)
         return;

      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

      CandleData temp_array_D1[];
      get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 21, true);

      double min_7d = 0;
      double max_7d = 0;
      for(int i = 0; i < 7; i++)
        {
         if(i==0 || min_7d > temp_array_D1[i].low)
            min_7d = temp_array_D1[i].low;

         if(i==0 || max_7d < temp_array_D1[i].high)
            max_7d = temp_array_D1[i].high;
        }
      double sl_buy = min_7d - amp_h4;
      double sl_sel = max_7d + amp_h4;

      double min_21d = 0;
      double max_21d = 0;
      for(int i = 0; i < ArraySize(temp_array_D1); i++)
        {
         if(i==0 || min_21d > temp_array_D1[i].low)
            min_21d = temp_array_D1[i].low;

         if(i==0 || max_21d < temp_array_D1[i].high)
            max_21d = temp_array_D1[i].high;
        }

      string trend_ma10_d1 = temp_array_D1[0].trend_by_ma10;
      double amp_sl =  trend_ma10_d1 == TREND_BUY ? (Bid - sl_buy) : (sl_sel - Ask);

      double vol = calc_volume_by_amp(symbol, amp_sl, risk_10_Percent_Account_Balance());
      string strLable = trend_ma10_d1 + " " + symbol + " Vol 10% = " + (string) vol + " lot";

      double sl = trend_ma10_d1 == TREND_BUY ? sl_buy : sl_sel;
      double sl_limit = trend_ma10_d1 == TREND_BUY ? min_7d - amp_sl : max_7d + amp_sl;

      double tp = trend_ma10_d1 == TREND_BUY ? max_21d : min_21d;

      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), symbol))
               count += 1;

      string comment = MASK_D10 + create_comment(create_trader_name(), trend_ma10_d1, count+1);
      string comment_limit = MASK_D10 + create_comment(create_trader_name(), trend_ma10_d1, count+2);

      string msg = strLable + "?\n";
      msg += comment + " Market " "\n";
      msg += comment_limit + " Limit " + "\n";

      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         int OP_TYPE = trend_ma10_d1 == TREND_BUY ? OP_BUY : trend_ma10_d1 == TREND_SEL ? OP_SELL : -1;
         int OP_LIMIT = trend_ma10_d1 == TREND_BUY ? OP_BUYLIMIT : trend_ma10_d1 == TREND_SEL ? OP_SELLLIMIT : -1;
         double price_limit = trend_ma10_d1 == TREND_BUY ? min_7d : trend_ma10_d1 == TREND_SEL ? max_7d : 0;

         if(OP_TYPE != -1 && trend_ma10_d1 != "" && price_limit > 0)
           {
            bool limit_ok = Open_Position(Symbol(), OP_LIMIT,
                                          NormalizeDouble(vol/2, 2), NormalizeDouble(sl_limit, Digits), NormalizeDouble(tp, Digits), comment_limit, NormalizeDouble(price_limit, Digits));
            if(limit_ok)
              {
               bool market_ok = Open_Position(Symbol(), OP_TYPE,
                                              NormalizeDouble(vol/2, 2), NormalizeDouble(sl, Digits), NormalizeDouble(tp, Digits), comment);
               if(market_ok)
                  Alert(MASK_D10 + Symbol() + " " + comment);
              }
           }
        }
     }
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
      double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

      if(sparam == BtnDeHedging)
        {
         if(global_bot_count_hedg_buy+global_bot_count_hedg_sel > 0)
           {
            string msg = "DeHedging " + Symbol() + "?\n";
            int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
            if(result == IDYES)
              {
               De_Hedging(true);
              }
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnHedgBuy2Sel || sparam == BtnHedgSel2Buy)
        {
         if(ACC_PROFIT + risk_1_Percent_Account_Balance() > 0)
            return;

         string msg = Symbol() + "    Hedging?\n";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            do_hedging(Symbol());
           }
        }

      if(sparam == BtnSetEntryBuy || sparam == BtnSetEntrySel)
        {
         double best_tp = 0;
         string find_trend = "";
         double total_potential_profit = 0;

         if(sparam == BtnSetEntryBuy)
           {
            if(global_tcount_buy == 0)
               return;

            find_trend = TREND_BUY;
            best_tp = get_tp_best(Symbol(), TREND_BUY);
            total_potential_profit = total_best_potential_profit_buy;
           }

         if(sparam == BtnSetEntrySel)
           {
            if(global_tcount_sel == 0)
               return;

            find_trend = TREND_SEL;
            best_tp = get_tp_best(Symbol(), TREND_SEL);
            total_potential_profit = total_best_potential_profit_sel;
           }

         string msg =  Symbol() + " Set TP " + find_trend + "?\n";
         msg += "    (YES) BestTP="+(string) best_tp + "  Est: " + (string)(int)total_potential_profit + "$\n";
         msg += "    (NO) TP=0.0";

         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
            ModifyTp_ToTPPrice(Symbol(),best_tp, find_trend);

         if(result == IDNO)
            ModifyTp_ToTPPrice(Symbol(),0.0, find_trend);
        }

      if(sparam == BtnPaddingTrade || sparam == BtnSolveNegative)
        {
         Solve_Negative(Symbol(), true);
        }

      if(sparam == BtnResetCond10per)
        {
         CondH4Price     = true;
         CondH1Heiken    = false;
         Cond15Seq125    = false;
         Cond05Seq125    = false;
         Cond01Seq125    = false;

         CondH4Stoch8020 = false;
         CondH1Stoch8020 = false;
         Cond15Stoch8020 = false;
         Cond05Stoch8020 = true;
         Cond01Stoch8020 = false;

         GlobalVariableSet("CondH4Price",       CondH4Price);
         GlobalVariableSet("CondH1Heiken",      CondH1Heiken);
         GlobalVariableSet("Cond15Seq125",      Cond15Seq125);
         GlobalVariableSet("Cond05Seq125",      Cond05Seq125);
         GlobalVariableSet("Cond01Seq125",      Cond01Seq125);

         GlobalVariableSet("CondH4Stoch8020",   CondH4Stoch8020);
         GlobalVariableSet("CondH1Stoch8020",   CondH1Stoch8020);
         GlobalVariableSet("Cond15Stoch8020",   Cond15Stoch8020);
         GlobalVariableSet("Cond05Stoch8020",   Cond05Stoch8020);
         GlobalVariableSet("Cond01Stoch8020",   Cond01Stoch8020);

         DeleteAllObjects();

         ResetStartPrice(false);

         Draw_Buttons();
         Draw_Lines(Symbol());
        }

      if(sparam == BtnCondH4Price)
        {
         CondH4Price = !CondH4Price;
         GlobalVariableSet("CondH4Price", CondH4Price);

         if(CondH4Price)
            ResetStartPrice();
        }

      if(sparam == BtnCondH4Stoch8020)
        {
         CondH4Stoch8020 = !CondH4Stoch8020;
         GlobalVariableSet("CondH4Stoch8020", CondH4Stoch8020);
        }
      if(sparam == BtnCondH1Heiken)
        {
         CondH1Heiken = !CondH1Heiken;
         GlobalVariableSet("CondH1Heiken", CondH1Heiken);
        }
      if(sparam == BtnCondH1Stoch8020)
        {
         CondH1Stoch8020 = !CondH1Stoch8020;
         GlobalVariableSet("CondH1Stoch8020", CondH1Stoch8020);
        }
      if(sparam == BtnCond15Seq125)
        {
         Cond15Seq125 = !Cond15Seq125;
         GlobalVariableSet("Cond15Seq125", Cond15Seq125);
        }
      if(sparam == BtnCond15Stoch8020)
        {
         Cond15Stoch8020 = !Cond15Stoch8020;
         GlobalVariableSet("Cond15Stoch8020", Cond15Stoch8020);
        }
      if(sparam == BtnCond05Seq125)
        {
         Cond05Seq125 = !Cond05Seq125;
         GlobalVariableSet("Cond05Seq125", Cond05Seq125);
        }
      if(sparam == BtnCond05Stoch8020)
        {
         Cond05Stoch8020 = !Cond05Stoch8020;
         GlobalVariableSet("Cond05Stoch8020", Cond05Stoch8020);
        }
      if(sparam == BtnCond01Seq125)
        {
         Cond01Seq125 = !Cond01Seq125;
         GlobalVariableSet("Cond01Seq125", Cond01Seq125);
        }
      if(sparam == BtnCond01Stoch8020)
        {
         Cond01Stoch8020 = !Cond01Stoch8020;
         GlobalVariableSet("Cond01Stoch8020", Cond01Stoch8020);
        }

      if(sparam == BtnWaitBuy10Per)
        {
         if(pass_pre_check_before_trade(TREND_BUY) == false)
            return;

         if(is_stop_trading_by_potential_loss())
           {
            ResetStartPrice();
            return;
           }

         bool is_30_percent_loss = (BALANCE*0.2 + ACC_PROFIT < 0);
         if(is_30_percent_loss)
           {
            Alert("DISABLE WAIT BUY 3x10% (Opened: " + (string)global_10percent_count_buy + "L), Profit: " + (string)(int)ACC_PROFIT
                  + "$ (" + format_double_to_string(ACC_PROFIT/INIT_EQUITY * 100, 1) + "%)");

            return;
           }

         IS_WAITTING_10PER_BUY = !IS_WAITTING_10PER_BUY;

         if(IS_WAITTING_10PER_BUY)
           {
            IS_WAITTING_10PER_SEL = false;
            IS_CONTINUE_TRADING_CYCLE_SEL = false;
           }
         saveAutoTrade();

         ResetStartPrice();
        }

      if(sparam == BtnWaitSel10Per)
        {
         if(pass_pre_check_before_trade(TREND_SEL) == false)
            return;

         if(is_stop_trading_by_potential_loss())
           {
            ResetStartPrice();
            return;
           }

         bool is_30_percent_loss = (BALANCE*0.2 + ACC_PROFIT < 0);
         if(is_30_percent_loss)
           {
            Alert("DISABLE WAIT SEL 3x10% (Opened: " + (string)global_10percent_count_sel + "L), Profit: " + (string)(int)ACC_PROFIT
                  + "$ (" + format_double_to_string(ACC_PROFIT/INIT_EQUITY * 100, 1) + "%)");

            return;
           }

         IS_WAITTING_10PER_SEL = !IS_WAITTING_10PER_SEL;

         if(IS_WAITTING_10PER_SEL)
           {
            IS_WAITTING_10PER_BUY = false;
            IS_CONTINUE_TRADING_CYCLE_BUY = false;
           }

         saveAutoTrade();

         ResetStartPrice();
        }

      if(sparam == BtnNewCycleBuy)
        {
         if(pass_pre_check_before_trade(TREND_BUY) == false)
           {
            IS_CONTINUE_TRADING_CYCLE_BUY = false;
            saveAutoTrade();
            return;
           }

         if(pass_pre_check_over_bs_by_stoc(TREND_BUY) == false)
           {
            IS_CONTINUE_TRADING_CYCLE_BUY = false;
            saveAutoTrade();
            return;
           }

         if(IS_CONTINUE_TRADING_CYCLE_BUY == false)
           {
            if(is_stop_trading_by_potential_loss())
              {
               ResetStartPrice();
               return;
              }


            string all_trend = getTrendFiltering(Symbol());
            if(is_same_symbol(all_trend, TREND_BUY) == false)
              {
               Alert("(NOT_ALLOW_BUY) ALL_TREND :\n" + all_trend);
               return;
              }
           }

         Print("The ", sparam," was clicked, IS_CONTINUE_TRADING_CYCLE_BUY=" + (string)IS_CONTINUE_TRADING_CYCLE_BUY);
         IS_CONTINUE_TRADING_CYCLE_BUY = !IS_CONTINUE_TRADING_CYCLE_BUY;


         if(IS_CONTINUE_TRADING_CYCLE_BUY)
           {
            IS_WAITTING_10PER_SEL = false;
            IS_CONTINUE_TRADING_CYCLE_SEL = false;
            ResetStartPrice();
           }

         saveAutoTrade();
        }

      if(sparam == BtnNewCycleSel)
        {
         if(pass_pre_check_before_trade(TREND_SEL) == false)
           {
            IS_CONTINUE_TRADING_CYCLE_SEL = false;
            saveAutoTrade();
            return;
           }

         if(pass_pre_check_over_bs_by_stoc(TREND_SEL) == false)
           {
            IS_CONTINUE_TRADING_CYCLE_SEL = false;
            saveAutoTrade();
            return;
           }

         if(IS_CONTINUE_TRADING_CYCLE_SEL == false)
           {
            if(is_stop_trading_by_potential_loss())
              {
               ResetStartPrice();
               return;
              }

            string all_trend = getTrendFiltering(Symbol());
            if(is_same_symbol(all_trend, TREND_SEL) == false)
              {
               Alert("(NOT_ALLOW_SELL) ALL_TREND :\n" + all_trend);
               return;
              }
           }

         Print("The ", sparam," was clicked, IS_CONTINUE_TRADING_CYCLE_SEL=" + (string)IS_CONTINUE_TRADING_CYCLE_SEL);
         IS_CONTINUE_TRADING_CYCLE_SEL = !IS_CONTINUE_TRADING_CYCLE_SEL;
         if(IS_CONTINUE_TRADING_CYCLE_SEL)
            IS_CONTINUE_TRADING_CYCLE_BUY = false;

         if(IS_CONTINUE_TRADING_CYCLE_SEL)
           {
            IS_WAITTING_10PER_BUY = false;
            IS_CONTINUE_TRADING_CYCLE_BUY = false;
            ResetStartPrice();
           }

         saveAutoTrade();
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnClosePositiveOrders)
        {
         Print("The ", sparam," was clicked IDYES");
         ClosePositivePosition(Symbol(), "");
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnCloseProfitBuy)
        {
         return;

         string msg = "CLOSE_ALL " + Symbol() + "  " + lable_profit_buy;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            IS_CONTINUE_TRADING_CYCLE_BUY = false;
            saveAutoTrade();

            //ClosePosition(Symbol(), OP_BUY, TREND_BUY);
            ClosePositivePosition(Symbol(), TREND_BUY);
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnCloseProfitSel)
        {
         return;

         string msg = "CLOSE_ALL " + Symbol() + "  " + lable_profit_sel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            IS_CONTINUE_TRADING_CYCLE_SEL = false;
            saveAutoTrade();

            //ClosePosition(Symbol(), OP_SELL, TREND_SEL);
            ClosePositivePosition(Symbol(), TREND_SEL);
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnBuyNow1Per || sparam == BtnSelNow1Per)
        {
         if(sparam == BtnBuyNow1Per)
           {
            if((pass_pre_check_before_trade(TREND_BUY) == false) || (pass_pre_check_over_bs_by_stoc(TREND_BUY) == false))
              {
               IS_CONTINUE_TRADING_CYCLE_SEL = false;
               saveAutoTrade();
               return;
              }
           }

         if(sparam == BtnSelNow1Per)
           {
            if((pass_pre_check_before_trade(TREND_SEL) == false) || (pass_pre_check_over_bs_by_stoc(TREND_SEL) == false))
              {
               IS_CONTINUE_TRADING_CYCLE_SEL = false;
               saveAutoTrade();
               return;
              }
           }

         if(is_stop_trading_by_potential_loss())
           {
            ResetStartPrice();
            return;
           }
         string all_trend = getTrendFiltering(Symbol());

         if(sparam == BtnBuyNow1Per)
            if(is_same_symbol(all_trend, TREND_BUY) == false)
              {
               StringReplace(all_trend, "\n", "");
               Alert("(NOT_ALLOW_BUY) ALL_TREND :\n" + all_trend);
               return;
              }

         if(sparam == BtnSelNow1Per)
            if(is_same_symbol(all_trend, TREND_SEL) == false)
              {
               StringReplace(all_trend, "\n", "");
               Alert("(NOT_ALLOW_SELL) ALL_TREND :\n" + all_trend);
               return;
              }

         double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         double cur_price = (bid+ask)/2;

         double volume_1percent = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, INIT_EQUITY*0.01);
         string find_trend = sparam == BtnBuyNow1Per ? TREND_BUY : TREND_SEL;
         double tp_price = 0;
         double amp_tp = 0;
         if(find_trend == TREND_BUY)
           {
            if(global_bot_count_manual_buy >= 20)
              {
               Alert("DISABLE BUY NOW 1% (Opened: " + (string)global_bot_count_manual_buy + "L)");
               return;
              }

            tp_price = get_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);
            amp_tp = tp_price - cur_price;
           }
         if(find_trend == TREND_SEL)
           {
            if(global_bot_count_manual_sel >= 20)
              {
               Alert("DISABLE SEL NOW 1% (Opened: " + (string)global_bot_count_manual_sel + "L)");
               return;
              }

            tp_price = get_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
            amp_tp = cur_price - tp_price;
           }

         string msg = " Manual " + find_trend + " " + Symbol() + "\n";
         msg += " AmpSL: " + (string)FIXED_SL_AMP + "$    Vol(1%): " + (string)volume_1percent + "lot ";
         msg += "   TP: " + format_double_to_string(tp_price, Digits-1);
         msg += "   AmpTp: " + format_double_to_string(amp_tp, Digits-1) + "\n";
         msg += all_trend + "\n\n";
         msg += "    (YES) "+ find_trend + " " + (string)volume_1percent+" (lot) SL_AMP: "+(string) FIXED_SL_AMP+"$ "+(INIT_TREND_TODAY == TREND_BUY ? "= MACD(H4)" : "")+"\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, find_trend) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, find_trend) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, find_trend) + "\n";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);

         int OP_TYPE = -1;
         int count = 1;
         string selected_trend = "";

         if(result == IDYES)
           {
            if(sparam == BtnBuyNow1Per)
              {
               if(pass_pre_check_over_bs_by_stoc(TREND_BUY) == false)
                  return;


               OP_TYPE = OP_BUY;
               selected_trend = TREND_BUY;

               count += global_bot_count_manual_buy;
              }

            if(sparam == BtnSelNow1Per)
              {
               if(pass_pre_check_over_bs_by_stoc(TREND_SEL) == false)
                  return;

               OP_TYPE = OP_SELL;
               selected_trend = TREND_SEL;

               count += global_bot_count_manual_sel;
              }

            if(OP_TYPE != -1 && selected_trend != "")
              {
               string comment = MASK_MANUAL + create_comment(create_trader_name(), selected_trend, count);
               tp_price = 0.0;
               bool exit_ok = Open_Position(Symbol(), OP_TYPE, volume_1percent, 0.0, tp_price, comment);
               if(exit_ok)
                  printf("("+MASK_MANUAL+")" + Symbol() + " " + comment);
              }
           }
        }

      //-----------------------------------------------------------------------
      if(sparam == BtnTradeWithStopLoss)
        {
         bool is_30_percent_loss = (BALANCE*0.3 + ACC_PROFIT < 0);
         if(is_30_percent_loss)
           {
            Alert("DISABLE TRADE 3x10% (Opened: " + (string)(global_10percent_count_buy + global_10percent_count_sel) + "L), Profit: " + (string)(int)ACC_PROFIT
                  + "$ (" + format_double_to_string(ACC_PROFIT/INIT_EQUITY * 100, 1) + "%)");

            return;
           }

         double close_d1 = iClose(Symbol(), PERIOD_D1, 1);
         double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         double cur_price = (bid+ask)/2;
         string all_trend = getTrendFiltering(Symbol());

         double volume_1percent = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, INIT_EQUITY*0.01);
         string find_trend = sparam == BtnBuyNow1Per ? TREND_BUY : TREND_SEL;
         double tp_price_buy = 0;
         double amp_tp_buy = 0;
         double tp_price_sel = 0;
         double amp_tp_sel = 0;
           {
            tp_price_buy = get_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);
            amp_tp_buy = tp_price_buy - cur_price;
           }
           {
            tp_price_sel = get_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
            amp_tp_sel = cur_price - tp_price_sel;
           }

         double risk_10percent = INIT_EQUITY*0.1;
         double volume = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, risk_10percent);

         string lblTrade10percent = "";
         lblTrade10percent += "   AmpSL: " + (string)FIXED_SL_AMP + "$        Vol(10%): " + (string)volume + "lot\n";
         lblTrade10percent += "   TPBuy: " + format_double_to_string(tp_price_buy, Digits-1);
         lblTrade10percent += "   AmpTpBuy: " + format_double_to_string(amp_tp_buy, Digits-1) + "\n";
         lblTrade10percent += "   TPSell: " + format_double_to_string(tp_price_sel, Digits-1);
         lblTrade10percent += "   AmpTpSell: " + format_double_to_string(amp_tp_sel, Digits-1) + "\n";

         string msg = " TradeWithStopLoss " + " " + Symbol()
                      + "\n    Count 10%:" + (string)(global_10percent_count_buy+global_10percent_count_sel)
                      + "\n    B:" + (string)global_10percent_count_buy + " min_buy: " + (string) get_min_buy_price(Symbol()) +  "  (" + (string)global_min_entry_buy + " ~ " + (string)global_max_entry_buy + ")"
                      + "\n    S:" + (string)global_10percent_count_sel + " max_sell: " + (string) get_max_sel_price(Symbol()) + "  (" + (string)global_max_entry_sel + " ~ " + (string)global_max_entry_sel + ")"
                      + "\n"
                      + "\n    Count 1%:" + (string)(global_bot_count_manual_buy+global_bot_count_manual_sel)
                      + "\n    B:" + (string)global_bot_count_manual_buy + " min_buy: " + (string) global_min_entry_manual_buy
                      + "\n    S:" + (string)global_bot_count_manual_sel + " max_sell: " + (string) global_max_entry_manual_sel
                      + "\n\n"
                      + lblTrade10percent + "\n";

         msg += getTrendFiltering(Symbol())+ "\n\n";
         msg += "    (YES) BUY " + (string)volume+" (lot) AmpSL: " + format_double_to_string(FIXED_SL_AMP, Digits-1) + "$ "+(INIT_TREND_TODAY == TREND_BUY ? "= MACD(H4)" : "")+"\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, TREND_BUY) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, TREND_BUY) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, TREND_BUY) + "\n\n";
         msg += "    (NO) SELL " + (string)volume+" (lot) AmpSL: " + format_double_to_string(FIXED_SL_AMP, Digits-1) + "$ "+(INIT_TREND_TODAY == TREND_SEL ? "= MACD(H4)" : "")+"\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, TREND_SEL) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, TREND_SEL) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, TREND_SEL) + "\n";
         if(is_stop_trading_by_potential_loss())
            msg += "(STOP_TRADE) By POTENTIAL_LOSS:" + (string)(int)GLOBAL_POTENTIAL_LOSS + "$ ("+ format_double_to_string(GLOBAL_POTENTIAL_LOSS/BALANCE*100, 1) + "%)";

         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);

         int OP_TYPE = -1;
         int count = 1;
         string selected_trend = "";
         double tp_price = 0;
         if(result == IDYES)
           {
            if(pass_pre_check_before_trade(TREND_BUY) == false)
               return;

            if(is_same_symbol(all_trend, TREND_BUY) == false)
              {
               StringReplace(all_trend, "\n", "");
               Alert("(NOT_ALLOW_BUY) ALL_TREND :\n" + all_trend);
               return;
              }

            OP_TYPE = OP_BUY;
            tp_price = tp_price_buy;
            selected_trend = TREND_BUY;
            count += global_10percent_count_buy;
           }
         if(result == IDNO)
           {
            if(pass_pre_check_before_trade(TREND_SEL) == false)
               return;
            if(is_same_symbol(all_trend, TREND_SEL) == false)
              {
               StringReplace(all_trend, "\n", "");
               Alert("(NOT_ALLOW_SELL) ALL_TREND :\n" + all_trend);
               return;
              }

            OP_TYPE = OP_SELL;
            tp_price = tp_price_sel;
            selected_trend = TREND_SEL;
            count += global_10percent_count_sel;
           }

         if(result == IDCANCEL)
            return;

         if(is_stop_trading_by_potential_loss())
           {
            ResetStartPrice();
            return;
           }

         if(OP_TYPE != -1 && selected_trend != "")
           {
            string comment = create_comment(MASK_10PER, selected_trend, count);
            tp_price = 0;
            bool exit_ok = Open_Position(Symbol(), OP_TYPE, volume, 0.0, tp_price, comment);
            if(exit_ok)
               Alert(MASK_10PER + Symbol() + " " + comment);
           }
        }
      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();
      Draw_Buttons();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_tp_by_fixed_sl_amp(string symbol, string TREND)
  {
   if(TREND == TREND_BUY)
      return iLow(symbol, PERIOD_D1, 0)  + FIXED_SL_AMP*3;
   if(TREND == TREND_SEL)
      return iHigh(symbol, PERIOD_D1, 0) - FIXED_SL_AMP*3;

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_tp_best(string symbol, string TREND)
  {
   if(TREND == TREND_BUY)
      return MathMin(iLow(Symbol(), PERIOD_W1, 1), iLow(Symbol(), PERIOD_W1, 0)) + MathMax(avg_candle_w1, FIXED_SL_AMP*3);
   if(TREND == TREND_SEL)
      return MathMax(iHigh(Symbol(), PERIOD_W1, 1), iHigh(Symbol(), PERIOD_W1, 0)) - MathMax(avg_candle_w1, FIXED_SL_AMP*3);

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_And_ProgressiveProfits(string symbol, string TRADING_TREND, double tp_price, string TRADER)
  {
   double old_tp = 0;
   double old_potential_profit = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
              {
               old_tp = OrderTakeProfit();
               if(TRADING_TREND == TREND_BUY)
                  old_potential_profit += calcPotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
               if(TRADING_TREND == TREND_SEL)
                  old_potential_profit += calcPotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
              }


   double new_tp = tp_price;
   if(old_tp != tp_price)
     {
      int count = 0;
      while(true)
        {
         double new_potential_profit = 0;
         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
               if(toLower(symbol) == toLower(OrderSymbol()))
                  if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
                    {
                     if(TRADING_TREND == TREND_BUY)
                        new_potential_profit += calcPotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), new_tp, OrderLots());
                     if(TRADING_TREND == TREND_SEL)
                        new_potential_profit += calcPotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), new_tp, OrderLots());
                    }

         if(new_potential_profit > old_potential_profit)
            break;

         if(TRADING_TREND == TREND_BUY)
            new_tp += AMP_DC;
         if(TRADING_TREND == TREND_SEL)
            new_tp -= AMP_DC;

         count += 1;
         if(count> 100)
            return;
        }
     }

   double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
   int slippage = (int)MathAbs(ASK-BID);

   datetime time_draw = iTime(symbol, PERIOD_H4, 0);
   color lineColor = TRADING_TREND == TREND_BUY ? clrBlue : clrFireBrick;
   create_trend_line(TRADER + TRADING_TREND + "_TP", time_draw, new_tp, time_draw + TIME_OF_ONE_H4_CANDLE, new_tp, lineColor, STYLE_SOLID, 3);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
              {
               double cur_tp = OrderTakeProfit();
               double opend_price = OrderOpenPrice();

               if(cur_tp != tp_price)
                 {
                  double price = (OrderType() == OP_BUY) ? ASK : (OrderType() == OP_SELL) ? BID : NormalizeDouble((ASK+BID/2), Digits);

                  int ross=0, demm = 1;
                  while(ross<=0 && demm<20)
                    {
                     ross=OrderModify(OrderTicket(),price,OrderStopLoss(),new_tp,0,clrBlue);
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
void ModifyTp_ExceptLock(string symbol, string TRADING_TREND, double tp_price, string TRADER)
  {
   double potential_profit = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
            if(StringFind(toLower(OrderComment()), toLower(TRADER)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderTakeProfit() != tp_price)
                     if(is_same_symbol(OrderComment(), LOCK) == false &&
                        is_same_symbol(OrderComment(), MASK_HEDG) == false &&
                        is_same_symbol(OrderComment(), "B2S") == false &&
                        is_same_symbol(OrderComment(), "S2B") == false)
                       {
                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);
                        if(OrderType() == OP_BUY)
                          {
                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                           potential_profit += calcPotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), tp_price, OrderLots());
                          }
                        if(OrderType() == OP_SELL)
                          {
                           price = SymbolInfoDouble(symbol, SYMBOL_BID);
                           potential_profit += calcPotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), tp_price, OrderLots());
                          }

                        int ross=0, demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0,clrBlue);
                           demm++;
                           Sleep(100);
                          }
                       }
     } //for

   if(potential_profit < risk_1_Percent_Account_Balance())
     {
        {
         if(TRADING_TREND == TREND_BUY)
            tp_price += AMP_DC;
         if(TRADING_TREND == TREND_SEL)
            tp_price -= AMP_DC;

         ModifyTp_ExceptLock(symbol, TRADING_TREND, tp_price, TRADER);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ToTPPrice(string symbol, double best_tpprice, string KEY_TO_CLOSE)
  {
   bool has_modify = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && is_same_symbol(OrderComment(), KEY_TO_CLOSE))
           {
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            double price = bid;
            double close_now_price = bid;
            bool close_now = false;
            if(OrderType() == OP_BUY)
              {
               price = ask;
               close_now_price = bid;
               if(price > best_tpprice && best_tpprice > 0)
                  close_now = true;
              }
            if(OrderType() == OP_SELL)
              {
               price = bid;
               close_now_price = ask;
               if(price < best_tpprice && best_tpprice > 0)
                  close_now = true;
              }

            int ross=0, demm = 1;
            while(ross<=0 && demm<20)
              {
               if(close_now)
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), close_now_price, (int)MathAbs(ask-bid));
                  if(successful)
                    {
                     ross = 1;
                     has_modify = true;
                    }
                 }
               else
                  ross=OrderModify(OrderTicket(),price,OrderStopLoss(),best_tpprice,0);

               demm++;
               Sleep(100);
              }
           }
     } //for
   if(has_modify)
      SendAlert(symbol, KEY_TO_CLOSE, "ModifyTp_ToTPPrice Ok");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ModifyTp_ToEntry(string symbol, double added_amp_tp, string KEY_TO_CLOSE)
  {
   bool has_modify = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && is_same_symbol(OrderComment(), KEY_TO_CLOSE))
           {
            double tp_price = OrderOpenPrice();
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            double price = bid;
            double close_now_price = bid;
            bool close_now = false;
            if(OrderType() == OP_BUY)
              {
               tp_price += added_amp_tp;
               price = ask;
               close_now_price = bid;
               if(price > tp_price)
                  close_now = true;
              }
            if(OrderType() == OP_SELL)
              {
               tp_price -= added_amp_tp;
               price = bid;
               close_now_price = ask;
               if(price < tp_price)
                  close_now = true;
              }

            int ross=0, demm = 1;
            while(ross<=0 && demm<20)
              {
               if(close_now)
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), close_now_price, (int)MathAbs(ask-bid));
                  if(successful)
                    {
                     ross = 1;
                     has_modify = true;
                     Alert("(CLOSE_NOW) ModifyTp_ToEntry " + (string)OrderTicket() + "   "  + symbol + "   Profit: " + (string)(int) OrderProfit() + "$");
                    }
                 }
               else
                  if((int)tp_price != (int)OrderTakeProfit())
                    {
                     ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0);

                     double potentialProfit = calcPotentialTradeProfit(symbol, OrderType(), OrderOpenPrice(), tp_price, OrderLots());

                     Alert("ModifyTp_ToEntry " + (string)OrderTicket()
                           + "   "  + symbol + "   "  + OrderComment()
                           + "   Profit: " + (string)(int) OrderProfit() + "$"
                           + "   Est: " + (string)(int)potentialProfit + "$");
                    }

               demm++;
               Sleep(100);
              }

           }
     } //for

   if(has_modify)
      SendAlert(symbol, KEY_TO_CLOSE, "ModifyTp_ToEntry Ok");

   return has_modify;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void ModifyTp_ForPotentialProfit(string symbol, int order_type, double added_amp_tp, string KEY_TO_CLOSE, double old_tp_price)
//  {
//   for(int i = OrdersTotal() - 1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//         if(is_same_symbol(OrderSymbol(), symbol))
//            if(is_same_symbol(OrderComment(), KEY_TO_CLOSE))
//               if(OrderType() == order_type)
//                  if(OrderTakeProfit() != old_tp_price)
//                     if(is_same_symbol(OrderComment(), LOCK) == false &&
//                        is_same_symbol(OrderComment(), "B2S") == false &&
//                        is_same_symbol(OrderComment(), "S2B") == false)
//                       {
//                        double tp_price = OrderTakeProfit();
//                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);
//
//                        if(OrderType() == OP_BUY)
//                          {
//                           tp_price += added_amp_tp;
//                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);
//                          }
//                        if(OrderType() == OP_SELL)
//                          {
//                           tp_price -= added_amp_tp;
//                           price = SymbolInfoDouble(symbol, SYMBOL_BID);
//                          }
//
//                        int ross=0, demm = 1;
//                        while(ross<=0 && demm<20)
//                          {
//                           ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0,clrBlue);
//                           demm++;
//                           Sleep(100);
//                          }
//                       }
//     } //for
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void ModifySL(string symbol, string TRADING_TREND, double sl_price, string KEY_TO_CLOSE)
//  {
//   for(int i = OrdersTotal() - 1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//         if(is_same_symbol(OrderSymbol(), symbol))
//            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
//               if(OrderStopLoss() != sl_price)
//                  if(is_same_symbol(OrderComment(), LOCK) == false &&
//                     is_same_symbol(OrderComment(), "B2S") == false &&
//                     is_same_symbol(OrderComment(), "S2B") == false)
//                    {
//                     double price = 0.0;
//                     if(OrderType() == OP_SELL)
//                       {
//                        price = SymbolInfoDouble(symbol, SYMBOL_ASK);
//                        if(price >= OrderOpenPrice())
//                           price = 0.0;
//                       }
//
//                     if(OrderType() == OP_BUY)
//                       {
//                        price = SymbolInfoDouble(symbol, SYMBOL_BID);
//                        if(price <= OrderOpenPrice())
//                           price = 0.0;
//                       }
//
//                     int ross=0, demm = 1;
//                     while(ross<=0 && demm<20)
//                       {
//                        ross=OrderModify(OrderTicket(),price,sl_price,OrderTakeProfit(),0,clrBlue);
//                        demm++;
//                        Sleep(100);
//                       }
//                    }
//     } //for
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePosition(string symbol, int ordertype, string TRADER)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && OrderType() == ordertype)
            if((TRADER == "") || is_same_symbol(OrderComment(), TRADER))
              {
               //Alert("ClosePosition ", symbol, ordertype, TRADER);

               int demm = 1;
               while(demm<20)
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if((OrderType() == OP_BUY) && (is_same_symbol(OrderComment(), TREND_BUY) || (OrderComment() == "" && TRADER == "")))
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                     if(successful)
                        return true;
                    }

                  if((OrderType() == OP_SELL) && (is_same_symbol(OrderComment(), TREND_SEL) || (OrderComment() == "" && TRADER == "")))
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                     if(successful)
                        return true;
                    }

                  if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                    {
                     bool successful=OrderDelete(OrderTicket());
                     if(successful)
                        return true;
                    }

                  demm++;
                  Sleep(100);
                 }
              }
     } //for

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositivePosition(string symbol, string TRADING_TREND)
  {
   double min_profit = minProfit();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderProfit() > min_profit))
            if((TRADING_TREND == "") || (OrderComment() == "") || is_same_symbol(OrderComment(), TRADING_TREND))
              {
               int demm = 1;
               while(demm<20)
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if(OrderType() == OP_BUY)
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                     if(successful)
                        break;
                    }

                  if(OrderType() == OP_SELL)
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                     if(successful)
                        break;
                    }

                  demm++;
                  Sleep(100);
                 }
              }
     } //for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string symbol, string trend, string message)
  {
   return;

   if(is_main_control_screen() == false)
      return;

   if(ALERT_MSG_TIME == iTime(symbol, PERIOD_H4, 0))
      return;
   ALERT_MSG_TIME = iTime(symbol, PERIOD_H4, 0);

   Alert(get_vntime(), message);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol, string trend, string message, bool is_send_now)
  {
   if(is_main_control_screen() == false)
      return;

   if(is_send_now == false)
     {
      string date_time = time2string(iTime(symbol, PERIOD_H4, 0));
      string key = symbol + "_" + trend + "_" + date_time;

      string send_telegram_today = ReadFileContent(FILE_NAME_SEND_MSG);
      if(StringFind(send_telegram_today, key) >= 0)
         return;
      WriteFileContent(FILE_NAME_SEND_MSG, "Telegram: " + key + " " + symbol + " " + trend + " " + message + "; " + send_telegram_today);
     }

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   string str_cur_price = " price:" + (string) price;

   Alert(get_vntime(), message + str_cur_price);

   if(IsTesting())
      return;

   string new_message = get_vntime() + message + str_cur_price;

   StringReplace(new_message, " ", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "_", "%20");
   StringReplace(new_message, " ", "%20");

   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s", telegram_url, botToken, chatId_duydk, new_message);

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
string get_acc_profit_percent()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   string percent = AppendSpaces(format_double_to_string(ACC_PROFIT, 2), 7, false) + "$ (" + AppendSpaces(format_double_to_string(ACC_PROFIT/BALANCE * 100, 1), 5, false) + "%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename, string symbol, string TRADING_TREND_KEY)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(symbol, TRADING_TREND_KEY);
   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string symbol, string TRADING_TREND_KEY, string note_stoploss = "", ulong ticket = 0, string note = "")
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(symbol, TRADING_TREND_KEY);

   WriteFileContent(filename, key);
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
void WriteFileContent(string file_name, string content)
  {
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      //string file_contents = CutString(content);

      FileWriteString(fileHandle, content);
      FileClose(fileHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void saveAutoTrade()
  {
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_BUY", IS_CONTINUE_TRADING_CYCLE_BUY);
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_SEL", IS_CONTINUE_TRADING_CYCLE_SEL);

   string content = (string) iTime(Symbol(), PERIOD_D1, 0) + "~";
   content += "AUTO_BUY:" + (string) IS_CONTINUE_TRADING_CYCLE_BUY + "~";
   content += "AUTO_SEL:" + (string) IS_CONTINUE_TRADING_CYCLE_SEL + "~";
   content += "WAIT_BUY_10:" + (string) IS_WAITTING_10PER_BUY + "~";
   content += "WAIT_SEL_10:" + (string) IS_WAITTING_10PER_SEL + "~";

   WriteFileContent(FILE_NAME_AUTO_TRADE, content);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadAutoTrade()
  {
   string content = ReadFileContent(FILE_NAME_AUTO_TRADE);
   string cur_time = (string) iTime(Symbol(), PERIOD_D1, 0) + "~";
   string str_auto_buy = "AUTO_BUY:" + (string) true + "~";
   string str_auto_sel = "AUTO_SEL:" + (string) true + "~";
   string str_wait_buy10 = "WAIT_BUY_10:" + (string) true + "~";
   string str_wait_sel10 = "WAIT_SEL_10:" + (string) true + "~";

   if(is_same_symbol(content, cur_time))
     {
      IS_CONTINUE_TRADING_CYCLE_BUY = is_same_symbol(content, str_auto_buy);
      IS_CONTINUE_TRADING_CYCLE_SEL = is_same_symbol(content, str_auto_sel);

      IS_WAITTING_10PER_BUY = is_same_symbol(content, str_wait_buy10);
      IS_WAITTING_10PER_SEL = is_same_symbol(content, str_wait_sel10);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int max_lengh = 10000;
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
string create_key(string symbol, string TRADING_TREND_KEY)
  {
   string date_time = time2string(iTime(symbol, PERIOD_H4, 0));
   string key = date_time + ":PERIOD_H4:" + TRADING_TREND_KEY + ":" + symbol +";";
   return key;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_fibo_vol(double cur_max_vol, double fibo)
  {
   double vol = 0.01;
   return NormalizeDouble(vol, 2);

   for(int i = 2; i <= 15; i++)
     {
      vol = NormalizeDouble(vol*fibo, 2);
      if(vol >= cur_max_vol + 0.01)
         return NormalizeDouble(vol, 2);
     }

   if(vol < INIT_VOLUME)
      return INIT_VOLUME;

   return NormalizeDouble(vol, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_fibo_dca(int trade_no)
  {
   double vol = 0.01;
   return NormalizeDouble(vol, 2);

   for(int i = 2; i <= trade_no; i++)
     {
      vol = vol*FIBO_1618;
      if(trade_no >= 15)
         break;
     }

   if(vol < INIT_VOLUME)
      return INIT_VOLUME;

   return NormalizeDouble(vol, 2);
  }

// Function to get the highest and lowest M5 candle times in the current day
void GetHighestLowestM5Times(string symbol, datetime timeStart, datetime timeEnd, int dIndex)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   string vnhig_d1 = "hig_" + time2string(timeStart);
   string vnlow_d1 = "low_" + time2string(timeStart);

   if(Period() <= PERIOD_H4 && !is_sunday(timeStart))
     {
      int i = 0;
      while(true)
        {
         datetime candleTime = iTime(symbol, PERIOD_H1, i);
         if(candleTime < timeStart)
            break;

         if(candleTime >= timeEnd)
           {
            i++;
            continue;
           }

         double high = iHigh(symbol, PERIOD_H1, i);
         double low = iLow(symbol, PERIOD_H1, i);

         if(highestPrice == -1 || high > highestPrice)
           {
            highestPrice = high;
            highestTime = candleTime;
           }

         if(lowestPrice == -1 || low < lowestPrice)
           {
            lowestPrice = low;
            lowestTime = candleTime;
           }

         i++;
        }

      bool is_up = lowestTime < highestTime;
      create_lable(vnhig_d1, dIndex==0 ? iTime(symbol, PERIOD_D1, 0) : timeStart, highestPrice,(is_up==true ? "" + format_double_to_string(highestPrice-lowestPrice, Digits - 2) + "" : ""), is_up==true ? TREND_BUY:"", true, 6);   // convert2vntime(highestTime)
      create_lable(vnlow_d1, dIndex==0 ? iTime(symbol, PERIOD_D1, 0) : timeStart, lowestPrice, (is_up==false? "" + format_double_to_string(lowestPrice-highestPrice, Digits - 2) + "" : ""),  is_up==false? TREND_SEL:"", true, 6);  // convert2vntime(lowestTime)
     }
   else
     {
      ObjectDelete(0, vnhig_d1);
      ObjectDelete(0, vnlow_d1);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendByLowHigTimes(string symbol, datetime timeStart, datetime timeEnd, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   int i = 0;
   while(true)
     {
      datetime candleTime = iTime(symbol, TIMEFRAME, i);
      if(candleTime < timeStart)
         break;

      if(candleTime >= timeEnd)
        {
         i++;
         continue;
        }

      double high = iHigh(symbol, TIMEFRAME, i);
      double low = iLow(symbol, TIMEFRAME, i);

      if(highestPrice == -1 || high > highestPrice)
        {
         highestPrice = high;
         highestTime = candleTime;
        }

      if(lowestPrice == -1 || low < lowestPrice)
        {
         lowestPrice = low;
         lowestTime = candleTime;
        }

      i++;
     }

   if(lowestTime == 0 && highestTime == 0)
      return "";

   bool is_up = lowestTime < highestTime;

   if(is_up)
      return TREND_BUY;

   return TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe,
      string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero
      , string &trend_vector_macd, string &trend_vector_signal, string &trend_macd_note)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";
   trend_vector_macd = "";
   trend_vector_signal = "";
   trend_macd_note = "";

   double macd_0=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,0);
   double macd_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,1);
   double sign_0=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,0);
   double sign_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,1);

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_by_macd = TREND_BUY;
   if(macd_0 <= 0 && sign_0 <= 0)
      trend_by_macd = TREND_SEL;

   if(macd_0 >= sign_0)
      trend_mac_vs_signal = TREND_BUY;
   if(macd_0 <= sign_0)
      trend_mac_vs_signal = TREND_SEL;

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_mac_vs_zero = TREND_BUY;
   if(macd_0 <= 0 && sign_0 <= 0)
      trend_mac_vs_zero = TREND_SEL;

   if(macd_0 >= macd_1)
      trend_vector_macd = TREND_BUY;
   if(macd_0 <= macd_1)
      trend_vector_macd = TREND_SEL;

   if(sign_0 >= sign_1)
      trend_vector_signal = TREND_BUY;
   if(sign_0 <= sign_1)
      trend_vector_signal = TREND_SEL;

   if(macd_1 <= 0 && macd_0 >= 0)
      trend_macd_note += "_st2"+ TREND_BUY;
   if(macd_1 >= 0 && macd_0 <= 0)
      trend_macd_note += "_st2"+ TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_macd(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   double macd_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,1);
   double macd_2=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,2);

   double sign_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,1);
   double sign_2=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,2);

   if(macd_1 > 0 && 0 > macd_2 && macd_1 > sign_1 && sign_1 > sign_2)
      return TREND_BUY;

   if(macd_1 < 0 && 0 < macd_2 && macd_1 < sign_1 && sign_1 < sign_2)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trend_shift(string symbol, string NEW_TREND)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double lowest = 0.0, higest = 0.0;
   for(int idx = 1; idx <= 55; idx++)
     {
      double close = iClose(symbol, PERIOD_H4, idx);
      if((idx == 0) || (lowest > close))
         lowest = close;
      if((idx == 0) || (higest < close))
         higest = close;
     }

   if((NEW_TREND == TREND_BUY) && (higest - AMP_TP*2 < price))
      return false;

   if((NEW_TREND == TREND_SEL) && (lowest + AMP_TP*2 > price))
      return false;

   double PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   if(EQUITY < BALANCE/2)
      return false;

   if(PROFIT < 0 && MathAbs(PROFIT) < EQUITY/3)
      return false;

// Cần chờ tối thiểu 1 giờ sau mỗi lần chuyển đổi để tránh tạo GAP sụt giảm tài khoản.
//bool pass_time_check = false;
//datetime currentTime = TimeCurrent();
//datetime timeGap = currentTime - last_trend_shift_time;
//if(timeGap < 1 * 60 * 60)
//   return false;

   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H4, NEW_TREND, 3, 2, 3))
      return true;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, NEW_TREND, 3, 2, 3))
      return true;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_M15, NEW_TREND, 3, 2, 3))
      return true;

   return false;
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
bool passes_time_between_trader()
  {
   int waiting_minus = 5;
   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - global_last_open_time;
   if(timeGap >= waiting_minus * 60)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_waiting_time_dca(datetime last_open_trade_time, int count_possion)
  {
   return true;

   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS + MINUTES_BETWEEN_ORDER*count_possion;

   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_open_trade_time;
   if(timeGap >= waiting_minus * 60)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int remaining_time_to_dca(datetime last_open_trade_time, int waiting_minus)
  {
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_open_trade_time;
   return (int)(waiting_minus - timeGap/60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string str_remaining_time(datetime last_open_trade_time, int count_possion)
  {
   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS + MINUTES_BETWEEN_ORDER*count_possion;

   int remain = remaining_time_to_dca(last_open_trade_time, waiting_minus);
   datetime currentTime = TimeCurrent();
   datetime newTime = currentTime + remain * 60;

   if(remain < 0)
      remain = 0;

   string value = "  " + (string)remain  + "p";

   return value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma7_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend)
  {
   string trend_m5_ma0710 = "";
   string trend_m5_ma1020 = "";
   string trend_m5_ma2050 = "";
   string trend_m5_C1ma10 = "";
   string trend_m5_ma50d1 = "";
   bool is_insign_m5 = false;
   get_trend_by_ma_seq71020_steadily(symbol, timeframe, trend_m5_ma0710, trend_m5_ma1020, trend_m5_ma2050, trend_m5_C1ma10, trend_m5_ma50d1, is_insign_m5);

   string trend_reverse = get_trend_reverse(find_trend);

   if(trend_reverse == trend_m5_ma2050)
      if(trend_m5_ma0710 == trend_m5_ma1020 && trend_m5_ma1020 == trend_m5_ma2050)
         return false;

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_m5_ma0710 = "";
   string trend_m5_ma1020 = "";
   string trend_m5_ma2050 = "";
   string trend_m5_C1ma10 = "";
   string trend_m5_ma50d1 = "";
   bool is_insign_m5 = false;
   get_trend_by_ma_seq71020_steadily(symbol, timeframe, trend_m5_ma0710, trend_m5_ma1020, trend_m5_ma2050, trend_m5_C1ma10, trend_m5_ma50d1, is_insign_m5);


   if(trend_m5_ma1020 == trend_m5_ma2050 && trend_m5_ma1020 == trend_m5_ma2050)
      return trend_m5_ma2050;

   return "";
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
bool is_allow_take_profit_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && red_D <= 20 && black_K <= 20)
      return true;

   if(find_trend == TREND_SEL && red_D >= 80 && black_K >= 80)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string check_stoch_before_trade(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   string msg = "";

   double h4_bla_K_5_3_2 = iStochastic(symbol,TIMEFRAME,5,3,2,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_5_3_2 = iStochastic(symbol,TIMEFRAME,5,3,2,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double h4_bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   if(find_trend == TREND_BUY)
      if(h4_bla_K_5_3_2 >= 80 || h4_red_D_5_3_2 >= 80 || h4_bla_K_13_5_5 >= 80 || h4_red_D_13_5_5 >= 80)
         msg = "BUY is not allowed. Stoch " + timeframe_to_string(TIMEFRAME) + " is in overbought.";

   if(find_trend == TREND_SEL)
      if(h4_bla_K_5_3_2 <= 20 || h4_red_D_5_3_2 <= 20 || h4_bla_K_13_5_5 <= 20 || h4_red_D_13_5_5 <= 20)
         msg = "SELL is not allowed. Stoch " + timeframe_to_string(TIMEFRAME) + " is in oversold.";

   return msg;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string wait_trade_by_stoch(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
//  {
////Scalping (giao dịch lướt sóng)       : %K period =  5, %D period = 3, Slowing = 2
////Swing trading (giao dịch trung hạn)  : %K period = 13, %D period = 5, Slowing = 5
////Position trading (giao dịch dài hạn) : %K period = 21, %D period = 7, Slowing = 7
//   double h4_bla_K_5_3_2  = iStochastic(symbol,TIMEFRAME, 5,3,2,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
//   double h4_red_D_5_3_2  = iStochastic(symbol,TIMEFRAME, 5,3,2,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//   double h4_bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
//   double h4_red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//   double h4_bla_K_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
//   double h4_red_D_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//
//   if(
//      (h4_bla_K_5_3_2 <= 20 && h4_red_D_5_3_2 <= 20)
//      || (h4_bla_K_13_5_5 <= 20 && h4_red_D_13_5_5 <= 20)
//      || (h4_bla_K_21_7_7 <= 20 && h4_red_D_21_7_7 <= 20)
//   )
//      return TREND_BUY;
//
//   if(
//      (h4_bla_K_5_3_2 >= 80 && h4_red_D_5_3_2 >= 80)
//      || (h4_bla_K_13_5_5 >= 80 && h4_red_D_13_5_5 >= 80)
//      || (h4_bla_K_21_7_7 >= 80 && h4_red_D_21_7_7 >= 80)
//   )
//      return TREND_SEL;
//
//   return "";
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_when_overbought_or_oversold_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double bla_K__5_3_2 = iStochastic(symbol,TIMEFRAME, 5,3,2,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D__5_3_2 = iStochastic(symbol,TIMEFRAME, 5,3,2,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   string result = "_";

   if(
      (bla_K__5_3_2 <= 20 || red_D__5_3_2 <= 20) ||
      (bla_K_13_5_5 <= 20 || red_D_13_5_5 <= 20) ||
      (bla_K_21_7_7 <= 20 || red_D_21_7_7 <= 20)
   )
      result += TREND_BUY + "_";

   if(
      (bla_K__5_3_2 >= 80 || red_D__5_3_2 >= 80) ||
      (bla_K_13_5_5 >= 80 || red_D_13_5_5 >= 80) ||
      (bla_K_21_7_7 >= 80 || red_D_21_7_7 >= 80)
   )
      result += TREND_SEL + "_";

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_manual_trade(string comment)
  {
   if(is_same_symbol(comment, MASK_MANUAL))
      return true;

   if(comment == "")
      return true;

   return false;
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
string appendZero100(int trade_no)
  {
   if(trade_no < 10)
      return "00" + (string) trade_no;

   if(trade_no < 100)
      return "0" + (string) trade_no;

   return (string) trade_no;
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
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int maLength = MathMax(ma_index_6, ma_index_9) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_6 = cal_MA(closePrices, ma_index_6, 1);
   double ma_9 = cal_MA(closePrices, ma_index_9, 1);

   if(ma_6 > ma_9)
      return TREND_BUY;

   if(ma_6 < ma_9)
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
string get_group_value(string comment, string str_start = "[G", string str_end = "]")
  {
   int startPos = StringFind(comment, str_start);
   int endPos = StringFind(comment, str_end, startPos);
   string result = "";

   if(startPos != -1 && endPos != -1)
      result = StringSubstr(comment, startPos, endPos - startPos + 1);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_group_name()
  {
   datetime VnTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(VnTime, time_struct);

   return "[G"
          + (string)time_struct.day
          + (string)time_struct.hour
          + (string)time_struct.min
          + "]";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_ticket_key(ulong ticket)
  {
   string key = "";

   if(ticket > 0)
     {
      key = "000" + (string)(ticket);
      int length = StringLen(key);

      string lastThree = StringSubstr(key, length - 3, 3);

      key = "[K" + lastThree+ "]";
     }

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today = (string)time;
   StringReplace(today, " ", "");
   StringReplace(today, "000000", "");
   StringReplace(today, "0000", "");
   StringReplace(today, "00:00:00", "");
   StringReplace(today, "00:00", "");

   return today;
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
string Append(double inputString, int totalLength = 6)
  {
   return AppendSpaces((string) inputString, totalLength);
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
string format_double_to_string(double number, int digits = 5)
  {
   string numberString = (string) number;
   int dotIndex = StringFind(numberString, ".");
   if(dotIndex >= 0)
     {
      string beforeDot = StringSubstr(numberString, 0, dotIndex);
      string afterDot = StringSubstr(numberString, dotIndex + 1);
      afterDot = StringSubstr(afterDot, 0, digits); // chỉ lấy digits chữ số đầu tiên sau dấu chấm

      numberString = beforeDot + "." + afterDot;
     }

   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "99999", "9");
   StringReplace(numberString, "99999", "9");
   StringReplace(numberString, "99999", "9");

   dotIndex = StringFind(numberString, ".");
   string afterDot = StringSubstr(numberString, dotIndex + 1);
   if(dotIndex > 0 && StringLen(afterDot) < digits)
      numberString += "0";

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
   if(Period() == PERIOD_M1)
      return "M1";

   if(Period() == PERIOD_M5)
      return "M5";

   if(Period() == PERIOD_M15)
      return "M15";

   if(Period() == PERIOD_M30)
      return "M30";

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
string get_current_timeframe()
  {
   if(Period() == PERIOD_M1)
      return "01";

   if(Period() == PERIOD_M5)
      return "05";

   if(Period() == PERIOD_M15)
      return "15";

   if(Period() == PERIOD_M30)
      return "30";

   if(Period() ==  PERIOD_H1)
      return "1";

   if(Period() ==  PERIOD_H4)
      return "4";

   if(Period() ==  PERIOD_D1)
      return "D";

   if(Period() ==  PERIOD_W1)
      return "W";

   return "??";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_to_string(ENUM_TIMEFRAMES PERIOD_XX)
  {
   if(PERIOD_XX == PERIOD_M1)
      return "M1";

   if(PERIOD_XX == PERIOD_M5)
      return "M5";

   if(PERIOD_XX == PERIOD_M15)
      return "M15";

   if(PERIOD_XX ==  PERIOD_H1)
      return "H1";

   if(PERIOD_XX ==  PERIOD_H4)
      return "H4";

   if(PERIOD_XX ==  PERIOD_D1)
      return "D1";

   if(PERIOD_XX ==  PERIOD_W1)
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
   string vntime = "(" + str_date_time + ")    ";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string convert2vntime(datetime time)
  {
// Time difference between UTC and Vietnam Time is +7 hours
   int timeOffset = 7 * 3600; // 7 hours in seconds

// Add the offset to the given time
   datetime vietnamTime = time + timeOffset;

   string str_date_time = TimeToString(vietnamTime, TIME_MINUTES);

   return str_date_time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool must_exit_trade_today(string symbol, string TREND)
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime timeStruct;
   TimeToStruct(vietnamTime, timeStruct);

   if(timeStruct.hour > 23 || (timeStruct.hour == 23 && timeStruct.min >= 30))
     {
      if(is_allow_take_profit_now_by_stoc(symbol, PERIOD_M15, TREND, 3, 2, 3))
         return true;

      if(is_allow_take_profit_now_by_stoc(symbol, PERIOD_M5,  TREND, 3, 2, 3))
         return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_sunday(datetime timeEnd)
  {
   MqlDateTime vietnamDateTime;
   TimeToStruct(timeEnd, vietnamDateTime);

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week == SUNDAY)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_time_enter_the_market()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(18 <= currentHour && currentHour <= 20)
      return false;

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
      return false;

   if(day_of_week == FRIDAY && currentHour > 22)
      return false;

   if(3 <= currentHour && currentHour <= 5)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_hedging_time()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(22 <= currentHour || currentHour <= 3)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   double                  price_from=0,                   // anchor point price
   datetime                time_to=0,                   // anchor point time
   double                  price_to=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               STYLE_XX=STYLE_SOLID,
   const int               width = 1,
   const bool              ray_left = false,
   const bool              ray_right = false,
   const bool              is_hiden = true
)
  {
   string name_new = name;
   ObjectDelete(0, name);
   if(ray_left)
      time_from = time_to - TIME_OF_ONE_H4_CANDLE * 1000;
   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_XX);
   ObjectSetInteger(0, name_new, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN,      is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_BACK,        is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE,  !is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT,   ray_right); // Bật tính năng "Rời qua phải"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_filled_rectangle(
   const string            name="Rectangle",         // object name
   datetime                time_from=0,              // anchor point time (bottom-left corner)
   double                  price_from=0,             // anchor point price (bottom-left corner)
   datetime                time_to=0,                // anchor point time (top-right corner)
   double                  price_to=0,               // anchor point price (top-right corner)
   const color             clr_fill=clrGray,         // fill color
   const bool              is_draw_border=false,
   const bool              is_fill_color=true
)
  {
   string name_new = name;
   if(is_fill_color)
     {
      ObjectDelete(0, name_new);  // Delete any existing object with the same name
      ObjectCreate(0, name_new, OBJ_RECTANGLE, 0, time_from, price_from, time_to, price_to);
      ObjectSetInteger(0, name_new, OBJPROP_COLOR, clrBlack);         // Set border color
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);      // Set border style to solid
      ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);            // Set hidden property
      ObjectSetInteger(0, name_new, OBJPROP_BACK, true);              // Set background property
      ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE, false);       // Set selectable property
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);      // Set style to solid
      ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_fill);         // Set fill color (this may not work as intended for all objects)
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);                // Setting this to 1 for consistency
     }

   if(is_draw_border)
     {
      create_trend_line(name_new + "_left", time_from, price_from, time_from, price_to, clrGray);
      create_trend_line(name_new + "_righ", time_to, price_from, time_to, price_to, clrGray);
      create_trend_line(name_new + "_top", time_from, price_to, time_to, price_to, clrGray);
      create_trend_line(name_new + "_bottom", time_from, price_from, time_to, price_from, clrGray);
     }
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
   ObjectDelete(0, name);
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
void get_trend_by_ma_seq71020_steadily(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string &trend_ma0710, string &trend_ma1020, string &trend_ma02050, string &trend_C1ma10, string &trend_h4_ma50d1, bool &insign_h4)
  {
   trend_ma0710 = "";
   trend_ma1020 = "";
   trend_ma02050 = "";
   trend_C1ma10 = "";
   trend_h4_ma50d1 = "";

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);


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

   for(int i = 0; i < 1; i++)
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
string get_trend_reverse(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return TREND_SEL;

   if(is_same_symbol(TREND, TREND_SEL))
      return TREND_BUY;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteArrowObjects()
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i);
      if(ObjectType(objectName) == OBJ_ARROW)
         ObjectDelete(0, objectName);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i);
      ObjectDelete(0, objectName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price = 0,
   color                   clrColor = clrBlack
)
  {
   ObjectDelete(0, name);
   datetime time_to=TimeCurrent();                   // anchor point time
   TextCreate(0,name, 0, time_to, price, label, clrColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const string            TRADING_TREND="",
   const bool              trim_text = true,
   const int               font_size=8
)
  {
   ObjectDelete(0, name);
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : TRADING_TREND==TREND_SEL ? clrRed : clrBlack;
   TextCreate(0,name, 0, time_to, price, trim_text ? " " + label : "        " + label, clr_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
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
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_pivot(ENUM_TIMEFRAMES TIMEFRAME, string symbol, int size = 20)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_pivot(symbol, TIMEFRAME, index);
     }
   double tf_amp = total_amp / size;

   return NormalizeDouble(tf_amp, digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_pivot(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int tf_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double tf_hig = iHigh(symbol,  TIMEFRAME, tf_index);
   double tf_low = iLow(symbol,   TIMEFRAME, tf_index);
   double tf_clo = iClose(symbol, TIMEFRAME, tf_index);

   double w_pivot    = format_double((tf_hig + tf_low + tf_clo) / 3, digits);
   double tf_s1    = format_double((2 * w_pivot) - tf_hig, digits);
   double tf_s2    = format_double(w_pivot - (tf_hig - tf_low), digits);
   double tf_s3    = format_double(tf_low - 2 * (tf_hig - w_pivot), digits);
   double tf_r1    = format_double((2 * w_pivot) - tf_low, digits);
   double tf_r2    = format_double(w_pivot + (tf_hig - tf_low), digits);
   double tf_r3    = format_double(tf_hig + 2 * (w_pivot - tf_low), digits);

   double tf_amp = MathAbs(tf_s3 - tf_s2)
                   + MathAbs(tf_s2 - tf_s1)
                   + MathAbs(tf_s1 - w_pivot)
                   + MathAbs(w_pivot - tf_r1)
                   + MathAbs(tf_r1 - tf_r2)
                   + MathAbs(tf_r2 - tf_r3);

   tf_amp = format_double(tf_amp / 6, digits);

   return NormalizeDouble(tf_amp, digits);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, START_TRADE_LINE);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isDragging)
     {
      double newPrice = NormalizeDouble(WindowPriceOnDropped(), Digits);
      if(newPrice > 0)
        {
         ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, newPrice);

         INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
         Print("OnTick START_TRADE_LINE "  + (string) INIT_START_PRICE);
         GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
        }
     }

   OnTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteAvgAmpToFile()
  {
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

   /*
      (.*)(W1)(.*)(D1)(.*)(H4)(.*)(H1)(.*)
      if(is_same_symbol(symbol, "\1")){amp_w1 = \3;amp_d1 = \5;amp_h4 = \7;amp_h1 = \9;return;}
   */

//XAUUSD W1    57.145   D1    21.409   H4    9.345 H1    6.118 M15    4.136   M5    2.763;
//XAUUSD W1    57.145   D1    21.409   H4    8.216 H1    1.132 M15    0.187   M5    0.047;

   string file_name = "AvgAmp.txt";
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
                                + "\t" + "W1: " + (string) CalculateAverageCandleHeight(PERIOD_W1, symbol, 20)
                                + "\t" + "D1: " + (string) CalculateAverageCandleHeight(PERIOD_D1, symbol, 60)
                                + "\t" + "H4: " + (string) CalculateAverageCandleHeight(PERIOD_H4, symbol, 360)
                                + "\t" + "H1: " + (string) CalculateAverageCandleHeight(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) CalculateAverageCandleHeight(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) CalculateAverageCandleHeight(PERIOD_M5, symbol, 720)
                                + ";\n";

         FileWriteString(fileHandle, file_contents);
        }
      FileClose(fileHandle);
     }

//XAUUSD W1    32.289   D1    10.591   H4    4.677 H1    3.061 M15    2.067   M5    1.382;
//XAUUSD W1    28.11    D1    10.591   H4    4.107 H1    0.566 M15    0.093   M5    0.024;

   file_name = "AvgPivot.txt";
   fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
                                + "\t" + "W1: " + (string) calc_avg_pivot(PERIOD_W1, symbol, 20)
                                + "\t" + "D1: " + (string) calc_avg_pivot(PERIOD_D1, symbol, 60)
                                + "\t" + "H4: " + (string) calc_avg_pivot(PERIOD_H4, symbol, 360)
                                + "\t" + "H1: " + (string) calc_avg_pivot(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) calc_avg_pivot(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) calc_avg_pivot(PERIOD_M5, symbol, 720)
                                + ";\n";

         FileWriteString(fileHandle, file_contents);
        }
      FileClose(fileHandle);
     }

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size=8, int sub_window = 0)
  {
   long chart_id=0;
   ObjectDelete(chart_id, objName);
   ResetLastError();
   if(!ObjectCreate(chart_id, objName, OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

   ObjectSetString(chart_id,  objName, OBJPROP_TEXT, text);
   ObjectSetInteger(chart_id, objName, OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_id, objName, OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_id, objName, OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_id, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_id, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id, objName, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_id, objName, OBJPROP_COLOR, clrTextColor);
   ObjectSetInteger(chart_id, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(chart_id, objName, OBJPROP_BORDER_COLOR, clrSilver);
   ObjectSetInteger(chart_id, objName, OBJPROP_BACK, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_STATE, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_SELECTED, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_HIDDEN, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_ZORDER, 999);

   return(true);
  }
//+-----------------------------------------------------------------+
//| Creates Label object on the chart

//| int Yt[3]= {50, 350, 200}, Xt[3]= {110, 110, 110};
//| color textColor=White;
//| ObjectCreateEx("_Benefit_t1_body", Yt[0]-30, Xt[0]-5, 23, 0, true);
//| ObjectSetText("_Benefit_t1_body", "ggg", 110, "Webdings", C'62,62,62'); //Òåëî òàáëèöû áàåâ
//| ObjectCreateEx("_Benefit_t1_Header", Yt[0]-25, Xt[0]+110, 23, 0);
//| ObjectSetText("_Benefit_t1_Header", "BUY-SIDE", 16, "Dungeon", White); //Çàãîëîâîê Buy
//| ObjectCreateEx("_Benefit_t1_1_1", Yt[0], Xt[0], 23, 0);
//| ObjectSetText("_Benefit_t1_1_1", "Orders: "+DoubleToStr(buys, 0), 10, "Courier New", textColor);
//+-----------------------------------------------------------------+
void ObjectCreateEx(string objname,int YOffset, int XOffset=0, string lable="Text", color textColor=White,bool background=false)
  {
   int objType=23, corner=0;
   bool needNUL=false;
   if(ObjectFind(objname)==-1)
     {
      needNUL=true;
      ObjectCreate(objname,objType,0,0,0,0,0);
     }

   ObjectSet(objname,103,YOffset);
   ObjectSet(objname,102,XOffset);
   ObjectSet(objname,101,corner);
   ObjectSet(objname, OBJPROP_BACK, background);
   if(needNUL)
      ObjectSetText(objname,"",14,"Tahoma",Gray);

   ObjectSetText(objname, lable, 10, "Courier New", textColor);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPotentialTradeProfit(string symbol, int orderType, double orderOpenPrice, double orderTakeProfitPrice, double orderLots)
  {
   if(orderTakeProfitPrice == 0)
     {
      if(orderType == OP_BUY)
         orderTakeProfitPrice = get_tp_by_fixed_sl_amp(symbol, TREND_BUY);

      if(orderType == OP_SELL)
         orderTakeProfitPrice = get_tp_by_fixed_sl_amp(symbol, TREND_SEL);
     }

   double   tradeTickValuePerLot    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);  //Loss/Gain for a 1 tick move with 1 lot
   double   tickValueBasedOnLots    = tradeTickValuePerLot * orderLots;
   double   priceDifference         = MathAbs(orderOpenPrice - orderTakeProfitPrice);
   int      pointsDifference        = (int)(priceDifference / Point);
   double   potentialProfit         = tickValueBasedOnLots * pointsDifference;

   if(orderType==OP_BUY)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? potentialProfit : -potentialProfit;

   if(orderType==OP_SELL)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? -potentialProfit : potentialProfit;

   return NormalizeDouble(potentialProfit, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_best_entry_for_wait(string TREND, double best_cur_entry)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return MathMin(global_min_close_heiken, best_cur_entry);

   if(is_same_symbol(TREND, TREND_SEL))
      return MathMax(global_max_close_heiken, best_cur_entry);

   return best_cur_entry;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_name()
  {
   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_manually(string TREND)
  {
   string name = getShortName(TREND);
   string trader_name = "{^" + name + "^}_";
   return trader_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createLable(string header, string trend)
  {
   string str = getShortName(trend);
   if(str == "")
      return "";

   return header + " " + str;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createLable2(string header, string lalbe)
  {
   if(lalbe == " " || lalbe == "")
      return "";

   return header + " " + lalbe;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortName(string trend)
  {
   if(is_same_symbol(trend, TREND_BUY))
      return "B";

   if(is_same_symbol(trend, TREND_SEL))
      return  "S";

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getColorByTrend(string trend, color clrDefault = clrNONE)
  {
   if(is_same_symbol(trend, TREND_BUY))
      return clrBlue;

   if(is_same_symbol(trend, TREND_SEL))
      return  clrRed;

   return clrDefault;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortStoc(string trend_over_bs_by_stoc)
  {
   string lblStoc = (is_same_symbol(trend_over_bs_by_stoc, TREND_BUY) ? "20" : "") + " " + (is_same_symbol(trend_over_bs_by_stoc, TREND_SEL) ? "80" : "");

   StringTrimLeft(lblStoc);
   StringTrimRight(lblStoc);

   if(lblStoc == " " || lblStoc == "" || lblStoc == "20 80")
      lblStoc = "";

   return lblStoc;
  }

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

      CandleData candle(time, open, high, low, close, trend, 0, 0, "TODO", 0, "");
      candleArray[index] = candle;
     }


   for(int index = length + 3; index >= 0; index--)
     {
      CandleData cancle_i = candleArray[index];

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(cancle_i.trend_heiken == candleArray[j].trend_heiken)
            count_trend += 1;
         else
            break;
        }

      candleArray[index].count_heiken = count_trend;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15, bool is_calc_ma10 = true)
  {
   ArrayResize(candleArray, length+5);
     {
      datetime pre_HaTime = iTime(symbol, TIME_FRAME, length+4);
      double pre_HaOpen = iOpen(symbol, TIME_FRAME, length+4);
      double pre_HaHigh = iHigh(symbol, TIME_FRAME, length+4);
      double pre_HaLow = iLow(symbol, TIME_FRAME, length+4);
      double pre_HaClose = iClose(symbol, TIME_FRAME, length+4);
      string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

      CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0, 0, "", 0, "");
      candleArray[length+4] = candle;
     }

   for(int index = length + 3; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen  = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen, haClose), iHigh(symbol, TIME_FRAME, index));
      double haLow   = MathMin(MathMin(haOpen, haClose),  iLow(symbol, TIME_FRAME, index));
      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_heiken = 1;
      for(int j = index+1; j < length; j++)
        {
         if(haTrend == candleArray[j].trend_heiken)
            count_heiken += 1;
         else
            break;
        }

      CandleData candle_x(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_heiken, 0, "", 0, "");
      candleArray[index] = candle_x;
     }


   if(is_calc_ma10)
     {
      double closePrices[];
      int maLength = length+15;
      ArrayResize(closePrices, maLength);

      for(int i = maLength - 1; i >= 0; i--)
         closePrices[i] = iClose(symbol, TIME_FRAME, i);

      for(int index = ArraySize(candleArray)-2; index >= 0; index--)
        {
         CandleData pre_cancle = candleArray[index+1];
         CandleData cur_cancle = candleArray[index];

         double ma10 = cal_MA(closePrices, 10, index);
         double mid = cur_cancle.close; //(cur_cancle.open + cur_cancle.close + cur_cancle.close)/3;
         string trend_by_ma10 = (mid > ma10) ? TREND_BUY : (mid < ma10) ? TREND_SEL : appendZero100(index);
         string trend_vector_ma10 = pre_cancle.ma10 < ma10 ? TREND_BUY : TREND_SEL;

         int count_ma10 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_by_ma10 == candleArray[j].trend_by_ma10)
               count_ma10 += 1;
            else
               break;
           }

         CandleData candle_x(cur_cancle.time, cur_cancle.open, cur_cancle.high, cur_cancle.low, cur_cancle.close, cur_cancle.trend_heiken
                             , cur_cancle.count_heiken, ma10, trend_by_ma10, count_ma10, trend_vector_ma10);
         candleArray[index] = candle_x;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   return candleArray[candle_index].trend_heiken;
  }
//+------------------------------------------------------------------+
double get_largest_negative(string TRADER)
  {
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name, TRADER))
         return MathAbs(NormalizeDouble(arr_largest_negative_trader_amount[i], 2));
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_largest_negative(string TRADER, double profit)
  {
   if(profit > 0)
      return;

   double found_trader = false;
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name, TRADER))
        {
         found_trader = true;
         if(MathAbs(arr_largest_negative_trader_amount[i]) < MathAbs(profit))
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
        }
     }

   if(found_trader == false)
     {
      for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
        {
         string name = arr_largest_negative_trader_name[i];
         if(name == "" || StringLen(name) < 1)
           {
            arr_largest_negative_trader_name[i] = TRADER;
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double risk_10_percent_by_init_equity()
//  {
//   double dbValueRisk = INIT_EQUITY * dbRiskRatio;
//   double max_risk = INIT_EQUITY*0.1;
//   if(dbValueRisk > max_risk)
//     {
//      Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than " + (string) max_risk + " per order. Too dangerous.");
//      return max_risk;
//     }
//
//   return dbValueRisk;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double minProfit()
  {
   return risk_1_Percent_Account_Balance()*0.1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double risk_10_Percent_Account_Balance()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   return BALANCE*0.1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double risk_1_Percent_Account_Balance()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   return BALANCE*0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment(string TRADER, string TRADING_TREND, int L)
  {
   string result = TRADER + TRADING_TREND + "_" + appendZero100(L);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_L(string TRADER, string trend, string last_comment)
  {
   for(int i = 1; i < 100; i++)
     {
      string comment = create_comment(TRADER, trend, i);
      if(is_same_symbol(last_comment, comment))
         return i;
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvgL15(string symbol, double &amp_w1, double &amp_d1, double &amp_h4, double &amp_grid_L100)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 60;
      amp_d1 = 25;
      amp_h4 = 6.295;
      amp_grid_L100 = 5;
      return;
     }
   if(is_same_symbol(symbol, "XAGUSD"))
     {
      amp_w1 = 1.3;
      amp_d1 = 0.45;
      amp_h4 = 0.2;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USOIL"))
     {
      amp_w1 = 7.182;
      amp_d1 = 1.983;
      amp_h4 = 0.805;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      amp_w1 = 3570.59;
      amp_d1 = 1273.25;
      amp_h4 = 789.1;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USTEC"))
     {
      amp_w1 = 664.39;
      amp_d1 = 199.95;
      amp_h4 = 81.16;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US30"))
     {
      amp_w1 = 1066.8;
      amp_d1 = 308.8;
      amp_h4 = 119.5;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US500"))
     {
      amp_w1 = 154.5;
      amp_d1 = 43.3;
      amp_h4 = 16.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "DE30"))
     {
      amp_w1 = 530.6;
      amp_d1 = 156.6;
      amp_h4 = 62.3;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "UK100"))
     {
      amp_w1 = 208.25;
      amp_d1 = 68.31;
      amp_h4 = 29.0;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "FR40"))
     {
      amp_w1 = 247.74;
      amp_d1 = 76.95;
      amp_h4 = 30.71;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUS200"))
     {
      amp_w1 = 204.43;
      amp_d1 = 67.52;
      amp_h4 = 29.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDCHF"))
     {
      amp_w1 = 0.01242;
      amp_d1 = 0.0042;
      amp_h4 = 0.00158;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDNZD"))
     {
      amp_w1 = 0.01293;
      amp_d1 = 0.00481;
      amp_h4 = 0.00178;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00567;
      amp_h4 = 0.00218;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDJPY"))
     {
      amp_w1 = 2.285;
      amp_d1 = 0.774;
      amp_h4 = 0.282;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "CHFJPY"))
     {
      amp_w1 = 2.911;
      amp_d1 = 1.107;
      amp_h4 = 0.458;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURJPY"))
     {
      amp_w1 = 3.166;
      amp_d1 = 1.101;
      amp_h4 = 0.434;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPJPY"))
     {
      amp_w1 = 3.873;
      amp_d1 = 1.326;
      amp_h4 = 0.53;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDJPY"))
     {
      amp_w1 = 2.034;
      amp_d1 = 0.704;
      amp_h4 = 0.272;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDJPY"))
     {
      amp_w1 = 3.044;
      amp_d1 = 1.072;
      amp_h4 = 0.427;
      amp_grid_L100 = 1.5;
      return;
     }
   if(is_same_symbol(symbol, "EURAUD"))
     {
      amp_w1 = 0.02969;
      amp_d1 = 0.01072;
      amp_h4 = 0.00417;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCAD"))
     {
      amp_w1 = 0.02146;
      amp_d1 = 0.00765;
      amp_h4 = 0.00284;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00429;
      amp_h4 = 0.0018;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURGBP"))
     {
      amp_w1 = 0.01162;
      amp_d1 = 0.00356;
      amp_h4 = 0.00131;
      amp_grid_L100 = 0.00155;
      return;
     }
   if(is_same_symbol(symbol, "EURNZD"))
     {
      amp_w1 = 0.03185;
      amp_d1 = 0.01191;
      amp_h4 = 0.00478;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURUSD"))
     {
      amp_w1 = 0.01858;
      amp_d1 = 0.00624;
      amp_h4 = 0.00239;
      amp_grid_L100 = 0.0035;
      return;
     }
   if(is_same_symbol(symbol, "GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00601;
      amp_h4 = 0.00241;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPNZD"))
     {
      amp_w1 = 0.03533;
      amp_d1 = 0.01304;
      amp_h4 = 0.00531;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPUSD"))
     {
      amp_w1 = 0.02454;
      amp_d1 = 0.00811;
      amp_h4 = 0.00317;
      amp_grid_L100 = 0.00335;
      return;
     }
   if(is_same_symbol(symbol, "NZDCAD"))
     {
      amp_w1 = 0.01459;
      amp_d1 = 0.0055;
      amp_h4 = 0.00216;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDUSD"))
     {
      amp_w1 = 0.0151;
      amp_d1 = 0.00524;
      amp_h4 = 0.0021;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      amp_w1 = 0.01943;
      amp_d1 = 0.00651;
      amp_h4 = 0.00252;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCHF"))
     {
      amp_w1 = 0.017;
      amp_d1 = 0.00715;
      amp_h4 = 0.00235;
      amp_grid_L100 = 0.006;
      return;
     }

   amp_w1 = CalculateAverageCandleHeight(PERIOD_W1, symbol, 20);
   amp_d1 = CalculateAverageCandleHeight(PERIOD_D1, symbol, 30);
   amp_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol, 60);
   amp_grid_L100 = amp_d1;
//SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
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
   dic_amp_init_d1 = calc_avg_amp_week(symbol, PERIOD_D1, 50);
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   dic_amp_init_h4 = calc_avg_amp_week(symbol, PERIOD_H4, 50);

   SendAlert(INDI_NAME, "SymbolData", " Get SymbolData:" + (string)symbol + "   i_top_price: " + (string)i_top_price + "   amp_w: " + (string)amp_w + "   dic_amp_init_h4: " + (string)dic_amp_init_h4);
   return;
  }
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
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTodayProfitLoss()
  {
   double totalProfitLoss = 0.0; // Variable to store total profit or loss

// Get the current date
   datetime today = StringToTime(TimeToStr(TimeCurrent(), TIME_DATE));

// Loop through closed orders in account history
   count_closed_today = 0;
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         // Check if the order was closed today
         if(OrderCloseTime() >= today)
           {
            int type = OrderType();
            if(type == OP_BUY  || type == OP_BUYLIMIT  || type == OP_BUYSTOP ||
               type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
              {
               totalProfitLoss += OrderProfit();
               count_closed_today += 1;
              }
           }
        }
     }

   return totalProfitLoss; // Return the total profit or loss
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteIndicatorsWindows()
  {
   long chart_id = ChartID();

   int windowCount = 100;  // Assumed maximum number of windows for safety
   for(int windowIndex = 1; windowIndex < windowCount; windowIndex++)
     {
      int indicatorCount = ChartIndicatorsTotal(chart_id, windowIndex);
      if(indicatorCount <= 0)
         continue;

      for(int i = indicatorCount - 1; i >= 0; i--)
        {
         string indicatorName = ChartIndicatorName(chart_id, windowIndex, i);

         if(!ChartIndicatorDelete(chart_id, windowIndex, indicatorName))
           {
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateRemainder(double price, double AMP_DCA_MIN)
  {
   return NormalizeDouble(MathMod(price, AMP_DCA_MIN), Digits-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateQuotient(double price, double AMP_DCA_MIN)
  {
   return MathFloor(price / AMP_DCA_MIN);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init_amp_dca(string symbol)
  {
   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

   avg_candle_w1 = CalculateAverageCandleHeight(PERIOD_W1, symbol, 5);

   double lowest = 0.0, higest = 0.0;
   double lowest_3d = 0.0, higest_3d = 0.0;
   for(int idx = 0; idx <= 7; idx++)
     {
      double low = iLow(symbol, PERIOD_D1, idx);
      double hig = iHigh(symbol, PERIOD_D1, idx);
      if((idx == 0) || (lowest > low))
         lowest = low;
      if((idx == 0) || (higest < hig))
         higest = hig;

      if((idx == 0) || (lowest_3d > low && idx <= 2))
         lowest_3d = low;
      if((idx == 0) || (higest_3d < hig && idx <= 2))
         higest_3d = hig;
     }
   amp_d7 = MathAbs(higest - lowest);
   LOWEST_OF_7_DAYS = NormalizeDouble(lowest, Digits);
   CENTER_OF_3_DAYS = NormalizeDouble((higest_3d + lowest_3d)/2, Digits);
   HIGEST_OF_7_DAYS = NormalizeDouble(higest, Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_Cno()
  {
   return "";

   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double price = (bid+ask)/2;
   double step = NormalizeDouble(AMP_DC / (NUMBER_OF_TRADER), 2);
   double rm1 = CalculateRemainder(price, AMP_DC);
   double rm2 = CalculateQuotient(rm1, step); //0.25: 20 Traders, 0.5: 10 Traders

   return "(C" + (string) + rm2 + ")";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_stoploss_buy_by_macd()
  {

   bool stoploss_buy_by_macd = trend_mac_vs_signal_h4 == TREND_SEL && trend_vector_macd_h4 == TREND_SEL && trend_vector_signal_h4 == TREND_SEL &&
                               trend_mac_vs_signal_h1 == TREND_SEL && trend_vector_macd_h1 == TREND_SEL && trend_vector_signal_h1 == TREND_SEL;

   return stoploss_buy_by_macd;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_stoploss_buy_by_heiken_h4h1()
  {
   return arrHeiken_h4[0].trend_heiken == TREND_SEL && arrHeiken_h1[0].trend_heiken == TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_stoploss_sel_by_heiken_h4h1()
  {
   return arrHeiken_h4[0].trend_heiken == TREND_BUY && arrHeiken_h1[0].trend_heiken == TREND_BUY;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_stoploss_sell_by_macd()
  {
   bool stoploss_sell_by_macd = trend_mac_vs_signal_h4 == TREND_BUY && trend_vector_macd_h4 == TREND_BUY && trend_vector_signal_h4 == TREND_BUY &&
                                trend_mac_vs_signal_h1 == TREND_BUY && trend_vector_macd_h1 == TREND_BUY && trend_vector_signal_h1 == TREND_BUY;
   return stoploss_sell_by_macd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool pass_pre_check_before_trade(string TREND)
  {
   if(TREND == TREND_BUY)
     {
      bool stoploss_buy_by_heiken = is_stoploss_buy_by_heiken_h4h1();
      bool stoploss_buy_by_macd = is_stoploss_buy_by_macd();
      if(stoploss_buy_by_heiken)
        {
         Alert("(PRE_CHECK) Heiken H4, H1 not allow BUY. STOPLOSS_BUY_BY_HEIKEN");
         return false;
        }

      if(stoploss_buy_by_macd)
        {
         Alert("(PRE_CHECK) MACD H4, H1 not allow BUY. STOPLOSS_BUY_BY_MACD");
         return false;
        }
     }

   if(TREND == TREND_SEL)
     {
      bool stoploss_sel_by_heiken = is_stoploss_sel_by_heiken_h4h1();
      bool stoploss_sell_by_macd = is_stoploss_sell_by_macd();
      if(stoploss_sel_by_heiken)
        {
         Alert("(PRE_CHECK) Heiken H4, H1 not allow SELL. stoploss_sel_by_heiken");
         return false;
        }

      if(stoploss_sell_by_macd)
        {
         Alert("(PRE_CHECK) Heiken H4, H1 not allow SELL. STOPLOSS_SELL_BY_MACD");
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool pass_pre_check_over_bs_by_stoc(string TREND)
  {
//Alert(TREND, trend_over_bs_by_stoc_d1, trend_over_bs_by_stoc_h4, trend_over_bs_by_stoc_h1);

   if(TREND == TREND_BUY)
     {
      // 80, 80, 80
      if(is_same_symbol(trend_over_bs_by_stoc_d1, TREND_SEL) &&
         is_same_symbol(trend_over_bs_by_stoc_h4, TREND_SEL) &&
         is_same_symbol(trend_over_bs_by_stoc_h1, TREND_SEL))
        {
         Alert("(PRE_CHECK) STOCK D1,H4,H1 not allow BUY. OVERBOUGHT");
         return false;
        }
     }

   if(TREND == TREND_SEL)
     {
      // 20, 20, 20
      if(is_same_symbol(trend_over_bs_by_stoc_d1, TREND_BUY) &&
         is_same_symbol(trend_over_bs_by_stoc_h4, TREND_BUY) &&
         is_same_symbol(trend_over_bs_by_stoc_h1, TREND_BUY))
        {
         Alert("(PRE_CHECK) STOCK D1,H4,H1 not allow BUY. OVERSOLD");
         return false;
        }
     }

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   if(is_main_control_screen() == false)
      return "";

   string symbol = Symbol();
   double profit_today = CalculateTodayProfitLoss();
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   string percent = " (" + format_double_to_string(profit_today/BALANCE * 100, 2) + "%)";

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime();// + "(" + cur_timeframe + ") ";
   str_comments += "    Profit(today): " + format_double_to_string(profit_today, 2) + "$" + percent + "/" + (string) count_closed_today + "L";

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double price = (bid+ask)/2;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   CandleData arrHeiken[];
   get_arr_heiken(symbol, PERIOD_CURRENT, arrHeiken);

   color clrHeiken = arrHeiken[1].trend_heiken == TREND_BUY ? clrBlue : clrRed;
   create_trend_line("close_heiken_1", iTime(symbol, PERIOD_CURRENT, 0) - TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, TimeCurrent() + TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, clrHeiken, STYLE_DOT, 1, false, false);

   double import_price = (price*25500*(37.5/31.1035)/1000000);

   str_comments += "    (Mac.Zero.H4): " + (string) trend_mac_vs_zero_h4;
   str_comments += "    (Mac.Sign.H1): " + (string) trend_mac_vs_signal_h1;
   str_comments += "    (Heiken "+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend_heiken + " (" + append1Zero(arrHeiken[0].count_heiken) + ")";
   str_comments += "    (Ma10 "+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend_by_ma10 + " (" + append1Zero(arrHeiken[0].count_ma10) + ")";
   str_comments += "    Init_Equity: " + format_double_to_string(INIT_EQUITY, 1) + "    Risk1%: " + format_double_to_string(risk_1_Percent_Account_Balance(), 1) + "$";

   if(is_same_symbol(Symbol(), "XAU") == false)
      return str_comments;

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);
   str_comments += "    VND: " + format_double_to_string(import_price*1.09, 2) + "~" + format_double_to_string(import_price*1.119, 2) + " tr";
   str_comments += "    Amp(W1): " + format_double_to_string(amp_w1, Digits) + "$";
   str_comments += "\n\n";


   return str_comments;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
