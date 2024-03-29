//+------------------------------------------------------------------+
//|                                                      bb_line.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>

CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

#define  HR2400 (PERIOD_D1 * 60) // 86400 = 24 * 3600 = 1440 * 60
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   DrawBB();
   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   DrawBB();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBB()
  {
   string symbol = Symbol();

   ObjectsDeleteAll();

//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   string tf_TP = "H1";
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1; // PERIOD_M15 PERIOD_H1
//End ----------------------------------------------------------------


   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places


   double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
   CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);
   double hi_h1_20_1 = upper_h1_20_1[0];
   double mi_h1_20_0 = middle_h1_20_1[0];
   double lo_h1_20_1 = lower_h1_20_1[0];
   double amp = MathAbs(hi_h1_20_1 - mi_h1_20_0);


   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;


   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
   double hi_h4_20_2 = upper_h4[0];
   double lo_h4_20_2 = lower_h4[0];
   create_lable("H4(20, 2)", today_close_time, hi_h4_20_2, "                         H4(20, 2)", clrBlack, digits);
   create_lable("H4(20, 2)", today_close_time, lo_h4_20_2, "                         H4(20, 2)", clrBlack, digits);
   create_trend_line("hi_h4_20_2", today_open_time, today_close_time, hi_h4_20_2, clrTeal, digits, false, false, true);
   create_trend_line("lo_h4_20_2", today_open_time, today_close_time, lo_h4_20_2, clrTeal, digits, false, false, true);

   create_lable_trim("lbl_mi_h1_20_0", today_close_time, mi_h1_20_0, " mi " + tf_TP + "(20, 0) "+ format_double_to_string(mi_h1_20_0, digits), clrRed, digits);
   create_trend_line("mi_h1_20_0", today_open_time, today_close_time, mi_h1_20_0, clrRed, digits, false, false);
   ObjectSetInteger(0, "mi_h1_20_0", OBJPROP_STYLE, STYLE_DASH);

   for(int i = 2; i<=5; i++)
     {
      bool is_solid = (i==2) ? true : false;
      color line_color = (i!=2) ? clrBlack : clrBlue;
      double hi_h1_20_i = mi_h1_20_0 + (i*amp);
      double lo_h1_20_i = mi_h1_20_0 - (i*amp);
      create_lable_trim("lbl_hi_h1_20_" + (string)i, today_close_time, hi_h1_20_i, " hi " + tf_TP + "(20, " + (string)i + ") "+ format_double_to_string(hi_h1_20_i, digits), line_color, digits);
      create_lable_trim("lbl_lo_h1_20_" + (string)i, today_close_time, lo_h1_20_i, " lo " + tf_TP + "(20, " + (string)i + ") "+ format_double_to_string(lo_h1_20_i, digits), line_color, digits);
      create_trend_line("lo_h1_20_" + (string)i, today_open_time, today_close_time, lo_h1_20_i, line_color, digits, false, false, is_solid);
      create_trend_line("hi_h1_20_" + (string)i, today_open_time, today_close_time, hi_h1_20_i, line_color, digits, false, false, is_solid);
     }

//Get price data
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double spread = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK) - price, digits);

   create_lable_trim("lbl_hi_h1_20_1", today_close_time, hi_h1_20_1, " hi " + tf_TP + "(20, 1) " + format_double_to_string(hi_h1_20_1, digits), clrBlack, digits);
   create_lable_trim("lbl_lo_h1_20_1", today_close_time, lo_h1_20_1, " lo " + tf_TP + "(20, 1) " + format_double_to_string(lo_h1_20_1, digits), clrBlack, digits);

   create_trend_line("hi_h1_20_1", today_open_time, today_close_time, hi_h1_20_1, clrBlack, digits, false, false);
   create_trend_line("lo_h1_20_1", today_open_time, today_close_time, lo_h1_20_1, clrBlack, digits, false, false);


   double upper_d1_20_2[], middl_d1_20_2[], lower_d1_20_2[];
   CalculateBollingerBands(symbol, PERIOD_D1, upper_d1_20_2, middl_d1_20_2, lower_d1_20_2, digits, 2);
   double hi_d1_20_2 = upper_d1_20_2[0];
   double mi_d1_20_0 = middl_d1_20_2[0];
   double lo_d1_20_2 = lower_d1_20_2[0];

   create_lable("lbl_hi_d1_20_2", today_close_time, hi_d1_20_2, "D1(20, 2)", clrBlack, digits);
   create_lable("lbl_lo_d1_20_2", today_close_time, lo_d1_20_2, "D1(20, 2)", clrBlack, digits);
   create_trend_line("hi_d1_20_2", today_open_time, today_close_time, hi_d1_20_2, clrFireBrick, digits, false, false, false);
   create_trend_line("lo_d1_20_2", today_open_time, today_close_time, lo_d1_20_2, clrFireBrick, digits, false, false, false);

//------------------------------------------------------------------
// dbRiskRatio=0.01 <-> 1% tài khoản/1 lệnh.
   double dbRiskRatio = 0.01;
   double INIT_EQUITY = 200.0; //Vốn ban đầu 200$
   double risk = format_double(dbRisk(dbRiskRatio, INIT_EQUITY), 2);
   double dbAmp     = MathAbs(hi_h1_20_1 - mi_h1_20_0);
   double volume = format_double(dblLotsRisk(symbol, dbAmp, risk), digits);
//------------------------------------------------------------------
   string str_risk  =  "    Profit Today:" + format_double_to_string(get_profit_today(), 2) +"$";
   str_risk += "    Risk(" + (string)(dbRiskRatio*100) + "%)=" + (string) risk + "$";
   str_risk += "    " + symbol + "    Unit: " + (string)volume  + "(lot)";

//      string trend_heiken = AppendSpaces("(Heiken)");
//      trend_heiken += "15: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_M15, 0));
//      trend_heiken += "H1: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H1, 0));
//      trend_heiken += "H4: "+ AppendSpaces(get_trend_by_heiken(symbol, PERIOD_H4, 0));
//      string trend_macd = AppendSpaces("(Macd)");
//      trend_macd += "15: "+ AppendSpaces(get_trend_by_macd(symbol, PERIOD_M15));
//      trend_macd += "H1: "+ AppendSpaces(get_trend_by_macd(symbol, PERIOD_H1));
//      trend_macd += "H4: "+ AppendSpaces(get_trend_by_macd(symbol, PERIOD_H4));
//      // + "\n" + trend_heiken + "\n" + trend_macd + "\n"

   string comment = (string)TimeCurrent() + str_risk + "\n";
   Comment(comment);

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
//|                                                                  |
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
