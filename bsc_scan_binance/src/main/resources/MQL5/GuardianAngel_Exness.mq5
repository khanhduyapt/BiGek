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

#define BComment "BComment"
#define BtnClosePosision "ButtonClosePosision"
#define BtnCloseOrder "ButtonCloseOrder"
#define BtnTrade "ButtonTrade"
#define BtnOrderBuy "ButtonOrderBuy"
#define BtnOrderSell "ButtonOrderSell"

double dbRiskRatio = 0.1; // Rủi ro 10% = 10$/lệnh
double INIT_EQUITY = 100.0; // Vốn đầu tư

string INDICES = "_USTEC_US30_US500_DE30_UK100_FR40_AUS200_BTCUSD_";

string arr_main_symbol[] = {"DXY", "XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

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
string SWITH_TREND_TYPE_DOJI   = "(Dj)";
string SWITH_TREND_TYPE_HEIKEN = "(Ha)";
string SWITH_TREND_TYPE_STOCH  = "(Oc)";
string SWITH_TREND_TYPE_MA69   = "(69)";
string SWITH_TREND_TYPE_MA10   = "(10)";
string SWITH_TREND_TYPE_MA20   = "(20)";
string SWITH_TREND_TYPE_SEQ    = "(Sq)";

string ENTRY_BY_COUNT_CANDLE = "COUNT_H1";

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

//iStochastic
int periodK = 5;
int periodD = 3;
int slowing = 3;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//WriteNotifyToken();
   Comment(GetComments());

   Draw_Bottom_Msg();

   EventSetTimer(180); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Comment(GetComments());
   if(IsMarketClose())
      return;

   WriteNotifyToken();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoTrade(string symbol)
  {
   datetime current_time = TimeCurrent();
   string tradingview_symbol = symbol;
   StringReplace(tradingview_symbol, ".cash", "");
   bool is_index = StringFind(INDICES, tradingview_symbol) >= 0;

   CandleData candle_arr_h4[];
   get_arr_heiken(symbol, PERIOD_H4, candle_arr_h4);

   CandleData candle_arr_h1[];
   get_arr_heiken(symbol, PERIOD_H1, candle_arr_h1);

   string trend_by_hei_h4 = candle_arr_h4[1].trend;
   string trend_by_hei_h1 = candle_arr_h1[1].trend;
   string trend_by_hei_15 = get_trend_by_heiken(symbol, PERIOD_M15, 1);

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double volume = get_default_volume(symbol);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double amp_sl = NormalizeDouble(week_amp*2, digits);


   int ord_buy = 0;
   int ord_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            if(StringFind(toLower(m_order.TypeDescription()), "buy") >= 0)
               ord_buy += 1;

            if(StringFind(toLower(m_order.TypeDescription()), "sel") >= 0)
               ord_sel += 1;
           }
        }
     }

//--------------------------------------------------------------------------------------------------------------------------

   ulong max_ticket_buy = 0, max_ticket_sel = 0;
   double best_entry_buy = 0, best_entry_sel = 0;
   int count_possion_buy = 0, count_possion_sel = 0;

   double total_profit = 0.0;
   double profit_buy = 0.0;
   double profit_sel = 0.0;
   datetime max_time_buy = 0;
   datetime max_time_sel = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            string TRADING_TREND = "";
            ulong ticket = m_position.Ticket();
            double profit = m_position.Profit();
            double price_open = m_position.PriceOpen();
            bool has_profit = (profit > 1);


            total_profit += profit;

            // ----------------------------AUTO_TRADE----------------------------
            if(StringFind(toLower(m_position.TypeDescription()), "buy") >= 0)
              {
               profit_buy += profit;
               count_possion_buy += 1;
               TRADING_TREND = TREND_BUY;

               if(max_ticket_buy < m_position.Ticket())
                 {
                  max_time_buy = m_position.Time();
                  max_ticket_buy = m_position.Ticket();
                  best_entry_buy = m_position.PriceOpen();
                 }
              }

            if(StringFind(toLower(m_position.TypeDescription()), "sel") >= 0)
              {
               profit_sel += profit;
               count_possion_sel += 1;
               TRADING_TREND = TREND_SEL;

               if(max_ticket_sel < m_position.Ticket())
                 {
                  max_time_sel = m_position.Time();
                  max_ticket_sel = m_position.Ticket();
                  best_entry_sel = m_position.PriceOpen();
                 }
              }
            // ----------------------------AUTO_TRADE----------------------------

            bool is_no_stop_loss = false;
            if(StringFind(m_position.Comment(), ENTRY_BY_COUNT_CANDLE) >= 0)
               is_no_stop_loss = true;

            // ----------------------------STOP_LOSS----------------------------
            if(is_no_stop_loss == false && IsMarketClose()== false)
              {
               if(TRADING_TREND == TREND_BUY)
                 {
                  double sl = price_open - amp_sl;
                  if(sl > price)
                    {
                     if(is_index && trend_by_hei_h4 == TREND_SEL && trend_by_hei_h1 == TREND_SEL)
                       {
                        m_trade.PositionClose(ticket);
                        SendTelegramMessage(symbol, STOP_LOSS + TRADING_TREND, STOP_LOSS + "   " + TRADING_TREND + "   " + symbol + "   P: " + (string) profit + "$");
                       }

                    }
                 }

               if(TRADING_TREND == TREND_SEL)
                 {
                  double sl = price_open + amp_sl;
                  if(sl < price)
                    {
                     if(is_index && trend_by_hei_h4 == TREND_BUY && trend_by_hei_h1 == TREND_BUY)
                       {
                        m_trade.PositionClose(ticket);
                        SendTelegramMessage(symbol, STOP_LOSS + TRADING_TREND, STOP_LOSS + "   " + TRADING_TREND + "   " + symbol + "   P: " + (string) profit + "$");
                       }


                    }
                 }
              }
            // ----------------------------STOP_LOSS----------------------------

           }
        }
     } // End For PositionsTotal

//if((count_possion_buy + count_possion_sel == 0) && (ord_buy + ord_sel > 0))
//   CloseOrders(symbol);
//--------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------TAKE_PROFIT---------------------------------------------------------------
   if(count_possion_buy + count_possion_sel > 0)
     {
      double risk = calcRisk();
      bool is_exit_trade = false;
      if(total_profit > risk)
        {
         if(count_possion_buy + count_possion_sel > 2)
            is_exit_trade = true;

         if(count_possion_buy + count_possion_sel == 1)
           {
            if(count_possion_buy == 1 && candle_arr_h4[1].trend == TREND_SEL)
               is_exit_trade = true;

            if(count_possion_sel == 1 && candle_arr_h4[1].trend == TREND_BUY)
               is_exit_trade = true;
           }
        }

      if((is_exit_trade == false) && (count_possion_buy + count_possion_sel == 1))
        {
         if(count_possion_buy > 0 && profit_buy > 1 && is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_BUY))
            is_exit_trade = true;

         if(count_possion_sel > 0 && profit_sel > 1 && is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_SEL))
            is_exit_trade = true;
        }

      if(is_exit_trade)
        {
         if(count_possion_buy > 0)
           {
            double time_diff_buy_hours = (double)(current_time - max_time_buy) / (60 * 60);
            if(time_diff_buy_hours <= 8.0)
               is_exit_trade = false;
           }

         if(count_possion_sel > 0)
           {
            double time_diff_sel_hours = (double)(current_time - max_time_sel) / (60 * 60);
            if(time_diff_sel_hours <= 8.0)
               is_exit_trade = false;
           }

         if(is_exit_trade == true && count_possion_buy > 0 && is_continue_hode_postion_by_ma_6_9_20(symbol, PERIOD_H4, TREND_BUY))
            is_exit_trade = false;

         if(is_exit_trade == true && count_possion_sel > 0 && is_continue_hode_postion_by_ma_6_9_20(symbol, PERIOD_H4, TREND_SEL))
            is_exit_trade = false;

         if(is_exit_trade)
           {
            ClosePosition(symbol, TREND_BUY, ENTRY_BY_COUNT_CANDLE);
            ClosePosition(symbol, TREND_SEL, ENTRY_BY_COUNT_CANDLE);
            SendTelegramMessage(symbol, STOP_TRADE, STOP_TRADE + "   " + symbol + "   Profit: " + (string) total_profit + "$");
           }
        }
     }
//-----------------------------------------------------------OPEN_TRADE---------------------------------------------------------------




//------------------------------------------------------------DCA-------------------------------------------------------------
   if(count_possion_buy + count_possion_sel > 0)
     {
      bool allow_push_buy = (count_possion_buy > 0) && (count_possion_buy < 3) &&
                            ((MathMax(best_entry_buy, best_entry_sel) - price) > week_amp);

      bool allow_push_sel = (count_possion_sel > 0) && (count_possion_sel < 3) &&
                            ((price - MathMax(best_entry_buy, best_entry_sel)) > week_amp);

      datetime current_time = TimeCurrent();
      if(allow_push_buy)
        {
         double time_diff_buy_hours = (double)(current_time - max_time_buy) / (60 * 60);
         if(time_diff_buy_hours <= 24.0)
            allow_push_buy = false;
        }

      if(allow_push_sel)
        {
         double time_diff_sel_hours = (double)(current_time - max_time_sel) / (60 * 60);
         if(time_diff_sel_hours <= 24.0)
            allow_push_sel = false;
        }


      if(allow_push_buy || allow_push_sel)
        {
         double volume = get_default_volume(symbol);

         string msg_append_trade = "";

         if(allow_push_buy && trend_by_hei_h4 == TREND_BUY && trend_by_hei_h1 == TREND_BUY)
            msg_append_trade = AUTO_TRADE + " allow.push.buy " + symbol + "   Vol: " + (string) volume;

         if(allow_push_sel && trend_by_hei_h4 == TREND_SEL && trend_by_hei_h1 == TREND_SEL)
            msg_append_trade = AUTO_TRADE + " allow.push.sel " + symbol + "   Vol: " + (string) volume;

         if(msg_append_trade != "")
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

            if(allow_push_buy && ord_buy == 0)
              {
               if(is_allow_trade_by_ma_10_20_50(symbol, PERIOD_H4, TREND_BUY))
                 {
                  //m_trade.Buy(volume, symbol, 0.0, 0.0, calc_tp_price(symbol, TREND_BUY), "MK_B" + (string)(count_possion_buy + 1) + "_AT_" + ENTRY_BY_COUNT_CANDLE);

                  m_trade.BuyLimit(volume, next_entry_buy, symbol, 0.0, calc_tp_price(symbol, TREND_BUY), 0, 0, "OD_B" + (string)(count_possion_buy + 2) + "_AT_" + ENTRY_BY_COUNT_CANDLE);
                  SendTelegramMessage(symbol, TREND_BUY, msg_append_trade);
                 }

              }

            if(allow_push_sel && ord_sel == 0)
              {
               if(is_allow_trade_by_ma_10_20_50(symbol, PERIOD_H4, TREND_SEL))
                 {
                  //m_trade.Sell(volume, symbol, 0.0, 0.0, calc_tp_price(symbol, TREND_SEL), "MK_S" + (string)(count_possion_sel + 1) + "_AT_" + ENTRY_BY_COUNT_CANDLE);

                  m_trade.SellLimit(volume, next_entry_sel, symbol, 0.0, calc_tp_price(symbol, TREND_SEL), 0, 0, "OD_S" + (string)(count_possion_sel + 2) + "_AT_" + ENTRY_BY_COUNT_CANDLE);
                  SendTelegramMessage(symbol, TREND_BUY, msg_append_trade);
                 }
              }


           }

        }
     }
//------------------------------------------------------------DCA-------------------------------------------------------------

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string trading_trend, string ENTRY_TYPE)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0)
               if(StringFind(m_position.Comment(), ENTRY_TYPE) >= 0)
                  m_trade.PositionClose(m_position.Ticket());
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

   string trend_by_ma50_h4 = get_trend_by_ma50(_Symbol, Period());

   str_comments += "    Macd (H4) " + AppendSpaces(trend_macd, 5);
   str_comments += "    Heiken(" + cur_timeframe + ") " + arr_heiken[0].trend + "("+(string)arr_heiken[0].count+")";
   str_comments += "    Ma50(" + cur_timeframe+ ") " + AppendSpaces(trend_by_ma50_h4, 10) ;
   str_comments += "    Ma9(" + cur_timeframe+ ") " + AppendSpaces(get_trend_by_ma(_Symbol, Period(), 9), 10) ;

   str_comments += "    Vol(00): " + volume_bt + " lot";

   str_comments += "    Risk: " + (string) risk + "$/" + (string)(dbRiskRatio * 100) + "% ";
   str_comments += "    " + get_profit_today();
   str_comments += "    WEEK(ha): " + arr_heiken_w1[0].trend + "("+(string)arr_heiken_w1[0].count+")";
   str_comments += "    WEEK(533): " + get_trend_by_stoc(_Symbol, PERIOD_W1);
   if(trend_swap != "")
      str_comments += "    Swap " + AppendSpaces(trend_swap, 5);

   if(IsMarketClose())
      str_comments += "    MarketClose";
   else
      str_comments += "    Market Open";

   return str_comments;
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

//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------

   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
      string tradingview_symbol = symbol;
      StringReplace(tradingview_symbol, ".cash", "");


      string str_count_trade = CountTrade(symbol);
      bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
      bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
      bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
      bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

      if(has_position_buy || has_position_sel)
        {
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

         if(rate_amp_sel < week_amp*1.5)
           {
            trend_by_amp_weeks = TREND_SEL;

            if(rate_amp_sel < week_amp)
               is_allow_alert = true;
           }

         if(rate_amp_buy < week_amp*1.5)
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

         if(is_allow_alert && bb_alert && ((trend_by_amp_weeks == TREND_BUY && bb_allow_buy) || (trend_by_amp_weeks == TREND_SEL && bb_allow_sel)))
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
      string trend_by_hei_h0 = get_trend_by_heiken(symbol, PERIOD_H4, 0);
      string trend_by_hei_h4 = get_trend_by_heiken(symbol, PERIOD_H4, 1);
      string trend_by_hei_h1 = get_trend_by_heiken(symbol, PERIOD_H1, 1);

      string trend_by_ma50_h4 = get_trend_by_ma50(symbol, PERIOD_H4);
      string trend_by_ma50_h1 = get_trend_by_ma50(symbol, PERIOD_H1);

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

         bool is_must_exit_h4 = is_must_exit_trade_by_stoch(symbol, PERIOD_H4, trading) || (trading != trend_by_hei_h4);
         if(is_must_exit_h4)
           {
            bool has_profit = (StringFind(str_count_trade, "-") >= 0) ? false : true;
            if(has_profit)
              {
               string msg = "(TP) " + AppendSpaces(trading, 5) + tradingview_symbol;
               int msg_index = ArraySize(msg_list_tp);
               ArrayResize(msg_list_tp, msg_index + 1);
               msg_list_tp[msg_index] = msg;
              }

            if(is_must_exit_trade_by_stoch(symbol, PERIOD_M5, trading))
               if(is_must_exit_trade_by_stoch(symbol, PERIOD_H1, trading) || is_must_exit_trade_by_stoch(symbol, PERIOD_M15, trading))
                  Take_Profit(symbol, str_count_trade);

           }
        }

      if(has_position_buy == false && has_position_sel == false)
        {
         if(trend_by_amp_weeks != "" && trend_by_amp_weeks == trend_by_hei_h4 && trend_by_amp_weeks == trend_by_hei_h0)
           {
            string msg = "(Am) W1 " + AppendSpaces(trend_by_amp_weeks, 5) + tradingview_symbol;
            int msg_index = ArraySize(msg_list_am);
            ArrayResize(msg_list_am, msg_index + 1);
            msg_list_am[msg_index] = msg + rate;

            if(is_allow_alert &&
               (trend_by_amp_weeks == trend_by_hei_h1) &&
               (IsDojiHeikenAshi(symbol, PERIOD_H4, 0) || (trend_by_ma50_h4 == trend_by_hei_h4))
              )
              {

               if(is_allow_trade_now_by_stoc(symbol, PERIOD_M5, trend_by_amp_weeks))
                  SendTelegramMessage(symbol, trend_by_amp_weeks, msg + rate);

               if((has_position_buy && trend_by_amp_weeks == TREND_SEL) ||
                  (has_position_sel && trend_by_amp_weeks == TREND_BUY))
                 {
                  int msg_index_tp = ArraySize(msg_list_tp);
                  ArrayResize(msg_list_tp, msg_index_tp + 1);
                  msg_list_tp[msg_index_tp] = "(TP) " + AppendSpaces(trading, 5) + tradingview_symbol;
                 }
              }
           }
         else
           {
            string trend_by_hei_w1 = get_trend_by_heiken(symbol, PERIOD_W1, 0);
            string trend_by_stoch_w1 = get_trend_by_stoc(symbol, PERIOD_W1);

            string trend_by_ma50_05 = get_trend_by_ma50(symbol, PERIOD_M5);
            string trend_by_heiken_05 = get_trend_by_heiken(symbol, PERIOD_M5, 0);

            bool h4_allow_trade = (trend_by_ma50_h4 == trend_by_hei_h4) &&
                                  (trend_by_ma50_h4 == trend_by_hei_h1) &&
                                  (trend_by_ma50_h4 == trend_by_ma50_h1) &&
                                  (trend_by_ma50_h4 == trend_by_ma50_05);

            if(h4_allow_trade == false)
               h4_allow_trade = (trend_by_hei_w1 == trend_by_hei_h4) &&
                                (trend_by_hei_w1 == trend_by_hei_h1) &&
                                (trend_by_hei_w1 == trend_by_ma50_h1) &&
                                (trend_by_hei_w1 == trend_by_heiken_05);

            if(trend_by_hei_w1 == trend_by_stoch_w1 && trend_by_hei_h4 != trend_by_hei_w1)
               h4_allow_trade = false;

            if(h4_allow_trade)

               if(is_must_exit_trade_by_stoch(symbol, PERIOD_D1, trend_by_hei_h4) == false)
                  if(is_must_exit_trade_by_stoch(symbol, PERIOD_W1, trend_by_hei_h4) == false)
                    {
                     string lable = PREFIX_TRADE_PERIOD_H4 + " " + AppendSpaces(trend_by_ma50_h4, 5) + symbol;
                     int msg_index = ArraySize(msg_list_h4);
                     ArrayResize(msg_list_h4, msg_index + 1);
                     msg_list_h4[msg_index] = lable + rate;

                     bool minus_allow_trade = (trend_by_hei_h4 == trend_by_ma50_05) &&
                                              (trend_by_hei_h4 == trend_by_heiken_05);

                     if(minus_allow_trade)
                       {
                        SendAlert(symbol, trend_by_ma50_h4, lable + rate);
                       }
                    }

           }
        }

      //--------------------------------------------------------------------------------------------------
      if(has_position_buy || has_position_sel)
        {
         string msg_close = "";
         if(has_position_buy &&
            trend_by_amp_weeks == TREND_SEL &&
            trend_by_hei_h4 == TREND_SEL &&
            trend_by_hei_h1 == TREND_SEL)
           {
            msg_close = "(X) " + AppendSpaces(TREND_BUY, 5) + tradingview_symbol;
           }

         if(has_position_sel &&
            trend_by_amp_weeks == TREND_BUY &&
            trend_by_hei_h4 == TREND_BUY &&
            trend_by_hei_h1 == TREND_BUY)
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

      string doji = "";
      if(IsDojiHeikenAshi(symbol, PERIOD_W1, 0))
         doji += "Doji_W0   ";
      if(IsDojiHeikenAshi(symbol, PERIOD_D1, 0))
         doji += "Doji_D0   ";


      string line = "";
      line += "." + AppendSpaces((string)(index + 1), 2, false) + "   ";
      line += AppendSpaces(tradingview_symbol) + AppendSpaces(format_double_to_string(price, digits-1), 8) + " | ";
      line += AppendSpaces("Swap(B:" + AppendSpaces((string)swap_long, 7, false) + ", S:" + AppendSpaces((string)swap_short, 7, false) + ") " + trend_swap, 35);

      line += str_volume + "/" + AppendSpaces(format_double_to_string(week_amp, digits), 8, false) + "  |  ";
      line += AppendSpaces(str_count_trade, 42);
      line += " | "  + AppendSpaces(remain, 15) + AppendSpaces(trade_by_amp, 25);
      line += " | " + AppendSpaces(doji, 20);
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

   FileDelete(FILE_NAME_ANGEL_LOG);
   int nfile_draft = FileOpen(FILE_NAME_ANGEL_LOG, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

//--------------------------------------------------------------------------------------------------
   if(nfile_draft != INVALID_HANDLE)
     {
      string str_profit = get_vntime() + get_profit_today();
      FileWrite(nfile_draft, str_profit);

      string line = "";
      line += "." + AppendSpaces((string)(0), 2, false) + "   ";
      line += AppendSpaces("VNINDEX") + AppendSpaces("", 164);
      line += "  https://www.tradingview.com/chart/r46Q5U5a/?symbol=" + AppendSpaces("VNINDEX");
      FileWrite(nfile_draft, AppendSpaces(line, line_length));

      FileWrite(nfile_draft, hyphen_line);
      FileWrite(nfile_draft, all_lines);

      FileClose(nfile_draft);
     }
//--------------------------------------------------------------------------------------------------
   Draw_Bottom_Msg();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Bottom_Msg()
  {
   int start_x = 10;
   int start_y = 50;
   int btn_high = 21;
   int btn_width = 225;
   int doji_width = 100;
   int btn_trade_width = 112;

//---------------------------------------------------------------------------------------------------------------------------------------
   int main_fx_size = ArraySize(arr_main_symbol);
   int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 30;
   for(int temp_i = 0; temp_i < main_fx_size; temp_i++)
     {
      string symbol = arr_main_symbol[temp_i];
      string tradingview_symbol = symbol;
      StringReplace(tradingview_symbol, ".cash", "");

      color clrBackground = clrWhiteSmoke;
      if(StringFind(_Symbol, tradingview_symbol) >= 0)
         clrBackground = clrHoneydew;

      createButton("btn_w1_" + tradingview_symbol, tradingview_symbol, temp_i*(doji_width + 10) + 10, y_ref_btn, doji_width, 20, clrBlack, clrBackground, 6);
     }
//---------------------------------------------------------------------------------------------------------------------------------------
   int count_doji = 0;
   int total_fx_size = ArraySize(arr_symbol);
   int y_doj_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 55;
   for(int temp_i = 0; temp_i < total_fx_size; temp_i++)
     {
      string symbol = arr_symbol[temp_i];
      string tradingview_symbol = symbol;
      StringReplace(tradingview_symbol, ".cash", "");

      color clrBackground = clrWhiteSmoke;
      if(StringFind(_Symbol, tradingview_symbol) >= 0)
         clrBackground = clrHoneydew;
      string btn_name = "btn_doji_" + tradingview_symbol;

      bool has_switch_trend = false;

      string swith_trend_w1 = get_switch_trend_by_heiken_3_0(symbol, PERIOD_W1);
      if(swith_trend_w1 != "")
        {
         //if(swith_trend_w1 == get_trend_by_stoc(symbol, PERIOD_W1))
           {
            createButton(btn_name, "W1 " + AppendSpaces(swith_trend_w1, 5) + tradingview_symbol, count_doji*(doji_width + 10) + 10, y_doj_btn, doji_width, 20, clrBlack, clrBackground, 6);
            count_doji += 1;
            has_switch_trend = true;
           }
        }

      if(has_switch_trend == false)
        {
         string swith_trend_d1 = get_switch_trend_by_heiken_3_0(symbol, PERIOD_D1);
         if(swith_trend_d1 != "" && (swith_trend_d1 == get_trend_by_stoc(symbol, PERIOD_W1)))
           {
            createButton(btn_name, "D1 "+ AppendSpaces(swith_trend_d1, 5) + tradingview_symbol, count_doji*(doji_width + 10) + 10, y_doj_btn, doji_width, 20, clrBlack, clrBackground, 6);
            count_doji += 1;
            has_switch_trend = true;
           }
        }

      if(has_switch_trend == false)
         ObjectDelete(0, btn_name);

     }

//---------------------------------------------------------------------------------------------------------------------------------------

   string str_count_trade = CountTrade(_Symbol);
   bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
   bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
   bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
   bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;
   string str_p = "";
   int index = StringFind(str_count_trade, "P:");
   if(index >= 0)
      str_p = StringSubstr(str_count_trade, index, StringLen(str_count_trade));
   color clrPosColor = (StringFind(str_p, "-") >= 0) ? clrFireBrick : clrBlue;


   string trend_vector_ma6_h4 = get_trend_by_vector_ma(_Symbol, PERIOD_H4, 6);

   string cur_haTrend = get_trend_by_heiken(_Symbol, Period(), 0);

   bool allow_trade = true; //(trend_vector_ma6_h4 == cur_haTrend) || (trend_vector_ma6_h4 == pre_haTrend)
//  || (cur_haTrend_H4 == cur_haTrend) || (cur_haTrend_H4 == pre_haTrend);

   color clrTrade = clrGray;
   if(cur_haTrend == TREND_BUY)
      clrTrade = clrTeal;
   if(cur_haTrend == TREND_SEL)
      clrTrade = clrFireBrick;

   ObjectDelete(0, BtnTrade);
   ObjectDelete(0, BtnOrderBuy);
   ObjectDelete(0, BtnOrderSell);
   ObjectDelete(0, BtnCloseOrder);
   ObjectDelete(0, BtnClosePosision);

   if(allow_trade)
      createButton(BtnTrade,  cur_haTrend + " " + get_current_timeframe_to_string(), start_x + 0*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrTrade, 8);

   if(has_order_buy == false && has_order_sel == false)
     {
      createButton(BtnOrderBuy,  "Order_B_" + get_current_timeframe_to_string(), start_x + 1*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrCadetBlue, 8);
      createButton(BtnOrderSell, "Order_S_" + get_current_timeframe_to_string(), start_x + 2*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrFireBrick, 8);
      if(has_position_buy || has_position_sel)
         createButton(BtnClosePosision, "Close " + str_p,                        start_x + 3*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrPosColor, clrHoneydew,  8);
     }
   else
     {
      createButton(BtnCloseOrder,    "Close Order",                              start_x + 1*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrGray,  8);
      if(has_position_buy || has_position_sel)
         createButton(BtnClosePosision, "Close " + str_p,                        start_x + 2*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrPosColor, clrHoneydew,  8);
     }

//---------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------

   string contents = ReadFileContent(FILE_NAME_BUTTONS);
   ushort delimiter = StringGetCharacter(";",0);
   string msgs[];
   StringSplit(contents, delimiter, msgs);

   int init_x = 10;
   int init_y = 80;

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
         y = init_y + (index_op * btn_high);
         has_o = true;

         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrWhite;
        }

      if(StringFind(msg, "(TP)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * btn_high);
         y += has_o ? 10 : 0;

         has_p = true;
         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrPaleGreen;
        }


      if(StringFind(msg, "(X)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * btn_high);
         y += has_o ? 10 : 0;
         y += has_p ? 10 : 0;

         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrLightGray;
        }
      // ------------------------------------------------------------
      bool is_found = false;

      int next_col = (index_op > 0) ? 1 : 0;
      if(is_found == false && StringFind(msg, "W1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         has_w = true;
         index_wa += 1;
         clrBackground = clrLightCyan;

         if(StringFind(msg, "(Am)") >= 0)
            clrBackground = clrPowderBlue;

         is_found = true;
        }

      if(is_found == false && StringFind(msg, "D1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         y += has_w ? 10 : 0;

         has_d = true;
         index_wa += 1;
         clrBackground = clrAliceBlue;

         is_found = true;
        }

      if(is_found == false && StringFind(msg, "H4") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         y += has_w ? 10 : 0;
         y += has_d ? 10 : 0;

         has_h4 = true;
         index_wa += 1;
         clrBackground = clrSnow;

         is_found = true;
        }

      if(is_found == false && StringFind(msg, "H1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         y += has_w ? 10 : 0;
         y += has_d ? 10 : 0;
         y += has_h4 ? 10 : 0;

         index_wa += 1;
         clrBackground = clrWhite;

         is_found = true;
        }


      if(msg != "" && x > 0 && y > 0)
        {
         color clrTrade = StringFind(msg, TREND_BUY) >= 0 ? clrNavy : clrFireBrick;
         string TRADING_TREND = StringFind(msg, TREND_BUY) >= 0 ? TREND_BUY : TREND_SEL;

         if(is_opening_btn)
            StringReplace(msg, "(Op)", "");

         if(cur_symbol == _Symbol)
           {
            clrBackground = clrHoneydew;
           }

         btn_count += 1;
         string btn_name = "btn_" + (string) btn_count;
         createButton(btn_name, msg, x, y, btn_width-5, 20, clrTrade, clrBackground, 6);
        }
     }
   for(int index = btn_count + 1; index < 100; index++)
      ObjectDelete(0, "btn_" + (string) index);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseChart(string symbol)
  {
   string tradingview_symbol = symbol;
   StringReplace(tradingview_symbol, ".cash", "");

   int count = 0;
   long chartID=ChartFirst();
   while(chartID >= 0)
     {
      ChartClose(chartID);
      chartID = ChartNext(chartID);
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
               CloseChart(tradingview_symbol);

               if(StringFind(buttonLabel, PREFIX_TRADE_PERIOD_W1) >= 0)
                  ChartOpen(symbol, PERIOD_W1);
               else
                  if((StringFind(sparam, "btn_w1_") >= 0) || (StringFind(sparam, "DXY") >= 0))
                     ChartOpen(symbol, PERIOD_W1);
                  else
                     ChartOpen(symbol, PERIOD_W1);
              }
           }
         // ------------------------------------------------------------------------
         if(StringFind(sparam, "DXY") >= 0)
           {
            CloseChart("DXY");
            ChartOpen("DXY", PERIOD_W1);
           }
         // ------------------------------------------------------------------------
        }


      //-----------------------------------------------------------------------
      //-----------------------------------------------------------------------
      if((sparam == BtnTrade) || (sparam == BtnOrderBuy) || (sparam == BtnOrderSell))
        {
         Print("The ", sparam," was clicked");
         //-----------------------------------------------------------------------
         double dic_top_price;
         double dic_amp_w;
         double dic_avg_candle_week;
         double dic_amp_init_d1;
         GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
         double week_amp = dic_amp_w;
         double amp_percent = dic_amp_init_d1;

         double amp_sl = week_amp*2;
         double volume = dblLotsRisk(_Symbol, amp_sl, calcRisk());
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         string cur_click_prefix = get_prefix_trade_from_current_timeframe();
         double amp_waste = NormalizeDouble(week_amp / 10, digits);

         double tp_buy = 0.0;
         double tp_sel = 0.0;
         double next_entry_buy = 0.0;
         double next_entry_sel = 0.0;
         double lowest_close_21 = 0.0;
         double higest_close_21 = 0.0;
         if((sparam == BtnTrade) || (sparam == BtnOrderBuy) || (sparam == BtnOrderSell))
           {
            for(int i = 1; i <= 55; i++)
              {
               double low = iLow(_Symbol, PERIOD_H4, i);
               double hig = iHigh(_Symbol, PERIOD_H4, i);
               double close = iClose(_Symbol, PERIOD_H4, i);

               if((i == 1) || (next_entry_buy > low))
                  next_entry_buy = low;
               if((i == 1) || (next_entry_sel < hig))
                  next_entry_sel = hig;

               if(i <= 21)
                 {
                  if((i == 1) || (lowest_close_21 > close))
                     lowest_close_21 = close;

                  if((i == 1) || (higest_close_21 < close))
                     higest_close_21 = close;
                 }
              }

            double nex_price_buy = lowest_close_21*(1 + amp_percent*1);
            double nex_price_sel = higest_close_21*(1 - amp_percent*1);

            tp_buy = next_entry_sel;
            if(tp_buy < nex_price_buy)
               tp_buy = nex_price_buy;

            tp_sel = next_entry_buy;
            if(tp_sel > nex_price_sel)
               tp_sel = nex_price_sel;

            next_entry_buy = next_entry_buy - week_amp;
            next_entry_sel = next_entry_sel + week_amp;
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

                  if(m_order.Type() == ORDER_TYPE_SELL_LIMIT || m_order.Type() == ORDER_TYPE_SELL || (StringFind(toLower(m_order.TypeDescription()), "sel") >= 0))
                     count_order_sel += 1;
                 }
              }
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

            string haTrend = get_trend_by_heiken(_Symbol, Period(), 0);
            string msg = OPEN_TRADE + "    " + AppendSpaces(haTrend, 5) + _Symbol + "  vol: " + (string) volume + " lot";

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  if(haTrend == TREND_BUY)
                    {
                     m_trade.Buy(volume, _Symbol, 0.0, 0.0, tp_buy, "MK_B1_" + cur_click_prefix);
                     if(count_order_buy == 0)
                       {
                        //m_trade.BuyLimit(volume, next_entry_buy,              _Symbol, 0.0, tp_buy, 0, 0, "OD_B2_" + cur_click_prefix);
                        //m_trade.BuyLimit(volume, next_entry_buy - amp_waste,  _Symbol, 0.0, tp_buy, 0, 0, "OD_B3_" + cur_click_prefix);
                       }
                    }

                  if(haTrend == TREND_SEL)
                    {
                     m_trade.Sell(volume, _Symbol, 0.0, 0.0, tp_sel, "MK_S1_" + cur_click_prefix);
                     if(count_order_sel == 0)
                       {
                        //m_trade.SellLimit(volume, next_entry_sel,             _Symbol, 0.0, tp_sel, 0, 0, "OD_S2_" + cur_click_prefix);
                        //m_trade.SellLimit(volume, next_entry_sel + amp_waste, _Symbol, 0.0, tp_sel, 0, 0, "OD_S3_" + cur_click_prefix);
                       }
                    }

                  Alert(msg+ ".");
                  break;

               case IDNO:
                  break;
              }
           }
         //-----------------------------------------------------------------------
         if(sparam == BtnOrderBuy)
           {
            if(count_order_buy > 0)
              {
               Alert(get_vntime(), " Đã có lệnh ORDER ", _Symbol);
               return;
              }

            double open_price = NormalizeDouble(lowest_close_21, digits);
            if(open_price > price - amp_waste)
               open_price = price - amp_waste;

            string msg = OPEN_ORDERS + AppendSpaces(TREND_BUY, 5) + _Symbol + "  vol: " + (string) volume + " lot";
            msg += "  Open: " + (string) open_price + "  TP: " + (string) tp_buy;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  //Alert(msg+ ".");
                  m_trade.BuyLimit(volume, open_price,                    _Symbol, 0.0, tp_buy, 0, 0, "OD_B1_" + cur_click_prefix);
                  //m_trade.BuyLimit(volume, next_entry_buy,              _Symbol, 0.0, tp_buy, 0, 0, "OD_B2_" + cur_click_prefix);
                  //m_trade.BuyLimit(volume, next_entry_buy - amp_waste,  _Symbol, 0.0, tp_buy, 0, 0, "OD_B3_" + cur_click_prefix);
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
               Alert(get_vntime(), " Đã có lệnh ORDER ", _Symbol);
               return;
              }

            double open_price = NormalizeDouble(higest_close_21, digits);
            if(open_price < price + amp_waste)
               open_price = price + amp_waste;

            string msg = OPEN_ORDERS + AppendSpaces(TREND_SEL, 5) + _Symbol + "  vol: " + (string) volume + " lot";
            msg += "  Open: " + (string) open_price + "  TP: " + (string) tp_sel;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  //Alert(msg+ ".");
                  m_trade.SellLimit(volume, open_price,                   _Symbol,  0.0, tp_sel, 0, 0, "OD_S1_" + cur_click_prefix);
                  //m_trade.SellLimit(volume, next_entry_sel,             _Symbol, 0.0, tp_sel, 0, 0, "OD_S2_" + cur_click_prefix);
                  //m_trade.SellLimit(volume, next_entry_sel + amp_waste, _Symbol, 0.0, tp_sel, 0, 0, "OD_S3_" + cur_click_prefix);
                  break;

               case IDNO:
                  break;
              }
           }

         Draw_Bottom_Msg();
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
                     //Alert("Position #", ticket, "   ", _Symbol, " was closed... profit: ", profit);
                     m_trade.PositionClose(ticket);
                    }
                 }
              }
           }

         Draw_Bottom_Msg();
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
                     //Alert("Order #" + (string) ticket+ "   " + m_order.TypeDescription() + "   " + _Symbol + "   " + comments);
                     m_trade.OrderDelete(ticket);
                    }
                 }
              }
           }

         Draw_Bottom_Msg();
        }

      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string find_switch_trend_wd(string symbol, string PREFIX_TRADE_XX)
  {
   ENUM_TIMEFRAMES TIME_FRAME = get_period(PREFIX_TRADE_XX);

   string find_trade = "";
   string trend_stoc_333 = get_trend_by_stoc(symbol, TIME_FRAME);

   if(PREFIX_TRADE_XX == PREFIX_TRADE_PERIOD_W1 && IsDojiHeikenAshi(symbol, PERIOD_W1, 0))
     {
      return SWITH_TREND_TYPE_DOJI + " " + PREFIX_TRADE_XX + " " + AppendSpaces(trend_stoc_333, 5) + symbol;
     }

   find_trade = get_switch_trend_by_heiken_3_0(symbol, TIME_FRAME);
   if((find_trade == trend_stoc_333))
      return SWITH_TREND_TYPE_HEIKEN + " " + PREFIX_TRADE_XX + " " + AppendSpaces(find_trade, 5) + symbol;

   if(is_allow_trade_now_by_stoc(symbol, TIME_FRAME, trend_stoc_333))
     {
      return SWITH_TREND_TYPE_STOCH + " " + PREFIX_TRADE_XX + " " + AppendSpaces(trend_stoc_333, 5) + symbol;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string find_switch_trend_hx(string symbol, string find_trade, string PREFIX_TRADE_XX)
  {
   ENUM_TIMEFRAMES TIME_FRAME = get_period(PREFIX_TRADE_XX);
   string PREFIX = get_prefix_trade_from_comments(PREFIX_TRADE_XX);
   if(PREFIX == "")
      PREFIX = PREFIX_TRADE_XX;
   PREFIX += " ";

   string msg = "";
   bool found = false;

   if((found == false) && is_allow_trade_now_by_stoc(symbol, TIME_FRAME, find_trade) && (find_trade == get_trend_by_stoc(symbol, TIME_FRAME)))
     {
      found = true;
      msg = SWITH_TREND_TYPE_STOCH + " " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_ma(symbol, TIME_FRAME, 6, 9)))
     {
      found = true;
      msg = SWITH_TREND_TYPE_MA69 + " " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_heiken_6_1(symbol, TIME_FRAME)))
     {
      found = true;
      msg = SWITH_TREND_TYPE_HEIKEN + " " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_heiken_and_ma_X_Y(symbol, TIME_FRAME, 6, 10)))
     {
      found = true;
      msg = SWITH_TREND_TYPE_MA10 + " " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if((found == false) && (find_trade == get_switch_trend_by_heiken_and_ma_X_Y(symbol, TIME_FRAME, 6, 20)))
     {
      found = true;
      msg = SWITH_TREND_TYPE_MA20 + " " + PREFIX + AppendSpaces(find_trade, 5);
     }

   if(StringFind(PREFIX_TRADE_PERIOD_H4 + PREFIX_TRADE_PERIOD_H1 + PREFIX_TRADE_PERIOD_M5, PREFIX_TRADE_XX) >= 0)
     {
      if((found == false) && (find_trade == get_switch_trend_by_seq_6_10_20_50(symbol, TIME_FRAME)))
        {
         found = true;
         msg = SWITH_TREND_TYPE_SEQ + " " + PREFIX + AppendSpaces(find_trade, 5);
        }
     }

   if(msg != "")
      msg += symbol;

   return msg;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Take_Profit(string symbol, string append)
  {
   string msg = "";
   double profit = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            if(m_position.Profit() > 1)
              {
               msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
               profit += m_position.Profit();
               //m_trade.PositionClose(m_position.Ticket());
              }
           }
        }
     } //for

   if(msg != "")
     {
      SendTelegramMessage(symbol, "TAKE_PROFIT", "(TAKE.PROFIT) H4 " + msg + " Total: " + (string) profit + "$ " + append);
     }
  }
//
double calc_tp_price(string symbol, string trading_trend)
  {
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
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Exit_Trade(string symbol, string TRADING_TREND)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();

            if(toLower(m_position.TypeDescription()) == toLower(TREND_BUY))
               m_trade.PositionClose(ticket);

            if(toLower(m_position.TypeDescription()) == toLower(TREND_SEL))
               m_trade.PositionClose(ticket);
           }
        }
     }
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
      result += AppendSpaces(TRADE_COUNT_POSITION_B + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_buy, 2), 20) + "  P:" + AppendSpaces(format_double_to_string(profit_buy, 2) + "$", 7, false);

   if(pos_sel > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_S + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_sel, 2), 20) + "  P:" + AppendSpaces(format_double_to_string(profit_sel, 2) + "$", 7, false);

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
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size, int z_index=999)
  {
   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }


   StringTrimLeft(text);
   StringTrimRight(text);
   StringReplace(text, TREND_BUY, "B");
   StringReplace(text, TREND_SEL, "S");
   StringReplace(text, "  ", " ");
   StringReplace(text, "  ", " ");
   StringReplace(text, "  ", " ");
   StringReplace(text, "(", "");
   StringReplace(text, ")", "");
   StringReplace(text, " ", "_");
   StringTrimLeft(text);
   StringTrimRight(text);

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
string get_trend_by_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close_1 = closePrices[1];
   double ma = cal_MA(closePrices, ma_index, 1);

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
string get_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int maLength = MathMax(ma_index_6, ma_index_9) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }
   double ma_6_1 = cal_MA(closePrices, ma_index_6, 1);
   double ma_6_2 = cal_MA(closePrices, ma_index_6, 2);
   double ma_9_1 = cal_MA(closePrices, ma_index_9, 1);
   double ma_9_2 = cal_MA(closePrices, ma_index_9, 2);


   if(ma_6_1 >= ma_9_1 && ma_6_2 <= ma_9_2)
      return TREND_BUY;

   if(ma_6_1 <= ma_9_1 && ma_6_2 >= ma_9_2)
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
      double haOpen  = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen, haClose), iHigh(symbol, TIME_FRAME, index));
      double haLow   = MathMin(MathMin(haOpen, haClose),  iLow(symbol, TIME_FRAME, index));

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

   string haTrend0 = candleArray[0].trend;
   string haTrend1 = candleArray[1].trend;
   string haTrend2 = candleArray[2].trend;
   if(haTrend0 == haTrend1 && haTrend1 != haTrend2 && candleArray[2].count > 3)
     {
      return haTrend1;
     }

   if(candleArray[2].count > 5 && IsDojiHeikenAshi(symbol, TIME_FRAME, 1))
     {
      return candleArray[2].trend == TREND_BUY ? TREND_SEL : TREND_BUY;
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
   if(haTrend0 != haTrend1 && candleArray[1].count > 2)
     {
      return haTrend0;
     }

   if(candleArray[1].count > 3 && IsDojiHeikenAshi(symbol, TIME_FRAME, 0))
     {
      return candleArray[1].trend == TREND_BUY ? TREND_SEL : TREND_BUY;
     }

   return "";
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
string get_switch_trend_by_heiken_and_ma_X_Y(string symbol, ENUM_TIMEFRAMES timeframe, int fast_ma=6, int slow_ma = 10)
  {
   int maLength = MathMax(fast_ma, slow_ma) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma6_0 = cal_MA(closePrices, fast_ma, 0);
   double ma6_1 = cal_MA(closePrices, fast_ma, 1);
   double ma10 = cal_MA(closePrices, slow_ma, 0);

   CandleData candleArray[];
   get_arr_heiken(symbol, timeframe, candleArray);

   string pre_haTrend = candleArray[1].trend;
   string cur_haTrend = candleArray[0].trend;
   double haOpen1     = candleArray[1].open;
   double haClose1    = candleArray[1].close;

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
bool is_continue_hode_postion_by_ma_6_9_20(string symbol, ENUM_TIMEFRAMES timeframe, string trading_trend)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_6 = cal_MA(closePrices, 6, 0);
   double ma_10 = cal_MA(closePrices, 10, 0);
   double ma_20 = cal_MA(closePrices, 20, 0);

   if((trading_trend == TREND_BUY) && (ma_6 >= ma_10) && (ma_10 >= ma_20))
      return true;

   if((trading_trend == TREND_SEL) && (ma_6 <= ma_10) && (ma_10 <= ma_20))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_seq_6_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_seq_ma10_20_50 = "";

   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_6_0 = cal_MA(closePrices, 6, 0);
   double ma_6_1 = cal_MA(closePrices, 6, 1);

   double ma_9 = cal_MA(closePrices, 9, 0);
   double ma_20 = cal_MA(closePrices, 20, 0);
   double ma_50 = cal_MA(closePrices, 50, 0);

   double close = iClose(symbol, timeframe, 0);


   if((ma_6_0 > ma_6_1) && (ma_6_0 > ma_9) && (ma_6_0 > ma_20))
      if((close > ma_9) && (close > ma_20) && (close > ma_50) && (ma_9 > ma_20))
         trend_seq_ma10_20_50 = TREND_BUY;

   if((ma_6_0 < ma_6_1) && (ma_6_0 < ma_9) && (ma_6_0 < ma_20))
      if((close < ma_9) && (close < ma_20) && (close < ma_50) && (ma_9 < ma_20))
         trend_seq_ma10_20_50 = TREND_SEL;


   if(trend_seq_ma10_20_50 != "")
     {
      double lowest = iLow(symbol, timeframe, 1);
      double higest = iHigh(symbol, timeframe, 1);
      double high = (higest - lowest)/2;

      if(trend_seq_ma10_20_50 == TREND_SEL)
         lowest = lowest - high;

      if(trend_seq_ma10_20_50 == TREND_BUY)
         higest = higest + high;

      if((lowest <= ma_50) && (ma_50 <= higest))
        {
         return trend_seq_ma10_20_50;
        }
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i < ma_index; i++)
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
   string vntime = "(" + str_date_time + ")    " + cpu + "   " + INDI_NAME + "   ";
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
//string get_trend_consensus_by_long_term_and_short_term_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
//  {
//   string trend_long_term = get_trend_by_stoc(symbol, timeframe, 12, 6, 9);
//   string trend_shot_term = get_trend_by_stoc(symbol, timeframe,  5, 3, 3);
//
//   if(trend_long_term == trend_shot_term)
//      return trend_long_term;
//
//   return "";
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   if(K[1] > D[1])
      return TREND_SEL;

   if(K[1] < D[1])
      return TREND_BUY;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend)
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
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string trend)
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

   if(trend == TREND_BUY && black_K > red_D && black_K <= 20 && red_D <= 20)
      return true;

   if(trend == TREND_SEL && black_K < red_D && black_K >= 80 && red_D >= 80)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe)
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
void DrawIndicators()
  {
   string symbol = Symbol();

   iMA(symbol,PERIOD_CURRENT,6,0,MODE_SMA,PRICE_CLOSE);
   iMA(symbol,PERIOD_CURRENT,9,0,MODE_SMA,PRICE_CLOSE);
   iBands(symbol,PERIOD_CURRENT, 20, 0, 2, PRICE_CLOSE);


   datetime label_postion = iTime(symbol, _Period, 0);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   string tradingview_symbol = _Symbol;
   StringReplace(tradingview_symbol, ".cash", "");

   double d1_ma10 = cal_MA_XX(symbol, PERIOD_D1, 9, 0); //get_ma_value(symbol, PERIOD_D1, 10, 0);
   double h4_ma50 = cal_MA_XX(symbol, PERIOD_H4, 50, 0); //get_ma_value(symbol, PERIOD_H4, 50, 0);
   create_lable_trim("d1_ma10", label_postion, d1_ma10, "   -------------D(9) " + tradingview_symbol, clrGreen, digits, 9);
   create_lable_trim("h4_ma50", label_postion, h4_ma50, "   ---H4(50)", clrGreen, digits, 9);

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

   double upper_15[], middle_15[], lower_15[];
   CalculateBollingerBands(symbol, PERIOD_M15, upper_15, middle_15, lower_15, digits, 1);
   double mi_15_20_0 = middle_15[0];
   double amp_15 = MathAbs(upper_15[0] - middle_15[0]);
   double hi_15_20_2 = mi_15_20_0 + amp_15*2;
   double lo_15_20_2 = mi_15_20_0 - amp_15*2;
   create_lable_trim("Hi_M15(20, 2)", label_postion, hi_15_20_2, str_line + "---------------------------15+2", clrGreen, digits);
   create_lable_trim("Lo_M15(20, 2)", label_postion, lo_15_20_2, str_line + "---------------------------15-2", clrGreen, digits);

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 1);
   double mi_h4_20_0 = middle_h4[0];
   double amp_h4 = MathAbs(upper_h4[0] - middle_h4[0]);

   double hi_h4_20_2 = mi_h4_20_0 + amp_h4*2;
   double lo_h4_20_2 = mi_h4_20_0 - amp_h4*2;

   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, str_line + "---------H4+2", clrGreen, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, str_line + "---------H4-2", clrGreen, digits);
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
   const int               font_size=8
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, label, clr_color);
   ObjectSetInteger(0,"redrw_" + name, OBJPROP_FONTSIZE,font_size);
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
   ObjectSetString(chart_ID,name,OBJPROP_TEXT, text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT, font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE, angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, z_order);
   return(true);
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
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &dic_amp_init_h4, double &dic_amp_init_d1)
  {
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.05;
      amp_w = 1357.35;
      dic_amp_init_h4 = 0.03;
      return;
     }

   if(is_same_symbol(symbol, "USOIL"))
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.10;
      amp_w = 2.75;
      dic_amp_init_h4 = 0.05;
      return;
     }

   if(is_same_symbol(symbol, "XAGUSD"))
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.06;
      amp_w = 0.63500;
      dic_amp_init_h4 = 0.03;
      return;
     }

   if(is_same_symbol(symbol, "XAUUSD"))
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.03;
      amp_w = 27.83;
      dic_amp_init_h4 = 0.015;
      return;
     }

   if(is_same_symbol(symbol, "US500"))
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.05;
      amp_w = 60.00;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "US100.cash") || is_same_symbol(symbol, "USTEC"))
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.05;
      amp_w = 274.5;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "US30"))
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.05;
      amp_w = 438.76;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "UK100"))
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.05;
      amp_w = 95.38;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "GER40"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "DE30"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "FRA40") || is_same_symbol(symbol, "FR40"))
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "AUS200"))
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
      amp_w = 93.59;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "AUDJPY"))
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.100;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "AUDUSD"))
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.015;
      return;
     }

   if(is_same_symbol(symbol, "EURAUD"))
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01365;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "EURGBP"))
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00497;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "EURUSD"))
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0080;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "GBPUSD"))
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      dic_amp_init_h4 = 0.01;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00795;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "USDCHF"))
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00750;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "USDJPY"))
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.4250;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "CADCHF"))
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(is_same_symbol(symbol, "CADJPY"))
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.0250;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "CHFJPY"))
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.365000;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "EURJPY"))
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.43500;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "GBPJPY"))
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.61500;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "NZDJPY"))
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.90000;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "EURCAD"))
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00945;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "EURCHF"))
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "EURNZD"))
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01585;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "GBPAUD"))
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01575;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "GBPCAD"))
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "GBPCHF"))
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0085;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "GBPNZD"))
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.016250;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "AUDCAD"))
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "AUDCHF"))
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.005805;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "AUDNZD"))
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00595;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "NZDCAD"))
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.007200;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "NZDCHF"))
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "NZDUSD"))
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(is_same_symbol(symbol, "DXY"))
     {
      i_top_price = 103.458;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.6995;
      dic_amp_init_h4 = 0.01;
      return;
     }

   i_top_price = iClose(symbol, PERIOD_W1, 1);
   dic_amp_init_d1 = 0.02;
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   dic_amp_init_h4 = 0.01;

   Alert(INDI_NAME, " Get SymbolData:",  symbol,"   i_top_price: ", i_top_price, "   amp_w: ", amp_w, "   dic_amp_init_h4: ", dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
