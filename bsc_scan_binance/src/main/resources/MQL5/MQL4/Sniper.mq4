//+------------------------------------------------------------------+
//|                                                       Sniper.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double dbRiskRatio = 0.01; // Rủi ro 1%
double INIT_EQUITY = 20000.0; // Vốn đầu tư

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string LOCK_SEL = "_LoS_";
string LOCK_BUY = "_LoB_";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

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
   int count_possion_buy = 0, count_possion_sel = 0;
   int last_ticket_buy = 0, last_ticket_sel = 0;
   double last_entry_buy = 0, last_entry_sel = 0;
   double first_entry_buy = 1000000, first_entry_sel = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ");
         break;
        }

      //int eDigits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      //double point = MarketInfo(OrderSymbol(), MODE_POINT);
      //double ask = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
      //double bid = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
      //double TickSize = SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);

      if(OrderType() == OP_BUY)
        {
         count_possion_buy += 1;

         if(first_entry_buy > OrderOpenPrice())
            first_entry_buy = OrderOpenPrice();

         if(last_ticket_buy < OrderTicket())
           {
            last_ticket_buy = OrderTicket();
            last_entry_buy = OrderOpenPrice();
           }
        }


      if(OrderType() == OP_SELL)
        {
         count_possion_sel += 1;

         if(first_entry_sel < OrderOpenPrice())
            first_entry_sel = OrderOpenPrice();

         if(last_ticket_sel < OrderTicket())
           {
            last_ticket_sel = OrderTicket();
            last_entry_sel = OrderOpenPrice();
           }
        }
     }

   int NUMBER_OF_TRADE = 20;
   string trend_w3 = get_trend_by_stoc2(_Symbol, PERIOD_W1, 3, 2, 3, 0);
   string trend_w5 = get_trend_by_stoc2(_Symbol, PERIOD_W1, 5, 3, 3, 0);
   string trend_d10 = get_trend_by_ma(_Symbol, PERIOD_D1, 10, 1);

   string TRADER = "(Cent)";
//if(trend_w3 == trend_w5 && trend_w5 == trend_d10)
     {
      string symbol = Symbol();
      double init_volume = 0.01;
      int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
      string trend_init = trend_d10;

      double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      double price = (bid + ask)/2;
      double AMP_DCA = 3;
      double AMP_TP_DCA = AMP_DCA * 2;

      if(count_possion_buy == 0)
        {
         int ticket = OrderSend(symbol,OP_BUY, init_volume, Ask, 0, 0.0, Ask + AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1));
         if(ticket > 0)
            Print("BUY order opened.");
        }

      if(count_possion_sel == 0)
        {
         int ticket = OrderSend(symbol,OP_SELL, init_volume, Bid, 0, 0.0, Bid - AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel+1));
         if(ticket > 0)
            Print("SEL order opened.");
        }


      //-----------------------------------------------------------------------------
      if(count_possion_buy > 0 && count_possion_buy < NUMBER_OF_TRADE && (price < last_entry_buy - AMP_DCA))
        {
         double amp_tp = MathMax(AMP_TP_DCA, MathAbs(first_entry_buy - last_entry_buy)*0.618);
         double tp_buy = NormalizeDouble(price + amp_tp, digits);

         count_possion_buy += 1;
         bool longExecuted = OrderSend(symbol,OP_BUY, init_volume, price, 0, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy));
         if(longExecuted)
            ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
        }

      if(count_possion_sel > 0 && count_possion_sel < NUMBER_OF_TRADE && (price > last_entry_sel + AMP_DCA))
        {
         double amp_tp = MathMax(AMP_TP_DCA, MathAbs(last_entry_sel - first_entry_sel)*0.618);
         double tp_sel = NormalizeDouble(price - amp_tp, digits);

         count_possion_sel += 1;

         bool shortExecuted = OrderSend(symbol,OP_SELL, init_volume, price, 0, 0.0, tp_sel, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel));
         if(shortExecuted)
            ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
        }
      //-----------------------------------------------------------------------------
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ExceptLockKey(string symbol, string TRADING_TREND, double tp_price, string KEY_TO_CLOSE)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderTakeProfit() != tp_price)
                     if(is_same_symbol(OrderComment(), LOCK_BUY) == false && is_same_symbol(OrderComment(), LOCK_SEL) == false)
                       {
                        double new_sl = OrderStopLoss();
                        double new_tp = OrderTakeProfit();
                        if(is_same_symbol(TRADING_TREND, TREND_BUY))
                          {
                           if(tp_price > OrderOpenPrice())
                              new_tp = tp_price;
                           else
                              new_sl = tp_price;
                          }

                        if(is_same_symbol(TRADING_TREND, TREND_SEL))
                          {
                           if(tp_price < OrderOpenPrice())
                              new_tp = tp_price;
                           else
                              new_sl = tp_price;
                          }

                        if(!OrderModify(OrderTicket(),OrderOpenPrice(), new_sl, new_tp,0,Red))
                           Print("OrderModify error ",GetLastError());

                       }
        }
     } //for
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol, ENUM_TIMEFRAMES timeframe, int inK = 13, int inD = 8, int inS = 5, int candle_no = 0)
  {
   double M_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double M_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  1);// 1st bar
   double S_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
   double S_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,1);// 1st bar

   double black_K = M_0;
   double red_D = S_0;

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_nm(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return "B";

   if(is_same_symbol(TREND, TREND_SEL))
      return "S";

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og, string symbol_tg)
  {
   if(symbol_og == "" || symbol_og == "")
      return false;

   if(StringFind(toLower(symbol_og), toLower(symbol_tg)) >= 0)
      return true;

   if(StringFind(toLower(symbol_tg), toLower(symbol_og)) >= 0)
      return true;

   return false;
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
//|                                                                  |
//+------------------------------------------------------------------+
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
      return "0" + (string) trade_no;

   return (string) trade_no;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index,int candle_no = 1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close_1 = closePrices[candle_no];
   double ma = cal_MA(closePrices, ma_index, candle_no);

   if(close_1 > ma)
      return TREND_BUY;

   if(close_1 < ma)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= candle_no + ma_index; i++)
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
double cal_MA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = cal_MA(closePrices, ma_index);
   return ma_value;
  }
//+------------------------------------------------------------------+
