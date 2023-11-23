//+------------------------------------------------------------------+
//|                                            BollingerGuardian.mq5 |
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

string input BOT_NAME = "BollingerGuardian";
int input    EXPERT_MAGIC = 2023112123456;

double input volume1 = 0.01;
double input volume2 = 0.02;
double input volume3 = 0.06;

string arr_symbol[] = {"XAUUSD", "BTCUSD",
                       "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
                       "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                       "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
                       "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                       "USDCAD", "USDCHF", "USDJPY", "CADJPY", "CHFJPY", "CADCHF"
                      };

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   EventSetTimer(10); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);
   printf(BOT_NAME + " initialized!");
//---
   return(INIT_SUCCEEDED);
  }

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
void OnTimer()
  {
//string arr_symbol[] = {"XAUUSD", "BTCUSD",
//                       "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
//                       "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
//                       "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
//                       "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
//                       "USDCAD", "USDCHF", "USDJPY", "CADJPY", "CHFJPY", "CADCHF"
//                      };

   string arr_symbol[] = {"AUDCHF"};

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      //------------------------------------------------------------------
      int count_possion;
      int count_limit;
      CountOrders(symbol, count_possion, count_limit);

      // Alert(TimeCurrent(), "    symbol: ", symbol, "    count_possion: ", count_possion, "    count_limit: ", count_limit);

      if((count_possion + count_limit) == 0)
        {
         double current_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
         double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
         double current_price = (current_bid + current_ask) / 2;


         double upper_h4[], middle_h4[], lower_h4[];
         CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
         double bb_up_h4 = upper_h4[0];
         double bb_lo_h4 = lower_h4[0];

         double upper_h1_dev2[], middle_h1_dev2[], lower_h1_dev2[];
         CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_dev2, middle_h1_dev2, lower_h1_dev2, digits, 2);
         double bb_up_h1_dev2 = upper_h1_dev2[0];
         double bb_lo_h1_dev2 = lower_h1_dev2[0];

         bool sel_cond_bb = (current_price > bb_up_h1_dev2) && (bb_up_h1_dev2 > bb_up_h4);
         bool buy_cond_bb = (current_price < bb_lo_h1_dev2) && (bb_lo_h1_dev2 < bb_lo_h4);

         //test
         //sel_cond_bb = true;

         if(sel_cond_bb || buy_cond_bb)
           {
            double upper_h1_dev3[], middle_h1_dev3[], lower_h1_dev3[];
            CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_dev3, middle_h1_dev3, lower_h1_dev3, digits, 3);
            double bb_up_h1_dev3 = upper_h1_dev3[0];
            double bb_lo_h1_dev3 = lower_h1_dev3[0];

            double upper_h1_dev4[], middle_h1_dev4[], lower_h1_dev4[];
            CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_dev4, middle_h1_dev4, lower_h1_dev4, digits, 4);
            double bb_up_h1_dev4 = upper_h1_dev4[0];
            double bb_lo_h1_dev4 = lower_h1_dev4[0];

            double price_h1_ema9 = CalculateEMA(symbol);
            double tp1_sel = (bb_up_h1_dev2 + price_h1_ema9) / 2.0;
            double tp1_buy = (bb_lo_h1_dev2 + price_h1_ema9) / 2.0;

            //------------------------------------------
            if(sel_cond_bb)
              {
               if(IsOpeningTradeWithComment(symbol, "SELL_1") == false)
                 {
                  Alert(TimeCurrent(), "  SELL: ", symbol, " vol1:", volume1, " vol2:", volume2, " vol3:", volume3);

                  if(!m_trade.PositionOpen(symbol, ORDER_TYPE_SELL, volume1, NormalizeDouble(current_price, digits), 0, NormalizeDouble(tp1_sel, digits), "SELL_1"))
                     Alert(" (Error) SELL_1: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                 }

               if(IsOpeningLimitWithComment(symbol, "SELL_2") == false)
                 {
                  if(!m_trade.SellLimit(volume2, NormalizeDouble(bb_up_h1_dev3, digits), symbol, 0.0, NormalizeDouble(bb_up_h1_dev2, digits), 0, 0, "SELL_2"))
                     Alert(" (Error) SELL_2 SellLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                 }

               if(IsOpeningLimitWithComment(symbol, "SELL_3") == false)
                 {
                  if(!m_trade.SellLimit(volume3, NormalizeDouble(bb_up_h1_dev4, digits), symbol, 0.0, NormalizeDouble(bb_up_h1_dev3, digits), 0, 0, "SELL_3"))
                     Alert(" (Error) SELL_3 SellLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                 }
              }

            //------------------------------------------
            if(buy_cond_bb)
              {
               if(IsOpeningTradeWithComment(symbol, "BUY_1") == false)
                 {
                  Alert(TimeCurrent(), "  BUY: ", symbol, " vol1:", volume1, " vol2:", volume2, " vol3:", volume3);

                  if(!m_trade.PositionOpen(symbol, ORDER_TYPE_BUY, volume1, NormalizeDouble(current_price, digits), 0, NormalizeDouble(tp1_buy, digits), "BUY_1"))
                     Alert(" (Error) BUY_1: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                 }

               if(IsOpeningLimitWithComment(symbol, "BUY_2") == false)
                 {
                  if(!m_trade.BuyLimit(volume2, NormalizeDouble(bb_lo_h1_dev3, digits), symbol, 0.0, NormalizeDouble(bb_lo_h1_dev2, digits), 0, 0, "BUY_2"))
                     Alert(" (Error) BUY_2 BuyLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                 }

               if(IsOpeningLimitWithComment(symbol, "BUY_3") == false)
                 {
                  if(!m_trade.BuyLimit(volume3, NormalizeDouble(bb_lo_h1_dev4, digits), symbol, 0.0, NormalizeDouble(bb_lo_h1_dev3, digits), 0, 0, "BUY_3"))
                     Alert(" (Error) BUY_3 BuyLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                 }
               //------------------------------------------
              }
           }
         else
            if(count_possion == 0)
              {
               //Close_All(symbol);
              }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
  {
// Kiểm tra nếu có lệnh đã đóng
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD && result.retcode == TRADE_RETCODE_PLACED)
     {
      // Kiểm tra nếu lệnh có Take Profit hoặc Stop Loss
      if(request.tp > 0 || request.sl > 0)
        {
         // Lấy thông tin về lệnh và tính toán lợi nhuận
         string symbol = request.symbol;

         // Hiển thị cửa sổ thông báo
         string alertMessage = StringFormat("Lệnh %d đã đóng vì Take Profit.\nSymbol: %s\nProfit: %f", trans.deal, symbol);
         Alert(alertMessage);

         Close_All(symbol);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOpeningTradeWithComment(string symbol, string comment)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         string trading_symbol = m_position.Symbol();
         string trading_comment = m_position.Comment();

         if((symbol == trading_symbol) && (trading_comment == comment))
           {
            return true;
           }
        }
     } //for

   return false; // Không tìm thấy lệnh thỏa mãn điều kiện
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOpeningLimitWithComment(string symbol, string comment)
  {
   int totalOrders = OrdersTotal(); // Lấy tổng số lệnh lịch sử
   for(int i = 0; i < totalOrders; i++)
     {
      if(OrderSelect(i))
        {
         string order_symbol = OrderGetString(ORDER_SYMBOL);
         string order_commnet = OrderGetString(ORDER_COMMENT);

         if((symbol == order_symbol) && (order_commnet == comment))
           {
            return true;
           }
        }
     }
   return false; // Không tìm thấy lệnh thỏa mãn điều kiện
  }

//+------------------------------------------------------------------+
void Close_All(string symbol)
  {
   double total_profit = 0;
   int count_possion = 0;
   string type = "";

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         string trading_symbol = m_position.Symbol();
         if(symbol == trading_symbol)
           {
            count_possion += 1;
            type = m_position.TypeDescription();
            total_profit += m_position.Profit();
            m_trade.PositionClose(m_position.Ticket());
           }
        }
     } //for

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      string order_symbol = OrderGetString(ORDER_SYMBOL);
      if(symbol == order_symbol)
        {
         ulong orderTicket = OrderGetTicket(i);
         if(OrderSelect(orderTicket))
           {
            count_possion += 1;
            m_trade.OrderDelete(orderTicket);
           }
        }
     }

   Alert("Close: ", type, "    ", symbol, "    Total Trade: ", count_possion,"   Total Profit: ", total_profit);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(string symbol)
  {
// Số lượng nến H1 cần lấy
   int n = 20;

// Khởi tạo mảng chứa giá đóng cửa của các nến H1 gần nhất
   double h1_prices[20];


// Lấy giá đóng cửa của các nến H1 gần nhất
   for(int i = 0; i < n; i++)
     {
      h1_prices[i] = iClose(_Symbol, PERIOD_H1, i);
     }

// Parameters
   int period = 9;

// Tính toán EMA
   double alpha = 2.0 / (period + 1);
   double ema = h1_prices[0];

   for(int i = 1; i < period; i++)
     {
      ema = alpha * h1_prices[i] + (1 - alpha) * ema;
     }

   return ema;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountOrders(string symbol, int &count_possion, int &count_limit)
  {
   count_possion = 0;
   count_limit = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      if(symbol == trading_symbol)
        {
         count_possion = count_possion + 1;
        }
     }


   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);
      string order_symbol = OrderGetString(ORDER_SYMBOL);
      if(symbol == order_symbol)
        {
         count_limit = count_limit + 1;
        }
     }

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

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
