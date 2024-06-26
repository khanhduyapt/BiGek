//+------------------------------------------------------------------+
//|                                                    XAUUSD-V3.mq4 |
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
double dbRiskRatio      = 0.01;    // Rủi ro 1%
double AMP_SOLVE        = 5;
double FIXED_SL_AMP     = 10;
double INIT_CLOSE_W1    = 2295;
double AMP_DC           = 1.5;
double AMP_TP           = 25;
string VER = "V240530";
string INDI_NAME = VER;
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
#define BtnSolveNegative         "BtnSolveNegative"
#define BtnPaddingTrade          "BtnPaddingTrade"
#define BtnTradeWithStopLoss     "BtnTradeWithStopLoss"
#define BtnClosePositiveOrders   "BtnClosePositiveOrders"
#define BtnAutoSL                "BtnAutoSL"
#define BtnNewCycleBuy           "NewCycleBuy"
#define BtnNewCycleSel           "NewCycleSel"
#define BtnCloseProfitBuy        "BtnCloseProfitBuy"
#define BtnCloseProfitSel        "BtnCloseProfitSel"
#define BtnWaitBuy10Per          "BtnWaitBuy10Per"
#define BtnWaitSel10Per          "BtnWaitSel10Per"
#define BtnBuyNow1Per            "BtnBuyNow1Per"
#define BtnSelNow1Per            "BtnSelNow1Per"
#define BtnHedgBuy2Sel           "BtnHedgBuy2Sel"
#define BtnHedgSel2Buy           "BtnHedgSel2Buy"
#define BtnSetEntryBuy           "BtnSetEntryBuy"
#define BtnSetEntrySel           "BtnSetEntrySel"
//-----------------------------------------------------------------------------
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
bool IS_WAITTING_BUY = false;
bool IS_WAITTING_SEL = false;
bool IS_CONTINUE_TRADING_CYCLE_BUY = false;
bool IS_CONTINUE_TRADING_CYCLE_SEL = false;
bool IS_HAS_AUTO_STOP_LOSS = false;
double PRICE_START_TRADE = 0.0;
//-----------------------------------------------------------------------------
//int    NUMBER_PE_TRADE   = 10;       // Mở quá NUMBER_PE_TRADE lệnh thì bắt đầu cầu hòa.
//-----------------------------------------------------------------------------
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
string MASK_HAVE_SL = "(HS)";
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
double global_range_min = 0, global_range_max = 0, global_bot_count_tp_zero = 0;
double MAXIMUM_DOUBLE = 999999999;
double global_min_exit_price = MAXIMUM_DOUBLE, global_max_exit_price = 0, global_profit_positive_orders = 0;
int global_bot_count_buy = 0, global_bot_count_sel = 0, count_closed_today = 0;
int global_tcount_buy = 0, global_tcount_sel = 0;
int global_bot_count_manual_buy = 0, global_bot_count_manual_sel = 0, global_10percent_count = 0;
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
string lable_profit_buy = "", lable_profit_sel = "", lableBtnPaddingTrade = "", lable_profit_positive_orders = "";
int DEFAULT_WAITING_DCA_IN_MINUS = 30;
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//WriteAvgAmpToFile();
   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

   if(is_same_symbol(Symbol(), "XAU"))
     {
      AMP_SOLVE        = 5;
      FIXED_SL_AMP     = 10;
      INIT_CLOSE_W1    = 2295;
      //AMP_DC           = 5;
      //AMP_TP           = 5;
     }
   else
     {
      double dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1;
      GetSymbolData(Symbol(), dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);

      AMP_SOLVE        = amp_d1;
      FIXED_SL_AMP     = NormalizeDouble(amp_d1/3, Digits);
      INIT_CLOSE_W1    = dic_top_price;
      AMP_DC           = amp_d1;
      AMP_TP           = amp_h4;
     }

   INIT_EQUITY = AccountInfoDouble(ACCOUNT_BALANCE);
   INIT_VOLUME = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, INIT_EQUITY*0.01);

   loadAutoTrade();
//DeleteAllObjects();
   InitOrderArr(Symbol());
   init_amp_dca(Symbol());
   init_trade_cond_10precent();

   Comment(GetComments());
   Draw_Buttons();

   if(GlobalVariableCheck("MyHorizontalLinePrice"))
      INIT_START_PRICE = GlobalVariableGet("MyHorizontalLinePrice");
   else
     {
      INIT_START_PRICE = iLow(Symbol(), PERIOD_W1, 0);
      GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
     }

   ObjectCreate(0, START_TRADE_LINE, OBJ_HLINE, 0, Time[0], INIT_START_PRICE);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, START_TRADE_LINE, OBJPROP_ZORDER, 0);


   if(is_main_control_screen())
     {
      for(int col = 0; col < 91; col ++)
        {
         double low_di = iLow(Symbol(), PERIOD_D1, col);
         double close_di = iClose(Symbol(), PERIOD_D1, col);
         double hig_di = iHigh(Symbol(), PERIOD_D1, col);

         datetime time_di = iTime(Symbol(), PERIOD_D1, col);

         double close_di1 = iClose(Symbol(), PERIOD_D1, col+1);
         datetime time_di0 = col == 0? TimeCurrent() : iTime(Symbol(), PERIOD_D1, col-1);
         string trend_sl_buy = "d" + (string)(col+1) + "_sl_buy";
         string trend_sl_sel = "d" + (string)(col+1) + "_sl_sel";


         string trend_name = "close_d" + (string)(col+1);
         string trend_di = close_di > close_di1 ? TREND_BUY : TREND_SEL;
         color clrTrend = close_di > close_di1 ? clrBlue : clrRed;

         double price_sl_di_buy = close_di1 - FIXED_SL_AMP;
         double price_sl_di_sel = close_di1 + FIXED_SL_AMP;
         if(Period() <= PERIOD_H4)
           {
            create_trend_line(trend_name, time_di, close_di1, time_di0, close_di1, clrTrend, STYLE_SOLID, col > 0 ? 1:1, false, false);

            if(trend_di == TREND_BUY)
               create_trend_line(trend_sl_buy, time_di, price_sl_di_buy, time_di0, price_sl_di_buy, clrTrend, STYLE_DASHDOT, 1, false, false);

            if(trend_di == TREND_SEL)
               create_trend_line(trend_sl_sel, time_di, price_sl_di_sel, time_di0, price_sl_di_sel, clrTrend, STYLE_DASHDOT, 1, false, false);
           }
         else
           {
            ObjectDelete(0, trend_name);
            ObjectDelete(0, trend_sl_buy);
            ObjectDelete(0, trend_sl_sel);
           }

         int count = int((hig_di - low_di)/ FIXED_SL_AMP) + 2;
         for(int idx = 1; idx < count; idx ++)
           {
            string trend_tp_Ix10 = "d" + (string)(col+1) + "_tp_" + (string)(idx*FIXED_SL_AMP);
            double price_tp_Idx10 = trend_di == TREND_BUY ? close_di1 + (idx*FIXED_SL_AMP) : close_di1 - (idx*FIXED_SL_AMP);

            if(Period() < PERIOD_H4)
               create_trend_line(trend_tp_Ix10, time_di, price_tp_Idx10, time_di0, price_tp_Idx10, clrTrend, STYLE_DOT, 1, false, false);
            else
               ObjectDelete(0, trend_tp_Ix10);
           }

         string ver_d1 = "d." + time2string(time_di);
         if(Period() <= PERIOD_H4)
            create_vertical_line(ver_d1, time_di, clrSilver, STYLE_SOLID);
         else
            ObjectDelete(0, ver_d1);

         if(col < 50 && col > 0)
            GetHighestLowestM5Times(time_di, time_di0);
        }
      //---------------------------------------------------------------------------------------------------------
      for(int col = 0; col < 13; col ++)
        {
         datetime time_wi = iTime(Symbol(), PERIOD_W1, col);
         datetime time_wi0 = col == 0? TimeCurrent() : iTime(Symbol(), PERIOD_W1, col-1);
         string ver_name = "W" + append1Zero(col);
         string close_name_wi = "W." + append1Zero(col);
         double close_wi = iClose(Symbol(), PERIOD_W1, col);
         double close_wi1 = iClose(Symbol(), PERIOD_W1, col+1);
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
         datetime time_mni = iTime(Symbol(), PERIOD_MN1, col);
         string ver_mi = "MN" + append1Zero(col);
         datetime time_mni0 = col == 0 ? TimeCurrent() + TIME_OF_ONE_H4_CANDLE : iTime(Symbol(), PERIOD_MN1, col-1);
         string close_name_mni = "MN." + append1Zero(col);
         double close_mni = iClose(Symbol(), PERIOD_MN1, col);
         double close_mni1 = iClose(Symbol(), PERIOD_MN1, col+1);
         color clrTrend = close_mni > close_mni1 ? clrBlue : clrRed;

         if(Period() <= PERIOD_H4)
           {
            create_vertical_line(ver_mi, time_mni, clrBlack, STYLE_SOLID, 2);
            create_trend_line(close_name_mni, time_mni, close_mni1, time_mni0, close_mni1, clrTrend, STYLE_SOLID, 3, false, false);

            if(col == 1)
              {
               create_lable("."+ close_name_mni, time_mni0, close_mni1, ver_mi + " (" + format_double_to_string(close_mni1, Digits-1) + ")", "");
               create_trend_line("MN_" + append1Zero(col), time_mni0, close_mni1, TimeCurrent() + TIME_OF_ONE_H4_CANDLE, close_mni1, clrTrend, STYLE_DASHDOTDOT, 1, false, false);
              }
           }
         else
           {
            ObjectDelete(0, ver_mi);
            ObjectDelete(0, close_name_mni);
           }
        }
     }

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string symbol = Symbol();
   loadAutoTrade();

   if(is_same_symbol(symbol, "XAU"))
      OpenTrade(symbol);

   Draw_Buttons();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade(string symbol)
  {
   if(is_same_symbol(symbol, Symbol()) == false)
      return;

   init_amp_dca(symbol);
   InitOrderArr(symbol);
   ProtectAccount(symbol);
   Solve_Negative(symbol, false);

   if(IsTesting())
     {
      //IS_CONTINUE_TRADING_CYCLE_BUY = true;
      //IS_CONTINUE_TRADING_CYCLE_SEL = true;
     }

   string trader_name = create_trader_name();
   OpenTrade_X100(symbol, trader_name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitOrderArr(string symbol)
  {
   string trend_by_macd = "", trend_mac_vs_signal = "", trend_mac_vs_zero = "";
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4, trend_by_macd, trend_mac_vs_signal, trend_mac_vs_zero);
   INIT_TREND_TODAY = trend_mac_vs_zero;

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
   global_bot_count_tp_zero = 0;
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
   global_10percent_count = 0;
   global_10percent_min_open_price = 0;
   global_10percent_max_open_price = 0;
   global_min_entry_manual_buy = 0;
   global_max_entry_manual_sel = 0;
   global_bot_count_tp_eq_en_buy = 0;
   global_bot_count_tp_eq_en_sel = 0;
   global_max_entry_buy = 0;
   global_min_entry_sel = 0;
   global_potential_profit_buy = 0;
   global_potential_profit_sel = 0;
   int max_count = 0;
   string msg_stoploss = "";
   double min_entry_buy = 0, min_entry_sel = 0;
   double max_entry_buy = 0, max_entry_sel = 0;
   double global_profit_buy = 0, global_profit_sel = 0;
   double potential_profit_buy = 0, potential_profit_sel = 0;
   global_profit_positive_orders = 0;
   int count_profit_positive_orders_buy = 0, count_profit_positive_orders_sel = 0;

   double risk = calcRisk();
   CandleData arrHeiken_H1[];
   get_arr_heiken(Symbol(), PERIOD_H1, arrHeiken_H1);

   double EQUITY  = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            string comment = OrderComment();
            double temp_profit = OrderProfit() + OrderSwap() + OrderCommission();
            double potentialProfit = calcPotentialTradeProfit(symbol, OrderType(), OrderOpenPrice(), OrderTakeProfit(), OrderLots());
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double cur_price = (bid+ask)/2;
            //-----------------------------------------------------------------------------------------------------------
            if(temp_profit > risk)
              {
               string msg = "TakeProfit: " + symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";
               if(OrderType() == OP_BUY && StringLen(comment) > 1)
                 {
                  if(must_exit_trade_today(symbol, TREND_BUY))
                    {
                     IS_CONTINUE_TRADING_CYCLE_BUY = false;
                     saveAutoTrade();
                     ClosePosition(symbol, OP_BUY, comment);
                     SendTelegramMessage(symbol, TREND_BUY, msg);
                    }

                  if((cur_price > OrderOpenPrice() + FIXED_SL_AMP) &&
                     (cur_price > calc_tp_by_fixed_sl_amp(symbol, TREND_BUY)) &&
                     is_allow_take_profit_now_by_stoc(symbol, PERIOD_M1, TREND_BUY, 3, 2, 3))
                    {
                     IS_CONTINUE_TRADING_CYCLE_BUY = false;
                     saveAutoTrade();
                     ClosePosition(symbol, OP_BUY, comment);
                     SendTelegramMessage(symbol, TREND_BUY, msg + " TP_MAX_AMP");
                    }
                 }

               if(OrderType() == OP_SELL && StringLen(comment) > 1)
                 {
                  if(must_exit_trade_today(symbol, TREND_SEL))
                    {
                     IS_CONTINUE_TRADING_CYCLE_SEL = false;
                     saveAutoTrade();
                     ClosePosition(symbol, OP_SELL, comment);
                     SendTelegramMessage(symbol, TREND_SEL, msg);
                    }

                  if((cur_price < OrderOpenPrice() - FIXED_SL_AMP) &&
                     (cur_price < calc_tp_by_fixed_sl_amp(symbol, TREND_SEL)) &&
                     is_allow_take_profit_now_by_stoc(symbol, PERIOD_M1, TREND_SEL, 3, 2, 3))
                    {
                     IS_CONTINUE_TRADING_CYCLE_SEL = false;
                     saveAutoTrade();
                     ClosePosition(symbol, OP_SELL, comment);
                     SendTelegramMessage(symbol, TREND_SEL, msg + " TP_MAX_AMP");
                    }
                 }
              }
            //-----------------------------------------------------------------------------------------------------------
            if(IS_HAS_AUTO_STOP_LOSS && (temp_profit < risk) && (BALANCE*0.1 + ACC_PROFIT < 0))
              {
               string msg = "StopLoss: " + symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";

               if(is_same_symbol(comment, TREND_BUY) && OrderType() == OP_BUY &&
                  arrHeiken_H1[1].trend == TREND_SEL && arrHeiken_H1[0].trend == TREND_SEL)

                  if(OrderOpenPrice() - FIXED_SL_AMP > arrHeiken_H1[0].close)
                     if(is_same_symbol(wait_trade_by_stoch(symbol, PERIOD_M5), TREND_BUY) == false)
                        if(is_same_symbol(wait_trade_by_stoch(symbol, PERIOD_M1), TREND_BUY) == false)
                          {
                           IS_CONTINUE_TRADING_CYCLE_BUY = false;
                           saveAutoTrade();

                           ClosePosition(symbol, OP_BUY, comment);
                           SendTelegramMessage(symbol, TREND_BUY, msg);
                          }

               if(is_same_symbol(comment, TREND_SEL) && OrderType() == OP_SELL &&
                  arrHeiken_H1[1].trend == TREND_BUY && arrHeiken_H1[0].trend == TREND_BUY)

                  if(OrderOpenPrice() + FIXED_SL_AMP < arrHeiken_H1[0].close)
                     if(is_same_symbol(wait_trade_by_stoch(symbol, PERIOD_M5), TREND_SEL) == false)
                        if(is_same_symbol(wait_trade_by_stoch(symbol, PERIOD_M1), TREND_SEL) == false)
                          {
                           IS_CONTINUE_TRADING_CYCLE_SEL = false;
                           saveAutoTrade();

                           ClosePosition(symbol, OP_SELL, comment);
                           SendTelegramMessage(symbol, TREND_SEL, msg);
                          }
              }
            //-----------------------------------------------------------------------------------------------------------
            if(OrderType() == OP_BUY)
              {
               global_tcount_buy += 1;
               global_tvol_buy += OrderLots();
               global_tprofit_buy += temp_profit;
               global_potential_profit_buy += potentialProfit;

               if(global_max_entry_buy == 0 || global_max_entry_buy < OrderOpenPrice())
                  global_max_entry_buy = OrderOpenPrice();
              }

            if(OrderType() == OP_SELL)
              {
               global_tcount_sel += 1;
               global_tvol_sel += OrderLots();
               global_tprofit_sel += temp_profit;
               global_potential_profit_sel += potentialProfit;

               if(global_min_entry_sel == 0 || global_min_entry_sel > OrderOpenPrice())
                  global_min_entry_sel = OrderOpenPrice();
              }

            if(OrderTakeProfit()-1 <= OrderOpenPrice() && OrderOpenPrice() <= OrderTakeProfit()+1)
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

            if(is_same_symbol(comment, MASK_HAVE_SL))
              {
               global_10percent_count += 1;
               bool must_sl = false;

               if(global_10percent_min_open_price > OrderOpenPrice())
                  global_10percent_min_open_price = OrderOpenPrice();
               if(global_10percent_max_open_price < OrderOpenPrice())
                  global_10percent_max_open_price = OrderOpenPrice();

               if((OrderType() == OP_BUY) && (cur_price < OrderOpenPrice() - FIXED_SL_AMP))
                  must_sl = true;

               if((OrderType() == OP_SELL) && (cur_price > OrderOpenPrice() + FIXED_SL_AMP))
                  must_sl = true;

               if(must_sl)
                 {
                  msg_stoploss += "StopLoss: " + symbol + (string)OrderTicket() + "   p: " + (string)temp_profit + "$\n" ;
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

            if(OrderType() == OP_BUY  && OrderOpenPrice() + 99 < OrderTakeProfit())
               global_bot_count_tp_zero += 1;
            if(OrderType() == OP_SELL && OrderOpenPrice() - 99 > OrderTakeProfit())
               global_bot_count_tp_zero += 1;

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

                  if(min_entry_buy == 0 || min_entry_buy > OrderOpenPrice())
                     min_entry_buy = OrderOpenPrice();
                  if(max_entry_buy < OrderOpenPrice())
                     max_entry_buy = OrderOpenPrice();
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

                  if(min_entry_sel == 0 || min_entry_sel > OrderOpenPrice())
                     min_entry_sel = OrderOpenPrice();
                  if(max_entry_sel < OrderOpenPrice())
                     max_entry_sel = OrderOpenPrice();
                 }
               //---------------------------------------------------------------------
              }
           }
     }

   if(msg_stoploss != "")
      SendAlert(symbol, "SL", msg_stoploss);

   global_min_entry_buy = min_entry_buy;
   global_max_entry_sel = max_entry_sel;

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
                         + "Est: " + format_double_to_string(potential_profit_buy, 1) + "$ "
                         + format_double_to_string(potential_profit_buy/INIT_EQUITY * 100, 1) + "%";

      if(is_main_screen)
         lable_profit_buy = "(B" + (string) global_tcount_buy + ") "
                            + AppendSpaces(format_double_to_string(global_tprofit_buy, 1) + " ", 8, false)
                            + "Est: " + format_double_to_string(global_potential_profit_buy, 1) + "$ "
                            + format_double_to_string(global_potential_profit_buy/INIT_EQUITY * 100, 1) + "%";
     }

   lable_profit_sel = "";
   if(global_bot_count_sel > 0 || (is_main_screen && global_tcount_sel > 0))
     {
      lable_profit_sel = "(S" + (string) global_bot_count_sel + ") "
                         + AppendSpaces(format_double_to_string(global_profit_sel, 1) + " ", 8, false)
                         + "Est: " + format_double_to_string(potential_profit_sel, 1) + "$ "
                         + format_double_to_string(potential_profit_sel/INIT_EQUITY * 100, 1) + "%";

      if(is_main_screen)
         lable_profit_sel = "(S" + (string) global_tcount_sel + ") "
                            + AppendSpaces(format_double_to_string(global_tprofit_sel, 1) + " ", 8, false)
                            + "Est: " + format_double_to_string(global_potential_profit_sel, 1) + "$ "
                            + format_double_to_string(global_potential_profit_sel/INIT_EQUITY * 100, 1) + "%";
     }
//-----------------------------------------------------------------------------
   global_comment = "";
   if(MathAbs(total_profit_buy) > 0)
     {
      if(!is_main_screen)
         global_comment +=  AppendSpaces(create_trader_name(), 8)
                            + " Buy: " + Append(count_possion_buy, 2) + "L" + AppendSpaces(format_double_to_string(total_volume_buy, 2), 6, false) + " lot.\n";

      if(is_main_screen)
         global_comment +=  AppendSpaces("ALL", 8)
                            + " Buy: " + Append(global_tcount_buy, 2) + "L" + AppendSpaces(format_double_to_string(global_tvol_buy, 2), 6, false) + " lot.\n";
     }

   if(MathAbs(total_profit_sel) > 0)
     {
      if(!is_main_screen)
         global_comment += AppendSpaces(create_trader_name(), 8)
                           + " Sell: " + Append(count_possion_sel, 2) + "L" + AppendSpaces(format_double_to_string(total_volume_sel, 2), 6, false) + " lot.\n";

      if(is_main_screen)
         global_comment +=  AppendSpaces("ALL", 8)
                            + " Sell: " + Append(global_tcount_sel, 2) + "L" + AppendSpaces(format_double_to_string(global_tvol_sel, 2), 6, false) + " lot.\n";
     }

   if(max_count < count_possion_buy)
      max_count = count_possion_buy;
   if(max_count < count_possion_sel)
      max_count = count_possion_sel;
   if(max_amp < max_entry_buy - min_entry_buy)
     {
      max_amp = max_entry_buy - min_entry_buy;
      max_amp_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }
   if(max_amp < max_entry_sel - min_entry_sel)
     {
      max_amp = max_entry_sel - min_entry_sel;
      max_amp_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }
//-----------------------------------------------------------------------------

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
                + "    Profit:" + get_acc_profit_percent()
                + "\n\n";
     }
   Comment(comment + global_comment);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

   double tp_buy = calc_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);
   double tp_sel = calc_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);

   if(ask > tp_buy)
     {
      IS_CONTINUE_TRADING_CYCLE_BUY = false;
      saveAutoTrade();
      ModifyTp_ToEntry(symbol, 1, TREND_BUY);
      SendAlert(symbol, TREND_BUY, "Exit BUY by D_RANGE_UP");
     }

   if(IS_CONTINUE_TRADING_CYCLE_BUY)
      if((bid > iLow(symbol, PERIOD_D1, 0) + FIXED_SL_AMP*2) ||
         is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3))
        {
         IS_CONTINUE_TRADING_CYCLE_BUY = false;
         saveAutoTrade();
         ModifyTp_ToEntry(symbol, 1, TREND_BUY);
         SendAlert(symbol, TREND_BUY, "Exit auto BUY by_stoc_h4");
        }

   if(bid < tp_sel)
     {
      IS_CONTINUE_TRADING_CYCLE_SEL = false;
      saveAutoTrade();
      ModifyTp_ToEntry(symbol, 1, TREND_SEL);
      SendAlert(symbol, TREND_BUY, "Exit SEL by D_RANGE_DN");
     }

   if(IS_CONTINUE_TRADING_CYCLE_SEL)
      if((ask < iHigh(symbol, PERIOD_D1, 0) - FIXED_SL_AMP*2) ||
         is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3))
        {
         IS_CONTINUE_TRADING_CYCLE_SEL = false;
         saveAutoTrade();
         ModifyTp_ToEntry(symbol, 1, TREND_SEL);
         SendAlert(symbol, TREND_BUY, "Exit auto SEL by_stoc_h4");
        }

   create_lable("TP BUY", TimeCurrent(), tp_buy, "TP BUY "  + format_double_to_string(tp_buy, Digits-2), TREND_BUY);
   create_lable("TP SEL", TimeCurrent(), tp_sel, "TP SELL " + format_double_to_string(tp_sel, Digits-2), TREND_BUY);
   create_trend_line("TP_BUY", iTime(symbol, PERIOD_D1, 0), tp_buy, TimeCurrent(), tp_buy, clrBlueViolet, STYLE_DASHDOT, 1, true, true);
   create_trend_line("TP_SEL", iTime(symbol, PERIOD_D1, 0), tp_sel, TimeCurrent(), tp_sel, clrBlueViolet, STYLE_DASHDOT, 1, true, true);
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
      if(IS_CONTINUE_TRADING_CYCLE_BUY || IS_CONTINUE_TRADING_CYCLE_SEL)
        {
         double close_d1 = iClose(symbol, PERIOD_D1, 1);

         if(IS_CONTINUE_TRADING_CYCLE_BUY && (global_bot_count_manual_buy == 0) && (ask < close_d1 - FIXED_SL_AMP) &&
            (wait_trade_by_stoch(symbol, PERIOD_H1) == TREND_BUY) && (wait_trade_by_stoch(symbol, PERIOD_M1) == TREND_BUY))
           {
            string comment = "at." + MASK_MANUAL + create_comment(create_trader_name(), TREND_BUY, global_bot_count_manual_buy+1);

            bool exit_ok = Open_Position(symbol, OP_BUY, INIT_VOLUME, 0.0, 0.0, comment);
            if(exit_ok)
              {
               IS_CONTINUE_TRADING_CYCLE_BUY = true;
               IS_CONTINUE_TRADING_CYCLE_SEL = false;
               saveAutoTrade();

               SendTelegramMessage(symbol, "AUTO_BUY", "AUTO_BUY ("+MASK_MANUAL+")" + symbol + " " + comment);
              }
           }

         if(IS_CONTINUE_TRADING_CYCLE_SEL && (global_bot_count_manual_sel == 0) && (bid > close_d1 + FIXED_SL_AMP) &&
            (wait_trade_by_stoch(symbol, PERIOD_H1) == TREND_SEL) && (wait_trade_by_stoch(symbol, PERIOD_M1) == TREND_SEL))
           {
            string comment = "at." + MASK_MANUAL + create_comment(create_trader_name(), TREND_SEL, global_bot_count_manual_sel+1);

            bool exit_ok = Open_Position(symbol, OP_SELL, INIT_VOLUME, 0.0, 0.0, comment);
            if(exit_ok)
              {
               IS_CONTINUE_TRADING_CYCLE_BUY = false;
               IS_CONTINUE_TRADING_CYCLE_SEL = true;
               saveAutoTrade();

               SendTelegramMessage(symbol, "AUTO_SEL", "AUTO_SEL ("+MASK_MANUAL+")" + symbol + " " + comment);
              }
           }
        }

      if(global_bot_count_manual_buy + global_bot_count_manual_sel > 0)
        {
         if(IS_CONTINUE_TRADING_CYCLE_BUY && global_bot_count_manual_buy > 0 &&
            global_bot_count_manual_buy > 0 && global_min_entry_manual_buy-AMP_DC > ask)
           {
            string comment = MASK_MANUAL + create_comment(create_trader_name(), TREND_BUY, global_bot_count_manual_buy+1);

            bool exit_ok = Open_Position(symbol, OP_BUY, INIT_VOLUME, 0.0, 0.0, comment);
            if(exit_ok)
               printf("("+MASK_MANUAL+")" + symbol + " " + comment);
           }

         if(IS_CONTINUE_TRADING_CYCLE_SEL && global_bot_count_manual_sel > 0 &&
            global_bot_count_manual_sel > 0 && global_max_entry_manual_sel+AMP_DC < bid)
           {
            string comment = MASK_MANUAL + create_comment(create_trader_name(), TREND_SEL, global_bot_count_manual_sel+1);

            bool exit_ok = Open_Position(symbol, OP_SELL, INIT_VOLUME, 0.0, 0.0, comment);
            if(exit_ok)
               printf("("+MASK_MANUAL+")" + symbol + " " + comment);
           }

         if(IS_CONTINUE_TRADING_CYCLE_BUY)
            create_trend_line("NEXT", TimeCurrent() - TIME_OF_ONE_H1_CANDLE, global_min_entry_manual_buy-AMP_DC, TimeCurrent() + TIME_OF_ONE_H1_CANDLE, global_min_entry_manual_buy-AMP_DC, clrBlue);
         if(IS_CONTINUE_TRADING_CYCLE_SEL)
            create_trend_line("NEXT", TimeCurrent() - TIME_OF_ONE_H1_CANDLE, global_max_entry_manual_sel+AMP_DC, TimeCurrent() + TIME_OF_ONE_H1_CANDLE, global_max_entry_manual_sel+AMP_DC, clrRed);
        }
     }

   if(false)
     {
      //-------------------------------------------------------------------------------------------------
      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

      double tp_buy = NormalizeDouble(ask + AMP_TP, digits);
      double tp_sel = NormalizeDouble(bid - AMP_TP, digits);

      double half_row = amp_grid_L100*0.5;
      double ClosePrice = (bid+ask)/2; //iClose(symbol, PERIOD_M1, 1);
      double PRICE_INIT = INIT_CLOSE_W1 - MAX_ROW*amp_grid_L100;

      if((IS_CONTINUE_TRADING_CYCLE_BUY || IS_CONTINUE_TRADING_CYCLE_SEL))
         //Kiểm tra trong lưới có lệnh Buy/Sel hay chưa.
         for(int row = 0; row < MAX_ROW*2; row ++)
           {
            double grid_row_price = PRICE_INIT + row*amp_grid_L100;
            string row_name = "Row_" + appendZero100(row);
              {
               if((grid_row_price - half_row < ClosePrice) && (ClosePrice < grid_row_price + half_row))
                 {
                  string comment_buy = create_comment(TRADER, TREND_BUY, row);
                  string comment_sel = create_comment(TRADER, TREND_SEL, row);


                  bool has_buy = false, has_sel = false;
                  for(int order_idx = 0; order_idx < MAX_ROW; order_idx ++)
                    {
                     string order_comment = OrdersComment[order_idx];
                     if(order_comment == "")
                        continue;

                     if(is_same_symbol(order_comment, comment_buy))
                        has_buy = true;

                     if(is_same_symbol(order_comment, comment_sel))
                        has_sel = true;
                    }

                  if((IS_CONTINUE_TRADING_CYCLE_BUY && has_buy == false) &&
                     ((global_min_entry_buy == 0) || (global_min_entry_buy > 0 && global_min_entry_buy-AMP_DC > ask)))
                    {
                     for(int i = OrdersTotal() - 1; i >= 0; i--)
                        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                           if(is_same_symbol(OrderSymbol(), symbol))
                              if(is_same_symbol(OrderComment(), comment_buy))
                                 has_buy = true;

                     if(has_buy == false)
                       {
                        bool opened_buy = Open_Position(symbol, OP_BUY, INIT_VOLUME, 0.0, tp_buy, comment_buy + "g" + append1Zero(global_bot_count_buy+1));
                        if(opened_buy)
                           InitOrderArr(symbol);
                       }
                    }

                  if((IS_CONTINUE_TRADING_CYCLE_SEL && has_sel == false) &&
                     ((global_max_entry_sel == 0) || (global_max_entry_sel > 0 && global_max_entry_sel+AMP_DC < bid)))
                    {
                     for(int i = OrdersTotal() - 1; i >= 0; i--)
                        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                           if(is_same_symbol(OrderSymbol(), symbol))
                              if(is_same_symbol(OrderComment(), comment_sel))
                                 has_sel = true;

                     if(has_sel == false)
                       {
                        bool opened_sel = Open_Position(symbol, OP_SELL, INIT_VOLUME, 0.0, tp_sel, comment_sel + "g" + append1Zero(global_bot_count_sel+1));
                        if(opened_sel)
                           InitOrderArr(symbol);
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
bool is_play_for_exit_trade()
  {
   return ((global_bot_count_hedg_buy+global_bot_count_hedg_sel > 0) || (global_bot_count_exit_order > 0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProtectAccount(string symbol)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   if(ACC_PROFIT > calcRisk() && is_play_for_exit_trade())
     {
      ClosePosition(symbol, OP_BUY, "");
      ClosePosition(symbol, OP_SELL, "");
     }

   if(global_bot_count_hedg_buy + global_bot_count_hedg_sel == 0)
      if((BALANCE*0.2 + ACC_PROFIT) < 0)
         if(is_main_control_screen())
            do_hedging(symbol);
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


// (Step 2) Những vị thế chưa được HEDG thì tiến hành HEDG.
   if(MathAbs(total_vol_buy - total_vol_sel) > 0.01)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int OP_TYPE = total_vol_buy > total_vol_sel ? OP_SELL : OP_BUY;
      int count = (int)(total_vol_buy > total_vol_sel ? global_bot_count_hedg_sel : global_bot_count_hedg_buy) + 1;
      string TREND_TYPE = total_vol_buy > total_vol_sel ? TREND_SEL : TREND_BUY;

      string hedg_comment = create_comment(MASK_HEDG, TREND_TYPE, count);

      double TP_of_HEDG = OP_TYPE == OP_BUY ? ask + 100 : bid - 100;
      double hedg_volume = MathAbs(total_vol_buy - total_vol_sel);

      bool hedging_ok = Open_Position(symbol, OP_TYPE, hedg_volume, 0.0, TP_of_HEDG, hedg_comment);
      if(hedging_ok)
         SendAlert(symbol, MASK_HEDG, "hedging_ok: " + TREND_TYPE + "    " + (string)hedg_volume + "    " + (string)hedg_volume + "lot.");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol, int OP_TYPE, double volume, double sl, double tp, string comment)
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
   string trend_by_ma10_m5 = get_trend_by_ma(symbol, PERIOD_M5, 10, 1);
   bool allow_append_buy = (trend_by_ma10_m5 == TREND_BUY) && (ask < CENTER_OF_3_DAYS - AMP_SOLVE);
   bool allow_append_sel = (trend_by_ma10_m5 == TREND_BUY) && (bid > CENTER_OF_3_DAYS + AMP_SOLVE);


   string TREND = (ask+bid)/2 < CENTER_OF_3_DAYS ? TREND_BUY : TREND_SEL;
   double draw_price = iClose(symbol, PERIOD_M5, 1);
   double tp_price = TREND == TREND_BUY ? ask + AMP_SOLVE : bid - AMP_SOLVE;
//create_lable("tp_padding_trade", TimeCurrent(), tp_price, " ------------- tp ------------- ", TREND, false);

   string the5 = "";
   double th5percent = BALANCE*0.05;
   double vol_balance = calc_volume_by_amp(symbol, AMP_SOLVE, MathAbs(ACC_PROFIT));
   if(th5percent + ACC_PROFIT < 0)
     {
      the5 = format_double_to_string(th5percent, 1) + "/";
      vol_balance = calc_volume_by_amp(symbol, AMP_SOLVE, MathAbs(th5percent));
     }
   double vol_1usd  = NormalizeDouble(calc_volume_by_amp(symbol, 1, MathAbs(ACC_PROFIT)), 2);
   string str_vol_1usd = "(" + AppendSpaces(format_double_to_string(vol_1usd, 2), 4, false)
                         + "/1$/"+ format_double_to_string((int)ACC_PROFIT, 1)+"$)";


   if(global_bot_count_exit_order == 0)
      vol_balance = INIT_VOLUME;

   lableBtnPaddingTrade = "(" + (string) global_bot_count_exit_order + ") " +
                          AppendSpaces(format_double_to_string(vol_balance, 2), 4, false) +
                          " tp" + (string)AMP_SOLVE +
                          " " + str_vol_1usd;
   if(ACC_PROFIT > 0)
      lableBtnPaddingTrade = "";

   color clrText = clrLightGray;
   if(allow_append_buy || allow_append_sel)
     {
      bool allow_notify_padding_trade = (INIT_TREND_TODAY == TREND_BUY && TREND == TREND_BUY && global_min_exit_price - AMP_SOLVE > bid) ||
                                        (INIT_TREND_TODAY == TREND_BUY && TREND == TREND_SEL && global_max_exit_price + AMP_SOLVE < ask);

      if(allow_notify_padding_trade)
        {
         clrText = allow_append_buy ? clrFireBrick : allow_append_sel ? clrFireBrick : clrLightGray;

         ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0,BtnPaddingTrade, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_COLOR, clrText);

         ObjectSetInteger(0,"tp_padding_trade", OBJPROP_FONTSIZE, 9);
         ObjectSetString(0,"tp_padding_trade", OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0,"tp_padding_trade", OBJPROP_COLOR, clrText);

         //SendAlert(symbol, "PADDING_TRADE", "Allow : " + lableBtnPaddingTrade);
        }
     }

   if(global_bot_count_exit_order == 0)
      clrText = clrLightGray;

   if(trade_now)
     {
      string msg = " " + symbol + " " + lableBtnPaddingTrade + "?\n";
      if(MathAbs(global_bot_vol_buy - global_bot_vol_sel) > INIT_VOLUME)
        {
         vol_balance = NormalizeDouble(MathAbs(global_bot_vol_buy - global_bot_vol_sel), 2);
         double potentialProfit = calcPotentialTradeProfit(symbol, OP_BUY, ask, ask + AMP_SOLVE, vol_balance);
         msg = MASK_HEDG + " " + symbol + " " + (string) vol_balance + " solve: " + format_double_to_string(potentialProfit, 1) + "$?\n";
        }
      if(vol_balance > 0.5)
         vol_balance =0.5;

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
            Alert("(NOT_ALLOW BUY) ALL_TREND :" + all_trend);
            return;
           }

         OP_TYPE = OP_BUY;
         selected_trend = TREND_BUY;
         tp_price = ask + AMP_SOLVE;
        }
      if(result == IDNO)
        {
         if(is_same_symbol(all_trend, TREND_SEL) == false)
           {
            Alert("(NOT_ALLOW SEL) ALL_TREND :" + all_trend);
            return;
           }

         OP_TYPE = OP_SELL;
         selected_trend = TREND_SEL;
         tp_price = bid - AMP_SOLVE;
        }

      if(OP_TYPE != -1 && selected_trend != "")
        {
         string comment = MASK_EXIT + create_comment(create_trader_name(), selected_trend, global_bot_count_exit_order+1);

         bool exit_ok = Open_Position(symbol, OP_TYPE, vol_balance, 0.0, tp_price, comment);
         if(exit_ok)
           {
            ModifyTp_ToEntry(Symbol(),100, TREND_BUY);
            ModifyTp_ToEntry(Symbol(),100, TREND_SEL);
           }
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
void Draw_Buttons()
  {
   DeleteArrowObjects();
   string symbol = Symbol();
   bool draw_common_btn = is_main_control_screen();
   double cur_price = iClose(symbol, PERIOD_M1, 1);

   color clrActiveBtn = clrLightGreen;
   int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 45;
   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   bool is_exit_trade = is_play_for_exit_trade();
   string mask_exit_trade = is_exit_trade ? " ^Ex^" : "";

   double ACC_PROFIT = AccountInfoDouble(ACCOUNT_PROFIT);

   color clrHasProfit = is_same_symbol(lable_profit_positive_orders, "B0") &&
                        is_same_symbol(lable_profit_positive_orders, "S0")
                        ? clrLightGray : clrActiveBtn;
   if(draw_common_btn)
      createButton(BtnClosePositiveOrders, lable_profit_positive_orders + mask_exit_trade, 10, y_ref_btn - 95, 140, 25, clrBlack, clrHasProfit);


   if(draw_common_btn)
      createButton(BtnAutoSL, "Auto SL " + (IS_HAS_AUTO_STOP_LOSS ? "(ON)" : "(OFF)"), 10, y_ref_btn - 65, 140, 25, clrBlack, IS_HAS_AUTO_STOP_LOSS ? clrActiveBtn : clrLightGray);


   int widthBtnProfit = 215;
   int widthBtnAutoTrade = 140;
   if(draw_common_btn == false)
     {
      widthBtnProfit = 185;
      widthBtnAutoTrade = 120;
     }

   color clrNewCycleColorBuy = IS_CONTINUE_TRADING_CYCLE_BUY ? clrActiveBtn : clrLightGray;
   color clrNewCycleColorSel = IS_CONTINUE_TRADING_CYCLE_SEL ? clrActiveBtn : clrLightGray;

   string lableBuy = "DC BUY " + (string)(global_bot_count_manual_buy > 0 ? format_double_to_string(global_min_entry_manual_buy-AMP_DC, Digits-1) : "");
   string lableSel = "DC SEL " + (string)(global_bot_count_manual_sel > 0 ? format_double_to_string(global_max_entry_manual_sel+AMP_DC, Digits-1) : "");

   if(draw_common_btn || lable_profit_buy != "")
      createButton(BtnNewCycleBuy, lableBuy, 10, y_ref_btn - 35, widthBtnAutoTrade, 30, clrBlack, clrNewCycleColorBuy);
   if(draw_common_btn || lable_profit_sel != "")
      createButton(BtnNewCycleSel, lableSel, 10, y_ref_btn,      widthBtnAutoTrade, 30, clrBlack, clrNewCycleColorSel);


   if(draw_common_btn)
      createButton(BtnSolveNegative, lableBtnPaddingTrade, 155, y_ref_btn - 65, widthBtnProfit, 25, clrBlack, clrLightGray, 8);

   color lblColorProfitBuy = StringFind(lable_profit_buy, "-") > 0 ? clrFireBrick : clrBlue;
   color lblColorProfitSel = StringFind(lable_profit_sel, "-") > 0 ? clrFireBrick : clrBlue;
   string wait_trend_h4 = wait_trade_by_stoch(Symbol(), PERIOD_H4);
   if(wait_trend_h4 != "")
     {
      wait_trend_h4 = "(Wait " + wait_trend_h4 + " H4)";

      MqlDateTime vietnamDateTime;
      TimeToStruct(TimeCurrent(), vietnamDateTime);
      int cur_sec = vietnamDateTime.sec;
      create_lable("WAIT", iTime(Symbol(), PERIOD_D1, 0), cur_price, wait_trend_h4, MathMod(cur_sec, 2) == 1 ? TREND_BUY : TREND_SEL, true);

      if(lable_profit_buy == "")
         lable_profit_buy = wait_trend_h4;
      if(lable_profit_sel == "")
         lable_profit_sel = wait_trend_h4;
     }


   if(draw_common_btn)
     {
      createButton(BtnCloseProfitBuy, lable_profit_buy, 155, y_ref_btn - 35, widthBtnProfit, 30, lblColorProfitBuy, lable_profit_buy == "" ? (wait_trend_h4 != "") ? clrBlue : clrLightGray : clrLightSkyBlue);
      createButton(BtnCloseProfitSel, lable_profit_sel, 155, y_ref_btn - 00, widthBtnProfit, 30, lblColorProfitSel, lable_profit_sel == "" ? (wait_trend_h4 != "") ? clrBlue : clrLightGray : clrSeashell);


      double close_d1 = iClose(symbol, PERIOD_D1, 1);
      double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);

      CandleData arrHeiken_h4[];
      get_arr_heiken(Symbol(), PERIOD_H4, arrHeiken_h4);
      CandleData arrHeiken_h1[];
      get_arr_heiken(Symbol(), PERIOD_H1, arrHeiken_h1);
      CandleData arrHeiken_m5[];
      get_arr_heiken(Symbol(), PERIOD_M5, arrHeiken_m5);

      double close_heiken_h4_0 = arrHeiken_h4[0].close;
      string FIND_TREND = "";
      if(arrHeiken_h4[0].trend == TREND_BUY && close_heiken_h4_0 > close_d1)
         FIND_TREND += "H4:" + TREND_BUY;
      if(arrHeiken_h4[0].trend == TREND_SEL && close_heiken_h4_0 < close_d1)
         FIND_TREND += "H4:" + TREND_SEL;

      double close_heiken_h1_0 = arrHeiken_h1[0].close;
      string trend_h1_by_ma10 = get_trend_by_ma(symbol, PERIOD_H1, 10, 0);
      if(trend_h1_by_ma10 == TREND_BUY && arrHeiken_h1[1].trend == TREND_BUY && close_heiken_h1_0 > close_d1)
         FIND_TREND += " H1:" + TREND_BUY;
      if(trend_h1_by_ma10 == TREND_SEL && arrHeiken_h1[1].trend == TREND_SEL && close_heiken_h1_0 < close_d1)
         FIND_TREND += " H1:" + TREND_SEL;


      double risk_10percent = INIT_EQUITY*0.1;
      double volume = calc_volume_by_amp(symbol, FIXED_SL_AMP, risk_10percent);

      bool notify_trade = is_reacts_with_close_d1(symbol);

      string lblTrade10percent =  FIND_TREND + " 10% ("+(string) global_10percent_count +") " + (string)(volume)
                                  + "/" + format_double_to_string(FIXED_SL_AMP, Digits - 1)
                                  + "/" + (string)((int) risk_10percent) + "$";
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

      string trend_102050_15 = get_trend_by_ma10_20_50(symbol, PERIOD_M15);
      string trend_102050_m5 = get_trend_by_ma10_20_50(symbol, PERIOD_M5);
      string trend_102050_m1 = get_trend_by_ma10_20_50(symbol, PERIOD_M1);

      bool allow_buy_now = IS_WAITTING_BUY;
      if(IS_WAITTING_BUY || IS_CONTINUE_TRADING_CYCLE_BUY)
        {
         if(is_same_symbol(allow_trade_now_by_price_closeH4_and_heikenM1(symbol, TREND_BUY), TREND_BUY))
            lblCondH4Price = "OK";
         else
            if(CondH4Price)
               allow_buy_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_H4) == TREND_BUY)
            lblCondH4Stoch8020 = "OK";
         else
            if(CondH4Stoch8020)
               allow_buy_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_H1) == TREND_BUY)
            lblCondH1Stoch8020 = "OK";
         else
            if(CondH1Stoch8020)
               allow_buy_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_M15) == TREND_BUY)
            lblCond15Stoch8020 = "OK";
         else
            if(Cond15Stoch8020)
               allow_buy_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_M5) == TREND_BUY)
            lblCond05Stoch8020 = "OK";
         else
            if(Cond05Stoch8020)
               allow_buy_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_M1) == TREND_BUY)
            lblCond01Stoch8020 = "OK";
         else
            if(Cond01Stoch8020)
               allow_buy_now = false;

         if(arrHeiken_h1[0].trend == TREND_BUY)
            lblCondH1Heiken = "OK";
         else
            if(CondH1Heiken)
               allow_buy_now = false;

         if(trend_102050_15 == TREND_BUY)
            lblCond15Seq125 = "OK";
         else
            if(Cond15Seq125)
               allow_buy_now = false;

         if(trend_102050_m5 == TREND_BUY)
            lblCond05Seq125 = "OK";
         else
            if(Cond05Seq125)
               allow_buy_now = false;

         if(trend_102050_m1 == TREND_BUY)
            lblCond01Seq125 = "OK";
         else
            if(Cond01Seq125)
               allow_buy_now = false;
        }

      if(IS_WAITTING_BUY && allow_buy_now)
        {
         if((global_tcount_buy == 0) || (global_10percent_min_open_price > 0 && global_10percent_min_open_price - FIXED_SL_AMP/2 > cur_price))
           {
            double volume_buy = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, risk_10percent);
            string comment = create_comment(MASK_HAVE_SL, TREND_BUY, 1);
            double tp_price_buy = calc_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);

            tp_price_buy = 0;
            bool exit_ok = Open_Position(Symbol(), OP_BUY, volume_buy, 0.0, tp_price_buy, comment);

            if(exit_ok)
              {
               IS_WAITTING_BUY = false;
               SendTelegramMessage(symbol, TREND_BUY, "(ALERT_BUY)" + MASK_HAVE_SL + Symbol() + " " + comment + lblTrade10percent);
              }
           }

        }
      //-------------------------------------------------------------------------------------

      bool allow_sel_now = IS_WAITTING_SEL;
      if(IS_WAITTING_SEL || IS_CONTINUE_TRADING_CYCLE_SEL)
        {
         if(is_same_symbol(allow_trade_now_by_price_closeH4_and_heikenM1(symbol, TREND_SEL), TREND_SEL))
            lblCondH4Price = "OK";
         else
            if(CondH4Price)
               allow_sel_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_H4) == TREND_SEL)
            lblCondH4Stoch8020 = "OK";
         else
            if(CondH4Stoch8020)
               allow_sel_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_H1) == TREND_SEL)
            lblCondH1Stoch8020 = "OK";
         else
            if(CondH1Stoch8020)
               allow_sel_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_M15) == TREND_SEL)
            lblCond15Stoch8020 = "OK";
         else
            if(Cond15Stoch8020)
               allow_sel_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_M5) == TREND_SEL)
            lblCond05Stoch8020 = "OK";
         else
            if(Cond05Stoch8020)
               allow_sel_now = false;

         if(wait_trade_by_stoch(symbol, PERIOD_M1) == TREND_SEL)
            lblCond01Stoch8020 = "OK";
         else
            if(Cond01Stoch8020)
               allow_sel_now = false;

         if(arrHeiken_h1[0].trend == TREND_SEL)
            lblCondH1Heiken = "OK";
         else
            if(CondH1Heiken)
               allow_sel_now = false;

         if(trend_102050_15 == TREND_SEL)
            lblCond15Seq125 = "OK";
         else
            if(Cond15Seq125)
               allow_sel_now = false;

         if(trend_102050_m5 == TREND_SEL)
            lblCond05Seq125 = "OK";
         else
            if(Cond05Seq125)
               allow_sel_now = false;

         if(trend_102050_m1 == TREND_SEL)
            lblCond01Seq125 = "OK";
         else
            if(Cond01Seq125)
               allow_sel_now = false;
        }


      if(IS_WAITTING_SEL && allow_sel_now)
        {
         if((global_tcount_sel == 0) || (global_10percent_max_open_price > 0 && global_10percent_max_open_price + FIXED_SL_AMP/2 < cur_price))
           {
            double volume_sel = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, risk_10percent);
            string comment = create_comment(MASK_HAVE_SL, TREND_SEL, 1);
            double tp_price_sel = calc_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
            tp_price_sel = 0;
            bool exit_ok = Open_Position(Symbol(), OP_SELL, volume_sel, 0.0, tp_price_sel, comment);
            if(exit_ok)
              {
               IS_WAITTING_SEL = false;
               Alert(MASK_HAVE_SL + Symbol() + " " + comment);

               SendTelegramMessage(symbol, TREND_BUY, "(ALERT_SEL)" + MASK_HAVE_SL + Symbol() + " " + comment + lblTrade10percent);
              }
           }
        }
      //-------------------------------------------------------------------------------------
      int start_y_cond = 125;
      string TREND_COND = IS_WAITTING_BUY ? TREND_BUY : IS_WAITTING_SEL ? TREND_SEL : "";
      lblCondH1Heiken    = getShortName(arrHeiken_h1[0].trend) + " " + lblCondH1Heiken;
      lblCondH4Stoch8020 = getShortName(get_trend_by_stoc2(symbol, PERIOD_H4,  3, 2, 3, 0)) + " " + lblCondH4Stoch8020;
      lblCondH1Stoch8020 = getShortName(get_trend_by_stoc2(symbol, PERIOD_H1,  3, 2, 3, 0)) + " " + lblCondH1Stoch8020;
      lblCond15Stoch8020 = getShortName(get_trend_by_stoc2(symbol, PERIOD_M15, 3, 2, 3, 0)) + " " + lblCond15Stoch8020;
      lblCond05Stoch8020 = getShortName(get_trend_by_stoc2(symbol, PERIOD_M5,  3, 2, 3, 0)) + " " + lblCond05Stoch8020;
      lblCond01Stoch8020 = getShortName(get_trend_by_stoc2(symbol, PERIOD_M1,  3, 2, 3, 0)) + " " + lblCond01Stoch8020;

      createButton(BtnResetCond10per,  "Reset Cond " + TREND_COND + " 10%",  10, start_y_cond + 0*30, 165, 25, clrBlack, clrLightGray, 7);
      createButton(BtnCondH4Price,     "H4 Clo " + lblCondH4Price,  10, start_y_cond + 1*30, 80, 25, clrBlack, CondH4Price     ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCondH4Stoch8020, "H4 Sto " + lblCondH4Stoch8020,  95, start_y_cond + 1*30, 80, 25, clrBlack, CondH4Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCondH1Heiken,    "H1 Hei " + lblCondH1Heiken, 10, start_y_cond + 2*30, 80, 25, clrBlack, CondH1Heiken    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCondH1Stoch8020, "H1 Sto " + lblCondH1Stoch8020,  95, start_y_cond + 2*30, 80, 25, clrBlack, CondH1Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond15Seq125,    "15 " + getShortName(trend_102050_15) + " " + lblCond15Seq125, 10, start_y_cond + 3*30, 80, 25, clrBlack, Cond15Seq125    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond15Stoch8020, "15 Sto " + lblCond15Stoch8020,  95, start_y_cond + 3*30, 80, 25, clrBlack, Cond15Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond05Seq125,    "05 " + getShortName(trend_102050_m5) + " " + lblCond05Seq125, 10, start_y_cond + 4*30, 80, 25, clrBlack, Cond05Seq125    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond05Stoch8020, "05 Sto " + lblCond05Stoch8020,  95, start_y_cond + 4*30, 80, 25, clrBlack, Cond05Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond01Seq125,    "01 " + getShortName(trend_102050_m1) + " " + lblCond01Seq125, 10, start_y_cond + 5*30, 80, 25, clrBlack, Cond01Seq125    ? clrActiveBtn : clrLightGray, 7);
      createButton(BtnCond01Stoch8020, "01 Sto " + lblCond01Stoch8020,  95, start_y_cond + 5*30, 80, 25, clrBlack, Cond01Stoch8020 ? clrActiveBtn : clrLightGray, 7);
      //-------------------------------------------------------------------------------------
      //-------------------------------------------------------------------------------------
      createButton(BtnTradeWithStopLoss,lblTrade10percent, 375, y_ref_btn - 65, 315, 25, clrBlack,
                   global_10percent_count > 0 ? clrLightSkyBlue : (notify_trade ? clrYellowGreen : clrLightGray));

      createButton(BtnWaitBuy10Per, "Wait B10%", 375, y_ref_btn - 35, 80, 30, clrBlack, IS_WAITTING_BUY ? clrActiveBtn : clrLightGray);
      createButton(BtnWaitSel10Per, "Wait S10%", 375, y_ref_btn - 00, 80, 30, clrBlack, IS_WAITTING_SEL ? clrActiveBtn : clrLightGray);

      double volume_1percent = calc_volume_by_amp(symbol, FIXED_SL_AMP, INIT_EQUITY*0.01);
      createButton(BtnBuyNow1Per, "("+(string) global_bot_count_manual_buy+") B1% " + format_double_to_string(volume_1percent, 2), 460, y_ref_btn - 35, 100, 30, clrBlack, global_bot_count_manual_buy == 0 ? clrLightGray : clrLightSkyBlue);
      createButton(BtnSelNow1Per, "("+(string) global_bot_count_manual_sel+") S1% " + format_double_to_string(volume_1percent, 2), 460, y_ref_btn - 00, 100, 30, clrBlack, global_bot_count_manual_sel == 0 ? clrLightGray : clrSeashell);

      if(notify_trade)
        {
         ObjectSetString(0,BtnTradeWithStopLoss, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, BtnTradeWithStopLoss, OBJPROP_COLOR, clrBlue);
         if(FIND_TREND == TREND_BUY)
            ObjectSetInteger(0, BtnBuyNow1Per, OBJPROP_BGCOLOR, clrYellowGreen);
         if(FIND_TREND == TREND_SEL)
            ObjectSetInteger(0, BtnSelNow1Per, OBJPROP_BGCOLOR, clrYellowGreen);
        }

      createButton(BtnHedgBuy2Sel, "(" + (string) global_bot_count_hedg_buy + ") hg B", 565, y_ref_btn - 35, 60, 30, clrBlack, (global_bot_count_hedg_buy == 0) ? clrLightGray : clrLightSkyBlue);
      createButton(BtnHedgSel2Buy, "(" + (string) global_bot_count_hedg_sel + ") hg S", 565, y_ref_btn - 00, 60, 30, clrBlack, (global_bot_count_hedg_sel == 0) ? clrLightGray : clrSeashell);

      createButton(BtnSetEntryBuy, "(" + (string) global_bot_count_tp_eq_en_buy + ") tp B", 630, y_ref_btn - 35, 60, 30, clrBlack, global_bot_count_tp_eq_en_buy == 0 ? clrLightGray : clrLightSkyBlue);
      createButton(BtnSetEntrySel, "(" + (string) global_bot_count_tp_eq_en_sel + ") tp S", 630, y_ref_btn - 00, 60, 30, clrBlack, global_bot_count_tp_eq_en_sel == 0 ? clrLightGray : clrSeashell);

      //---------------------------------------------------------------------------

      datetime time_d0 = iTime(symbol, PERIOD_D1, 0);
      datetime time_d1 = iTime(symbol, PERIOD_D1, 1);
      double hig_d1 = iHigh(symbol,    PERIOD_D1, 1);
      double low_d1 = iLow(symbol,     PERIOD_D1, 1);
      double hig_d0 = iHigh(symbol,    PERIOD_D1, 0);
      double low_d0 = iLow(symbol,     PERIOD_D1, 0);
      color clrTrendD1 = cur_price > close_d1 ? clrBlue : clrRed;
      string strTrendD1 = cur_price > close_d1 ? TREND_BUY : TREND_SEL;

      create_lable("open_d0", TimeCurrent(), close_d1, "               (D0.0)", strTrendD1, false);
      create_trend_line("trend_d1", time_d0, close_d1, TimeCurrent(), cur_price, clrTrendD1, STYLE_SOLID, 2);
      create_trend_line("close_d1", time_d0, close_d1, TimeCurrent(), close_d1,  clrTrendD1, STYLE_SOLID, 2);

      create_lable("hig_d0", TimeCurrent(), hig_d0, "H " + format_double_to_string(hig_d0 - close_d1, Digits-1) + "" + (string)(" ("+format_double_to_string(hig_d0-low_d0, Digits-1)+")"), TREND_BUY);
      create_lable("low_d0", TimeCurrent(), low_d0, "L " + format_double_to_string(close_d1 - low_d0, Digits-1) + "" + (string)(" ("+format_double_to_string(low_d0-hig_d0, Digits-1)+")"), TREND_SEL);

      create_trend_line("line_hig_d1", iTime(symbol, PERIOD_D1, 1), hig_d1, time_d0, hig_d1, clrBlue, STYLE_SOLID);
      create_trend_line("line_low_d1", iTime(symbol, PERIOD_D1, 1), low_d1, time_d0, low_d1, clrRed,  STYLE_SOLID);
      create_lable("hig_d1", time_d1, hig_d1, "H " + format_double_to_string(hig_d1 - low_d1, Digits-1), TREND_BUY);
      create_lable("low_d1", time_d1, low_d1, "L " + format_double_to_string(hig_d1 - low_d1, Digits-1), TREND_SEL);
      create_trend_line("line_hig_d0", time_d0, hig_d0, TimeCurrent(), hig_d0, clrBlue, STYLE_SOLID);
      create_trend_line("line_low_d0", time_d0, low_d0, TimeCurrent(), low_d0, clrRed,  STYLE_SOLID);

      string strLable_trend_d1 = "              " ;
      strLable_trend_d1 += format_double_to_string(cur_price - close_d1, Digits-1) + "";
      strLable_trend_d1 += "(+" + format_double_to_string((cur_price-low_d0), Digits-1);
      strLable_trend_d1 += " " + format_double_to_string((cur_price-hig_d0), Digits-1) + ")";
      strLable_trend_d1 += create_Cno();

      create_lable("cur_price", TimeCurrent(), cur_price, strLable_trend_d1, strTrendD1, false);
      ObjectSetInteger(0,"cur_price", OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0,"cur_price", OBJPROP_COLOR, clrTrendD1);

      create_vertical_line("now", TimeCurrent(), clrSilver, STYLE_SOLID);

      if(Period() < PERIOD_H4)
        {
         double open_w0 = iOpen(Symbol(), PERIOD_W1, 0);
         create_lable("open_w0", iTime(symbol, PERIOD_W1, 0), open_w0-1,
                      (cur_price > open_w0 ? "W0(+" : "W0(-") + format_double_to_string(MathAbs(cur_price - open_w0), Digits-1) + ")",
                      cur_price > open_w0 ? TREND_BUY : TREND_SEL, true);
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
        }

      if(Period() == PERIOD_M1)
        {
         string cNo = create_Cno();
         create_lable("No", TimeCurrent(), cur_price, cNo, "");
         ObjectSetInteger(0,"No", OBJPROP_FONTSIZE, 10);
         ObjectSetInteger(0,"No", OBJPROP_TIMEFRAMES, OBJ_PERIOD_M1);
        }

      if(IS_CONTINUE_TRADING_CYCLE_BUY && strTrendD1 == TREND_BUY && MathAbs(cur_price-low_d0) > 25)
        {
         IS_CONTINUE_TRADING_CYCLE_BUY = false;
         saveAutoTrade();
         ModifyTp_ToEntry(symbol, 1, TREND_BUY);
         SendAlert(symbol, TREND_BUY, "Exit BUY by (cur_price-low_d0)gt25$");
        }

      if(IS_CONTINUE_TRADING_CYCLE_SEL && strTrendD1 == TREND_SEL && MathAbs(hig_d0-cur_price) > 25)
        {
         IS_CONTINUE_TRADING_CYCLE_SEL = false;
         saveAutoTrade();
         ModifyTp_ToEntry(symbol, 1, TREND_SEL);
         SendAlert(symbol, TREND_BUY, "Exit SEL by (hig_d0-cur_price)gt25$");
        }
     }
   else
      deleteIndicatorsWindows();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string allow_trade_now_by_price_closeH4_and_heikenM1(string symbol, string find_trend)
  {
   double cur_price = iClose(symbol, PERIOD_M1, 1);

   CandleData arrHeiken_h4[];
   get_arr_heiken(Symbol(), PERIOD_H4, arrHeiken_h4);

   if(find_trend == TREND_BUY)
     {
      bool pass_price_h4 = true;
      for(int i = 0; i < 10; i++) //ArraySize(arrHeiken_h4)
        {
         double close = arrHeiken_h4[i].close;
         if(close < cur_price)
            pass_price_h4 = false;
        }

      if(pass_price_h4)
        {
         CandleData arrHeiken_m5[];
         get_arr_heiken(Symbol(), PERIOD_M1, arrHeiken_m5);

         if(arrHeiken_m5[0].trend == TREND_BUY)
            return TREND_BUY;
        }
     }
//------------------------------------------------
   if(find_trend == TREND_SEL)
     {
      bool pass_price_h4 = true;
      for(int i = 0; i < 10; i++) //ArraySize(arrHeiken_h4)
        {
         double close = arrHeiken_h4[i].close;
         if(close > cur_price)
            pass_price_h4 = false;
        }

      if(pass_price_h4)
        {
         CandleData arrHeiken_m5[];
         get_arr_heiken(Symbol(), PERIOD_M1, arrHeiken_m5);

         if(arrHeiken_m5[0].trend == TREND_SEL)
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
string getTrendFiltering(string symbol)
  {
   CandleData arrHeiken_d1[];
   get_arr_heiken(Symbol(), PERIOD_D1, arrHeiken_d1);
   CandleData arrHeiken_h4[];
   get_arr_heiken(Symbol(), PERIOD_H4, arrHeiken_h4);
   CandleData arrHeiken_h1[];
   get_arr_heiken(Symbol(), PERIOD_H1, arrHeiken_h1);

   double ma10_d1 = cal_MA_XX(Symbol(), PERIOD_D1, 10, 0);
   double ma10_h4 = cal_MA_XX(Symbol(), PERIOD_H4, 10, 0);
   double ma20_h1 = cal_MA_XX(Symbol(), PERIOD_H1, 20, 0);
   double ma10_h1 = cal_MA_XX(Symbol(), PERIOD_H1, 10, 0);

   string result = "";
   result += " Heiken_D1[0]: " + arrHeiken_d1[0].trend;
   result += "    Ma10[0]: " + (arrHeiken_d1[0].close > ma10_d1 ? TREND_BUY : TREND_SEL);
   result += "    StocD1[3]: " + get_trend_by_stoc2(symbol, PERIOD_D1, 3, 2, 3, 0) + "\n";

   result += " Heiken_H4[0]: " + arrHeiken_h4[0].trend;
   result += "    Ma10[0]: " + (arrHeiken_h4[0].close > ma10_h4 ? TREND_BUY : TREND_SEL);
   result += "    StocH4[3]: " + get_trend_by_stoc2(symbol, PERIOD_H4, 3, 2, 3, 0) + "\n";

   result += " Heiken_H1[0]: " + arrHeiken_h1[0].trend;
   result += "    Ma10[0]: " + (arrHeiken_h1[0].close > ma10_h1 ? TREND_BUY : TREND_SEL);
   result += "    StocH1[3]: " + get_trend_by_stoc2(symbol, PERIOD_H1, 3, 2, 3, 0) + "\n";

   return result;
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
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == BtnAutoSL)
        {
         IS_HAS_AUTO_STOP_LOSS = !IS_HAS_AUTO_STOP_LOSS;
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnHedgBuy2Sel || sparam == BtnHedgSel2Buy)
        {
         string msg = Symbol() + "    Hedging?\n";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
            do_hedging(Symbol());
        }

      if(sparam == BtnSetEntryBuy || sparam == BtnSetEntrySel)
        {
         double best_tp = 0;
         string find_trend = "";
         if(sparam == BtnSetEntryBuy)
           {
            find_trend = TREND_BUY;
            best_tp = global_max_entry_buy + AMP_TP;
           }
         if(sparam == BtnSetEntrySel)
           {
            find_trend = TREND_SEL;
            best_tp = global_min_entry_sel - AMP_TP;
           }

         string msg =  Symbol() + " Set TP " + find_trend + "?\n";
         msg += "    (YES) TP=EntryPrice+"+(string) AMP_TP + "\n";
         msg += "    (NO) BestTP="+(string) best_tp + "\n";

         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
            ModifyTp_ToEntry(Symbol(),AMP_TP, find_trend);

         if(result == IDNO)
            ModifyTp_ToTPPrice(Symbol(),best_tp, find_trend);
        }

      if(sparam == BtnPaddingTrade || sparam == BtnSolveNegative)
        {
         Solve_Negative(Symbol(), true);
        }

      if(sparam == BtnResetCond10per)
        {
         CondH4Price     = false;
         CondH1Heiken    = false;
         Cond15Seq125    = false;
         Cond05Seq125    = false;
         Cond01Seq125    = false;

         CondH4Stoch8020 = true;
         CondH1Stoch8020 = true;
         Cond15Stoch8020 = false;
         Cond05Stoch8020 = true;
         Cond01Stoch8020 = true;

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
        }

      if(sparam == BtnCondH4Price)
        {
         CondH4Price = !CondH4Price;
         GlobalVariableSet("CondH4Price", CondH4Price);
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
         IS_WAITTING_BUY = !IS_WAITTING_BUY;
         if(IS_WAITTING_BUY && IS_WAITTING_SEL)
            IS_WAITTING_SEL = false;
        }

      if(sparam == BtnWaitSel10Per)
        {
         IS_WAITTING_SEL = !IS_WAITTING_SEL;
         if(IS_WAITTING_BUY && IS_WAITTING_SEL)
            IS_WAITTING_BUY = false;
        }

      if(sparam == BtnNewCycleBuy)
        {
         if(IS_CONTINUE_TRADING_CYCLE_BUY == false)
           {
            string all_trend = getTrendFiltering(Symbol());
            if(is_same_symbol(all_trend, TREND_BUY) == false)
              {
               Alert("(NOT_ALLOW BUY) ALL_TREND :" + all_trend);
               return;
              }
           }

         Print("The ", sparam," was clicked, IS_CONTINUE_TRADING_CYCLE_BUY=" + (string)IS_CONTINUE_TRADING_CYCLE_BUY);
         IS_CONTINUE_TRADING_CYCLE_BUY = !IS_CONTINUE_TRADING_CYCLE_BUY;
         if(IS_CONTINUE_TRADING_CYCLE_BUY)
            IS_CONTINUE_TRADING_CYCLE_SEL = false;

         Print("IS_CONTINUE_TRADING_CYCLE_BUY ->" + (string)IS_CONTINUE_TRADING_CYCLE_BUY);
         saveAutoTrade();
        }

      if(sparam == BtnNewCycleSel)
        {
         if(IS_CONTINUE_TRADING_CYCLE_SEL == false)
           {
            string all_trend = getTrendFiltering(Symbol());
            if(is_same_symbol(all_trend, TREND_SEL) == false)
              {
               Alert("(NOT_ALLOW SEL) ALL_TREND :" + all_trend);
               return;
              }
           }

         Print("The ", sparam," was clicked, IS_CONTINUE_TRADING_CYCLE_SEL=" + (string)IS_CONTINUE_TRADING_CYCLE_SEL);
         IS_CONTINUE_TRADING_CYCLE_SEL = !IS_CONTINUE_TRADING_CYCLE_SEL;
         if(IS_CONTINUE_TRADING_CYCLE_SEL)
            IS_CONTINUE_TRADING_CYCLE_BUY = false;

         Print("IS_CONTINUE_TRADING_CYCLE_SEL ->" + (string)IS_CONTINUE_TRADING_CYCLE_SEL);
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
         string msg = "CLOSE_ALL " + Symbol() + "  " + lable_profit_buy;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            IS_CONTINUE_TRADING_CYCLE_BUY = false;
            saveAutoTrade();

            ClosePosition(Symbol(), OP_BUY, TREND_BUY);
            OnTimer();
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnCloseProfitSel)
        {
         string msg = "CLOSE_ALL " + Symbol() + "  " + lable_profit_sel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            IS_CONTINUE_TRADING_CYCLE_SEL = false;
            saveAutoTrade();

            ClosePosition(Symbol(), OP_SELL, TREND_SEL);
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnBuyNow1Per || sparam == BtnSelNow1Per)
        {
         double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         double cur_price = (bid+ask)/2;
         string all_trend = getTrendFiltering(Symbol());

         double volume_1percent = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, INIT_EQUITY*0.01);
         string find_trend = sparam == BtnBuyNow1Per ? TREND_BUY : TREND_SEL;
         double tp_price = 0;
         double amp_tp = 0;
         if(find_trend == TREND_BUY)
           {
            tp_price = calc_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);
            amp_tp = tp_price - cur_price;
           }
         if(find_trend == TREND_SEL)
           {
            tp_price = calc_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
            amp_tp = cur_price - tp_price;
           }

         string msg = " Manual " + find_trend + " " + Symbol() + "\n";
         msg += " AmpSL: " + (string)FIXED_SL_AMP + "$    Vol(1%): " + (string)volume_1percent + "lot ";
         msg += "   TP: " + format_double_to_string(tp_price, Digits-1);
         msg += "   AmpTp: " + format_double_to_string(amp_tp, Digits-1) + "\n";
         msg += all_trend + "\n\n";
         msg += "    (YES) "+ find_trend + " " + (string)volume_1percent+" (lot) AmpTP: "+(string) AMP_SOLVE+"$ "+(INIT_TREND_TODAY == TREND_BUY ? "= MACD(H4)" : "")+"\n";
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
               //if(is_same_symbol(all_trend, TREND_BUY) == false)
               //  {
               //   StringReplace(all_trend, "\n", "");
               //   Alert("(NOT_ALLOW BUY) ALL_TREND :" + all_trend);
               //   return;
               //  }

               OP_TYPE = OP_BUY;
               selected_trend = TREND_BUY;

               count += global_bot_count_manual_buy;
              }

            if(sparam == BtnSelNow1Per)
              {
               //if(is_same_symbol(all_trend, TREND_SEL) == false)
               //{
               // StringReplace(all_trend, "\n", "");
               // Alert("(NOT_ALLOW SEL) ALL_TREND :" + all_trend);
               // return;
               //}

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
            tp_price_buy = calc_tp_by_fixed_sl_amp(Symbol(), TREND_BUY);
            amp_tp_buy = tp_price_buy - cur_price;
           }
           {
            tp_price_sel = calc_tp_by_fixed_sl_amp(Symbol(), TREND_SEL);
            amp_tp_sel = cur_price - tp_price_sel;
           }


         double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);

         double trend_ma10_h1 = cal_MA_XX(Symbol(), PERIOD_H1, 10, 0);
         string FIND_TREND = trend_ma10_h1 > close_d1 ? TREND_BUY : TREND_SEL;

         double risk_10percent = INIT_EQUITY*0.1;
         double volume = calc_volume_by_amp(Symbol(), FIXED_SL_AMP, risk_10percent);

         string lblTrade10percent = "";
         lblTrade10percent += "   AmpSL: " + (string)FIXED_SL_AMP + "$        Vol(10%): " + (string)volume + "lot\n";
         lblTrade10percent += "   TPBuy: " + format_double_to_string(tp_price_buy, Digits-1);
         lblTrade10percent += "   AmpTpBuy: " + format_double_to_string(amp_tp_buy, Digits-1) + "\n";
         lblTrade10percent += "   TPSell: " + format_double_to_string(tp_price_sel, Digits-1);
         lblTrade10percent += "   AmpTpSell: " + format_double_to_string(amp_tp_sel, Digits-1) + "\n";

         string msg = " TradeWithStopLoss " + " " + Symbol() + "    (Count 10%: "+(string) global_10percent_count +") \n" + lblTrade10percent + "\n";
         msg += getTrendFiltering(Symbol())+ "\n\n";
         msg += "    (YES) BUY " + (string)volume+" (lot) AmpSL: " + format_double_to_string(FIXED_SL_AMP, Digits-1) + "$ "+(INIT_TREND_TODAY == TREND_BUY ? "= MACD(H4)" : "")+"\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, TREND_BUY) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, TREND_BUY) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, TREND_BUY) + "\n";
         msg += "    (NO) SELL " + (string)volume+" (lot) AmpSL: " + format_double_to_string(FIXED_SL_AMP, Digits-1) + "$ "+(INIT_TREND_TODAY == TREND_SEL ? "= MACD(H4)" : "")+"\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_D1, TREND_SEL) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H4, TREND_SEL) + "\n";
         msg += "            " + check_stoch_before_trade(Symbol(), PERIOD_H1, TREND_SEL) + "\n";

         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);

         int OP_TYPE = -1;
         int count = 1;
         string selected_trend = "";
         double tp_price = 0;
         if(result == IDYES)
           {
            if(is_same_symbol(all_trend, TREND_BUY) == false)
              {
               StringReplace(all_trend, "\n", "");
               Alert("(NOT_ALLOW BUY) ALL_TREND :" + all_trend);
               return;
              }

            OP_TYPE = OP_BUY;
            tp_price = tp_price_buy;
            selected_trend = TREND_BUY;
            count += global_10percent_count;
           }
         if(result == IDNO)
           {
            if(is_same_symbol(all_trend, TREND_SEL) == false)
              {
               StringReplace(all_trend, "\n", "");
               Alert("(NOT_ALLOW SEL) ALL_TREND :" + all_trend);
               return;
              }

            OP_TYPE = OP_SELL;
            tp_price = tp_price_sel;
            selected_trend = TREND_SEL;
            count += global_10percent_count;
           }

         if(OP_TYPE != -1 && selected_trend != "")
           {
            string comment = create_comment(MASK_HAVE_SL, selected_trend, count);
            tp_price = 0;
            bool exit_ok = Open_Position(Symbol(), OP_TYPE, volume, 0.0, tp_price, comment);
            if(exit_ok)
               Alert(MASK_HAVE_SL + Symbol() + " " + comment);
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
double calc_tp_by_fixed_sl_amp(string symbol, string TREND)
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

   if(potential_profit < calcRisk())
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
               if(price > best_tpprice)
                  close_now = true;
              }
            if(OrderType() == OP_SELL)
              {
               price = bid;
               close_now_price = ask;
               if(price < best_tpprice)
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
void ModifyTp_ToEntry(string symbol, double added_amp_tp, string KEY_TO_CLOSE)
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
                     //Alert("close_now close_now_price");
                    }
                 }
               else
                  ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0);

               demm++;
               Sleep(100);
              }

           }
     } //for
   if(has_modify)
      SendAlert(symbol, KEY_TO_CLOSE, "ModifyTp_ToEntry Ok");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ForPotentialProfit(string symbol, int order_type, double added_amp_tp, string KEY_TO_CLOSE, double old_tp_price)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
            if(is_same_symbol(OrderComment(), KEY_TO_CLOSE))
               if(OrderType() == order_type)
                  if(OrderTakeProfit() != old_tp_price)
                     if(is_same_symbol(OrderComment(), LOCK) == false &&
                        is_same_symbol(OrderComment(), "B2S") == false &&
                        is_same_symbol(OrderComment(), "S2B") == false)
                       {
                        double tp_price = OrderTakeProfit();
                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);

                        if(OrderType() == OP_BUY)
                          {
                           tp_price += added_amp_tp;
                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                          }
                        if(OrderType() == OP_SELL)
                          {
                           tp_price -= added_amp_tp;
                           price = SymbolInfoDouble(symbol, SYMBOL_BID);
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
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifySL(string symbol, string TRADING_TREND, double sl_price, string KEY_TO_CLOSE)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(OrderStopLoss() != sl_price)
                  if(is_same_symbol(OrderComment(), LOCK) == false &&
                     is_same_symbol(OrderComment(), "B2S") == false &&
                     is_same_symbol(OrderComment(), "S2B") == false)
                    {
                     double price = 0.0;
                     if(OrderType() == OP_SELL)
                       {
                        price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                        if(price >= OrderOpenPrice())
                           price = 0.0;
                       }

                     if(OrderType() == OP_BUY)
                       {
                        price = SymbolInfoDouble(symbol, SYMBOL_BID);
                        if(price <= OrderOpenPrice())
                           price = 0.0;
                       }

                     int ross=0, demm = 1;
                     while(ross<=0 && demm<20)
                       {
                        ross=OrderModify(OrderTicket(),price,sl_price,OrderTakeProfit(),0,clrBlue);
                        demm++;
                        Sleep(100);
                       }
                    }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, int ordertype, string TRADER)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && OrderType() == ordertype)
            if((TRADER == "") || is_same_symbol(OrderComment(), TRADER))
              {
               int demm = 1;
               while(demm<20)
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if(OrderType() == OP_BUY && is_same_symbol(OrderComment(), TREND_BUY))
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                     if(successful)
                        break;
                    }

                  if(OrderType() == OP_SELL && is_same_symbol(OrderComment(), TREND_SEL))
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
void ClosePositivePosition(string symbol, string TRADER)
  {
   double min_profit = calcRisk()*0.1;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderProfit() > min_profit))
            if((TRADER == "") || is_same_symbol(OrderComment(), TRADER))
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
void SendTelegramMessage(string symbol, string trend, string message)
  {
   if(is_main_control_screen() == false)
      return;

   string date_time = time2string(iTime(symbol, PERIOD_H4, 0));
   string key = date_time;//;

   string send_telegram_today = ReadFileContent(FILE_NAME_SEND_MSG);
   if(StringFind(send_telegram_today, key) >= 0)
      return;
   WriteFileContent(FILE_NAME_SEND_MSG, "Telegram: " + key + " " + symbol + " " + trend + " " + message + "; " + send_telegram_today);



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

   string content = (string) iTime(Symbol(), PERIOD_H1, 0) + "~";
   content += "AUTO_BUY:" + (string) IS_CONTINUE_TRADING_CYCLE_BUY + "~";
   content += "AUTO_SEL:" + (string) IS_CONTINUE_TRADING_CYCLE_SEL + "~";
   WriteFileContent(FILE_NAME_AUTO_TRADE, content);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadAutoTrade()
  {
   string content = ReadFileContent(FILE_NAME_AUTO_TRADE);
   string cur_time = (string) iTime(Symbol(), PERIOD_H1, 0) + "~";
   string str_auto_buy = "AUTO_BUY:" + (string) true + "~";
   string str_auto_sel = "AUTO_SEL:" + (string) true + "~";
   if(is_same_symbol(content, cur_time))
     {
      IS_CONTINUE_TRADING_CYCLE_BUY = is_same_symbol(content, str_auto_buy);
      IS_CONTINUE_TRADING_CYCLE_SEL = is_same_symbol(content, str_auto_sel);
      PRICE_START_TRADE = iClose(Symbol(), PERIOD_M5, 1);
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
void GetHighestLowestM5Times(datetime timeStart, datetime timeEnd)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   string vnhig_d1 = "hig_" + time2string(timeStart);
   string vnlow_d1 = "low_" + time2string(timeStart);
   if(Period() < PERIOD_H1 && !is_sunday(timeStart))
     {
      int i = 0;
      while(true)
        {
         datetime candleTime = iTime(NULL, PERIOD_M5, i);
         if(candleTime < timeStart)
            break;

         if(candleTime >= timeEnd)
           {
            i++;
            continue;
           }

         double high = iHigh(NULL, PERIOD_M5, i);
         double low = iLow(NULL, PERIOD_M5, i);

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

      create_lable(vnhig_d1, highestTime, highestPrice, convert2vntime(highestTime) + " (" + format_double_to_string(highestPrice-lowestPrice, Digits - 2) + ")", "");
      create_lable(vnlow_d1, lowestTime,  lowestPrice,  convert2vntime(lowestTime)  + " (" + format_double_to_string(highestPrice-lowestPrice, Digits - 2) + ")", "");
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
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe,
      string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";

   double macd_0=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,0);
   double macd_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,1);
   double sign_0=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,0);
   double sign_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,1);

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_by_macd = TREND_BUY;

   if(macd_0 <= 0 && sign_0 <= 0)
      trend_by_macd = TREND_SEL;

   if(macd_0 >= sign_0 && macd_1 >= sign_1 && macd_0 >= macd_1)
      trend_mac_vs_signal = TREND_BUY;

   if(macd_0 <= sign_0 && macd_1 <= sign_1 && macd_0 <= macd_1)
      trend_mac_vs_signal = TREND_SEL;

   if(macd_0 >= 0 && macd_1 >= 0)
      trend_mac_vs_zero = TREND_BUY;

   if(macd_0 <= 0 && macd_1 <= 0)
      trend_mac_vs_zero = TREND_SEL;
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

   double h4_bla_K_323 = iStochastic(symbol,TIMEFRAME,3,2,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_323 = iStochastic(symbol,TIMEFRAME,3,2,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double h4_bla_K_853 = iStochastic(symbol,TIMEFRAME,8,5,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_853 = iStochastic(symbol,TIMEFRAME,8,5,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   if(find_trend == TREND_BUY)
      if(h4_bla_K_323 >= 80 || h4_red_D_323 >= 80 || h4_bla_K_853 >= 80 || h4_red_D_853 >= 80)
         msg = "BUY is not allowed. Stoch " + timeframe_to_string(TIMEFRAME) + " is in overbought.";

   if(find_trend == TREND_SEL)
      if(h4_bla_K_323 <= 20 || h4_red_D_323 <= 20 || h4_bla_K_853 <= 20 || h4_red_D_853 <= 20)
         msg = "SELL is not allowed. Stoch " + timeframe_to_string(TIMEFRAME) + " is in oversold.";

   return msg;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string wait_trade_by_stoch(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double h4_bla_K_323 = iStochastic(symbol,TIMEFRAME,3,2,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_323 = iStochastic(symbol,TIMEFRAME,3,2,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double h4_bla_K_853 = iStochastic(symbol,TIMEFRAME,8,5,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_853 = iStochastic(symbol,TIMEFRAME,8,5,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   if((h4_bla_K_323 <= 20 && h4_red_D_323 <= 20) || (h4_bla_K_853 <= 20 && h4_red_D_853 <= 20))
      return TREND_BUY;

   if((h4_bla_K_323 >= 80 && h4_red_D_323 >= 80) || (h4_bla_K_853 >= 80 && h4_red_D_853 >= 80))
      return TREND_SEL;

   return "";
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

   for(int i = 1; i < 2; i++)
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
////+------------------------------------------------------------------+
//void DeleteAllObjects()
//  {
//   return;
//
//   int totalObjects = ObjectsTotal();
//   for(int i = 0; i < totalObjects - 1; i++)
//     {
//      string objectName = ObjectName(0, i);
//      ObjectDelete(0, objectName);
//     }
//  }
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
   TextCreate(0,name, 0, time_to, price, "        " + label, clrColor);
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
   ObjectDelete(0, name);
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : TRADING_TREND==TREND_SEL ? clrRed : clrBlack;
   TextCreate(0,name, 0, time_to, price, trim_text ? " " + label : "        " + label, clr_color);
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
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size=8, int z_index=999)
  {
   ObjectDelete(0, objName);
   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE,width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTextColor);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrSilver);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, z_index);
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
         orderTakeProfitPrice = calc_tp_by_fixed_sl_amp(symbol, TREND_BUY);

      if(orderType == OP_SELL)
         orderTakeProfitPrice = calc_tp_by_fixed_sl_amp(symbol, TREND_SEL);
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
string create_trader_name()
  {
   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_manually(string TREND)
  {
   string name = TREND == TREND_BUY ? "B" : "S";
   string trader_name = "{^" + name + "^}_";
   return trader_name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortName(string TREND)
  {
   string name = TREND == TREND_BUY ? "B" : "S";
   return name;
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

      CandleData candle_x(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle_x;
     }
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
      amp_w1 = 50;
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
string GetComments()
  {
   if(is_main_control_screen() == false)
      return "";

   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double price = (bid+ask)/2;
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   CandleData arrHeiken[];
   get_arr_heiken(Symbol(), PERIOD_CURRENT, arrHeiken);

   color clrHeiken = arrHeiken[1].trend == TREND_BUY ? clrBlue : clrRed;
   create_trend_line("close_heiken_1", iTime(Symbol(), PERIOD_CURRENT, 0) - TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, TimeCurrent() + TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, clrHeiken, STYLE_DOT, 1, false, false);

   double import_price = (price*25500*(37.5/31.1035)/1000000);
   double profit_today = CalculateTodayProfitLoss();
//double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   string percent = " (" + format_double_to_string(profit_today/INIT_EQUITY * 100, 2) + "%)";

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime();// + "(" + cur_timeframe + ") ";
   str_comments += "    Profit(today): " + format_double_to_string(profit_today, 2) + "$" + percent + "/" + (string) count_closed_today + "L";
//str_comments += "    (GridW1): " + (string) INIT_CLOSE_W1; //iClose(Symbol(), PERIOD_W1, 1);
   str_comments += "    (MacdH4): " + (string) trend_mac_vs_zero_h4;
   str_comments += "    (Heiken"+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend + " (c" + (string) arrHeiken[0].count + ")";

//
   str_comments += "    Funds: " + format_double_to_string(INIT_EQUITY, 1) + "$    Risk: " + format_double_to_string(calcRisk(), 1) + "$ (" +(string)(dbRiskRatio*100) + "%)";
   str_comments += "    1%: " + (string) INIT_VOLUME + " lot";
   double min_profit = calcRisk()*0.1;
   str_comments += "    MinProfit: " + format_double_to_string(min_profit, 1) + "$";
   str_comments += "\n\n";

   if(AMP_DC != AMP_DC)
     {
      str_comments += "    DCA.Buy: " + (string) AMP_DC;
      str_comments += "    DCA.Sel: " + (string) AMP_DC;
      str_comments += "    TP: " + (string) AMP_TP;
     }
   else
     {
      str_comments += "    DCA: " + (string) AMP_DC + " TP:" + (string) AMP_TP;
     }
   double rm1 = CalculateRemainder(price, 5);
   double step = NormalizeDouble(AMP_DC / (NUMBER_OF_TRADER), 2);
   str_comments += "    Rm1: " + format_double_to_string(rm1, 2) + " " + create_Cno() + " Step: " + format_double_to_string(step, 2);
   str_comments += "    VND: " + format_double_to_string(import_price*1.09, 2) + "~" + format_double_to_string(import_price*1.119, 2) + " tr";
   str_comments += "    MaxDD: "  + format_double_to_string(max_drawdown, 2) + "$" + " (" + format_double_to_string(100*(max_drawdown/INIT_EQUITY), 2)+ "%) "  + max_draw_day;
   str_comments += "    MaxAmp: " + format_double_to_string(max_amp, 2) + " ("+ max_amp_day+ ")";
   str_comments += "    StartTrade: " + format_double_to_string(INIT_START_PRICE, Digits) ;
//double amp_w1, amp_d1, amp_h4, amp_grid_L100;
//GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

//str_comments += "    Amp(Grid): " + format_double_to_string(amp_grid_L100, Digits);
//str_comments += "    Amp(M15): " + format_double_to_string(CalculateAverageCandleHeight(PERIOD_M15, Symbol(), 500), Digits); // 3.019$
//str_comments += "    Amp(H1): " + format_double_to_string(CalculateAverageCandleHeight(PERIOD_H1, Symbol(), 500), Digits);   // 7.843$
//str_comments += "    Amp(H4): " + format_double_to_string(CalculateAverageCandleHeight(PERIOD_H4, Symbol(), 500), Digits);   // 10.84$
//str_comments += "    Amp(H4): " + format_double_to_string(amp_h4, Digits);
//str_comments += "    Amp(D1): " + format_double_to_string(amp_d1, Digits) + " (" + format_double_to_string(amp_d7, Digits)+ ")";
//str_comments += "    Amp(W1): " + format_double_to_string(amp_w1, Digits) + " (Avg: " + format_double_to_string(avg_candle_w1, Digits)+ ")";

//str_comments += "    " + get_group_name("[G05062220]Trader1_SELL_01");
//str_comments += "    " + create_group_name();

//if(is_time_enter_the_market() == false)
//   str_comments += "    Do Nothing! Stand outside";

//str_comments += "    CycleBuy: " + (string) IS_CONTINUE_TRADING_CYCLE_BUY;
//str_comments += "    CycleSel: " + (string) IS_CONTINUE_TRADING_CYCLE_SEL;
//str_comments += "    Next(5p): " + (string) passes_time_between_trader();
   str_comments += "\n\n";
   return str_comments;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
