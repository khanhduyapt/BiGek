//+------------------------------------------------------------------+
//|                                                  BB_Guardian_D3.mq5 |
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

string input BOT_NAME = "BB_Guardian_D3";
int input    EXPERT_MAGIC = 20240101;

double dbRiskRatio = 0.01; // Rủi ro 1%
double INIT_EQUITY = 1000.0; // Vốn ban đầu 1000$

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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();

   EventSetTimer(180); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

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
   iBands(_Symbol,PERIOD_D1, 20, 0, 3, PRICE_CLOSE);
   trade_by_bb_d3(_Symbol);


   return;

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      trade_by_bb_d3(symbol);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trade_by_bb_d3(string symbol)
  {
   double risk = calcRisk();

   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
//------------------------------------------------------------------

   BbCleanTrade(symbol);

//------------------------------------------------------------------
   int count = 0;
   string lowcase_symbol = toLower(symbol);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = toLower(PositionGetSymbol(i));
      string lowcase_comment = toLower(PositionGetString(POSITION_COMMENT));

      if((lowcase_symbol == trading_symbol) && (StringFind(lowcase_comment, "bb_") >= 0))
        {
         count = count + 1;
        }
     }

   bool has_trade = false;
   if(count == 0)
     {
      double price = SymbolInfoDouble(symbol, SYMBOL_BID);
      //--------------------------------------------------------------------
      //double upper_h4[], middle_h4[], lower_h4[];
      //CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
      //double hi_h4_20_2 = upper_h4[0];
      //double lo_h4_20_2 = lower_h4[0];

      double upper_d1_20_1[], middl_d1_20_1[], lower_d1_20_1[];
      CalculateBollingerBands(symbol, PERIOD_D1, upper_d1_20_1, middl_d1_20_1, lower_d1_20_1, digits, 1);
      double hi_d1_20_1 = upper_d1_20_1[1];
      double mi_d1_20_0 = middl_d1_20_1[1];
      double lo_d1_20_1 = lower_d1_20_1[1];
      double amp_d1 = MathAbs(hi_d1_20_1 - mi_d1_20_0);

      double dic_top_price;
      double dic_amp_w;
      double dic_lot_size;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_lot_size);
      double week_amp = dic_amp_w;

      //--------------------------------------------------------------------
      //if(amp_d1 < week_amp)
      //   amp_d1 = week_amp;

      double volume = dblLotsRisk(symbol, amp_d1, risk);
      //--------------------------------------------------------------------
      double hi_d1_20_3 = mi_d1_20_0 + amp_d1*3;
      double hi_d1_20_4 = hi_d1_20_3 + amp_d1;
      double hi_d1_20_5 = hi_d1_20_4 + amp_d1;

      double lo_d1_20_3 = mi_d1_20_0 - amp_d1*3;
      double lo_d1_20_4 = lo_d1_20_3 - amp_d1;
      double lo_d1_20_5 = lo_d1_20_4 - amp_d1;

      bool buy_cond = (price < lo_d1_20_3);
      bool sel_cond = (price > hi_d1_20_3);

      if(buy_cond || sel_cond)
        {
         double tp1_sel = price - amp_d1;
         double tp1_buy = price + amp_d1;

         //------------------------------------------
         if(buy_cond)
           {
            has_trade = true;

            m_trade.Buy(volume, symbol, 0.0, lo_d1_20_5, tp1_buy, "BB_BUY_1");

            Alert(get_vntime(), BOT_NAME, "  BUY: ", symbol);
           }
         //------------------------------------------
         if(sel_cond)
           {
            has_trade = true;

            m_trade.Sell(volume, symbol, 0.0, hi_d1_20_5, tp1_sel, "BB_SELL_1");

            Alert(get_vntime(), BOT_NAME, "  SELL: ", symbol);
           }
         //------------------------------------------
        }


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trade_by_102050()
  {
   /*

            //--------------------------------------------------------------------
            if(has_trade == false)
              {
               int maLength = 55;
               double close_prices_m15[];
               ArrayResize(close_prices_m15, maLength);
               for(int i = maLength - 1; i >= 0; i--)
                 {
                  close_prices_m15[i] = iClose(symbol, PERIOD_M15, i);
                 }

               double ma10_M15 = CalculateMA(close_prices_m15, 10, 1);
               double ma20_M15 = CalculateMA(close_prices_m15, 20, 1);
               double ma50_M15 = CalculateMA(close_prices_m15, 50, 1);
               double close_M15_c1 = close_prices_m15[1];

               bool buy_cond = (close_M15_c1 > ma50_M15) && (ma10_M15 > ma20_M15) && (ma20_M15 > ma50_M15) && (mi_d1_20_0 > price) && (ma20_M15 > price);
               bool sel_cond = (close_M15_c1 < ma50_M15) && (ma10_M15 < ma20_M15) && (ma20_M15 < ma50_M15) && (mi_d1_20_0 < price) && (ma20_M15 < price);

               if(buy_cond)
                 {
                  has_trade = true;

                  m_trade.Buy(volume1, symbol, 0.0, price - amp_d1, price + amp_d1, "M15_BUY");
                  Alert(get_vntime(), "  M15_BUY : ", symbol);
                 }

               if(sel_cond)
                 {
                  has_trade = true;

                  m_trade.Sell(volume, symbol, 0.0, price + amp_d1, price - amp_d1, "M15_SELL");
                  Alert(get_vntime(), "  M15_SELL: ", symbol);
                 }
              }

            //--------------------------------------------------------------------
            if(has_trade == false)
              {
               int maLength = 55;
               double close_prices_m12[];
               ArrayResize(close_prices_m12, maLength);
               for(int i = maLength - 1; i >= 0; i--)
                 {
                  close_prices_m12[i] = iClose(symbol, PERIOD_M12, i);
                 }

               double ma10_M12 = CalculateMA(close_prices_m12, 10, 1);
               double ma20_M12 = CalculateMA(close_prices_m12, 20, 1);
               double ma50_M12 = CalculateMA(close_prices_m12, 50, 1);
               double close_M12_c1 = close_prices_m12[1];

               bool buy_cond = (close_M12_c1 > ma50_M12) && (ma10_M12 > ma20_M12) && (ma20_M12 > ma50_M12) && (mi_d1_20_0 > price) && (ma20_M12 > price);
               bool sel_cond = (close_M12_c1 < ma50_M12) && (ma10_M12 < ma20_M12) && (ma20_M12 < ma50_M12) && (mi_d1_20_0 < price) && (ma20_M12 < price);

               if(buy_cond)
                 {
                  has_trade = true;

                  m_trade.Buy(volume1, symbol, 0.0, price - amp_d1, price + amp_d1, "M12_BUY");
                  Alert(get_vntime(), "  M12_BUY : ", symbol);
                 }

               if(sel_cond)
                 {
                  has_trade = true;

                  m_trade.Sell(volume, symbol, 0.0, price + amp_d1, price - amp_d1, "M12_SELL");
                  Alert(get_vntime(), "  M12_SELL: ", symbol);
                 }
              }
            //--------------------------------------------------------------------
            if(has_trade == false)
              {
               int maLength = 55;
               double close_prices_m10[];
               ArrayResize(close_prices_m10, maLength);
               for(int i = maLength - 1; i >= 0; i--)
                 {
                  close_prices_m10[i] = iClose(symbol, PERIOD_M10, i);
                 }

               double ma10_M10 = CalculateMA(close_prices_m10, 10, 1);
               double ma20_M10 = CalculateMA(close_prices_m10, 20, 1);
               double ma50_M10 = CalculateMA(close_prices_m10, 50, 1);
               double close_M10_c1 = close_prices_m10[1];

               bool buy_cond = (close_M10_c1 > ma50_M10) && (ma10_M10 > ma20_M10) && (ma20_M10 > ma50_M10) && (mi_d1_20_0 > price) && (ma20_M10 > price);
               bool sel_cond = (close_M10_c1 < ma50_M10) && (ma10_M10 < ma20_M10) && (ma20_M10 < ma50_M10) && (mi_d1_20_0 < price) && (ma20_M10 < price);

               if(buy_cond)
                 {
                  has_trade = true;

                  m_trade.Buy(volume1, symbol, 0.0, price - amp_d1, price + amp_d1, "M10_BUY");
                  Alert(get_vntime(), "  M10_BUY : ", symbol);
                 }

               if(sel_cond)
                 {
                  has_trade = true;

                  m_trade.Sell(volume, symbol, 0.0, price + amp_d1, price - amp_d1, "M10_SELL");
                  Alert(get_vntime(), "  M10_SELL: ", symbol);
                 }
              }

            //--------------------------------------------------------------------
            if(has_trade == false)
              {
               double ma10_h1 = CalculateMA_XX(symbol, PERIOD_H1, 10, 1);
               double ma20_h1 = CalculateMA_XX(symbol, PERIOD_H1, 20, 1);
               double close_h1_c1 = iClose(symbol, PERIOD_H1, 1);

               double ma20_m15 = CalculateMA_XX(symbol, PERIOD_M15, 20, 1);
               double close_m15_c1 = iClose(symbol, PERIOD_M15, 1);

               bool buy_cond = (close_m15_c1 > ma20_m15) && (close_h1_c1 > ma20_h1) && (ma10_h1 > ma20_h1) && (mi_d1_20_0 >= price) && (close_price_m1_c1 > ma10_m1);
               bool sel_cond = (close_m15_c1 < ma20_m15) && (close_h1_c1 < ma20_h1) && (ma10_h1 < ma20_h1) && (mi_d1_20_0 <= price) && (close_price_m1_c1 < ma10_m1);

               if(buy_cond)
                 {
                  has_trade = true;

                  m_trade.Buy(volume1, symbol, 0.0, price - amp_d1, price + amp_d1, "H1_BUY");
                  Alert(get_vntime(), "  H1_BUY : ", symbol);
                 }

               if(sel_cond)
                 {
                  has_trade = true;

                  m_trade.Sell(volume, symbol, 0.0, price + amp_d1, price - amp_d1, "H1_SELL");
                  Alert(get_vntime(), "  H1_SELL: ", symbol);
                 }
              }
   */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   string computerName = TerminalInfoString(TERMINAL_CPU_NAME);
   string startString = "Core ";
   string endString = " @";
   int startIndex = StringFind(computerName, startString) + 5;
   int endIndex = StringFind(computerName, endString);
   if(startIndex != -1 && endIndex != -1)
     {
      computerName = StringSubstr(computerName, startIndex, endIndex - startIndex);
     }

   datetime vietnamTime = TimeCurrent() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + " ";
   return computerName + "   " + vntime;
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
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      totalHeight += candleHeight;
      count += 1;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / count;

   return format_double(averageHeight, 5);
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
double CalculateMA(double& closePrices[], int ma_index, int candle_no)
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
void BbCleanTrade(string symbol)
  {
   double risk = calcRisk();
   bool is_market_close = IsMarketClose();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         ulong ticket= m_position.Ticket();
         double profit = m_position.Profit();
         string trading_symbol = toLower(m_position.Symbol());
         string commnets = m_position.Comment();

         if((toLower(symbol) == trading_symbol) && (StringFind(toLower(commnets), "bb_") >= 0))
           {

            if(profit > risk)
              {
               m_trade.PositionClose(ticket);
               Alert(get_vntime(), "(POSITON_CLOSE)   ", symbol, "   Profit: ", (string) m_position.Profit(), "    ", commnets);
              }

            if(is_market_close && profit > 0)
              {
               //m_trade.PositionClose(ticket);
               //Alert(get_vntime(), "(MARKET_CLOSE)   ", symbol, "   Profit: ", (string) m_position.Profit(), "    ", commnets);
              }

           }
        }
     } //for

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
//|                                                                  |
//+------------------------------------------------------------------+
string get_volume_cur_symbol()
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_lot_size;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_lot_size);
   double week_amp = dic_amp_w;
   double risk_per_trade = calcRiskPerTrade();
   string volume = " Vol: " + format_double_to_string(dblLotsRisk(_Symbol, week_amp, risk_per_trade), 2) + "    ";

   return volume;
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
