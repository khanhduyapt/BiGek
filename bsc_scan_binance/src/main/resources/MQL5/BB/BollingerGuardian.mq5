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
bool input is_requires_compare_BbH1_and_BbH4 = false;

//+------------------------------------------------------------------+
class MyDictionary
  {
private:
   string            keys[];
   int               values[];

public:
   // Hàm thêm một cặp key-value vào Dictionary
   void              Add(string key, int value)
     {
      ArrayResize(keys, ArraySize(keys) + 1);
      ArrayResize(values, ArraySize(values) + 1);
      keys[ArraySize(keys) - 1] = key;
      values[ArraySize(values) - 1] = value;
     }

   // Hàm lấy giá trị tương ứng với một key
   int               GetValue(string key)
     {
      for(int i = 0; i < ArraySize(keys); i++)
        {
         if(keys[i] == key)
            return values[i];
        }
      return 0; // Trả về 0 nếu key không tồn tại
     }

   // Hàm thiết lập giá trị cho một key
   void              SetValue(string key, int value)
     {
      for(int i = 0; i < ArraySize(keys); i++)
        {
         if(keys[i] == key)
           {
            values[i] = value;
            return; // Kết thúc hàm khi đã thiết lập giá trị cho key
           }
        }

      // Nếu key không tồn tại, thêm key mới và thiết lập giá trị
      Add(key, value);
     }

   string            toString()
     {
      string value = "";
      for(int i = 0; i < ArraySize(keys); i++)
        {
         if(values[i] > 0)
           {
            value += keys[i] + ":" + values[i] + "; ";
           }
        }

      return value;
     }
  };

MyDictionary myDict;

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
   EventSetTimer(30); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);


   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      myDict.Add(symbol, 0);
     }

   printf(BOT_NAME + " initialized: " + myDict.toString());


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
//string arr_symbol[] = {"AUDCHF"};

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      //------------------------------------------------------------------

      CleanTrade(symbol);

      //------------------------------------------------------------------
      int count_possion;
      int count_limit;
      CountOrders(symbol, count_possion, count_limit);
      // Alert(TimeCurrent(), "    symbol: ", symbol, "    count_possion: ", count_possion, "    count_limit: ", count_limit);

      if((count_possion + count_limit) == 0)
        {
         double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
         double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
         double avg_price = NormalizeDouble((bid + ask) / 2, digits);

         double current_price_sel = NormalizeDouble(bid, digits);
         double current_price_buy = NormalizeDouble(ask, digits);


         double upper_h4[], middle_h4[], lower_h4[];
         CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
         double bb_up_h4 = upper_h4[0];
         double bb_lo_h4 = lower_h4[0];

         double upper_h1_dev2[], middle_h1_dev2[], lower_h1_dev2[];
         CalculateBollingerBands(symbol, PERIOD_H1, upper_h1_dev2, middle_h1_dev2, lower_h1_dev2, digits, 2);
         double bb_up_h1_dev2 = upper_h1_dev2[0];
         double bb_lo_h1_dev2 = lower_h1_dev2[0];

         bool buy_cond = (avg_price < bb_lo_h1_dev2) && (bb_lo_h1_dev2 < bb_lo_h4);
         bool sel_cond = (avg_price > bb_up_h1_dev2) && (bb_up_h1_dev2 > bb_up_h4);

         if(is_requires_compare_BbH1_and_BbH4 == false)
           {
            buy_cond = (avg_price < bb_lo_h1_dev2);
            sel_cond = (avg_price > bb_up_h1_dev2);
           }

         if(buy_cond || sel_cond)
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

            double tp1_sel = NormalizeDouble(bb_up_h1_dev2 - ((bb_up_h1_dev2 - price_h1_ema9) / 2.0), digits);
            double tp1_buy = NormalizeDouble(bb_lo_h1_dev2 + ((price_h1_ema9 - bb_lo_h1_dev2) / 2.0), digits);
            double no_stop_loss = 0.0;

            //------------------------------------------
            if(buy_cond)
              {
               printf(" init buy: " + symbol + "   " + (string) myDict.GetValue(symbol));

               if(myDict.GetValue(symbol) == 0)
                 {
                  Alert(TimeCurrent(), "  BUY: ", symbol, "   price: ", current_price_buy, "    tp1_buy: ", tp1_buy, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);

                  if(m_trade.Buy(volume1, symbol, 0.0, 0.0, tp1_buy, "BUY_1"))
                    {
                     myDict.SetValue(symbol, 1);
                    }
                  else
                    {
                     //Alert(TimeCurrent(), " (Error) BUY_1: ", symbol, " ERROR:", m_trade.ResultRetcode(), "    ", m_trade.ResultRetcodeDescription());
                    }
                 }

               if(myDict.GetValue(symbol) == 1)
                 {
                  if(m_trade.BuyLimit(volume2, NormalizeDouble(bb_lo_h1_dev3, digits), symbol, no_stop_loss, NormalizeDouble(bb_lo_h1_dev2, digits), 0, 0, "BUY_2"))
                    {
                     myDict.SetValue(symbol, 2);
                     //Alert(TimeCurrent(), " (Error) BUY_2 BuyLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                    }
                 }

               if(myDict.GetValue(symbol) == 2)
                 {
                  if(m_trade.BuyLimit(volume3, NormalizeDouble(bb_lo_h1_dev4, digits), symbol, no_stop_loss, NormalizeDouble(bb_lo_h1_dev3, digits), 0, 0, "BUY_3"))
                    {
                     myDict.SetValue(symbol, 3);
                     //Alert(TimeCurrent(), " (Error) BUY_3 BuyLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                    }

                 }
              }
            //------------------------------------------
            //------------------------------------------
            //------------------------------------------
            if(sel_cond)
              {
               printf(" init buy: " + symbol + "   " + (string) myDict.GetValue(symbol));

               if(myDict.GetValue(symbol) == 0)
                 {
                  Alert(TimeCurrent(), "  SELL: ", symbol, "   price: ", current_price_sel, "    tp1_sel: ", tp1_sel, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);

                  if(m_trade.Sell(volume1, symbol, 0.0, 0.0, tp1_sel, "SELL_1"))
                    {
                     myDict.SetValue(symbol, 1);
                    }
                  else
                    {
                     //Alert(TimeCurrent(), " (Error) SELL_1: ", symbol, " ERROR:", m_trade.ResultRetcode(), "    ", m_trade.ResultRetcodeDescription());
                    }
                 }

               if(myDict.GetValue(symbol) == 1)
                 {
                  if(m_trade.SellLimit(volume2, NormalizeDouble(bb_up_h1_dev3, digits), symbol, no_stop_loss, NormalizeDouble(bb_up_h1_dev2, digits), 0, 0, "SELL_2"))
                    {
                     myDict.SetValue(symbol, 2);
                     //Alert(TimeCurrent(), " (Error) SELL_2 SellLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                    }
                 }

               if(myDict.GetValue(symbol) == 2)
                 {
                  if(m_trade.SellLimit(volume3, NormalizeDouble(bb_up_h1_dev4, digits), symbol, no_stop_loss, NormalizeDouble(bb_up_h1_dev3, digits), 0, 0, "SELL_3"))
                    {
                     myDict.SetValue(symbol, 3);
                     //Alert(TimeCurrent(), " (Error) SELL_3 SellLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                    }

                 }
              }
            //------------------------------------------
            //------------------------------------------
            //------------------------------------------
           }
        }
     }
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
   if((count_possion == 0) && (count_orders == 0))
     {
      myDict.SetValue(symbol, 0);
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
      myDict.SetValue(symbol, 0);
      //Alert(TimeCurrent(), " CloseOrders: ", type, "    ", symbol, "    possion_comments: ", possion_comments, "    order_comments: ", order_comments);
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

//// Tính toán EMA
//   double alpha = 2.0 / (period + 1);
//   double ema = h1_prices[0];
//
//   for(int i = 1; i < period; i++)
//     {
//      ema = alpha * h1_prices[i] + (1 - alpha) * ema;
//     }
//
//   return ema;

   double ma9_current = 0.0;
   int count = 9;

   for(int i = 0; i < count; i++)
     {
      ma9_current += h1_prices[i];
     }

   ma9_current /= count;

   return ma9_current;
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
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            count_possion = count_possion + 1;
           }
        }
     } //for

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            count_limit = count_limit + 1;
           }
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
