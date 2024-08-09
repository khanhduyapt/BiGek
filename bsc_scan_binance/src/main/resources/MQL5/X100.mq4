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
#define BtnNoticeW1              "BtnNoticeW1"
#define BtnNoticeD1              "BtnNoticeD1"
#define BtnNoticeH4              "BtnNoticeH4"
#define BtnNoticeH1              "BtnNoticeH1"
#define BtnTradeNow10D           "TRADE_NOW_10D"
#define BtnTradeReverse10D       "BtnTradeReverse10D"
#define BtnTPCurSymbol           "BtnTPCurSymbol"
#define BtnTelegramMessage       "Telegram_Message"
#define BtnTpDay_06_07           "BtnTpDay_06_07"
#define BtnTpDay_13_14           "BtnTpDay_13_14"
#define BtnTpDay_20_21           "BtnTpDay_20_21"
#define BtnTpDay_27_28           "BtnTpDay_27_28"
#define BtnTpDay_34_35           "BtnTpDay_34_35"
#define BtnSendNotice_D1         "BtnSendNoticeD1"
#define BtnSendNotice_H4         "BtnSendNoticeH4"
#define BtnSendNotice_H1         "BtnSendNoticeH1"
#define BtnTradeH1               "BtnTradeH1"
#define SendTeleMsg_             "SendTeleMsg_"
#define START_TRADE_LINE         "START_TRADE"
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
string MASK_REV_D10  = "(R.V)";
string MASK_LIMIT  = "(L.M)";
string MASK_TREND_TRANSFER = "(T.F)";
string SWITCH_TREND_BY_HISTOGRAM = "SwByHistogram_";
string LOCK = "(Lock)";
double MAXIMUM_DOUBLE = 999999999;
int count_closed_today = 0;
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
string FILE_NAME_AUTO_TRADE = "_auto_trade_today.txt";
datetime ALERT_MSG_TIME = 0;
datetime TIME_OF_ONE_H1_CANDLE = 3600;
datetime TIME_OF_ONE_H4_CANDLE = 14400;
datetime TIME_OF_ONE_D1_CANDLE = 86400;
datetime TIME_OF_ONE_W1_CANDLE = 604800;
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
bool isDragging = false;
double INIT_START_PRICE = 0.0;
color clrActiveBtn = clrLightGreen;
//+------------------------------------------------------------------+
string globalArrFlashSymbols[];
string trend_over_bs_by_stoc_w1 = "_";
string trend_over_bs_by_stoc_d1 = "_";
string trend_over_bs_by_stoc_h4 = "_";
string trend_over_bs_by_stoc_h1 = "_";
string trend_over_bs_by_stoc_15 = "_";
string trend_over_bs_by_stoc_05 = "_";
string trend_over_bs_by_stoc_01 = "_";
string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "", trend_vector_histogram_h4 = "", trend_vector_signal_h4 = "", trend_macd_note_h4="";
string trend_by_macd_h1 = "", trend_mac_vs_signal_h1 = "", trend_mac_vs_zero_h1 = "", trend_vector_histogram_h1 = "", trend_vector_signal_h1 = "", trend_macd_note_h1="";
string trend_by_macd_cu = "", trend_mac_vs_signal_cu = "", trend_mac_vs_zero_cu = "", trend_vector_histogram_cu = "", trend_vector_signal_cu = "", trend_macd_note_cu="";
string trend_week_by_time = "", trend_today_by_time = "", trend_by_ma10_w1 = "", trend_by_ma10_d1 = "", trend_by_ma10_h4 = "", trend_by_ma10_h1 = "";
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
   string            trend_by_ma05;
   string            trend_ma3_vs_ma5;
   int               count_ma3_vs_ma5;
   string            trend_seq;
   double            ma50;
   string            trend_ma10vs20;
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
      trend_by_ma05 = "";
      trend_ma3_vs_ma5 = "";
      count_ma3_vs_ma5 = 0;
      trend_seq = "";
      ma50 = 0;
      trend_ma10vs20 = "";
     }
                     CandleData(
      datetime t, double o, double h, double l, double c,
      string trend_heiken_, int count_heiken_,
      double ma10_, string trend_by_ma10_, int count_ma10_, string trend_vector_ma10_,
      string trend_by_ma05_, string trend_ma3_vs_ma5_, int count_ma3_vs_ma5_,
      string trend_seq_, double ma50_, string trend_ma10vs20_)
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
      trend_by_ma05 = trend_by_ma05_;
      trend_ma3_vs_ma5 = trend_ma3_vs_ma5_;
      count_ma3_vs_ma5 = count_ma3_vs_ma5_;
      trend_seq = trend_seq_;
      ma50 = ma50_;
      trend_ma10vs20 = trend_ma10vs20_;
     }
  };
CandleData arrHeiken_w1[];
CandleData arrHeiken_d1[];
CandleData arrHeiken_h4[];
CandleData arrHeiken_h1[];
CandleData arrHeiken_m5[];
CandleData arrHeiken_m1[];
string ARR_SYMBOLS[] =
  {
   "XAUUSD"
   , "AUDJPY", "NZDJPY", "EURJPY", "GBPJPY", "USDJPY"
   , "AUDUSD", "AUDNZD", "EURNZD", "GBPNZD", "NZDUSD", "EURAUD", "AUDCHF", "EURCHF", "GBPCHF", "USDCHF"
   , "EURGBP", "EURUSD", "GBPUSD", "EURCAD", "USDCAD"
   , "USOIL", "BTCUSD", "US30", "US500", "USTEC", "FR40", "JP225"
  };

string ARR_SYMBOLS_6[] =
  {
   "XAUUSDc"
   , "AUDJPYc", "NZDJPYc", "EURJPYc", "GBPJPYc", "USDJPYc", "AUDUSDc", "AUDNZDc"
   , "EURNZDc", "GBPNZDc", "NZDUSDc", "EURAUDc", "AUDCHFc", "EURCHFc", "GBPCHFc"
   , "USDCHFc", "EURGBPc", "EURUSDc", "GBPUSDc", "EURCADc", "USDCADc"
  };
//+------------------------------------------------------------------+
//| OpenTrade_X100                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//WriteAvgAmpToFile();
   string symbol = Symbol();

   Draw_CurPrice_Line();
   InitGlobalArrHeiken(symbol);
   Draw_Buttons_Trend(symbol);
   Draw_Notice_Ma10D();
   Draw_Heiken(symbol);

   string date_fr = "";
   string date_to = "";
   get_time_zones(symbol, date_fr, date_to);
   Draw_TimeZones(symbol + "1", date_fr, date_to, 5);
   Draw_TimeZones(symbol + "2", date_to, date_fr, 25);

   string time1, time2;
   double price1, scale;
   getGannGridProperties(symbol, time1, time2, price1, scale);
   if(price1 > 0 && scale > 0)
      createGannGrid("GannGrid", StringToTime(time1), StringToTime(time2), price1, scale);
   else
      ObjectDelete(0, "GannGrid");

   if(is_same_symbol(symbol, "XAU"))
      Draw_Lines(symbol);

   DeleteArrowObjects();
   EventSetTimer(900); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string symbol = Symbol();

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime, time_struct);
   int cur_hour = time_struct.hour;
   int pre_check_hour = -1;
   if(GlobalVariableCheck("timer_one_hour"))
      pre_check_hour = (int)GlobalVariableGet("timer_one_hour");
   GlobalVariableSet("timer_one_hour", cur_hour);
   bool allow_re_check_after_1h = false;
   if(pre_check_hour != cur_hour)
      allow_re_check_after_1h = true;

   Draw_CurPrice_Line();
   Add_Flashing_Color();

   int size = ArraySize(ARR_SYMBOLS);
   for(int index = 0; index < size; index++)
     {
      int count_L = 0;
      string find_trend = "";
      double total_profit = 0;
      bool has_opened_today = false;
      string temp_symbol = ARR_SYMBOLS[index];
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), temp_symbol))
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {
                  count_L += 1;
                  double profit = OrderProfit() + OrderSwap() + OrderCommission();
                  total_profit += profit;
                  find_trend = (OrderType() == OP_BUY) ? TREND_BUY : TREND_SEL;

                  color clrTrend = (profit > 0) ? clrBlue : clrRed;

                  if(is_same_symbol(symbol, temp_symbol))
                     create_lable_simple((string)OrderTicket(), (string)(int)profit + " $", OrderOpenPrice(), clrTrend);
                  else
                     ObjectDelete(0, (string)OrderTicket());

                  if(allow_re_check_after_1h)
                     has_opened_today = is_order_opened_today(temp_symbol);
                 }

      if(count_L > 0)
        {
         string objName = BtnD10 + temp_symbol;
         string buttonLabel = ObjectGetString(0, objName, OBJPROP_TEXT);

         string str_profit = (total_profit > 0 ? "+":"") + (string)(int)total_profit + to_percent(total_profit, 1) + (string)count_L + "L";;

         ObjectSetString(0, objName, OBJPROP_TEXT, ReplaceStringAfter(buttonLabel, "$", str_profit));

         if(allow_re_check_after_1h && has_opened_today == false)
           {
            if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, find_trend, 5, 3, 2))
              {
               Alert(symbol + " H1 allow " + find_trend);
              }
           }
        }
     }
//-------------------------------------------------------------------------------
     {
      int cur_minus = time_struct.min;
      int pre_check_minus = -1;
      if(GlobalVariableCheck("timer_one_minu"))
         pre_check_minus = (int)GlobalVariableGet("timer_one_minu");
      GlobalVariableSet("timer_one_minu", cur_minus);
      if(pre_check_minus != cur_minus)
         Draw_Notice_Ma10D();
     }
//-------------------------------------------------------------------------------
   if(pre_check_hour != cur_hour)
      Auto_SL_TP();
//-------------------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Notice_Ma10D()
  {
   int x = 5;
   int y = 5;
   int btn_width = 210;
   int btn_heigh = 20;
   int chart_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS))/2 - 50;
   double minimum_profit = minProfit();

   string STR_SYMBOLS_OPENING = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), STR_SYMBOLS_OPENING) == false)
            STR_SYMBOLS_OPENING += OrderSymbol();

   ObjectDelete(0, BtnTPCurSymbol);

   int count = 0;
   string master_msg = "";
   string prefix_msg = "";
   string arrNoticeSymbols_W[];
   string arrNoticeSymbols_D[];
   string arrNoticeSymbols_H4[];
   string arrNoticeSymbols_H1[];
   string strNoticeSymbols = "";
   string strTrade_Symbols_H1 = "";
   double risk_1p = risk_1_Percent_Account_Balance();

   ArrayResize(globalArrFlashSymbols, 0);
   int size = ArraySize(ARR_SYMBOLS);
   for(int index = 0; index < size; index++)
     {
      string symbol = ARR_SYMBOLS[index];

      string str_profit = "";
      string trading_trend = "";
      double total_profit = 0;
      int count_L = 0;
      if(is_same_symbol(symbol, STR_SYMBOLS_OPENING))
         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
               if(is_same_symbol(OrderSymbol(), symbol))
                 {

                  trading_trend += OrderType() == OP_BUY ? TREND_BUY : "";
                  trading_trend += OrderType() == OP_SELL ? TREND_SEL : "";
                  total_profit += OrderProfit() + OrderSwap() + OrderCommission();

                  if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                     count_L += 1;
                 }

      if(count_L > 0)
         str_profit = " $" + (total_profit > 0 ? "+":"") + (string)(int)total_profit + to_percent(total_profit, 1);

      CandleData temp_array_W1[];
      get_arr_heiken(symbol, PERIOD_W1, temp_array_W1);

      CandleData temp_array_D1[];
      get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 45, true);

      CandleData temp_array_H4[];
      get_arr_heiken(symbol, PERIOD_H4, temp_array_H4, 15, true);

      CandleData temp_array_H1[];
      get_arr_heiken(symbol, PERIOD_H1, temp_array_H1, 15, true);

      string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "", trend_vector_histogram_d1 = "", trend_vector_signal_d1 = "", trend_macd_note_d1="";
      get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1, trend_vector_histogram_d1, trend_vector_signal_d1, trend_macd_note_d1);

      string trend_ma10_w1 = temp_array_W1[0].trend_by_ma10;
      string trend_ma10_d1 = temp_array_D1[0].trend_by_ma10;
      string trend_ma10_h4 = temp_array_H4[0].trend_by_ma10;
      string trend_ma10vs20_d1 = temp_array_D1[0].trend_ma10vs20;

      string trend_heiken_d1 = temp_array_D1[0].trend_heiken;
      string trend_heiken_h4 = temp_array_H4[0].trend_heiken;

      string all_trend_wdh = trend_ma10_w1 + trend_ma10_d1 + trend_ma10_h4 +
                             trend_heiken_d1 + trend_heiken_h4;

      bool d1_allow_trade = temp_array_D1[1].trend_by_ma10 == temp_array_D1[0].trend_heiken ? true : false;

      string trend_week_must_follow = (trend_ma10_w1 == temp_array_W1[0].trend_by_ma05) &&
                                      (trend_ma10_w1 == temp_array_W1[0].trend_heiken)
                                      ? trend_ma10_w1 : "";

      bool allow_reverse = (trend_week_must_follow == trend_ma10_d1 &&
                            trend_week_must_follow == temp_array_D1[0].trend_ma3_vs_ma5)
                           ? false : true;

      string Notice_Symbol = (string) GetGlobalVariable(SendTeleMsg_ + symbol);

      string key_d1_buy = (string)PERIOD_D1 + (string)OP_BUY;
      string key_d1_sel = (string)PERIOD_D1 + (string)OP_SELL;

      if(is_same_symbol(Notice_Symbol, key_d1_buy) && is_same_symbol(Notice_Symbol, key_d1_sel))
         GlobalVariableSet(SendTeleMsg_ + symbol, -1);
      else
         if(is_same_symbol(Notice_Symbol, key_d1_buy) || is_same_symbol(Notice_Symbol, key_d1_sel))
           {
            string find_trend = is_same_symbol(Notice_Symbol, key_d1_buy)? TREND_BUY :
                                is_same_symbol(Notice_Symbol, key_d1_sel) ? TREND_SEL : "";

            if(find_trend == temp_array_D1[0].trend_by_ma10 &&
               find_trend == temp_array_H1[0].trend_heiken &&
               find_trend == temp_array_H4[0].trend_heiken &&
               find_trend == temp_array_D1[0].trend_heiken &&
               find_trend == temp_array_D1[0].trend_by_ma10)
              {
               StringReplace(Notice_Symbol, key_d1_buy, "");
               StringReplace(Notice_Symbol, key_d1_sel, "");
               GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);

               SendTelegramMessage(symbol, find_trend, SendTeleMsg_ + symbol + " D1 " + find_trend, true);

               OpenChartWindow(symbol);
              }
           }

      string key_h4_buy = (string)PERIOD_H4 + (string)OP_BUY;
      string key_h4_sel = (string)PERIOD_H4 + (string)OP_SELL;

      if(is_same_symbol(Notice_Symbol, key_h4_buy) && is_same_symbol(Notice_Symbol, key_h4_sel))
         GlobalVariableSet(SendTeleMsg_ + symbol, -1);
      else
         if(is_same_symbol(Notice_Symbol, key_h4_buy) || is_same_symbol(Notice_Symbol, key_h4_sel))
           {
            string find_trend = is_same_symbol(Notice_Symbol, key_h4_buy)? TREND_BUY : is_same_symbol(Notice_Symbol, key_h4_sel) ? TREND_SEL : "";

            if(find_trend == temp_array_D1[0].trend_by_ma10 &&
               find_trend == temp_array_H1[0].trend_heiken &&
               find_trend == temp_array_H4[0].trend_heiken &&
               find_trend == temp_array_H4[0].trend_by_ma05 &&
               find_trend == temp_array_H4[0].trend_by_ma10 &&
               (temp_array_H4[0].count_ma3_vs_ma5 < 3 || temp_array_H4[0].count_ma10 < 3))
              {
               StringReplace(Notice_Symbol, key_h4_buy, "");
               StringReplace(Notice_Symbol, key_h4_sel, "");
               GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);

               SendTelegramMessage(symbol, find_trend, SendTeleMsg_ + symbol + " H4 " + find_trend, true);

               OpenChartWindow(symbol);
              }
           }

      string key_h1_buy = (string)PERIOD_H1 + (string)OP_BUY;
      string key_h1_sel = (string)PERIOD_H1 + (string)OP_SELL;

      if(is_same_symbol(Notice_Symbol, key_h1_buy) && is_same_symbol(Notice_Symbol, key_h1_sel))
         GlobalVariableSet(SendTeleMsg_ + symbol, -1);
      else
         if(is_same_symbol(Notice_Symbol, key_h1_buy) || is_same_symbol(Notice_Symbol, key_h1_sel))
           {
            string find_trend = is_same_symbol(Notice_Symbol, key_h1_buy)? TREND_BUY : is_same_symbol(Notice_Symbol, key_h1_sel) ? TREND_SEL : "";

            if(find_trend == temp_array_H4[0].trend_heiken &&
               find_trend == temp_array_H1[0].trend_heiken &&
               find_trend == temp_array_H1[0].trend_by_ma05 &&
               find_trend == temp_array_H1[0].trend_by_ma10 &&
               (temp_array_H1[0].count_ma3_vs_ma5 < 3 || temp_array_H1[0].count_ma10 < 3))
              {
               StringReplace(Notice_Symbol, key_h1_buy, "");
               StringReplace(Notice_Symbol, key_h1_sel, "");
               GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);

               SendTelegramMessage(symbol, find_trend, SendTeleMsg_ + symbol + " H1 " + find_trend, true);

               OpenChartWindow(symbol);
              }
           }

      int count_d10 = temp_array_D1[0].count_ma10;
      int count_hei_d1 = temp_array_D1[0].count_heiken;

      if(total_profit > minimum_profit)
        {
         string key_d_count = "_" + (string)count_d10 + "_";
         string day_stop_trade = get_day_stop_trade(symbol, true);
         if(is_same_symbol(day_stop_trade, key_d_count))
           {
            string trend_reverse_d1 = get_trend_reverse(trend_ma10_d1);
            string oo_h4 = get_trend_allow_trade_by_stoc(symbol, PERIOD_H4);
            if(is_same_symbol(oo_h4, trend_reverse_d1))
              {
               string oo_h1 = get_trend_allow_trade_by_stoc(symbol, PERIOD_H1);
               if(is_same_symbol(oo_h1, trend_reverse_d1))
                 {
                  string oo_05 = get_trend_allow_trade_by_stoc(symbol, PERIOD_M5);
                  if(is_same_symbol(oo_05, trend_reverse_d1))
                     if(ClosePositivePosition(symbol, trend_ma10_d1))
                        SendTelegramMessage(symbol, trend_ma10_d1, "TAKE_PROFIT " + symbol
                                            + " by count_d10=" + (string)count_d10
                                            + " Profit: " + (string)(int) total_profit, true);
                 }
              }
           }
        }

      color clrD10 = trend_ma10_d1 == TREND_BUY ? clrBlue : clrRed;
      bool is_cur_tab = is_same_symbol(symbol, ChartSymbol(0));

      string lblWeek = "";
      bool pass_count_cond_d10 = (count_d10 <= 3);
      if((trend_ma10_d1 == trend_ma10_w1))
        {
         lblWeek = "W" + (string)temp_array_W1[0].count_ma10 + "" ;

         if(count_d10 <= 5)
            pass_count_cond_d10 |= (trend_ma10_d1 == temp_array_D1[0].trend_heiken) && (count_hei_d1 <= 1);
        }


      string lblBtn10 = (lblWeek != "" ? lblWeek + " ": "") + symbol + " " + getShortName(trend_ma10_d1) + "" + (string)(count_d10) + "";
      if(count_L > 0)
        {
         lblBtn10 += str_profit;
         lblBtn10 += (string)count_L + "L";
        }
      StringReplace(lblBtn10, "  ", " ");


      color clrBackground = pass_count_cond_d10 && is_same_symbol(trend_week_must_follow, trend_ma10_d1) ? clrLightGreen : pass_count_cond_d10 ? clrYellowGreen : clrLightGray;
      if(is_cur_tab)
         clrBackground = clrPaleTurquoise;
      if(count_L > 0 && trend_ma10_d1 != "")
         if(!is_same_symbol(trading_trend, trend_ma10_d1) && !is_same_symbol(trading_trend, trend_heiken_d1))
            clrBackground = clrYellow;


      color clrText = total_profit > 0 ? clrBlue : (MathAbs(total_profit) > risk_1p) ? clrRed : clrBlack;

      if(temp_array_W1[0].count_ma10 == 1 || temp_array_W1[0].count_ma3_vs_ma5 == 1 || temp_array_W1[0].count_heiken <= 2)
        {
         int num_symbols = ArraySize(arrNoticeSymbols_W);
         ArrayResize(arrNoticeSymbols_W, num_symbols+1);

         string str_doji = temp_array_W1[0].count_ma10 == 1 ? "(Ma10) " + temp_array_W1[0].trend_by_ma10 : "(Hei1) " + temp_array_W1[1].trend_heiken;
         strNoticeSymbols += symbol + ".";
         arrNoticeSymbols_W[num_symbols] = str_profit + " W " + str_doji + " D (" + getShortName(trend_ma10_d1) + (string) count_d10 + ") ~" + symbol;
        }

      if((1 < count_d10 && count_d10 < 3) ||
         (is_same_symbol(trend_week_must_follow, trend_heiken_d1) && count_hei_d1 < 3) ||
         (temp_array_D1[1].trend_by_ma10 == trend_vector_histogram_d1 && trend_vector_histogram_d1 != "" && trend_ma10_d1 != trend_vector_histogram_d1))
        {
         int num_symbols = ArraySize(arrNoticeSymbols_D);
         ArrayResize(arrNoticeSymbols_D, num_symbols+1);

         strNoticeSymbols += symbol + ".";
         arrNoticeSymbols_D[num_symbols] = str_profit + " D1(" + trend_ma10_d1 + " " + (string) count_d10 + ") ~" + symbol;

         if(is_same_symbol(trend_week_must_follow, trend_ma10_d1))
            clrBackground = clrActiveBtn;
         else
            clrBackground = clrYellowGreen;
        }

      string trend_seq_h4 = temp_array_H4[1].trend_seq != "" ? temp_array_H4[1].trend_seq  : temp_array_H4[0].trend_seq != "" ? temp_array_H4[0].trend_seq  : "";
      if(trend_seq_h4 != "")
        {
         int num_symbols = ArraySize(arrNoticeSymbols_H4);
         ArrayResize(arrNoticeSymbols_H4, num_symbols+1);

         arrNoticeSymbols_H4[num_symbols] = str_profit + " H4.Seq." + trend_seq_h4 + " D(" + getShortName(trend_ma10_d1) + "." + (string) count_d10 + ") ~" + symbol;
        }

      string strLblBtnTradeH1 = "";
      string trend_seq_h1 = temp_array_H1[1].trend_seq != "" ? temp_array_H1[1].trend_seq  : temp_array_H1[0].trend_seq != "" ? temp_array_H1[0].trend_seq : "";
      if((trend_seq_h1 != "") && is_same_symbol(trend_by_ma10_d1 + trend_ma10vs20_d1, trend_seq_h1))
        {
         int num_symbols = ArraySize(arrNoticeSymbols_H1);
         ArrayResize(arrNoticeSymbols_H1, num_symbols+1);

         strTrade_Symbols_H1 += "~" + symbol;
         string lblH1Seq = str_profit + " H1.Seq." + trend_seq_h1 + " D.(" + getShortName(trend_ma10_d1) + "." + (string) count_d10 + ") ~" + symbol;
         arrNoticeSymbols_H1[num_symbols] = lblH1Seq;
         if(is_cur_tab)
            strLblBtnTradeH1 = lblH1Seq;
        }

      btn_heigh = index == 0 ? 80 : 20;
      if(index == 0 && size < 22)
         btn_heigh = 80;
      if(index == 0 && size >= 22)
         btn_heigh = 110;

      if(index == 0)
         lblBtn10 += " " + format_double_to_string(SymbolInfoDouble(symbol, SYMBOL_BID), 1) + "$";
      if(index == 8)
        {count = 0; x = btn_width+10; y = 35; btn_heigh = 20;}
      if(index == 15)
        {count = 0; x = btn_width+10; y = 65; btn_heigh = 20;}
      if(index == 21)
        {count = 0; x = btn_width+10; y = 95; btn_heigh = 20;}

      int sub_window = 3;
      createButton(BtnD10 + symbol, lblBtn10, x + (btn_width + 5)*count, is_cur_tab && (index > 0) ? y - 7 : y, btn_width, (index == 0) ? btn_heigh : is_cur_tab ? btn_heigh+15 : btn_heigh, clrText, clrBackground, 7, sub_window);

      if(is_same_symbol(symbol, STR_SYMBOLS_OPENING))
         createButton("_" + symbol, "", x + (btn_width + 5)*count, y + (is_cur_tab ? 3 : 0) + btn_heigh, btn_width, 5, clrBlack, clrLightGreen, 8, sub_window);
      count += 1;

      double vol = 0;
      if(is_cur_tab)
        {
         Comment(GetComments());
         ObjectSetString(0, BtnD10 + symbol, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, BtnD10 + symbol, OBJPROP_COLOR, clrText);

         createButton(BtnTpDay_06_07, "D 06 07", 10, chart_heigh-25*2, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_06_07 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_13_14, "D 13 14", 10, chart_heigh-25*1, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_13_14 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_20_21, "D 20 21", 10, chart_heigh-25*0, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_20_21 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_27_28, "D 27 28", 10, chart_heigh+25*1, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_27_28 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_34_35, "D 34 35", 10, chart_heigh+25*2, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_34_35 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);

         if(is_same_symbol(strTrade_Symbols_H1, symbol))
           {
            color clrBtnTradeH1 = is_same_symbol(strLblBtnTradeH1, TREND_BUY) ? clrBlue : clrRed;
            createButton(BtnTradeH1, strLblBtnTradeH1, chart_width/2, chart_heigh, 300, 20, clrBlack, clrBtnTradeH1, 7);
           }

         if(Period() <= PERIOD_H4)
           {
            double amp_w1, amp_d1, amp_h4, amp_grid_L100;
            GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

            trend_seq_h4 = arrHeiken_h4[1].trend_seq + arrHeiken_h4[0].trend_seq;
            if(trend_seq_h4 == "")
               trend_seq_h4 = arrHeiken_w1[0].trend_heiken;
            double ma50 = temp_array_H4[0].ma50;
            double next = trend_seq_h4 == TREND_BUY ? ma50 + amp_d1 : ma50 - amp_d1;

            color clrAmpH4 = is_same_symbol(trend_seq_h4, TREND_BUY) ? clrPowderBlue : is_same_symbol(trend_seq_h4, TREND_SEL) ? clrFireBrick : clrSilver;
            create_trend_line("LINE_AMP_D", TimeCurrent(), ma50, TimeCurrent(), next, clrAmpH4, STYLE_SOLID, 20);
            ObjectSetInteger(0, "LINE_AMP_D", OBJPROP_STATE, true);
            ObjectSetInteger(0, "LINE_AMP_D", OBJPROP_SELECTED, true);
            ObjectSetInteger(0, "LINE_AMP_D", OBJPROP_SELECTABLE, true);
           }

         double min_7w = 0;
         double max_7w = 0;
         for(int i = 0; i < 7; i++)
           {
            if(i==0 || min_7w > temp_array_W1[i].low)
               min_7w = temp_array_W1[i].low;

            if(i==0 || max_7w < temp_array_W1[i].high)
               max_7w = temp_array_W1[i].high;
           }

         double amp_w1, amp_d1, amp_h4, amp_grid_L100;
         GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

         double sl = trend_ma10_d1 == TREND_BUY ? min_7w - amp_h4: max_7w + amp_h4;
         double amp_sl = trend_ma10_d1 == TREND_BUY ? (Bid - sl) : (sl - Ask);
         amp_sl = MathMax(amp_sl, amp_w1);

         double min_21w = 0;
         double max_21w = 0;
         int size_w1 = ArraySize(temp_array_W1);
         for(int i = 0; i < size_w1; i++)
           {
            if(i==0 || min_21w > temp_array_W1[i].low)
               min_21w = temp_array_W1[i].low;

            if(i==0 || max_21w < temp_array_W1[i].high)
               max_21w = temp_array_W1[i].high;
           }

         double amp_tp  = trend_ma10_d1 == TREND_BUY ? (max_21w - Ask) : (Bid - min_21w);
         double risk_5p = risk_5p_Percent_Account_Equity();
         vol = calc_volume_by_amp(symbol, amp_sl, risk_5p);

         double tp = trend_ma10_d1 == TREND_BUY ? max_21w : min_21w;
         string rr_d1 = "1:" + format_double_to_string(amp_tp/amp_sl, 1) + " ";

         datetime timeW0 = iTime(symbol, PERIOD_W1, 0) - TIME_OF_ONE_W1_CANDLE*3;
         create_lable("RR", TimeCurrent()+TIME_OF_ONE_W1_CANDLE, tp, rr_d1);
         create_trend_line("SL", timeW0, sl, TimeCurrent()+TIME_OF_ONE_W1_CANDLE, sl, clrBlack, STYLE_DASH, 1, false);
         create_trend_line("TP", timeW0, tp, TimeCurrent()+TIME_OF_ONE_W1_CANDLE, tp, clrBlack, STYLE_DASH, 1, false);
         create_trend_line("Ma10D", timeW0, temp_array_D1[0].ma10, TimeCurrent()+TIME_OF_ONE_W1_CANDLE, temp_array_D1[0].ma10, clrBlack, STYLE_SOLID, 1, false);
         create_trend_line("Ma10W", timeW0, temp_array_W1[0].ma10, TimeCurrent()+TIME_OF_ONE_W1_CANDLE, temp_array_W1[0].ma10, clrBlack, STYLE_SOLID, 2, false);

         int x_btn, y_btn;
         ObjectDelete(0, BtnTradeNow10D);
         //if(trend_ma10_d1 == temp_array_H4[0].trend_heiken)
         if(is_main_control_screen() && ChartTimePriceToXY(0, 0, TimeCurrent(), (trend_ma10_d1 == TREND_BUY ? min_7w : max_7w), x_btn, y_btn))
           {
            string str_trade_by_ma10 = trend_ma10_d1 + " " + symbol + " 5%(" + (string)(int) risk_5p + "$) " + format_double_to_string(vol, 2) + " " + rr_d1;
            createButton(BtnTradeNow10D, str_trade_by_ma10, int(chart_width/2) - 125, (trend_ma10_d1 == TREND_BUY ? y_btn-25 : y_btn), 250, 20, trend_ma10_d1 == TREND_BUY ? clrBlue : clrFireBrick, clrWhite, 6);
           }

         string Trend_Reverse10D = get_trend_reverse(trend_ma10_d1);
         if(is_same_symbol(all_trend_wdh, Trend_Reverse10D))
           {
            double sl_reverse = Trend_Reverse10D == TREND_BUY ? min_7w - amp_h4: max_7w + amp_h4;
            double tp_reverse = Trend_Reverse10D == TREND_BUY ? max_21w: min_21w;

            double amp_sl_reverse  = Trend_Reverse10D == TREND_BUY ? MathAbs(Bid - sl_reverse) : MathAbs(sl_reverse - Ask);
            if(amp_sl_reverse < amp_d1)
              {
               amp_sl_reverse = amp_d1;
               sl_reverse = Trend_Reverse10D == TREND_BUY ? Bid - amp_sl_reverse: Ask + amp_sl_reverse;
              }

            double amp_tp_reverse  = Trend_Reverse10D == TREND_BUY ? (max_21w - Ask) : (Bid - min_21w);
            double vol_reverse = calc_volume_by_amp(symbol, amp_sl_reverse, risk_5p);

            string rr_reverse1 = "1:" + format_double_to_string(amp_tp_reverse/amp_sl_reverse, 1) + " ";
            string str_trade_by_Reverse10 = MASK_REV_D10 + " " + Trend_Reverse10D + " LIMIT " + symbol + " 5%(" + (string)(int) risk_5p + "$) " + format_double_to_string(vol_reverse, 2) + " " + rr_reverse1;

            if(is_main_control_screen() && ChartTimePriceToXY(0, 0, TimeCurrent(), (Trend_Reverse10D == TREND_BUY ? min_7w : max_7w), x_btn, y_btn))
               createButton(BtnTradeReverse10D, str_trade_by_Reverse10, int(chart_width/2) - 125, (Trend_Reverse10D == TREND_BUY ? y_btn-25 : y_btn), 250, 20, clrBlack, clrWhite, 6);
           }

         string strLblTP = "(Close) " + symbol + " $" + (total_profit>0?"+":"") + (string)(int) total_profit + " ";
         if(total_profit > 0 && total_profit > minProfit())
            if(is_main_control_screen() && ChartTimePriceToXY(0, 0, TimeCurrent(), tp, x_btn, y_btn))
               createButton(BtnTPCurSymbol, strLblTP, int(chart_width/2) - 75, y_btn-11, 150, 20,  clrBlue, clrWhite, 7);
        }

      // Send Message
      if(pass_count_cond_d10)
        {
         prefix_msg = symbol + " " + trend_ma10_d1 + " D(" + (string)count_d10 + ")";
         string msg = "";
         if(trend_ma10_d1 == temp_array_H4[0].trend_heiken && trend_ma10_d1 == temp_array_H1[0].trend_heiken)
           {
            if(temp_array_H4[0].count_ma10 <= 3)
               msg += " MaH4(" + (string)temp_array_H4[0].count_ma10 + ")";

            if(temp_array_H4[0].count_heiken <= 3)
               msg += " HeiH4(" + (string)temp_array_H4[0].count_heiken + ")";
           }

         if(msg != "")
            master_msg += prefix_msg + "\n" +  msg;
        }
     }

   if(master_msg != "")
      SendTelegramMessage("D10", "OPEN_TRADE", master_msg, false);
//------------------------------------------------------------------
   for(int index = 0; index < ArraySize(ARR_SYMBOLS); index++)
     {
      string symbol = ARR_SYMBOLS[index];
      ObjectDelete(0, BtnNoticeW1 + symbol);
      ObjectDelete(0, BtnNoticeD1 + symbol);
      ObjectDelete(0, BtnNoticeH4 + symbol);
      ObjectDelete(0, BtnNoticeH1 + symbol);
     }
//------------------------------------------------------------------
   int count_btn = 0;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_W); index++)
     {
      string strLable = arrNoticeSymbols_W[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : clrFireBrick;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : is_same_symbol(arrNoticeSymbols_W[index], "$") ? clrLightGray : clrWhite;
      int width = 300;

      createButton(BtnNoticeW1 + symbol, strLable, chart_width-width-6, 80+count_btn*25, width, 20, clrText, clrBg, 7);
      count_btn += 1;
     }
   count_btn += count_btn > 0 ? 1 : 0;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_D); index++)
     {
      string strLable = arrNoticeSymbols_D[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : clrFireBrick;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : clrWhite;
      int width = 300;
      createButton(BtnNoticeD1 + symbol, strLable, chart_width-width-6, 80+count_btn*25, width, 20, clrText, clrBg, 7);
      count_btn += 1;
     }
//------------------------------------------------------------------
   int count_h = 0;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_H4); index++)
     {
      string strLable = arrNoticeSymbols_H4[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : is_same_symbol(strLable, "$-") ? clrFireBrick : clrBlack;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : clrWhite;
      int width = 300;
      createButton(BtnNoticeH4 + symbol, strLable, 150, 50+count_h*25, width, 20, clrText, clrBg, 7);
      count_h += 1;
     }
   count_h += count_h > 0 ? 1 : 0;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_H1); index++)
     {
      string strLable = arrNoticeSymbols_H1[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : is_same_symbol(strLable, "$-") ? clrFireBrick : clrBlack;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : clrWhite;
      int width = 300;
      createButton(BtnNoticeH1 + symbol, strLable, 150, 50+count_h*25, width, 20, clrText, clrBg, 7);
      count_h += 1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Auto_SL_TP()
  {
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   double risk_5p = risk_1_Percent_Account_Balance()*5;
   double risk_10 = risk_10_Percent_Account_Balance();

   string arrLimitSymbols[];
   string str_opening_symbols = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         string symbol = OrderSymbol();
         string comment = OrderComment();
         double temp_profit = OrderProfit() + OrderSwap() + OrderCommission();

         bool is_05_percent_loss = (risk_5p + temp_profit < 0);
         bool is_10_percent_profit = (temp_profit > risk_10);

         if((OrderType() == OP_BUY) || (OrderType() == OP_SELL))
            str_opening_symbols += "_" + OrderSymbol();

         if((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT))
           {
            int num_symbols = ArraySize(arrLimitSymbols);
            ArrayResize(arrLimitSymbols, num_symbols+1);
            arrLimitSymbols[num_symbols] = OrderSymbol();
           }

         if(MathAbs(temp_profit) > risk_5p)
           {
            string msg = symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";

            CandleData tempHeiken_d1[];
            get_arr_heiken(symbol, PERIOD_D1, tempHeiken_d1, 15, true);

            CandleData tempHeiken_h4[];
            get_arr_heiken(symbol, PERIOD_H4, tempHeiken_h4, 15, true);

            if(is_05_percent_loss)
              {
               if((OrderType() == OP_BUY) &&
                  (tempHeiken_d1[0].trend_by_ma10 == TREND_SEL) &&
                  (tempHeiken_h4[1].trend_by_ma10 == TREND_SEL) &&
                  (tempHeiken_h4[0].trend_heiken == TREND_SEL))
                 {
                  if(ClosePositionByTicket(OrderTicket(), symbol))
                     SendTelegramMessage(symbol, "STOP_BUY_BY_MA10", "STOP_BUY_BY_MA10: " + msg, true);
                  return;
                 }

               if((OrderType() == OP_SELL) &&
                  (tempHeiken_d1[0].trend_by_ma10 == TREND_BUY) &&
                  (tempHeiken_h4[1].trend_by_ma10 == TREND_BUY) &&
                  (tempHeiken_h4[0].trend_heiken == TREND_BUY))
                 {
                  if(ClosePositionByTicket(OrderTicket(), symbol))
                     SendTelegramMessage(symbol, "STOP_SEL_BY_MA10", "STOP_SEL_BY_MA10: " + msg, true);
                  return;
                 }
              }

            if(is_05_percent_loss)
              {
               CandleData tempHeiken_h1[];
               get_arr_heiken(symbol, PERIOD_H1, tempHeiken_h1, 15, true);

               bool stop_buy_by_heiken = (tempHeiken_h4[0].trend_heiken == TREND_SEL && tempHeiken_h1[0].trend_heiken == TREND_SEL);
               bool stop_sel_by_heiken = (tempHeiken_h4[0].trend_heiken == TREND_BUY && tempHeiken_h1[0].trend_heiken == TREND_BUY);

               if((OrderType() == OP_BUY) && stop_buy_by_heiken)
                 {
                  if(ClosePositionByTicket(OrderTicket(), symbol))
                     SendTelegramMessage(symbol, "STOP_LOSS", (is_05_percent_loss ? "STOP_LOSS" : "TAKE_PROFIT") + msg, true);
                  return;
                 }

               if(OrderType() == OP_SELL && stop_sel_by_heiken)
                 {
                  if(ClosePositionByTicket(OrderTicket(), symbol))
                     SendTelegramMessage(symbol, "STOP_LOSS", (is_05_percent_loss ? "STOP_LOSS" : "TAKE_PROFIT") + msg, true);
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
                  while(demm<5)
                    {
                     double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
                     double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
                     price = (OrderType() == OP_BUY) ? ASK : (OrderType() == OP_SELL) ? BID : NormalizeDouble((ASK+BID/2), Digits);

                     if(OrderModify(OrderTicket(),price,OrderOpenPrice(), OrderTakeProfit(),0))
                        return;

                     demm++;
                     Sleep(500);
                    }
                 }
              }

           }
        }

//if(str_opening_symbols != "" || (str_opening_symbols == "" && OrdersTotal() > 0))
//   for(int index = 0; index < ArraySize(arrLimitSymbols); index++)
//     {
//      string symbol = arrLimitSymbols[index];
//      if(is_same_symbol(str_opening_symbols, symbol) == false)
//        {
//         if(ClosePosition(symbol, OP_BUYLIMIT, TREND_BUY))
//            printf("Close OP_BUYLIMIT: " + symbol);
//
//         if(ClosePosition(symbol, OP_SELLLIMIT, TREND_SEL))
//            printf("Close OP_SELLLIMIT: " + symbol);
//        }
//     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetGlobalVariable(string varName)
  {
   if(GlobalVariableCheck(varName))
      return GlobalVariableGet(varName);
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_stop_trade(string symbol, bool hasOpenOrder)
  {
   string result = "";

   if(GetGlobalVariable(BtnTpDay_06_07 + "_" + symbol) > 0)
      result += "_6_7_";
   if(GetGlobalVariable(BtnTpDay_13_14 + "_" + symbol) > 0)
      result += "_13_14_";
   if(GetGlobalVariable(BtnTpDay_20_21 + "_" + symbol) > 0)
      result += "_20_21_";
   if(GetGlobalVariable(BtnTpDay_27_28 + "_" + symbol) > 0)
      result += "_27_28_";
   if(GetGlobalVariable(BtnTpDay_34_35 + "_" + symbol) > 0)
      result += "_34_35_";

   if(result == "" && hasOpenOrder)
     {
      GlobalVariableSet(BtnTpDay_13_14 + "_" + symbol, 1);
      return "_13_14_";
     }

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitGlobalArrHeiken(string symbol)
  {
//trend_over_bs_by_stoc_w1 = get_trend_allow_trade_by_stoc(symbol, PERIOD_W1);
//trend_over_bs_by_stoc_d1 = get_trend_allow_trade_by_stoc(symbol, PERIOD_D1);
//trend_over_bs_by_stoc_h4 = get_trend_allow_trade_by_stoc(symbol, PERIOD_H4);
//trend_over_bs_by_stoc_h1 = get_trend_allow_trade_by_stoc(symbol, PERIOD_H1);
//trend_over_bs_by_stoc_15 = get_trend_allow_trade_by_stoc(symbol, PERIOD_M15);
//trend_over_bs_by_stoc_05 = get_trend_allow_trade_by_stoc(symbol, PERIOD_M5);
//trend_over_bs_by_stoc_01 = get_trend_allow_trade_by_stoc(symbol, PERIOD_M1);

   trend_by_seq102050_h4 = get_trend_by_seq102050(symbol, PERIOD_H4, 0);
   trend_by_seq102050_h1 = get_trend_by_seq102050(symbol, PERIOD_H1, 0);
   trend_by_seq102050_15 = "";//get_trend_by_ma10_20_50(symbol, PERIOD_M15);
   trend_by_seq102050_05 = "";//get_trend_by_ma10_20_50(symbol, PERIOD_M5);
   trend_by_seq102050_01 = "";//get_trend_by_ma10_20_50(symbol, PERIOD_M1);

   get_arr_heiken(symbol, PERIOD_W1, arrHeiken_w1);
   get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 35, true);
   get_arr_heiken(symbol, PERIOD_H4, arrHeiken_h4, 20, true);
   get_arr_heiken(symbol, PERIOD_H1, arrHeiken_h1, 20, true);
   get_arr_heiken(symbol, PERIOD_M5, arrHeiken_m5);
   get_arr_heiken(symbol, PERIOD_M1, arrHeiken_m1);

   trend_by_ma10_w1 = arrHeiken_w1[0].trend_by_ma10;
   trend_by_ma10_d1 = arrHeiken_d1[0].trend_by_ma10;
   trend_by_ma10_h4 = arrHeiken_h4[0].trend_by_ma10;
   trend_by_ma10_h1 = arrHeiken_h1[0].trend_by_ma10;

   trend_week_by_time = getTrendByLowHigTimes(symbol, iTime(symbol, PERIOD_W1, 0), TimeCurrent(), PERIOD_H4);
   trend_today_by_time = getTrendByLowHigTimes(symbol, iTime(symbol, PERIOD_D1, 0), TimeCurrent(), PERIOD_H1);

   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4,      trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4, trend_vector_histogram_h4, trend_vector_signal_h4, trend_macd_note_h4);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H1,      trend_by_macd_h1, trend_mac_vs_signal_h1, trend_mac_vs_zero_h1, trend_vector_histogram_h1, trend_vector_signal_h1, trend_macd_note_h1);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_CURRENT, trend_by_macd_cu, trend_mac_vs_signal_cu, trend_mac_vs_zero_cu, trend_vector_histogram_cu, trend_vector_signal_cu, trend_macd_note_cu);

   INIT_TREND_TODAY = trend_mac_vs_zero_h4;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_hedging(string symbol)
  {
   double global_bot_count_hedg_buy = 0;
   double global_bot_count_hedg_sel = 0;
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
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol, int OP_TYPE, double volume, double sl, double tp, string comment, double priceLimit=0)
  {
//StringToLower(symbol);

   printf("Open_Position symbol: " + symbol + " OP_TYPE:" + (string) OP_TYPE + " volume:"
          + (string) volume + " sl:" + (string) sl + " tp:" + (string) tp + " comment:" + (string) comment);

   ResetLastError();
   int nextticket= 0, demm = 1;
   while(nextticket<=0 && demm < 5)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int slippage = (int)MathAbs(ask-bid)*2;
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
      else
         printf("Open_Position Error:" + (string)GetLastError());
      demm++;
      Sleep(500); //milliseconds
     }

   return false;
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons_Trend(string symbol)
  {

   int x_max = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS)) - 70;
   int y_start = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 25;
   int y_row_m4 = y_start - 20*11 - 5*6;
   int y_row_m3 = y_start - 20*10 - 5*5;
   int y_row_m2 = y_start - 20*9  - 5*4;
   int y_row_m1 = y_start - 20*7 - 5*2;
   int y_row_0  = y_start - 20*6 - 5*1;
   int y_row_1  = y_start - 20*5 + 5*0;
   int y_row_2  = y_start - 20*4 + 5*1;
   int y_row_3  = y_start - 20*3 + 5*2;
   int y_row_4  = y_start - 20*2 + 5*3;
   int y_row_5  = y_start - 20*1 + 5*4;

   string lblStocW1 = getShortStoc(trend_over_bs_by_stoc_w1);
   string lblStocD1 = getShortStoc(trend_over_bs_by_stoc_d1);
   string lblStocH4 = getShortStoc(trend_over_bs_by_stoc_h4);
   string lblStocH1 = getShortStoc(trend_over_bs_by_stoc_h1);

   string Notice_Symbol = (string) GetGlobalVariable(SendTeleMsg_ + symbol);
   string key_d1_buy = (string)PERIOD_D1 + (string)OP_BUY;
   string key_d1_sel = (string)PERIOD_D1 + (string)OP_SELL;
   string key_h4_buy = (string)PERIOD_H4 + (string)OP_BUY;
   string key_h4_sel = (string)PERIOD_H4 + (string)OP_SELL;
   string key_h1_buy = (string)PERIOD_H1 + (string)OP_BUY;
   string key_h1_sel = (string)PERIOD_H1 + (string)OP_SELL;

   string lblMsgD1 = "(D1) Msg " + (is_same_symbol(Notice_Symbol, key_d1_buy) ? TREND_BUY : "") + (is_same_symbol(Notice_Symbol, key_d1_sel) ? TREND_SEL : "");
   if(is_same_symbol(lblMsgD1, TREND_BUY) && is_same_symbol(lblMsgD1, TREND_SEL))
      lblMsgD1 = "(D1) Msg";
   color bgColorD1 = is_same_symbol(Notice_Symbol, key_d1_buy) ? clrActiveBtn : is_same_symbol(Notice_Symbol, key_d1_sel) ? clrMistyRose : clrLightGray;

   string lblMsgH4 = "(H4) Msg " + (is_same_symbol(Notice_Symbol, key_h4_buy) ? TREND_BUY : "") + (is_same_symbol(Notice_Symbol, key_h4_sel) ? TREND_SEL : "");
   if(is_same_symbol(lblMsgH4, TREND_BUY) && is_same_symbol(lblMsgH4, TREND_SEL))
      lblMsgH4 = "(H4) Msg";
   color bgColorH4 = is_same_symbol(Notice_Symbol, key_h4_buy) ? clrActiveBtn : is_same_symbol(Notice_Symbol, key_h4_sel) ? clrMistyRose : clrLightGray;

   string lblMsgH1 = "(H1) Msg " + (is_same_symbol(Notice_Symbol, key_h1_buy) ? TREND_BUY : "") + (is_same_symbol(Notice_Symbol, key_h1_sel) ? TREND_SEL : "");
   if(is_same_symbol(lblMsgH1, TREND_BUY) && is_same_symbol(lblMsgH1, TREND_SEL))
      lblMsgH1 = "(H1) Msg";
   color bgColorH1 = is_same_symbol(Notice_Symbol, key_h1_buy) ? clrActiveBtn : is_same_symbol(Notice_Symbol, key_h1_sel) ? clrMistyRose : clrLightGray;

   int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS))/2 - 50 + 25*3;
   createButton(BtnSendNotice_D1, lblMsgD1, 10, chart_heigh+25*4, 95, 20, clrBlack, bgColorD1, 7);
   createButton(BtnSendNotice_H4, lblMsgH4, 10, chart_heigh+25*5, 95, 20, clrBlack, bgColorH4, 7);
   createButton(BtnSendNotice_H1, lblMsgH1, 10, chart_heigh+25*6, 95, 20, clrBlack, bgColorH1, 7);

   createButton("Seq.H4",     createLable("SeqH4", trend_by_seq102050_h4),         x_max - 65*1, y_row_m1, 63, 20, getColorByTrend(trend_by_seq102050_h4, clrBlack), clrWhite,     7);
   createButton("Seq.H1",     createLable("SeqH1", trend_by_seq102050_h1),         x_max - 65*0, y_row_m1, 63, 20, getColorByTrend(trend_by_seq102050_h1, clrBlack), clrWhite,     7);

   createButton("Ma10",     "Ma10", x_max - 65*4 + 18, y_row_0, 45, 20, clrBlack, clrWhite, 7);
   createButton("Ma10W1",   "W1 " + getShortName(arrHeiken_w1[0].trend_by_ma10) + ":" + (string)arrHeiken_w1[0].count_ma10,  x_max - 65*3, y_row_0, 63, 20, trend_by_ma10_w1 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
   createButton("Ma10D1",   "D "  + getShortName(arrHeiken_d1[0].trend_by_ma10) + ""  + (string)arrHeiken_d1[0].count_ma10,  x_max - 65*2, y_row_0, 63, 20, trend_by_ma10_d1 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 10);
   createButton("Ma10H4",   "H4 " + getShortName(arrHeiken_h4[0].trend_by_ma10) + ":" + (string)arrHeiken_h4[0].count_ma10,  x_max - 65*1, y_row_0, 63, 20, trend_by_ma10_h4 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
   createButton("Ma10H1",   "H1 " + getShortName(arrHeiken_h1[0].trend_by_ma10) + ":" + (string)arrHeiken_h1[0].count_ma10,  x_max - 65*0, y_row_0, 63, 20, trend_by_ma10_h1 == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);

   createButton("Heiken",     "Heiken", x_max - 65*4 + 18, y_row_1, 45, 20, clrBlack, clrWhite, 7);
   createButton("HeiW1[0]", "W1 " + getShortName(arrHeiken_w1[0].trend_heiken) + ":" + (string)arrHeiken_w1[0].count_heiken, x_max - 65*3, y_row_1, 63, 20, arrHeiken_w1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
   createButton("HeiD1[0]", "D1 " + getShortName(arrHeiken_d1[0].trend_heiken) + ":" + (string)arrHeiken_d1[0].count_heiken, x_max - 65*2, y_row_1, 63, 20, arrHeiken_d1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
   createButton("HeiH4[0]", "H4 " + getShortName(arrHeiken_h4[0].trend_heiken) + ":" + (string)arrHeiken_h4[0].count_heiken, x_max - 65*1, y_row_1, 63, 20, arrHeiken_h4[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);
   createButton("HeiH1[0]", "H1 " + getShortName(arrHeiken_h1[0].trend_heiken) + ":" + (string)arrHeiken_h1[0].count_heiken, x_max - 65*0, y_row_1, 63, 20, arrHeiken_h1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrAliceBlue, 7);

   createButton("MacdH4",     "Macd", x_max - 65*4 + 18, y_row_2, 45, 20, clrBlack, clrWhite, 7);
   createButton("Mac.Zer.H4", createLable("ZeoH4", trend_mac_vs_zero_h4),          x_max - 65*3, y_row_2, 63, 20, getColorByTrend(trend_mac_vs_zero_h4,    clrBlack), clrGainsboro, 7);
   createButton("Mac.Sig.H4", createLable("MacH4", trend_mac_vs_signal_h4),        x_max - 65*2, y_row_2, 63, 20, getColorByTrend(trend_mac_vs_signal_h4,  clrBlack), clrGainsboro, 7);
   createButton("Vec.Mac.H4", createLable("HisH4", trend_vector_histogram_h4),     x_max - 65*1, y_row_2, 63, 20, getColorByTrend(trend_vector_histogram_h4,    clrBlack), clrGainsboro, 7);
   createButton("Vec.Sig.H4", createLable("SigH4", trend_vector_signal_h4),        x_max - 65*0, y_row_2, 63, 20, getColorByTrend(trend_vector_signal_h4,  clrBlack), clrGainsboro, 7);

   createButton("MacdH1",     "Macd", x_max - 65*4 + 18, y_row_3, 45, 20, clrBlack, clrWhite, 7);
   createButton("Mac.Zer.H1", createLable("ZeoH1", trend_mac_vs_zero_h1),          x_max - 65*3, y_row_3, 63, 20, getColorByTrend(trend_mac_vs_zero_h1,    clrBlack), clrGainsboro, 7);
   createButton("Mac.Sig.H1", createLable("MacH1", trend_mac_vs_signal_h1),        x_max - 65*2, y_row_3, 63, 20, getColorByTrend(trend_mac_vs_signal_h1,  clrBlack), clrGainsboro, 7);
   createButton("Vec.Mac.H1", createLable("HisH1", trend_vector_histogram_h1),     x_max - 65*1, y_row_3, 63, 20, getColorByTrend(trend_vector_histogram_h1,    clrBlack), clrGainsboro, 7);
   createButton("Vec.Sig.H1", createLable("SigH1", trend_vector_signal_h1),        x_max - 65*0, y_row_3, 63, 20, getColorByTrend(trend_vector_signal_h1,  clrBlack), clrGainsboro, 7);

   if(Period() != PERIOD_H4 && Period() != PERIOD_H1)
     {
      string tf = get_current_timeframe();
      createButton("MacdCu",     "Macd", x_max - 65*4 + 18, y_row_4, 45, 20, clrBlack, clrWhite, 7);
      createButton("Mac.Zer.CU", createLable("Zero" + tf, trend_mac_vs_zero_cu),       x_max - 65*3, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_zero_cu,   clrBlack), clrGainsboro, 7);
      createButton("Mac.Sig.CU", createLable("Mac." + tf, trend_mac_vs_signal_cu),     x_max - 65*2, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_signal_cu,  clrBlack), clrGainsboro, 7);
      createButton("Vec.Mac.CU", createLable("His." + tf, trend_vector_histogram_cu),  x_max - 65*1, y_row_4, 63, 20, getColorByTrend(trend_vector_histogram_cu,    clrBlack), clrGainsboro, 7);
      createButton("Vec.Sig.CU", createLable("Sig." + tf, trend_vector_signal_cu),     x_max - 65*0, y_row_4, 63, 20, getColorByTrend(trend_vector_signal_cu,  clrBlack), clrGainsboro, 7);
     }
   else
     {
      ObjectDelete(0, "MacdCu");
      ObjectDelete(0, "Mac.Zer.CU");
      ObjectDelete(0, "Mac.Sig.CU");
      ObjectDelete(0, "Vec.Mac.CU");
      ObjectDelete(0, "Vec.Sig.CU");
     }

   createButton("Stoc",  "Stoc",                        x_max - 65*4 + 18, y_row_5, 45, 20, clrBlack, clrWhite, 7);
   createButton("TocW1", createLable2("W1", lblStocW1), x_max - 65*3, y_row_5, 63, 20, is_same_symbol(lblStocW1, "20") ? clrBlue: is_same_symbol(lblStocW1, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
   createButton("TocD1", createLable2("D1", lblStocD1), x_max - 65*2, y_row_5, 63, 20, is_same_symbol(lblStocD1, "20") ? clrBlue: is_same_symbol(lblStocD1, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
   createButton("TocH4", createLable2("H4", lblStocH4), x_max - 65*1, y_row_5, 63, 20, is_same_symbol(lblStocH4, "20") ? clrBlue: is_same_symbol(lblStocH4, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
   createButton("TocH1", createLable2("H1", lblStocH1), x_max - 65*0, y_row_5, 63, 20, is_same_symbol(lblStocH1, "20") ? clrBlue: is_same_symbol(lblStocH1, "80") ? clrRed : clrBlack, clrAliceBlue, 7);
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
   ObjectDelete(0, "hei_w_" + append1Zero(0));

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


      create_filled_rectangle(candle_name, time_i2, low, time_i1, hig, clrColor, false);
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

  }//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_time_zones(string symbol, string &date_fr, string &date_to)
  {
   date_fr = "2023.12.31"; //GetFirstWeekOfCurrentMonth();
   date_to = AddWeeksToDate(date_fr, 13);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AddWeeksToDate(string date_fr, int weeks)
  {
// Chuyển đổi chuỗi ngày thành kiểu datetime
   datetime date_value = StringToTime(date_fr);

// Lấy thời gian hiện tại
   datetime current_time = TimeCurrent();

// Tính toán số giây trong một tuần
   int seconds_in_week = 7 * 24 * 3600; // 1 tuần có 7 ngày, mỗi ngày có 24 giờ, mỗi giờ có 3600 giây

   datetime new_date_value = date_value;

// Thêm tuần từng tuần một và kiểm tra nếu ngày mới lớn hơn ngày hiện tại
   for(int i = 0; i < weeks; i++)
     {
      new_date_value += seconds_in_week;
      if(new_date_value > current_time)
        {
         new_date_value -= seconds_in_week; // Bỏ tuần cuối cùng nếu nó vượt quá ngày hiện tại
         break;
        }
     }

// Chuyển đổi datetime mới thành chuỗi ngày
   string date_to = TimeToString(new_date_value, TIME_DATE);

   return date_to;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateWeeksBetweenDates(string date_fr, string date_to)
  {
// Chuyển đổi chuỗi ngày thành kiểu datetime
   datetime datetime_fr = StringToTime(date_fr);
   datetime datetime_to = StringToTime(date_to);

// Tính toán chênh lệch thời gian giữa hai ngày dưới dạng số giây
   int seconds_difference = (int)(datetime_to - datetime_fr);

// Tính toán số giây trong một tuần
   int seconds_in_week = 7 * 24 * 3600; // 1 tuần có 7 ngày, mỗi ngày có 24 giờ, mỗi giờ có 3600 giây

// Tính toán số tuần
   int weeks_difference = (int)(seconds_difference / seconds_in_week);

   return weeks_difference;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_TimeZones(string symbol, string date_form, string date_to, int levels = 20)
  {
   string name = "FiboTimeZones_" + symbol;
   ObjectDelete(name);

   ObjectCreate(0, name, OBJ_FIBOTIMES, 0, StringToTime(date_form), 0, StringToTime(date_to), 0);

   ObjectSetInteger(0,name,OBJPROP_LEVELS,levels);
   for(int i = 0; i < levels; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,i);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrBlack);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i, i == 0 ? "0" : "");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReplaceStringAfter(string str_input, string match_string, string replacement)
  {
// Tìm vị trí của ký tự "$"
   int pos = StringFind(str_input, match_string);

// Nếu không tìm thấy ký tự "$", trả về chuỗi gốc
   if(pos == -1)
      return str_input;

// Tách phần trước và phần sau của ký tự "$"
   string beforeDollar = StringSubstr(str_input, 0, pos + 1);

// Kết hợp phần trước và phần thay thế
   string newString = beforeDollar + replacement;

   return newString;
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
void Draw_CurPrice_Line()
  {
   string symbol = Symbol();
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   create_trend_line("cur_price", TimeCurrent()-TIME_OF_ONE_W1_CANDLE, cur_price, TimeCurrent()+TIME_OF_ONE_W1_CANDLE, cur_price, clrBlue, STYLE_DOT, 1, true, true);
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenChartWindow(string buttonLabel, ENUM_TIMEFRAMES TIMEFRAME = PERIOD_W1)
  {
   for(int index = 0; index < ArraySize(ARR_SYMBOLS); index++)
     {
      string cur_symbol = ARR_SYMBOLS[index];

      if(is_same_symbol(buttonLabel, cur_symbol))
        {
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
   if(is_same_symbol(sparam, BtnD10) || is_same_symbol(sparam, BtnNoticeW1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel);
     }

   if(is_same_symbol(sparam, BtnD10) || is_same_symbol(sparam, BtnNoticeD1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel, PERIOD_D1);
     }

   if(is_same_symbol(sparam, BtnNoticeH4))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel, PERIOD_H4);
     }

   if(is_same_symbol(sparam, BtnNoticeH1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel, PERIOD_H1);
     }

   if(is_same_symbol(sparam, BtnSendNotice_D1) ||
      is_same_symbol(sparam, BtnSendNotice_H4) ||
      is_same_symbol(sparam, BtnSendNotice_H1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);

      if(is_same_symbol(buttonLabel, TREND_BUY) == false && is_same_symbol(buttonLabel, TREND_SEL) == false)
         buttonLabel += TREND_BUY;
      else
         if(is_same_symbol(buttonLabel, TREND_BUY))
            StringReplace(buttonLabel, TREND_BUY, TREND_SEL);
         else
            if(is_same_symbol(buttonLabel, TREND_SEL))
               StringReplace(buttonLabel, TREND_SEL, "");

      ObjectSetString(0, sparam, OBJPROP_TEXT, buttonLabel);

      saveAutoTrade();

      Draw_Buttons_Trend(symbol);
     }

   if(is_same_symbol(sparam, BtnTPCurSymbol))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, symbol) == false)
         return;

      string msg = buttonLabel + "?\n";
      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         ClosePositivePosition(symbol, "");
         Draw_Notice_Ma10D();
        }
     }
//----------------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnTradeH1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, Symbol()) == false)
         return;

      string find_trend = is_same_symbol(buttonLabel, TREND_BUY) ? TREND_BUY : is_same_symbol(buttonLabel, TREND_SEL) ? TREND_SEL : "";
      if(find_trend == "")
         return;

      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

      CandleData temp_array_H1[];
      get_arr_heiken(symbol, PERIOD_H1, temp_array_H1, 21, true);

      double min_21h = 0;
      double max_21w = 0;
      int size = ArraySize(temp_array_H1);
      for(int i = 0; i < size; i++)
        {
         if(i==0 || min_21h > temp_array_H1[i].low)
            min_21h = temp_array_H1[i].low;

         if(i==0 || max_21w < temp_array_H1[i].high)
            max_21w = temp_array_H1[i].high;
        }

      double sl_buy = min_21h - amp_h4;
      double sl_sel = max_21w + amp_h4;

      double amp_sl = is_same_symbol(buttonLabel, TREND_BUY) ? (Bid - sl_buy) : (sl_sel - Ask);
      if(amp_sl < amp_h4)
        {
         amp_sl = amp_h4;
         sl_buy = Bid - amp_sl;
         sl_sel = Ask + amp_sl;
        }

      double risk_1p = risk_1_Percent_Account_Balance();
      double volume_1p = calc_volume_by_amp(symbol, amp_sl, risk_1p);
      double SL = find_trend == TREND_BUY ? sl_buy : find_trend == TREND_SEL ? sl_sel : 0;
      double TP = find_trend == TREND_BUY ? Ask + amp_d1 : find_trend == TREND_SEL ? Bid - amp_d1 : 0;
      int OP_TYPE = find_trend == TREND_BUY ? OP_BUY : find_trend == TREND_SEL ? OP_SELL : -1;

     }
//----------------------------------------------------------------------------------------------------------------
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

      CandleData temp_array_W1[];
      get_arr_heiken(symbol, PERIOD_W1, temp_array_W1, 21, true);

      double min_7w = 0;
      double max_7w = 0;
      for(int i = 0; i < 7; i++)
        {
         if(i==0 || min_7w > temp_array_W1[i].low)
            min_7w = temp_array_W1[i].low;

         if(i==0 || max_7w < temp_array_W1[i].high)
            max_7w = temp_array_W1[i].high;
        }
      double sl_buy = min_7w - amp_h4;
      double sl_sel = max_7w + amp_h4;

      double min_21w = 0;
      double max_21w = 0;
      int size_w1 = ArraySize(temp_array_W1);
      for(int i = 0; i < size_w1; i++)
        {
         if(i==0 || min_21w > temp_array_W1[i].low)
            min_21w = temp_array_W1[i].low;

         if(i==0 || max_21w < temp_array_W1[i].high)
            max_21w = temp_array_W1[i].high;
        }

      string trend_ma10_d1 = temp_array_D1[0].trend_by_ma10;
      double amp_sl =  trend_ma10_d1 == TREND_BUY ? (Bid - sl_buy) : (sl_sel - Ask);
      if(amp_sl < amp_w1)
        {
         amp_sl = amp_w1;
         sl_buy = Bid - amp_sl;
         sl_sel = Ask + amp_sl;
        }

      double risk_5p = risk_5p_Percent_Account_Equity();
      double vol_5percent = calc_volume_by_amp(symbol, amp_sl, risk_5p);
      double vol_limit = NormalizeDouble(vol_5percent, 2);
      double vol_market = NormalizeDouble(vol_5percent, 2);

      string strLable = trend_ma10_d1 + " " + symbol + " Vol 5% = " + format_double_to_string(vol_5percent, 2) + " lot ("+(string)(int)risk_5p+")";

      double sl = trend_ma10_d1 == TREND_BUY ? sl_buy : sl_sel;
      double sl_limit = trend_ma10_d1 == TREND_BUY ? min_7w - amp_sl : max_7w + amp_sl;

      double tp = trend_ma10_d1 == TREND_BUY ? max_21w : min_21w;

      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), symbol))
               count += 1;

      string comment_market = MASK_D10 + create_comment(create_trader_name(), trend_ma10_d1, count+1);
      string comment_limit = MASK_LIMIT + create_comment(create_trader_name(), trend_ma10_d1, count+1);
      int OP_TYPE = trend_ma10_d1 == TREND_BUY ? OP_BUY : trend_ma10_d1 == TREND_SEL ? OP_SELL : -1;
      int OP_LIMIT = trend_ma10_d1 == TREND_BUY ? OP_BUYLIMIT : trend_ma10_d1 == TREND_SEL ? OP_SELLLIMIT : -1;
      double price_limit = trend_ma10_d1 == TREND_BUY ? min_7w : trend_ma10_d1 == TREND_SEL ? max_7w : 0;

      string msg = strLable + "?\n";
      msg += "(YES) " + comment_market + "    " + format_double_to_string(vol_market, 2) + " lot. Market " "\n";
      msg += "(NO)  " + comment_limit + "   " + format_double_to_string(vol_limit, 2) + " lot. Limit " + "\n";

      //tp = 0.0;
      sl = 0.0;
      sl_limit = 0.0;

      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
         if(OP_TYPE != -1 && trend_ma10_d1 != "" && price_limit > 0)
           {
            bool market_ok = Open_Position(Symbol(), OP_TYPE, vol_market, NormalizeDouble(sl, Digits), NormalizeDouble(tp, Digits), comment_market);
            if(market_ok)
               GlobalVariableSet(BtnTpDay_20_21 + "_" + symbol, 1);
            Draw_Notice_Ma10D();
           }

      if(result == IDNO)
         if(OP_TYPE != -1 && trend_ma10_d1 != "" && price_limit > 0)
           {
            bool limit_ok = Open_Position(Symbol(), OP_LIMIT, vol_limit, NormalizeDouble(sl_limit, Digits), NormalizeDouble(0.0, Digits), comment_limit, NormalizeDouble(price_limit, Digits));
            if(limit_ok)
              {
              }
           }
     }
//-------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnTradeReverse10D))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, Symbol()) == false)
         return;

      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

      CandleData temp_array_D1[];
      get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 21, true);

      CandleData temp_array_W1[];
      get_arr_heiken(symbol, PERIOD_W1, temp_array_W1, 21, true);

      double min_7w = 0;
      double max_7w = 0;
      for(int i = 0; i < 7; i++)
        {
         if(i==0 || min_7w > temp_array_W1[i].low)
            min_7w = temp_array_W1[i].low;

         if(i==0 || max_7w < temp_array_W1[i].high)
            max_7w = temp_array_W1[i].high;
        }
      double sl_buy = min_7w - amp_h4;
      double sl_sel = max_7w + amp_h4;

      double min_21w = 0;
      double max_21w = 0;
      int size_w1 = ArraySize(temp_array_W1);
      for(int i = 0; i < size_w1; i++)
        {
         if(i==0 || min_21w > temp_array_W1[i].low)
            min_21w = temp_array_W1[i].low;

         if(i==0 || max_21w < temp_array_W1[i].high)
            max_21w = temp_array_W1[i].high;
        }

      string Trend_Reverse10D = get_trend_reverse(temp_array_D1[0].trend_by_ma10);
      double amp_sl =  Trend_Reverse10D == TREND_BUY ? (Bid - sl_buy) : (sl_sel - Ask);
      if(amp_sl < amp_w1)
        {
         amp_sl = amp_w1;
         sl_buy = Bid - amp_sl;
         sl_sel = Ask + amp_sl;
        }

      double risk_5p = risk_5p_Percent_Account_Equity();
      double vol_5percent = calc_volume_by_amp(symbol, amp_sl, risk_5p);
      double vol_limit = NormalizeDouble(vol_5percent, 2);
      double vol_market = NormalizeDouble(vol_5percent/2, 2);

      string strLable = Trend_Reverse10D + " " + symbol + " Vol 5% = " + format_double_to_string(vol_5percent, 2) + " lot ("+(string)(int)risk_5p+")";

      double sl = Trend_Reverse10D == TREND_BUY ? sl_buy : sl_sel;
      double sl_limit = Trend_Reverse10D == TREND_BUY ? min_7w - amp_sl : max_7w + amp_sl;

      double tp = Trend_Reverse10D == TREND_BUY ? max_21w : min_21w;

      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), symbol))
               count += 1;

      string comment_limit = MASK_LIMIT + create_comment(create_trader_name(), Trend_Reverse10D, count+1);
      string comment_market = MASK_REV_D10 + create_comment(create_trader_name(), Trend_Reverse10D, count+1);

      string msg = strLable + "?\n";
      msg += "Yes: " + comment_limit + "   " + format_double_to_string(vol_limit, 2) + " lot (LIMIT 5%)\n";
      msg += "No : " + comment_market + "    " + format_double_to_string(vol_market, 2) + " lot (MARKET 2.5%)\n\n";

      int OP_TYPE = Trend_Reverse10D == TREND_BUY ? OP_BUY : Trend_Reverse10D == TREND_SEL ? OP_SELL : -1;
      int OP_LIMIT = Trend_Reverse10D == TREND_BUY ? OP_BUYLIMIT : Trend_Reverse10D == TREND_SEL ? OP_SELLLIMIT : -1;
      double price_limit = Trend_Reverse10D == TREND_BUY ? min_7w : Trend_Reverse10D == TREND_SEL ? max_7w : 0;

      //tp = 0.0;
      sl = 0.0;
      sl_limit = 0.0;

      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         if(OP_TYPE != -1 && Trend_Reverse10D != "" && price_limit > 0)
           {
            bool limit_ok = Open_Position(Symbol(), OP_LIMIT, vol_limit, NormalizeDouble(sl_limit, Digits), NormalizeDouble(0.0, Digits), comment_limit, NormalizeDouble(price_limit, Digits));
            if(limit_ok)
              {
               Alert(MASK_D10 + Symbol() + " " + comment_limit);
               Draw_Notice_Ma10D();
              }
           }
        }

      if(result == IDNO)
        {
         if(OP_TYPE != -1 && Trend_Reverse10D != "" && price_limit > 0)
           {
            bool market_ok = Open_Position(Symbol(), OP_TYPE, vol_market, NormalizeDouble(sl_limit, Digits), NormalizeDouble(tp, Digits), comment_market);
            if(market_ok)
              {
               Alert(MASK_D10 + Symbol() + " " + comment_limit + "    " + comment_market);
               Draw_Notice_Ma10D();
              }
           }
        }
     }

   if(is_same_symbol(sparam, BtnTpDay_06_07) || is_same_symbol(sparam, BtnTpDay_13_14) ||
      is_same_symbol(sparam, BtnTpDay_20_21) ||
      is_same_symbol(sparam, BtnTpDay_27_28) || is_same_symbol(sparam, BtnTpDay_34_35))
     {
      string key = sparam + "_" + Symbol();
      if(GetGlobalVariable(key) > 0)
         GlobalVariableSet(key, -1);
      else
         GlobalVariableSet(key, 1);

      Draw_Notice_Ma10D();
     }

   if(is_same_symbol(sparam, BtnTelegramMessage))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      OpenChartWindow(buttonLabel);
     }
//-------------------------------------------------------------------------------------------------------
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
      double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

      //-----------------------------------------------------------------------

      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();
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
                     Sleep(500);
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
                           Sleep(500);
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
               Sleep(500);
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
               Sleep(500);
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
//                           Sleep(500);
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
//                        Sleep(500);
//                       }
//                    }
//     } //for
//  }
bool ClosePositionByTicket(int ticket_number, string symbol)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderTicket() == ticket_number)
           {
            int demm = 1;
            while(demm<5)
              {
               double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
               double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
               int slippage = (int)MathAbs(ask-bid);

               if((OrderType() == OP_BUY))
                 {
                  bool successful=OrderClose(ticket_number, OrderLots(), bid, slippage, clrViolet);
                  if(successful)
                     return true;
                 }

               if((OrderType() == OP_SELL))
                 {
                  bool successful=OrderClose(ticket_number, OrderLots(), ask, slippage, clrViolet);
                  if(successful)
                     return true;
                 }

               if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                 {
                  bool successful=OrderDelete(ticket_number);
                  if(successful)
                     return true;
                 }

               demm++;
               Sleep(500);
              }
           }
     } //for

   return false;
  }
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
               while(demm<5)
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
                  Sleep(500);
                 }
              }
     } //for

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePositivePosition(string symbol, string TRADING_TREND)
  {
   bool result = false;
   double min_profit = minProfit();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderProfit() > min_profit))
            if((TRADING_TREND == "") || (OrderComment() == "") || is_same_symbol(OrderComment(), TRADING_TREND))
              {
               int demm = 1;
               while(demm<5)
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if(OrderType() == OP_BUY)
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                     if(successful)
                       {
                        result = true;
                        break;
                       }
                    }

                  if(OrderType() == OP_SELL)
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                     if(successful)
                       {
                        result = true;
                        break;
                       }
                    }

                  demm++;
                  Sleep(500);
                 }
              }
     } //for

   return result;
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

   int y_start = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 22;
   string no_new_line_msg = get_vnhour() + " " + message;
   StringReplace(no_new_line_msg, "\n", "");
   createButton(BtnTelegramMessage, no_new_line_msg, 2, y_start, 450, 20, clrLightYellow, clrLightYellow);
   int sub_windows = 0;
   datetime y_time;
   double y_price;
   if(ChartXYToTimePrice(0, 5, y_start+10, sub_windows, y_time, y_price))
      create_lable("Telegram.Message", y_time, y_price, no_new_line_msg, "");
   printf(no_new_line_msg);

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

   string new_message = AccountInfoString(ACCOUNT_NAME) + get_vntime() + message + str_cur_price;

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

   OpenChartWindow(symbol);
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
   string symbol = Symbol();
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_BUY", IS_CONTINUE_TRADING_CYCLE_BUY);
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_SEL", IS_CONTINUE_TRADING_CYCLE_SEL);

   string content = (string) iTime(symbol, PERIOD_D1, 0) + "~";
   content += "AUTO_BUY:" + (string) IS_CONTINUE_TRADING_CYCLE_BUY + "~";
   content += "AUTO_SEL:" + (string) IS_CONTINUE_TRADING_CYCLE_SEL + "~";
   content += "WAIT_BUY_10:" + (string) IS_WAITTING_10PER_BUY + "~";
   content += "WAIT_SEL_10:" + (string) IS_WAITTING_10PER_SEL + "~";

   WriteFileContent(FILE_NAME_AUTO_TRADE, content);

   string buttonLabelD1 = ObjectGetString(0, BtnSendNotice_D1, OBJPROP_TEXT);
   string buttonLabelH4 = ObjectGetString(0, BtnSendNotice_H4, OBJPROP_TEXT);
   string buttonLabelH1 = ObjectGetString(0, BtnSendNotice_H1, OBJPROP_TEXT);

   string Notice_Symbol = "";

   string key_d1_buy = (string)PERIOD_D1 + (string)OP_BUY;
   string key_d1_sel = (string)PERIOD_D1 + (string)OP_SELL;
   if(is_same_symbol(buttonLabelD1, TREND_BUY))
      Notice_Symbol += key_d1_buy;
   if(is_same_symbol(buttonLabelD1, TREND_SEL))
      Notice_Symbol += key_d1_sel;

   string key_h4_buy = (string)PERIOD_H4 + (string)OP_BUY;
   string key_h4_sel = (string)PERIOD_H4 + (string)OP_SELL;
   if(is_same_symbol(buttonLabelH4, TREND_BUY))
      Notice_Symbol += key_h4_buy;
   if(is_same_symbol(buttonLabelH4, TREND_SEL))
      Notice_Symbol += key_h4_sel;

   string key_h1_buy = (string)PERIOD_H1 + (string)OP_BUY;
   string key_h1_sel = (string)PERIOD_H1 + (string)OP_SELL;
   if(is_same_symbol(buttonLabelH1, TREND_BUY))
      Notice_Symbol += key_h1_buy;
   if(is_same_symbol(buttonLabelH1, TREND_SEL))
      Notice_Symbol += key_h1_sel;

   if(Notice_Symbol == "")
      Notice_Symbol = "-1";

   GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);
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
      , string &trend_vector_histogram, string &trend_vector_signal, string &trend_macd_note)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";
   trend_vector_histogram = "";
   trend_vector_signal = "";
   trend_macd_note = "";

   double macd_0=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_MAIN,  0);
   double sign_0=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_SIGNAL,0);

   double macd_1=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_MAIN,  1);
   double sign_1=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_SIGNAL,1);

   double macd_2=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_MAIN,  2);
   double sign_2=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_SIGNAL,2);

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

   if(macd_0 > macd_1)
      trend_vector_histogram = TREND_BUY;
   if(macd_0 >= macd_1 && macd_2 > macd_1)
      trend_macd_note += SWITCH_TREND_BY_HISTOGRAM + TREND_BUY;


   if(macd_0 < macd_1)
      trend_vector_histogram = TREND_SEL;
   if(macd_2 < macd_1)
      trend_macd_note += SWITCH_TREND_BY_HISTOGRAM + TREND_SEL;


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
   double macd_1=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_2=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_MAIN,2);

   double sign_1=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double sign_2=iMACD(symbol, timeframe,18,36,9,PRICE_CLOSE,MODE_SIGNAL,2);

   if(macd_1 > 0 && 0 > macd_2 && macd_1 > sign_1 && sign_1 > sign_2)
      return TREND_BUY;

   if(macd_1 < 0 && 0 < macd_2 && macd_1 < sign_1 && sign_1 < sign_2)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_order_opened_today(string symbol)
  {
// Lấy thời gian hiện tại
   datetime current_time = TimeCurrent();

// Lấy thời gian bắt đầu của ngày hôm nay
   datetime start_of_today = StringToTime(TimeToString(current_time, TIME_DATE));

// Duyệt qua tất cả các lệnh trong lịch sử và đang hoạt động
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(is_same_symbol(OrderSymbol(), symbol))
            // Kiểm tra nếu lệnh được mở từ thời gian bắt đầu của ngày hôm nay trở đi
            if(OrderOpenTime() >= start_of_today)
               return true;
     }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         // Kiểm tra nếu lệnh được mở từ thời gian bắt đầu của ngày hôm nay trở đi
         if(OrderOpenTime() >= start_of_today)
            return true;
        }
     }

// Nếu không có lệnh nào được mở trong ngày hôm nay
   return false;
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
string get_trend_allow_trade_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
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
string get_vnhour()
  {
   string cpu = "";
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime, TIME_MINUTES);
   string vntime = "(" + str_date_time + ")";
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
      time_from = time_to - TIME_OF_ONE_W1_CANDLE * 350;
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
string get_trend_by_seq102050(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int candle_index)
  {
   int count = 0;
   int maLength = 55+candle_index;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }
   double ma10_0 = cal_MA(closePrices, 10, candle_index + 0);
   double ma10_1 = cal_MA(closePrices, 10, candle_index + 1);

   double ma20_0 = cal_MA(closePrices, 20, candle_index + 0);
   double ma20_1 = cal_MA(closePrices, 20, candle_index + 1);

   double ma50_0 = cal_MA(closePrices, 50, candle_index + 0);
   double ma50_1 = cal_MA(closePrices, 50, candle_index + 1);

   if((ma10_0 > ma10_1) && (ma20_0 > ma20_1 || ma50_0 > ma50_1) && (ma10_0 > ma20_0) && (ma20_0 > ma50_0))
      return TREND_BUY;

   if((ma10_0 < ma10_1) && (ma20_0 < ma20_1 || ma50_0 < ma50_1) && (ma10_0 < ma20_0) && (ma20_0 < ma50_0))
      return TREND_SEL;

   return "";
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
   trend_ma02050 = (ma20[0] > ma50_0) ? TREND_BUY : TREND_SEL;

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
   datetime time_to=TimeCurrent() + TIME_OF_ONE_H4_CANDLE;                   // anchor point time
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
//|                                                                  |
//+------------------------------------------------------------------+
void createChannel(string name, datetime time1, double price1, datetime time2, double price2, datetime time3, double price3)
  {
// Xóa kênh nếu đã tồn tại
   ObjectDelete(0, name);

// Tạo kênh mới
   ObjectCreate(0, name, OBJ_CHANNEL, 0, time1, price1, time2, price2, time3, price3);

// Đặt các thuộc tính cho kênh
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);             // Màu của kênh
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);                  // Độ dày của kênh
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);        // Kiểu đường nét của kênh
   ObjectSetInteger(0, name, OBJPROP_RAY, false);                // Không mở rộng đường kênh
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);          // Cho phép chọn kênh
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);             // Không ẩn kênh
   ObjectSetInteger(0, name, OBJPROP_BACK, false);               // Vẽ kênh phía trước các đối tượng khác
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getGannGridProperties(string symbol, string &time1, string &time2, double &price1, double &scale)
  {
   time1 = "2020.04.05";
   time2 = "2020.10.04";
   if(is_same_symbol("AUDJPY", symbol))
     {
      price1 = 56.780251;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("NZDJPY", symbol))
     {
      price1 = 57.136103;
      scale = 120.00;
      return;
     }
   if(is_same_symbol("EURJPY", symbol))
     {
      price1 = 109.326526;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("GBPJPY", symbol))
     {
      price1 = 119.382734;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("USDJPY", symbol))
     {
      price1 = 104.781215;
      scale = 250.00;
      return;
     }
   if(is_same_symbol("AUDUSD", symbol))
     {
      price1 = 0.539664;
      scale = 100.00;
      return;
     }
   if(is_same_symbol("AUDNZD", symbol))
     {
      price1 = 0.999311;
      scale = 60;
      return;
     }
   if(is_same_symbol("EURNZD", symbol))
     {
      price1 = 1.5475;
      scale = 140;
      return;
     }
   if(is_same_symbol("GBPNZD", symbol))
     {
      price1 = 1.801365;
      scale = 120.00;
      return;
     }
   if(is_same_symbol("NZDUSD", symbol))
     {
      price1 = 0.541205;
      scale = 70;
      return;
     }
   if(is_same_symbol("EURAUD", symbol))
     {
      price1 = 1.393284;
      scale = 200;
      return;
     }
   if(is_same_symbol("AUDCHF", symbol))
     {
      price1 = 0.527752;
      scale = 90.00;
      return;
     }
   if(is_same_symbol("EURCHF", symbol))
     {
      price1 = 0.905838;
      scale = 150;
      return;
     }
   if(is_same_symbol("GBPCHF", symbol))
     {
      price1 = 1.022527;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("USDCHF", symbol))
     {
      price1 = 0.820282;
      scale = 100;
      return;
     }
   if(is_same_symbol("EURGBP", symbol))
     {
      price1 = 0.828975;
      scale = 60;
      return;
     }
   if(is_same_symbol("EURUSD", symbol))
     {
      price1 = 0.946562;
      scale = 100;
      return;
     }
   if(is_same_symbol("GBPUSD", symbol))
     {
      price1 = 1.008458;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("EURCAD", symbol))
     {
      price1 = 1.268354;
      scale = 120;
      return;
     }
   if(is_same_symbol("USDCAD", symbol))
     {
      price1 = 1.196023;
      scale = 100.00;
      return;
     }
   if(is_same_symbol("XAUUSD", symbol))
     {
      price1 = 1094.10099;
      scale = 2931.52;
      return;
     }
   if(is_same_symbol("USOIL", symbol))
     {
      price1 = 7.418861;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("BTCUSD", symbol))
     {
      price1 = 3635.108768;
      scale = 18992.5;
      return;
     }
   if(is_same_symbol("US30", symbol))
     {
      price1 = 18271.067371;
      scale = 800.00;
      return;
     }
   if(is_same_symbol("US500", symbol))
     {
      price1 = 2264.744749;
      scale = 1000.00;
      return;
     }
   if(is_same_symbol("USTEC", symbol))
     {
      price1 = 6185.376848;
      scale = 5555;
      return;
     }
   if(is_same_symbol("FR40", symbol))
     {
      price1 = 3247.2;
      scale = 2000.00;
      return;
     }
   if(is_same_symbol("JP225", symbol))
     {
      price1 = 14371.216374;
      scale = 1000;
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createGannGrid(string name, datetime time1, datetime time2, double price1, double scale)
  {
// Xóa Gann Grid nếu đã tồn tại
   ObjectDelete(0, name);
   ResetLastError();
   if(!ObjectCreate(0,name,OBJ_GANNGRID,0,time1,price1,time2,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

// Đặt các thuộc tính cho Gann Grid
   ObjectSetDouble(0, name, OBJPROP_SCALE, scale);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrDimGray); // Màu của Gann Grid
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);  // Kiểu đường nét của Gann Grid
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);          // Độ dày của Gann Grid
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);  // Cho phép chọn Gann Grid
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);     // Không ẩn Gann Grid
   ObjectSetInteger(0, name, OBJPROP_BACK, true);        // Vẽ Gann Grid phía trước các đối tượng khác
   ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_PERIOD_W1); // OBJ_PERIOD_D1|

   return(true);
  }
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
   ObjectSetInteger(chart_id, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_id, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_id, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_id, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_id, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id, objName, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_id, objName, OBJPROP_COLOR, clrTextColor);
   ObjectSetInteger(chart_id, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(chart_id, objName, OBJPROP_BORDER_COLOR, clrSilver);
   ObjectSetInteger(chart_id, objName, OBJPROP_BACK, true);
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

      CandleData candle(time, open, high, low, close, trend, 0, 0, "", 0, "", "", "", 0, "", 0, "");
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
   bool check_seq = false;
   if(TIME_FRAME == PERIOD_H4 || TIME_FRAME == PERIOD_H1)
     {
      length = 50;
      check_seq = true;
     }

   ArrayResize(candleArray, length+5);
     {
      datetime pre_HaTime = iTime(symbol, TIME_FRAME, length+4);
      double pre_HaOpen = iOpen(symbol, TIME_FRAME, length+4);
      double pre_HaHigh = iHigh(symbol, TIME_FRAME, length+4);
      double pre_HaLow = iLow(symbol, TIME_FRAME, length+4);
      double pre_HaClose = iClose(symbol, TIME_FRAME, length+4);
      string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

      CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0, 0, "", 0, "", "", "", 0, "", 0, "");
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

      CandleData candle_x(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_heiken, 0, "", 0, "", "", "", 0, "", 0, "");
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

         double ma03 = cal_MA(closePrices,  3, index);
         double ma05 = cal_MA(closePrices,  5, index);
         double ma10 = cal_MA(closePrices, 10, index);

         string trend_vector_ma10 = pre_cancle.ma10 < ma10 ? TREND_BUY : TREND_SEL;

         double mid = cur_cancle.close;
         string trend_by_ma05 = (mid > ma05) ? TREND_BUY : (mid < ma05) ? TREND_SEL : appendZero100(index);
         string trend_by_ma10 = (mid > ma10) ? TREND_BUY : (mid < ma10) ? TREND_SEL : appendZero100(index);
         int count_ma10 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_by_ma10 == candleArray[j].trend_by_ma10)
               count_ma10 += 1;
            else
               break;
           }

         string trend_ma3_vs_ma5 = (ma03 > ma05) ? TREND_BUY : (ma03 < ma05) ? TREND_SEL : appendZero100(index);
         int count_ma3_vs_ma5 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_ma3_vs_ma5 == candleArray[j].trend_ma3_vs_ma5)
               count_ma3_vs_ma5 += 1;
            else
               break;
           }

         double ma50 = 0;
         string trend_seq = "";
         if(check_seq && (index <= 1))
           {
            ma50 = cal_MA(closePrices, 50, index);

            string temp_seq = "";
            double ma20 = cal_MA(closePrices, 20, index);

            if(ma03 >= ma05 && ma05 >= ma10 && ma10 >= ma20 && ma05 >= ma50 && ma10 >= ma50)
               temp_seq = TREND_BUY;

            if(ma03 <= ma05 && ma05 <= ma10 && ma10 <= ma20 && ma05 <= ma50 && ma10 <= ma50)
               temp_seq = TREND_SEL;

            if(temp_seq != "")
              {
               double amp_w1, amp_d1, amp_h4, amp_grid_L100;
               GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

               double amp_seq = MathMax(MathAbs(ma03 - ma20),MathAbs(ma03 - ma50));
               if(amp_seq <= amp_d1)
                  trend_seq = temp_seq;
              }
           }

         string trend_ma10vs20 = "";
         if(TIME_FRAME == PERIOD_D1 && index == 0)
           {
            double ma20 = cal_MA(closePrices, 20, index);
            trend_ma10vs20 = (ma10 > ma20) ? TREND_BUY : (ma10 < ma20) ? TREND_SEL : appendZero100(index);
           }

         CandleData candle_x(cur_cancle.time, cur_cancle.open, cur_cancle.high, cur_cancle.low, cur_cancle.close, cur_cancle.trend_heiken
                             , cur_cancle.count_heiken, ma10, trend_by_ma10, count_ma10, trend_vector_ma10, trend_by_ma05, trend_ma3_vs_ma5, count_ma3_vs_ma5, trend_seq, ma50, trend_ma10vs20);

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
   return risk_1_Percent_Account_Balance()*0.5;
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
double risk_5p_Percent_Account_Equity()
  {
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   return EQUITY*0.05;
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

   bool stoploss_buy_by_macd = trend_mac_vs_signal_h4 == TREND_SEL && trend_vector_histogram_h4 == TREND_SEL && trend_vector_signal_h4 == TREND_SEL &&
                               trend_mac_vs_signal_h1 == TREND_SEL && trend_vector_histogram_h1 == TREND_SEL && trend_vector_signal_h1 == TREND_SEL;

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
   bool stoploss_sell_by_macd = trend_mac_vs_signal_h4 == TREND_BUY && trend_vector_histogram_h4 == TREND_BUY && trend_vector_signal_h4 == TREND_BUY &&
                                trend_mac_vs_signal_h1 == TREND_BUY && trend_vector_histogram_h1 == TREND_BUY && trend_vector_signal_h1 == TREND_BUY;
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
bool is_doji_heiken_ashi(CandleData &candleArray[], int candle_index)
  {
   double open = candleArray[candle_index].open;
   double high = candleArray[candle_index].high;
   double low = candleArray[candle_index].low;
   double close = candleArray[candle_index].close;

   double body = MathAbs(open - close) * 3;
   double shadow_hig = high - MathMax(open, close);
   double shadow_low = MathMin(open, close) - low;

   bool isDoji = (body <= shadow_hig) && (body <= shadow_low);

   return isDoji;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string to_percent(double profit, double decimal_part = 2)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   string percent = " (" + format_double_to_string(profit/BALANCE * 100, 1) + "%)";
   return percent;
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
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double PL=EQUITY - BALANCE;
   string percent = to_percent(profit_today);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double price = (bid+ask)/2;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   CandleData arrHeiken[];
   get_arr_heiken(symbol, PERIOD_CURRENT, arrHeiken);

   color clrHeiken = arrHeiken[1].trend_heiken == TREND_BUY ? clrBlue : clrRed;
   create_trend_line("close_heiken_1", iTime(symbol, PERIOD_CURRENT, 0) - TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, TimeCurrent() + TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, clrHeiken, STYLE_DOT, 1, false, false);
   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

   double import_price = (price*25500*(37.5/31.1035)/1000000);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = AccountInfoString(ACCOUNT_NAME) + " " + get_vntime();// + "(" + cur_timeframe + ") ";
   str_comments += "    Profit(today): " + format_double_to_string(profit_today, 2) + "$"
                   + " (" + format_double_to_string(profit_today*25500/1000000, 2) + " tr)" + percent + "/" + (string) count_closed_today + "L";
   str_comments += "    PL: " + (string)(int)PL + "$" + to_percent(PL)
                   + " (" + format_double_to_string(PL*25500/1000000, 2) + " tr)";

   str_comments += "    (Mac.Zero.H4): " + (string) trend_mac_vs_zero_h4;
   str_comments += "    (Mac.Sign.H1): " + (string) trend_mac_vs_signal_h1;
   str_comments += "    (Heiken "+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend_heiken + " (" + append1Zero(arrHeiken[0].count_heiken) + ")";
   str_comments += "    (Ma10 "+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend_by_ma10 + " (" + append1Zero(arrHeiken[0].count_ma10) + ")";
   str_comments += "    Init_Equity: " + format_double_to_string(INIT_EQUITY, 1) + "    Risk1%: " + format_double_to_string(risk_1_Percent_Account_Balance(), 1) + "$";

   if(is_same_symbol(Symbol(), "XAU"))
      str_comments += "    VND: " + format_double_to_string(import_price*1.09, 2) + "~" + format_double_to_string(import_price*1.119, 2) + " tr";

   str_comments += "    Amp(W1): " + format_double_to_string(amp_w1, Digits) + "$";
   str_comments += "    Amp(D1): " + format_double_to_string(amp_d1, Digits) + "$";
   str_comments += "    Amp(H4): " + format_double_to_string(amp_h4, Digits) + "$";
   str_comments += "    TP_D" + get_day_stop_trade(symbol, false);
   str_comments += "\n\n";


   return str_comments;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
