//+------------------------------------------------------------------+
//|                                           GuardianAngel_Ftmo.mq5 |
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

#define BtnClose "ButtonClose"
#define BtnTrade "ButtonTrade"
#define BtnOrderBuy "ButtonOrderBuy"
#define BtnOrderSell "ButtonOrderSell"

string INDI_NAME = "GuardianAngel_Ftmo";
double dbRiskRatio = 0.05; // Rủi ro 10% = 100$/lệnh
double INIT_EQUITY = 50.0; // Vốn đầu tư

string arr_symbol[] =
  {
   "XAUUSD", "XAGUSD", "USOIL.cash", "BTCUSD",
   "US100.cash", "US30.cash", "US500.cash", "GER40.cash", "UK100.cash", "FRA40.cash", "AUS200.cash",
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
string PREFIX_TRADE_VECHAI_H1 = "H1";
string PREFIX_TRADE_VECHAI_M15 = "M15";



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OPEN_TRADE = "(OPEN_TRADE)";
string OPEN_ORDERS = "(OPEN_ORDER)    ";
string TRADE_COUNT_ORDER = " Order";
string TRADE_COUNT_ORDER_B = TRADE_COUNT_ORDER + " (B):";
string TRADE_COUNT_ORDER_S = TRADE_COUNT_ORDER + " (S):";
string TRADE_COUNT_POSITION = " Position";
string TRADE_COUNT_POSITION_B = TRADE_COUNT_POSITION + " (B):";
string TRADE_COUNT_POSITION_S = TRADE_COUNT_POSITION + " (S):";

string FILE_NAME_OPEN_TRADE = "open_trade_today.txt";
string FILE_NAME_SEND_MSG = "send_msg_today.txt";
string FILE_NAME_ANGEL_LOG = "angel.log";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   WriteComments();
   WriteNotifyToken();

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
   string volume_w1 = format_double_to_string(dblLotsRisk(_Symbol, week_amp, risk), 2);
   string volume_h4 = format_double_to_string(dblLotsRisk(_Symbol, get_default_amp_trade(_Symbol, PERIOD_H4), risk), 2);
   string volume_h1 = format_double_to_string(dblLotsRisk(_Symbol, get_default_amp_trade(_Symbol, PERIOD_H1), risk), 2);
   string volume_15 = format_double_to_string(dblLotsRisk(_Symbol, get_default_amp_trade(_Symbol, PERIOD_M15), risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + _Symbol;
   string trend_macd = get_trend_by_macd_and_signal_vs_zero(_Symbol, PERIOD_H4);

   CandleData candle_heiken;
   CountHeikenList(_Symbol, PERIOD_CURRENT, 1, candle_heiken);

   str_comments += "   Macd (H4) " + AppendSpaces(trend_macd, 5);

   str_comments += "   Stoc1296 (H4) " + get_candle_switch_trend_stoch(_Symbol, PERIOD_H4, 12, 9, 6);
   str_comments += "   CandleData(1) (" + cur_timeframe + ") " + candle_heiken.trend + "("+(string)candle_heiken.count+")";

   str_comments += "    Vol(H1): " + volume_h1 + " lot";
   str_comments += "    Vol(H4): " + volume_h4 + " lot";
   str_comments += "    Vol(W1): " + volume_w1 + " lot";

   str_comments += "    Risk: " + (string) risk + "$/" + (string)(dbRiskRatio * 100) + "% ";
   str_comments += "    Vol(m15): " + volume_15 + " lot. " + get_profit_today();

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
   int total_fx_size = ArraySize(arr_symbol);

   uint line_length = 380;
   string hyphen_line = "";
   for(uint j = 0; j < line_length; j++)
      hyphen_line += "-";

   string msg_list_h4[];
   string msg_list_h1[];
   string msg_list_15[];
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
         Exit_Trade(symbol);

      string trend_macd_h4 = get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4);

      string trend_vector_ma6_h1 = get_trend_by_vector_ma(symbol, PERIOD_H1, 6);
      string trend_vector_ma6_h4 = get_trend_by_vector_ma(symbol, PERIOD_H4, 6);
      string trend_vector_ma6_d1 = get_trend_by_vector_ma(symbol, PERIOD_D1, 6);

      string switch_trend_d1_ma69 = get_switch_trend_by_ma(symbol, PERIOD_D1, 6, 9);
      string switch_trend_h4_ma69 = get_switch_trend_by_ma(symbol, PERIOD_H4, 6, 9);

      string switch_trend_seq_15 = get_swith_trend_by_seq_6_10_20_50(symbol, PERIOD_M15);
      string switch_trend_seq_h1 = get_swith_trend_by_seq_6_10_20_50(symbol, PERIOD_H1);
      string switch_trend_seq_h4 = get_swith_trend_by_seq_6_10_20_50(symbol, PERIOD_H4);

      string switch_trend_h4_ma6_20 = get_swith_trend_by_heiken_and_ma_X_Y(symbol, PERIOD_H4, 6, 20);
      string switch_trend_h1_ma6_20 = get_swith_trend_by_heiken_and_ma_X_Y(symbol, PERIOD_H1, 6, 20);

      string switch_trend_hei_h4_6_1 = get_swith_trend_by_heiken_6_1(symbol, PERIOD_H4);
      string switch_trend_hei_h1_6_1 = get_swith_trend_by_heiken_6_1(symbol, PERIOD_H1);

      if(!(has_position_buy || has_position_sel))
        {
         if(switch_trend_hei_h4_6_1 != "")
           {
            int msg_index = ArraySize(msg_list_h4);
            ArrayResize(msg_list_h4, msg_index + 1);
            string msg = "(HEIKEN) H4 " + AppendSpaces(switch_trend_hei_h4_6_1, 5) + AppendSpaces(tradingview_symbol);
            msg_list_h4[msg_index] = msg;
           }
         else
            if(switch_trend_seq_h4 != "")
              {
               int msg_index = ArraySize(msg_list_h4);
               ArrayResize(msg_list_h4, msg_index + 1);
               string msg = "(SEQ) H4 " + AppendSpaces(switch_trend_seq_h4, 5) + AppendSpaces(tradingview_symbol);
               msg_list_h4[msg_index] = msg;
              }
            else
               if(switch_trend_hei_h4_6_1 != "")
                 {
                  int msg_index = ArraySize(msg_list_h4);
                  ArrayResize(msg_list_h4, msg_index + 1);
                  string msg = "(Ma20) H4 " + AppendSpaces(switch_trend_hei_h4_6_1, 5) + AppendSpaces(tradingview_symbol);
                  msg_list_h4[msg_index] = msg;
                 }

         if(switch_trend_hei_h1_6_1 != "" && switch_trend_hei_h1_6_1 == trend_vector_ma6_h4)
           {
            int msg_index = ArraySize(msg_list_h1);
            ArrayResize(msg_list_h1, msg_index + 1);
            string msg = "(HEIKEN) H1 " + AppendSpaces(switch_trend_hei_h1_6_1, 5) + AppendSpaces(tradingview_symbol);
            msg_list_h1[msg_index] = msg;
           }
         else
            if(switch_trend_seq_h1 != "" && switch_trend_seq_h1 == trend_vector_ma6_h4)
              {
               int msg_index = ArraySize(msg_list_h1);
               ArrayResize(msg_list_h1, msg_index + 1);
               string msg = "(SEQ) H1 " + AppendSpaces(switch_trend_seq_h1, 5) + AppendSpaces(tradingview_symbol);
               msg_list_h1[msg_index] = msg;
              }
            else
               if(switch_trend_hei_h1_6_1 != "" && switch_trend_hei_h1_6_1 == trend_vector_ma6_h4)
                 {
                  int msg_index = ArraySize(msg_list_h1);
                  ArrayResize(msg_list_h1, msg_index + 1);
                  string msg = "(Ma20) H1 " + AppendSpaces(switch_trend_hei_h1_6_1, 5) + AppendSpaces(tradingview_symbol);
                  msg_list_h1[msg_index] = msg;
                 }

         if(switch_trend_seq_15 != "" && switch_trend_seq_15 == trend_vector_ma6_h4)
           {
            int msg_index = ArraySize(msg_list_15);
            ArrayResize(msg_list_15, msg_index + 1);
            string msg = "(SEQ) 15 " + AppendSpaces(switch_trend_seq_15, 5) + AppendSpaces(tradingview_symbol);
            msg_list_15[msg_index] = msg;
           }
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

         if(price <= lo_d1 && price <= lo_h4)
            bb_alert = true;
        }

      if(price >= hi_d1 || price >= hi_h4)
        {
         bb_allow_sel = true;

         bb_note += (price >= hi_d1) ? "D1":"";
         bb_note += (price >= hi_h4) ? "H4":"";
         bb_note += "(S)";

         if(price >= hi_d1 && price >= hi_h4)
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
      if((amp_cycle_weeks / week_amp) >= 4)
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
         trade_by_amp = AppendSpaces(trend_by_amp_weeks, 7);

         if(trend_by_amp_weeks == TREND_BUY)
            trade_by_amp += "tba(" + format_double_to_string((rate_amp_buy / week_amp), 2) + ")";

         if(trend_by_amp_weeks == TREND_SEL)
            trade_by_amp += "tba(" + format_double_to_string((rate_amp_sel / week_amp), 2) + ")";

         if(bb_alert && ((trend_by_amp_weeks == TREND_BUY && bb_allow_buy) || (trend_by_amp_weeks == TREND_SEL && bb_allow_sel)))
           {
            string msg = OPEN_TRADE + bb_note + " ByAmp13W(BB): " + trend_by_amp_weeks + "    " + symbol + "    " + str_volume;
            SendTelegramMessage(symbol, trend_by_amp_weeks, msg);
           }
        }

      //--------------------------------------------------------------------------------------------------

      double rate_buy = (rate_amp_buy / week_amp);
      double rate_sel = (rate_amp_sel / week_amp);

      string tba_d1 = "";
      tba_d1 += "   Rm(B): " + format_double_to_string(rate_sel, 2);
      tba_d1 += "   Rm(S): " + format_double_to_string(rate_buy, 2);

      if(bb_alert)
        {
         string trend_bb = "";
         if(bb_allow_buy)
            trend_bb = TREND_BUY;
         if(bb_allow_sel)
            trend_bb = TREND_SEL;

         string msg = OPEN_TRADE + bb_note + " ByBB: " + trend_bb + "    " + symbol + "    " + str_volume;
         msg += "rate_sel:rate_buy("+format_double_to_string(rate_sel, 2) + ":" + format_double_to_string(rate_buy, 2) + ")";
         SendTelegramMessage(symbol, trend_bb, msg);
        }

      string remain = "";
      if(has_position_buy)
         remain += " Rm(B)(" + format_double_to_string(rate_sel, 2) + ")";
      if(has_position_sel)
         remain += " Rm(S)(" + format_double_to_string(rate_buy, 2) + ")";

      string switch_d1 = "";
      if(switch_trend_d1_ma69 != "")
        {
         switch_d1 = switch_d1 = "SwitchMa69: " + switch_trend_d1_ma69;
        }
      else
        {
         switch_d1 = get_candle_switch_trend_by_ma(symbol, PERIOD_D1, 10);
         if(switch_d1 != "")
            switch_d1 = "SwitchMa10: " + switch_d1;
         else
           {
            switch_d1 = get_candle_switch_trend_by_ma(symbol, PERIOD_D1, 6);
            if(switch_d1 != "")
               switch_d1 = "SwitchMa 6: " + switch_d1;
           }
        }

      switch_d1 = AppendSpaces(switch_d1, 16) + " | ";

      if(switch_trend_seq_15 != "")
        {
         switch_trend_seq_15 = "   Seq(15): " + AppendSpaces(switch_trend_seq_15, 5);
         if(switch_trend_seq_15 == trend_vector_ma6_h1)
            switch_trend_seq_15 += "(+H1)";
         if(switch_trend_seq_15 == trend_vector_ma6_h4)
            switch_trend_seq_15 += "(+H4)";
        }

      if(switch_trend_seq_h1 != "")
        {
         switch_trend_seq_h1 = "   Seq(H1): " + AppendSpaces(switch_trend_seq_h1, 5);
         if(switch_trend_seq_h1 == trend_vector_ma6_h4)
            switch_trend_seq_h1 += "(+H4)";
         if(switch_trend_seq_h1 == trend_vector_ma6_d1)
            switch_trend_seq_h1 += "(+D1)";
        }

      if(switch_trend_seq_h4 != "")
        {
         switch_trend_seq_h4 = "   Seq(H4): " + AppendSpaces(switch_trend_seq_h4, 5);
         if(switch_trend_seq_h1 == trend_vector_ma6_h1)
            switch_trend_seq_h4 += "(+H1)";
         if(switch_trend_seq_h1 == trend_vector_ma6_d1)
            switch_trend_seq_h4 += "(+D1)";
        }

      double swap_long  = SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG);
      double swap_short  = SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT);

      string msg_swith_trend_folow_macd_h4 = "";
      if(trend_macd_h4 != "")
        {
         if(trend_macd_h4 == switch_trend_h4_ma69)
            msg_swith_trend_folow_macd_h4 += "   h4_ma69";

         if(trend_macd_h4 == switch_trend_seq_h4)
            msg_swith_trend_folow_macd_h4 += "   seq_h4";

         if(trend_macd_h4 == switch_trend_seq_h1)
            msg_swith_trend_folow_macd_h4 += "   seq_h1";

         if(trend_macd_h4 == switch_trend_seq_15)
            msg_swith_trend_folow_macd_h4 += "   seq_15";

         string msg_sw_hei_ma610 = "";
         if(switch_trend_h4_ma6_20 != "")
            msg_sw_hei_ma610 = "   h4_620";
         if(switch_trend_h1_ma6_20 != "")
            msg_sw_hei_ma610 = "   h1_620";

         if(msg_swith_trend_folow_macd_h4 != "" || msg_sw_hei_ma610 != "")
            msg_swith_trend_folow_macd_h4 = "MacdH4(" + AppendSpaces(trend_macd_h4, 4) + ")" + msg_swith_trend_folow_macd_h4 + msg_sw_hei_ma610;
        }

      string line = "";
      line += "." + AppendSpaces((string)(index + 1), 2, false) + "   ";
      line += AppendSpaces(tradingview_symbol) + AppendSpaces(format_double_to_string(price, digits-1), 8) + " | ";
      line += AppendSpaces("Swap(B:" + AppendSpaces((string)swap_long, 7, false) + ", S:" + AppendSpaces((string)swap_short, 7, false) + ")", 30);

      line += str_volume + "/" + AppendSpaces(format_double_to_string(week_amp, digits), 8, false) + "  |  ";
      line += AppendSpaces(str_count_trade, 42) + " | ";
      line += AppendSpaces(msg_swith_trend_folow_macd_h4, 45);
      line += AppendSpaces(switch_trend_seq_15 + switch_trend_seq_h1 + switch_trend_seq_h4, 45);
      line += " | "  + switch_d1 + AppendSpaces(remain, 15) + AppendSpaces(trade_by_amp + bb_note, 25);

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
   int h4_array_size = ArraySize(msg_list_h4);
   int h1_array_size = ArraySize(msg_list_h1);
   int m15_array_size = ArraySize(msg_list_15);

   ArrayResize(msg_list_h4, h4_array_size + 1 + h1_array_size + 1 + m15_array_size);

   msg_list_h4[h4_array_size] = "";

   for(int i = 0; i < h1_array_size; i++)
     {
      h4_array_size += 1;
      msg_list_h4[h4_array_size] = msg_list_h1[i];
     }

   h4_array_size += 1;
   msg_list_h4[h4_array_size] = "";

   for(int i = 0; i < m15_array_size; i++)
     {
      h4_array_size += 1;
      msg_list_h4[h4_array_size] = msg_list_15[i];
     }

   Draw_Bottom_Msg(msg_list_h4);
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
void Draw_Bottom_Msg(string& msgs[])
  {
   double haOpen1, haClose1, haHigh1, haLow1;
   CalculateHeikenAshi(_Symbol, PERIOD_CURRENT, 1, haOpen1, haClose1, haHigh1, haLow1);
   string pre_haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(_Symbol, PERIOD_CURRENT, 0, haOpen0, haClose0, haHigh0, haLow0);
   string cur_haTrend = haOpen0 < haClose0 ? TREND_BUY : TREND_SEL;

   bool hide_buy = false;
   bool hide_sel = false;
   if(cur_haTrend == TREND_BUY && pre_haTrend == TREND_BUY)
      hide_sel = true;
   if(cur_haTrend == TREND_SEL && pre_haTrend == TREND_SEL)
      hide_buy = true;

   color clrTrade = clrGray;
   if(cur_haTrend == TREND_BUY)
      clrTrade = clrCadetBlue;
   if(cur_haTrend == TREND_SEL)
      clrTrade = clrFireBrick;

   int start_y = 50;
   createButton(BtnTrade,        "Trade " + get_current_timeframe_to_string(), 30, start_y + 30*0, 85, 25, clrTrade,     8);

   if(hide_buy == false)
      createButton(BtnOrderBuy,  "Order " + get_current_timeframe_to_string(), 30, start_y + 30*1, 85, 25, clrCadetBlue, 8);
   else
      ObjectDelete(0, BtnOrderBuy);

   if(hide_sel == false)
      createButton(BtnOrderSell, "Order " + get_current_timeframe_to_string(), 30, start_y + 30*2, 85, 25, clrFireBrick, 8);
   else
      ObjectDelete(0, BtnOrderSell);

   createButton(BtnClose,        "Close " + get_current_timeframe_to_string(), 30, start_y + 30*3, 85, 25, clrGray,      8);

//-----------------------------------------------------------------------

   int init_x = 30;
   int init_y = 180;
   int size = ArraySize(msgs);
   for(int index = 0; index < size; index++)
     {
      int x = init_x;
      int y = init_y;

      if(index >= 30)
        {
         x = init_x + 3*180;
         y = init_y + ((40-index-2) * 25);
        }
      else
         if(index >= 20)
           {
            x = init_x + 2*180;
            y = init_y + ((30-index-1) * 25);
           }
         else
            if(index >= 10)
              {
               x = init_x + 1*180;
               y = init_y + ((20-index-1) * 25);
              }
            else
              {
               x = init_x;
               y = init_y + (index * 25);
              }

      string msg = msgs[index];
      if(msg != "")
        {
         string button_name = "btn_dkd_" + (string) index;
         createButton(button_name, AppendSpaces(msg, 27), x, y, 150, 20, clrGray, 6);
        }
     }

   ChartRedraw();
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
         Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            string tradingview_symbol = symbol;
            StringReplace(tradingview_symbol, ".cash", "");
            if(StringFind(buttonLabel, tradingview_symbol) >= 0)
              {
               ChartOpen(symbol, PERIOD_H4);
               ChartRedraw();
              }
           }

        }

      double dic_top_price;
      double dic_amp_w;
      double dic_avg_candle_week;
      double dic_amp_init_d1;
      GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
      double week_amp = dic_amp_w;
      double volume = dblLotsRisk(_Symbol, week_amp, calcRisk());

      string cur_trade_prefix = get_prefix_trade_from_current_timeframe();
      //-----------------------------------------------------------------------
      if(sparam == BtnTrade)
        {
         for(int i = PositionsTotal()-1; i >= 0; i--)
           {
            if(m_position.SelectByIndex(i))
              {
               if(toLower(_Symbol) == toLower(m_position.Symbol()))
                 {
                  string trade_from_comment = get_prefix_trade_from_comments(m_position.Comment());
                  if(cur_trade_prefix == trade_from_comment)
                    {
                     Alert(trade_from_comment, "    Position ", m_position.TypeDescription(), "   ", _Symbol, " was opened... profit: ", m_position.Profit());
                     return;
                    }
                 }
              }
           }

         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

         double haOpen1, haClose1, haHigh1, haLow1;
         CalculateHeikenAshi(_Symbol, PERIOD_CURRENT, 0, haOpen1, haClose1, haHigh1, haLow1);
         string haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

         string prefix_trade = "    " +  cur_trade_prefix + "    ";
         double amp_trade_default = get_default_amp_trade(_Symbol, Period());
         //double volume = dblLotsRisk(_Symbol, amp_trade_default, calcRisk());

         double sl = 0.0;
         double tp = 0.0;
         if(haTrend == TREND_BUY)
           {
            sl = price - amp_trade_default;
            tp = price + amp_trade_default*3;
           }
         if(haTrend == TREND_SEL)
           {
            sl = price + amp_trade_default;
            tp = price - amp_trade_default*3;
           }

         sl = NormalizeDouble(sl, digits);
         tp = NormalizeDouble(tp, digits);

         string msg = OPEN_TRADE + "    " + AppendSpaces(haTrend, 5) + prefix_trade + _Symbol + "  vol: " + (string) volume + " lot";
         msg += "  SL: " + (string) sl + "  TP: " + (string) tp;

         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         switch(result)
           {
            case IDYES:
               if(haTrend == TREND_BUY)
                  m_trade.Buy(volume, _Symbol, 0.0, 0.0, tp, cur_trade_prefix);

               if(haTrend == TREND_SEL)
                  m_trade.Sell(volume, _Symbol, 0.0, 0.0, tp, cur_trade_prefix);

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

         string prefix_trade = "    " +  cur_trade_prefix + "    ";
         double amp_trade_default = get_default_amp_trade(_Symbol, Period());
         //double volume = dblLotsRisk(_Symbol, amp_trade_default, calcRisk());

         double lowest = 0.0;
         double higest = 0.0;
         double lowest_close = 0.0;
         double higest_close = 0.0;
         for(int i = 1; i <= 55; i++)
           {
            double close = iClose(_Symbol, PERIOD_H4, i);
            double lowPrice = close;// iLow(symbol, PERIOD_H4, i);
            double higPrice = close;// iHigh(symbol, PERIOD_H4, i);

            if((i == 1) || (lowest > lowPrice))
               lowest = lowPrice;

            if((i == 1) || (higest < higPrice))
               higest = higPrice;

            if(i <= 21)
              {
               if((i == 1) || (lowest_close > lowPrice))
                  lowest_close = lowPrice;

               if((i == 1) || (higest_close < higPrice))
                  higest_close = higPrice;
              }
           }
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

                  if(m_order.Type() == ORDER_TYPE_SELL_LIMIT || m_order.Type() == ORDER_TYPE_SELL || (StringFind(toLower(m_order.TypeDescription()), "sell") >= 0))
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

            double open_price = lowest_close;
            double sl = open_price - amp_trade_default;
            double tp = open_price + amp_trade_default*3;
            if(tp < higest)
               tp = higest;

            open_price = NormalizeDouble(open_price, digits);
            sl = NormalizeDouble(sl, digits);
            tp = NormalizeDouble(tp, digits);

            string msg = OPEN_ORDERS + AppendSpaces(TREND_BUY, 5) + prefix_trade + _Symbol + "  vol: " + (string) volume + " lot";
            msg += "  Open: " + (string) open_price + "  SL: " + (string) sl + "  TP: " + (string) tp;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  Alert(msg+ ".");
                  m_trade.BuyLimit(volume, open_price, _Symbol, 0.0, tp, 0, 0, cur_trade_prefix);
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

            double open_price = higest_close;
            double sl = open_price + amp_trade_default;
            double tp = open_price - amp_trade_default*3;

            open_price = NormalizeDouble(open_price, digits);
            sl = NormalizeDouble(sl, digits);
            tp = NormalizeDouble(tp, digits);

            string msg = OPEN_ORDERS + AppendSpaces(TREND_SEL, 5) + prefix_trade + _Symbol + "  vol: " + (string) volume + " lot";
            msg += "  Open: " + (string) open_price + "  SL: " + (string) sl + "  TP: " + (string) tp;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  Alert(msg+ ".");
                  m_trade.SellLimit(volume, open_price, _Symbol, 0.0, tp, 0, 0, cur_trade_prefix);

                  break;

               case IDNO:
                  break;
              }
           }
        }

      //-----------------------------------------------------------------------
      if(sparam == BtnClose)
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
                  if(cur_trade_prefix == get_prefix_trade_from_comments(comments))
                    {
                     int confirm_result = MessageBox(cur_trade_prefix + "Đóng Position #" + (string) ticket + "   " + m_position.TypeDescription() + "   " + _Symbol + " profit: " + (string) profit + "?", "Confirm", MB_YESNOCANCEL);
                     if(confirm_result == IDYES)
                       {
                        Alert("Position #", ticket, "   ", _Symbol, " was closed... profit: ", profit);
                        m_trade.PositionClose(ticket);
                       }
                    }
              }
           }

         for(int i = OrdersTotal() - 1; i >= 0; i--)
           {
            if(m_order.SelectByIndex(i))
              {
               ulong ticket = OrderGetTicket(i);
               string comments = OrderGetString(ORDER_COMMENT);

               if((toLower(_Symbol) == toLower(m_order.Symbol())))
                  if(cur_trade_prefix == get_prefix_trade_from_comments(comments))
                    {
                     int confirm_result = MessageBox(cur_trade_prefix + " Đóng Order #" + (string) ticket+ "   " + m_order.TypeDescription() + "   " + _Symbol + "   " + comments + "?", "Confirm", MB_YESNOCANCEL);
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
                     Alert(get_vntime(), "   INIT   SL   (BUY) : ", symbol, "   sl_new: ", (string)sl_new);
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
                     Alert(get_vntime(), "   INIT   SL   (SELL): ", symbol, "   sl_new: ", (string)sl_new);
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
bool createButton(string objName, string text, int x, int y, int width, int height, color clrBackground, int font_size = 10)
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
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 999);
   return(true);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_swith_trend_by_heiken_6_1(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[15];
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
string get_swith_trend_by_heiken_and_ma_X_Y(string symbol, ENUM_TIMEFRAMES timeframe, int fast_ma=6, int slow_ma = 10)
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
string get_swith_trend_by_seq_6_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
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
   if(Period() == PERIOD_M15)
      return PREFIX_TRADE_VECHAI_M15;

   if(Period() ==  PERIOD_H1)
      return PREFIX_TRADE_VECHAI_H1;

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

   if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_H1)) >= 0)
      return PREFIX_TRADE_VECHAI_H1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_M15)) >= 0)
      return PREFIX_TRADE_VECHAI_M15;

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
   else
      if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
         return PERIOD_D1;
      else
         if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
            return PERIOD_H4;
         else
            if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_H1)) >= 0)
               return PERIOD_H1;
            else
               if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_M15)) >= 0)
                  return PERIOD_M15;


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
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + "   (GMT: " + current_gmt_hour + "h) ";
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
   if(prefix == PREFIX_TRADE_VECHAI_H1)
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
   if(prefix == PREFIX_TRADE_VECHAI_H1)
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
string get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return "NG";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,50,K);
   CopyBuffer(handle_iStochastic,1,0,50,D);


// Tìm vị trí x thỏa mãn điều kiện
   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   for(int i = 0; i < ArraySize(K) - 1; i++)
     {
      if((K[i] <= D[i] && K[i + 1] >= D[i + 1]) || (K[i] >= D[i] && K[i + 1] <= D[i + 1]))
        {
         // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
         x = i;
         break;
        }
     }

   if(x != -1)
     {
      return (K[0] > D[0] ? TREND_BUY : TREND_SEL) + "(" + (string)(x) + ")"; ;
     }
   else
     {
      return "NG";
     }
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

   if(symbol == "USOIL.cash")
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

   if(symbol == "US500.cash")
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.035;
      amp_w = 60.00;
      avg_candle_week = 593.00;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.07;
      amp_w = 274.5;
      avg_candle_week = 503.15;
      return;
     }

   if(symbol == "US30.cash")
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.04;
      amp_w = 438.76;
      avg_candle_week = 818.86;
      return;
     }

   if(symbol == "UK100.cash")
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

   if(symbol == "FRA40.cash")
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 160;
      amp_w = 117.6866;
      avg_candle_week = 1145.95;
      return;
     }

   if(symbol == "AUS200.cash")
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 236.5;
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

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
