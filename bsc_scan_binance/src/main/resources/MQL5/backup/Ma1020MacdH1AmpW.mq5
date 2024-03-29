//+------------------------------------------------------------------+
//|                                             Ma1020MacdH1AmpW.mq5 |
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

string input BOT_NAME = "ZenithTrader_XAUUSD";
int input    EXPERT_MAGIC = 20231213;

double dbRiskRatio = 0.01; // Rủi ro 0.01 = 1%
double INIT_EQUITY = 1000.0; // Vốn ban đầu

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string arr_symbol[] = {"XAUUSD", "XAGUSD"
                       ,"BTCUSD"
                       ,"US30.cash", "US100.cash", "USOIL.cash"
                       ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
                       ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
                       ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
                       ,"NZDCAD", "NZDJPY", "NZDUSD"
                       ,"USDCAD", "USDJPY", "CADJPY"

                       , "USDCHF", "CADCHF", "CHFJPY", "EURCHF", "GBPCHF", "AUDCHF", "NZDCHF"
                      };

string open_trade_today = "";


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);

// printf(BOT_NAME + " initialized ");

   return(INIT_SUCCEEDED);
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//Trade_by_Ma1020MacdH1AmpW(_Symbol);

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      Trade_by_Ma1020MacdH1AmpW(symbol);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade_by_Ma1020MacdH1AmpW(string symbol)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_amp_w_2;
   double dic_avg_candle_week;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_amp_w_2, dic_avg_candle_week);
   double week_amp = dic_amp_w_2;

   double risk = dbRisk();
   double volume = dblLotsRisk(symbol, week_amp, risk);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   bool is_market_close = IsMarketClose();

   CandleData candle_heiken_h4;
   CountHeikenList(symbol, PERIOD_H4, 1, candle_heiken_h4);

   string str_risk  =  "";
   str_risk += "     Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
   str_risk += "    " + _Symbol + "     Heiken(H4): " + candle_heiken_h4.trend + "\n";

   str_risk += "_____________________________________________________________________________________________________________";
   str_risk += "    Amp(W): " + (string) week_amp;
   string message = get_vntime() + str_risk + "\n";
   message += "Profit Today:" + format_double_to_string(get_profit_today(), 2) + "$" + get_volume_cur_symbol();

   if(is_market_close)
     {
      message += "\n(" + BOT_NAME + ") Market Close (Sat, Sun, 3 < Vn.Hour < 7).";
      Comment(message);
     }
   else
     {
      message += "\n(" + BOT_NAME + ") Market Open";
      Comment(message);
     }
//----------------------------------------------------------------------------------------------------------------------------
   double profit = 0;
   int count_order_buy = 0;
   int count_order_sel = 0;
   int count_possion_buy = 0;
   int count_possion_sel = 0;
   int count_total_trade = 0;

   string lowcase_symbol = toLower(symbol);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      if(lowcase_symbol == order_symbol)
        {
         count_total_trade = count_total_trade + 1;

         long type = OrderGetInteger(ORDER_TYPE);
         if(type == ORDER_TYPE_BUY_LIMIT)
           {
            count_order_buy += 1;
           }
         if(type == ORDER_TYPE_SELL_LIMIT)
           {
            count_order_sel += 1;
           }
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         count_total_trade = count_total_trade + 1;
         // --------------------------------------------------------
         ulong ticket = PositionGetTicket(i);
         profit += PositionGetDouble(POSITION_PROFIT);

         // --------------------------------------------------------
         long type = PositionGetInteger(POSITION_TYPE);
         if(type == POSITION_TYPE_BUY)
           {
            count_possion_buy += 1;
           }

         if(type == POSITION_TYPE_SELL)
           {
            count_possion_sel += 1;
           }
         // --------------------------------------------------------
        }
     } //for
//----------------------------------------------------------------------------------------------------------------------------
   string trend_signal_h4 = get_trend_by_signal_vs_zero(symbol,PERIOD_H4, 12, 26, 9);

//----------------------------------------------------------------------------------------------------------------------------
   if(count_total_trade > 0)
      CleanTrade(symbol);

   if((count_possion_buy > 0) && (candle_heiken_h4.trend == TREND_SEL))
     {
      ClosePositionTrend(symbol, TREND_BUY);
      CloseOrdersTrend(symbol, TREND_BUY);
     }
   if((count_possion_sel > 0) && (candle_heiken_h4.trend == TREND_BUY))
     {
      ClosePositionTrend(symbol, TREND_SEL);
      CloseOrdersTrend(symbol, TREND_SEL);
     }
   if(count_order_buy == 0 && count_order_sel == 0 && count_possion_buy > 0 && count_possion_sel > 0)
     {
      ClosePosition(symbol);
     }
//----------------------------------------------------------------------------------------------------------------------------
   double w_open = iOpen(symbol, PERIOD_W1, 0);
   double amp_movied = MathAbs(price - w_open);

//if(amp_movied > week_amp*2)
//  {
//   if((price > w_open) && (count_possion_sel == 0))
//     {
//      trade_x5(symbol, TREND_SEL, week_amp, "AMP");
//     }
//   if((price < w_open) && (count_possion_buy == 0))
//     {
//      trade_x5(symbol, TREND_BUY, week_amp, "AMP");
//     }
//  }

   if(amp_movied < week_amp && trend_signal_h4 == candle_heiken_h4.trend && candle_heiken_h4.count == 1)
     {
      trade_x1(symbol, candle_heiken_h4.trend, week_amp, "HEI");
     }
  }

//+------------------------------------------------------------------+
bool trade_x5(string symbol, string trade_trend, double week_amp, string note)
  {
   if(is_open_this_candle_h4(symbol))
      return true;

   bool has_trade = false;

   if(trade_trend == "")
      return false;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double amp_drop_1 = NormalizeDouble(week_amp * 0.1, digits);

   double amp_tp = week_amp*2/3;

   double en_buy_1 = price;
   double tp_buy_1 = price + amp_tp;

   double en_buy_2 = price - week_amp;
   double tp_buy_2 = tp_buy_1 + amp_drop_1;

   double en_buy_3 = price - week_amp*2;
   double tp_buy_3 = tp_buy_1 + amp_drop_1*2;

   double en_buy_4 = price - week_amp*3;
   double tp_buy_4 = tp_buy_1 + amp_drop_1*3;

   double en_buy_5 = price - week_amp*4;
   double tp_buy_5 = tp_buy_1 + amp_drop_1*4;

   double sl_buy = en_buy_5 - week_amp;
   sl_buy = 0.0;
   tp_buy_1 = 0.0;

   double en_sel_1 = price;
   double tp_sel_1 = price - amp_tp;

   double en_sel_2 = price + week_amp;
   double tp_sel_2 = tp_sel_1 - amp_drop_1;

   double en_sel_3 = price + week_amp*2;
   double tp_sel_3 = tp_sel_1 - amp_drop_1*2;

   double en_sel_4 = price + week_amp*3;
   double tp_sel_4 = tp_sel_1 - amp_drop_1*3;

   double en_sel_5 = price + week_amp*4;
   double tp_sel_5 = tp_sel_1 - amp_drop_1*4;

   double sl_sel = en_sel_5 + week_amp;
   sl_sel = 0.0;
   tp_sel_1 = 0.0;

   double volume1 = dblLotsRisk(symbol, week_amp, dbRisk());
   double volume2 = volume1*2;
   double volume3 = volume2*2;
   double volume4 = volume3*2;
   double volume5 = volume4*2;

//------------------------------------------
   if(trade_trend == TREND_BUY)
     {
      has_trade = true;
      add_open_trade_today(symbol);

      m_trade.Buy(volume1,           symbol, 0.0, sl_buy, tp_buy_1,       note + "_BB_BUY_1");
      m_trade.BuyLimit(volume2, en_buy_2, symbol, sl_buy, tp_buy_1, 0, 0, note + "_BB_BUY_2");
      m_trade.BuyLimit(volume3, en_buy_3, symbol, sl_buy, tp_buy_1, 0, 0, note + "_BB_BUY_3");
      m_trade.BuyLimit(volume4, en_buy_4, symbol, sl_buy, tp_buy_1, 0, 0, note + "_BB_BUY_4");
      m_trade.BuyLimit(volume5, en_buy_5, symbol, sl_buy, tp_buy_1, 0, 0, note + "_BB_BUY_5");

      Alert(get_vntime(), "  BUY: ", symbol, "   note:", note);
     }
//------------------------------------------
   if(trade_trend == TREND_SEL)
     {
      has_trade = true;
      add_open_trade_today(symbol);

      m_trade.Sell(volume1,           symbol, 0.0, sl_sel, tp_sel_1,       note + "_BB_SELL_1");
      m_trade.SellLimit(volume2, en_sel_2, symbol, sl_sel, tp_sel_1, 0, 0, note + "_BB_SELL_2");
      m_trade.SellLimit(volume3, en_sel_3, symbol, sl_sel, tp_sel_1, 0, 0, note + "_BB_SELL_3");
      m_trade.SellLimit(volume4, en_sel_4, symbol, sl_sel, tp_sel_1, 0, 0, note + "_BB_SELL_4");
      m_trade.SellLimit(volume5, en_sel_5, symbol, sl_sel, tp_sel_1, 0, 0, note + "_BB_SELL_5");

      Alert(get_vntime(), "  SELL: ", symbol, "   note:", note);
     }
//------------------------------------------
   return has_trade;
  }


//+------------------------------------------------------------------+
bool trade_x1(string symbol, string trade_trend, double week_amp, string note)
  {
   if(is_open_this_candle_h4(symbol))
      return true;

   bool has_trade = false;

   if(trade_trend == "")
      return false;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double risk = dbRisk();
   double volume = dblLotsRisk(symbol, week_amp, risk);

   double tp_buy = NormalizeDouble(price + week_amp, digits);
   double sl_buy = NormalizeDouble(price - week_amp, digits);

   double tp_sel = NormalizeDouble(price - week_amp, digits);
   double sl_sel = NormalizeDouble(price + week_amp, digits);

//------------------------------------------
   if(trade_trend == TREND_BUY)
     {
      has_trade = true;
      add_open_trade_today(symbol);

      m_trade.Buy(volume, symbol, 0.0, sl_buy, tp_buy,       note + "_BUY_1");

      Alert(get_vntime(), "  BUY: ", symbol, "   note:", note);
     }
//------------------------------------------
   if(trade_trend == TREND_SEL)
     {
      has_trade = true;
      add_open_trade_today(symbol);

      m_trade.Sell(volume, symbol, 0.0, sl_sel, tp_sel,       note + "_SELL_1");

      Alert(get_vntime(), "  SELL: ", symbol, "   note:", note);
     }
//------------------------------------------
   return has_trade;
  }

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
         if((toLower(symbol) == trading_symbol)) // && (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            count_possion += 1;
            total_profit += m_position.Profit();
            type = m_position.TypeDescription();
            possion_comments += m_position.Comment() + "; ";
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
            count_orders += 1;
            order_comments += m_order.Comment() + "; ";
           }
        }
     }


   if(total_profit > dbRisk())
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }

   if(count_possion == 0 && count_orders > 0)
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }

  }

//+------------------------------------------------------------------+
void ClosePosition(string symbol)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionTrend(string symbol, string trading_trend)
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
void CloseOrdersTrend(string symbol, string trading_trend)
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
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, int periodK = 5, int periodD = 3, int slowing = 3)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return "iStochastic_invalid";

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

   return "iStochastic";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_seq_ma10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_seq_ma10_20_50 = "SEQ122050";

   int SMA_10_Handle = iMA(symbol,timeframe,10,0,MODE_SMA,PRICE_CLOSE);
   int SMA_20_Handle = iMA(symbol,timeframe,20,0,MODE_SMA,PRICE_CLOSE);
   int SMA_50_Handle = iMA(symbol,timeframe,50,0,MODE_SMA,PRICE_CLOSE);

   double SMA_10_Buffer[];
   double SMA_20_Buffer[];
   double SMA_50_Buffer[];
   ArraySetAsSeries(SMA_10_Buffer, true);
   ArraySetAsSeries(SMA_20_Buffer, true);
   ArraySetAsSeries(SMA_50_Buffer, true);
   if(CopyBuffer(SMA_10_Handle,0,0,5,SMA_10_Buffer)<=0
      ||CopyBuffer(SMA_20_Handle,0,0,5,SMA_20_Buffer)<=0
      ||CopyBuffer(SMA_50_Handle,0,0,5,SMA_50_Buffer)<=0)
     {
      trend_seq_ma10_20_50 = "";
     }
   else
     {
      if((SMA_10_Buffer[0] > SMA_20_Buffer[0]) && (SMA_10_Buffer[0] > SMA_50_Buffer[0]))
        {
         trend_seq_ma10_20_50 = TREND_BUY;
        }
      if((SMA_10_Buffer[0] < SMA_20_Buffer[0]) && (SMA_10_Buffer[0] < SMA_50_Buffer[0]))
        {
         trend_seq_ma10_20_50 = TREND_SEL;
        }
     }

   return trend_seq_ma10_20_50;
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

   double m_signal_0 = m_buff_MACD_signal[1];
   double m_signal_1 = m_buff_MACD_signal[2];
   double m_signal_2 = m_buff_MACD_signal[3];
//-------------------------------------------------
   if(m_signal_0 > m_signal_1 && m_signal_1 > m_signal_2)
      return TREND_BUY;

   if(m_signal_0 < m_signal_1 && m_signal_1 < m_signal_2)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
string get_trend_by_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA, int slowEMA, int signal)
  {
   string trend_macd = "iMACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return trend_macd;
     }

   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_signal,true);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double m_signal_0 = m_buff_MACD_signal[0];
   double m_signal_1 = m_buff_MACD_signal[1];
//-------------------------------------------------
   if(m_signal_0 > 0 && m_signal_1 > 0)
     {
      return TREND_BUY;
     }
//-------------------------------------------------
   if(m_signal_0 < 0 && m_signal_1 < 0)
     {
      return TREND_SEL;
     }
//-------------------------------------------------
   return trend_macd;
  }

//+------------------------------------------------------------------+
bool is_stoc_allow_trade_now(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int periodK, int periodD, int slowing)
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

   if((find_trend == TREND_BUY) && (black_K > red_D) && (black_K <= 20 || red_D <= 20))
      return true;

   if((find_trend == TREND_SEL) && (black_K < red_D) && (black_K >= 80 || red_D >= 80))
      return true;

   return false;
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

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + "   (GMT: " + (string) current_gmt_hour + "h) ";
   return vntime;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double adjust_target_price(double ma10, double dic_top_price, double week_amp)
  {
   double target_price = dic_top_price;

   if(ma10 < dic_top_price)
     {
      // Nếu ma10 nhỏ hơn dic_top_price, giảm target_price cho đến khi nào nó nhỏ hơn ma10
      while(target_price - week_amp >= ma10)
        {
         target_price -= week_amp;
        }
     }
   else
     {
      // Nếu ma10 lớn hơn dic_top_price, tăng target_price cho đến khi nào nó lớn hơn ma10
      while(target_price + week_amp <= ma10)
        {
         target_price += week_amp;
        }
     }

// Kết quả cuối cùng
   return target_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &amp_w_2, double &avg_candle_week)
  {
   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      amp_w = 1060.00;
      amp_w_2 = 1357.35;
      avg_candle_week = 3697.32;
      return;
     }
   if(symbol == "USOIL.cash")
     {
      i_top_price = 99.85;
      amp_w = 2.50000;
      amp_w_2 = 2.768;
      avg_candle_week = 5.606;
      return;
     }
   if(symbol == "XAGUSD")
     {
      i_top_price = 28.380;
      amp_w = 0.63500;
      amp_w_2 = 0.666;
      avg_candle_week = 1.396;
      return;
     }
   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      amp_w = 22.9500;
      amp_w_2 = 27.83;
      avg_candle_week = 65.93;
      return;
     }

   if(symbol == "US100.cash")
     {
      i_top_price = 15920;
      amp_w = 271.500;
      amp_w_2 = 274.5;
      avg_candle_week = 503.15;
      return;
     }
   if(symbol == "US30.cash")
     {
      i_top_price = 35700;
      amp_w = 388.350;
      amp_w_2 = 438.76;
      avg_candle_week = 818.86;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.6500;
      amp_w = 1.07795;
      amp_w_2 = 1.134;
      avg_candle_week = 2.097;
      return;
     }
   if(symbol == "AUDUSD")
     {
      i_top_price = 0.72000;
      amp_w = 0.00765;
      amp_w_2 = 0.00780;
      avg_candle_week = 0.01481;
      return;
     }
   if(symbol == "EURAUD")
     {
      i_top_price = 1.73000;
      amp_w = 0.01375;
      amp_w_2 = 0.01410;
      avg_candle_week = 0.02593;
      return;
     }
   if(symbol == "EURGBP")
     {
      i_top_price = 0.90265;
      amp_w = 0.00455;
      amp_w_2 = 0.00497;
      avg_candle_week = 0.00816;
      return;
     }
   if(symbol == "EURUSD")
     {
      i_top_price = 1.12500;
      amp_w = 0.00790;
      amp_w_2 = 0.00846;
      avg_candle_week = 0.01773;
      return;
     }
   if(symbol == "GBPUSD")
     {
      i_top_price = 1.31365;
      amp_w = 0.01085;
      amp_w_2 = 0.01103;
      avg_candle_week = 0.02180;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.40775;
      amp_w = 0.00795;
      amp_w_2 = 0.00909;
      avg_candle_week = 0.01907;
      return;
     }
   if(symbol == "USDCHF")
     {
      i_top_price = 0.94235;
      amp_w = 0.00715;
      amp_w_2 = 0.00777;
      avg_candle_week = 0.01586;
      return;
     }
   if(symbol == "USDJPY")
     {
      i_top_price = 154.395;
      amp_w = 1.29500;
      amp_w_2 = 1.475;
      avg_candle_week = 3.240;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.70200;
      amp_w = 0.00500;
      amp_w_2 = 0.00529;
      avg_candle_week = 0.00894;
      return;
     }
   if(symbol == "CADJPY")
     {
      i_top_price = 112.000;
      amp_w = 1.00000;
      amp_w_2 = 1.138;
      avg_candle_week = 2.298;
      return;
     }
   if(symbol == "CHFJPY")
     {
      i_top_price = 169.320;
      amp_w = 1.41000;
      amp_w_2 = 1.551;
      avg_candle_week = 3.451;
      return;
     }
   if(symbol == "EURJPY")
     {
      i_top_price = 162.065;
      amp_w = 1.39000;
      amp_w_2 = 1.542;
      avg_candle_week = 3.31;
      return;
     }
   if(symbol == "GBPJPY")
     {
      i_top_price = 188.115;
      amp_w = 1.61500;
      amp_w_2 = 1.815;
      avg_candle_week = 3.973;
      return;
     }
   if(symbol == "NZDJPY")
     {
      i_top_price = 90.7000;
      amp_w = 0.90000;
      amp_w_2 = 1.006;
      avg_candle_week = 1.946;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.51938;
      amp_w = 0.00945;
      amp_w_2 = 0.01019;
      avg_candle_week = 0.01895;
      return;
     }
   if(symbol == "EURCHF")
     {
      i_top_price = 1.01016;
      amp_w = 0.00455;
      amp_w_2 = 0.00533;
      avg_candle_week = 0.01156;
      return;
     }
   if(symbol == "EURNZD")
     {
      i_top_price = 1.89388;
      amp_w = 0.01585;
      amp_w_2 = 0.01596;
      avg_candle_week = 0.02848;
      return;
     }
   if(symbol == "GBPAUD")
     {
      i_top_price = 2.02830;
      amp_w = 0.01605;
      amp_w_2 = 0.01581;
      avg_candle_week = 0.02700;
      return;
     }
   if(symbol == "GBPCAD")
     {
      i_top_price = 1.75620;
      amp_w = 0.01210;
      amp_w_2 = 0.01194;
      avg_candle_week = 0.02005;
      return;
     }
   if(symbol == "GBPCHF")
     {
      i_top_price = 1.16955;
      amp_w = 0.00685;
      amp_w_2 = 0.00783;
      avg_candle_week = 0.01625;
      return;
     }
   if(symbol == "GBPNZD")
     {
      i_top_price = 2.18685;
      amp_w = 0.01705;
      amp_w_2 = 0.01697;
      avg_candle_week = 0.02895;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.94763;
      amp_w = 0.00735;
      amp_w_2 = 0.00727;
      avg_candle_week = 0.01345;
      return;
     }
   if(symbol == "AUDCHF")
     {
      i_top_price = 0.65518;
      amp_w = 0.00545;
      amp_w_2 = 0.00589;
      avg_candle_week = 0.01076;
      return;
     }
   if(symbol == "AUDNZD")
     {
      i_top_price = 1.11568;
      amp_w = 0.00595;
      amp_w_2 = 0.00679;
      avg_candle_week = 0.01017;
      return;
     }
   if(symbol == "NZDCAD")
     {
      i_top_price = 0.87860;
      amp_w = 0.00725;
      amp_w_2 = 0.00728;
      avg_candle_week = 0.01275;
      return;
     }
   if(symbol == "NZDCHF")
     {
      i_top_price = 0.58565;
      amp_w = 0.00515;
      amp_w_2 = 0.00559;
      avg_candle_week = 0.00988;
      return;
     }
   if(symbol == "NZDUSD")
     {
      i_top_price = 0.65315;
      amp_w = 0.00670;
      amp_w_2 = 0.00702;
      avg_candle_week = 0.01388;
      return;
     }


   i_top_price = iClose(symbol, PERIOD_W1, 1);
   amp_w = calc_avg_amp_week(symbol, 20);
   amp_w_2 = amp_w;
   avg_candle_week = CalculateAverageCandleHeight(PERIOD_W1, symbol);

//Alert(" Add Symbol Data:",  symbol, " amp:", amp_w);
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 50; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      totalHeight += candleHeight;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / 10.0;

   return averageHeight;
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

//+------------------------------------------------------------------+
string format_double_to_string(double number, int digits = 5)
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
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }
//+------------------------------------------------------------------+

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
string get_volume_cur_symbol()
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_amp_w_2;
   double dic_avg_candle_week;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_amp_w_2, dic_avg_candle_week);
   double week_amp = dic_amp_w;

   double risk_per_trade = dbRisk();
   string volume = " Vol: " + format_double_to_string(dblLotsRisk(_Symbol, week_amp, risk_per_trade), 2) + "    ";

   return volume;
  }
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
