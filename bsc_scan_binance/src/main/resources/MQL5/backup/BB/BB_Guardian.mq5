//+------------------------------------------------------------------+
//|                                                  BB_Guardian.mq5 |
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

string input BOT_NAME = "BB_Guardian";
int input    EXPERT_MAGIC = 20231129;

string arr_symbol[] = {"XAUUSD", "XAGUSD"
                       ,"BTCUSD", "ETHUSD"
                       ,"US30", "USTEC"
                       ,"AUDCAD", "AUDJPY", "AUDNZD", "AUDUSD"
                       ,"EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD", "EURUSD"
                       ,"GBPAUD", "GBPCAD", "GBPJPY", "GBPNZD", "GBPUSD"
                       ,"NZDCAD", "NZDJPY", "NZDUSD"
                       ,"USDCAD", "USDJPY", "USDCHF", "CADJPY"
                      };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   EventSetTimer(30); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

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

   double volume1 = 0.01;
   double volume2 = 0.02;
   double volume3 = 0.04;
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1;  // PERIOD_M15 PERIOD_H1
//End ----------------------------------------------------------------

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      //------------------------------------------------------------------

      CleanTrade(symbol);

      //------------------------------------------------------------------
      if(IsMarketClose())
        {
         string message = get_vntime() + "(BB_Guardian) Market Close (Sat, Sun, 3 < Vn.Hour < 7).";
         message += "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";

         Comment(message);
         continue;
        }
      else
        {
         string str_risk  =  "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";
         str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
         str_risk += "    " + _Symbol;
         string comment = get_vntime() + " (BB_Guardian) Market Open " + str_risk + "\n";
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

      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         string trading_symbol = PositionGetSymbol(i);
         trading_symbol = toLower(trading_symbol);

         if(lowcase_symbol == trading_symbol)
           {
            count = count + 1;
           }
        }

      // Alert(TimeCurrent(), "    symbol: ", symbol, "    count_possion: ", count_possion, "    count_limit: ", count_limit);

      if(count == 0)
        {
         double upper_h4[], middle_h4[], lower_h4[];
         CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
         double hi_h4_20_2 = upper_h4[0];
         double lo_h4_20_2 = lower_h4[0];

         double upper_h1_20_1[], middl_h1_20_1[], lower_h1_20_1[];
         CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_1, middl_h1_20_1, lower_h1_20_1, digits, 1);
         double hi_h1_20_1 = upper_h1_20_1[0];
         double mi_h1_20_0 = middl_h1_20_1[0];
         double lo_h1_20_1 = lower_h1_20_1[0];
         double amp_h1 = MathAbs(hi_h1_20_1 - mi_h1_20_0);
         double hi_h1_20_2 = hi_h1_20_1 + amp_h1;
         double lo_h1_20_2 = lo_h1_20_1 - amp_h1;

         if((lo_h1_20_2 < lo_h4_20_2) || (hi_h1_20_2 > hi_h4_20_2))
           {
            double price = SymbolInfoDouble(symbol, SYMBOL_BID);

            //1 minute
            int maLength = 15;
            double closePrices[15];
            for(int i = maLength - 1; i >= 0; i--)
              {
               closePrices[i] = iClose(symbol, PERIOD_M1, i);
              }
            double ma10_m1 = CalculateMA(closePrices, 10);
            double close_prices_c1 = iClose(symbol, PERIOD_M1, 1);
            double min_price = FindMinPrice(closePrices);
            double max_price = FindMinPrice(closePrices);

            double hi_h1_20_3 = max_price + amp_h1;
            double hi_h1_20_4 = hi_h1_20_3 + amp_h1;
            double lo_h1_20_3 = min_price - amp_h1;
            double lo_h1_20_4 = lo_h1_20_3 - amp_h1;

            bool buy_cond = (min_price < lo_h1_20_2) && (lo_h1_20_2 < lo_h4_20_2) && (close_prices_c1 > ma10_m1);
            bool sel_cond = (max_price > hi_h1_20_2) && (hi_h1_20_2 > hi_h4_20_2) && (close_prices_c1 < ma10_m1);

            if(buy_cond || sel_cond)
              {
               double amp_discarded = amp_h1*0.1;
               double tp1_sel = price - amp_h1 + amp_discarded;
               double tp1_buy = price + amp_h1 - amp_discarded;

               double dbAmp     = MathAbs(hi_h1_20_1 - mi_h1_20_0);
               double volume = format_double(dblLotsRisk(symbol, dbAmp, risk), digits);
               volume1 = volume;
               volume2 = volume1 * 2;
               volume3 = volume2 * 2;

               //------------------------------------------
               if(buy_cond)
                 {
                  m_trade.Buy(volume1, symbol, 0.0, 0.0, tp1_buy, "BUY_1");
                  m_trade.BuyLimit(volume2, NormalizeDouble(lo_h1_20_3, digits), symbol, 0.0, NormalizeDouble(lo_h1_20_2, digits), 0, 0, "BUY_2");
                  m_trade.BuyLimit(volume3, NormalizeDouble(lo_h1_20_4, digits), symbol, 0.0, NormalizeDouble(lo_h1_20_3, digits), 0, 0, "BUY_3");

                  Alert(get_vntime(), "  BUY: ", symbol, "   price: ", price, "    tp1_buy: ", tp1_buy, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);
                 }
               //------------------------------------------
               //------------------------------------------
               //------------------------------------------
               if(sel_cond)
                 {
                  m_trade.Sell(volume1, symbol, 0.0, 0.0, tp1_sel, "SELL_1");
                  m_trade.SellLimit(volume2, NormalizeDouble(hi_h1_20_3, digits), symbol, 0.0, NormalizeDouble(hi_h1_20_2, digits), 0, 0, "SELL_2");
                  m_trade.SellLimit(volume3, NormalizeDouble(hi_h1_20_4, digits), symbol, 0.0, NormalizeDouble(hi_h1_20_3, digits), 0, 0, "SELL_3");

                  Alert(get_vntime(), "  SELL: ", symbol, "   price: ", price, "    tp1_sel: ", tp1_sel, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);
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
string get_vntime()
  {
   datetime vietnamTime = TimeCurrent() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + " ";
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
bool IsMarketClose()
  {
// Lấy giờ hiện tại theo múi giờ GMT
   datetime currentGMTTime = TimeCurrent();

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
double dbRisk(double dbRiskRatio, double INIT_EQUITY)
  {
   double dbValueAccount = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY),
                                     AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

   double dbValueRisk = fmax(INIT_EQUITY, dbValueAccount) * dbRiskRatio;

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
         if(toLower(symbol) == trading_symbol)
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
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            count_orders += 1;
            order_comments += m_order.Comment() + "; ";
           }
        }
     }

   if(count_possion + count_orders > 0)
     {
      //Alert(TimeCurrent(), "Opening: ", type, "    ", symbol, "    possion_comments: ", possion_comments, "    order_comments: ", order_comments);
     }

//-------------------------------------------------------------------------
// Trường hợp: Tất cả các lệnh LIMIT được mở & không thua -> đóng tất cả lệnh, đánh hòa.
   if((total_profit > 0) && (count_orders == 0))
     {
      ClosePosition(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp: các lệnh đang mở được đóng (do TP, hoặc đóng bằng tay) -> thì đóng tất cả các lệnh Orders
   if((count_possion == 0) && (count_orders > 0))
     {
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BUY_3/SELL_3 được đóng -> đóng tất cả Positions(No.1, No.2) & Orders
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BUY_3") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "SELL_3") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
// Trường hợp lệnh BUY_2/SELL_2 được đóng -> đóng tất cả Positions(No.1) & Orders(Mo.3)
   if((type == "buy") && (StringFind(possion_comments + order_comments, "BUY_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
   if((type == "sell") && (StringFind(possion_comments + order_comments, "SELL_2") < 0))
     {
      ClosePosition(symbol);
      CloseOrders(symbol);
     }
//-------------------------------------------------------------------------
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

//+------------------------------------------------------------------+
//- Điều kiện 1: Chưa có bất cứ lệnh nào (kể cả lệnh chờ)
//- Điều kiện 2: Bolliger band (20,2) trên của H1 vượt Bolliger band (20,2) trên của 4H.
//- Điệu kiện 3: Giá vượt Bolligerband (20,2) trên của H1.
//2. Entry:
//Khi có 2 điều kiện trên xảy ra cùng lúc, mở luôn 3 lệnh như sau:
//- Lệnh L1: SELL n Lot có vị thế ngay - TP biên trên boliger band (20,1)
//- Lệnh L2 - limit: SELL 2n Lot limit tại giá đúng bằng biên Bolliger band (20,3) - TP = giá lệnh 1.
//- Lệnh L3 - limit: SELL 4n Lot limit tại giá đúng bằng biên Bolliger band (20,4) - TP = giá lệnh 2.
//3. Thoát lệnh:
//- Khi lệnh 1 đạt TP. Lệnh 2 limit và lệnh 3 limit được hủy. Chờ đạt ĐK mới.
//- Khi lệnh 2 limit khớp. Nếu giá quay về giá TP của lệnh 2 ( chính là giá entry của lệnh 1). Thoát hết các lệnh ( Lệnh 1,2 đang có vị thế, lệnh 3 đang chờ cũng thoát)
//- Khi lệnh 3 limit khớp. Nếu giá quay về giá TP của lệnh 3 ( chính là giá entry của lệnh 2). Thoát hết các lệnh ( cả 3 lệnh đang có vị thế thoát hết, chờ game mới)
//- Còn lại là chờ đến khi cháy. ( Cutloss = tài khoản, để vòng lặp kết thúc, lúc này người chơi đánh giá lại tình hình và nạp tiền game mới sau).

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
