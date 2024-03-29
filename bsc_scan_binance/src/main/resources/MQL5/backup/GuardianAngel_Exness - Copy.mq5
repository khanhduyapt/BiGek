//+------------------------------------------------------------------+
//|                                         GuardianAngel_Exness.mq5 |
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

#define BtnBackground "_BACKGROUND"
#define BtnClosePosision "ButtonClosePosision"
#define BtnCloseOrder "ButtonCloseOrder"
#define BtnTrade "ButtonTrade"
#define BtnOrderBuy "ButtonOrderBuy"
#define BtnOrderSell "ButtonOrderSell"

double dbRiskRatio = 0.05; // Rủi ro 10% = 100$/lệnh
double INIT_EQUITY = 50.0; // Vốn đầu tư

string arr_main_symbol[] = {"XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

string INDI_NAME = "GuardianAngel_Exness";
string FILE_NAME_ANGEL_LOG = "Exness.log";
string arr_symbol[] =
  {
   "XAUUSD", "XAGUSD", "USOIL", "BTCUSD",
   "USTEC", "US30", "US500", "DE30", "UK100", "FR40", "AUS200",
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
string PREFIX_TRADE_PERIOD_H1 = "H1";
string PREFIX_TRADE_PERIOD_M5 = "M5";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OPEN_TRADE = "(OPEN_TRADE)";
string STOP_TRADE = "(STOP_TRADE)";
string OPEN_ORDERS = "(OPEN_ORDER)    ";

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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//WriteNotifyToken();
   Draw_Bottom_Msg();
   WriteComments();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   WriteNotifyToken();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteComments()
  {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(_Symbol, week_amp*2, risk), 2);
   string volume_w1 = format_double_to_string(dblLotsRisk(_Symbol, week_amp, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + _Symbol;
   string trend_macd = get_trend_by_macd_and_signal_vs_zero(_Symbol, PERIOD_H4);


   CandleData arr_heiken_w1[];
   get_arr_heiken(_Symbol, PERIOD_W1, arr_heiken_w1);
   CandleData arr_heiken[];
   get_arr_heiken(_Symbol, Period(), arr_heiken);

   string trend_swap = "";
   double swap_long  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double swap_short  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   if(swap_long > swap_short*2)
      trend_swap = TREND_BUY;
   if(swap_short > swap_long*2)
      trend_swap = TREND_SEL;

   str_comments += "    Macd (H4) " + AppendSpaces(trend_macd, 5);
   str_comments += "    Heiken(" + cur_timeframe + ") " + arr_heiken[0].trend + "("+(string)arr_heiken[0].count+")";
   str_comments += "    Vol(W1): " + volume_w1 + " lot";
   str_comments += "    Vol(00): " + volume_bt + " lot";

   str_comments += "    Risk: " + (string) risk + "$/" + (string)(dbRiskRatio * 100) + "% ";
   str_comments += "    " + get_profit_today();
   str_comments += "    WEEK(ha): " + arr_heiken_w1[0].trend + "("+(string)arr_heiken_w1[0].count+")";
   str_comments += "    WEEK(t3): " + get_trend_by_stoc(_Symbol, PERIOD_W1, 3, 2, 3);
   if(trend_swap != "")
      str_comments += "    Swap " + AppendSpaces(trend_swap, 5);

   Comment(str_comments);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteNotifyToken()
  {
   double risk_per_trade = calcRisk();

   string all_lines = "";
   string pre_symbol_prifix = "A";

   uint line_length = 380;
   string hyphen_line = "";
   for(uint j = 0; j < line_length; j++)
      hyphen_line += "-";

   string msg_list_am[];
   string msg_list_tp[];

   string msg_list_w1[];
   string msg_list_d1[];
   string msg_list_h4[];
   string msg_list_h1[];

   string msg_need_2_close[];
   string msg_list_trading[];

   string trade_amp_21w = "";
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
      string tradingview_symbol = symbol;
      StringReplace(tradingview_symbol, ".cash", "");

      //------------------------------------------------------------------

      string str_count_trade = CountTrade(symbol);
      bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
      bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
      bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
      bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

      if(str_count_trade != "" && StringFind(str_count_trade, TRADE_COUNT_POSITION) >= 0)
        {
         Exit_Trade(symbol);
         AutoTrade(symbol);
        }

      //------------------------------------------------------------------
      double upper_d1[], middle_d1[], lower_d1[];
      CalculateBollingerBands(symbol, PERIOD_D1, upper_d1, middle_d1, lower_d1, digits, 2);
      double hi_d1 = upper_d1[0];
      double lo_d1 = lower_d1[0];

      double upper_h4[], middle_h4[], lower_h4[];
      CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
      double hi_h4 = upper_h4[0];
      double lo_h4 = lower_h4[0];

      string bb_note = "";
      bool bb_allow_buy = false;
      bool bb_allow_sel = false;
      bool bb_alert = false;
      if(price <= lo_d1 || price <= lo_h4)
        {
         bb_allow_buy = true;

         bb_note += (price <= lo_d1) ? "D1":"";
         bb_note += (price <= lo_h4) ? "H4":"";
         bb_note += "(B)";

         if(price <= lo_d1 && price <= lo_h4) // && price <= lo_h1
            bb_alert = true;
        }

      if(price >= hi_d1 || price >= hi_h4)
        {
         bb_allow_sel = true;

         bb_note += (price >= hi_d1) ? "D1":"";
         bb_note += (price >= hi_h4) ? "H4":"";
         bb_note += "(S)";

         if(price >= hi_d1 && price >= hi_h4) // && price >= hi_h1
            bb_alert = true;
        }

      if(bb_note != "")
         bb_note = "(BB)" + bb_note;

      //------------------------------------------------------------------
      double dic_top_price;
      double dic_amp_w;
      double dic_avg_candle_week;
      double dic_amp_init_d1;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
      double week_amp = dic_amp_w;

      double volume = dblLotsRisk(symbol, week_amp, risk_per_trade);
      string str_volume = AppendSpaces(format_double_to_string(volume, 2), 5) +  "lot/" + AppendSpaces((string) NormalizeDouble(risk_per_trade, 0), 3, false) + "$";
      StringReplace(str_volume, ".0$", "$");
      //------------------------------------------------------------------
      double lowest = 0.0;
      double higest = 0.0;
      for(int i = 0; i < 21; i++)
        {
         double lowPrice = iLow(symbol, PERIOD_W1, i);
         double higPrice = iHigh(symbol, PERIOD_W1, i);

         if((i == 0) || (lowest > lowPrice))
            lowest = lowPrice;

         if((i == 0) || (higest < higPrice))
            higest = higPrice;
        }

      double rate_amp_buy = 0;
      double rate_amp_sel = 0;
      double amp_cycle_weeks = MathAbs(higest - lowest);


      bool is_allow_alert = false;
      string trend_by_amp_weeks = "";
      if((amp_cycle_weeks / week_amp) >= 3)
        {
         rate_amp_sel = MathAbs(higest - price);
         rate_amp_buy = MathAbs(lowest - price);

         if(rate_amp_sel < week_amp*2)
           {
            trend_by_amp_weeks = TREND_SEL;

            if(rate_amp_sel < week_amp)
               is_allow_alert = true;
           }

         if(rate_amp_buy < week_amp*2)
           {
            trend_by_amp_weeks = TREND_BUY;

            if(rate_amp_buy < week_amp)
               is_allow_alert = true;
           }
        }

      string trade_by_amp = "";
      if(trend_by_amp_weeks != "")
        {
         trade_amp_21w += symbol+ ";";
         trade_by_amp = AppendSpaces(trend_by_amp_weeks, 7);

         if(trend_by_amp_weeks == TREND_BUY)
           {
            trade_by_amp += "tba(" + format_double_to_string((rate_amp_buy / week_amp), 2) + ")";
            if(rate_amp_buy < week_amp)
               trade_by_amp += " * ";
           }

         if(trend_by_amp_weeks == TREND_SEL)
           {
            trade_by_amp += "tba(" + format_double_to_string((rate_amp_sel / week_amp), 2) + ")";
            if(rate_amp_sel < week_amp)
               trade_by_amp += " * ";
           }

         if(((trend_by_amp_weeks == TREND_BUY && bb_allow_buy) || (trend_by_amp_weeks == TREND_SEL && bb_allow_sel)))
           {
            string msg = OPEN_TRADE + bb_note + " ByAmp21W(BB): " + trend_by_amp_weeks + "    " + symbol + "    " + str_volume;
            SendTelegramMessage(symbol, trend_by_amp_weeks, msg);
           }
        }

      //--------------------------------------------------------------------------------------------------

      string tba_d1 = "";
      double rate_buy = (rate_amp_buy / week_amp);
      double rate_sel = (rate_amp_sel / week_amp);
      tba_d1 += "   Rm(B): " + format_double_to_string(rate_sel, 2);
      tba_d1 += "   Rm(S): " + format_double_to_string(rate_buy, 2);
      string rate = " B" + (string) NormalizeDouble(rate_sel, 1) + " S" + (string) NormalizeDouble(rate_buy,1);

      //--------------------------------------------------------------------------------------------------
      string trend_by_vect_h4 = get_trend_by_vector_ma(symbol, PERIOD_H4, 6);
      string trend_by_vect_h1 = get_trend_by_vector_ma(symbol, PERIOD_H1, 6);
      string trend_by_vect_15 = get_trend_by_vector_ma(symbol, PERIOD_M15, 6);

      string trading = "";
      if(has_position_buy)
         trading += TREND_BUY;
      if(has_position_sel)
         trading += TREND_SEL;

      if(has_position_buy || has_position_sel)
        {
         int msg_index = ArraySize(msg_list_trading);
         ArrayResize(msg_list_trading, msg_index + 1);

         string msg = "(Op) " + AppendSpaces(trading, 5) + tradingview_symbol;
         msg_list_trading[msg_index] = msg + rate;

         bool is_must_exit_h4 = is_must_exit_trade_by_stoch(symbol, PERIOD_H4, trading, 3, 3, 3);
         if(is_must_exit_h4)
           {
            string msg = "(TP) " + AppendSpaces(trading, 5) + tradingview_symbol;

            int msg_index = ArraySize(msg_list_tp);
            ArrayResize(msg_list_tp, msg_index + 1);
            msg_list_tp[msg_index] = msg;

            if(is_must_exit_trade_by_stoch(symbol, PERIOD_H1, trading, 3, 3, 3) ||
               is_must_exit_trade_by_stoch(symbol, PERIOD_M15, trading, 3, 3, 3) ||
               is_must_exit_trade_by_stoch(symbol, PERIOD_M5, trading, 3, 3, 3))
              {
               SendTelegramMessage(symbol, trading, "(TAKE.PROFIT.BY.STOC) H4 " + msg + str_count_trade);
              }
           }
        }
      else
         if(trend_by_amp_weeks != "" && is_allow_alert && trend_by_amp_weeks == trend_by_vect_h4)
           {
            string msg = "(Am) W1 " + AppendSpaces(trend_by_amp_weeks, 5) + tradingview_symbol;

            int msg_index = ArraySize(msg_list_am);
            ArrayResize(msg_list_am, msg_index + 1);
            msg_list_am[msg_index] = msg + rate;

            if((has_position_buy && StringFind(trend_by_amp_weeks, TREND_SEL) >= 0) ||
               (has_position_sel && StringFind(trend_by_amp_weeks, TREND_BUY) >= 0))
              {
               int msg_index_tp = ArraySize(msg_list_tp);
               ArrayResize(msg_list_tp, msg_index_tp + 1);
               msg_list_tp[msg_index_tp] = "(TP) " + AppendSpaces(trading, 5) + tradingview_symbol;
              }
           }
         else
           {
            string msg_w1 = find_switch_trend_w1(symbol);
            if(msg_w1 != "" && StringFind(msg_w1, trend_by_vect_h4) >= 0)
              {
               int msg_index = ArraySize(msg_list_w1);
               ArrayResize(msg_list_w1, msg_index + 1);
               msg_list_w1[msg_index] = msg_w1 + rate;

               if((has_position_buy && StringFind(msg_w1, TREND_SEL) >= 0) ||
                  (has_position_sel && StringFind(msg_w1, TREND_BUY) >= 0))
                 {
                  int msg_index_tp = ArraySize(msg_list_tp);
                  ArrayResize(msg_list_tp, msg_index_tp + 1);
                  msg_list_tp[msg_index_tp] = "(TP) " + AppendSpaces(trading, 5) + tradingview_symbol;
                 }
              }

            CandleData arr_heiken_w1[];
            get_arr_heiken(symbol, PERIOD_W1, arr_heiken_w1);

            string trend_by_ma50_h4 = get_trend_by_maX_maY(symbol, PERIOD_H4, 1, 50) == TREND_BUY ? TREND_SEL : TREND_BUY;
            string trend_by_ma50_h1 = get_trend_by_maX_maY(symbol, PERIOD_H1, 1, 50) == TREND_BUY ? TREND_SEL : TREND_BUY;
            string trend_by_ma50_05 = get_trend_by_maX_maY(symbol, PERIOD_M5, 1, 50) == TREND_BUY ? TREND_SEL : TREND_BUY;

            string msg_d1 = find_switch_trend(symbol, arr_heiken_w1[0].trend, PREFIX_TRADE_PERIOD_D1);
            if(msg_d1 != "")
              {
               int msg_index = ArraySize(msg_list_d1);
               ArrayResize(msg_list_d1, msg_index + 1);
               msg_list_d1[msg_index] = msg_d1 + rate;
              }

            if(trend_by_ma50_h4 == trend_by_vect_h4 && (trend_by_ma50_h4 == trend_by_vect_h1 || trend_by_ma50_h4 == trend_by_vect_15))
              {
               string msg_h4 = find_switch_trend(symbol, trend_by_ma50_h4, PREFIX_TRADE_PERIOD_H4);
               if(msg_h4 != "")
                 {
                  int msg_index = ArraySize(msg_list_h4);
                  ArrayResize(msg_list_h4, msg_index + 1);
                  msg_list_h4[msg_index] = msg_h4 + rate;

                  if(trend_by_vect_h4 == trend_by_ma50_05)
                     SendAlert(symbol, trend_by_vect_h4, msg_h4);
                 }
              }

            if(trend_by_vect_h4 == trend_by_ma50_h1)
              {
               string msg_h1 = find_switch_trend(symbol, trend_by_ma50_h1, PREFIX_TRADE_PERIOD_H1);
               if(msg_h1 != "")
                 {
                  int msg_index = ArraySize(msg_list_h1);
                  ArrayResize(msg_list_h1, msg_index + 1);
                  msg_list_h1[msg_index] = msg_h1 + rate;

                  if(trend_by_vect_h4 == trend_by_ma50_05)
                     SendAlert(symbol, trend_by_vect_h4, msg_h1);
                 }
              }

           }
      //--------------------------------------------------------------------------------------------------
      if(has_position_buy || has_position_sel)
        {
         CandleData arr_heiken_d1[];
         get_arr_heiken(symbol, PERIOD_D1, arr_heiken_d1);
         CandleData arr_heiken_h4[];
         get_arr_heiken(symbol, PERIOD_H4, arr_heiken_h4);

         string msg_close = "";
         if(has_position_buy && arr_heiken_d1[0].trend == TREND_SEL && arr_heiken_h4[1].trend == TREND_SEL && trend_by_vect_h4 == TREND_SEL && trend_by_vect_h1 == TREND_SEL)
           {
            msg_close = "(X) " + AppendSpaces(TREND_BUY, 5) + tradingview_symbol;
           }

         if(has_position_sel && arr_heiken_d1[0].trend == TREND_BUY && arr_heiken_h4[1].trend == TREND_BUY && trend_by_vect_h4 == TREND_BUY && trend_by_vect_h1 == TREND_BUY)
           {
            msg_close = "(X) " + AppendSpaces(TREND_SEL, 5) + tradingview_symbol;
           }

         if(msg_close != "")
           {
            int msg_index = ArraySize(msg_need_2_close);
            ArrayResize(msg_need_2_close, msg_index + 1);
            msg_need_2_close[msg_index] = msg_close + rate;
           }
        }

      //--------------------------------------------------------------------------------------------------
      if(bb_alert)
        {
         if((bb_allow_buy && has_position_sel) ||
            (bb_allow_sel && has_position_buy))
           {
            string msg = STOP_TRADE + " TAKE_PROFIT_BY_BOLLINGER_BANDS " + symbol;
            SendTelegramMessage(symbol, STOP_TRADE, msg);
           }
        }

      string remain = "";
      if(has_position_buy)
         remain += " Rm(B)(" + format_double_to_string(rate_sel, 2) + ")";
      if(has_position_sel)
         remain += " Rm(S)(" + format_double_to_string(rate_buy, 2) + ")";


      string trend_swap = "";
      double swap_long  = SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG);
      double swap_short  = SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT);
      if(swap_long > swap_short*2)
         trend_swap = TREND_BUY;
      if(swap_short > swap_long*2)
         trend_swap = TREND_SEL;


      string line = "";
      line += "." + AppendSpaces((string)(index + 1), 2, false) + "   ";
      line += AppendSpaces(tradingview_symbol) + AppendSpaces(format_double_to_string(price, digits-1), 8) + " | ";
      line += AppendSpaces("Swap(B:" + AppendSpaces((string)swap_long, 7, false) + ", S:" + AppendSpaces((string)swap_short, 7, false) + ") " + trend_swap, 35);

      line += str_volume + "/" + AppendSpaces(format_double_to_string(week_amp, digits), 8, false) + "  |  ";
      line += AppendSpaces(str_count_trade, 42);
      line += " | "  + AppendSpaces(remain, 15) + AppendSpaces(trade_by_amp, 25);

      line += "  https://www.tradingview.com/chart/r46Q5U5a/?symbol=" + AppendSpaces(tradingview_symbol);
      line += AppendSpaces(tba_d1, 30);

      //--------------------------------------------------------------------------------------------------
      if(StringLen(line) > 100)
        {
         if(StringFind(all_lines, tradingview_symbol) < 0)
           {
            string cur_symbol_prifix = StringSubstr(tradingview_symbol, 0, 1);
            if(pre_symbol_prifix != cur_symbol_prifix && 13 < index)
              {
               all_lines += hyphen_line + "\n";
               pre_symbol_prifix = cur_symbol_prifix;
              }

            if(index == 4 || index == 11)
               all_lines += hyphen_line + "\n";

            if(index == 38)
               all_lines += AppendSpaces(line, line_length);
            else
               all_lines += AppendSpaces(line, line_length) + "\n";
           }
        }
     }

//--------------------------------------------------------------------------------------------------
   string msgs = "";

   int trading_size = ArraySize(msg_list_trading);
   for(int i = 0; i < trading_size; i++)
      msgs += msg_list_trading[i] + ";";

   int am_array_size = ArraySize(msg_list_am);
   for(int i = 0; i < am_array_size; i++)
      msgs += msg_list_am[i] + ";";

   int w1_array_size = ArraySize(msg_list_w1);
   for(int i = 0; i < w1_array_size; i++)
      msgs += msg_list_w1[i] + ";";

   int tp_array_size = ArraySize(msg_list_tp);
   for(int i = 0; i < tp_array_size; i++)
      msgs += msg_list_tp[i] + ";";

   int d1_array_size = ArraySize(msg_list_d1);
   for(int i = 0; i < d1_array_size; i++)
      msgs += msg_list_d1[i] + ";";

   int h4_array_size = ArraySize(msg_list_h4);
   for(int i = 0; i < h4_array_size; i++)
      msgs += msg_list_h4[i] + ";";

   int h1_array_size = ArraySize(msg_list_h1);
   for(int i = 0; i < h1_array_size; i++)
      msgs += msg_list_h1[i] + ";";

   int close_ar_size = ArraySize(msg_need_2_close);
   for(int i = 0; i < close_ar_size; i++)
      msgs += msg_need_2_close[i] + ";";

   WriteFileContent(FILE_NAME_BUTTONS, msgs);
//--------------------------------------------------------------------------------------------------

   FileDelete(FILE_NAME_ANGEL_LOG);
   int nfile_draft = FileOpen(FILE_NAME_ANGEL_LOG, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_draft != INVALID_HANDLE)
     {
      string str_profit = get_vntime() + get_profit_today();
      FileWrite(nfile_draft, str_profit);

      string line = "";
      line += "." + AppendSpaces((string)(0), 2, false) + "   ";
      line += AppendSpaces("VNINDEX") + AppendSpaces("", 159);
      line += "  https://www.tradingview.com/chart/r46Q5U5a/?symbol=" + AppendSpaces("VNINDEX");
      FileWrite(nfile_draft, AppendSpaces(line, line_length));

      FileWrite(nfile_draft, hyphen_line);
      FileWrite(nfile_draft, all_lines);

      FileClose(nfile_draft);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Bottom_Msg()
  {
   int start_x = 10;
   int start_y = 50;
   int btn_width = 225;
   int btn_trade_width = 100;

//ObjectDelete(0, BtnBackground);
//createButton(BtnBackground, (string) TimeCurrent(), 0, start_y - 5, btn_width*2 + 15, 50 * 25, clrWhite, clrWhite, 8, 0);
//ObjectSetInteger(0, BtnBackground, OBJPROP_CORNER, CORNER_LEFT_UPPER);

   string str_count_trade = CountTrade(_Symbol);
   bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
   bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
   bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
   bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

   string trend_vector_ma6_h4 = get_trend_by_vector_ma(_Symbol, PERIOD_H4, 6);

   double haOpenH4, haCloseH4, haHighH4, haLowH4;
   CalculateHeikenAshi(_Symbol, PERIOD_H4, 0, haOpenH4, haCloseH4, haHighH4, haLowH4);
   string cur_haTrend_H4 = haOpenH4 < haCloseH4 ? TREND_BUY : TREND_SEL;

   double haOpen1, haClose1, haHigh1, haLow1;
   CalculateHeikenAshi(_Symbol, PERIOD_CURRENT, 1, haOpen1, haClose1, haHigh1, haLow1);
   string pre_haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(_Symbol, PERIOD_CURRENT, 0, haOpen0, haClose0, haHigh0, haLow0);
   string cur_haTrend = haOpen0 < haClose0 ? TREND_BUY : TREND_SEL;

   bool allow_trade = (trend_vector_ma6_h4 == cur_haTrend) || (trend_vector_ma6_h4 == pre_haTrend)
                      || (cur_haTrend_H4 == cur_haTrend) || (cur_haTrend_H4 == pre_haTrend);

   color clrTrade = clrGray;
   if(cur_haTrend == TREND_BUY)
      clrTrade = clrCadetBlue;
   if(cur_haTrend == TREND_SEL)
      clrTrade = clrFireBrick;




   if(allow_trade)
      createButton(BtnTrade,  "Trade " + get_current_timeframe_to_string(), start_x + 0*btn_trade_width, start_y, btn_trade_width - 5, 25, clrWhite, clrTrade, 8);
   else
      ObjectDelete(0, BtnTrade);

   createButton(BtnOrderBuy,  "Order " + get_current_timeframe_to_string(), start_x + 1*btn_trade_width, start_y, btn_trade_width - 5, 25, clrWhite, clrCadetBlue, 8);
   createButton(BtnOrderSell, "Order " + get_current_timeframe_to_string(), start_x + 2*btn_trade_width, start_y, btn_trade_width - 5, 25, clrWhite, clrFireBrick, 8);

   if(has_order_buy || has_order_sel)
      createButton(BtnCloseOrder,    "Close Ord",                           start_x + 3*btn_trade_width, start_y, btn_trade_width - 5, 25, clrWhite, clrGray,  8);
   else
     {
      ObjectDelete(0, BtnCloseOrder);
     }

   if(has_position_buy || has_position_sel)
     {
      if(has_order_buy || has_order_sel)
         createButton(BtnClosePosision, "Close Pos",                        start_x + 4*btn_trade_width, start_y, btn_trade_width - 5, 25, clrWhite, clrGray,  8);
      else
         createButton(BtnClosePosision, "Close Pos",                        start_x + 3*btn_trade_width, start_y, btn_trade_width - 5, 25, clrWhite, clrGray,  8);
     }
   else
     {
      ObjectDelete(0, BtnClosePosision);
     }

//-----------------------------------------------------------------------
   string contents = ReadFileContent(FILE_NAME_BUTTONS);
   ushort delimiter = StringGetCharacter(";",0);
   string msgs[];
   StringSplit(contents, delimiter, msgs);

   int init_x = 10;
   int init_y = 85;

   int size = ArraySize(msgs);
   int index_op = 0, index_wa = 0, btn_count = 0;
   bool has_o = false, has_p = false, has_w = false, has_d = false, has_h4 = false;
   for(int index = 0; index < size; index++)
     {
      string msg = msgs[index];
      color clrBackground = clrWhiteSmoke;

      string cur_symbol = "";
      int count_trade = 0;
      double profit = 0.0;

      ulong pre_ticket = 0;
      datetime min_start_date = TimeCurrent();
      int total_fx_size = ArraySize(arr_symbol);
      for(int temp_i = 0; temp_i < total_fx_size; temp_i++)
        {
         string symbol = arr_symbol[temp_i];
         string tradingview_symbol = symbol;
         StringReplace(tradingview_symbol, ".cash", "");

         if(StringFind(msg, tradingview_symbol) >= 0)
           {
            cur_symbol = symbol;

            for(int pos = PositionsTotal()-1; pos >= 0; pos--)
              {
               if(m_position.SelectByIndex(pos))
                 {
                  if(toLower(cur_symbol) == toLower(m_position.Symbol()))
                    {
                     count_trade += 1;
                     profit += m_position.Profit();

                     if(pre_ticket == 0 || pre_ticket > m_position.Ticket())
                        min_start_date = m_position.Time();
                    }
                 }
              }
           }
        }

      if(count_trade > 0)
        {
         int secondsPerDay = 24 * 60 * 60;
         int day = (int)MathRound((TimeCurrent() - min_start_date) / secondsPerDay);

         string str_profit = " o"+(string) count_trade + " " + format_double_to_string(profit, 1) +"$ " +(string)day+"d";
         msg += str_profit;
        }

      int x = 0;
      int y = 0;

      bool is_opening_btn = false;

      if(StringFind(msg, "(Op)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * 25);
         has_o = true;

         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrWhite;
        }

      if(StringFind(msg, "(TP)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * 25);
         y += has_o ? 10 : 0;

         has_p = true;
         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrPaleGreen;
        }


      if(StringFind(msg, "(X)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * 25);
         y += has_o ? 10 : 0;
         y += has_p ? 10 : 0;

         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrLightGray;
        }


      int next_col = (index_op > 0) ? 1 : 0;


      if(StringFind(msg, "W1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * 25);
         has_w = true;
         index_wa += 1;
         clrBackground = clrLightCyan;

         if(StringFind(msg, "(Am)") >= 0)
            clrBackground = clrPowderBlue;
        }

      if(StringFind(msg, "D1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * 25);
         y += has_w ? 10 : 0;

         has_d = true;
         index_wa += 1;
         clrBackground = clrAliceBlue;
        }

      if(StringFind(msg, "H4") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * 25);
         y += has_w ? 10 : 0;
         y += has_d ? 10 : 0;

         has_h4 = true;
         index_wa += 1;
         clrBackground = clrSnow;
        }

      if(StringFind(msg, "H1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * 25);
         y += has_w ? 10 : 0;
         y += has_d ? 10 : 0;
         y += has_h4 ? 10 : 0;

         index_wa += 1;
         clrBackground = clrWhite;
        }


      if(msg != "" && x > 0 && y > 0)
        {
         color clrTrade = StringFind(msg, TREND_BUY) >= 0 ? clrNavy : clrFireBrick;
         string TRADING_TREND = StringFind(msg, TREND_BUY) >= 0 ? TREND_BUY : TREND_SEL;

         if(is_opening_btn)
            StringReplace(msg, "(Op)", "");

         StringTrimLeft(msg);
         StringTrimRight(msg);
         StringReplace(msg, TREND_BUY, "B");
         StringReplace(msg, TREND_SEL, "S");
         StringReplace(msg, "  ", " ");
         StringReplace(msg, "  ", " ");
         StringReplace(msg, "  ", " ");
         StringReplace(msg, "(", "");
         StringReplace(msg, ")", "");
         StringReplace(msg, " ", "_");
         StringTrimLeft(msg);
         StringTrimRight(msg);

         if(cur_symbol == _Symbol)
           {
            clrBackground = clrHoneydew;
           }

         btn_count += 1;
         string btn_name = "btn_" + (string) btn_count;
         createButton(btn_name, msg, x, y, btn_width-5, 20, clrTrade, clrBackground, 6);
        }
     }

//int max_row = MathMax(index_op, index_wa) + 2;
//ObjectSetInteger(0, BtnBackground, OBJPROP_YSIZE, max_row * 25 + 10);

   for(int index = btn_count + 1; index < 100; index++)
      ObjectDelete(0, "btn_" + (string) index);

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
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if((StringFind(sparam, "btn_") >= 0) || (StringFind(sparam, "Button") >= 0))
        {
         string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         //Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            string tradingview_symbol = symbol;
            StringReplace(tradingview_symbol, ".cash", "");
            if(StringFind(buttonLabel, tradingview_symbol) >= 0)
              {
               if(StringFind(buttonLabel, PREFIX_TRADE_PERIOD_W1) >= 0)
                  ChartOpen(symbol, PERIOD_W1);
               else
                  ChartOpen(symbol, PERIOD_D1);

               long chartID=ChartFirst();
               while(chartID >= 0)
                 {
                  long close_chart_id = chartID;
                  string chartSymbol = ChartSymbol(close_chart_id);
                  if(chartSymbol != symbol)
                    {
                     ChartClose(close_chart_id);
                    }
                  chartID = ChartNext(chartID);
                 }

               Draw_Bottom_Msg();
              }
           }
        }

      double dic_top_price;
      double dic_amp_w;
      double dic_avg_candle_week;
      double dic_amp_init_d1;
      GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
      double week_amp = dic_amp_w;

      double amp_sl = week_amp*2;
      double volume = dblLotsRisk(_Symbol, amp_sl, calcRisk());

      string cur_click_prefix = get_prefix_trade_from_current_timeframe();

      double tp_buy = 0.0;
      double tp_sel = 0.0;
      double lowest_close_21 = 0.0;
      double higest_close_21 = 0.0;
      if((sparam == BtnTrade) || (sparam == BtnOrderBuy) || (sparam == BtnOrderSell))
        {
         double lowest = 0.0;
         double higest = 0.0;
         for(int i = 1; i <= 55; i++)
           {
            double close = iClose(_Symbol, PERIOD_H4, i);

            if((i == 1) || (lowest > close))
               lowest = close;

            if((i == 1) || (higest < close))
               higest = close;


            if(i <= 21)
              {
               if((i == 1) || (lowest_close_21 > close))
                  lowest_close_21 = close;

               if((i == 1) || (higest_close_21 < close))
                  higest_close_21 = close;
              }
           }

         tp_buy = higest;
         tp_sel = lowest;
        }

      //-----------------------------------------------------------------------
      if(sparam == BtnTrade)
        {
         for(int i = PositionsTotal()-1; i >= 0; i--)
           {
            if(m_position.SelectByIndex(i))
              {
               if(toLower(_Symbol) == toLower(m_position.Symbol()))
                 {
                  //string trade_from_comment = get_prefix_trade_from_comments(m_position.Comment());
                  //if(cur_trade_prefix == trade_from_comment)
                  Alert("Position   ", m_position.TypeDescription(), "   ", _Symbol, " was opened... profit: ", m_position.Profit());
                  return;
                 }
              }
           }

         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

         double haOpen1, haClose1, haHigh1, haLow1;
         CalculateHeikenAshi(_Symbol, PERIOD_CURRENT, 0, haOpen1, haClose1, haHigh1, haLow1);
         string haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

         double sl = 0.0;
         if(haTrend == TREND_BUY)
            sl = NormalizeDouble(price - amp_sl, digits);

         if(haTrend == TREND_SEL)
            sl = NormalizeDouble(price + amp_sl, digits);

         string msg = OPEN_TRADE + "    " + AppendSpaces(haTrend, 5) + _Symbol + "  vol: " + (string) volume + " lot";

         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         switch(result)
           {
            case IDYES:
               if(haTrend == TREND_BUY)
                  m_trade.Buy(volume,  _Symbol, 0.0, sl, tp_buy, "MK_B_" + cur_click_prefix);

               if(haTrend == TREND_SEL)
                  m_trade.Sell(volume, _Symbol, 0.0, sl, tp_sel, "MK_S_" + cur_click_prefix);

               Alert(msg+ ".");
               break;

            case IDNO:
               break;
           }
        }
      //-----------------------------------------------------------------------
      if((sparam == BtnOrderBuy) || (sparam == BtnOrderSell))
        {
         Print("The ", sparam," was clicked");

         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

         //-----------------------------------------------------------------------
         int count_order_buy = 0;
         int count_order_sel = 0;
         for(int i = OrdersTotal() - 1; i >= 0; i--)
           {
            if(m_order.SelectByIndex(i))
              {
               if((toLower(_Symbol) == toLower(m_order.Symbol())))
                 {
                  if(m_order.Type() == ORDER_TYPE_BUY_LIMIT || m_order.Type() == ORDER_TYPE_BUY || (StringFind(toLower(m_order.TypeDescription()), "buy") >= 0))
                     count_order_buy += 1;

                  if(m_order.Type() == ORDER_TYPE_SELL_LIMIT || m_order.Type() == ORDER_TYPE_SELL || (StringFind(toLower(m_order.TypeDescription()), "sel") >= 0))
                     count_order_sel += 1;
                 }
              }
           }

         //-----------------------------------------------------------------------
         if(sparam == BtnOrderBuy)
           {
            if(count_order_buy > 0)
              {
               Alert(get_vntime(), " Đã có lệnh ORDER BUY ", _Symbol);
               return;
              }

            double open_price = NormalizeDouble(lowest_close_21, digits);
            double sl = NormalizeDouble(open_price - amp_sl, digits);

            string msg = OPEN_ORDERS + AppendSpaces(TREND_BUY, 5) + _Symbol + "  vol: " + (string) volume + " lot";
            msg += "  Open: " + (string) open_price + "  SL: " + (string) sl + "  TP: " + (string) tp_buy;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  Alert(msg+ ".");
                  m_trade.BuyLimit(volume, open_price, _Symbol, sl, tp_buy, 0, 0, "OD_B_" + cur_click_prefix);
                  break;

               case IDNO:
                  break;
              }
           }
         //-----------------------------------------------------------------------
         if(sparam == BtnOrderSell)
           {
            if(count_order_sel > 0)
              {
               Alert(get_vntime(), " Đã có lệnh ORDER SELL ", _Symbol);
               return;
              }

            double open_price = NormalizeDouble(higest_close_21, digits);
            double sl = NormalizeDouble(open_price + amp_sl, digits);

            string msg = OPEN_ORDERS + AppendSpaces(TREND_SEL, 5) + _Symbol + "  vol: " + (string) volume + " lot";
            msg += "  Open: " + (string) open_price + "  SL: " + (string) sl + "  TP: " + (string) tp_sel;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  Alert(msg+ ".");
                  m_trade.SellLimit(volume, open_price, _Symbol, 0.0, tp_sel, 0, 0, "OD_S_" + cur_click_prefix);

                  break;

               case IDNO:
                  break;
              }
           }
        }

      //-----------------------------------------------------------------------
      if(sparam == BtnClosePosision)
        {
         Print("The ", sparam," was clicked");

         for(int i = PositionsTotal()-1; i >= 0; i--)
           {
            if(m_position.SelectByIndex(i))
              {
               ulong ticket = PositionGetTicket(i);
               double profit = PositionGetDouble(POSITION_PROFIT);
               string symbol = PositionGetString(POSITION_SYMBOL);
               string comments = PositionGetString(POSITION_COMMENT);

               if(toLower(_Symbol) == toLower(symbol))
                 {
                  int confirm_result = MessageBox("Đóng Position #" + (string) ticket + "   " + m_position.TypeDescription() + "   " + _Symbol + " profit: " + (string) profit + "?", "Confirm", MB_YESNOCANCEL);
                  if(confirm_result == IDYES)
                    {
                     Alert("Position #", ticket, "   ", _Symbol, " was closed... profit: ", profit);
                     m_trade.PositionClose(ticket);
                    }
                 }
              }
           }
        }

      if(sparam == BtnCloseOrder)
        {
         Print("The ", sparam," was clicked");

         for(int i = OrdersTotal() - 1; i >= 0; i--)
           {
            if(m_order.SelectByIndex(i))
              {
               ulong ticket = OrderGetTicket(i);
               string comments = OrderGetString(ORDER_COMMENT);

               if((toLower(_Symbol) == toLower(m_order.Symbol())))
                 {
                  int confirm_result = MessageBox("Đóng Order #" + (string) ticket+ "   " + m_order.TypeDescription() + "   " + _Symbol + "   " + comments + "?", "Confirm", MB_YESNOCANCEL);
                  if(confirm_result == IDYES)
                    {
                     Alert("Order #" + (string) ticket+ "   " + m_order.TypeDescription() + "   " + _Symbol + "   " + comments);
                     m_trade.OrderDelete(ticket);
                    }
                 }
              }
           }
        }

      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string find_switch_trend_w1(string symbol)
  {
   string find_trade = "";
   string trend_stoc_d3 = get_trend_by_stoc(symbol, PERIOD_D1, 3, 2, 3);

   find_trade = get_switch_trend_by_heiken_3_0(symbol, PERIOD_W1);
   if(find_trade != "" && find_trade == trend_stoc_d3)
      return "(Ha) " + PREFIX_TRADE_PERIOD_W1 + " " + AppendSpaces(find_trade, 5) + symbol;


   find_trade = get_switch_trend_by_stoch(symbol, PERIOD_W1, 3, 2, 3);
   if(find_trade != "" && find_trade == trend_stoc_d3)
      return "(Oc) " + PREFIX_TRADE_PERIOD_W1 + " " + AppendSpaces(find_trade, 5) + symbol;


   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string find_switch_trend(string symbol, string find_trade, string PREFIX_TRADE_XX)
  {
   ENUM_TIMEFRAMES TIME_FRAME = get_period(PREFIX_TRADE_XX);
   string PREFIX = get_prefix_trade_from_comments(PREFIX_TRADE_XX);
   if(PREFIX == "")
      PREFIX = PREFIX_TRADE_XX;
   PREFIX += " ";

   string msg = "";
   bool found = false;

   if((found == false) && is_allow_trade_now_by_stoc(symbol, TIME_FRAME, find_trade, 12, 6, 9) && (find_trade == get_trend_by_stoc(symbol, TIME_FRAME, 3, 3, 3)))
     {
      found = true;
      msg = "(Oc) " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_ma(symbol, TIME_FRAME, 6, 9)))
     {
      found = true;
      msg = "(69) " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_heiken_6_1(symbol, TIME_FRAME)))
     {
      found = true;
      msg = "(Ha) " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_heiken_and_ma_X_Y(symbol, TIME_FRAME, 6, 10)))
     {
      found = true;
      msg = "(10) " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_heiken_and_ma_X_Y(symbol, TIME_FRAME, 6, 20)))
     {
      found = true;
      msg = "(20) " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if(StringFind(PREFIX_TRADE_PERIOD_H4 + PREFIX_TRADE_PERIOD_H1 + PREFIX_TRADE_PERIOD_M5, PREFIX_TRADE_XX) >= 0)
     {
      if((found == false) && (find_trade == get_switch_trend_by_seq_6_10_20_50(symbol, TIME_FRAME)))
        {
         found = true;
         msg = "(Sq) " + PREFIX + AppendSpaces(find_trade, 5);
        }
     }


   if(StringFind(PREFIX_TRADE_PERIOD_H4 + PREFIX_TRADE_PERIOD_D1 + PREFIX_TRADE_PERIOD_W1, PREFIX_TRADE_XX) >= 0)
     {
      string trend_stoc_d3 = get_trend_by_stoc(symbol, PERIOD_D1, 3, 2, 3);
      if(find_trade != trend_stoc_d3)
         return "";

      if((found == false) && (find_trade == get_switch_trend_by_stoch(symbol, PERIOD_H4, 3, 2, 3)))
        {
         found = true;
         msg = "(Oc) " + PREFIX + AppendSpaces(find_trade, 5);
        }

      if((found == false) && (find_trade == get_switch_trend_by_stoch(symbol, PERIOD_D1, 3, 2, 3)))
        {
         found = true;
         msg = "(Oc) " + PREFIX + AppendSpaces(find_trade, 5);
        }

      if((found == false) && (find_trade == get_switch_trend_by_stoch(symbol, PERIOD_W1, 3, 2, 3)))
        {
         found = true;
         msg = "(Oc) " + PREFIX + AppendSpaces(find_trade, 5);
        }
     }

   if(msg != "")
      msg += symbol;

   return msg;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoTrade(string symbol)
  {
   ulong max_ticket_buy = 0, max_ticket_sel = 0;
   double best_entry_buy = 0, best_entry_sel = 0;
   int count_possion_buy = 0, count_possion_sel = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            // --------------------------------------------------------
            if(StringFind(toLower(m_position.TypeDescription()), "buy") >= 0)
              {
               count_possion_buy += 1;

               if(max_ticket_buy < m_position.Ticket())
                 {
                  max_ticket_buy = m_position.Ticket();
                  best_entry_buy = m_position.PriceOpen();
                 }
              }

            if(StringFind(toLower(m_position.TypeDescription()), "sel") >= 0)
              {
               count_possion_sel += 1;
               if(max_ticket_sel < m_position.Ticket())
                 {
                  max_ticket_sel = m_position.Ticket();
                  best_entry_sel = m_position.PriceOpen();
                 }
              }
           }
        }
     } //for
//------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(count_possion_buy > 0)
     {
      bool allow_push_buy = (MathMax(best_entry_buy, best_entry_sel) - price) > week_amp;

      if(allow_push_buy && get_trend_by_vector_ma(symbol, PERIOD_M15, 6) == TREND_BUY && get_trend_by_heiken(symbol, PERIOD_H1, 0) == TREND_BUY)
        {
         SendTelegramMessage(symbol, TREND_BUY, " allow.push.buy  " + symbol + "   Vol: " + (string) get_default_volume(symbol));
        }
     }

   if(count_possion_sel > 0)
     {
      bool allow_push_sel = (price - MathMax(best_entry_buy, best_entry_sel)) > week_amp;

      if(allow_push_sel && get_trend_by_vector_ma(symbol, PERIOD_M15, 6) == TREND_SEL && get_trend_by_heiken(symbol, PERIOD_H1, 0) == TREND_SEL)
        {
         SendTelegramMessage(symbol, TREND_SEL, " allow.push.sel " + symbol + "   Vol: " + (string) get_default_volume(symbol));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Exit_Trade(string symbol)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();
            double price_open = m_position.PriceOpen();
            double profit = m_position.Profit();
            double sl = m_position.StopLoss();
            double tp = m_position.TakeProfit();
            string comments = m_position.Comment();

            datetime time = m_position.Time();
            datetime nex_time = time - (iTime(symbol, PERIOD_H1, 1) - iTime(symbol, PERIOD_H1, 10));

            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
            double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);

            string TRADING_TREND = "";
            if(toLower(m_position.TypeDescription()) == toLower(TREND_BUY))
               TRADING_TREND = TREND_BUY;

            if(toLower(m_position.TypeDescription()) == toLower(TREND_SEL))
               TRADING_TREND = TREND_SEL;

            ENUM_TIMEFRAMES TRADE_PERIOD = get_period(comments);
            double amp_trade_default = get_default_amp_trade(symbol, TRADE_PERIOD);
            //-------------------------------------------------------------------------------------------------
            //-------------------------------------------------------------------------------------------------
            double haOpen1, haClose1, haHigh1, haLow1;
            CalculateHeikenAshi(symbol, TRADE_PERIOD, 1, haOpen1, haClose1, haHigh1, haLow1);
            string haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

            if(TRADING_TREND == TREND_BUY)
              {
               double stop_loss = price_open - amp_trade_default;
               if(haTrend == TREND_SEL && haClose1 <= stop_loss)
                 {
                  //Alert(get_vntime(), "   STOP_LOSS (BUY) : ", symbol, "   Profit: ", (string)profit + "$");
                 }
              }

            if(TRADING_TREND == TREND_SEL)
              {
               double stop_loss = price_open + amp_trade_default;
               if(haTrend == TREND_BUY && haClose1 >= stop_loss)
                 {
                  //Alert(get_vntime(), "   STOP_LOSS (SELL): ", symbol, "   Profit: ", (string)profit + "$");
                 }
              }
            //-------------------------------------------------------------------------------------------------
            //-------------------------------------------------------------------------------------------------
            if(sl == 0)
              {
               double dic_top_price;
               double dic_amp_w;
               double dic_avg_candle_week;
               double dic_amp_init_d1;
               GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
               double week_amp = dic_amp_w;


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
                  if(amp_sl < week_amp*2)
                     amp_sl = week_amp*2;

                  double sl_new = price_open - amp_sl;
                  if(sl_new < price)
                    {
                     m_trade.PositionModify(ticket, NormalizeDouble(sl_new, digits), tp);
                     //Alert(get_vntime(), "   INIT   SL   (BUY) : ", symbol, "   sl_new: ", (string)sl_new);
                    }
                 }

               if(TRADING_TREND == TREND_SEL)
                 {
                  double amp_sl = (higest - price);
                  if(amp_sl < week_amp*2)
                     amp_sl = week_amp*2;

                  double sl_new = price_open + amp_sl;
                  if(sl_new > price)
                    {
                     m_trade.PositionModify(ticket, NormalizeDouble(sl_new, digits), tp);
                     //Alert(get_vntime(), "   INIT   SL   (SELL): ", symbol, "   sl_new: ", (string)sl_new);
                    }
                 }
              }
            //-------------------------------------------------------------------------------------------------
            //-------------------------------------------------------------------------------------------------

           }
        }
     }
  }


//+------------------------------------------------------------------+
string CountTrade(string symbol)
  {
   int ord_buy = 0;
   int ord_sel = 0;
   int pos_buy = 0;
   int pos_sel = 0;

   int count_possion = 0;
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
      result += AppendSpaces(TRADE_COUNT_ORDER_B + (string)ord_buy, 13);

   if(ord_sel > 0)
      result += AppendSpaces(TRADE_COUNT_ORDER_S + (string)ord_sel, 13);

   if(ord_buy + ord_sel == 0)
      result += AppendSpaces("", 13);

   if(pos_buy > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_B + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_buy, 2), 20) + "  P:" + AppendSpaces(format_double_to_string(profit_buy, 2) + "$", 7, false);

   if(pos_sel > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_S + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_sel, 2), 20) + "  P:" + AppendSpaces(format_double_to_string(profit_sel, 2) + "$", 7, false);

   StringReplace(result, ".0$", "$");

   return AppendSpaces(result, 50);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size, int z_index=999)
  {
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
double get_default_amp_trade(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(TIMEFRAME == PERIOD_W1)
      return NormalizeDouble(week_amp, digits);

   if(TIMEFRAME == PERIOD_D1)
      return NormalizeDouble(week_amp / 2, digits);

   if(TIMEFRAME == PERIOD_H4)
      return NormalizeDouble(week_amp / 4, digits);

   if(TIMEFRAME == PERIOD_H1)
      return NormalizeDouble(week_amp / 8, digits);

   if(TIMEFRAME < PERIOD_H1)
      return NormalizeDouble(week_amp / 16, digits);

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
double get_ma_value(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index, int canlde_index)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);


   int SMA_Handle = iMA(symbol,timeframe,ma_index,0,MODE_SMA,PRICE_CLOSE);
   double SMA_Buffer[];
   ArraySetAsSeries(SMA_Buffer, true);
   if(CopyBuffer(SMA_Handle,0,0,canlde_index+5,SMA_Buffer)<=0)
      return price;

   return SMA_Buffer[canlde_index];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int SMA_6_Handle = iMA(symbol,timeframe,ma_index_6,0,MODE_SMA,PRICE_CLOSE);
   int SMA_9_Handle = iMA(symbol,timeframe,ma_index_9,0,MODE_SMA,PRICE_CLOSE);

   double SMA_6_Buffer[];
   double SMA_9_Buffer[];

   ArraySetAsSeries(SMA_6_Buffer, true);
   ArraySetAsSeries(SMA_9_Buffer, true);

   if(CopyBuffer(SMA_6_Handle,0,0,5,SMA_6_Buffer)<=0 ||
      CopyBuffer(SMA_9_Handle,0,0,5,SMA_9_Buffer)<=0)
      return "";

   if(SMA_6_Buffer[0] > SMA_9_Buffer[0])
      return TREND_BUY;

   if(SMA_6_Buffer[0] < SMA_9_Buffer[0])
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int SMA_6_Handle = iMA(symbol,timeframe,ma_index_6,0,MODE_SMA,PRICE_CLOSE);
   int SMA_9_Handle = iMA(symbol,timeframe,ma_index_9,0,MODE_SMA,PRICE_CLOSE);

   double SMA_6_Buffer[];
   double SMA_9_Buffer[];

   ArraySetAsSeries(SMA_6_Buffer, true);
   ArraySetAsSeries(SMA_9_Buffer, true);

   if(CopyBuffer(SMA_6_Handle,0,0,5,SMA_6_Buffer)<=0 ||
      CopyBuffer(SMA_9_Handle,0,0,5,SMA_9_Buffer)<=0)
      return "";

   if(SMA_6_Buffer[1] >= SMA_9_Buffer[1] && SMA_6_Buffer[2] <= SMA_9_Buffer[2])
      return TREND_BUY;

   if(SMA_6_Buffer[1] <= SMA_9_Buffer[1] && SMA_6_Buffer[2] >= SMA_9_Buffer[2])
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_vector_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   int SMA_10_Handle = iMA(symbol,timeframe,ma_index,0,MODE_SMA,PRICE_CLOSE);

   double SMA_10_Buffer[];

   ArraySetAsSeries(SMA_10_Buffer, true);

   if(CopyBuffer(SMA_10_Handle,0,0,5,SMA_10_Buffer)<=0)
      return "";

   if(SMA_10_Buffer[0] > SMA_10_Buffer[1])
      return TREND_BUY;

   if(SMA_10_Buffer[0] < SMA_10_Buffer[1])
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
void get_arr_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[])
  {
   ArrayResize(candleArray, 15);

   datetime pre_HaTime = iTime(symbol, TIME_FRAME, 14);
   double pre_HaOpen = iOpen(symbol, TIME_FRAME, 14);
   double pre_HaHigh = iHigh(symbol, TIME_FRAME, 14);
   double pre_HaLow = iLow(symbol, TIME_FRAME, 14);
   double pre_HaClose = iClose(symbol, TIME_FRAME, 14);
   string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0);
   candleArray[14] = candle;

   for(int index = 13; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh = MathMax(iOpen(symbol, TIME_FRAME, index), MathMax(haClose, pre_cancle.high));
      double haLow = MathMin(iOpen(symbol, TIME_FRAME, index), MathMin(haClose, pre_cancle.low));

      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_trend = 1;
      for(int j = index+1; j < 10; j++)
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
string get_switch_trend_by_heiken_6_1(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   string haTrend1 = candleArray[1].trend;
   string haTrend2 = candleArray[2].trend;
   if(haTrend1 != haTrend2 && candleArray[2].count > 3)
     {
      return haTrend1;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_heiken_3_0(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   string haTrend0 = candleArray[0].trend;
   string haTrend1 = candleArray[1].trend;
   if(haTrend0 != haTrend1 && candleArray[1].count >= 2)
     {
      return haTrend0;
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(symbol, TIME_FRAME, candle_index, haOpen0, haClose0, haHigh0, haLow0);

   if(haOpen0 < haClose0)
      return TREND_BUY;

   if(haOpen0 > haClose0)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_heiken_and_ma_X_Y(string symbol, ENUM_TIMEFRAMES timeframe, int fast_ma=6, int slow_ma = 10)
  {
   int SMA_06_Handle = iMA(symbol,timeframe,fast_ma,0,MODE_SMA,PRICE_CLOSE);
   int SMA_10_Handle = iMA(symbol,timeframe,slow_ma,0,MODE_SMA,PRICE_CLOSE);

   double SMA_06_Buffer[];
   double SMA_10_Buffer[];
   ArraySetAsSeries(SMA_06_Buffer, true);
   ArraySetAsSeries(SMA_10_Buffer, true);
   if(CopyBuffer(SMA_06_Handle,0,0,5,SMA_06_Buffer)<=0 ||
      CopyBuffer(SMA_10_Handle,0,0,5,SMA_10_Buffer)<=0)
      return "";

   double ma6_0 = SMA_06_Buffer[0];
   double ma6_1 = SMA_06_Buffer[1];
   double ma10 = SMA_10_Buffer[1];

   double haOpen1, haClose1, haHigh1, haLow1;
   CalculateHeikenAshi(symbol, timeframe, 1, haOpen1, haClose1, haHigh1, haLow1);
   string pre_haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(symbol, timeframe, 0, haOpen0, haClose0, haHigh0, haLow0);
   string cur_haTrend = haOpen0 < haClose0 ? TREND_BUY : TREND_SEL;

   if((pre_haTrend == TREND_BUY && cur_haTrend == TREND_BUY) && (ma6_0 > ma6_1) &&
      (haOpen1 <= ma6_1 && ma6_1 <= haClose1) && (haOpen1 <= ma10 && ma10 <= haClose1))
      return TREND_BUY;

   if((pre_haTrend == TREND_SEL && cur_haTrend == TREND_SEL) && (ma6_0 < ma6_1) &&
      (haOpen1 >= ma6_1 && ma6_1 >= haClose1) && (haOpen1 >= ma10 && ma10 >= haClose1))
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_seq_6_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_seq_ma10_20_50 = "";

   int SMA_06_Handle = iMA(symbol,timeframe, 6,0,MODE_SMA,PRICE_CLOSE);
   int SMA_10_Handle = iMA(symbol,timeframe,10,0,MODE_SMA,PRICE_CLOSE);
   int SMA_20_Handle = iMA(symbol,timeframe,20,0,MODE_SMA,PRICE_CLOSE);
   int SMA_50_Handle = iMA(symbol,timeframe,50,0,MODE_SMA,PRICE_CLOSE);

   double close = iClose(symbol, timeframe, 0);

   double SMA_06_Buffer[];
   double SMA_10_Buffer[];
   double SMA_20_Buffer[];
   double SMA_50_Buffer[];

   ArraySetAsSeries(SMA_06_Buffer, true);
   ArraySetAsSeries(SMA_10_Buffer, true);
   ArraySetAsSeries(SMA_20_Buffer, true);
   ArraySetAsSeries(SMA_50_Buffer, true);

   if(CopyBuffer(SMA_06_Handle,0,0,5,SMA_06_Buffer)<=0 ||
      CopyBuffer(SMA_10_Handle,0,0,5,SMA_10_Buffer)<=0 ||
      CopyBuffer(SMA_20_Handle,0,0,5,SMA_20_Buffer)<=0 ||
      CopyBuffer(SMA_50_Handle,0,0,5,SMA_50_Buffer)<=0)
      return "";

   if((SMA_06_Buffer[0] >= SMA_10_Buffer[1]) && (SMA_06_Buffer[0] >= SMA_20_Buffer[1]))
      if((close >= SMA_10_Buffer[1]) && (close >= SMA_20_Buffer[1]) && (close > SMA_50_Buffer[1]))
         if((SMA_06_Buffer[0] >= SMA_06_Buffer[1]) && ((SMA_10_Buffer[0] >= SMA_10_Buffer[1]) || (SMA_20_Buffer[0] >= SMA_20_Buffer[1])))
           {
            trend_seq_ma10_20_50 = TREND_BUY;
           }

   if((SMA_06_Buffer[0] <= SMA_10_Buffer[1]) && (SMA_06_Buffer[0] <= SMA_20_Buffer[1]))
      if((close <= SMA_10_Buffer[1]) && (close <= SMA_20_Buffer[1]) && (close < SMA_50_Buffer[1]))
         if((SMA_06_Buffer[0] <= SMA_06_Buffer[1]) && ((SMA_10_Buffer[0] <= SMA_10_Buffer[1]) || (SMA_20_Buffer[0] <= SMA_20_Buffer[1])))
           {
            trend_seq_ma10_20_50 = TREND_SEL;
           }


   if(trend_seq_ma10_20_50 != "")
     {
      double lowest = iLow(symbol, timeframe, 1);
      double higest = iHigh(symbol, timeframe, 1);
      double high = (higest - lowest)/2;

      if(trend_seq_ma10_20_50 == TREND_SEL)
         lowest = lowest - high;

      if(trend_seq_ma10_20_50 == TREND_BUY)
         higest = higest + high;

      if((lowest <= SMA_50_Buffer[1]) && (SMA_50_Buffer[1] <= higest))
        {
         return trend_seq_ma10_20_50;
        }
     }

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   int SMA_10_Handle = iMA(symbol,timeframe,ma_index,0,MODE_SMA,PRICE_CLOSE);
   double SMA_10_Buffer[];
   ArraySetAsSeries(SMA_10_Buffer, true);
   if(CopyBuffer(SMA_10_Handle,0,0,5,SMA_10_Buffer)<=0)
      return "";

   double haOpen1, haClose1, haHigh1, haLow1;
   CalculateHeikenAshi(symbol, timeframe, 1, haOpen1, haClose1, haHigh1, haLow1);

   double haOpen2, haClose2, haHigh2, haLow2;
   CalculateHeikenAshi(symbol, timeframe, 2, haOpen2, haClose2, haHigh2, haLow2);

   double close_1 = iClose(symbol, timeframe, 1);
   if(close_1 >= SMA_10_Buffer[1] && haClose1 >= SMA_10_Buffer[1] && haClose2 <= SMA_10_Buffer[1])
      return TREND_BUY;

   if(close_1 <= SMA_10_Buffer[1] && haClose1 <= SMA_10_Buffer[1] && haClose2 >= SMA_10_Buffer[1])
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
string get_prefix_trade_from_current_timeframe()
  {
   if(Period() == PERIOD_M5)
      return PREFIX_TRADE_PERIOD_M5;

   if(Period() ==  PERIOD_H1)
      return PREFIX_TRADE_PERIOD_H1;

   if(Period() ==  PERIOD_H4)
      return PREFIX_TRADE_PERIOD_H4;

   if(Period() ==  PERIOD_D1)
      return PREFIX_TRADE_PERIOD_D1;

   if(Period() ==  PERIOD_W1)
      return PREFIX_TRADE_PERIOD_W1;

   return PREFIX_TRADE_PERIOD_H4;
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
ENUM_TIMEFRAMES get_period(string comments)
  {
   string TRADE_PERIOD = "";
   string low_comments =toLower(comments);

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
   string vntime = "(" + str_date_time + ")    " + cpu + "   ";
   return vntime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string prefix, string symbol, string trend, ENUM_TIMEFRAMES TIMEFRAME)
  {
   string date_time = (string)iTime(symbol, TIMEFRAME, 0);
   StringReplace(date_time, ":00:00", "h");
   StringReplace(date_time, "2024.", "");
   StringReplace(date_time, "2025.", "");
   StringReplace(date_time, "2026.", "");

   return date_time + ":" + prefix + ":" + trend + ":" + symbol +";";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string prefix, string symbol, string trend)
  {
   string open_trade_today = ReadFileContent(filename);

   ENUM_TIMEFRAMES TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_W1)
      TIMEFRAME = PERIOD_W1;
   if(prefix == PREFIX_TRADE_PERIOD_D1)
      TIMEFRAME = PERIOD_D1;
   if(prefix == PREFIX_TRADE_PERIOD_H4)
      TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_H1)
      TIMEFRAME = PERIOD_H1;

   string key = create_key(prefix, symbol, trend, TIMEFRAME);

   open_trade_today = open_trade_today + key;
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
bool is_has_memo_in_file(string filename, string prefix, string symbol, string trend)
  {
   string open_trade_today = ReadFileContent(filename);

   ENUM_TIMEFRAMES TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_W1)
      TIMEFRAME = PERIOD_W1;
   if(prefix == PREFIX_TRADE_PERIOD_D1)
      TIMEFRAME = PERIOD_D1;
   if(prefix == PREFIX_TRADE_PERIOD_H4)
      TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_H1)
      TIMEFRAME = PERIOD_H1;

   string key = create_key(prefix, symbol, trend, TIMEFRAME);

   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
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
   if(Period() ==  PERIOD_H8)
      return "H8";
   if(Period() ==  PERIOD_H12)
      return "H12";
   if(Period() ==  PERIOD_D1)
      return "D1";
   if(Period() ==  PERIOD_W1)
      return "W1";
   if(Period() ==  PERIOD_MN1)
      return "MN";


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
   string numberString = (string) number;
   int dotPosition = StringFind(numberString, ".");
   if(dotPosition > 0)
     {
      int integerPart = (int)MathFloor(number);
      string fractionalPart = StringSubstr(numberString, dotPosition + 1, digits);
      if(StringLen(fractionalPart) < digits)
         fractionalPart += "0";

      numberString = (string)integerPart+ "." + fractionalPart;
     }
   StringReplace(numberString, "00000000000001", "");
   StringReplace(numberString, "99999999999999", "9");
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
   string trend_long_term = get_trend_by_stoc(symbol, timeframe, 12, 6, 9);
   string trend_shot_term = get_trend_by_stoc(symbol, timeframe,  3, 3, 3);

   if(trend_long_term == trend_shot_term)
      return trend_long_term;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, int periodK = 12, int periodD = 6, int slowing = 9)
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

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   if(black_K == red_D)
     {
      if(K[1] > D[1])
         return TREND_SEL;

      if(K[1] < D[1])
         return TREND_BUY;

      if(K[0] > K[1])
         return TREND_BUY;

      if(K[0] < K[1])
         return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int periodK, int periodD, int slowing)
  {
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
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string trend, int periodK, int periodD, int slowing)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(trend == TREND_BUY && (black_K <= 20 && red_D <= 20))
      return true;

   if(trend == TREND_SEL && (black_K >= 80 && red_D >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
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
string get_switch_trend_by_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
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

   if(symbol == "USOIL.cash" || symbol == "USOIL")
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

   if(symbol == "US500.cash" || symbol == "US500")
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.035;
      amp_w = 60.00;
      avg_candle_week = 593.00;
      return;
     }

   if(symbol == "US100.cash" || symbol == "USTEC")
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.07;
      amp_w = 274.5;
      avg_candle_week = 503.15;
      return;
     }

   if(symbol == "US30.cash" || symbol == "US30")
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.04;
      amp_w = 438.76;
      avg_candle_week = 818.86;
      return;
     }

   if(symbol == "UK100.cash" || symbol == "UK100")
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

   if(symbol == "DE30")
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.045;
      amp_w = 222.45;
      avg_candle_week = 2205.075;
      return;
     }

   if(symbol == "FRA40.cash" || symbol == "FR40")
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      avg_candle_week = 1145.95;
      return;
     }

   if(symbol == "AUS200.cash" || symbol == "AUS200")
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
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

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
