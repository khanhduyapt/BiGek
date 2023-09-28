//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame = PERIOD_D1; // Chọn khung thời gian (D1 là mặc định)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   DrawDailyPivot();
   EventSetMillisecondTimer(60000); // Cập nhật mỗi phút
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   datetime current_time = TimeCurrent();
   datetime last_bar_time = iTime(Symbol(), TimeFrame, 0);
   if(current_time > last_bar_time)
     {
      ObjectsDeleteAll();
      DrawDailyPivot();
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
//Daily Pivot thường được tính dựa trên công thức sau:

//Pivot Point (PP): Điểm Pivot là điểm giữa giá đóng cửa (Close), giá cao (High), và giá thấp (Low) của phiên giao dịch trước đó. Công thức tính Pivot Point là:
//PP = (High + Low + Close) / 3

//Support và Resistance Levels: Dựa vào Pivot Point, bạn có thể tính toán các mức hỗ trợ (Support) và kháng cự (Resistance) hàng ngày.
//Các mức này thường được tính dựa trên các công thức khác nhau, nhưng một trong những cách phổ biến để tính mức Support và Resistance là sử dụng các công thức sau:

//Support 1 (S1): S1 = (2 * PP) - High
//Support 2 (S2): S2 = PP - (High - Low)
//Resistance 1 (R1): R1 = (2 * PP) - Low
//Resistance 2 (R2): R2 = PP + (High - Low)
//+------------------------------------------------------------------+
void DrawDailyPivot()
  {
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);// number of decimal places

   if(chartPeriod > PERIOD_H12)
     {
      //ObjectsDeleteAll();
      //return;
     }



   /*


      double mid = yesterday_close - yesterday_open;
      color candle_color = clrBlue;
      if(yesterday_open > yesterday_close)
        {
         candle_color = clrRed;
         mid = yesterday_open - yesterday_close;
        }

      mid = (mid / 2);

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
      if(yesterday_open > yesterday_close)
        {
         mid = yesterday_close + mid;
        }
      else
        {
         mid = yesterday_open + mid;
        }


   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
      double pivot = (daily_high + daily_low + yesterday_close) / 3;
      double support1 = (2 * pivot) - daily_high;
      double support2 = pivot - (daily_high - daily_low);
      double support3 = daily_low - 2 * (daily_high - pivot);
      double resistance1 = (2 * pivot) - daily_low;
      double resistance2 = pivot + (daily_high - daily_low);
      double resistance3 = daily_high + 2 * (pivot - daily_low);

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
      double amp = MathAbs(support3 - support2) + MathAbs(support2 - support1) + MathAbs(support1 - pivot) + MathAbs(pivot - resistance1) + MathAbs(resistance1 - resistance2) + MathAbs(resistance2 - resistance3);
      amp = format_double(amp / 6, digits);

      support1    = yesterday_close - amp;//mid - amp;
      resistance1 = yesterday_close + amp;//mid + amp;

      support2    = support1 - amp;
      resistance2 = resistance1 + amp;

      support3    = support2 - amp;
      resistance3 = resistance2 + amp;

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+

      mid                = format_double(mid, digits);
      pivot              = format_double(pivot, digits);
      support1           = format_double(support1, digits);
      support2           = format_double(support2, digits);
      support3           = format_double(support3, digits);
      resistance1        = format_double(resistance1, digits);
      resistance2        = format_double(resistance2, digits);
      resistance3        = format_double(resistance3, digits);



      ObjectCreate(0, "mid", OBJ_TREND, 0, daily_time, mid, TimeCurrent(), mid);
      ObjectSetInteger(0, "mid", OBJPROP_COLOR, candle_color);
      ObjectSetInteger(0, "mid", OBJPROP_STYLE, STYLE_SOLID);
      TextCreate(0,"Label_mid", 0, TimeCurrent(), mid, (string)mid + " d, amp:" +(string)amp, candle_color);

      ObjectCreate(0, "S1", OBJ_TREND, 0, daily_time, support1, TimeCurrent(), support1);
      ObjectSetInteger(0, "S1", OBJPROP_COLOR, clrBlack);
      TextCreate(0,"ds1", 0, TimeCurrent(), support1, (string)support1, clrBlack);

      ObjectCreate(0, "S2", OBJ_TREND, 0, daily_time, support2, TimeCurrent(), support2);
      ObjectSetInteger(0, "S2", OBJPROP_COLOR, clrBlack);
      TextCreate(0,"ds2", 0, TimeCurrent(), support2, (string)support2, clrBlack);

      ObjectCreate(0, "S3", OBJ_TREND, 0, daily_time, support3, TimeCurrent(), support3);
      ObjectSetInteger(0, "S3", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, "S3", OBJPROP_WIDTH, 2);
      TextCreate(0,"ds3", 0, TimeCurrent(), support3, (string)support3, clrBlack);

      ObjectCreate(0, "R1", OBJ_TREND, 0, daily_time, resistance1, TimeCurrent(), resistance1);
      ObjectSetInteger(0, "R1", OBJPROP_COLOR, clrBlack);
      TextCreate(0,"dr1", 0, TimeCurrent(), resistance1, (string)resistance1, clrBlack);

      ObjectCreate(0, "R2", OBJ_TREND, 0, daily_time, resistance2, TimeCurrent(), resistance2);
      ObjectSetInteger(0, "R2", OBJPROP_COLOR, clrBlack);
      TextCreate(0,"dr2", 0, TimeCurrent(), resistance2, (string)resistance2, clrBlack);

      ObjectCreate(0, "R3", OBJ_TREND, 0, daily_time, resistance3, TimeCurrent(), resistance3);
      ObjectSetInteger(0, "R3", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, "R3", OBJPROP_WIDTH, 2);
      TextCreate(0,"dr3", 0, TimeCurrent(), resistance3, (string)resistance3, clrBlack);
   */

   datetime daily_time   = iTime(Symbol(), TimeFrame, 1);
   double   yesterday_open   = iOpen(Symbol(), TimeFrame, 1);
   double   daily_high   = iHigh(Symbol(), TimeFrame, 1);
   double   daily_low    = iLow(Symbol(), TimeFrame, 1);
   double   yesterday_close  = iClose(Symbol(), TimeFrame, 1);
   double   today_open = iOpen(Symbol(), TimeFrame, 0);
   double   today_close = iClose(Symbol(), TimeFrame, 0);

   color candle_color = clrBlue;
   if(yesterday_open > yesterday_close)
     {
      candle_color = clrFireBrick;
     }

   /*
      for(int index = 1; index < 5; index++)
        {
         RectangleCreate(0, "day_"+ (string)index, 0,
                         iTime(Symbol(), PERIOD_D1, index + 1), iOpen(Symbol(), PERIOD_D1, index),
                         iTime(Symbol(), PERIOD_D1, index), iClose(Symbol(), PERIOD_D1, index));
        }
   */

//VLineCreate(0, "hkia_close", 0, iTime(Symbol(), TimeFrame, 1));
//VLineCreate(0, "hqua_close", 0, iTime(Symbol(), PERIOD_D1, 0));

// -----------------------------------------------------------------------
   double pre_week_open = iOpen(Symbol(), PERIOD_W1, 1);
   double pre_week_close = iClose(Symbol(), PERIOD_W1, 1);
   double pre_week_mid = format_double((pre_week_open + pre_week_close) / 2.0, digits);

   double this_week_open = iOpen(Symbol(), PERIOD_W1, 0);
   double this_week_close = iClose(Symbol(), PERIOD_W1, 0);
   double this_week_mid = format_double((this_week_open + this_week_close) / 2.0, digits);

   color week_mid_color = clrBlue;// Màu nền xanh cho tuần lên
   if(pre_week_mid > this_week_mid)
     {
      week_mid_color = clrFireBrick;
     }

   double week_hig = iHigh(Symbol(), PERIOD_W1, 1);
   double week_low = iLow(Symbol(), PERIOD_W1, 1);
   double week_clo = iClose(Symbol(), PERIOD_W1, 1);


   double week_pivot = format_double((week_hig + week_low + week_clo) / 3, digits);
   double week_s1    = format_double((2 * week_pivot) - week_hig, digits);
   double week_s2    = format_double(week_pivot - (week_hig - week_low), digits);
   double week_s3    = format_double(week_low - 2 * (week_hig - week_pivot), digits);
   double week_r1    = format_double((2 * week_pivot) - week_low, digits);
   double week_r2    = format_double(week_pivot + (week_hig - week_low), digits);
   double week_r3    = format_double(week_hig + 2 * (week_pivot - week_low), digits);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double week_amp = MathAbs(week_s3 - week_s2) + MathAbs(week_s2 - week_s1) + MathAbs(week_s1 - week_pivot) + MathAbs(week_pivot - week_r1) + MathAbs(week_r1 - week_r2) + MathAbs(week_r2 - week_r3);
   week_amp = format_double(week_amp / 6, digits);

   datetime pre_week_time = iTime(Symbol(), PERIOD_W1, 1);
   ObjectCreate(0, "Week_Trend", OBJ_TREND, 0, pre_week_time, pre_week_mid, TimeCurrent(), this_week_mid);
   ObjectSetInteger(0, "Week_Trend", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "Week_Trend", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "Week_Trend", OBJPROP_WIDTH, 2);
   TextCreate(0,"Label_Week_Trend", 0, TimeCurrent(), this_week_mid, "                                  " + (string)this_week_mid + " w", week_mid_color);


// Lấy chỉ số của ngày trong tuần
//int dayOfWeek = TimeDayOfWeek(TimeCurrent());

// Mảng chứa tên các ngày trong tuần
   string daysOfWeek[7];
   daysOfWeek[0] = "Sun";   // Sunday
   daysOfWeek[1] = "Mon";    // Monday
   daysOfWeek[2] = "Tue";     // Tuesday
   daysOfWeek[3] = "Wed";     // Wednesday
   daysOfWeek[4] = "Thu";    // Thursday
   daysOfWeek[5] = "Fri";    // Friday
   daysOfWeek[6] = "Sat";    // Saturday

   MqlDateTime ngay_0;
   TimeToStruct(TimeCurrent(), ngay_0);


   /*
      for(int index = ngay_0.day_of_week - 1; index > 1; index--)
        {
         MqlDateTime ngay_i;
         TimeToStruct(iTime(Symbol(), PERIOD_D1, index), ngay_i);

         RectangleCreate(0, daysOfWeek[ngay_i.day_of_week]
                         , iTime(Symbol(), PERIOD_D1, ngay_i.day_of_week)
                         , iOpen(Symbol(), PERIOD_D1, ngay_i.day_of_week)
                         , iTime(Symbol(), PERIOD_D1, ngay_i.day_of_week - 1)
                         , iClose(Symbol(), PERIOD_D1, ngay_i.day_of_week));
        }
   */


   RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-5), iTime(Symbol(), PERIOD_D1, 5), iOpen(Symbol(), PERIOD_D1, 5), iTime(Symbol(), PERIOD_D1, 4), iClose(Symbol(), PERIOD_D1, 5));
   RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-4), iTime(Symbol(), PERIOD_D1, 4), iOpen(Symbol(), PERIOD_D1, 4), iTime(Symbol(), PERIOD_D1, 3), iClose(Symbol(), PERIOD_D1, 4));
   RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-3), iTime(Symbol(), PERIOD_D1, 3), iOpen(Symbol(), PERIOD_D1, 3), iTime(Symbol(), PERIOD_D1, 2), iClose(Symbol(), PERIOD_D1, 3));
   RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-2), iTime(Symbol(), PERIOD_D1, 2), iOpen(Symbol(), PERIOD_D1, 2), iTime(Symbol(), PERIOD_D1, 1), iClose(Symbol(), PERIOD_D1, 2));
   RectangleCreate(0, get_day_of_week(ngay_0.day_of_week-1), iTime(Symbol(), PERIOD_D1, 1), iOpen(Symbol(), PERIOD_D1, 1), iTime(Symbol(), PERIOD_D1, 0), iClose(Symbol(), PERIOD_D1, 1));
   RectangleCreate(0, get_day_of_week(ngay_0.day_of_week), iTime(Symbol(), PERIOD_D1, 0), today_open, TimeCurrent(), today_close);

   double close = iClose(Symbol(), PERIOD_W1, 1);//default=1: hôm qua; 2:hôm kia; 3: hôm kìa
   double w_s1  = close - week_amp;
   double w_r1  = close + week_amp;
   double w_s2  = w_s1 - week_amp;
   double w_r2  = w_r1 + week_amp;
   double w_s3  = w_s2 - week_amp;
   double w_r3  = w_r2 + week_amp;


   create_trend_line("yesterday_close",pre_week_time, TimeCurrent(), close, clrBlack);

   create_trend_line("w_s1",pre_week_time, TimeCurrent(), w_s1, clrBlack);
   create_trend_line("w_r1",pre_week_time, TimeCurrent(), w_r1, clrBlack);
   TextCreate(0,"Label_Week_Amp", 0, TimeCurrent(), w_s3, "                                  amp:" +(string)week_amp, week_mid_color);

   create_trend_line("w_s2",pre_week_time, TimeCurrent(), w_s2, clrBlack);
   create_trend_line("w_r2",pre_week_time, TimeCurrent(), w_r2, clrBlack);

   create_trend_line("w_s3",pre_week_time, TimeCurrent(), w_s3, clrBlack);
   create_trend_line("w_r3",pre_week_time, TimeCurrent(), w_r3, clrBlack);

// ----------------------------------------------------------------------



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_of_week(const int index)
  {
   string daysOfWeek[7];
   daysOfWeek[0] = "Sun";   // Sunday
   daysOfWeek[1] = "Mon";   // Monday
   daysOfWeek[2] = "Tue";   // Tuesday
   daysOfWeek[3] = "Wed";   // Wednesday
   daysOfWeek[4] = "Thu";   // Thursday
   daysOfWeek[5] = "Fri";   // Friday
   daysOfWeek[6] = "Sat";   // Saturday

   if((1 <= index) && (index <= 5))
     {
      return daysOfWeek[index];
     }
   if(index == -1)
     {
      return daysOfWeek[5+index];
     }


   return "d" + (string)index;
  }


//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {

   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed               // color
)
  {
   ObjectCreate(0, name, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, true);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false); // Bật tính năng "Rời qua phải"
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);

   TextCreate(0,"lbl_" + name, 0, time_to, price, format_double_to_string(price, 5), clr_color);
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
                const int               font_size=10,             // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_CENTER,     // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=false,             // hidden in the object list
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

   StringReplace(text, "00000000001", "");
   StringReplace(text, "99999999999", "");
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,"                " + text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
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


//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool VLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="VLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time=0,            // line time
                 const color           clr=clrBlack,        // line color
                 const ENUM_LINE_STYLE style=STYLE_DOT, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=false,    // highlight to move
                 const bool            ray=true,          // line's continuation down
                 const bool            hidden=false,      // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the line time is not set, draw it via the last bar
   if(!time)
      time=TimeCurrent();
//--- reset the error value
   ResetLastError();
//--- create a vertical line
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of displaying the line in the chart subwindows
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_rectangle

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price (Open)
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price (Close)
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=false,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
   int             sub_window=0;      // subwindow index

//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }

   color clr=clrRed;        // rectangle color
   if(price2 > price1)
     {
      clr=clrGreen;
     }


//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
