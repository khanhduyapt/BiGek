//+------------------------------------------------------------------+
//|                                                 ZenithTrader.mq5 |
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

string input BOT_NAME = "ZenithTrader";
int input    EXPERT_MAGIC = 20231213;

double dbRiskRatio = 0.05; // Rủi ro 0.01 = 1%
double INIT_EQUITY = 2000.0; // Vốn ban đầu

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string BALAN_ORDER = "BALAN";

string arr_symbol[] = {"XAUUSD", "XAGUSD"
                       ,"BTCUSD" // , "ETHUSD"
                       ,"US30.cash", "US100.cash", "USOIL.cash"
                       ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
                       ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
                       ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
                       ,"NZDCAD", "NZDJPY", "NZDUSD"
                       ,"USDCAD", "USDJPY", "CADJPY", "USDCHF"
                      };

//USDCHF - kq 13.566 - lãi 35%
//USDJPY - kq 12.203 - lãi 22%
//EURJYP - kq 11.241 - lãi 12%
//EURCAD - kq 11.902 - lãi 19%
//EURUSD lãi 23%
//GBPUSD lãi 59.5%
//"USDCHF", "USDJPY", "EURJPY", "EURCAD", "EURUSD", "GBPUSD", "EURGBP"

//DELETE: "AUDCHF", "CHFJPY", "EURCHF", "GBPCHF", "NZDCHF", "CADCHF"

//Debug: ,


string open_trade_today = "";


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
//trade_by_amp_week(_Symbol);
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      trade_by_amp_week(symbol);
     }
  }

//+------------------------------------------------------------------+
void trade_by_amp_week(string symbol)
  {
   double total_profit_today = get_profit_today();

   double dic_top_price;
   double dic_amp_w;
   double dic_lot_size;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
   double week_amp = dic_amp_w;
   double volume = dblLotsRisk(symbol, week_amp, dbRisk());

   double risk = dbRisk();
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   bool is_market_close = IsMarketClose();

   CandleData candle_heiken_h4;
   CountHeikenList(symbol, PERIOD_H4, 1, candle_heiken_h4);

   CandleData candle_heiken_h1;
   CountHeikenList(symbol, PERIOD_H1, 1, candle_heiken_h1);

   bool STOP_TRADE = false;
   if(total_profit_today + INIT_EQUITY*0.3 < 0)
      STOP_TRADE = true;

   string trend_heiken_h4 = candle_heiken_h4.trend;
   string parallel_vector_h4 = trend_of_histogram_vs_signal(symbol, PERIOD_H4, 18, 36, 9);
   string trend_stock_h4 = get_trend_stoc(symbol, PERIOD_H4, 21, 17, 5);

   string str_risk  =  "";
   str_risk += "     Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
   str_risk += "    " + _Symbol + "     Heiken(H4): " + candle_heiken_h4.trend + "     Trade: " + parallel_vector_h4;
   str_risk += "     Verify: " + ((trend_heiken_h4 == parallel_vector_h4) && (trend_heiken_h4 == parallel_vector_h4) ? " OK " : "____") + "\n";

   string message = get_vntime() + str_risk + "\n";
   message += "    Profit Today:" + format_double_to_string(total_profit_today, 2) + "$" + get_volume_cur_symbol();

   if(is_market_close)
     {
      message += "\n(ZenithTrader) Market Close (Sat, Sun, 3 < Vn.Hour < 7)." + (STOP_TRADE? "   STOP ORDERS  " : "   ");

      Comment(message);
     }
   if(is_market_close == false)
     {
      message += "(ZenithTrader) Market Open " + (STOP_TRADE? "   STOP ORDERS  " : "   ");
      Comment(message);
     }

//if(STOP_TRADE)
//   return;
//------------------------------------------------------------------

   int maLength = 100;
   double low_h4[];
   double hig_h4[];
   ArrayResize(low_h4, maLength);
   ArrayResize(hig_h4, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      low_h4[i] = iLow(symbol, PERIOD_H4, i);
      hig_h4[i] = iHigh(symbol, PERIOD_H4, i);
     }

   double min_20_candle = FindMinPrice(low_h4);
   double max_20_candle = FindMaxPrice(hig_h4);

   int count_order_buy = 0;
   int count_order_sel = 0;
   string lowcase_symbol = toLower(symbol);
//------------------------------------------------------------------
   double total_buy = 0;
   double total_sel = 0;
   double total_profit = 0;

   int count_possion_buy = 0;
   int count_possion_sel = 0;

   ulong max_ticket_buy = 0;
   ulong max_ticket_sel = 0;
   double best_entry_buy = 0;
   double best_entry_sel = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         // --------------------------------------------------------
         ulong ticket = PositionGetTicket(i);
         long type = PositionGetInteger(POSITION_TYPE);
         double profit = PositionGetDouble(POSITION_PROFIT);
         double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
         total_profit += profit;
         // --------------------------------------------------------
         if(type == POSITION_TYPE_BUY)
           {
            count_possion_buy += 1;
            total_buy+=profit;
            if(max_ticket_buy < ticket)
              {
               max_ticket_buy = ticket;
               best_entry_buy = price_open;
              }
           }

         if(type == POSITION_TYPE_SELL)
           {
            count_possion_sel += 1;
            total_sel += profit;
            if(max_ticket_sel < ticket)
              {
               max_ticket_sel = ticket;
               best_entry_sel = price_open;
              }
           }
        }
     } //for
//------------------------------------------------------------------

   double init_volume = dblLotsRisk(symbol, week_amp, dbRisk());

// Cứu SELL với điều kiện giá đã di chuyển ít nhất 1 đoạn week_amp so với  giá vào lệnh lớn nhất:
   bool allow_push_sel = (price - MathMax(best_entry_buy, best_entry_sel)) > week_amp;
   bool allow_push_buy = (MathMax(best_entry_buy, best_entry_sel) - price) > week_amp;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
   if(total_profit + risk < 0)
     {
      // Thằng SEL gây lỗi lần 1.
      if(count_possion_sel == 1 && count_possion_buy == 0 && (total_sel + risk <= 0))
        {
         //Cân lệnh đầu tiên cứu lệnh SEL nếu tất cả xu hướng vẫn ủng hộ phe BUY
         if(trend_heiken_h4 == TREND_BUY && parallel_vector_h4 == TREND_BUY && trend_stock_h4 == TREND_BUY)
           {
            trade_x1(symbol, TREND_BUY, week_amp, init_volume, BALAN_ORDER, 2);
            return;
           }

         // Nếu phe BUY suy yếu, và phe SELL thắng thế, thì đánh x2 volume lệnh sell đầu.
         if(allow_push_sel && trend_heiken_h4 == TREND_SEL && parallel_vector_h4 == TREND_SEL && trend_stock_h4 == TREND_SEL)
           {
            trade_x1(symbol, TREND_SEL, week_amp, init_volume, "PUSH", 3);
            return;
           }
        }

      // Giữ lệnh âm 1R tiếp tục cho đến khi phe BUY suy yếu, cứu lần 2:
      if(count_possion_sel == 1 && count_possion_buy == 1 && (total_sel + risk <= 0))
        {
         if(allow_push_sel && trend_heiken_h4 == TREND_SEL && parallel_vector_h4 == TREND_SEL && trend_stock_h4 == TREND_SEL)
           {
            trade_x1(symbol, TREND_SEL, week_amp, init_volume, "PUSH", 4);
            return;
           }
        }

      // Giữ lệnh âm 3R, chờ cho thị trường đi thêm 1 khoảng week_amp thì nhồi lệnh 3:
      if(count_possion_sel == 2 && count_possion_buy == 1 && (total_sel + risk <= 0))
        {
         if(allow_push_sel && trend_heiken_h4 == TREND_SEL && parallel_vector_h4 == TREND_SEL && trend_stock_h4 == TREND_SEL)
           {
            trade_x1(symbol, TREND_SEL, week_amp, init_volume, "PUSH", 5);
            return;
           }
        }

      // Giữ lệnh âm 6R, chờ cho thị trường đi thêm 1 khoảng week_amp thì nhồi lệnh 4:
      if(count_possion_sel == 3 && count_possion_buy == 1 && (total_sel + risk <= 0))
        {
         if(allow_push_sel && trend_heiken_h4 == TREND_SEL && parallel_vector_h4 == TREND_SEL && trend_stock_h4 == TREND_SEL)
           {
            trade_x1(symbol, TREND_SEL, week_amp, init_volume, "PUSH", 6);
            return;
           }
        }

      if(count_possion_sel == 4 && count_possion_buy == 1 && (total_sel + risk <= 0))
        {
         if(allow_push_sel && trend_heiken_h4 == TREND_SEL && parallel_vector_h4 == TREND_SEL && trend_stock_h4 == TREND_SEL)
           {
            trade_x1(symbol, TREND_SEL, week_amp, init_volume*3, "PUSH", 7);
            return;
           }
        }

      //------------------------------------------------------------------------------
      //------------------------------------------------------------------------------
      //------------------------------------------------------------------------------
      // Thằng BUY gây lỗi lần 1.
      if(count_possion_sel == 0 && count_possion_buy == 1 && (total_buy + risk <= 0))
        {
         //Cân lệnh đầu tiên cứu lệnh BUY nếu tất cả xu hướng vẫn ủng hộ phe SEL
         if(trend_heiken_h4 == TREND_SEL && parallel_vector_h4 == TREND_SEL && trend_stock_h4 == TREND_SEL)
           {
            trade_x1(symbol, TREND_SEL, week_amp, init_volume, BALAN_ORDER, 2);
            return;
           }

         // Nếu phe SELL suy yếu, và phe BUY thắng thế, thì đánh x2 volume lệnh buy đầu.
         if(allow_push_buy && trend_heiken_h4 == TREND_BUY && parallel_vector_h4 == TREND_BUY && trend_stock_h4 == TREND_BUY)
           {
            trade_x1(symbol, TREND_BUY, week_amp, init_volume, "PUSH", 3);
            return;
           }
        }

      // Giữ lệnh âm 1R tiếp tục cho đến khi phe SEL suy yếu,
      if(count_possion_sel == 1 && count_possion_buy == 1 && (total_buy + risk <= 0))
        {
         if(allow_push_buy && trend_heiken_h4 == TREND_BUY && parallel_vector_h4 == TREND_BUY && trend_stock_h4 == TREND_BUY)
           {
            trade_x1(symbol, TREND_BUY, week_amp, init_volume, "PUSH", 4);
            return;
           }
        }

      if(count_possion_sel == 1 && count_possion_buy == 2 && (total_buy + risk <= 0))
        {
         if(allow_push_buy && trend_heiken_h4 == TREND_BUY && parallel_vector_h4 == TREND_BUY && trend_stock_h4 == TREND_BUY)
           {
            trade_x1(symbol, TREND_BUY, week_amp, init_volume, "PUSH", 5);
            return;
           }
        }

      if(count_possion_sel == 1 && count_possion_buy == 3 && (total_buy + risk <= 0))
        {
         if(allow_push_buy && trend_heiken_h4 == TREND_BUY && parallel_vector_h4 == TREND_BUY && trend_stock_h4 == TREND_BUY)
           {
            trade_x1(symbol, TREND_BUY, week_amp, init_volume, "PUSH", 6);
            return;
           }
        }

      if(count_possion_sel == 1 && count_possion_buy == 3 && (total_buy + risk <= 0))
        {
         if(allow_push_buy && trend_heiken_h4 == TREND_BUY && parallel_vector_h4 == TREND_BUY && trend_stock_h4 == TREND_BUY)
           {
            trade_x1(symbol, TREND_BUY, week_amp, init_volume*3, "PUSH", 7);
            return;
           }
        }
     }
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//---------------------------------------TRAILING_STOP---------------------------------------
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         // --------------------------------------------------------
         ulong ticket = PositionGetTicket(i);
         long type = PositionGetInteger(POSITION_TYPE);
         // --------------------------------------------------------
         double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
         double price_sl = PositionGetDouble(POSITION_SL);
         double price_tp = PositionGetDouble(POSITION_TP);
         string pos_comments = PositionGetString(POSITION_COMMENT);

         if(type == POSITION_TYPE_BUY && (price - price_open > week_amp) && (price_sl != price_open))
           {
            m_trade.PositionModify(ticket, price_open, price_tp);
            Alert("MODIFY_POS   (BUY): ", symbol);
           }
         if(type == POSITION_TYPE_SELL && (price_open - price > week_amp) && (price_sl != price_open))
           {
            m_trade.PositionModify(ticket, price_open, price_tp);
            Alert("MODIFY_POS   (SEL): ", symbol);
           }
        }
     } //for


   if((count_possion_buy > 0) || (count_order_buy > 0))
      CleanTrade(symbol);

   if((is_market_close == false) && ((count_possion_buy == 0 && parallel_vector_h4 == TREND_BUY) || (count_possion_sel == 0 && parallel_vector_h4 == TREND_SEL)))
     {
      if(parallel_vector_h4 == trend_stock_h4 && parallel_vector_h4 == trend_heiken_h4 && (candle_heiken_h4.count < 10))
        {
         trade_x1(symbol, parallel_vector_h4, week_amp, init_volume, "INIT", 1);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanTrade(string symbol)
  {
   double total_profit = 0;
   string possion_comments = "";
   string order_comments = "";
   string type = "";

   int count_possion = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         string trading_symbol = toLower(m_position.Symbol());
         if(toLower(symbol) == trading_symbol)
           {
            if((toLower(symbol) == trading_symbol) && (StringFind(toLower(m_position.Comment()), "sign_") >= 0))
              {
               total_profit += m_position.Profit();
              }
           }
        }
     } //for

   double risk = dbRisk();
   if(total_profit > risk)
     {
      ClosePosition(symbol, TREND_BUY);
      CloseOrders(symbol, TREND_BUY);
      ClosePosition(symbol, TREND_SEL);
      CloseOrders(symbol, TREND_SEL);
     }
  }

//+------------------------------------------------------------------+
bool trade_x1(string symbol, string trade_trend, double week_amp, double init_volume, string note, int trade_no)
  {
   if(is_open_this_candle_h4(symbol))
      return true;
   bool has_trade = false;

   if(trade_trend == "")
      return false;

   bool allow_trade_now = is_stock_allow_trade_now(symbol, PERIOD_M15, trade_trend, 3,3,3, true);
   if(allow_trade_now == false)
      return false;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double amp_tp = week_amp*2/3;
   if(trade_no > 1)
      amp_tp = week_amp;

   double en_buy_1 = price;
   double tp_buy_1 = price + amp_tp;
   double sl_buy_e = 0.0;

   double en_sel_1 = price;
   double tp_sel_1 = price - week_amp;
   double sl_sel_e = 0.0;

   if(BALAN_ORDER == note)
     {
      tp_buy_1= 0.0;
      tp_sel_1= 0.0;
     }

//------------------------------------------
   if(trade_trend == TREND_BUY)
     {
      has_trade = true;
      add_open_trade_today(symbol);

      m_trade.Buy(init_volume, symbol, 0.0, sl_buy_e, tp_buy_1, note + "_SIGN_BUY_" + (string)trade_no);

      Alert(get_vntime(), "  BUY: ", symbol, "   note:", note);
     }
//------------------------------------------
   if(trade_trend == TREND_SEL)
     {
      has_trade = true;
      add_open_trade_today(symbol);

      m_trade.Sell(init_volume, symbol, 0.0, sl_sel_e, tp_sel_1, note + "_SIGN_SELL_" + (string)trade_no);

      Alert(get_vntime(), "  SELL: ", symbol, "   note:", note);
     }
//------------------------------------------
   return has_trade;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int originalLength = StringLen(originalString);

// Nếu độ dài của chuỗi lớn hơn 1000, cắt bỏ phần đầu
   if(originalLength > 1000)
     {
      int startIndex = originalLength - 1000; // Chỉ số bắt đầu để giữ lại 1000 ký tự sau cùng
      return StringSubstr(originalString, startIndex, 1000);
     }

// Nếu độ dài không vượt quá 1000, giữ lại nguyên chuỗi
   return originalString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_open_trade_today(string symbol)
  {
   open_trade_today += (string)iTime(symbol, PERIOD_H4, 0) + "_"+ symbol + ";";

   CutString(open_trade_today);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_open_this_candle_h4(string symbol)
  {
   string key = (string)iTime(symbol, PERIOD_H4, 0) + "_"+ symbol + ";";

   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string switch_trend_by_histogram(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal= 9)
  {
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return "___";
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double m_histogarm_1 = m_buff_MACD_main[1];
   double m_histogarm_2 = m_buff_MACD_main[2];
   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[1];
//-------------------------------------------------
   if((m_histogarm_1 > 0) && (0 > m_histogarm_2) && (m_histogarm_1 > m_signal_1) && (m_histogarm_2 > m_signal_2))
      return TREND_BUY;

//-------------------------------------------------
   if((m_histogarm_1 < 0) && (0 < m_histogarm_2) && (m_histogarm_1 < m_signal_1) && (m_histogarm_2 < m_signal_2))
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
string trend_of_histogram_vs_signal(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal = 9)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return "____";
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double main_black_1    = m_buff_MACD_main[1];
   double main_black_2    = m_buff_MACD_main[2];

   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[2];
//-------------------------------------------------
   if((main_black_1 > main_black_2) && (m_signal_1 > m_signal_2) && (main_black_2 > m_signal_1))
      return TREND_BUY;

   if((main_black_1 < main_black_2) && (m_signal_1 < m_signal_2) && (main_black_2 < m_signal_1))
      return TREND_SEL;

   return "____";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string trend_by_vector_signal(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal = 9)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double main_black    = m_buff_MACD_main[1];
   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[2];
//-------------------------------------------------
   if(main_black > m_signal_1 && m_signal_1 > m_signal_2)
      return TREND_BUY;

   if(main_black < m_signal_1 && m_signal_1 < m_signal_2)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string trend_parallel_vector_macd(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal = 9)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double main_black_1 = m_buff_MACD_main[1];
   double main_black_2 = m_buff_MACD_main[2];

   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[2];
//-------------------------------------------------
   if((m_signal_1 > 0) && (main_black_1 > m_signal_1) && (main_black_1 > main_black_2) && (m_signal_1 > m_signal_2))
      return TREND_BUY;

   if((m_signal_1 < 0) && (main_black_1 < m_signal_1) && (main_black_1 < main_black_2) && (m_signal_1 < m_signal_2))
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
string trend_by_signal_of_macd_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal = 9)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double main_black    = m_buff_MACD_main[1];

   double m_signal_1 = m_buff_MACD_signal[1];
//-------------------------------------------------
   if((m_signal_1 > 0) && (main_black > 0))
     {
      return TREND_BUY;
     }
//-------------------------------------------------
   if((m_signal_1 < 0) && (main_black < 0))
     {
      return TREND_SEL;
     }
//-------------------------------------------------
   return "";
  }


//+------------------------------------------------------------------+
bool is_stock_allow_trade_now(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int periodK, int periodD, int slowing, bool is_require_80_20)
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

   if(is_require_80_20)
     {
      if((find_trend == TREND_BUY) && (black_K <= 80 || red_D <= 80))
         return true;

      if((find_trend == TREND_SEL) && (black_K >= 80 || red_D >= 80))
         return true;
     }
   else
     {
      if((find_trend == TREND_BUY) && (black_K >= red_D))
         return true;

      if((find_trend == TREND_SEL) && (black_K <= red_D))
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_stoc(string symbol, ENUM_TIMEFRAMES timeframe, int periodK = 8, int periodD = 5, int slowing = 3)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return (string) timeframe + "_invalid";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "----";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK = 21, int periodD = 17, int slowing = 5)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return 50;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,50,K);
   CopyBuffer(handle_iStochastic,1,0,50,D);

   double black_K = K[0];
   double red_D = D[0];

// Tìm vị trí x thỏa mãn điều kiện
   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   for(int i = 0; i < ArraySize(K) - 1; i++)
     {
      if((K[i] < D[i] && K[i + 1] > D[i + 1])
         || (K[i] > D[i] && K[i + 1] < D[i + 1]))
        {
         // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
         x = i;
         break;
        }
     }


   if(x != -1)
     {
      return x;
     }
   else
     {
      return 50;
     }
  }
//+------------------------------------------------------------------+
string get_short_note(string note)
  {
   string short_note = note;
   StringReplace(short_note, "ma10_w1", "w");
   StringReplace(short_note, "heiken_w1", "");
   StringReplace(short_note, "heiken_w0", "");

   StringReplace(short_note, "ma10_d1", "_d");
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

//+------------------------------------------------------------------+
//|                                                                  |
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

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;
   string gmt = "   (GMT: " + ((current_gmt_hour < 10) ? "0" + (string) current_gmt_hour : (string) current_gmt_hour) + "h) ";

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + gmt;
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
   if(dtw.hour == 6)
     {
      return true; // đóng bot do thị trường giật mạnh, 13hvn.
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
void ClosePosition(string symbol, string trading_trend)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         long type = PositionGetInteger(POSITION_TYPE);
         if(trading_trend == TREND_BUY && type == POSITION_TYPE_SELL)
            continue;
         if(trading_trend == TREND_SEL && type == POSITION_TYPE_BUY)
            continue;

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
void CloseOrders(string symbol, string trading_trend)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         long type = OrderGetInteger(ORDER_TYPE);
         if(trading_trend == TREND_BUY && type == ORDER_TYPE_SELL_LIMIT)
            continue;
         if(trading_trend == TREND_SEL && type == ORDER_TYPE_BUY_LIMIT)
            continue;

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

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
