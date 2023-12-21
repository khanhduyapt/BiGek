//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//#include <MovingAverages.mqh>
//D:\01_Projects\ScanBinance\bsc_scan_binance\src\main\resources\MQL5\backup\GuardianAngel_ver1.0\utils.mq5

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string INDI_NAME = "DailyRange";
double dbRiskRatio = 0.001; // Rủi ro 0.1%
double INIT_EQUITY = 4000.0; // Vốn ban đầu 200$

string TREND_BUY = "BUY";
string TREND_SEL = "SEL";

string arr_symbol[] = {"XAUUSD", "XAGUSD"
                       ,"BTCUSD" // , "ETHUSD"
                       ,"US30.cash", "US100.cash", "USOIL.cash"
                       ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
                       ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
                       ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
                       ,"NZDCAD", "NZDJPY", "NZDUSD"
                       ,"USDCAD", "USDJPY", "CADJPY" //, "USDCHF"
                      };

string open_message_this_hour = "";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   WriteNotifyToken();
   EventSetTimer(900); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   WriteNotifyToken();
  }

//+------------------------------------------------------------------+
void WriteNotifyToken()
  {
   ObjectsDeleteAll();

   if(Period() <= PERIOD_H1)
      DrawBB();

   double risk_per_trade = calcRiskPerTrade();

   string pin_bar_d1 = "";
   string switch_trend_d1 = "";
   string cutting_ma10 = "";
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);

      //------------------------------------------------------------------
      double dic_top_price;
      double dic_amp_w;
      double dic_lot_size;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
      double week_amp = dic_amp_w;

      double volume = dblLotsRisk(symbol, week_amp, risk_per_trade);

      string vol_buy = " " + AppendSpaces(format_double_to_string(price, digits)) + " Vol: " + format_double_to_string(volume, 2) + " SL(B): " + format_double_to_string(price - week_amp, digits) + "/" + (string) risk_per_trade + "$\n";
      string vol_sel = " " + AppendSpaces(format_double_to_string(price, digits)) + " Vol: " + format_double_to_string(volume, 2) + " SL(S): " + format_double_to_string(price + week_amp, digits) + "/" + (string) risk_per_trade + "$\n";
      //------------------------------------------------------------------

      /*
            CandleData candle_heiken_d1;
            CountHeikenList(symbol, PERIOD_D1, 1, candle_heiken_d1);

            CandleData candle_heiken_h4;
            CountHeikenList(symbol, PERIOD_H4, 1, candle_heiken_h4);

            CandleData candle_heiken_h1;
            CountHeikenList(symbol, PERIOD_H1, 1, candle_heiken_h1);
            string trend_stoch_h1_333 =  get_trend_stoc(symbol, PERIOD_H1, 3, 3, 3);

            string main_trend_h4 = trend_of_histogram_vs_signal(symbol, PERIOD_H4, 18, 36, 9);
            string trend_stoch_h4_333 =  get_trend_stoc(symbol, PERIOD_H4, 3, 3, 3);
            string trend_stoch_h4_1385 =  get_trend_stoc(symbol, PERIOD_H4, 13, 8, 5);

            int count = 0;
            int count_pos = 0;
            string lowcase_symbol = toLower(symbol);

            for(int i = OrdersTotal() - 1; i >= 0; i--)
              {
               ulong orderTicket = OrderGetTicket(i);

               string order_symbol = OrderGetString(ORDER_SYMBOL);
               order_symbol = toLower(order_symbol);

               if(lowcase_symbol == order_symbol)
                 {
                  count = count + 1;
                 }
              }

            for(int i = PositionsTotal() - 1; i >= 0; i--)
              {
               string trading_symbol = PositionGetSymbol(i);
               trading_symbol = toLower(trading_symbol);

               if(lowcase_symbol == trading_symbol)
                 {
                  count = count + 1;
                  count_pos = count_pos + 1;
                  double profit = PositionGetDouble(POSITION_PROFIT);


                  string trade_trend = "";

                  long type = PositionGetInteger(POSITION_TYPE);

                  if((type == POSITION_TYPE_BUY) && (main_trend_h4 == TREND_SEL) && (trend_stoch_h4_333 == TREND_SEL || trend_stoch_h4_1385 == TREND_SEL))
                     trade_trend = TREND_BUY;

                  if((type == POSITION_TYPE_SELL) && (main_trend_h4 == TREND_BUY) && (trend_stoch_h4_333 == TREND_BUY || trend_stoch_h4_1385 == TREND_BUY))
                     trade_trend = TREND_SEL;

                  if(trade_trend != "" && profit > 0)
                    {
                     if(is_open_this_candle_h4(symbol) == false)
                       {
                        add_open_trade_today(symbol);
                        Alert(get_vntime() + "   TAKE_PROFIT  ", trade_trend, "    ", symbol, "   STOC: ", trend_stoch_h4_333, "  Profit: ", profit);
                       }
                    }

                 }
              }

            string opening = "";
            if(count > 0 && count_pos > 0)
               opening = " (Open)";
            else
               if(count > 0 && count_pos == 0)
                  opening = " (Limit)";

            bool allow_allert = true;
            if(count == 0 && candle_heiken_h4.trend == candle_heiken_h1.trend)
              {

               double SMA_20_Buffer[];
               ArraySetAsSeries(SMA_20_Buffer, true);
               int SMA_20_Handle = iMA(symbol,PERIOD_H4,20,0,MODE_SMA,PRICE_CLOSE);
               if(CopyBuffer(SMA_20_Handle,0,0,5,SMA_20_Buffer)<=0)
                  continue;

               double SMA_50_Buffer[];
               ArraySetAsSeries(SMA_50_Buffer, true);
               int SMA_50_Handle = iMA(symbol,PERIOD_H4,50,0,MODE_SMA,PRICE_CLOSE);
               if(CopyBuffer(SMA_50_Handle,0,0,5,SMA_50_Buffer)<=0)
                  continue;

               double ma20 = SMA_20_Buffer[0];
               double ma50 = SMA_50_Buffer[0];

               string show_msg_open_trade = "";
               if(ma20 > ma50 && candle_heiken_h4.trend == TREND_BUY && candle_heiken_h4.count<=2 && is_stoc_allow_trade_now(symbol, PERIOD_H1, TREND_BUY) && trend_stoch_h4_1385 == TREND_BUY && trend_stoch_h4_333 == TREND_BUY)
                 {
                  show_msg_open_trade = " OPEN_TRADE    "  + symbol + "   " + candle_heiken_h4.trend + "   (" + (string) candle_heiken_h4.count + ")" + vol_buy;
                 }
               if(ma20 < ma50 && candle_heiken_h4.trend == TREND_SEL && candle_heiken_h4.count<=2 && is_stoc_allow_trade_now(symbol, PERIOD_H1, TREND_SEL) && trend_stoch_h4_1385 == TREND_SEL && trend_stoch_h4_333 == TREND_SEL)
                 {
                  show_msg_open_trade = " OPEN_TRADE    "  + symbol + "   " + candle_heiken_h4.trend + "   (" + (string) candle_heiken_h4.count + ")" + vol_buy;
                 }

               if(show_msg_open_trade != "" && is_open_this_candle_h4(symbol + candle_heiken_h4.trend) == false)
                 {
                  add_open_trade_today(symbol + (string)candle_heiken_h4.trend);
                  cutting_ma10 += (get_vntime() + show_msg_open_trade);
                 }
              }
            else
               allow_allert = false;


            //----------------------------------------------------

            string symbol_len_15 = AppendSpaces(symbol, 15);
            if(count == 0 && candle_heiken_h4.trend == candle_heiken_h1.trend)
              {
               string check_trend_by_stoch_d8 =  get_trend_stoc(symbol, PERIOD_D1, 8, 5, 3);
               string check_trend_by_stoch_d5 =  get_trend_stoc(symbol, PERIOD_D1, 5, 3, 3);

               if(check_trend_by_stoch_d8 == check_trend_by_stoch_d5 && check_trend_by_stoch_d8 == candle_heiken_h4.trend && check_trend_by_stoch_d8 == get_trend_stoc(symbol, PERIOD_H4, 8, 5, 3))
                 {
                  if(check_trend_by_stoch_d5 == get_trend_stoc(symbol, PERIOD_W1, 5, 3, 3))
                    {
                     string msg_alert = "";
                     if((check_trend_by_stoch_d8 == TREND_BUY) && (check_trend_by_stoch_d5  == TREND_BUY))
                       {
                        if(symbol == _Symbol)
                           msg_alert = "*  ";
                        else
                           msg_alert = "    ";
                        msg_alert += AppendSpaces(TREND_BUY) + symbol_len_15 + vol_buy;
                       }

                     if((check_trend_by_stoch_d8 == TREND_SEL) && (check_trend_by_stoch_d5  == TREND_SEL))
                       {
                        if(symbol == _Symbol)
                           msg_alert = "*  ";
                        else
                           msg_alert = "    ";
                        msg_alert +=  AppendSpaces(TREND_SEL) + symbol_len_15 + vol_sel;
                       }

                     if(msg_alert != "")
                       {
                        pin_bar_d1 += msg_alert;

                        if(allow_allert && is_open_this_candle_h4(symbol) == false)
                          {
                           add_open_trade_today(symbol);
                           //Alert(get_vntime() + msg_alert);
                           //cutting_ma10 += msg_alert;
                          }
                       }
                    }
                 }
              }


            string trend_heiken_d1_0 = get_trend_by_heiken(symbol, PERIOD_D1, 0);
            string trend_heiken_w1_0 = get_trend_by_heiken(symbol, PERIOD_W1, 0);
            if(trend_heiken_d1_0 != trend_heiken_w1_0)
               continue;

            //------------------------------------------------------------------


            double ma10_d1 = CalculateMA_XX(symbol, PERIOD_D1, 10, 1);
            double ma50_h1 = CalculateMA_XX(symbol, PERIOD_H1, 50, 1);

            double close_prices_c1 = iClose(symbol, PERIOD_D1, 1);
            bool is_buy = close_prices_c1 >= ma10_d1;
            bool is_sel = close_prices_c1 <= ma10_d1;

            string trend_h4 = get_trend_by_heiken(symbol, PERIOD_H4, 1);
            string trend_h1 = get_trend_by_heiken(symbol, PERIOD_H1, 1);
            string trend_15 = get_trend_by_heiken(symbol, PERIOD_M15, 1);

            double hiPrice = iHigh(symbol, PERIOD_D1, 1);
            double loPrice = iLow(symbol, PERIOD_D1,  1);

            string cur_message = "";

            if(candle_heiken_h4.count == 1)
              {
               if(cur_message == "" && candle_heiken_d1.count == 1 && candle_heiken_d1.trend == candle_heiken_h4.trend)
                 {
                  cur_message = "(Count D1=1) Heiken: " + candle_heiken_h4.trend + "   " + symbol;
                 }
               if(cur_message == "" && trend_heiken_w1_0 == candle_heiken_h4.trend)
                 {
                  cur_message = "(W0=H4) Heiken: " + candle_heiken_h4.trend + "   " + symbol;
                 }

               if(cur_message == "" && trend_heiken_d1_0 == candle_heiken_h4.trend)
                 {
                  cur_message = "(D0=H4) Heiken: " + candle_heiken_h4.trend + "   " + symbol;
                 }
               // Alert(get_vntime() + "(" + INDI_NAME + ") " + cur_message);
              }

            if(loPrice <= ma10_d1 && ma10_d1 <= hiPrice)
              {
               if(cur_message == "" && is_buy && trend_heiken_w1_0 == TREND_BUY)  // && price <= ma50_h1 && trend_15 == TREND_BUY
                 {
                  cur_message = "    (D1)    (B) " + symbol;
                 }

               if(cur_message == "" && is_sel && trend_heiken_w1_0 == TREND_SEL)  // && price >= ma50_h1 && trend_15 == TREND_SEL
                 {
                  cur_message = "    (D1)    (S) " + symbol;
                 }
              }
            //-------------------------------------------------------------------------
            if(cur_message == "" && is_buy && price <= ma50_h1  && trend_heiken_w1_0 == TREND_BUY) // && trend_h1 == TREND_BUY  && trend_15 == TREND_BUY
              {
               cur_message = "    (H4)    (B) " + symbol;
              }

            if(cur_message == "" && is_sel && price >= ma50_h1  && trend_heiken_w1_0 == TREND_SEL) // && trend_h1 == TREND_SEL && trend_15 == TREND_SEL
              {
               cur_message = "    (H4)    (S) " + symbol;
              }

            if(cur_message != "" && opening == "" && allow_trade_by_amp_50candle(symbol, trend_heiken_w1_0))
              {
               if(is_open_this_candle_h4(symbol) == false)
                 {
                  add_open_trade_today(symbol);

                  if(trend_heiken_w1_0 == TREND_BUY)
                     cur_message += vol_buy;

                  if(trend_heiken_w1_0 == TREND_SEL)
                     cur_message += vol_sel;

                  cutting_ma10 += cur_message;
                 }
              }
      */
      //-------------------------------------------------------------------------
     }

   WriteComment(cutting_ma10);

   DrawDailyPivot();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteComment(string append)
  {
   string trend_cur_period = "____";
   if(Period() < PERIOD_D1)
      trend_cur_period = "Macd: (" + trend_of_histogram_vs_signal(_Symbol, PERIOD_CURRENT, 18, 36, 9) + ")";
   else
      trend_cur_period = "Stoc: (" +get_trend_stoc(_Symbol, PERIOD_CURRENT, 3, 3, 3) + ")";

   double risk_per_trade = calcRiskPerTrade();

   double dic_top_price;
   double dic_amp_w;
   double dic_lot_size;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_lot_size);
   double week_amp = dic_amp_w;
   string volume = format_double_to_string(dblLotsRisk(_Symbol, week_amp, risk_per_trade), 2);

   CandleData candle_heiken;
   CountHeikenList(_Symbol, PERIOD_CURRENT, 1, candle_heiken);

   string str_comments = get_vntime() + "(" + INDI_NAME + ") " + _Symbol + "    " + GetCurrentTimeframeToString() + "    " + trend_cur_period;

   str_comments += "    Heiken(" + candle_heiken.trend + ")" + (string) candle_heiken.count;

   str_comments += "    Vol: " + volume + "/" + (string) risk_per_trade + "$/" + (string)(dbRiskRatio * 100) + "%    amp: " + (string) NormalizeDouble(week_amp, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));

   str_comments += "    Switch(" + GetCurrentTimeframeToString() + "): " + get_trend_stoc(_Symbol, PERIOD_H4, 3, 2, 3) + " " + (string) get_candle_switch_trend_stoch(_Symbol, PERIOD_H4, 3, 2, 3, 1);

   string find_switch_trend = "";
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int count = get_candle_switch_trend_stoch(symbol, PERIOD_H4, 3, 2, 3, 1);

      if(count <= 2)
        {
         int points = 0;
         string str_agree = "";
         bool allow_trade_now = false;
         string trend_new = get_trend_stoc(symbol, PERIOD_H4, 3, 2, 3);

         allow_trade_now = is_stoc_allow_trade_now(symbol, PERIOD_H4, trend_new, 8, 5, 3);
         if(allow_trade_now)
           {
            points += 1;
            str_agree += "H8 ";
           }

         allow_trade_now = is_stoc_allow_trade_now(symbol, PERIOD_H4, trend_new, 13, 8, 5);
         if(allow_trade_now)
           {
            points += 1;
            str_agree += "H13 ";
           }


         allow_trade_now = is_stoc_allow_trade_now(symbol, PERIOD_D1, trend_new, 3, 2, 3);
         if(allow_trade_now)
           {
            points += 1;
            str_agree += "D3 ";
           }

         allow_trade_now = is_stoc_allow_trade_now(symbol, PERIOD_D1, trend_new, 8, 5, 3);
         if(allow_trade_now)
           {
            points += 1;
            str_agree += "D8 ";
           }


         allow_trade_now = is_stoc_allow_trade_now(symbol, PERIOD_D1, trend_new, 13, 8, 5);
         if(allow_trade_now)
           {
            points += 1;
            str_agree += "D13 ";
           }

         if(points > 1)
           {
            find_switch_trend += "    " + symbol + "    " + trend_new + "    " + str_agree + ";";
           }
        }
     }

//if(find_switch_trend != "")
//   Alert(get_vntime() + "(" + INDI_NAME + ") " + find_switch_trend);

   StringReplace(find_switch_trend, ";", "\n");
   str_comments += "\n" + find_switch_trend;

   double total_profit_today = get_profit_today();
   str_comments += "\nProfit Today:" + format_double_to_string(total_profit_today, 2) + "$";

   Comment(str_comments);
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

//+------------------------------------------------------------------+
string get_trend_stoc(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
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

   if((black_K > red_D))
      return TREND_BUY;

   if((black_K < red_D))
      return TREND_SEL;

   return (K[1] >= D[1]) ? TREND_BUY : TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
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

   if((find_trend == TREND_BUY) && ((black_K <= 25) || (red_D <= 25)))
      return true;

   if((find_trend == TREND_SEL) && ((black_K >= 75) || (red_D >= 75)))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
int get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing, int start_index)
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

   for(int i = start_index; i < ArraySize(K) - 1; i++)
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
string trend_of_histogram_vs_signal(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal = 9)
  {
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_WEIGHTED);
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

   double main_black_1 = m_buff_MACD_main[1];
   double main_black_2 = m_buff_MACD_main[2];

   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[2];
//-------------------------------------------------
   if((main_black_1 > main_black_2) && (m_signal_1 > m_signal_2) && (main_black_1 > m_signal_1) && (main_black_2 > m_signal_2))
      return TREND_BUY;

   if((main_black_1 < main_black_2) && (m_signal_1 < m_signal_2) && (main_black_1 < m_signal_1) && (main_black_2 < m_signal_2))
      return TREND_SEL;

   return "____";
  }


//+------------------------------------------------------------------+
void DrawDailyPivot()
  {
   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

//--------------------------------------------------------------------
   /*
      double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
      CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
      double hi_h1_20_1 = upper_h1_20_1[0];
      double mi_h1_20_0 = middle_h1_20_1[0];
      double lo_h1_20_1 = lower_h1_20_1[0];
      double amp = MathAbs(hi_h1_20_1 - mi_h1_20_0);

      double upper_h4[], middle_h4[], lower_h4[];
      CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
      double hi_h4_20_2 = upper_h4[0];
      double lo_h4_20_2 = lower_h4[0];
      create_lable_trim("Hi_H4(20, 2)", today_close_time, hi_h4_20_2, "--------------------------------H4(+2)", clrRed, digits);
      create_lable_trim("Lo_H4(20, 2)", today_close_time, lo_h4_20_2, "--------------------------------H4(-2)", clrRed, digits);
      create_trend_line("hi_h4_20_2", today_open_time, today_close_time, hi_h4_20_2, clrRed, digits, false, false, true);
      create_trend_line("lo_h4_20_2", today_open_time, today_close_time, lo_h4_20_2, clrRed, digits, false, false, true);

      create_lable_trim("lbl_mi_h1_20_0", today_close_time, mi_h1_20_0, " (00) "+ format_double_to_string(mi_h1_20_0, digits), clrRed, digits);
      create_trend_line("mi_h1_20_0", today_open_time, today_close_time, mi_h1_20_0, clrRed, digits, false, false);
      ObjectSetInteger(0, "mi_h1_20_0", OBJPROP_STYLE, STYLE_DASH);
      for(int i = 1; i<=5; i++)
        {
         bool is_solid = (i==2) || (i==4) ? true : false;
         color line_color = clrBlack;
         if(i == 1)
            line_color = clrDimGray;
         if(i == 2)
            line_color = clrBlue;
         if(i == 3)
            line_color = clrMediumSeaGreen;
         if(i == 4)
            line_color = clrBlack;
         if(i == 5)
            line_color = clrRed;
         double hi_h1_20_i = mi_h1_20_0 + (i*amp);
         double lo_h1_20_i = mi_h1_20_0 - (i*amp);
         create_lable_trim("lbl_hi_h1_20_" + (string)i, today_close_time, hi_h1_20_i, " (+" + (string)i + ") "+ format_double_to_string(hi_h1_20_i, digits), line_color, digits);
         create_lable_trim("lbl_lo_h1_20_" + (string)i, today_close_time, lo_h1_20_i, " (-" + (string)i + ") "+ format_double_to_string(lo_h1_20_i, digits), line_color, digits);
         create_trend_line("lo_h1_20_" + (string)i, today_open_time, today_close_time, lo_h1_20_i, line_color, digits, false, false, is_solid);
         create_trend_line("hi_h1_20_" + (string)i, today_open_time, today_close_time, hi_h1_20_i, line_color, digits, false, false, is_solid);
        }
   */
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
//   if(chartPeriod <= PERIOD_H4)
//     {
//      VLineCreate(0, "close_time_today", 0, close_time_today);
//
//      for(int index = 0; index < 30; index ++)
//        {
//         VLineCreate(0, "d"+ (string)index + "_c_time", 0, iTime(symbol, PERIOD_D1, index));
//        }
//     }
// -----------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_lot_size;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
   double week_amp = dic_amp_w;
//double week_amp = calc_avg_amp_week(symbol, 20);

   double d_amp = week_amp / 2.0;

   int total_candle = 50;
   double total_amp_h4 = 0.0;
   double amp_max_d1 = 0.0;
   double amp_avg_d1 = 0.0;
   for(int index = 1; index <= total_candle; index ++)
     {
      double   tmp_hig_h4         = iHigh(symbol, PERIOD_H4, index);
      double   tmp_low_h4         = iLow(symbol, PERIOD_H4, index);
      total_amp_h4 += (tmp_hig_h4 - tmp_low_h4);

      double   tmp_hig_d1         = iHigh(symbol, PERIOD_D1, index);
      double   tmp_low_d1         = iLow(symbol, PERIOD_D1, index);

      if(amp_max_d1 == (tmp_hig_d1 - tmp_low_d1))
        {
         amp_max_d1 = (tmp_hig_d1 - tmp_low_d1);
        }
      amp_avg_d1 += (tmp_hig_d1 - tmp_low_d1);
     }

   double amp_avg_h4 = format_double(total_amp_h4 / total_candle, digits);
   amp_avg_d1 = format_double(amp_avg_d1 / total_candle, digits);

// -----------------------------------------------------------------------
// sleep_time
   if(chartPeriod <= PERIOD_H1)
     {
      for(int index = 0; index <= 5; index ++)
        {
         datetime tmp_open_time   = iTime(symbol, PERIOD_D1, index);
         datetime tmp_open_08am   = tmp_open_time + 3600;
         datetime tmp_close_time  = tmp_open_time + 86400;

         double   tmp_open_price  = iOpen(symbol, PERIOD_D1, index);
         double   tmp_close_price = iClose(symbol, PERIOD_D1, index);

         MqlDateTime struct_open_time;
         TimeToStruct(tmp_open_time, struct_open_time);
         string   prefix = date_time_to_string(struct_open_time);

         double   tmp_low_price = iLow(symbol, PERIOD_D1, index);
         double   tmp_hig_price = iHigh(symbol, PERIOD_D1, index);
         RectangleCreate(0, prefix + "_sleep_time", tmp_open_time, tmp_low_price, tmp_open_08am, tmp_hig_price, STYLE_DOT, 1, true, true, false, true, 0, clrGainsboro);
        }
     }


     {
      datetime week_time_1 = iTime(symbol, PERIOD_W1, 1);
      //      datetime week_time_0 = iTime(symbol, PERIOD_W1, 0) - 86400;
      //
      //      double w_open = iOpen(symbol, PERIOD_W1, 1);
      //      create_trend_line("w_open", week_time_1, week_time_0, w_open, clrBlack, digits, false);
      //      ObjectSetInteger(0, "w_open", OBJPROP_STYLE, STYLE_DASH);
      //      ObjectSetInteger(0, "w_open", OBJPROP_WIDTH, 2);
      //
      //      double w_close = iClose(symbol, PERIOD_W1, 1);
      //      create_trend_line("w_close", week_time_1, week_time_0, w_close, clrBlack, digits, false);
      //      ObjectSetInteger(0, "w_close", OBJPROP_STYLE, STYLE_DASH);
      //      ObjectSetInteger(0, "w_close", OBJPROP_WIDTH, 2);

      //Print(symbol, " init:",  dic_top_price, " amp:", week_amp);
      for(int index = 0; index < 25; index ++)
        {
         color line_color = clrBlack;
         bool is_solid = false;
         if(index == 0)
           {
            is_solid = true;
           }
         double w_s1  = dic_top_price - (week_amp*index);
         create_trend_line("w_dn_" + (string)index, week_time_1, TimeGMT(), w_s1, line_color, digits, true, true, is_solid);

         double w_r1  = dic_top_price + (week_amp*index);
         create_trend_line("w_up_" + (string)index, week_time_1, TimeGMT(), w_r1, line_color, digits, true, true, is_solid);
        }
     }

// ----------------------------------------------------------------------
  }

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



// Hàm tính giá trị tối đa và tối thiểu của 50 cây nến gần nhất
void CalculateMaxMinPrices(string symbol, ENUM_TIMEFRAMES timeframe, double &maxPrice, double &minPrice)
  {
   maxPrice = -DBL_MAX; // Khởi tạo giá trị max với giá trị nhỏ nhất
   minPrice = DBL_MAX; // Khởi tạo giá trị min với giá trị lớn nhất

   int candlesToCheck = 50; // Số cây nến cần xem xét

   for(int i = 0; i < candlesToCheck; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i); // Giá cao nhất của cây nến
      double lowPrice = iLow(symbol, timeframe, i); // Giá thấp nhất của cây nến

      // Tìm giá trị max và min
      if(highPrice > maxPrice)
         maxPrice = highPrice;

      if(lowPrice < minPrice)
         minPrice = lowPrice;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRiskPerTrade()
  {
   double risk_per_trade = format_double(calcRisk(), 2);
//risk_per_trade = 2.0; // USD

   return risk_per_trade;
  }
//+------------------------------------------------------------------+
//| https://market24hclock.com/?set_time_zone=%2B0                   |
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
void DrawBB()
  {
//ObjectsDeleteAll();

   string str_line = "";
   for(int index = 1; index <= 500; index++)
      str_line += "-";

   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   datetime label_postion = iTime(symbol, PERIOD_CURRENT, 0);

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
   CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
   double hi_h1_20_1 = upper_h1_20_1[0];
   double mi_h1_20_0 = middle_h1_20_1[0];
   double lo_h1_20_1 = lower_h1_20_1[0];

   double amp_h1 = MathAbs(hi_h1_20_1 - mi_h1_20_0);

   string str_stop = "          H1(00)";
   double avg_amp_h1 = CalculateAverageCandleHeight(PERIOD_H1, symbol);
   if(amp_h1 < avg_amp_h1)
      str_stop = "          STOP ";


   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
   double hi_h4_20_2 = upper_h4[0];
   double lo_h4_20_2 = lower_h4  [0];

   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, "H4(+2)--------------" + str_line, clrRed, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, "H4(-2)--------------" + str_line, clrRed, digits);

   create_lable_trim("lbl_mi_h1_20_0", label_postion, mi_h1_20_0, str_stop + "" + str_line, clrRed, digits);

   ObjectSetInteger(0, "mi_h1_20_0", OBJPROP_STYLE, STYLE_DASH);
   for(int i = 1; i<=5; i++)
     {
      bool is_solid = false;
      bool is_ray_left = (i==2) ? true : false;
      color line_color = clrBlack;
      if(i == 1)
         line_color = clrDimGray;
      if(i == 2)
         line_color = clrBlue;
      if(i == 3)
         line_color = clrMediumSeaGreen;
      if(i == 4)
         line_color = clrBlack;
      if(i == 5)
         line_color = clrRed;
      double hi_h1_20_i = mi_h1_20_0 + (i*amp_h1);
      double lo_h1_20_i = mi_h1_20_0 - (i*amp_h1);

      create_lable_trim("lbl_hi_h1_20_" + (string)i, label_postion, hi_h1_20_i, "          H1(+" + (string)i + ")" + str_line, line_color, digits);
      create_lable_trim("lbl_lo_h1_20_" + (string)i, label_postion, lo_h1_20_i, "          H1(-" + (string)i + ")" + str_line, line_color, digits);
     }
  }

//+------------------------------------------------------------------+
void draw_amp(double d_amp, double d_close, string name, int digits, datetime time_from, datetime time_to, double yesterday_low, double yesterday_high, const color d_color=clrBlack
              , bool ray_left = false, bool ray_right = true)
  {
   double d_s1  = d_close - d_amp;
   double d_r1  = d_close + d_amp;
   double d_s2  = d_s1 - d_amp;
   double d_r2  = d_r1 + d_amp;
   double d_s3  = d_s2 - d_amp;
   double d_r3  = d_r2 + d_amp;
   double d_s4  = d_s3 - d_amp;
   double d_r4  = d_r3 + d_amp;
   double d_s5  = d_s4 - d_amp;
   double d_r5  = d_r4 + d_amp;

   create_trend_line(name + "_cl", time_from, time_to, d_close, d_color, digits, ray_left, ray_right);

   if(d_s1 > yesterday_low)
      create_trend_line(name + "_s1", time_from, time_to, d_s1, d_color, digits, ray_left, ray_right);

   if(d_r1< yesterday_high)
      create_trend_line(name + "_r1", time_from, time_to, d_r1, d_color, digits, ray_left, ray_right);

   if(d_s2 > yesterday_low)
      create_trend_line(name + "_s2", time_from, time_to, d_s2, d_color, digits, ray_left, ray_right);

   if(d_r2 < yesterday_high)
      create_trend_line(name + "_r2", time_from, time_to, d_r2, d_color, digits, ray_left, ray_right);

   if(d_s3 > yesterday_low)
      create_trend_line(name + "_s3", time_from, time_to, d_s3, d_color, digits, ray_left, ray_right);

   if(d_r3 < yesterday_high)
      create_trend_line(name + "_r3", time_from, time_to, d_r3, d_color, digits, ray_left, ray_right);

   if(d_s4 > yesterday_low)
      create_trend_line(name + "_s4", time_from, time_to, d_s4, d_color, digits, ray_left, ray_right);

   if(d_s5 > yesterday_low)
      create_trend_line(name + "_s5", time_from, time_to, d_s5, d_color, digits, ray_left, ray_right);

   if(d_r4 < yesterday_high)
      create_trend_line(name + "_r4", time_from, time_to, d_r4, d_color, digits, ray_left, ray_right);

   if(d_r5 < yesterday_high)
      create_trend_line(name + "_r5", time_from, time_to, d_r5, d_color, digits, ray_left, ray_right);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_of_week(const int index)
  {
   string daysOfWeek[7];

   daysOfWeek[0] = "Sun";   // Sunday
   daysOfWeek[1] = "Mon";   // Monday
   daysOfWeek[2] = "Tue";   // Tuesday
   daysOfWeek[3] = "Wed";   // Wednesday
   daysOfWeek[4] = "Thu";   // Thursday
   daysOfWeek[5] = "Fri";   // Friday
   daysOfWeek[6] = "Sat";   // Saturday

   if((1 <= index) && (index <= 5))
     {
      return daysOfWeek[index];
     }
   if(index <= 0)
     {
      return daysOfWeek[5+index];
     }

   return "d" + (string)index;
  }


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

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
   const bool              is_solid_line = false
)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
     }
   else
     {
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

//create_lable(name, time_to, price, clr_color, digits);
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
   TextCreate(0,"lbl_" + name, 0, time_to, price, "        " + format_double_to_string(price, digits), clr_color);
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
   TextCreate(0,"lbl_" + name, 0, time_to, price, "        " + label, clr_color);
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
   const int               digits=5
)
  {
   TextCreate(0,"lbl_" + name, 0, time_to, price, label, clr_color);
  }

//+------------------------------------------------------------------+
//| Creating Text object                                             |
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
//--- set anchor point coordinates if they are not set
//ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text

   ObjectSetString(chart_ID,name,OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE, angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR, anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR, clr);

//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, back);

//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, selection);

   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, selection);

//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, hidden);

//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, z_order);
//--- successful execution

   return(true);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool VLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="VLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time=0,            // line time
                 const color           clr=clrBlack,        // line color
                 const ENUM_LINE_STYLE style=STYLE_DOT, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=false,    // highlight to move
                 const bool            ray=false,          // line's continuation down
                 const bool            hidden=true,      // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the line time is not set, draw it via the last bar
   if(!time)
      time=TimeGMT();
//--- reset the error value
   ResetLastError();
//--- create a vertical line
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of displaying the line in the chart subwindows
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_rectangle

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price (Open)
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price (Close)
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            background=false,        // in the background
                     const bool            selection=false,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0,         // priority for mouse click
                     const color           def_color=clrBlack
                    )
  {
   int             sub_window=0;      // subwindow index

//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
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

//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,background);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeGMT();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+

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
string date_time_to_string(const MqlDateTime &deal_time)
  {
   string result = "";//(string)deal_time.year;
   if(deal_time.mon < 10)
     {
      result += "0" + (string)deal_time.mon ;
     }
   else
     {
      result += (string)deal_time.mon ;
     }
   if(deal_time.day < 10)
     {
      result += "0" + (string)deal_time.day ;
     }
   else
     {
      result += (string)deal_time.day;
     }


   return result;
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
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 10; i++)
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
double CalculateMA(double& prices[], int period)
  {
   double ma = 0.0;

// Tính tổng của giá đóng cửa của period nến gần nhất
   for(int i = 0; i < period; i++)
     {
      ma += prices[i];
     }

// Chia tổng cho số lượng nến để tính trung bình
   ma /= period;

   return ma;
  }

//+------------------------------------------------------------------+
//|                                                                  |
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

   double ma_value = CalculateMA(closePrices, ma_index);
   return ma_value;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk()
  {
   double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

   double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;

   if(dbValueRisk > 200)
     {
      //Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than 200 per order. Too dangerous.");
      return 200;
     }
   return dbValueRisk;
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

   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize < 0.01)
      roundedLotSize = 0.01;

   return roundedLotSize;
  }
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void ObjectsDeleteAll()
  {
   int totalObjects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
//|                                                                  |
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
      for(int j = index+1; j < 45; j++)
        {
         if((haTrend == candleArray[j].trend))
           {
            count_trend += 1;
           }
         else
           {
            if((haTrend != candleArray[j+1].trend))
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
bool PreHeikenAshiIsPinbar(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
// Lấy giá trị của nến trước đó
   int index = 0;

   double prevHaOpen = iOpen(symbol, TIME_FRAME, index + 1);
   double prevHaClose = iClose(symbol, TIME_FRAME, index + 1);
   double prevHaHigh = iHigh(symbol, TIME_FRAME, index + 1);
   double prevHaLow = iLow(symbol, TIME_FRAME, index + 1);

   bool is_pin_bar = false;
   double body = MathAbs(prevHaOpen - prevHaClose);
   double bred_hig = MathAbs(prevHaHigh - MathMax(prevHaOpen, prevHaClose));
   double bred_low = MathAbs(prevHaLow - MathMax(prevHaOpen, prevHaClose));
   if(bred_low > body && bred_hig > body)
      is_pin_bar = true;

   return is_pin_bar;
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
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(double& prices[], int period, int candle_no)
  {
   int maLength = ArraySize(prices);
   double smoothingFactor = 2.0 / (period + 1);

   double ema[];
   ArrayResize(ema, maLength);

   ema[maLength - 1] = prices[maLength - 1];

   for(int i = maLength - 2; i >= 0; i--)
     {
      double currentPrice = prices[i];
      double previousEMA = ema[i + 1];
      ema[i] = format_double((currentPrice * smoothingFactor) + (previousEMA * (1-smoothingFactor)), 5);
     }

   return ema[candle_no];
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSMA(double& prices[], double& sma[], int period)
  {
   int maLength = ArraySize(prices);
   ArrayResize(sma, maLength);
   for(int i = 0; i<maLength ; i++)
     {
      sma[i] = 0;
     }

   for(int i = 0; i < maLength - period; i++)
     {
      double sum = 0;
      for(int j = i; j < i + period; j++)
        {
         sum += prices[j];
        }
      sma[i] = sum / period;
     }
  }
//+------------------------------------------------------------------+
bool allow_trade_by_amp_50candle(string symbol, string find_trend)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int count_candle = 0;
   int length_55 = 55;
   double close_prices_d1[];
   ArrayResize(close_prices_d1, length_55);
   for(int i = length_55 - 1; i >= 0; i--)
     {
      double temp_close = iClose(symbol, PERIOD_D1, i);
      if(temp_close > 0)
         count_candle += 1;

      close_prices_d1[i] = temp_close;
     }
   if(count_candle < 50)
      return false;

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
string AppendSpaces(string inputString, int totalLength = 10, bool is_append_right = true)
  {

   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
     {
      return (inputString);
     }
   else
     {
      int spacesToAdd = totalLength - currentLength;
      string spaces = "";
      for(int index = 1; index <= spacesToAdd; index++)
        {
         spaces+= " ";
        }

      if(is_append_right)
        {
         return (inputString + spaces);
        }
      else
        {
         return (spaces + inputString);
        }

     }
  }

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
   open_message_this_hour += (string)iTime(symbol, PERIOD_H4, 0) + "_"+ symbol + ";";

   CutString(open_message_this_hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_open_this_candle_h4(string symbol)
  {
   string key = (string)iTime(symbol, PERIOD_H4, 0) + "_"+ symbol + ";";

   if(StringFind(open_message_this_hour, key) >= 0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
string GetCurrentTimeframeToString()
  {
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
   if(Period() < PERIOD_M15)
      return "Minus";

   return "??";
  }
//+------------------------------------------------------------------+
