//+------------------------------------------------------------------+
//|                                                  BB_Guardian_Test.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

string input BOT_NAME = "BB_Guardian_Test";
int input    EXPERT_MAGIC = 20231201;

string arr_symbol[] = {"XAUUSD" //, "XAGUSD"
                       ,"BTCUSD" //, "ETHUSD"
                       ,"US30", "USTEC"
                       ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
                       ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
                       ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
                       ,"NZDCAD", "NZDJPY", "NZDUSD"
                       ,"USDCAD", "USDJPY", "CADJPY"
                       , "USDCHF", "AUDCHF", "CHFJPY", "EURCHF", "GBPCHF", "NZDCHF", "CADCHF"
                      };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   OnTimer();

   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);

   printf(BOT_NAME + " initialized ");

//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnTimer()
  {
//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   double dbRiskRatio = 0.01; // Rủi ro 1%
   double INIT_EQUITY = 200.0; // Vốn ban đầu 200$
   double risk = format_double(dbRisk(dbRiskRatio, INIT_EQUITY), 2);
//End ----------------------------------------------------------------
   bool ALLOW_TRADE = true;

   double total_profit = get_profit_today();
   double loss_percent = MathAbs(total_profit / INIT_EQUITY);
   string profit_today = "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$ "
                         + format_double_to_string(loss_percent * 100, 2) + "%";
   if(loss_percent > 0.15)
     {
      ALLOW_TRADE = false;
     }

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
      //------------------------------------------------------------------

      CleanTrade(symbol);

      //------------------------------------------------------------------
      if(IsMarketClose())
        {
         ALLOW_TRADE = false;

         string message = get_vntime() + "(" + BOT_NAME + ") Market Close (Sat, Sun, 3 <= Vn.Hour <= 7).";
         message += profit_today;
         if(ALLOW_TRADE == false)
            message += " STOP ";
         Comment(message);

         continue;
        }
      else
        {
         if(symbol == _Symbol)
           {
            string str_risk  =  profit_today;
            str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
            if(ALLOW_TRADE == false)
               str_risk += " STOP ";
            str_risk += "    " + _Symbol + " (" + GetTrendByPricePosition(_Symbol) + ")";

            string comment = get_vntime() + " (" + BOT_NAME + ") Market Open " + str_risk;
            Comment(comment);
           }
        }

      //----------------------------------------------------------------------
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

      ulong ticket = 0;
      string trading_trend = "";
      double profit_this_symbol = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         string trading_symbol = PositionGetSymbol(i);
         trading_symbol = toLower(trading_symbol);

         if(m_position.SelectByIndex(i))
           {
            if(lowcase_symbol == toLower(m_position.Symbol()))
              {
               count = count + 1;
               profit_this_symbol += m_position.Profit();

               if(m_position.Type()  == POSITION_TYPE_BUY)
                 {
                  trading_trend = "buy";
                  ticket = m_position.Ticket();
                 }

               if(m_position.Type()  == POSITION_TYPE_SELL)
                 {
                  trading_trend = "sell";
                  ticket = m_position.Ticket();
                 }
              }
           }
        }

      if(profit_this_symbol > 0)
        {
         double upper_m15_20_2[], middl_m15_20_2[], lower_m15_20_2[];
         CalculateBollingerBands(symbol, PERIOD_M15, upper_m15_20_2, middl_m15_20_2, lower_m15_20_2, digits, 2);
         double hi_m15 = upper_m15_20_2[0];
         double lo_m15 = lower_m15_20_2[0];

         if((trading_trend == "buy") && (price >= hi_m15))
           {
            m_trade.PositionClose(ticket);
            Alert(get_vntime(), " CLOSE BUY (by BB m15): ", symbol, "   profit_this_symbol: ", profit_this_symbol);
           }

         if((trading_trend == "sell") && (price <= hi_m15))
           {
            m_trade.PositionClose(ticket);
            Alert(get_vntime(), " CLOSE BUY (by BB m15): ", symbol, "   profit_this_symbol: ", profit_this_symbol);
           }
        }
      //----------------------------------------------------------------------

      // Alert(TimeGMT(), "    symbol: ", symbol, "    count_possion: ", count_possion, "    count_limit: ", count_limit);
      double dic_top_price;
      double dic_amp_w;
      double dic_lot_size;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
      double week_amp = dic_amp_w;

      double amp_takprofit = week_amp * 0.3;

      if(ALLOW_TRADE && (count == 0))
        {

         int maLength = 15;
         double close_prices_d1[15];
         for(int i = maLength - 1; i > 0; i--)
           {
            close_prices_d1[i] = iClose(symbol, PERIOD_D1, i);
           }
         double ma10_d1 = CalculateMA(close_prices_d1, 10);

         bool buy_cond = (price < (ma10_d1 - week_amp));
         bool sel_cond = (price > (ma10_d1 + week_amp));

         if(buy_cond || sel_cond)
           {
            // Chờ M5 hãm đã đà xu hướng
            ENUM_TIMEFRAMES TIME_FRAME_WAITING = PERIOD_M5;
            int maLength = 15;
            double closePrices[15];
            for(int i = maLength - 1; i >= 0; i--)
              {
               closePrices[i] = iClose(symbol, TIME_FRAME_WAITING, i);
              }
            double ma10_m1 = CalculateMA(closePrices, 10);
            double close_prices_c1 = iClose(symbol, TIME_FRAME_WAITING, 1);


            // ----------------------------------------------------
            string trend_by_price =  GetTrendByPricePosition(symbol);
            // ----------------------------------------------------

            buy_cond = buy_cond && (trend_by_price == "B") && (close_prices_c1 > ma10_m1);
            sel_cond = sel_cond && (trend_by_price == "S") && (close_prices_c1 < ma10_m1);

            if((symbol == "US30.cash") || (symbol == "US100.cash"))
              {
               if(buy_cond)
                 {
                  continue;
                 }
              }
            //Alert(get_vntime(), "  SELL: ", symbol, sel_cond, (max_price > hi_h1_20_2), (hi_h1_20_2 > hi_h4_20_2), (close_prices_c1 < ma10_m1));

            if(buy_cond || sel_cond)
              {
               double volume = dblLotsRisk(symbol, week_amp, risk);
               double volume1 = volume;
               double volume2 = volume1 * 2;
               double volume3 = volume2 * 2;

               //------------------------------------------
               if(buy_cond)
                 {
                  m_trade.BuyLimit(volume3, price - (week_amp * 2), symbol, 0.0, price - (week_amp * 1), 0, 0, "BB_BUY_3");

                  m_trade.BuyLimit(volume2, price - (week_amp * 1), symbol, 0.0, price - (week_amp * 0), 0, 0, "BB_BUY_2");

                  if(m_trade.Buy(volume1, symbol, 0.0, 0.0, price + amp_takprofit, "BB_BUY_1"))
                    {
                     Alert(get_vntime(), "  BUY: ", symbol, "   price: ", price, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);
                    }
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
               if(sel_cond)
                 {
                  m_trade.SellLimit(volume3, price + (week_amp * 2), symbol, 0.0, price + (week_amp * 1), 0, 0, "BB_SELL_3");

                  m_trade.SellLimit(volume2, price + (week_amp * 1), symbol, 0.0, price + (week_amp * 0), 0, 0, "BB_SELL_2");

                  if(m_trade.Sell(volume1, symbol, 0.0, 0.0, price - amp_takprofit, "BB_SELL_1"))
                    {
                     Alert(get_vntime(), "  SELL: ", symbol, "   price: ", price, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);
                    }
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
              }
           }
        }
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 10; i++)
     {
      double highPrice = iHigh(symbol, PERIOD_M1, i);
      double lowPrice = iLow(symbol, PERIOD_M1, i);
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
double GetLowestLowCandleM1(string symbol, int length)
  {
   double lowestLow = iLow(symbol, PERIOD_M1, 0);

   for(int i = 1; i < length; i++)
     {
      double low = iLow(symbol, PERIOD_M1, i);
      if(low < lowestLow)
         lowestLow = low;
     }

   return lowestLow;
  }

// Hàm lấy giá cao nhất của 50 cây nến 1 phút
double GetHighestHighCandleM1(string symbol, int length)
  {
   double highestHigh = iHigh(symbol, PERIOD_M1, 0);

   for(int i = 1; i < length; i++)
     {
      double high = iHigh(symbol, PERIOD_M1, i);
      if(high > highestHigh)
         highestHigh = high;
     }

   return highestHigh;
  }

//+------------------------------------------------------------------+
string GetTrendByPricePosition(string symbol)
  {
   int maLength = 120;
   double closePrices[120];
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, PERIOD_M1, i);
     }
   double higestClose = FindMaxPrice(closePrices);
   double lowestClose = FindMinPrice(closePrices);
   double currentPrice = iClose(symbol, PERIOD_M1, 0);

   double range = higestClose - lowestClose;
   double upperThreshold = higestClose - (range / 2);
   double lowerThreshold = lowestClose + (range / 2);

   if(currentPrice < lowerThreshold)
      return "B";
   else
      if(currentPrice > upperThreshold)
         return "S";
      else
         return "";
  }

//+------------------------------------------------------------------+
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
string get_vntime()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + " ";
   return vntime;
  }

//+------------------------------------------------------------------+
//https://www.babypips.com/tools/forex-market-hours
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
   datetime vietnamTime = currentGMTTime + gmtOffset * 3600;

   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
// Lấy giờ từ cấu trúc datetime
   int currentHour = dt.hour;
   if(3 <= currentHour && currentHour <= 7)
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
double dbRisk(double dbRiskRatio, double INIT_EQUITY)
  {
   double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

   double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;

   if(dbValueRisk > 200)
     {
      Alert("(", BOT_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than 200 per order. Too dangerous.");
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
void CleanTrade(string symbol)
  {
   double total_profit = 0;
   int count_possion = 0;
   string possion_comments = "";
   string order_comments = "";
   string type = "";

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
           }
        }
     } //for

   int count_orders = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_order.Symbol()) && (StringFind(toLower(m_position.Comment()), "bb_") >= 0)))
           {
            count_orders += 1;
            order_comments += m_order.Comment() + "; ";
           }
        }
     }

//-------------------------------------------------------------------------
// Trường hợp lệnh BB_BUY_3/BB_SELL_3 được đóng -> đóng tất cả Positions(No.1, No.2) & Orders
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BB_BUY_3") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "BB_SELL_3") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BB_BUY_2/BB_SELL_2 được đóng -> đóng tất cả Positions(No.1) & Orders(Mo.3)
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BB_BUY_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "BB_SELL_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BB_BUY_1/BB_SELL_1 được đóng -> đóng tất cả Positions(No.2) & Orders(Mo.3)
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BB_BUY_1") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "BB_SELL_1") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
  }

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
   TimeToStruct(TimeGMT(), date_time);
   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;
   int row_count = 0;
// --------------------------------------------------------------------
// --------------------------------------------------------------------
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   HistorySelect(0, TimeGMT()); // today closed trades PL
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
