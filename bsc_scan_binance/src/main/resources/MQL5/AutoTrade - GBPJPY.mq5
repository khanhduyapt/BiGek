//+------------------------------------------------------------------+
//|                                                    AutoTrade.mq5 |
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

#define BComment "BComment"
#define BtnClosePosision "ButtonClosePosision"
#define BtnCloseOrder "ButtonCloseOrder"
#define BtnTrade "ButtonTrade"
#define BtnOrderBuy "ButtonOrderBuy"
#define BtnOrderSell "ButtonOrderSell"

double dbRiskRatio = 0.02; // Rủi ro 2% = 20$/lệnh
double INIT_EQUITY = 1000.0; // Vốn đầu tư

string INDICES = "_USTEC_US30_US500_DE30_UK100_FR40_AUS200_BTCUSD_";

string arr_main_symbol[] = {"DXY", "XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

string INDI_NAME = "AutoTrade";
string FILE_NAME_ANGEL_LOG = "Exness.log";

string free_extended_overnight_fees[] = {"GBPJPY"};
string arr_symbol[] = {"GBPJPY"};

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string PREFIX_TRADE_PERIOD_MO = "Mn";
string PREFIX_TRADE_PERIOD_W1 = "W1";
string PREFIX_TRADE_PERIOD_D1 = "D1";
string PREFIX_TRADE_PERIOD_H4 = "H4";
string PREFIX_TRADE_PERIOD_H1 = "H1";
string PREFIX_TRADE_PERIOD_M5 = "M5";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SWITH_TREND_TYPE_HEIKEN = "(Hei)";
string SWITH_TREND_TYPE_MA0710 = "(0710)";
string SWITH_TREND_TYPE_MA0120 = "(0120)";
string SWITH_TREND_TYPE_MA0320 = "(0320)";

string SEQ_071020 = ".S.E.Q.20.";
string SEQ_102050 = ".S.E.Q.50.";
int STOP_LOSS_CANDLES = 7;

string KEY_CLOSE_H1 = ".b.y." + PREFIX_TRADE_PERIOD_H1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OPEN_TRADE = "(OPEN_TRADE)";
string STOP_TRADE = "(STOP_TRADE)";
string OPEN_ORDERS = "(OPEN_ORDER)    ";
string STOP_LOSS = "(STOP_LOSS)";
string AUTO_TRADE  = "(AUTO_TRADE)";

string TRADE_COUNT_ORDER = " Order";
string TRADE_COUNT_ORDER_B = TRADE_COUNT_ORDER + " (B):";
string TRADE_COUNT_ORDER_S = TRADE_COUNT_ORDER + " (S):";
string TRADE_COUNT_POSITION = " Position";
string TRADE_COUNT_POSITION_B = TRADE_COUNT_POSITION + " (B):";
string TRADE_COUNT_POSITION_S = TRADE_COUNT_POSITION + " (S):";

string FILE_NAME_OPEN_TRADE = "_open_trade_today.txt";
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
string FILE_NAME_ALERT_MSG = "_alert_today.txt";
string FILE_NAME_BUTTONS = "_buttons.log";
string FILE_NAME_BUTTONS_FOOTER = "_buttons_footer.log";
string FILE_NAME_BUTTONS_WDH4 = "_buttons_wdh4.log";

string FILE_ONE_TRADE_ONE_WEEK = "_no_delete_file_OneTradeOneWeek.log";
string FILE_SAVE_STOP_LOSS = "_no_delete_file_SaveStopLoss.log";

//iStochastic
int periodK = 5;
int periodD = 3;
int slowing = 3;

bool DEBUG_ON_HISTORY_DATA = IS_DEBUG_MODE;
bool ALLOW_AUTO_TRADE = true;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetExpertMagicNumber(20240304);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   Save_Entry(_Symbol);

   Comment(GetComments());
   DeleteAllObjects();
   Draw_Heikens();

   if(DEBUG_ON_HISTORY_DATA)
     {
      TestInitIndicator();
     }
   else
     {
      DrawIndicators(_Symbol);
     }

//WriteNotifyToken();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(IsMarketClose())
      return;

   if(DEBUG_ON_HISTORY_DATA)
      TestInitIndicator();

   OpenTrade(_Symbol);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_entry_mask(string symbol, string trend, string text_lable)
  {
   datetime cur_candle = iTime(symbol, PERIOD_H4, 0);

   string lbl_name = "MASK_En_" + trend + "_" + (string) cur_candle;
   StringReplace(lbl_name, " ", "");
   StringReplace(lbl_name, ":", "");

   bool found_lable = false;
   int totalObjects = ObjectsTotal(0);
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i);
      if(StringFind(objectName, lbl_name) >= 0)
        {
         found_lable = true;
         break;
        }
     }

   if(found_lable)
      return;

   datetime time_3candles = (iTime(symbol, PERIOD_H4, 1) - iTime(symbol, PERIOD_H4, 2))*3;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   color clrColor = (trend == TREND_BUY) ? clrBlue : clrRed;

   datetime lbl_time = cur_candle;
   TextCreate(0, lbl_name, 0, lbl_time, price, text_lable, clrColor);

   string mask_name = "MASK_V_" + trend + "_" + (string) cur_candle;
   create_line(mask_name, cur_candle, iHigh(symbol, PERIOD_H4, 0), cur_candle, iLow(symbol, PERIOD_H4, 0), clrColor, true);
   ObjectSetInteger(0, "redrw_" + mask_name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, "redrw_" + mask_name, OBJPROP_RAY_LEFT, true);


   string mask_horizon = "MASK_H_" + trend + "_" + (string) cur_candle;
   create_trend_line(mask_horizon, cur_candle - time_3candles, cur_candle, price, clrColor, 5, false, false);

   double sl = get_sl_default(symbol, trend, 0);

   string lbl_sl = "MASK_SL_" + trend + "_" + (string) cur_candle;
   StringReplace(lbl_sl, " ", "");
   StringReplace(lbl_sl, ":", "");
   TextCreate(0, lbl_sl, 0, lbl_time, sl, "SL: " + (string) sl, clrColor);

   string mask_sl = "MASK_Hor_SL_" + trend + "_" + (string) cur_candle;
   create_trend_line(mask_sl, cur_candle - time_3candles, cur_candle, sl, clrColor, 5, false, false);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade(string symbol)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
   string tradingview_symbol = get_tradingview_symbol(symbol);
//------------------------------------------------------------------
   string str_count_trade = CountTrade(symbol);
   bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
   bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
   bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
   bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

   if(has_position_buy || has_position_sel)
     {
      Save_Entry(symbol);
     }

   string trend_ma10_h4_1 = get_trend_by_ma(symbol, PERIOD_H4, 10, 1);

   CandleData arr_heiken_d1[];
   get_arr_heiken(symbol, PERIOD_D1, arr_heiken_d1);
   string trend_hei_d1_0 = arr_heiken_d1[0].trend;
   string trend_hei_d1_1 = arr_heiken_d1[1].trend;

   CandleData arr_heiken_h4[];
   get_arr_heiken(symbol, PERIOD_H4, arr_heiken_h4);
   string trend_hei_h4_0 = arr_heiken_h4[0].trend;
   string trend_hei_h4_1 = arr_heiken_h4[1].trend;

   CandleData arr_candlestick_h4[];
   get_arr_candlestick(symbol, PERIOD_H4, arr_candlestick_h4);

   string trend_hei_h1_1 = get_trend_by_heiken(symbol, PERIOD_H1, 1);

   string trend_h4_1041 = "";
   if(trend_ma10_h4_1 == trend_hei_h4_1 && trend_hei_h4_1 == trend_hei_h4_0 && trend_hei_h4_0 == trend_hei_h4_0)
      trend_h4_1041 = trend_hei_h4_1;

   string find_trend_wd = "";
   string trend_w7 = get_trend_by_ma(symbol, PERIOD_W1, 7, 1);
   string trend_d10_1 = get_trend_by_ma(symbol, PERIOD_D1, 10, 1);
   if(trend_w7 == trend_d10_1)
      find_trend_wd = trend_w7;

   string trend_by_SEQ_071020 = get_trend_by_seq_7_10_20(symbol, PERIOD_H4);
   string sw_seq_10_20_50_h4 = get_switch_trend_by_seq_10_20_50(symbol, PERIOD_H4);
   string sw_seq_07_10_20_h4 = get_switch_trend_by_seq_07_10_20(symbol, PERIOD_H4);

   if(sw_seq_10_20_50_h4 != "" && sw_seq_10_20_50_h4 == arr_candlestick_h4[1].trend && arr_candlestick_h4[1].count == 1)
     {
      create_entry_mask(symbol, sw_seq_10_20_50_h4, SEQ_102050 + " : " + sw_seq_10_20_50_h4);
     }

   if(sw_seq_07_10_20_h4 != "" && sw_seq_07_10_20_h4 == arr_candlestick_h4[1].trend && arr_candlestick_h4[1].count == 1)
     {
      create_entry_mask(symbol, sw_seq_07_10_20_h4, SEQ_071020 + " : " + sw_seq_07_10_20_h4);
     }


   string trend_close_by_stoc = "";
   string trend_stoc5_h4 = get_trend_by_stoc2(symbol, PERIOD_H4, 5, 3, 3, 1);
   string trend_stoc13_h4 = get_trend_by_stoc2(symbol, PERIOD_H4, 13, 8, 5, 1);

   string trend_stoc513 = "";
   if(trend_stoc5_h4 == trend_stoc13_h4)
      trend_stoc513 = trend_stoc13_h4;

   if(trend_ma10_h4_1 == trend_stoc13_h4 && trend_stoc13_h4 == trend_stoc5_h4 && trend_stoc5_h4 == trend_hei_h4_0 && trend_hei_h4_0 == trend_hei_h1_1)
      trend_close_by_stoc = trend_stoc13_h4;
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
   if((has_position_buy == false && find_trend_wd == TREND_BUY) ||
      (has_position_sel == false && find_trend_wd == TREND_SEL))
     {
      if(find_trend_wd == trend_hei_d1_0 && arr_heiken_d1[0].count < 5 && arr_heiken_h4[0].count < 7 &&
         find_trend_wd == trend_hei_h4_1 && find_trend_wd == trend_hei_h4_0 && find_trend_wd == trend_hei_h1_1 &&
         is_tradable_by_stoch(symbol, PERIOD_H4, find_trend_wd)
        )
        {
         bool has_open = false;
         double amp_trade = calc_amp_trade_by_candle_h4(symbol, find_trend_wd);
         double volume = dblLotsRisk(symbol, amp_trade, calcRisk());

         if(has_open == false && find_trend_wd == sw_seq_10_20_50_h4)
           {
            has_open = true;
            string note = "4h" + SEQ_102050;
            Open_Market(symbol, find_trend_wd, volume, KEY_CLOSE_H1, 0.0, note);
           }


         if(has_open == false && find_trend_wd == sw_seq_07_10_20_h4)
           {
            has_open = true;
            string note = "4h" + SEQ_071020;
            Open_Market(symbol, find_trend_wd, volume, KEY_CLOSE_H1, 0.0, note);
           }
        }
     }
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
   if(has_position_buy && (trend_stoc513 != TREND_BUY))
     {
      bool is_opening = true;
      if((find_trend_wd == TREND_SEL) || (sw_seq_10_20_50_h4 == TREND_SEL) || (trend_by_SEQ_071020 == TREND_SEL) || (trend_h4_1041 == TREND_SEL) || (trend_close_by_stoc == TREND_SEL))
        {
         is_opening = false;
         ClosePosition(symbol, TREND_BUY, KEY_CLOSE_H1);
        }

      if(is_opening && is_continue_hode_postion_by_ma_7_10_20(symbol, PERIOD_H4, TREND_BUY) == false)
        {
         is_opening = false;
         ClosePosition(symbol, TREND_BUY, KEY_CLOSE_H1);
        }

      if(is_opening &&
         is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_BUY) &&
         is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_BUY) &&
         is_must_exit_trade_by_stoch(symbol, PERIOD_M5, TREND_BUY))
        {
         is_opening = false;
         ClosePosition(symbol, TREND_BUY, KEY_CLOSE_H1);
        }
     }



   if(has_position_sel && (trend_stoc513 != TREND_SEL))
     {
      bool is_opening = true;

      if((find_trend_wd == TREND_BUY) || (sw_seq_10_20_50_h4 == TREND_BUY) || (trend_by_SEQ_071020 == TREND_BUY) || (trend_h4_1041 == TREND_BUY) || (trend_close_by_stoc == TREND_BUY))
        {
         is_opening = false;
         ClosePosition(symbol, TREND_BUY, KEY_CLOSE_H1);
        }

      if(is_opening && is_continue_hode_postion_by_ma_7_10_20(symbol, PERIOD_H4, TREND_SEL) == false)
        {
         is_opening = false;
         ClosePosition(symbol, TREND_SEL, KEY_CLOSE_H1);
        }

      if(is_opening &&
         is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_SEL) &&
         is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_SEL) &&
         is_must_exit_trade_by_stoch(symbol, PERIOD_M5, TREND_SEL))
        {
         is_opening = false;
         ClosePosition(symbol, TREND_SEL, KEY_CLOSE_H1);
        }
     }

// --------------------------------------------------------------------------------
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_amp_init_h4;
   double dic_amp_init_d1;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_amp_init_h4, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(_Symbol, week_amp*2, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + _Symbol;
   string trend_macd = get_trend_by_macd_and_signal_vs_zero(_Symbol, PERIOD_H4);

   string trend_swap = "";
   double swap_long  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double swap_short  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   if(swap_long > swap_short*2)
      trend_swap = TREND_BUY;
   if(swap_short > swap_long*2)
      trend_swap = TREND_SEL;

   CandleData arr_heiken_w1[];
   get_arr_heiken(_Symbol, PERIOD_W1, arr_heiken_w1, 25);
   CandleData arr_heiken_d1[];
   get_arr_heiken(_Symbol, PERIOD_D1, arr_heiken_d1, 25);

   CandleData arr_candlestick_xx[];
   get_arr_candlestick(_Symbol, Period(), arr_candlestick_xx);

   string trend_d13 = get_trend_by_stoc2(_Symbol, PERIOD_D1, 13, 8, 5, 0);
   string trend_h413 = get_trend_by_stoc2(_Symbol, PERIOD_H4, 13, 8, 5, 0);
   string trend_d13_candles = get_candle_switch_trend_stoch(_Symbol, PERIOD_D1, 13, 8, 5);
   string trend_h413_candles = get_candle_switch_trend_stoch(_Symbol, PERIOD_H4, 13, 8, 5);

   if(is_same_symbol(_Symbol, "XAU"))
     {
      str_comments += "    Avg(H1): " + (string) calc_amp_tp_by_avg_candle_heigh(_Symbol, PERIOD_H1);
      str_comments += "    Avg(H4): " + (string) calc_amp_tp_by_avg_candle_heigh(_Symbol, PERIOD_H4);
      str_comments += "    Avg(D1): " + (string) calc_amp_tp_by_avg_candle_heigh(_Symbol, PERIOD_D1);
      str_comments += "    Avg(W1): " + (string) calc_amp_tp_by_avg_candle_heigh(_Symbol, PERIOD_W1);
     }

   str_comments += "    Amp: " + (string) get_default_amp_trade(_Symbol);
   str_comments += "    Vol: " + volume_bt + " lot";

   str_comments += "    Funds: " + (string) INIT_EQUITY + "$ / Risk: " + (string) risk + "$ / " + (string)(dbRiskRatio * 100) + "%    ";

   if(trend_swap != "")
      str_comments += "    Swap " + AppendSpaces(trend_swap, 5);

   str_comments += "    Ma7(W) " + AppendSpaces(get_trend_by_ma(_Symbol, PERIOD_W1, 7, 1));
   str_comments += "    Ma10(D) " + AppendSpaces(get_trend_by_ma(_Symbol, PERIOD_D1, 10, 1));

   str_comments += "    Hei(W) " + AppendSpaces(arr_heiken_w1[0].trend + " ("+(string)arr_heiken_w1[0].count+")", 10);
   str_comments += "    Hei(D) " + AppendSpaces(arr_heiken_d1[0].trend + " ("+(string)arr_heiken_d1[0].count+")", 10);

   str_comments += "    Candle_" + cur_timeframe + "[1] " + AppendSpaces(arr_candlestick_xx[1].trend + " ("+(string)arr_candlestick_xx[1].count+")", 10);

   str_comments += "\n";
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
void Open_Market(string symbol, string TRADING_TREND, double volume, string KEY_CLOSE, double amp_tp, string note)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double open = iOpen(symbol, PERIOD_H4, 1);
   double close = iClose(symbol, PERIOD_H4, 1);
   string trend_candle_1 = "";
   if(open < close)
      trend_candle_1 = TREND_BUY;
   if(open > close)
      trend_candle_1 = TREND_SEL;

   bool allow_trade_now = false;
   if(trend_candle_1 == TRADING_TREND)
     {
      if(TRADING_TREND == TREND_BUY && price <= close)
         allow_trade_now = true;

      if(TRADING_TREND == TREND_SEL && price >= close)
         allow_trade_now = true;
     }
   if(allow_trade_now == false)
      return;


   if(is_has_memo_in_file(FILE_ONE_TRADE_ONE_WEEK, PREFIX_TRADE_PERIOD_W1, symbol, TRADING_TREND))
      return;
   add_memo_to_file(FILE_ONE_TRADE_ONE_WEEK, PREFIX_TRADE_PERIOD_W1, symbol, TRADING_TREND);


   double tp_price = 0.0;
   if(amp_tp > 0)
     {
      if(TRADING_TREND == TREND_BUY)
         tp_price = price + amp_tp;

      if(TRADING_TREND == TREND_SEL)
         tp_price = price - amp_tp;
     }


   if(TRADING_TREND == TREND_BUY)
     {
      string comment = "MK_B_" + (string)volume + KEY_CLOSE + "_" + note;

      m_trade.Buy(volume, symbol, 0.0, 0.0, tp_price, comment);

      string msg_open_trade = OPEN_TRADE + "   BUY    " + symbol + "   "+comment+"   Vol: " + (string) volume;
      SendTelegramMessage(symbol, TREND_BUY, msg_open_trade);
     }

   if(TRADING_TREND == TREND_SEL)
     {
      string comment = "MK_S_" + (string)volume + KEY_CLOSE + "_" + note;

      m_trade.Sell(volume, symbol, 0.0, 0.0, tp_price, comment);

      string msg_open_trade = OPEN_TRADE + "   SELL   " + symbol + "   "+comment+"   Vol: " + (string) volume;
      SendTelegramMessage(symbol, TREND_BUY, msg_open_trade);
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string trading_trend, string KEY_CLOSE)
  {
   CloseOrders(symbol);

   string msg = "";
   double profit = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0)
               if(KEY_CLOSE == "" || (StringFind(m_position.Comment(), KEY_CLOSE) >= 0))
                 {
                  bool pass_hold_min_time = false;
                  double time_diff_buy_hours = (double)(TimeCurrent() - m_position.Time()) / (60 * 60);
                  if(time_diff_buy_hours > 8.0)
                     pass_hold_min_time = true;

                  if(pass_hold_min_time)
                    {
                     msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                     profit += m_position.Profit();
                     m_trade.PositionClose(m_position.Ticket());
                    }
                 }

     } //for

   if(msg != "")
      SendTelegramMessage(symbol, STOP_TRADE, STOP_TRADE + " " + trading_trend + "  " + symbol + "   Total: " + (string) profit + "$ ");

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
//|                                                                  |
//+------------------------------------------------------------------+
double get_next_entry(string symbol, string find_trend)
  {
   double next_entry_buy = 0.0;
   double next_entry_sel = 0.0;
   for(int i = 0; i <= 25; i++)
     {
      double low = iLow(_Symbol, PERIOD_H4, i);
      double hig = iHigh(_Symbol, PERIOD_H4, i);

      if((i == 0) || (next_entry_buy > low))
         next_entry_buy = low;
      if((i == 0) || (next_entry_sel < hig))
         next_entry_sel = hig;
     }

   if(find_trend == TREND_BUY)
      return next_entry_buy;

   if(find_trend == TREND_SEL)
      return next_entry_sel;

   return 0.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseChart()
  {
   long chart_ID=ChartFirst();
   while(chart_ID >= 0)
     {
      ChartClose(chart_ID);
      chart_ID = ChartNext(chart_ID);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_tp_price(string symbol, string trading_trend)
  {
   if(DEBUG_ON_HISTORY_DATA)
      return 0.0;

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double amp_waste = dic_amp_w*0.1;

   double lowest_close_21 = 0.0;
   double higest_close_21 = 0.0;

   for(int i = 1; i <= 21; i++)
     {
      double low = iLow(_Symbol, PERIOD_H4, i);
      double hig = iHigh(_Symbol, PERIOD_H4, i);

      if((i == 1) || (lowest_close_21 > low))
         lowest_close_21 = low;

      if((i == 1) || (higest_close_21 < hig))
         higest_close_21 = hig;

     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double tp = 0.0;
   if(trading_trend == TREND_BUY)
     {
      tp = lowest_close_21*(1 + dic_amp_init_d1*1) - amp_waste;
      if(tp < price + dic_amp_w)
         tp = price + dic_amp_w;
     }

   if(trading_trend == TREND_SEL)
     {
      tp = higest_close_21*(1 - dic_amp_init_d1*1) + amp_waste;
      if(tp > price - dic_amp_w)
         tp = price - dic_amp_w;
     }

   return tp;
  }


//+------------------------------------------------------------------+
string CountTrade(string symbol)
  {

   int pos_buy = 0;
   int pos_sel = 0;
   double profit_buy = 0.0;
   double profit_sel = 0.0;
   double volume = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_position.Symbol()))) // && (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            double profit = m_position.Profit() + m_position.Swap();
            long type = PositionGetInteger(POSITION_TYPE);
            volume += m_position.Volume();

            if(type == POSITION_TYPE_BUY)
              {
               pos_buy += 1;
               profit_buy += profit;
              }

            if(type == POSITION_TYPE_SELL)
              {
               pos_sel += 1;
               profit_sel += profit;
              }
           }
        }
     } //for

   int ord_buy = 0;
   int ord_sel = 0;
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
      result += AppendSpaces(TRADE_COUNT_ORDER_B + (string)ord_buy, 13);

   if(ord_sel > 0)
      result += AppendSpaces(TRADE_COUNT_ORDER_S + (string)ord_sel, 13);

   if(ord_buy + ord_sel == 0)
      result += AppendSpaces("", 13);

   if(pos_buy > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_B + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_buy, 2), 20) + "  P:" + AppendSpaces((string) NormalizeDouble(profit_buy, 2) + "$", 7, false);

   if(pos_sel > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_S + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_sel, 2), 20) + "  P:" + AppendSpaces((string) NormalizeDouble(profit_sel, 2) + "$", 7, false);

   StringReplace(result, ".0$", "$");

   return AppendSpaces(result, 50);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
   if(3 < currentHour && currentHour < 7)
      return true; //VietnamEarlyMorning

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_tradingview_symbol(string symbol)
  {
   string text = symbol;
   StringReplace(text, ".cash", "");

// Lấy một phần của chuỗi mà không bao gồm ký tự "m" cuối cùng
   if(StringGetCharacter(text, StringLen(text) - 1) == 'm')
      text = StringSubstr(text, 0, StringLen(text) - 1);

   return text;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_default_volume(string symbol)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   double risk = calcRisk();
   return dblLotsRisk(symbol, week_amp*2, risk);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_amp_trade_by_candle_h4(string symbol, string find_trend)
  {
   double stoploss = get_sl_default(symbol, find_trend, 0);

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double amp_trade = 0.0;
   if(find_trend == TREND_BUY)
      amp_trade = MathAbs(price - stoploss);

   if(find_trend == TREND_SEL)
      amp_trade = MathAbs(stoploss - price);

   return amp_trade;
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
double calc_amp_tp_by_avg_candle_heigh(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   return CalculateAverageCandleHeight(TIMEFRAME, symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_default_amp_trade(string symbol)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   return NormalizeDouble(week_amp * 2, digits);
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

   return "    Profit Today:" + format_double_to_string(loss, 2) + "$" + "    Swap:" + format_double_to_string(swap, 2) + "$";
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

   return "sw";
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
string get_trend_by_ma50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close0 = closePrices[0];
   double ma_50 = cal_MA(closePrices, 50, 1);

   if(close0 > ma_50)
      return TREND_SEL;

   if(close0 < ma_50)
      return TREND_BUY;

   return "eq";
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
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_short, int ma_long)
  {
   int maLength = MathMax(ma_short, ma_long) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_short_1 = cal_MA(closePrices, ma_short, 1);
   double ma_short_2 = cal_MA(closePrices, ma_short, 2);
   double ma_long_1 = cal_MA(closePrices, ma_long, 1);
   double ma_long_2 = cal_MA(closePrices, ma_long, 2);

   if(ma_short_1 >= ma_long_1 && ma_short_2 <= ma_long_2)
      return TREND_BUY;

   if(ma_short_1 <= ma_long_1 && ma_short_2 >= ma_long_2)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_vector_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_0 = cal_MA(closePrices, ma_index, 0);
   double ma_1 = cal_MA(closePrices, ma_index, 1);


   if(ma_0 > ma_1)
      return TREND_BUY;

   if(ma_0 < ma_1)
      return TREND_SEL;

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
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   return candleArray[candle_index].trend;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken_ma6_stoc(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   string trend_by_hei = candleArray[0].trend;
   string trend_by_ma6 = get_trend_by_ma(symbol, TIME_FRAME, 6, 0);
   string trend_by_sto = get_trend_by_stoc(symbol, TIME_FRAME, 0);

//Print("[get_trend_by_heiken_ma6_stoc] ", get_prefix_trade_from_current_timeframe(TIME_FRAME)
//      , "  trend_by_hei_c0: ", trend_by_hei, "  trend_by_ma6_c0: ", trend_by_ma6, "  trend_by_sto_c0: ", trend_by_sto);

   if(trend_by_hei == trend_by_ma6 && trend_by_hei == trend_by_sto)
      return trend_by_hei;

//   if(trend_by_hei == trend_by_ma6)
//      return trend_by_hei;
//
//   if(trend_by_hei == trend_by_sto)
//      return trend_by_hei;

   return "sw_" + get_prefix_trade_from_current_timeframe(TIME_FRAME);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_seq_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_10 = cal_MA(closePrices, 10, 1);
   double ma_20 = cal_MA(closePrices, 20, 1);
   double ma_50 = cal_MA(closePrices, 50, 1);

   if((ma_10 >= ma_20) && (ma_20 >= ma_50))
      return TREND_BUY;

   if((ma_10 <= ma_20) && (ma_20 <= ma_50))
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe, string trend_by_amp_55h4)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_10 = cal_MA(closePrices, 10, 1);
   double ma_20 = cal_MA(closePrices, 20, 1);
   double ma_50 = cal_MA(closePrices, 50, 1);

   if((trend_by_amp_55h4 == TREND_SEL) && (ma_10 >= ma_20) && (ma_20 >= ma_50))
      return false;

   if((trend_by_amp_55h4 == TREND_BUY) && (ma_10 <= ma_20) && (ma_20 <= ma_50))
      return false;

   return true;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_continue_hode_postion_by_ma_7_10_20(string symbol, ENUM_TIMEFRAMES timeframe, string trading_trend)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_07 = cal_MA(closePrices, 7, 0);
   double ma_10 = cal_MA(closePrices, 10, 0);
   double ma_20 = cal_MA(closePrices, 20, 0);

   if((trading_trend == TREND_BUY) && (ma_07 >= ma_20) && (ma_10 >= ma_20))
      return true;

   if((trading_trend == TREND_SEL) && (ma_07 <= ma_20) && (ma_10 <= ma_20))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_seq_07_10_20(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }


   double max_bread = 0.0;
   double lowest_5c = 0.0, higest_5c = 0.0;
   for(int i = 0; i <= 5; i++)
     {
      double low = iLow(symbol, timeframe, i);
      double hig = iHigh(symbol, timeframe, i);

      double open = iOpen(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i);
      double body_low = MathMin(open, close);
      double body_hig = MathMax(open, close);
      if(max_bread < (body_low - low))
         max_bread = (body_low - low);
      if(max_bread < (hig - body_hig))
         max_bread = (hig - body_hig);

      if(i == 0 || lowest_5c > low)
         lowest_5c = low;

      if(i == 0 || higest_5c < hig)
         higest_5c = hig;
     }

   lowest_5c = lowest_5c - max_bread*2;
   higest_5c = higest_5c + max_bread*2;


   double ma_3_0 = cal_MA(closePrices, 3, 0);
   double ma_3_1 = cal_MA(closePrices, 3, 1);

   double ma_5_0 = cal_MA(closePrices, 5, 0);
   double ma_5_1 = cal_MA(closePrices, 5, 1);

   double ma_7_0 = cal_MA(closePrices, 7, 0);
   double ma_7_1 = cal_MA(closePrices, 7, 1);

   double ma_10_0 = cal_MA(closePrices, 10, 0);
   double ma_10_1 = cal_MA(closePrices, 10, 1);

   double ma_20_0 = cal_MA(closePrices, 20, 0);
   double ma_20_1 = cal_MA(closePrices, 20, 1);

   double ma_50_0 = cal_MA(closePrices, 50, 0);
   double ma_50_1 = cal_MA(closePrices, 50, 1);

   bool inside = false;
   if((lowest_5c <= ma_7_0 || lowest_5c <= ma_7_1) && (ma_7_0 <= higest_5c || ma_7_1 <= higest_5c))
      if((lowest_5c <= ma_10_0 || lowest_5c <= ma_10_1) && (ma_10_0 <= higest_5c || ma_10_1 <= higest_5c))
         if((lowest_5c <= ma_20_0 || lowest_5c <= ma_20_1) && (ma_20_0 <= higest_5c || ma_20_1 <= higest_5c))
            if((lowest_5c <= ma_50_0 || lowest_5c <= ma_50_1) && (ma_50_0 <= higest_5c || ma_50_1 <= higest_5c))
               inside = true;


   if(inside)
     {
      if((ma_3_0 >= ma_3_1) && (ma_5_0 >= ma_5_1) && (ma_7_0 >= ma_7_1) && (ma_10_0 >= ma_10_1) && (ma_7_0 >= ma_10_0) && (ma_10_0 >= ma_20_0))
         return TREND_BUY;

      if((ma_3_0 <= ma_3_1) && (ma_5_0 <= ma_5_1) && (ma_7_0 <= ma_7_1) && (ma_10_0 <= ma_10_1) && (ma_7_0 <= ma_10_0) && (ma_10_0 <= ma_20_0))
         return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_seq_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double max_bread = 0.0;
   double lowest_5c = 0.0, higest_5c = 0.0;
   for(int i = 0; i <= 5; i++)
     {
      double low = iLow(symbol, timeframe, i);
      double hig = iHigh(symbol, timeframe, i);

      double open = iOpen(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i);
      double body_low = MathMin(open, close);
      double body_hig = MathMax(open, close);
      if(max_bread < (body_low - low))
         max_bread = (body_low - low);
      if(max_bread < (hig - body_hig))
         max_bread = (hig - body_hig);

      if(i == 0 || lowest_5c > low)
         lowest_5c = low;

      if(i == 0 || higest_5c < hig)
         higest_5c = hig;
     }

   lowest_5c = lowest_5c - max_bread;
   higest_5c = higest_5c + max_bread;

   double ma_3_0 = cal_MA(closePrices, 3, 0);
   double ma_3_1 = cal_MA(closePrices, 3, 1);

   double ma_7_0 = cal_MA(closePrices, 7, 0);
   double ma_7_1 = cal_MA(closePrices, 7, 1);

   double ma_10_0 = cal_MA(closePrices, 10, 0);
   double ma_10_1 = cal_MA(closePrices, 10, 1);

   double ma_20_0 = cal_MA(closePrices, 20, 0);
   double ma_20_1 = cal_MA(closePrices, 20, 1);

   double ma_50_0 = cal_MA(closePrices, 50, 0);
   double ma_50_1 = cal_MA(closePrices, 50, 1);

   bool inside = false;
   if((lowest_5c <= ma_7_0 || lowest_5c <= ma_7_1) && (ma_7_0 <= higest_5c || ma_7_1 <= higest_5c))
      if((lowest_5c <= ma_10_0 || lowest_5c <= ma_10_1) && (ma_10_0 <= higest_5c || ma_10_1 <= higest_5c))
         if((lowest_5c <= ma_20_0 || lowest_5c <= ma_20_1) && (ma_20_0 <= higest_5c || ma_20_1 <= higest_5c))
            if((lowest_5c <= ma_50_0 || lowest_5c <= ma_50_1) && (ma_50_0 <= higest_5c || ma_50_1 <= higest_5c))
               inside = true;

   if(inside)
     {
      if((ma_3_0 >= ma_3_1) && (ma_7_0 > ma_7_1) && (ma_7_0 > ma_10_0) && (ma_10_0 > ma_20_0) && (ma_7_0 > ma_50_0) && ((ma_10_0 > ma_50_0) || (ma_20_0 > ma_50_0)))
         return TREND_BUY;

      // -----------------------------------------------------------------------------

      if((ma_3_0 <= ma_3_1) && (ma_7_0 < ma_7_1) && (ma_7_0 < ma_10_0) && (ma_10_0 < ma_20_0) && (ma_7_0 < ma_50_0) && ((ma_10_0 < ma_50_0) || (ma_20_0 < ma_50_0)))
         return TREND_SEL;
     }

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_seq_7_10_20(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 25;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_3_0 = cal_MA(closePrices, 3, 0);
   double ma_3_1 = cal_MA(closePrices, 3, 1);

   double ma_7_0 = cal_MA(closePrices, 7, 0);
   double ma_7_1 = cal_MA(closePrices, 7, 1);

   double ma_10_0 = cal_MA(closePrices, 10, 0);
   double ma_10_1 = cal_MA(closePrices, 10, 1);

   double ma_20_0 = cal_MA(closePrices, 20, 0);
   double ma_20_1 = cal_MA(closePrices, 20, 1);

   if((ma_3_0 >= ma_3_1) && (ma_7_0 >= ma_7_1) && (ma_10_0 >= ma_10_1) && (ma_7_0 >= ma_10_0) && (ma_10_0 >= ma_20_0))
      return TREND_BUY;

// -----------------------------------------------------------------------------

   if((ma_3_0 <= ma_3_1) && (ma_7_0 <= ma_7_1) && (ma_10_0 <= ma_10_1) && (ma_7_0 <= ma_10_0) && (ma_10_0 <= ma_20_0))
      return TREND_SEL;

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
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   double ma10 = cal_MA_XX(symbol, timeframe, ma_index, 1);

   CandleData candleArray[];
   get_arr_heiken(symbol, timeframe, candleArray);
   double haClose1 = candleArray[1].close;
   double haClose2 = candleArray[2].close;

   double close_1 = iClose(symbol, timeframe, 1);
   if(close_1 >= ma10 && haClose1 >= ma10 && haClose2 <= ma10)
      return TREND_BUY;

   if(close_1 <= ma10 && haClose1 <= ma10 && haClose2 >= ma10)
      return TREND_SEL;

   return "";
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

   if(StringFind(message, "OPEN_TRADE") >= 0)
     {
      string str_count_trade = CountTrade(symbol);
      bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
      bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

      if(trend == TREND_BUY && has_position_buy)
         return;

      if(trend == TREND_SEL && has_position_sel)
         return;

      if(is_allow_send_msg_telegram(symbol, PERIOD_W1, 10, trend) == false)
         return;
     }

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
string get_prefix_trade_from_current_timeframe(ENUM_TIMEFRAMES period)
  {
   if(period == PERIOD_M5)
      return PREFIX_TRADE_PERIOD_M5;

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

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M5)) >= 0)
      return PERIOD_M5;

   return PERIOD_H4;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_timeframe(string PREFIX_TRADE_PERIOD_XX)
  {
   ENUM_TIMEFRAMES TIMEFRAME = PERIOD_D1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_W1)
      TIMEFRAME = PERIOD_W1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_D1)
      TIMEFRAME = PERIOD_D1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_H4)
      TIMEFRAME = PERIOD_H4;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_H1)
      TIMEFRAME = PERIOD_H1;

   return TIMEFRAME;
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
string create_key(string PREFIX_TRADE_PERIOD_XX, string symbol, string trend)
  {
   ENUM_TIMEFRAMES TIMEFRAME = get_timeframe(PREFIX_TRADE_PERIOD_XX);

   string date_time = (string)iTime(symbol, TIMEFRAME, 0);
   StringReplace(date_time, ":00:00", "h");
   StringReplace(date_time, "2024.", "");
   StringReplace(date_time, "2025.", "");
   StringReplace(date_time, "2026.", "");

   string key = date_time + ":" + PREFIX_TRADE_PERIOD_XX + ":" + trend + ":" + symbol +";";
   StringReplace(key, " ", "");

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string trend)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(PREFIX_TRADE_PERIOD_XX, symbol, trend);
   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string trend, string note_stoploss = "", ulong ticket = 0)
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(PREFIX_TRADE_PERIOD_XX, symbol, trend);

   open_trade_today = open_trade_today + key;

   if(note_stoploss != "")
     {
      open_trade_today += "@SL:" + note_stoploss;
      open_trade_today += "@Ticket:" + (string) ticket;
     }
   open_trade_today += "@NEXT@";

   open_trade_today = CutString(open_trade_today);

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
bool is_pass_min_time(string prefix, string symbol, string trend)
  {
   return (is_has_memo_in_file(FILE_NAME_OPEN_TRADE, prefix, symbol, trend) == false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_send_msg_telegram(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int length, string find_trend)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
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

   if(find_trend == TREND_BUY && (MathAbs(price - lowest) < week_amp))
      return true;

   if(find_trend == TREND_SEL && (MathAbs(higest - price) < week_amp))
      return true;

   return false;
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_signal);

   double m_macd    = m_buff_MACD_main[0];
   double m_signal  = m_buff_MACD_signal[0];

   if(m_macd >= 0 && m_signal >= 0)
      return TREND_BUY ;

   if(m_macd <= 0 && m_signal <= 0)
      return TREND_SEL ;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_consensus_by_long_term_and_short_term_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_long_term = get_trend_by_stoc2(symbol, timeframe, 13, 8, 5, 0);
   string trend_shot_term = get_trend_by_stoc2(symbol, timeframe,  5, 3, 3, 0);

   if(trend_long_term == trend_shot_term)
      return trend_long_term;

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
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, int candle_no = 1)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   if(K[candle_no] > D[candle_no])
      return TREND_BUY;

   if(K[candle_no] < D[candle_no])
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 5, 3, 3))
      return true;

   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 13, 8, 5))
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc513(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   string trend_stoc5_h4 = get_trend_by_stoc2(symbol, TIMEFRAME, 5, 3, 3, 0);
   string trend_stoc13_h4 = get_trend_by_stoc2(symbol, TIMEFRAME, 13, 8, 5, 0);

   if(trend_stoc13_h4 == trend_stoc5_h4)
      return trend_stoc13_h4;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_tradable_by_stoch(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   string trend_513 = get_trend_by_stoc513(symbol, TIMEFRAME);

   if(find_trend == trend_513)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 5, 3, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 13, 8, 5))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_StayOut_or_TakeProfit_by_stoc_Extrema(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   int handle = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return true;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(find_trend == TREND_BUY && black_K < red_D)
      return true;
   if(find_trend == TREND_BUY && black_K >= 80 && red_D >= 80)
      return true;


   if(find_trend == TREND_SEL && black_K > red_D)
      return true;
   if(find_trend == TREND_SEL && black_K <= 20 && red_D <= 20)
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

   double black_K = K[0];
   double red_D = D[0];

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
string get_trend_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(black_K > red_D && black_K <= 20 && red_D <= 20)
      return TREND_BUY;

   if(black_K < red_D && black_K >= 80 && red_D >= 80)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int inK, int inD, int inS)
  {
   int handle = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,50,K);
   CopyBuffer(handle,1,0,50,D);

// Tìm vị trí x thỏa mãn điều kiện
   int index = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   for(int i = 0; i < ArraySize(K) - 1; i++)
     {
      if((K[i] <= D[i] && K[i + 1] >= D[i + 1]) || (K[i] >= D[i] && K[i + 1] <= D[i + 1]))
        {
         // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
         index = i;
         break;
        }
     }

   if(index != -1)
     {
      return (K[0] > D[0] ? TREND_BUY : TREND_SEL) + "(" + (string)(index) + ")"; ;
     }
   else
     {
      return "";
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_stoch(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);


   int i = 0;
   if((K[i] < D[i] && K[i + 1] > D[i + 1]) || (K[i] > D[i] && K[i + 1] < D[i + 1]))
     {
      if(K[i] >= D[i])
         return TREND_BUY;

      if(K[i] <= D[i])
         return TREND_SEL;
     }

   return "";
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
void TestInitIndicator()
  {
//return;

   if(DEBUG_ON_HISTORY_DATA == false)
      return;

   Comment(GetComments());
   iMA(_Symbol,PERIOD_CURRENT,3,0,MODE_SMA,PRICE_CLOSE);
   iMA(_Symbol,PERIOD_CURRENT,6,0,MODE_SMA,PRICE_CLOSE);
   iMA(_Symbol,PERIOD_CURRENT,9,0,MODE_SMA,PRICE_CLOSE);

   if(Period() <= PERIOD_H4)
     {
      iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);
      iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_SMA,PRICE_CLOSE);
     }

   iStochastic(_Symbol, PERIOD_CURRENT, 3, 3, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 7, 3, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 9, 5, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 11, 5, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 13, 8, 5, MODE_SMA, STO_LOWHIGH);

   if(Period() <= PERIOD_H4)
      iStochastic(_Symbol, PERIOD_CURRENT, 21, 17, 5, MODE_SMA, STO_LOWHIGH);

   DrawBB(_Symbol);

   Draw_Heikens();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicators(string symbol)
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   if(is_same_symbol(_Symbol, symbol) == false)
      return;

   Save_Entry(symbol);

   Draw_Amp_D_Wave(symbol);

   Draw_PivotHorizontal_TimeVertical();

   DrawBB(symbol);

   CalculatePivot("PERIOD_W1", PERIOD_W1);

   CalculateAvgCandleHeigh("PERIOD_W1", PERIOD_W1);
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
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   int count = 0;
   double totalHeight = 0.0;

   for(int i = 0; i < 20; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      count += 1;
      totalHeight += candleHeight;
     }

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double averageHeight = NormalizeDouble(totalHeight / count, digits);

   return averageHeight;
  }
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
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int totalObjects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      if(StringFind(objectName, "redrw_") >= 0 || StringFind(objectName, "dkd") >= 0)
         ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
   if(!time1)
      time1=TimeGMT();
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];

      time2=time1;
     }
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   price2=price1;
  }

//+------------------------------------------------------------------+
bool create_rectangle(
   const string          name="Rectangle",  // rectangle name
   datetime              time1=0,           // first point time
   double                price1=0,          // first point price (Open)
   datetime              time2=0,           // second point time
   double                price2=0,          // second point price (Close)
   const color           def_color=clrBlack,
   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
   const int             width=1,           // width of rectangle lines
   const bool            fill=false,        // filling rectangle with color
   const bool            background=false,        // in the background
   const bool            selection=false,    // highlight to move
   const bool            hidden=true,       // hidden in the object list
   const long            z_order=0         // priority for mouse click
)
  {
   int sub_window=0;      // subwindow index
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
   ResetLastError();
   if(!ObjectCreate(0,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }

   color clr = get_line_color(price1, price2);
   if(def_color != clrBlack)
     {
      clr = def_color;
     }

   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
   ObjectSetInteger(0,name,OBJPROP_BACK,background);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
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

   double amp_trade = week_amp;
   if(TIMEFRAME <= PERIOD_H4)
      amp_trade = week_amp / 2;

//if(TIMEFRAME == PERIOD_H1)
//   amp_trade = week_amp / 8;
//if(TIMEFRAME < PERIOD_H1)
//   amp_trade = week_amp / 16;
   return amp_trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Amp_D_Wave(string symbol)
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   if(Period() != PERIOD_D1 && Period() != PERIOD_H4 && Period() != PERIOD_H1)
      return;

   ENUM_TIMEFRAMES TIMEFRAME = Period();
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_amp_init_h4;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_amp_init_h4, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   double amp_percent = dic_amp_init_d1;

   int size = 55;
   string prefix = "d1";

   if(Period() == PERIOD_H1)
     {
      size = 65;
      prefix = "h1";
      amp_percent = dic_amp_init_h4/2;
     }

   bool is_h4 = (Period() == PERIOD_H4);
   if(is_h4)
     {
      size = 99;
      prefix = "h4";
      amp_percent = dic_amp_init_h4;
     }

   double lowest = 0;
   double higest = 0;
   int candle_index_buy = 1;
   int candle_index_sel = 1;

   int low_idx_h4_55 = 0, hig_idx_h4_55 = 0;
   double low_h4_55 = iClose(symbol, TIMEFRAME, 0), hig_h4_55 = 0.0;

   for(int i = 0; i <= size; i++)
     {
      double close = iClose(symbol, TIMEFRAME, i);

      if(i == 0 || higest <= close)
        {
         higest = close;
         candle_index_sel = i;
        }
      if(i == 0 || lowest >= close)
        {
         lowest = close;
         candle_index_buy = i;
        }


      if((is_h4 && i <= 45) && (hig_h4_55 <= close))
        {
         hig_h4_55 = close;
         hig_idx_h4_55 = i;
        }
      if((is_h4 && i <= 45) && (low_h4_55 >= close))
        {
         low_h4_55 = close;
         low_idx_h4_55 = i;
        }
     }
   bool is_bold = false;

   if(true)
     {
      //vẽ BUY
      datetime cur_time = iTime(symbol, TIMEFRAME, (candle_index_buy-2>0?candle_index_buy-2:0));
      if(Period() == PERIOD_H4)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_buy + 3);
      if(Period() == PERIOD_H1)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_buy + 3);

      datetime nex_time = iTime(symbol, TIMEFRAME, (candle_index_buy-3>0?candle_index_buy-3:candle_index_buy+3));

      double nex_price_1 = lowest*(1 + amp_percent*1);
      double nex_price_2 = lowest*(1 + amp_percent*2);
      double nex_price_3 = lowest*(1 + amp_percent*3);

      create_trend_line(prefix + ".buy_0", cur_time, nex_time, lowest,      clrGreen, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_1", cur_time, nex_time, nex_price_1, clrGreen, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_2", cur_time, nex_time, nex_price_2, clrGreen, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_3", cur_time, nex_time, nex_price_3, clrGreen, digits, false, false, is_bold, true);

      create_lable(prefix + ".lbl.buy_0",  nex_time, lowest, (string)(amp_percent*000) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_1",  nex_time, nex_price_1, (string)(amp_percent*100) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_2",  nex_time, nex_price_2, (string)(amp_percent*200) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_3",  nex_time, nex_price_3, (string)(amp_percent*300) +"%", clrBlack, digits);

      if(is_h4 && low_idx_h4_55 != candle_index_buy)
        {
         datetime time_w0_h4_fr = iTime(symbol, TIMEFRAME, (low_idx_h4_55-3>0?low_idx_h4_55-3:0));
         datetime time_w0_h4_to = iTime(symbol, TIMEFRAME, low_idx_h4_55+3);

         create_lable("lbl.w0.h4.buy_0",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*0), (string)(amp_percent*000) +"%", clrGreen, digits);
         create_lable("lbl.w0.h4.buy_1",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*1), (string)(amp_percent*100) +"%", clrGreen, digits);
         create_lable("lbl.w0.h4.buy_2",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*2), (string)(amp_percent*200) +"%", clrGreen, digits);

         create_trend_line("w0.h4.buy_0", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*0), clrGreen, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.buy_1", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*1), clrGreen, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.buy_2", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*2), clrGreen, digits, false, false, is_bold, true);
        }
     }

   if(true)
     {
      //vẽ SELL
      datetime cur_time = iTime(symbol, TIMEFRAME, (candle_index_sel-2>0?candle_index_sel-2:0));
      if(Period() == PERIOD_H4)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_sel + 3);
      if(Period() == PERIOD_H1)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_sel + 3);

      datetime nex_time = iTime(symbol, TIMEFRAME, (candle_index_sel-3>0?candle_index_sel-3:candle_index_sel+3));

      double nex_price_1 = higest*(1 - amp_percent*1);
      double nex_price_2 = higest*(1 - amp_percent*2);
      double nex_price_3 = higest*(1 - amp_percent*3);

      create_trend_line(prefix + ".sel_0", cur_time, nex_time, higest,      clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_1", cur_time, nex_time, nex_price_1, clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_2", cur_time, nex_time, nex_price_2, clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_3", cur_time, nex_time, nex_price_3, clrFireBrick, digits, false, false, is_bold, true);

      create_lable(prefix + ".lbl.sel_0",  nex_time, higest, (string)(amp_percent*000) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_1",  nex_time, nex_price_1, (string)(amp_percent*100) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_2",  nex_time, nex_price_2, (string)(amp_percent*200) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_3",  nex_time, nex_price_3, (string)(amp_percent*300) +"%", clrBlack, digits);

      if(is_h4 && low_idx_h4_55 != candle_index_sel)
        {
         datetime time_w0_h4_fr = iTime(symbol, TIMEFRAME, (hig_idx_h4_55-3>0?hig_idx_h4_55-3:0));
         datetime time_w0_h4_to = iTime(symbol, TIMEFRAME, hig_idx_h4_55+3);

         create_lable("lbl.w0.h4.sel_0",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*0), (string)(amp_percent*000) +"%",  clrFireBrick, digits);
         create_lable("lbl.w0.h4.sel_1",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*1), (string)(amp_percent*100) +"%",  clrFireBrick, digits);
         create_lable("lbl.w0.h4.sel_2",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*2), (string)(amp_percent*200) +"%",  clrFireBrick, digits);

         create_trend_line("w0.h4.sel_0", time_w0_h4_fr, time_w0_h4_to, hig_h4_55,                     clrFireBrick, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.sel_1", time_w0_h4_fr, time_w0_h4_to, hig_h4_55*(1 - amp_percent*1), clrFireBrick, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.sel_2", time_w0_h4_fr, time_w0_h4_to, hig_h4_55*(1 - amp_percent*2), clrFireBrick, digits, false, false, is_bold, true);
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heikens()
  {
   if(Period() == PERIOD_H4 || Period() == PERIOD_H1)
      Draw_Heiken(_Symbol, PERIOD_D1, 25);

   if(Period() == PERIOD_D1)
      Draw_Heiken(_Symbol, PERIOD_MN1, 10);

   if(Period() == PERIOD_H4 || Period() == PERIOD_D1)
      Draw_Heiken(_Symbol, PERIOD_W1, 25);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken(string symbol, ENUM_TIMEFRAMES PERIOD_XX, int length)
  {
   CandleData arr_w[];
   get_arr_heiken(symbol, PERIOD_XX, arr_w, length);

   string PREFIX_TRADE_PERIOD_XX = get_prefix_trade_from_current_timeframe(PERIOD_XX);
   StringReplace(PREFIX_TRADE_PERIOD_XX, "1", "");

   bool is_solid = true;
   datetime time_1d = iTime(symbol, PERIOD_D1, 1) - iTime(symbol, PERIOD_D1, 2);
   if(PERIOD_XX < PERIOD_W1)
      is_solid = false;

   for(int i = 0; i < ArraySize(arr_w) - 2; i++)
     {
      string prefix = "Heiken_" + (string)iTime(symbol, PERIOD_XX, i) + "_" + PREFIX_TRADE_PERIOD_XX + "_";
      StringReplace(prefix, " ", "");

      CandleData candle_i = arr_w[i];

      datetime time_i1;

      datetime time_i2 = iTime(symbol, PERIOD_XX, i);
      if(i == 0)
        {
         time_i1 = time_i2 + time_1d * 1;

         if(PERIOD_XX == PERIOD_MN1)
            time_i1 = time_i2 + time_1d * 30;

         if(PERIOD_XX == PERIOD_W1)
            time_i1 = time_i2 + time_1d * 5;
        }
      else
        {
         time_i1 = iTime(symbol, PERIOD_XX, i-1);
        }

      string candle_x = "  ";
      candle_x += PREFIX_TRADE_PERIOD_XX;
      StringReplace(candle_x, "_", "");

      if(DEBUG_ON_HISTORY_DATA && Period() == PERIOD_H4)
         candle_x += "." + (candle_i.trend == TREND_BUY ? "B" : "S");
      candle_x += "." + (string) candle_i.count + "\n";

      color clrColor = candle_i.trend == TREND_BUY ? clrCadetBlue : clrFireBrick;

      create_line(prefix + "O", time_i2, candle_i.open,  time_i1, candle_i.open,  clrColor, is_solid);
      create_line(prefix + "C", time_i2, candle_i.close, time_i1, candle_i.close, clrColor, is_solid);
      create_line(prefix + "L", time_i2, candle_i.open,  time_i2, candle_i.close, clrColor, is_solid);
      create_line(prefix + "R", time_i1, candle_i.open,  time_i1, candle_i.close, clrColor, is_solid);
      create_lable_trim(prefix + "No.", time_i2, MathMax(candle_i.open, candle_i.close), candle_x, clrColor, 5, 8, ANCHOR_LEFT_LOWER);

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string find_trend_by_wd(string symbol)
  {
   string trend_w7 = get_trend_by_ma(symbol, PERIOD_W1, 7, 1);
   string trend_d10_1 = get_trend_by_ma(symbol, PERIOD_D1, 10, 1);

   if(trend_w7 == trend_d10_1)
      return trend_w7;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBB(string symbol)
  {
   if(is_same_symbol(_Symbol, symbol) == false)
      return;


   datetime label_postion = iTime(symbol, _Period, 0);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   string tradingview_symbol = get_tradingview_symbol(symbol);

   double d1_ma10 = cal_MA_XX(symbol, PERIOD_D1, 10, 0); //get_ma_value(symbol, PERIOD_D1, 10, 0);
   double h4_ma50 = cal_MA_XX(symbol, PERIOD_H4, 50, 0); //get_ma_value(symbol, PERIOD_H4, 50, 0);

   string find_trade = find_trend_by_wd(symbol);
   if(find_trade != "")
      find_trade = " (find): " + find_trade;

   string lable_d1 = "--- " + tradingview_symbol + free_overnight(tradingview_symbol) + find_trade;
   string lable_h4 = "   ---H4(50)";

   create_lable_trim("d1_ma10", label_postion, d1_ma10, lable_d1, clrGreen, digits, 9);
   create_lable_trim("h4_ma50", label_postion, h4_ma50, lable_h4, clrGreen, digits, 9);


   if(Period() > PERIOD_D1)
      return;

   string str_line = "   ";
   for(int index = 1; index <= 3; index++)
      str_line += "-";


   double upper_d1_20_1[], middle_d1_20_1[], lower_d1_20_1[];
   CalculateBollingerBands(symbol, PERIOD_D1, upper_d1_20_1, middle_d1_20_1, lower_d1_20_1, digits, 1);
   double hi_d1_20_1 = upper_d1_20_1[0];
   double mi_d1_20_0 = middle_d1_20_1[0];
   double lo_d1_20_1 = lower_d1_20_1[0];

   double amp_d1 = MathAbs(hi_d1_20_1 - mi_d1_20_0);

   string str_stop = " D(00)";

   double upper_h1[], middle_h1[], lower_h1[];
   CalculateBollingerBands(symbol, PERIOD_H1, upper_h1, middle_h1, lower_h1, digits, 1);
   double mi_h1_20_0 = middle_h1[0];
   double amp_h1 = MathAbs(upper_h1[0] - middle_h1[0]);
   double hi_h1_20_2 = mi_h1_20_0 + amp_h1*2;
   double lo_h1_20_2 = mi_h1_20_0 - amp_h1*2;
   create_lable_trim("Hi_H1(20, 2)", label_postion, hi_h1_20_2, str_line + "------------------H1+2", clrGreen, digits);
   create_lable_trim("Lo_H1(20, 2)", label_postion, lo_h1_20_2, str_line + "------------------H1-2", clrGreen, digits);

//double upper_15[], middle_15[], lower_15[];
//CalculateBollingerBands(symbol, PERIOD_M15, upper_15, middle_15, lower_15, digits, 1);
//double mi_15_20_0 = middle_15[0];
//double amp_15 = MathAbs(upper_15[0] - middle_15[0]);
//double hi_15_20_2 = mi_15_20_0 + amp_15*2;
//double lo_15_20_2 = mi_15_20_0 - amp_15*2;
//create_lable_trim("Hi_M15(20, 2)", label_postion, hi_15_20_2, str_line + "---------------------------15+2", clrGreen, digits);
//create_lable_trim("Lo_M15(20, 2)", label_postion, lo_15_20_2, str_line + "---------------------------15-2", clrGreen, digits);

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 1);
   double mi_h4_20_0 = middle_h4[0];
   double amp_h4 = MathAbs(upper_h4[0] - middle_h4[0]);

   double hi_h4_20_2 = mi_h4_20_0 + amp_h4*2;
   double lo_h4_20_2 = mi_h4_20_0 - amp_h4*2;


   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, str_line + "---------H4+2", clrGreen, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, str_line + "---------H4-2", clrGreen, digits);

   ObjectSetInteger(0, "redrw_" + "mi_d1_20_0", OBJPROP_STYLE, STYLE_DASH);
   for(int i = 2; i<=5; i++)
     {
      bool is_solid = false;
      bool is_ray_left = (i==2) ? true : false;
      color line_color = clrGreen;
      if(i == 1)
         line_color = clrDimGray;
      if(i == 2)
         line_color = clrGreen;
      if(i == 3)
         line_color = clrMediumSeaGreen;
      if(i == 4)
         line_color = clrGreen;
      if(i == 5)
         line_color = clrRed;
      line_color = clrGreen;

      double hi_d1_20_i = mi_d1_20_0 + (i*amp_d1);
      double lo_d1_20_i = mi_d1_20_0 - (i*amp_d1);

      create_lable_trim("lbl_hi_d1_20_" + (string)i, label_postion, hi_d1_20_i, str_line + " D+" + (string)i + "", line_color, digits);
      create_lable_trim("lbl_lo_d1_20_" + (string)i, label_postion, lo_d1_20_i, str_line + " D-" + (string)i + "", line_color, digits);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_sl_default(string symbol, string TRADING_TREND, int start_index)
  {
   double lowest = 0.0;
   double higest = 0.0;

   for(int j = 0; j <= STOP_LOSS_CANDLES; j++)
     {
      double lowPrice = iLow(symbol,  PERIOD_H4, start_index+j);
      double higPrice = iHigh(symbol, PERIOD_H4, start_index+j);

      if((j == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((j == 0) || (higest < higPrice))
         higest = higPrice;
     }

   if(TRADING_TREND == TREND_BUY)
      return lowest;

   if(TRADING_TREND == TREND_SEL)
      return higest;

   return 0.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_stoploss_in_file(string symbol, ulong ticket, string TRADING_TREND, datetime opentime)
  {
   double sl_3candles = 0;

   string text = ReadFileContent(FILE_SAVE_STOP_LOSS);
   string key = create_key(PREFIX_TRADE_PERIOD_H4, symbol, TRADING_TREND);

   bool found_sl = false;
   int index = StringFind(text, key);

   if(index != -1)
     {
      // Tìm vị trí của chuỗi "@SL:" sau chuỗi key
      int sl_index = StringFind(text, "@SL:", index);
      int tk_index = StringFind(text, (string) ticket, index);

      if((sl_index != -1) && (tk_index != -1))
        {
         // Tìm vị trí của ký tự "@" sau chuỗi "@SL:"
         int next_index = StringFind(text, "@", sl_index + 4);

         // Lấy phần chuỗi từ vị trí của "@SL:" đến vị trí của ký tự "@" tiếp theo
         string sl_text = StringSubstr(text, sl_index + 4, next_index - sl_index - 4);

         if(sl_text != "")
            sl_3candles = StringToDouble(sl_text);

         // Alert(symbol, "    ", ticket, "    ", TRADING_TREND, "    sl_text:", sl_text);
        }
     }

   if(sl_3candles <= 0)
     {
      datetime time_find = opentime + (iTime(symbol, PERIOD_H4, 1) - iTime(symbol, PERIOD_H4, 2));

      for(int i = 0; i <= 100; i++)
        {
         datetime time = iTime(symbol, PERIOD_H4, i);
         if(time <= time_find)
           {
            sl_3candles = get_sl_default(symbol, TRADING_TREND, i);
            break;
           }
        }

      if(TRADING_TREND == TREND_BUY && sl_3candles <= 0)
         sl_3candles = iLow(symbol, PERIOD_W1, 0);

      if(TRADING_TREND == TREND_SEL && sl_3candles <= 0)
         sl_3candles = iHigh(symbol, PERIOD_W1, 0);

      add_memo_to_file(FILE_SAVE_STOP_LOSS, PREFIX_TRADE_PERIOD_H4, symbol, TRADING_TREND, (string) sl_3candles, ticket);
     }


   return sl_3candles;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Save_Entry(string symbol)
  {
   datetime time_2candles = (iTime(symbol, PERIOD_H4, 1) - iTime(symbol, PERIOD_H4, 2))*2;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();
            double price_open = m_position.PriceOpen();

            datetime opentime = m_position.Time();
            string comments = m_position.Comment();

            string TRADING_TREND = "";
            if(StringFind(toLower(m_position.TypeDescription()), "buy") >= 0)
               TRADING_TREND = TREND_BUY ;
            if(StringFind(toLower(m_position.TypeDescription()), "sel") >= 0)
               TRADING_TREND = TREND_SEL ;

            double sl_3candles = get_stoploss_in_file(symbol, ticket, TRADING_TREND, opentime);

            string str_profit = "";
            str_profit += StringFind(toLower(m_position.TypeDescription()), "buy") >= 0 ? "(Buy)" : "(Sel)" ;
            str_profit += m_position.Comment() + "   P: " + (string) NormalizeDouble(m_position.Profit(), 1) + "$";

            datetime nex_time = opentime - (iTime(symbol, PERIOD_H1, 1) - iTime(symbol, PERIOD_H1, 10));
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

            bool is_stop_loss = false;
            double close_c1 = iClose(symbol, PERIOD_H4, 1);
            if(sl_3candles > 0 && TRADING_TREND == TREND_BUY && close_c1 < sl_3candles)
              {
               is_stop_loss = true;
               str_profit += "_STOP_LOSS";
              }
            if(sl_3candles > 0 && TRADING_TREND == TREND_SEL && close_c1 > sl_3candles)
              {
               is_stop_loss = true;
               str_profit += "_STOP_LOSS";
              }

            color clr_profit_color = clrGreen;
            if(m_position.Profit() < 0)
               clr_profit_color = clrRed;

            color clrColor = StringFind(toLower(m_position.TypeDescription()), "buy") >= 0 ? clrGreen : clrRed;

            ENUM_TIMEFRAMES TRADE_PERIOD = get_cur_timeframe(comments);
            double amp_trade_default = get_amp_trade(symbol, TRADE_PERIOD);

            create_lable("lbl_" + (string) ticket, opentime, price_open, str_profit, clr_profit_color, digits);


            double amp = NormalizeDouble(MathAbs(m_position.PriceOpen() - sl_3candles) / 2, digits);
            double top = m_position.PriceOpen() + amp;
            double bot = m_position.PriceOpen() - amp;

            string mask_name = "mask_sl_" + TRADING_TREND + "_" + (string) ticket;
            create_line(mask_name, opentime, top,  opentime, bot, clrColor, true);
            ObjectSetInteger(0, "redrw_" + mask_name, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, "redrw_" + mask_name, OBJPROP_RAY_LEFT, true);

            create_lable("lbl_" + mask_name, opentime, sl_3candles, "SL: "+ (string) sl_3candles, clrColor, digits);
            create_trend_line("sl_" + TRADING_TREND + "_" + (string) ticket, opentime - time_2candles, opentime + time_2candles, sl_3candles, clrColor, 5, false, false);
            //----------------------------------------------------------

            if(is_stop_loss)
               m_trade.PositionClose(ticket);
           }
        }
     }

  }

//+------------------------------------------------------------------+
void Draw_PivotHorizontal_TimeVertical()
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

// -----------------------------------------------------------------------
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   datetime close_time_today = iTime(symbol, PERIOD_D1, 0) + 86400;
   double   yesterday_open   = iOpen(symbol, PERIOD_D1, 1);
   double   yesterday_close  = iClose(symbol, PERIOD_D1, 1);
   double   yesterday_high   = iHigh(symbol, PERIOD_D1, 1);
   double   yesterday_low    = iLow(symbol, PERIOD_D1, 1);
   color    yesterday_color  = get_line_color(yesterday_open, yesterday_close);

   double   today_open = iOpen(symbol, PERIOD_D1, 0);
   double   today_close = iClose(symbol, PERIOD_D1, 0);
   double   today_low = iLow(symbol, PERIOD_D1, 0);
   double   today_hig = iHigh(symbol, PERIOD_D1, 0);

   double pre_day_mid = (yesterday_high + yesterday_low) / 2.0;
   double today_mid = (today_hig + today_low) / 2.0;
   color day_mid_color = get_line_color(pre_day_mid, today_mid);

// -----------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

// -----------------------------------------------------------------------
   datetime time_1day = iTime(_Symbol, PERIOD_D1, 1) - iTime(_Symbol, PERIOD_D1, 2);

   datetime week_time_1 = iTime(symbol, PERIOD_W1, 1); //Returns the opening time of the bar
   datetime shift_chart = iTime(_Symbol, _Period, 0) - iTime(_Symbol, _Period, 10);
   datetime time_candle_cur = iTime(_Symbol, _Period, 0) + shift_chart;


//   for(int index = 0; index < 150; index ++)
//      if(Period() < PERIOD_H1)
//         create_vertical_line("H4_"+(string)index, iTime(_Symbol, PERIOD_H4, index), clrSilver, STYLE_DOT);
//      else
//         ObjectDelete(0, "H4_"+(string)index);
//
//
//   for(int index = 0; index < 150; index ++)
//      if(Period() < PERIOD_D1)
//         create_vertical_line("D"+(string)index, iTime(_Symbol, PERIOD_D1, index), clrSilver, STYLE_DOT);
//      else
//         ObjectDelete(0, "D"+(string)index);


//for(int index = 0; index < 35; index ++)
//   if(Period() < PERIOD_W1)
//      create_vertical_line("W"+(string)index,  iTime(symbol, PERIOD_W1, index),  clrBlack,STYLE_DASHDOTDOT, 2);
//   else
//      ObjectDelete(0, "W"+(string)index);


   for(int index = 0; index < 10; index ++)
     {
      if(Period() == PERIOD_D1)
         create_vertical_line("Mo"+(string)index,  iTime(symbol, PERIOD_MN1, index), clrBlack, STYLE_SOLID, 1);
      else
         ObjectDelete(0, "Mo"+(string)index);
     }

   bool allow_redraw_trendline = false;
   for(int index = 0; index < 35; index ++)
     {
      color line_color = clrBlack;
      bool is_solid = false;

      double w_s1  = dic_top_price - (week_amp*index);
      create_trend_line("w_dn_" + (string)index, week_time_1, TimeGMT(), w_s1, line_color, digits, true, true, is_solid, allow_redraw_trendline);
      ObjectSetInteger(0, "w_dn_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "w_dn_" + (string)index, OBJPROP_COLOR, clrSilver);

      double w_r1  = dic_top_price + (week_amp*index);
      create_trend_line("w_up_" + (string)index, week_time_1, TimeGMT(), w_r1, line_color, digits, true, true, is_solid, allow_redraw_trendline);
      ObjectSetInteger(0, "w_up_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "w_up_" + (string)index, OBJPROP_COLOR, clrSilver);
     }

//   if(Period() > PERIOD_H4)
//     {
//      double lowest = 0.0;
//      double higest = 0.0;
//      for(int i = 0; i <= 21; i++)
//        {
//         double lowPrice = iLow(symbol, PERIOD_W1, i);
//         double higPrice = iHigh(symbol, PERIOD_W1, i);
//
//         if((i == 0) || (lowest > lowPrice))
//            lowest = lowPrice;
//
//         if((i == 0) || (higest < higPrice))
//            higest = higPrice;
//        }
//
//      double mid_price = NormalizeDouble((higest + lowest) / 2, digits-1);
//      datetime time_pre_21w = iTime(symbol, PERIOD_W1, 21);
//
//      create_trend_line("low_21w", time_pre_21w, TimeCurrent(), lowest,    clrViolet, digits, false, false, false, allow_redraw_trendline);
//      create_trend_line("mid_21w", time_pre_21w, TimeCurrent(), mid_price, clrFireBrick,  digits, false, false, false, allow_redraw_trendline);
//      create_trend_line("hig_21w", time_pre_21w, TimeCurrent(), higest,    clrTomato,     digits, false, false, false, allow_redraw_trendline);
//
//      ObjectSetInteger(0, "low_21w", OBJPROP_STYLE, STYLE_SOLID);
//      ObjectSetInteger(0, "hig_21w", OBJPROP_STYLE, STYLE_SOLID);
//      ObjectSetInteger(0, "mid_price", OBJPROP_WIDTH, 1);
//      ObjectSetInteger(0, "mid_price", OBJPROP_COLOR, clrFireBrick);
//     }
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
//string name = "redrw_" + name0;
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
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, "        " + format_double_to_string(price, digits), clr_color);
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
   TextCreate(0,"redrw_" + name, 0, time_to, price, "        " + label, clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_trim(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const int               font_size=8,
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, label, clr_color);
   ObjectSetInteger(0,"redrw_" + name, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0,"redrw_" + name,OBJPROP_ANCHOR, anchor);
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
                const int               font_size=8,             // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,     // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,             // hidden in the object list
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
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const bool              ray_left = false,
   const bool              ray_right = true,
   const bool              is_solid_line = false,
   const bool              is_re_draw = true
)
  {
   string name_new = name;
   if(is_re_draw)
      name_new = "redrw_" + name;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 2);
     }
   else
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   double                  price_from=0,                   // anchor point price
   datetime                time_to=0,                   // anchor point time
   double                  price_to=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const bool              is_solid_line = false,
   const bool              is_re_draw = true
)
  {
   string name_new = name;
   if(is_re_draw)
      name_new = "redrw_" + name;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, false);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, false); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }
   else
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK, true);
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

//https://vn.investing.com/indices/vn100-components
//Dưới đây là các công ty còn lại từ chỉ số VN100 và được phân loại vào các ngành tương ứng:
//Công nghệ, Năng lượng tái tạo, Y tế và dược phẩm, Công nghiệp 4.0
//1. Ngân hàng:
//   - VCB (Vietcombank)
//   - TCB (Techcombank)
//   - MBB (MBBank)
//   - VPB (VPBank)
//   - HDB (HDBank)
//   - ACB (Asia Commercial Bank)
//   - LPB (LienVietPostBank)
//   - TPB (TPBank)
//
//2. Bất động sản:
//   - VIC (Vingroup)
//   - NLG (Nam Long Group)
//   - DXG (Dat Xanh Group)
//   - DIG (Đất Xanh Group)
//   - NVL (Novaland)
//   - KDH (Kinh Đô Corporation)
//
//3. Viễn thông:
//   - VNM (Viettel)
//   - FPT (FPT Corporation)
//   - VNG (VNG Corporation)
//   - GTEL (Global Telecom)
//   - CTS (Công ty cổ phần Viễn thông Công nghệ Sài Gòn)
//
//4. Hàng tiêu dùng:
//   - MSN (Masan Group)
//   - VNM (Vinamilk)
//   - SAB (Sabeco)
//   - MWG (Mobile World Group)
//   - PNJ (Phú Nhuận Jewelry)
//
//5. Năng lượng:
//   - GAS (PetroVietnam Gas)
//   - PLX (Petrolimex)
//   - POW (PetroVietnam Power)
//   - PVD (PetroVietnam Drilling and Well Services)
//
//6. Công nghệ:
//   - FPT (FPT Corporation)
//   - VNG (VNG Corporation)
//   - VCS (Vietnam National Petroleum Group)
//   - PTB (Petrolimex Trading Joint Stock Company)
//
//7. Sản xuất, y tế và dược phẩm
//   - HPG (Hoà Phát Group)
//   - DPM (Đạm Phú Mỹ)
//   - GEX (Gemadept Corporation)
//   - DHG: Công ty Cổ phần Dược Hậu Giang
//   - DMC: Công ty Cổ phần Dược phẩm MEDIC
//   - IMP: Công ty Cổ phần Dược phẩm Imexpharm


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
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   dic_amp_init_h4 = 0.01;

   SendAlert(INDI_NAME, "SymbolData", " Get SymbolData:" + (string)symbol + "   i_top_price: " + (string)i_top_price + "   amp_w: " + (string)amp_w + "   dic_amp_init_h4: " + (string)dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
