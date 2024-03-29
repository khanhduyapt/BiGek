//+------------------------------------------------------------------+
//|                                            TitanBollingerBot.mq5 |
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

string input BOT_NAME = "TitanBollingerBot";
int input    EXPERT_MAGIC = 20231124;

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
            value += keys[i] + ":" + (string) values[i] + "; ";
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
//--- create timer
   EventSetTimer(30); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      myDict.Add(symbol, 3);
     }

   string opening_symbols = "";
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int totalOpenOrders = 0;
      CountOrders(symbol, totalOpenOrders);
      if(totalOpenOrders > 0)
        {
         opening_symbols += symbol + "(" + (string)totalOpenOrders + ")" + "; ";
        }
     }
   Print((string)TimeCurrent() + " (OnInit) " + opening_symbols);

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
//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1;  // PERIOD_M15 PERIOD_H1
//End ----------------------------------------------------------------

   double dbRiskRatio = 0.01;
   double risk = dbRisk(dbRiskRatio);

   string opening_symbols = "";
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      //------------------------------------------------------------------

      CleanTrade(symbol);

      //------------------------------------------------------------------
      int totalOpenOrders = 0;
      CountOrders(symbol, totalOpenOrders);

      if(totalOpenOrders > 0)
        {
         opening_symbols += symbol + "(" + (string)totalOpenOrders + ")" + "; ";
        }

      myDict.SetValue(symbol, totalOpenOrders);

      bool allow_append_trade = false;
      if((totalOpenOrders == 0) && (myDict.GetValue(symbol) == 0))
        {
         allow_append_trade = true;
        }


      if(allow_append_trade)
        {
         double price = SymbolInfoDouble(symbol, SYMBOL_BID);

         double upper_h4[], middle_h4[], lower_h4[];
         CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
         double bb_up_h4 = upper_h4[0];
         double bb_lo_h4 = lower_h4[0];

         double upper_h1_20_2[], middle_h1_20_2[], lower_h1_20_2[];
         CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_2, middle_h1_20_2, lower_h1_20_2, digits, 2);
         double bb_up_h1_20_2 = upper_h1_20_2[0];
         double bb_lo_h1_20_2 = lower_h1_20_2[0];

         double upper_h1_20_3[], middle_h1_20_3[], lower_h1_20_3[];
         CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_3, middle_h1_20_3, lower_h1_20_3, digits, 3);
         double bb_up_h1_20_3 = upper_h1_20_3[0];
         double bb_lo_h1_20_3 = lower_h1_20_3[0];

         bool buy_cond = (price < bb_lo_h1_20_2) && (bb_lo_h1_20_2 < bb_lo_h4);
         bool sel_cond = (price > bb_up_h1_20_2) && (bb_up_h1_20_2 > bb_up_h4);


         if(buy_cond || sel_cond)
           {
            double upper_h1_20_4[], middle_h1_20_4[], lower_h1_20_4[];
            CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_4, middle_h1_20_4, lower_h1_20_4, digits, 4);
            double bb_up_h1_20_4 = upper_h1_20_4[0];
            double bb_lo_h1_20_4 = lower_h1_20_4[0];

            double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
            CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
            double tp1_sel = upper_h1_20_1[0];
            double tp1_buy = lower_h1_20_1[0];


            // dbRiskRatio=0.01 <-> 1% tài khoản/1 lệnh.
            double dbAmp = MathAbs(bb_lo_h1_20_4 - bb_lo_h1_20_3);
            double lot_size = dblLotsRisk(symbol, dbAmp, risk);
            double volume1 = format_double(lot_size, digits);
            double volume2 = format_double(lot_size * 2.0, digits);
            double volume3 = format_double(volume2 * 2.0, digits);

            //------------------------------------------
            if(buy_cond)
              {
               printf(" init buy: " + symbol + "   " + (string) myDict.GetValue(symbol));

               if(myDict.GetValue(symbol) == 0)
                 {
                  Alert(TimeCurrent(), "  BUY: ", symbol, "   price: ", price, "    tp1_buy: ", tp1_buy, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);

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
                  if(m_trade.BuyLimit(volume2, NormalizeDouble(bb_lo_h1_20_3, digits), symbol, 0.0, NormalizeDouble(bb_lo_h1_20_2, digits), 0, 0, "BUY_2"))
                    {
                     myDict.SetValue(symbol, 2);
                     //Alert(TimeCurrent(), " (Error) BUY_2 BuyLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                    }
                 }

               if(myDict.GetValue(symbol) == 2)
                 {
                  if(m_trade.BuyLimit(volume3, NormalizeDouble(bb_lo_h1_20_4, digits), symbol, 0.0, NormalizeDouble(bb_lo_h1_20_3, digits), 0, 0, "BUY_3"))
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
                  Alert(TimeCurrent(), "  SELL: ", symbol, "   price: ", price, "    tp1_sel: ", tp1_sel, "    vol1:", volume1, " vol2:", volume2, " vol3:", volume3);

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
                  if(m_trade.SellLimit(volume2, NormalizeDouble(bb_up_h1_20_3, digits), symbol, 0.0, NormalizeDouble(bb_up_h1_20_2, digits), 0, 0, "SELL_2"))
                    {
                     myDict.SetValue(symbol, 2);
                     //Alert(TimeCurrent(), " (Error) SELL_2 SellLimit: ", symbol, " ERROR:", m_trade.ResultRetcodeDescription());
                    }
                 }

               if(myDict.GetValue(symbol) == 2)
                 {
                  if(m_trade.SellLimit(volume3, NormalizeDouble(bb_up_h1_20_4, digits), symbol, 0.0, NormalizeDouble(bb_up_h1_20_3, digits), 0, 0, "SELL_3"))
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

   Print((string)TimeCurrent() + " (OnTimer) opening:" + opening_symbols);

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrders(string symbol, int &count)
  {
   count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            count += 1;
           }
        }
     } //for

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            count += 1;
           }
        }
     }

   return count;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double dbRisk(double dbRiskRatio)
  {
   double dbValueAccount = fmin(fmin(
                                   AccountInfoDouble(ACCOUNT_EQUITY),
                                   AccountInfoDouble(ACCOUNT_BALANCE)),
                                AccountInfoDouble(ACCOUNT_MARGIN_FREE));

   double dbValueRisk    = dbValueAccount * dbRiskRatio;

   return dbValueRisk;
  }
//+------------------------------------------------------------------+
// Calculate Max Lot Size based on Maximum Risk
//+------------------------------------------------------------------+
double dblLotsRisk(string symbol, double dbAmp, double dbRisk)
  {
   double dbLotsMinimum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double dbLotsMaximum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double dbLotsStep     = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double dbTickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   double dbLotReal      = (dbRisk / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   return roundedLotSize;
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
