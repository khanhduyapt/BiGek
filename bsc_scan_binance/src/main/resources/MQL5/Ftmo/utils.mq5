//+------------------------------------------------------------------+
//|                                                        utils.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool is_buy_now_by_ma_20_50_2r(string macd_h4, string macd_h1, string macd_minus
                               , double cur_price, double ma_20, double ma_50, double lo_h1_20_1, double mi_h1_20_0)
  {
   if((macd_h4 == TREND_BUY) && (macd_h4 == macd_h1) && (macd_h4 == macd_minus))
     {
      if((cur_price < lo_h1_20_1)  && (lo_h1_20_1 < ma_50) && (ma_50 < ma_20) && (ma_20 < mi_h1_20_0))
        {
         return true;
        }

      if((cur_price < mi_h1_20_0)  && (lo_h1_20_1 < ma_50) && (ma_50 < ma_20) && (ma_20 < mi_h1_20_0))
        {
         return true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool is_sell_now_by_ma_20_50_2r(string macd_h4, string macd_h1, string macd_minus
                                , double cur_price, double ma_20, double ma_50, double hi_h1_20_1, double mi_h1_20_0)
  {
   if((macd_h4 == TREND_SEL) && (macd_h4 == macd_h1) && (macd_h4 == macd_minus))
     {
      if((cur_price > hi_h1_20_1)  && (hi_h1_20_1 > ma_50) && (ma_50 > ma_20) && (ma_20 > mi_h1_20_0))
        {
         return true;
        }

      if((cur_price > ma_20)  && (hi_h1_20_1 > ma_50) && (ma_50 > ma_20) && (ma_20 > mi_h1_20_0))
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

  }

//+------------------------------------------------------------------+
string getType(string trend)
  {
   if(TREND_BUY == trend)
      return "(B)";

   if(TREND_SEL == trend)
      return "(S)";

   return "";
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

   return roundedLotSize;
  }

//+------------------------------------------------------------------+

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

// Hàm đếm số lần mức giá thấp nhất và cao nhất nằm trong mức giá hỗ trợ hoặc kháng cự
int CountPricesInRange(double& low[], double& high[], double priceLevel)
  {
   int count = 0;

   for(int i = 0; i < ArraySize(low); i++)
     {
      if((low[i] <= priceLevel) && (priceLevel <= high[i]))
        {
         count++;
        }
     }

   return count;
  }


// double deviation = 2; // Độ lệch chuẩn cho Bollinger Bands
// Hàm tính toán Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits, double deviation = 2)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
   int count = 50;//Bars(symbol, timeframe); // Số nến trên biểu đồ

   for(int i = 0; i < count; i++)
     {
      double sum = 0.0;
      double sumSquared = 0.0;

      for(int j = 0; j < period; j++)
        {
         double price = iClose(symbol, timeframe, i + j);
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
string get_trend_by_macd(string symbol, double& closePrices[])
  {
//int maLength = 50;
//double closePrices[50];
//ENUM_TIMEFRAMES TIME_FRAME;
//for(int i = maLength - 1; i >= 0; i--)
//  {
//   closePrices[i] = iClose(symbol, TIME_FRAME, i);
//  }

   double macd[];
   double signalLine[];
   int shortTermPeriod = 3;
   int longTermPeriod = 6;
   int signalPeriod = 9;
   CalculateMACDandSignal(closePrices, shortTermPeriod, longTermPeriod, signalPeriod, macd, signalLine);

   string result = "";
   double signal = signalLine[0];
   if(signal > 0)
     {
      result += TREND_BUY;
     }
   else
     {
      result += TREND_SEL;
     }

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_signal_macd(string symbol, double& closePrices[])
  {

   double macd[];
   double signalLine[];
   int shortTermPeriod = 3;
   int longTermPeriod = 6;
   int signalPeriod = 9;
   CalculateMACDandSignal(closePrices, shortTermPeriod, longTermPeriod, signalPeriod, macd, signalLine);

   string result = "";
   double signal = signalLine[0];

   return signal;
  }

// Hàm tính toán MACD và Signal Line
void CalculateMACDandSignal(double& prices[], int shortTermPeriod, int longTermPeriod, int signalPeriod, double& macd[], double& signal[])
  {
// Tính toán EMA ngắn hạn và dài hạn
   double emaShort[];
   double emaLong[];

   CalculateEMA(prices, emaShort, shortTermPeriod);
   CalculateEMA(prices, emaLong, longTermPeriod);

// Tính toán MACD
   ArrayResize(macd, ArraySize(prices));

   for(int i = 0; i < ArraySize(prices); i++)
     {
      macd[i] = emaShort[i] - emaLong[i];
     }

// Tính toán Signal Line
   CalculateSMA(macd, signal, signalPeriod);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//string log_msg = AppendSpaces(symbol) + AppendSpaces(TimeframeToString(TIME_FRAME)) + "\n";
//double ema[];
//CalculateEMA(closePrices, ema, 9);
//for(int index = 0; index < ArraySize(ema); index++)
//  {
//   log_msg += AppendSpaces("Bar " + (string) index);
//   log_msg += "  ema9: " + AppendSpaces(format_double_to_string(ema[index])) + "\n";
//  }
//log_msg += "\n\n\n";

// Hàm tính toán EMA -> TEST OK
void CalculateEMA(double& prices[], double& ema[], int period)
  {
   int maLength = ArraySize(prices);
   double smoothingFactor = 2.0 / (period + 1);

   ArrayResize(ema, maLength);

   CalculateSMA(prices, ema, period);

   for(int i = maLength - period; i > 0; i--)
     {
      double currentPrice = prices[i];
      double previousEMA = ema[i - 1];
      ema[i] = format_double((currentPrice * smoothingFactor) + (previousEMA * (1-smoothingFactor)), 5);
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Hàm tính toán Simple Moving Average (SMA) -> TEST OK
//string log_msg = AppendSpaces(symbol) + AppendSpaces(TimeframeToString(TIME_FRAME)) + "\n";
//double sma[];
//CalculateSMA(closePrices, sma, 9);
//for(int index = 0; index < ArraySize(sma); index++)
//  {
//   log_msg += AppendSpaces("Bar " + (string) index);
//   log_msg += "  sma9: " + AppendSpaces(format_double_to_string(sma[index])) + "\n";
//  }
//log_msg += "\n\n\n
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

string CurrentTimeframeToString()
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
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
  {
   switch(timeframe)
     {
      case PERIOD_M15:
         return "MINUTE_15";
      case PERIOD_H1:
         return "HOUR_01";
      case PERIOD_H4:
         return "HOUR_04";
      case PERIOD_D1:
         return "DAY";
      case PERIOD_W1:
         return "WEEK";
      case PERIOD_MN1:
         return "MONTH";
      default:
         return (string)timeframe +"?";
     }
  }
//+------------------------------------------------------------------+
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
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
void WriteToLog(string logMessage)
  {
// Mở hoặc tạo file log
   int fileHandle = FileOpen("FxSynergyScanner.txt", FILE_WRITE | FILE_TXT | FILE_CSV, ',');

   if(fileHandle != INVALID_HANDLE)
     {
      // Di chuyển đến cuối file để thêm dòng mới
      FileSeek(fileHandle, 0, SEEK_END);

      // Ghi string vào file
      FileWrite(fileHandle, logMessage + "\n\n");

      // Đóng file
      FileClose(fileHandle);
     }
   else
     {
      Print("Không thể mở hoặc tạo file log!");
     }
  }
//+------------------------------------------------------------------+
datetime GetVietnamTime()
  {
   datetime serverTime = TimeCurrent();

// Lấy thông tin về ngày và giờ từ giá trị thời gian
   MqlDateTime timeInfo;
   TimeToStruct(serverTime, timeInfo);

// Chuyển đổi giờ sang múi giờ Việt Nam (UTC+7)
   timeInfo.hour += 7;

// Kiểm tra xem có cần điều chỉnh ngày không
   if(timeInfo.hour >= 24)
     {
      timeInfo.hour -= 24;
      timeInfo.day++;
     }

// Tạo giá trị thời gian mới từ thông tin đã được điều chỉnh
   datetime vietnamTime = StructToTime(timeInfo);

   return vietnamTime;
  }
//+------------------------------------------------------------------+

string trend_parallel_vector_macd(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA, int slowEMA, int signal)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return macd;
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
   if((main_black_1 > m_signal_1) && (main_black_1 > main_black_2) && (m_signal_1 > m_signal_2))
      return TREND_BUY;

   if((main_black_1 < m_signal_1) && (main_black_1 < main_black_2) && (m_signal_1 < m_signal_2))
      return TREND_SEL;

   return "";
  }
  
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

   double main_black_1    = m_buff_MACD_main[1];
   double main_black_2    = m_buff_MACD_main[2];

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
string trend_by_signal_of_macd_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal = 9)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double main_black    = m_buff_MACD_main[1];

   double m_signal_1 = m_buff_MACD_signal[1];
//-------------------------------------------------
   if((m_signal_1 > 0) && (main_black > 0))
     {
      return TREND_BUY;
     }
//-------------------------------------------------
   if((m_signal_1 < 0) && (main_black < 0))
     {
      return TREND_SEL;
     }
//-------------------------------------------------
   return "";
  }


//+------------------------------------------------------------------+
bool is_stock_allow_trade_now(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int periodK, int periodD, int slowing, bool is_require_80_20)
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

   if(is_require_80_20)
     {
      if((find_trend == TREND_BUY) && (black_K <= 80 || red_D <= 80))
         return true;

      if((find_trend == TREND_SEL) && (black_K >= 80 || red_D >= 80))
         return true;
     }
   else
     {
      if((find_trend == TREND_BUY) && (black_K >= red_D))
         return true;

      if((find_trend == TREND_SEL) && (black_K <= red_D))
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
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


string switch_trend_by_histogram(string symbol, ENUM_TIMEFRAMES timeframe, int fastEMA = 12, int slowEMA = 26, int signal= 9)
  {
   int m_handle_macd = iMACD(symbol, timeframe, fastEMA, slowEMA, signal, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      return "___";
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];

   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 5, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 5, m_buff_MACD_signal);

   double m_histogarm_1 = m_buff_MACD_main[1];
   double m_histogarm_2 = m_buff_MACD_main[2];
   double m_signal_1 = m_buff_MACD_signal[1];
   double m_signal_2 = m_buff_MACD_signal[1];
//-------------------------------------------------
   if((m_histogarm_1 > 0) && (0 > m_histogarm_2) && (m_histogarm_1 > m_signal_1) && (m_histogarm_2 > m_signal_2))
      return TREND_BUY;

//-------------------------------------------------
   if((m_histogarm_1 < 0) && (0 < m_histogarm_2) && (m_histogarm_1 < m_signal_1) && (m_histogarm_2 < m_signal_2))
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateATR14(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int period = 14;
   double atr = 0.0;

// Lấy độ biến động (true range) của các nến
   for(int i = 1; i <= period; i++)
     {
      double high = iHigh(symbol, timeframe, i);
      double low = iLow(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i - 1);

      // Tính toán true range của nến
      double trueRange = MathMax(high - low, MathMax(MathAbs(high - close), MathAbs(low - close)));

      // Cộng dồn true range
      atr += trueRange;
     }


   atr /= period;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return NormalizeDouble(atr, digits);
  }
//+------------------------------------------------------------------
