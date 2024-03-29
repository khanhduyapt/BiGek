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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   DrawBB();
   EventSetTimer(30); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
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
   ObjectsDeleteAll();
//Start ------- Chỉnh sửa Timeframe muốn TP ở đây --------------------
   string tf_TP = "H1";
   ENUM_TIMEFRAMES TIME_FRAME_TP = PERIOD_H1; // PERIOD_M15 PERIOD_H1
//End ----------------------------------------------------------------

   string symbol = Symbol();
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
   double bb_up_h4 = upper_h4[0];
   double bb_lo_h4 = lower_h4[0];

   double upper_h1_dev1[], middle_h1_dev1[], lower_h1_dev1[];
   CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_dev1, middle_h1_dev1, lower_h1_dev1, digits, 1);
   double tp1_sel = upper_h1_dev1[0];
   double tp1_buy = lower_h1_dev1[0];

   double upper_h1_dev2[], middle_h1_dev2[], lower_h1_dev2[];
   CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_dev2, middle_h1_dev2, lower_h1_dev2, digits, 2);
   double bb_up_h1_dev2 = upper_h1_dev2[0];
   double bb_lo_h1_dev2 = lower_h1_dev2[0];

   double upper_h1_dev3[], middle_h1_dev3[], lower_h1_dev3[];
   CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_dev3, middle_h1_dev3, lower_h1_dev3, digits, 3);
   double bb_up_h1_dev3 = upper_h1_dev3[0];
   double bb_lo_h1_dev3 = lower_h1_dev3[0];

   double upper_h1_dev4[], middle_h1_dev4[], lower_h1_dev4[];
   CalculateBollingerBands(symbol, TIME_FRAME_TP, upper_h1_dev4, middle_h1_dev4, lower_h1_dev4, digits, 4);
   double bb_up_h1_dev4 = upper_h1_dev4[0];
   double bb_lo_h1_dev4 = lower_h1_dev4[0];




   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   create_lable("lbl_upper_h4", today_close_time, bb_up_h4, "                                H4(20, 2) " + format_double_to_string(bb_up_h4, digits) + "", clrBlack, digits);
   create_lable("lbl_lower_h4", today_close_time, bb_lo_h4, "                                H4(20, 2) " + format_double_to_string(bb_lo_h4, digits) + "", clrBlack, digits);

   create_trend_line("upper_h4", today_open_time, today_close_time, bb_up_h4, clrTeal, digits, false, false, true);
   create_trend_line("lower_h4", today_open_time, today_close_time, bb_lo_h4, clrTeal, digits, false, false, true);


   create_lable("lbl_up_h1_dev2", today_close_time, bb_up_h1_dev2, tf_TP + "(20, 2) "+ format_double_to_string(bb_up_h1_dev2, digits), clrBlue, digits);
   create_lable("lbl_up_h1_dev3", today_close_time, bb_up_h1_dev3, tf_TP + "(20, 3) "+ format_double_to_string(bb_up_h1_dev3, digits), clrFireBrick, digits);
   create_lable("lbl_up_h1_dev4", today_close_time, bb_up_h1_dev4, tf_TP + "(20, 4) "+ format_double_to_string(bb_up_h1_dev4, digits), clrRed, digits);

   create_trend_line("bb_up_h1_dev2", today_open_time, today_close_time, bb_up_h1_dev2, clrBlue, digits, false, false);
   create_trend_line("bb_up_h1_dev3", today_open_time, today_close_time, bb_up_h1_dev3, clrFireBrick, digits, false, false);
   create_trend_line("bb_up_h1_dev4", today_open_time, today_close_time, bb_up_h1_dev4, clrRed, digits, false, false);



   create_lable("lbl_lo_h1_dev2", today_close_time, bb_lo_h1_dev2, tf_TP + "(20, 2) "+ format_double_to_string(bb_lo_h1_dev2, digits), clrBlue, digits);
   create_lable("lbl_lo_h1_dev3", today_close_time, bb_lo_h1_dev3, tf_TP + "(20, 3) "+ format_double_to_string(bb_lo_h1_dev3, digits), clrFireBrick, digits);
   create_lable("lbl_lo_h1_dev4", today_close_time, bb_lo_h1_dev4, tf_TP + "(20, 4) "+ format_double_to_string(bb_lo_h1_dev4, digits), clrRed, digits);

   create_trend_line("bb_lo_h1_dev2", today_open_time, today_close_time, bb_lo_h1_dev2, clrBlue, digits, false, false);
   create_trend_line("bb_lo_h1_dev3", today_open_time, today_close_time, bb_lo_h1_dev3, clrFireBrick, digits, false, false);
   create_trend_line("bb_lo_h1_dev4", today_open_time, today_close_time, bb_lo_h1_dev4, clrRed, digits, false, false);


//Get price data
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double spread = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK) - price, digits);
//double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
//double avg_price = NormalizeDouble((current_bid + current_ask) / 2, digits);

//double price_h1_ema9 = CalculateEMA(symbol);
//double tp1_sel = NormalizeDouble(bb_up_h1_dev2 - ((bb_up_h1_dev2 - price_h1_ema9) / 2.0), digits);
//double tp1_buy = NormalizeDouble(bb_lo_h1_dev2 + ((price_h1_ema9 - bb_lo_h1_dev2) / 2.0), digits);

//create_lable_trim("lbl_h1_ma9", today_close_time, price_h1_ema9, "ma9", clrBlack, digits);
//create_trend_line("tp_h1_ma9", TimeCurrent(), today_close_time, price_h1_ema9, clrBlack, digits, false, false);

   create_lable("lbl_tp_sel_1", today_close_time, tp1_sel, tf_TP + "(20, 1) " + format_double_to_string(tp1_sel, digits) + " (TP)", clrBlack, digits);
   create_lable("lbl_tp_buy_1", today_close_time, tp1_buy, tf_TP + "(20, 1) " + format_double_to_string(tp1_buy, digits) + " (TP)", clrBlack, digits);

   create_trend_line("tp_sel_1", today_open_time, today_close_time, tp1_sel, clrBlack, digits, false, false);
   create_trend_line("tp_buy_1", today_open_time, today_close_time, tp1_buy, clrBlack, digits, false, false);

   bool buy_cond = (price < bb_lo_h1_dev2) && (bb_lo_h1_dev2 < bb_lo_h4);
   bool sel_cond = (price > bb_up_h1_dev2) && (bb_up_h1_dev2 > bb_up_h4);

   double riskAmount = 50.0; // Số tiền rủi ro (50 USD)
   double contractSize = GetContractSize(symbol);


   double volume1 = CalculateVolume(bb_lo_h1_dev2, tp1_buy, riskAmount, contractSize);
   volume1 = NormalizeDouble(volume1, digits);
   double volume2 = volume1 * 2.0;
   double volume3 = volume2 * 2.0;

   string risk_vol = "     contractSize: " + (string)contractSize + "$"
                     + "   RISK:" + (string)riskAmount + "$" + "    vol1:" + (string)volume1 + " vol2:" + (string)volume2 + " vol3:" +(string) volume3;

//
   Comment(TimeCurrent(), "    ", symbol, "    ", price, "    spread: ", spread
           , "\n\n"
           , "  BUY = ", buy_cond
           , "                      cond(1): price < H1(20, 2) = ", (price < bb_lo_h1_dev2)
           , "                      cond(2): H1(20, 2) < H4(20, 2) = ", (bb_lo_h1_dev2 < bb_lo_h4), "\n"
           , "  (trade1) BUY           (h1, dev2): ", format_double_to_string(bb_lo_h1_dev2, digits), "   tp(1): ", format_double_to_string(tp1_buy, digits), "\n"
           , "  (trade2) BUY  LIMIT (h1, dev3): ", format_double_to_string(bb_lo_h1_dev3, digits), "   tp(2): ", format_double_to_string(bb_lo_h1_dev2, digits), "\n"
           , "  (trade3) BUY  LIMIT (h1, dev4): ", format_double_to_string(bb_lo_h1_dev4, digits), "   tp(3): ", format_double_to_string(bb_lo_h1_dev3, digits), "\n"

           , "\n"
           , "  SELL = ", sel_cond
           , "                      cond(1): price > H1(20, 2) = ", (price > bb_up_h1_dev2)
           , "                      cond(2): H1(20, 2) > H4(20, 2) = ", (bb_up_h1_dev2 > bb_up_h4), "\n"
           , "  (trade1) SELL          (h1, dev2): ", format_double_to_string(bb_up_h1_dev2, digits), "   tp(1): ", format_double_to_string(tp1_sel, digits), "\n"
           , "  (trade2) SELL LIMIT (h1, dev3): ", format_double_to_string(bb_up_h1_dev3, digits), "   tp(2): ", format_double_to_string(bb_up_h1_dev2, digits), "\n"
           , "  (trade3) SELL LIMIT (h1, dev4): ", format_double_to_string(bb_up_h1_dev4, digits), "   tp(3): ", format_double_to_string(bb_up_h1_dev3, digits), "\n"
           , "\n"

          );
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Lấy contract size cho một symbol cụ thể
double GetContractSize(string symbol)
  {
   double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(volumeStep == 0.0)
     {
      Print("Lỗi: Không thể lấy thông tin về contract size cho symbol ", symbol);
      return 0.0;
     }

// Tính toán contract size
   double contractSize = 1000.0 / volumeStep;

   return contractSize;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateVolume(double entryPrice, double targetPrice, double riskAmount, double contractSize)
  {
// Tính toán khoảng cách giữa entry price và target price
   double distance = MathAbs(entryPrice - targetPrice);

// Tính toán số lượng lot dựa trên số tiền rủi ro, khoảng cách, và contract size
   double volume = (riskAmount / distance) / contractSize;

// Trả về khối lượng tính được
   return volume;
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
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {

   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }
//+------------------------------------------------------------------+
