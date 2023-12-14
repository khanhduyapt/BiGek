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

double dbRiskRatio = 0.01; // Rủi ro 0.01 = 1%
double INIT_EQUITY = 1000.0; // Vốn ban đầu

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string arr_symbol[] =
  {
   "AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
   ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
   ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
   ,"NZDCAD", "NZDJPY", "NZDUSD"
   ,"USDCAD", "USDJPY", "CADJPY"
   ,"USDCHF", "AUDCHF", "CHFJPY", "EURCHF", "GBPCHF", "NZDCHF", "CADCHF"

//   "USDCHF", "USDJPY", "EURJPY", "EURCAD", "EURUSD", "GBPUSD", "EURGBP"
  };
//USDCHF - kq 13.566 - lãi 35%
//USDJPY - kq 12.203 - lãi 22%
//EURJYP - kq 11.241 - lãi 12%
//EURCAD - kq 11.902 - lãi 19%
//EURUSD lãi 23%
//GBPUSD lãi 59.5%

//DELETE: "AUDCHF", "CHFJPY", "EURCHF", "GBPCHF", "NZDCHF", "CADCHF"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();

   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);

// printf(BOT_NAME + " initialized ");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnTimer()
  {
//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   double risk = format_double(dbRisk(), 2);

   double volume1 = 0.01;
   double volume2 = 0.01;
   double volume3 = 0.01;
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1;  // PERIOD_M15 PERIOD_H1
//End ----------------------------------------------------------------

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = SymbolInfoDouble(symbol, SYMBOL_BID);
      //------------------------------------------------------------------

      CleanTrade(symbol);

      //------------------------------------------------------------------
      if(IsMarketClose())
        {
         string str_risk  =  "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";
         str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$/" + (string) INIT_EQUITY + "$";
         str_risk += "    " + _Symbol;
         string comment = get_vntime() + " (" + BOT_NAME + ") Market Close " + str_risk + "\n (Sat, Sun, 3 < Vn.Hour < 7)." ;
         Comment(comment);

         continue;
        }
      else
        {
         string str_risk  =  "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";
         str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$/" + (string) INIT_EQUITY + "$";
         str_risk += "    " + _Symbol;
         string comment = get_vntime() + " (" + BOT_NAME + ") Market Open " + str_risk + "\n";
         Comment(comment);
        }

      int count = 0;
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

      string pos_comments = "";
      double total_profit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         string trading_symbol = PositionGetSymbol(i);
         trading_symbol = toLower(trading_symbol);

         if(lowcase_symbol == trading_symbol)
           {
            count = count + 1;
            pos_comments += PositionGetString(POSITION_COMMENT);
            total_profit += PositionGetDouble(POSITION_PROFIT);
           }
        }

      double dic_top_price;
      double dic_amp_w;
      double dic_lot_size;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
      double week_amp = dic_amp_w;

      double volume = dblLotsRisk(symbol, week_amp, risk);
      volume1 = volume;
      volume2 = volume1 * 2;
      volume3 = volume2 * 2;

      string ref_heiken_h1 = get_trend_by_heiken(symbol, PERIOD_H1, 1);
      string ref_heiken_h4 = get_trend_by_heiken(symbol, PERIOD_H4, 1);
      double avg_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol);

      int count_candle = 0;
      int length_55 = 55;
      double close_prices_h4[];
      double close_prices_d1[];
      ArrayResize(close_prices_h4, length_55);
      ArrayResize(close_prices_d1, length_55);
      for(int i = length_55 - 1; i >= 0; i--)
        {
         double temp_close = iClose(symbol, PERIOD_H4, i);
         if(temp_close > 0)
            count_candle += 1;

         close_prices_h4[i] = temp_close;

         close_prices_d1[i] = iClose(symbol, PERIOD_D1, i);
        }
      if(count_candle < 50)
         continue;

      double ma10_h4 = CalculateMA(close_prices_h4, 10);
      double ma20_h4 = CalculateMA(close_prices_h4, 20);
      double ma50_h4 = CalculateMA(close_prices_h4, 50);

      double min_close_d1 = FindMinPrice(close_prices_d1);
      double max_close_d1 = FindMaxPrice(close_prices_d1);

      double close_h4_c1 = close_prices_h4[1];
      double min_close_h4 = FindMinPrice(close_prices_h4);
      double max_close_h4 = FindMaxPrice(close_prices_h4);
      double amp_close_h4 = MathAbs(max_close_h4 - min_close_h4);

      double amp_next_trade = week_amp * 2;



      double pre_d1_heigh = iHigh(symbol, PERIOD_D1, 1) - iLow(symbol, PERIOD_D1, 1);
      if(avg_h4 < (pre_d1_heigh/3))
         avg_h4 = (pre_d1_heigh/3);

      string trend_seq_h4 = "seq";
      if((close_h4_c1 > ma10_h4) && (ma10_h4 > ma20_h4) && (ma20_h4 > ma50_h4))
         trend_seq_h4 = TREND_BUY;

      if((close_h4_c1 < ma10_h4) && (ma10_h4 < ma20_h4) && (ma20_h4 < ma50_h4))
         trend_seq_h4 = TREND_SEL;

      double ma10_d1 = CalculateMA(close_prices_d1, 10);
      string trend_d10 = (price > ma10_d1) ? TREND_BUY: TREND_SEL;

      bool is_must_follow_wdh4 = false;
      if(trend_d10 == trend_seq_h4)
         is_must_follow_wdh4 = true;

      if((is_must_follow_wdh4) && (count > 0) && (total_profit > 0))
        {
         //STOP_LOSS(BUY)
         if((StringFind(pos_comments, "BUY") >= 0) && (trend_d10 == TREND_SEL) && (ref_heiken_h4 == TREND_SEL) && (ref_heiken_h1 == TREND_SEL))
           {
            ClosePosition(symbol);
            Alert(get_vntime(), "(STOP_LOSS) Against the major trend. ", symbol, "   ", pos_comments, "   ", total_profit);
           }

         //STOP_LOSS(SELL)
         if((StringFind(pos_comments, "SELL") >= 0) && (trend_d10 == TREND_BUY) && (ref_heiken_h4 == TREND_BUY) && (ref_heiken_h1 == TREND_BUY))
           {
            ClosePosition(symbol);
            Alert(get_vntime(), "(STOP_LOSS) Against the major trend. ", symbol, "   ", pos_comments, "   ", total_profit);
           }
        }

      if(count == 0)
        {
         min_close_h4 = min_close_h4 + avg_h4;
         max_close_h4 = max_close_h4 - avg_h4;

         bool has_trade = false;
         if((price < min_close_h4) || (price > max_close_h4))
           {
            double tp1_buy = price + avg_h4 ;
            double tp1_sell = price - avg_h4;

            bool buy_cond = (price < min_close_h4) && (ref_heiken_h1 == TREND_BUY) && (ref_heiken_h4 == TREND_BUY);
            bool sel_cond = (price > max_close_h4) && (ref_heiken_h1 == TREND_SEL) && (ref_heiken_h4 == TREND_SEL);

            if(buy_cond || sel_cond)
              {
               double low_2 = price - amp_next_trade;
               double low_3 = low_2 - amp_next_trade;
               double sl_buy = low_3 - amp_next_trade;

               double hig_2 = price + amp_next_trade;
               double hig_3 = hig_2 + amp_next_trade;
               double sl_sell = hig_3 + amp_next_trade;

               //------------------------------------------
               if(buy_cond)
                 {
                  has_trade = true;

                  m_trade.Buy(volume, symbol, 0.0, sl_buy, tp1_buy, "BB_BUY_1h");
                  m_trade.BuyLimit(volume2, NormalizeDouble(low_2, digits), symbol, sl_buy, NormalizeDouble(price, digits), 0, 0, "BB_BUY_2h");
                  m_trade.BuyLimit(volume3, NormalizeDouble(low_3, digits), symbol, sl_buy, NormalizeDouble(low_2, digits), 0, 0, "BB_BUY_3h");

                  Alert(get_vntime(), "  BUY: ", symbol);
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
               if(sel_cond)
                 {
                  has_trade = true;

                  m_trade.Sell(volume, symbol, 0.0, sl_sell, tp1_sell, "BB_SELL_1h");
                  m_trade.SellLimit(volume2, NormalizeDouble(hig_2, digits), symbol, sl_sell, NormalizeDouble(price, digits), 0, 0, "BB_SELL_2h");
                  m_trade.SellLimit(volume3, NormalizeDouble(hig_3, digits), symbol, sl_sell, NormalizeDouble(hig_2, digits), 0, 0, "BB_SELL_3h");

                  Alert(get_vntime(), "  SELL: ", symbol);
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
              }
           }

         if((has_trade == false) && ((price < min_close_d1) || (price > max_close_d1)))
           {
            double tp1_buy = price + avg_h4 ;
            double tp1_sell = price - avg_h4;

            bool buy_cond = (price < min_close_h4) && (ref_heiken_h1 == TREND_BUY); // && (ref_heiken_h4 == TREND_BUY)
            bool sel_cond = (price > max_close_h4) && (ref_heiken_h1 == TREND_SEL); // && (ref_heiken_h4 == TRE ND_SEL)

            if(buy_cond || sel_cond)
              {
               double low_2 = price - amp_next_trade;
               double low_3 = low_2 - amp_next_trade;
               double sl_buy = low_3 - amp_next_trade;

               double hig_2 = price + amp_next_trade;
               double hig_3 = hig_2 + amp_next_trade;
               double sl_sell = hig_3 + amp_next_trade;

               //------------------------------------------
               if(buy_cond)
                 {
                  has_trade = true;

                  m_trade.Buy(volume, symbol, 0.0, sl_buy, tp1_buy, "BB_BUY_1d");
                  m_trade.BuyLimit(volume2, NormalizeDouble(low_2, digits), symbol, sl_buy, NormalizeDouble(price, digits), 0, 0, "BB_BUY_2d");
                  m_trade.BuyLimit(volume3, NormalizeDouble(low_3, digits), symbol, sl_buy, NormalizeDouble(low_2, digits), 0, 0, "BB_BUY_3d");

                  Alert(get_vntime(), "  BUY: ", symbol);
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
               if(sel_cond)
                 {
                  has_trade = true;

                  m_trade.Sell(volume, symbol, 0.0, sl_sell, tp1_sell, "BB_SELL_1d");
                  m_trade.SellLimit(volume2, NormalizeDouble(hig_2, digits), symbol, sl_sell, NormalizeDouble(price, digits), 0, 0, "BB_SELL_2d");
                  m_trade.SellLimit(volume3, NormalizeDouble(hig_3, digits), symbol, sl_sell, NormalizeDouble(hig_2, digits), 0, 0, "BB_SELL_3d");

                  Alert(get_vntime(), "  SELL: ", symbol);
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
              }
           }
         //------------------------------------------

         //------------------------------------------
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
         string trading_symbol = toLower(m_position.Symbol());
         if((toLower(symbol) == trading_symbol) && (StringFind(toLower(m_position.Comment()), "bb_") >= 0))
           {
            count_possion += 1;
            total_profit += m_position.Profit();
            type = m_position.TypeDescription();
            possion_comments += m_position.Comment() + "; ";

            if(is_close_trade_today)
               m_trade.PositionClose(m_position.Ticket());

            if(is_close_if_has_profit && m_position.Profit()>0)
               m_trade.PositionClose(m_position.Ticket());
           }
        }
     } //for

   int count_orders = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_order.Symbol())) && (StringFind(toLower(m_position.Comment()), "bb_") >= 0))
           {
            count_orders += 1;
            order_comments += m_order.Comment() + "; ";
           }
        }
     }



   if(count_possion == 3 && total_profit > 0)
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }

   double risk = format_double(dbRisk(), 2);
   if(count_possion == 2 && total_profit > 0)
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }

   if(count_possion + count_orders < 3)
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }

//-------------------------------------------------------------------------
// Trường hợp lệnh BUY_3/SELL_3 được đóng -> đóng tất cả Positions(No.1, No.2) & Orders
   if((StringFind(possion_comments + order_comments, "BUY") > 0) && (StringFind(possion_comments + order_comments, "BB_BUY_1") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((StringFind(possion_comments + order_comments, "SELL") > 0) && (StringFind(possion_comments + order_comments, "BB_SELL_1") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BUY_2/SELL_2 được đóng -> đóng tất cả Positions(No.1) & Orders(Mo.3)
   if((StringFind(possion_comments + order_comments, "BUY") > 0) && (StringFind(possion_comments + order_comments, "BB_BUY_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((StringFind(possion_comments + order_comments, "SELL") > 0) && (StringFind(possion_comments + order_comments, "BB_SELL_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
  }

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
double GetMaxCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
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
string get_vntime()
  {
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;

   datetime vietnamTime = TimeCurrent() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + " (GMT: " + (string) current_gmt_hour + "h) ";
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
double CalculateMA(double& prices[], int period)
  {
   double ma = 0.0;

// Tính tổng của giá đóng cửa của period nến gần nhất
   for(int i = 1; i <= period; i++)
     {
      ma += prices[i];
     }

// Chia tổng cho số lượng nến để tính trung bình
   ma /= period;

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
   double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

//double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;
   double dbValueRisk = INIT_EQUITY * dbRiskRatio;
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
//|                                                                  |
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
      double lowPrice = iLow(symbol, timeframe, i);
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