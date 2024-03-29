//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//#include <MovingAverages.mqh>
#include <Trade\PositionInfo.mqh>
CPositionInfo  m_position;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string INDI_NAME = "DailyRange";
double dbRiskRatio = 0.001; // Rủi ro 0.1%
double INIT_EQUITY = 1000.0; // Vốn ban đầu 200$

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

//https://tradingview.com/chart/?symbol=USINTR
string arr_symbol[] =
  {
   "XAUUSD", "XAGUSD", "USOIL.cash", "BTCUSD",
   "US100.cash", "US30.cash", "US500.cash", "GER40.cash", "UK100.cash", "FRA40.cash", "AUS200.cash",
   "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
   "CADCHF", "CADJPY", "CHFJPY",
   "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
   "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
   "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
   "USDCAD", "USDCHF", "USDJPY"
  };

string PREFIX_TRADE_PERIOD_W1 = "W1";
string PREFIX_TRADE_PERIOD_D1 = "D1";
string PREFIX_TRADE_PERIOD_H4 = "H4";
string PREFIX_TRADE_VECHAI_H1 = "H1";
string PREFIX_TRADE_VECHAI_M15 = "M15";


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   CalculatePivot("PERIOD_W1", PERIOD_W1);
   CalculateAvgCandleHeigh("PERIOD_W1", PERIOD_W1);
   WriteNotifyToken();
   Draw_Amp_H(_Symbol);
   Draw_Entry(_Symbol);
   EventSetTimer(1800); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   WriteNotifyToken();
  }

//+------------------------------------------------------------------+
void WriteNotifyToken()
  {
   ObjectsDeleteAll();

   Draw_Amp_D_Wave(_Symbol);

   DrawDailyPivot();

   DrawBB_Label_D1();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Entry(string symbol)
  {
   int SMA_Handle = iMA(symbol,PERIOD_CURRENT,6,0,MODE_SMA,PRICE_CLOSE);
   double SMA_Buffer[];
   ArraySetAsSeries(SMA_Buffer, true);
   if(CopyBuffer(SMA_Handle,0,0,5,SMA_Buffer)>0)
     {
      ObjectDelete(0,"TREND_BY_ANGLE_2");
      ObjectCreate(0,"TREND_BY_ANGLE_2",OBJ_TRENDBYANGLE,0
                   , iTime(_Symbol,PERIOD_CURRENT,2), SMA_Buffer[2]
                   , iTime(_Symbol,PERIOD_CURRENT,1), SMA_Buffer[1]);
      ObjectSetInteger(0,"TREND_BY_ANGLE_2",OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0,"TREND_BY_ANGLE_2",OBJPROP_RAY_RIGHT,true);
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();
            double price_open = m_position.PriceOpen();
            double profit = m_position.Profit();
            datetime time = m_position.Time();
            string comments = m_position.Comment();
            string str_profit = StringFind(toLower(m_position.TypeDescription()), "buy") >= 0 ? "(B)" : "(S)" ;
            str_profit += format_double_to_string(profit, 2) + "$";

            datetime nex_time = time - (iTime(symbol, PERIOD_H1, 1) - iTime(symbol, PERIOD_H1, 10));
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

            color clr_profit_color = clrBlue;
            if(profit < 0)
               clr_profit_color = clrRed;

            color clr_trade2_color = StringFind(toLower(m_position.TypeDescription()), "buy") >= 0 ? clrBlue : clrRed ;
            double dic_top_price;
            double dic_amp_w;
            double dic_avg_candle_week;
            double dic_amp_init_d1;
            GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
            double week_amp = dic_amp_w;


            ENUM_TIMEFRAMES TRADE_PERIOD = get_period(comments);
            double amp_trade_default = get_amp_trade(symbol, TRADE_PERIOD);

            double haOpen1, haClose1, haHigh1, haLow1;
            CalculateHeikenAshi(symbol, TRADE_PERIOD, 1, haOpen1, haClose1, haHigh1, haLow1);
            string haTrend = haOpen1 < haClose1 ? TREND_BUY : TREND_SEL;

            //create_trend_line("open_trade_" + symbol, time, TimeCurrent(), price_open, clr_profit_color, digits, false, false);
            create_lable("lbl_" + (string) ticket, time, price_open, str_profit, clr_profit_color, digits);

            if(toLower(m_position.TypeDescription()) == toLower(TREND_BUY))
              {
               double amp_sl = price_open - amp_trade_default;
               create_trend_line("stop_trade_" + symbol, time, TimeCurrent(), amp_sl, clrRed, digits, false, false);

               create_trend_line("open_trade_No.2_of_" + (string) m_position.Ticket(), time, iTime(symbol, PERIOD_D1, 0), price_open - week_amp, clr_trade2_color, digits, false, true);
              }

            if(toLower(m_position.TypeDescription()) == toLower(TREND_SEL))
              {
               double amp_sl = price_open + amp_trade_default;
               create_trend_line("stop_trade_" + symbol, time, TimeCurrent(), amp_sl, clrRed, digits, false, false);

               create_trend_line("open_trade_No.2_of_" + (string) m_position.Ticket(), time, iTime(symbol, PERIOD_D1, 0), price_open + week_amp, clr_trade2_color, digits, false, true);
              }

           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Amp_H(string symbol)
  {
   ENUM_TIMEFRAMES TIMEFRAME = PERIOD_CURRENT;
   if(Period() > PERIOD_H4)
      return;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double amp_trade = get_amp_trade(symbol, Period());

   double lowest = 0.0;
   double higest = 0.0;
   double lowest_close = 0.0;
   double higest_close = 0.0;
   for(int i = 0; i <= 250; i++)
     {
      double lowPrice = iLow(symbol, PERIOD_H4, i);
      double higPrice = iHigh(symbol, PERIOD_H4, i);

      if((i == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((i == 0) || (higest < higPrice))
         higest = higPrice;

      if(i <= 21)
        {
         double close = iClose(symbol, TIMEFRAME, i);

         if((i == 1) || (lowest_close > lowPrice))
            lowest_close = lowPrice;

         if((i == 1) || (higest_close < higPrice))
            higest_close = higPrice;
        }
     }

   datetime cur_time = iTime(symbol, TIMEFRAME, 0);
   datetime nex_time = iTime(symbol, TIMEFRAME, 250);
   lowest = lowest - amp_trade;
   higest = higest + amp_trade;
   int count_line = int((higest - lowest) / amp_trade);

   for(int index = 0; index <= count_line; index ++)
     {
      double line_val = higest - amp_trade*index;
      create_trend_line("line_" + (string)index, cur_time, nex_time, line_val, clrGray, digits, false, true);
     }

   cur_time = iTime(symbol, TIMEFRAME, 1);
   nex_time = iTime(symbol, TIMEFRAME, 21);

   create_rectangle("lowest_higest", cur_time, lowest_close, nex_time, higest_close, clrBlue, STYLE_DOT);
   create_trend_line("mid_low_hig",  cur_time, nex_time, NormalizeDouble((lowest_close+higest_close)/2, digits), clrBlue, digits, false, false);
   ObjectSetInteger(0, "redrw_mid_low_hig", OBJPROP_STYLE, STYLE_DOT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Amp_D_Wave(string symbol)
  {
   if(Period() != PERIOD_D1 && Period() != PERIOD_H4 && Period() != PERIOD_H1)
      return;


   ENUM_TIMEFRAMES TIMEFRAME = Period();
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_amp_init_h4;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_amp_init_h4, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   double amp_percent = dic_amp_init_d1;

   int size = 55;
   string prefix = "d1";

   if(Period() == PERIOD_H1)
     {
      size = 65;
      prefix = "h1";
      amp_percent = dic_amp_init_h4/2;
     }

   bool is_h4 = (Period() == PERIOD_H4);
   if(is_h4)
     {
      size = 99;
      prefix = "h4";
      amp_percent = dic_amp_init_h4;
     }

   double lowest = 0;
   double higest = 0;
   int candle_index_buy = 1;
   int candle_index_sel = 1;

   int low_idx_h4_55 = 0, hig_idx_h4_55 = 0;
   double low_h4_55 = iClose(symbol, TIMEFRAME, 0), hig_h4_55 = 0.0;

   for(int i = 0; i <= size; i++)
     {
      double close = iClose(symbol, TIMEFRAME, i);

      if(i == 0 || higest <= close)
        {
         higest = close;
         candle_index_sel = i;
        }
      if(i == 0 || lowest >= close)
        {
         lowest = close;
         candle_index_buy = i;
        }


      if((is_h4 && i <= 45) && (hig_h4_55 <= close))
        {
         hig_h4_55 = close;
         hig_idx_h4_55 = i;
        }
      if((is_h4 && i <= 45) && (low_h4_55 >= close))
        {
         low_h4_55 = close;
         low_idx_h4_55 = i;
        }
     }
   bool is_bold = false;

   if(true)
     {
      //vẽ BUY
      datetime cur_time = iTime(symbol, TIMEFRAME, (candle_index_buy-2>0?candle_index_buy-2:0));
      if(Period() == PERIOD_H4)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_buy + 3);
      if(Period() == PERIOD_H1)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_buy + 3);

      datetime nex_time = iTime(symbol, TIMEFRAME, (candle_index_buy-3>0?candle_index_buy-3:candle_index_buy+3));

      double nex_price_1 = lowest*(1 + amp_percent*1);
      double nex_price_2 = lowest*(1 + amp_percent*2);
      double nex_price_3 = lowest*(1 + amp_percent*3);

      create_trend_line(prefix + ".buy_0", cur_time, nex_time, lowest,      clrDarkBlue, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_1", cur_time, nex_time, nex_price_1, clrDarkBlue, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_2", cur_time, nex_time, nex_price_2, clrDarkBlue, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_3", cur_time, nex_time, nex_price_3, clrDarkBlue, digits, false, false, is_bold, true);

      create_lable(prefix + ".lbl.buy_0",  nex_time, lowest, (string)(amp_percent*000) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_1",  nex_time, nex_price_1, (string)(amp_percent*100) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_2",  nex_time, nex_price_2, (string)(amp_percent*200) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_3",  nex_time, nex_price_3, (string)(amp_percent*300) +"%", clrBlack, digits);

      if(is_h4 && low_idx_h4_55 != candle_index_buy)
        {
         datetime time_w0_h4_fr = iTime(symbol, TIMEFRAME, (low_idx_h4_55-3>0?low_idx_h4_55-3:0));
         datetime time_w0_h4_to = iTime(symbol, TIMEFRAME, low_idx_h4_55+3);

         create_lable("lbl.w0.h4.buy_0",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*0), (string)(amp_percent*000) +"%", clrDarkBlue, digits);
         create_lable("lbl.w0.h4.buy_1",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*1), (string)(amp_percent*100) +"%", clrDarkBlue, digits);
         create_lable("lbl.w0.h4.buy_2",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*2), (string)(amp_percent*200) +"%", clrDarkBlue, digits);

         create_trend_line("w0.h4.buy_0", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*0), clrDarkBlue, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.buy_1", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*1), clrDarkBlue, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.buy_2", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*2), clrDarkBlue, digits, false, false, is_bold, true);
        }
     }

   if(true)
     {
      //vẽ SELL
      datetime cur_time = iTime(symbol, TIMEFRAME, (candle_index_sel-2>0?candle_index_sel-2:0));
      if(Period() == PERIOD_H4)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_sel + 3);
      if(Period() == PERIOD_H1)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_sel + 3);

      datetime nex_time = iTime(symbol, TIMEFRAME, (candle_index_sel-3>0?candle_index_sel-3:candle_index_sel+3));

      double nex_price_1 = higest*(1 - amp_percent*1);
      double nex_price_2 = higest*(1 - amp_percent*2);
      double nex_price_3 = higest*(1 - amp_percent*3);

      create_trend_line(prefix + ".sel_0", cur_time, nex_time, higest,      clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_1", cur_time, nex_time, nex_price_1, clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_2", cur_time, nex_time, nex_price_2, clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_3", cur_time, nex_time, nex_price_3, clrFireBrick, digits, false, false, is_bold, true);

      create_lable(prefix + ".lbl.sel_0",  nex_time, higest, (string)(amp_percent*000) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_1",  nex_time, nex_price_1, (string)(amp_percent*100) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_2",  nex_time, nex_price_2, (string)(amp_percent*200) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_3",  nex_time, nex_price_3, (string)(amp_percent*300) +"%", clrBlack, digits);

      if(is_h4 && low_idx_h4_55 != candle_index_sel)
        {
         datetime time_w0_h4_fr = iTime(symbol, TIMEFRAME, (hig_idx_h4_55-3>0?hig_idx_h4_55-3:0));
         datetime time_w0_h4_to = iTime(symbol, TIMEFRAME, hig_idx_h4_55+3);

         create_lable("lbl.w0.h4.sel_0",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*0), (string)(amp_percent*000) +"%",  clrFireBrick, digits);
         create_lable("lbl.w0.h4.sel_1",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*1), (string)(amp_percent*100) +"%",  clrFireBrick, digits);
         create_lable("lbl.w0.h4.sel_2",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*2), (string)(amp_percent*200) +"%",  clrFireBrick, digits);

         create_trend_line("w0.h4.sel_0", time_w0_h4_fr, time_w0_h4_to, hig_h4_55,                     clrFireBrick, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.sel_1", time_w0_h4_fr, time_w0_h4_to, hig_h4_55*(1 - amp_percent*1), clrFireBrick, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.sel_2", time_w0_h4_fr, time_w0_h4_to, hig_h4_55*(1 - amp_percent*2), clrFireBrick, digits, false, false, is_bold, true);
        }
     }

  }

//+------------------------------------------------------------------+
void DrawDailyPivot()
  {
   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

// -----------------------------------------------------------------------
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   datetime close_time_today = iTime(symbol, PERIOD_D1, 0) + 86400;
   double   yesterday_open   = iOpen(symbol, PERIOD_D1, 1);
   double   yesterday_close  = iClose(symbol, PERIOD_D1, 1);
   double   yesterday_high   = iHigh(symbol, PERIOD_D1, 1);
   double   yesterday_low    = iLow(symbol, PERIOD_D1, 1);
   color    yesterday_color  = get_line_color(yesterday_open, yesterday_close);

   double   today_open = iOpen(symbol, PERIOD_D1, 0);
   double   today_close = iClose(symbol, PERIOD_D1, 0);
   double   today_low = iLow(symbol, PERIOD_D1, 0);
   double   today_hig = iHigh(symbol, PERIOD_D1, 0);

   double pre_day_mid = (yesterday_high + yesterday_low) / 2.0;
   double today_mid = (today_hig + today_low) / 2.0;
   color day_mid_color = get_line_color(pre_day_mid, today_mid);

// -----------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;


   double temp_lowest = 0.0;
   double temp_higest = 0.0;
   for(int i = 0; i <= 250; i++)
     {
      double lowPrice = iLow(symbol, PERIOD_H4, i);
      double higPrice = iHigh(symbol, PERIOD_H4, i);

      if((i == 0) || (temp_lowest > lowPrice))
         temp_lowest = lowPrice;

      if((i == 0) || (temp_higest < higPrice))
         temp_higest = higPrice;
     }
   dic_top_price = temp_higest;
// -----------------------------------------------------------------------
   datetime time_1day = iTime(_Symbol, PERIOD_D1, 1) - iTime(_Symbol, PERIOD_D1, 2); // + iTime(_Symbol, PERIOD_H1, 7) - iTime(_Symbol, PERIOD_H1, 0)

   datetime week_time_1 = iTime(symbol, PERIOD_W1, 1); //Returns the opening time of the bar
   datetime shift_chart = iTime(_Symbol, _Period, 0) - iTime(_Symbol, _Period, 10);
   datetime time_candle_cur = iTime(_Symbol, _Period, 0) + shift_chart;
   for(int index = 0; index < 35; index ++)
     {
      color line_color = clrBlack;
      bool is_solid = false;
      if(index == 0)
        {
         //is_solid = true;
        }

      double w_s1  = dic_top_price - (week_amp*index);
      //create_lable("lbl_w_dn_"+ (string)index, time_candle_cur, w_s1, format_double_to_string(w_s1, digits), clrBlack, digits);
      create_trend_line("w_dn_" + (string)index, week_time_1, TimeGMT(), w_s1, line_color, digits, true, true, is_solid);
      ObjectSetInteger(0, "redrw_" + "w_dn_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "redrw_" + "w_dn_" + (string)index, OBJPROP_COLOR, clrSilver);

      double w_r1  = dic_top_price + (week_amp*index);
      //create_lable("lbl_w_up_"+ (string)index, time_candle_cur, w_r1, format_double_to_string(w_r1, digits), clrBlack, digits);
      create_trend_line("w_up_" + (string)index, week_time_1, TimeGMT(), w_r1, line_color, digits, true, true, is_solid);
      ObjectSetInteger(0, "redrw_" + "w_up_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "redrw_" + "w_up_" + (string)index, OBJPROP_COLOR, clrSilver);

      if(Period() < PERIOD_W1)
        {
         datetime temp_w_open_time = iTime(symbol, PERIOD_W1, index);
         create_vertical_line("w"+(string)index, temp_w_open_time, clrBlack,STYLE_DASHDOTDOT, 2);
        }
      else
         if(Period() == PERIOD_W1)
            create_vertical_line("w"+(string)index, iTime(symbol, PERIOD_MN1, index), clrBlack);
         else
            ObjectDelete(0, "w"+(string)index);
     }

   if(Period() < PERIOD_D1)
     {
      for(int index = 0; index < 150; index ++)
         create_vertical_line("d1."+(string)index, iTime(_Symbol, PERIOD_D1, index), clrSilver, STYLE_DASH);
     }

   if(Period() < PERIOD_H1)
     {
      for(int index = 0; index < 150; index ++)
         create_vertical_line("h4."+(string)index, iTime(_Symbol, PERIOD_H4, index), clrSilver, STYLE_DOT);
     }


   double lowest = 0.0;
   double higest = 0.0;
   for(int i = 0; i <= 21; i++)
     {
      double lowPrice = iLow(symbol, PERIOD_W1, i);
      double higPrice = iHigh(symbol, PERIOD_W1, i);

      if((i == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((i == 0) || (higest < higPrice))
         higest = higPrice;
     }

   double mid_price = NormalizeDouble((higest + lowest) / 2, digits-1);
//create_lable("lbl_mid_price", time_candle_cur + shift_chart/2, mid_price, format_double_to_string(mid_price, digits-1), clrBlack, digits);

   datetime time_pre_21w = iTime(symbol, PERIOD_W1, 21);
   create_trend_line("low_21w", time_pre_21w, TimeCurrent(), lowest,    clrBlueViolet, digits, false, false);
   create_trend_line("mid_21w", time_pre_21w, TimeCurrent(), mid_price, clrFireBrick,  digits, false, false);
   create_trend_line("hig_21w", time_pre_21w, TimeCurrent(), higest,    clrTomato,     digits, false, false);

//create_lable("lbl_low_21w", time_pre_21w, lowest,    "low_21w", clrBlack, digits);
//create_lable("lbl_mid_21w", time_pre_21w, mid_price, "mid_21w", clrBlack, digits);
//create_lable("lbl_hig_21w", time_pre_21w, higest,    "hig_21w", clrBlack, digits);

   ObjectSetInteger(0, "redrw_" + "low_21w", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "redrw_" + "hig_21w", OBJPROP_STYLE, STYLE_SOLID);

   ObjectSetInteger(0, "redrw_" + "mid_price", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, "redrw_" + "mid_price", OBJPROP_COLOR, clrFireBrick);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBB_Label_D1()
  {
   string symbol = Symbol();

   datetime label_postion = iTime(symbol, _Period, 0);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   string tradingview_symbol = _Symbol;
   StringReplace(tradingview_symbol, ".cash", "");

   double d1_ma10 = CalculateMA_XX(symbol, PERIOD_D1, 9, 0); //get_ma_value(symbol, PERIOD_D1, 10, 0);
   double h4_ma50 = CalculateMA_XX(symbol, PERIOD_H4, 50, 0); //get_ma_value(symbol, PERIOD_H4, 50, 0);
   create_lable_trim("d1_ma10", label_postion, d1_ma10, "   -------------D(9) " + tradingview_symbol, clrBlue, digits, 9);
   create_lable_trim("h4_ma50", label_postion, h4_ma50, "   ---H4(50)", clrDarkBlue, digits, 9);


   if(Period() > PERIOD_D1)
      return;

   string str_line = "   ";
   for(int index = 1; index <= 3; index++)
      str_line += "-";


   double upper_d1_20_1[], middle_d1_20_1[], lower_d1_20_1[];
   CalculateBollingerBands(symbol, PERIOD_D1, upper_d1_20_1, middle_d1_20_1, lower_d1_20_1, digits, 1);
   double hi_d1_20_1 = upper_d1_20_1[0];
   double mi_d1_20_0 = middle_d1_20_1[0];
   double lo_d1_20_1 = lower_d1_20_1[0];

   double amp_d1 = MathAbs(hi_d1_20_1 - mi_d1_20_0);

   string str_stop = " D(00)";
   double avg_amp_d1 = CalculateAverageCandleHeight(PERIOD_D1, symbol);

   double upper_h1[], middle_h1[], lower_h1[];
   CalculateBollingerBands(symbol, PERIOD_H1, upper_h1, middle_h1, lower_h1, digits, 1);
   double mi_h1_20_0 = middle_h1[0];
   double amp_h1 = MathAbs(upper_h1[0] - middle_h1[0]);
   double hi_h1_20_2 = mi_h1_20_0 + amp_h1*2;
   double lo_h1_20_2 = mi_h1_20_0 - amp_h1*2;
   create_lable_trim("Hi_H1(20, 2)", label_postion, hi_h1_20_2, str_line + "------------------H1+2", clrBlack, digits);
   create_lable_trim("Lo_H1(20, 2)", label_postion, lo_h1_20_2, str_line + "------------------H1-2", clrBlack, digits);

   double upper_15[], middle_15[], lower_15[];
   CalculateBollingerBands(symbol, PERIOD_M15, upper_15, middle_15, lower_15, digits, 1);
   double mi_15_20_0 = middle_15[0];
   double amp_15 = MathAbs(upper_15[0] - middle_15[0]);
   double hi_15_20_2 = mi_15_20_0 + amp_15*2;
   double lo_15_20_2 = mi_15_20_0 - amp_15*2;
   create_lable_trim("Hi_M15(20, 2)", label_postion, hi_15_20_2, str_line + "---------------------------15+2", clrBlack, digits);
   create_lable_trim("Lo_M15(20, 2)", label_postion, lo_15_20_2, str_line + "---------------------------15-2", clrBlack, digits);

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 1);
   double mi_h4_20_0 = middle_h4[0];
   double amp_h4 = MathAbs(upper_h4[0] - middle_h4[0]);

   double hi_h4_20_2 = mi_h4_20_0 + amp_h4*2;
   double lo_h4_20_2 = mi_h4_20_0 - amp_h4*2;


   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, str_line + "---------H4+2", clrBlack, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, str_line + "---------H4-2", clrBlack, digits);

//create_lable_trim("lbl_mi_d1_20_0", label_postion, mi_d1_20_0, str_line + " D00", clrBlack, digits);

   ObjectSetInteger(0, "redrw_" + "mi_d1_20_0", OBJPROP_STYLE, STYLE_DASH);
   for(int i = 2; i<=5; i++)
     {
      bool is_solid = false;
      bool is_ray_left = (i==2) ? true : false;
      color line_color = clrBlack;
      if(i == 1)
         line_color = clrDimGray;
      if(i == 2)
         line_color = clrBlue;
      if(i == 3)
         line_color = clrMediumSeaGreen;
      if(i == 4)
         line_color = clrBlack;
      if(i == 5)
         line_color = clrRed;
      line_color = clrBlack;

      double hi_d1_20_i = mi_d1_20_0 + (i*amp_d1);
      double lo_d1_20_i = mi_d1_20_0 - (i*amp_d1);

      create_lable_trim("lbl_hi_d1_20_" + (string)i, label_postion, hi_d1_20_i, str_line + " D+" + (string)i + "", line_color, digits);
      create_lable_trim("lbl_lo_d1_20_" + (string)i, label_postion, lo_d1_20_i, str_line + " D-" + (string)i + "", line_color, digits);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_period(string comments)
  {
   string TRADE_PERIOD = "";
   string low_comments =toLower(comments);

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_W1)) >= 0)
      return PERIOD_W1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
      return PERIOD_D1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
      return PERIOD_H4;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_H1)) >= 0)
      return PERIOD_H1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_VECHAI_M15)) >= 0)
      return PERIOD_M15;

   return PERIOD_H4;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_amp_trade(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double amp_trade = week_amp / 2;
   if(TIMEFRAME == PERIOD_H4)
      amp_trade = week_amp / 4;
   if(TIMEFRAME == PERIOD_H1)
      amp_trade = week_amp / 8;
   if(TIMEFRAME < PERIOD_H1)
      amp_trade = week_amp / 16;
   return amp_trade;
  }
//+------------------------------------------------------------------+
bool is_stoc_allow_find_trade_now(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
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

   if(black_K <= 20 || red_D <= 20)
      return true;

   if(black_K >= 80 || red_D >= 80)
      return true;

   return false;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CalculatePivot(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_AMP_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = calc_avg_amp_week(symbol, TIME_FRAME, 50);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }


//+------------------------------------------------------------------+
void CalculateAvgCandleHeigh(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_CANDLE_HEIGH_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = CalculateAverageCandleHeight(TIME_FRAME, symbol);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }

//+------------------------------------------------------------------+
bool IsMarketClose()
  {
// Lấy giờ hiện tại theo múi giờ GMT
   datetime currentGMTTime = TimeGMT();

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



// Hàm tính giá trị tối đa và tối thiểu của 50 cây nến gần nhất
void CalculateMaxMinPrices(string symbol, ENUM_TIMEFRAMES timeframe, double &maxPrice, double &minPrice)
  {
   maxPrice = -DBL_MAX; // Khởi tạo giá trị max với giá trị nhỏ nhất
   minPrice = DBL_MAX; // Khởi tạo giá trị min với giá trị lớn nhất

   int candlesToCheck = 50; // Số cây nến cần xem xét

   for(int i = 0; i < candlesToCheck; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i); // Giá cao nhất của cây nến
      double lowPrice = iLow(symbol, timeframe, i); // Giá thấp nhất của cây nến

      // Tìm giá trị max và min
      if(highPrice > maxPrice)
         maxPrice = highPrice;

      if(lowPrice < minPrice)
         minPrice = lowPrice;
     }
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
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   string cpu = "";
   string inputString = TerminalInfoString(TERMINAL_CPU_NAME);
   string startString = "Core ";
   string endString = " @";
   int startIndex = StringFind(inputString, startString) + 5;
   int endIndex = StringFind(inputString, endString);
   if(startIndex != -1 && endIndex != -1)
     {
      cpu = StringSubstr(inputString, startIndex, endIndex - startIndex);
     }

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   int current_gmt_hour = gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string vntime = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "    " + cpu + "   (GMT: " + (string) current_gmt_hour + "h) ";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_amp(double d_amp, double d_close, string name, int digits, datetime time_from, datetime time_to, double yesterday_low, double yesterday_high, const color d_color=clrBlack
              , bool ray_left = false, bool ray_right = true)
  {
   double d_s1  = d_close - d_amp;
   double d_r1  = d_close + d_amp;
   double d_s2  = d_s1 - d_amp;
   double d_r2  = d_r1 + d_amp;
   double d_s3  = d_s2 - d_amp;
   double d_r3  = d_r2 + d_amp;
   double d_s4  = d_s3 - d_amp;
   double d_r4  = d_r3 + d_amp;
   double d_s5  = d_s4 - d_amp;
   double d_r5  = d_r4 + d_amp;

   create_trend_line(name + "_cl", time_from, time_to, d_close, d_color, digits, ray_left, ray_right);

   if(d_s1 > yesterday_low)
      create_trend_line(name + "_s1", time_from, time_to, d_s1, d_color, digits, ray_left, ray_right);

   if(d_r1< yesterday_high)
      create_trend_line(name + "_r1", time_from, time_to, d_r1, d_color, digits, ray_left, ray_right);

   if(d_s2 > yesterday_low)
      create_trend_line(name + "_s2", time_from, time_to, d_s2, d_color, digits, ray_left, ray_right);

   if(d_r2 < yesterday_high)
      create_trend_line(name + "_r2", time_from, time_to, d_r2, d_color, digits, ray_left, ray_right);

   if(d_s3 > yesterday_low)
      create_trend_line(name + "_s3", time_from, time_to, d_s3, d_color, digits, ray_left, ray_right);

   if(d_r3 < yesterday_high)
      create_trend_line(name + "_r3", time_from, time_to, d_r3, d_color, digits, ray_left, ray_right);

   if(d_s4 > yesterday_low)
      create_trend_line(name + "_s4", time_from, time_to, d_s4, d_color, digits, ray_left, ray_right);

   if(d_s5 > yesterday_low)
      create_trend_line(name + "_s5", time_from, time_to, d_s5, d_color, digits, ray_left, ray_right);

   if(d_r4 < yesterday_high)
      create_trend_line(name + "_r4", time_from, time_to, d_r4, d_color, digits, ray_left, ray_right);

   if(d_r5 < yesterday_high)
      create_trend_line(name + "_r5", time_from, time_to, d_r5, d_color, digits, ray_left, ray_right);
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
   if(index <= 0)
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
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const bool              ray_left = false,
   const bool              ray_right = true,
   const bool              is_solid_line = false,
   const bool              is_alow_del = true
)
  {
   string name_new = "redrw_" + name;
   if(is_alow_del == false)
      name_new = name;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 2);
     }
   else
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK, true);
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
   TextCreate(0,"redrw_" + name, 0, time_to, price, "        " + format_double_to_string(price, digits), clr_color);
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
   TextCreate(0,"redrw_" + name, 0, time_to, price, "        " + label, clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_trim(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const int               font_size=8
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, label, clr_color);
   ObjectSetInteger(0,"redrw_" + name, OBJPROP_FONTSIZE,font_size);
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


//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool create_vertical_line(
   const string          name0="VLine",      // line name
   datetime              time=0,            // line time
   const color           clr=clrBlack,        // line color
   const ENUM_LINE_STYLE style=STYLE_DOT, // line style
   const int             width=1,           // line width
   const bool            back=true,        // in the background
   const bool            selection=false,    // highlight to move
   const bool            ray=false,          // line's continuation down
   const bool            hidden=true,      // hidden in the object list
   const long            z_order=0)         // priority for mouse click
  {
   string name= "redrw_" + name0;
   long chart_ID=0;
   int sub_window=0;      // subwindow index

   if(!time)
      time=TimeGMT();

   ResetLastError();

   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__, ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, true);
   return(true);
  }
//+------------------------------------------------------------------+
//https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_rectangle

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool create_rectangle(
   const string          name="Rectangle",  // rectangle name
   datetime              time1=0,           // first point time
   double                price1=0,          // first point price (Open)
   datetime              time2=0,           // second point time
   double                price2=0,          // second point price (Close)
   const color           def_color=clrBlack,
   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
   const int             width=1,           // width of rectangle lines
   const bool            fill=false,        // filling rectangle with color
   const bool            background=false,        // in the background
   const bool            selection=false,    // highlight to move
   const bool            hidden=true,       // hidden in the object list
   const long            z_order=0         // priority for mouse click
)
  {
   int sub_window=0;      // subwindow index
   long chart_ID=0;        // chart's ID
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

   color clr = get_line_color(price1, price2);
   if(def_color != clrBlack)
     {
      clr = def_color;
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
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,background);
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
      time1=TimeGMT();
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color get_line_color(double open_price, double close_price)
  {
   color candle_color = clrDarkGreen;
   if(open_price > close_price)
     {
      candle_color = clrFireBrick;
     }

   return candle_color;
  }
//+------------------------------------------------------------------+
string date_time_to_string(const MqlDateTime &deal_time)
  {
   string result = "";//(string)deal_time.year;
   if(deal_time.mon < 10)
     {
      result += "0" + (string)deal_time.mon ;
     }
   else
     {
      result += (string)deal_time.mon ;
     }
   if(deal_time.day < 10)
     {
      result += "0" + (string)deal_time.day ;
     }
   else
     {
      result += (string)deal_time.day;
     }


   return result;
  }

//+------------------------------------------------------------------+
double adjust_target_price(double ma10, double dic_top_price, double week_amp)
  {
   double target_price = dic_top_price;

   if(ma10 < dic_top_price)
     {
      // Nếu ma10 nhỏ hơn dic_top_price, giảm target_price cho đến khi nào nó nhỏ hơn ma10
      while(target_price - week_amp >= ma10)
        {
         target_price -= week_amp;
        }
     }
   else
     {
      // Nếu ma10 lớn hơn dic_top_price, tăng target_price cho đến khi nào nó lớn hơn ma10
      while(target_price + week_amp <= ma10)
        {
         target_price += week_amp;
        }
     }

// Kết quả cuối cùng
   return target_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 50; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      totalHeight += candleHeight;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / 10.0;

   return averageHeight;
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
//+------------------------------------------------------------------+
double CalculateMA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i < ma_index; i++)
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
double CalculateMA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = CalculateMA(closePrices, ma_index);
   return ma_value;
  }


//+------------------------------------------------------------------+
//|                                                                  |
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

//+------------------------------------------------------------------+
void ObjectsDeleteAll()
  {
   int totalObjects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      if(StringFind(objectName, "redrw_") >= 0 || StringFind(objectName, "dkd") >= 0)
         ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_amp_week(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_week_amp(symbol, TIMEFRAME, index);
     }
   double week_amp = total_amp / size;

   return week_amp;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol,  TIMEFRAME, week_index);
   double week_low = iLow(symbol,   TIMEFRAME, week_index);
   double week_clo = iClose(symbol, TIMEFRAME, week_index);

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




// Định nghĩa lớp CandleData
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend;
   int               count;
   // Default constructor
                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend = "";
      count = 0;
     }
                     CandleData(datetime t, double o, double h, double l, double c, string c_trend, int count_c1)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend = c_trend;
      count = count_c1;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountHeikenList(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_no, CandleData &candle_heiken)
  {
   CandleData candleArray[55];

   datetime pre_HaTime = iTime(symbol, TIME_FRAME, 54);
   double pre_HaOpen = iOpen(symbol, TIME_FRAME, 54);
   double pre_HaHigh = iHigh(symbol, TIME_FRAME, 54);
   double pre_HaLow = iLow(symbol, TIME_FRAME, 54);
   double pre_HaClose = iClose(symbol, TIME_FRAME, 54);
   string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0);
   candleArray[54] = candle;

   for(int index = 53; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh = MathMax(iOpen(symbol, TIME_FRAME, index), MathMax(haClose, pre_cancle.high));
      double haLow = MathMin(iOpen(symbol, TIME_FRAME, index), MathMin(haClose, pre_cancle.low));

      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_trend = 1;
      for(int j = index+1; j < 50; j++)
        {
         if(haTrend == candleArray[j].trend)
           {
            count_trend += 1;
           }
         else
           {
            break;
           }
        }

      CandleData candle(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle;
     }

   candle_heiken = candleArray[candle_no];
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(double& prices[], int period, int candle_no)
  {
   int maLength = ArraySize(prices);
   double smoothingFactor = 2.0 / (period + 1);

   double ema[];
   ArrayResize(ema, maLength);

   ema[maLength - 1] = prices[maLength - 1];

   for(int i = maLength - 2; i >= 0; i--)
     {
      double currentPrice = prices[i];
      double previousEMA = ema[i + 1];
      ema[i] = format_double((currentPrice * smoothingFactor) + (previousEMA * (1-smoothingFactor)), 5);
     }

   return ema[candle_no];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double get_ma_value(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index, int canlde_index)
//  {
//   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
//   int SMA_Handle = iMA(symbol,timeframe,ma_index,0,MODE_SMA,PRICE_CLOSE);
//   double SMA_Buffer[];
//   ArraySetAsSeries(SMA_Buffer, true);
//   if(CopyBuffer(SMA_Handle,0,0,5,SMA_Buffer)<=0)
//      return price;
//
//   return SMA_Buffer[canlde_index];
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
bool allow_trade_by_amp_50candle(string symbol, string find_trend)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   int count_candle = 0;
   int length_55 = 55;
   double close_prices_d1[];
   ArrayResize(close_prices_d1, length_55);
   for(int i = length_55 - 1; i >= 0; i--)
     {
      double temp_close = iClose(symbol, PERIOD_D1, i);
      if(temp_close > 0)
         count_candle += 1;

      close_prices_d1[i] = temp_close;
     }
   if(count_candle < 50)
      return false;

   double close_d1_c1 = close_prices_d1[1];

   double min_close_d1 = FindMinPrice(close_prices_d1);
   double max_close_d1 = FindMaxPrice(close_prices_d1);
   double amp_1_3 = MathAbs(max_close_d1 - min_close_d1) / 3;

   double sel_area = max_close_d1 - amp_1_3;
   double buy_area = min_close_d1 + amp_1_3;

   if(find_trend == TREND_BUY && price <= buy_area)
      return true;

   if(find_trend == TREND_SEL && price >= sel_area)
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_heiken(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   CandleData candle_heiken;
   CountHeikenList(symbol, timeframe, 1, candle_heiken);

   return candle_heiken.trend + "("+(string) candle_heiken.count+")" ;
  }

//+------------------------------------------------------------------+
string get_candle_switch_trend_adx(string symbol, ENUM_TIMEFRAMES timeframe, int ma_period)
  {
   double    ExtADXBuffer[];  // ADx
   double    ExtPDIBuffer[];  // DI+
   double    ExtNDIBuffer[];  // DI-

   ArraySetAsSeries(ExtADXBuffer, true);
   ArraySetAsSeries(ExtPDIBuffer, true);
   ArraySetAsSeries(ExtNDIBuffer, true);

   int adx_handle = iADX(symbol, timeframe, ma_period);

   if(adx_handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iADXWilder indicator for the symbol %s/%s, error code %d",
                  symbol,
                  EnumToString(timeframe),
                  GetLastError());
      //--- the indicator is stopped early
      return(string) INIT_FAILED;
     }

   int x = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   string trend = "";
   string str_adx = "";
   if(CopyBuffer(adx_handle,0,0,50,ExtADXBuffer)>=0
      && CopyBuffer(adx_handle,1,0,50,ExtPDIBuffer)>=0
      && CopyBuffer(adx_handle,2,0,50,ExtNDIBuffer)>=0)
     {
      str_adx = "   Adx: " + format_double_to_string(ExtADXBuffer[0], 2) + "   Dm+: " + format_double_to_string(ExtPDIBuffer[0], 2) + "   Dm-: " + format_double_to_string(ExtNDIBuffer[0], 2);

      if(ExtPDIBuffer[1] > ExtNDIBuffer[1])
        {
         trend = TREND_BUY;
         for(int i = 1; i < ArraySize(ExtADXBuffer) - 1; i++)
           {
            if(ExtPDIBuffer[i] < ExtNDIBuffer[i])
              {
               // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
               x = i;
               break;
              }
           }

        }
      else
        {
         trend = TREND_SEL;
         for(int i = 1; i < ArraySize(ExtADXBuffer) - 1; i++)
           {
            if(ExtPDIBuffer[i] > ExtNDIBuffer[i])
              {
               // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
               x = i;
               break;
              }
           }

        }

     }


   if(x != -1)
      return trend + "("+(string) x+")" ;// + str_adx;
   else
      return trend + "(5x)" ;//  + str_adx;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing)
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

   for(int i = 0; i < ArraySize(K) - 1; i++)
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

//+------------------------------------------------------------------+


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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd369(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string macd = "MACD";
   int m_handle_macd = iMACD(symbol, timeframe, 3, 6, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      macd += " Error in iMACD. Error code: " + (string)GetLastError();
      return macd;
     }

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_signal);

   double m_macd_current    = m_buff_MACD_main[0];
   double m_signal_current  = m_buff_MACD_signal[0];

//double m_macd_previous   = m_buff_MACD_main[1];
//double m_signal_previous = m_buff_MACD_signal[1];
//int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   return (m_signal_current > 0 ? TREND_BUY : TREND_SEL);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc323(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string stoch = "";

   int periodK = 3; // %K
   int periodD = 2; // %D
   int slowing = 3; // Slowing

   string indicatorPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Indicators\\Examples\\Stochastic.mq5";

   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
     {
      stoch += " Error in iStochastic. Error code: " + (string)GetLastError();
      return stoch;
     }

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);

   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);
   double blackK = K[0];
   double redD = D[0];
//stoch += "   K (Black) : " + (string) format_double_to_string(blackK, 2);
//stoch += "   D (Red) : " + (string) format_double_to_string(redD, 2);

   string trend_stoch = "";
   if(redD < blackK)
     {
      return TREND_BUY ;
     }

   if(redD > blackK)
     {
      return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &dic_amp_init_h4, double &dic_amp_init_d1)
  {
   if(symbol == "BTCUSD")
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.05;
      amp_w = 1357.35;
      dic_amp_init_h4 = 0.03;
      return;
     }

   if(symbol == "USOIL.cash" || symbol == "USOIL")
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.10;
      amp_w = 2.75;
      dic_amp_init_h4 = 0.05;
      return;
     }

   if(symbol == "XAGUSD")
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.06;
      amp_w = 0.63500;
      dic_amp_init_h4 = 0.03;
      return;
     }

   if(symbol == "XAUUSD")
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.03;
      amp_w = 27.83;
      dic_amp_init_h4 = 0.015;
      return;
     }

   if(symbol == "US500.cash" || symbol == "US500")
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.05;
      amp_w = 60.00;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "US100.cash" || symbol == "USTEC")
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.05;
      amp_w = 274.5;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "US30.cash" || symbol == "US30")
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.05;
      amp_w = 438.76;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "UK100.cash" || symbol == "UK100")
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.05;
      amp_w = 95.38;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "GER40.cash")
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "DE30")
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "FRA40.cash" || symbol == "FR40")
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "AUS200.cash" || symbol == "AUS200")
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
      amp_w = 93.59;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "AUDJPY")
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.100;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "AUDUSD")
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.015;
      return;
     }

   if(symbol == "EURAUD")
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01365;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "EURGBP")
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00497;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "EURUSD")
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0080;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "GBPUSD")
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      dic_amp_init_h4 = 0.01;
      return;
     }
   if(symbol == "USDCAD")
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00795;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "USDCHF")
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00750;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "USDJPY")
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.4250;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "CADCHF")
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.02;
      return;
     }

   if(symbol == "CADJPY")
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.0250;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "CHFJPY")
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.365000;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "EURJPY")
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.43500;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "GBPJPY")
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.61500;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "NZDJPY")
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.90000;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "EURCAD")
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00945;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "EURCHF")
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "EURNZD")
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01585;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "GBPAUD")
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01575;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "GBPCAD")
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "GBPCHF")
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0085;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "GBPNZD")
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.016250;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "AUDCAD")
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "AUDCHF")
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.005805;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "AUDNZD")
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00595;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "NZDCAD")
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.007200;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "NZDCHF")
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "NZDUSD")
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      dic_amp_init_h4 = 0.01;
      return;
     }

   if(symbol == "DXY")
     {
      i_top_price = 103.458;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.6995;
      dic_amp_init_h4 = 0.01;
      return;
     }

   i_top_price = iClose(symbol, PERIOD_W1, 1);
   dic_amp_init_d1 = 0.02;
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   dic_amp_init_h4 = 0.01;

   Alert(INDI_NAME, " Get SymbolData:",  symbol,"   i_top_price: ", i_top_price, "   amp_w: ", amp_w, "   dic_amp_init_h4: ", dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
