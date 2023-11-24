//+------------------------------------------------------------------+
//|                                    UltimateCoreTrendGuardian.mq5 |
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

string input BOT_NAME = "UltimateCoreTrendGuardian";
int input    EXPERT_MAGIC = 2023112423;

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
   EventSetTimer(30);

//---
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
//---
//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1;  // PERIOD_M15 PERIOD_H1
   double dbRiskRatio = 0.01;
   double risk = dbRisk(dbRiskRatio);
//End ----------------------------------------------------------------

   int count_candidate = 0;
   string waiting_symbols = "(M15) ";
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];

      int totalOpenOrders = 0;
      CountOrders(symbol, totalOpenOrders);
      if(totalOpenOrders > 0)
        {
         continue;
        }
      //--------------------------------------------------------
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
      CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);

      double up_h1_20_1 = upper_h1_20_1[0];
      double mid_h1 = middle_h1_20_1[0];
      double dn_h1_20_1 = lower_h1_20_1[0];

      string trend = check_ma_and_heiken_conditon(symbol, up_h1_20_1, mid_h1, dn_h1_20_1);

      if(trend != "")
        {
         count_candidate += 1;
         waiting_symbols += "(" + trend + ")" + symbol+ "; ";

         // dbRiskRatio=0.01 <-> 1% tài khoản/1 lệnh.
         double dbAmp = MathAbs(up_h1_20_1 - mid_h1);
         double lot_size = dblLotsRisk(symbol, dbAmp, risk);

         if(trend == "BUY")
           {
            m_trade.Buy(lot_size, symbol, (dn_h1_20_1 - dbAmp), 0.0, NormalizeDouble(up_h1_20_1, digits), "BUY_1");
            m_trade.BuyLimit(lot_size, NormalizeDouble(dn_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mid_h1, digits), 0, 0, "BUY_2");
            m_trade.BuyLimit(lot_size, NormalizeDouble(dn_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mid_h1, digits), 0, 0, "BUY_3");
           }

         if(trend == "SELL")
           {
            m_trade.Sell(lot_size, symbol, 0.0, (up_h1_20_1 + dbAmp), dn_h1_20_1, "SELL_1");
            m_trade.SellLimit(lot_size, NormalizeDouble(up_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mid_h1, digits), 0, 0, "SELL_2");
            m_trade.SellLimit(lot_size, NormalizeDouble(up_h1_20_1, digits), symbol, 0.0, NormalizeDouble(mid_h1, digits), 0, 0, "SELL_3");
           }
        }
     }

   if(count_candidate > 0)
      Alert(TimeCurrent(), " ", " (waiting) ", waiting_symbols);

  }
//+------------------------------------------------------------------+
string check_ma_and_heiken_conditon(string symbol, double up_h1_20_1, double mid_h1, double dn_h1_20_1)
  {
   int maLength = 50;
   double closePrices[50];
   for(int i = 0; i < maLength; i++)
     {
      closePrices[i] = iClose(symbol, PERIOD_M15, i);
     }

   double ma_20 = CalculateMA(closePrices, 20);
   double ma_50 = CalculateMA(closePrices, 50);
   double cur_price = SymbolInfoDouble(symbol, SYMBOL_BID);
   bool is_uptren_heiken_0 = is_uptren_heiken_0(symbol);

   if((cur_price < mid_h1) && (is_uptren_heiken_0 == true) && (dn_h1_20_1 < ma_50) && (ma_50 < ma_20) && (ma_20 < mid_h1))
     {
      return "BUY";
     }

   if((cur_price > mid_h1) && (is_uptren_heiken_0 == false) && (up_h1_20_1 > ma_50) && (ma_50 > ma_20) && (ma_20 > mid_h1))
     {
      return "SELL";
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_uptren_heiken_0(string symbol)
  {
   double haOpen0, haClose0, haHigh0, haLow0;
   CalculateHeikenAshi(symbol, 0, haOpen0, haClose0, haHigh0, haLow0);
   bool is_uptren_heiken0 = (haOpen0 < haClose0);

   return is_uptren_heiken0;
  }


// Hàm tính toán giá trị của nến Heiken Ashi
void CalculateHeikenAshi(string symbol, int index, double &haOpen, double &haClose, double &haHigh, double &haLow)
  {
// Lấy giá trị của nến trước đó
   double prevHaOpen = iOpen(symbol, PERIOD_M15, index + 1);
   double prevHaClose = iClose(symbol, PERIOD_M15, index + 1);
   double prevHaHigh = iHigh(symbol, PERIOD_M15, index + 1);
   double prevHaLow = iLow(symbol, PERIOD_M15, index + 1);

// Tính toán giá trị của nến Heiken Ashi
   haClose = (iOpen(symbol, PERIOD_M15, index) + iClose(symbol, PERIOD_M15, index) + iHigh(symbol, PERIOD_M15, index) + iLow(symbol, PERIOD_M15, index)) / 4.0;
   haOpen = (prevHaOpen + prevHaClose) / 2.0;
   haHigh = MathMax(iOpen(symbol, PERIOD_M15, index), MathMax(haClose, prevHaHigh));
   haLow = MathMin(iOpen(symbol, PERIOD_M15, index), MathMin(haClose, prevHaLow));
  }

// Hàm tính toán Moving Average (MA) với độ dài 50
double CalculateMA(double& prices[], int period)
  {
   double ma = 0.0;

// Tính tổng của giá đóng cửa của 50 nến gần nhất
   for(int i = 0; i < period; i++)
     {
      ma += prices[i];
     }

// Chia tổng cho số lượng nến để tính trung bình
   ma /= period;

   return ma;
  }


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
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
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
