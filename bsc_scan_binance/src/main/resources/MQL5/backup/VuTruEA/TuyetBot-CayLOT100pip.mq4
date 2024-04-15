//+------------------------------------------------------------------+
//|                                           Strategy: TuyetBot.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "https://www.eabuilder.com"
#property version   "1.00"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>
extern bool BuyKhongDieuKienEMA = true;
extern bool BuyNenNamTrongEMA = true;
extern bool SellKhongDieuKienEMA = true;
extern bool SellNenNamTrongEMA = true;

extern double Lot = 0.01;
extern double SL_ = 100;
extern double TP_ = 100;

extern double SLALL = 1;
extern double KhoangCach = 100;
int LotDigits; //initialized in OnInit
int MagicNumber = 1298453;
int NextOpenTradeAfterMinutes = 1; //next open trade after time
int MaxSlippage = 300; //slippage, adjusted in OnInit
bool crossed[4]; //initialized to true, used in function Cross
int MaxOpenTrades = 1000;
int MaxLongTrades = 10;
int MaxShortTrades = 10;
int MaxPendingOrders = 1000;
int MaxLongPendingOrders = 1000;
int MaxShortPendingOrders = 1000;
bool Hedging = true;
int OrderRetry = 5; //# of retries if sending order returns error
int OrderWait = 5; //# of seconds to wait if sending order returns error
double myPoint; //initialized in OnInit

bool Cross(int i, bool condition) //returns true if "condition" is true and was false in the previous call
  {
   bool ret = condition && !crossed[i];
   crossed[i] = condition;
   return(ret);
  }
void CloseTradesAtPL(double PL) //close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
  {
   double totalPL = TotalOpenProfit(0);
   if((PL > 0 && totalPL >= PL) || (PL < 0 && totalPL <= PL))
     {
      myOrderClose(OP_BUY, 100, "");
      myOrderClose(OP_SELL, 100, "");
     }
  }
double TotalOpenProfit(int direction)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)   
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
      result += OrderProfit();
     }
   return(result);
  }
void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | TuyetBot @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

double OpenLot(int direction)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
       if(OrderType() > 1) continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || (OrderType() != OP_BUY && OrderType() != OP_SELL)) continue;
      result += OrderLots();
     }
   return(result);
  }
double LastTradePrice(int direction)
  {
   double result = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderType() > 1) continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         result = OrderOpenPrice();
         break;
        }
     } 
   return(result);
  }

datetime LastOpenTradeTime()
  {
   datetime result = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderType() > 1) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         result = OrderOpenTime();
         break;
        }
     } 
   return(result);
  }

bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     } 
   return(lastOrder >= 0);
  }

datetime LastOpenTime()
  {
   datetime opentime1 = 0, opentime2 = 0;
   if(SelectLastHistoryTrade())
      opentime1 = OrderOpenTime();
   opentime2 = LastOpenTradeTime();
   if (opentime1 > opentime2)
      return opentime1;
   else
      return opentime2;
  }

int myOrderSend(int type, double price, double volume, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   if(!IsTradeAllowed()) return(-1);
   int ticket = -1;
   int retries = 0;
   int err = 0;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   //test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert("print", "Order"+ordername_+" not sent, hedging not allowed");
      return(-1);
     }
   //test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
   || (type % 2 == 1 && short_trades >= MaxShortTrades)
   || (long_trades + short_trades >= MaxOpenTrades)
   || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders)
   || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders)
   || (type > 1 && long_pending + short_pending >= MaxPendingOrders)
   )
     {
      myAlert("print", "Order"+ordername_+" not sent, maximum reached");
      return(-1);
     }
   //prepare to send order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(type == OP_BUY)
      price = Ask;
   else if(type == OP_SELL)
      price = Bid;
   else if(price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
   int clr = (type % 2 == 1) ? clrRed : clrBlue;
   while(ticket < 0 && retries < OrderRetry+1)
     {
      ticket = OrderSend(Symbol(), type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, 0, 0, ordername, MagicNumber, 0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(ticket < 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+Symbol()+" Magic #"+IntegerToString(MagicNumber));
   return(ticket);
  }

int myOrderModify(int ticket, double SL, double TP) //modify SL and TP (absolute price), zero targets do not modify
  {
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = NormalizeDouble(SL, Digits());
   TP = NormalizeDouble(TP, Digits());
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(ticket, NormalizeDouble(OrderOpenPrice(), Digits()), NormalizeDouble(SL, Digits()), NormalizeDouble(TP, Digits()), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+IntegerToString(ticket);
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
   myAlert("modify", alertstr);
   return(0);
  }

int myOrderModifyRel(int ticket, double SL, double TP) //modify SL and TP (relative to open price), zero targets do not modify
  {
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = NormalizeDouble(SL, Digits());
   TP = NormalizeDouble(TP, Digits());
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   //convert relative to absolute
   if(OrderType() % 2 == 0) //buy
     {
      if(NormalizeDouble(SL, Digits()) != 0)
         SL = OrderOpenPrice() - SL;
      if(NormalizeDouble(TP, Digits()) != 0)
         TP = OrderOpenPrice() + TP;
     }
   else //sell
     {
      if(NormalizeDouble(SL, Digits()) != 0)
         SL = OrderOpenPrice() + SL;
      if(NormalizeDouble(TP, Digits()) != 0)
         TP = OrderOpenPrice() - TP;
     }
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(ticket, NormalizeDouble(OrderOpenPrice(), Digits()), NormalizeDouble(SL, Digits()), NormalizeDouble(TP, Digits()), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+IntegerToString(ticket);
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
   myAlert("modify", alertstr);
   return(0);
  }

void myOrderClose(int type, double volumepercent, string ordername) //close open orders for current symbol, magic number and "type" (OP_BUY or OP_SELL)
  {
   if(!IsTradeAllowed()) return;
   if (type > 1)
     {
      myAlert("error", "Invalid type in myOrderClose");
      return;
     }
   bool success = false;
   int retries = 0;
   int err = 0;
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      double price = (type == OP_SELL) ? Ask : Bid;
      double volume = NormalizeDouble(OrderLots()*volumepercent * 1.0 / 100, LotDigits);
      if (NormalizeDouble(volume, LotDigits) == 0) continue;

      success = false; retries = 0;
      while(!success && retries < OrderRetry+1)
        {
         success = OrderClose(OrderTicket(), volume, NormalizeDouble(price, Digits()), MaxSlippage, clrWhite);
         if(!success)
           {
            err = GetLastError();
            myAlert("print", "OrderClose"+ordername_+" failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
            Sleep(OrderWait*1000);
           }
         retries++;
        }
      if(!success)
        {
         myAlert("error", "OrderClose"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
         return;
       }
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   if(success) myAlert("order", "Orders closed"+ordername_+": "+typestr[type]+" "+Symbol()+" Magic #"+IntegerToString(MagicNumber));
  }

void TrailingStopTrail(int type, double TS, double step, bool aboveBE, double aboveBEval) //set Stop Loss to "TS" if price is going your way with "step"
  {
   int total = OrdersTotal();
   TS = NormalizeDouble(TS, Digits());
   step = NormalizeDouble(step, Digits());
   for(int i = total-1; i >= 0; i--)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
	  RefreshRates();
      if(type == OP_BUY && (!aboveBE || Bid > OrderOpenPrice() + TS + aboveBEval) && (NormalizeDouble(OrderStopLoss(), Digits()) <= 0 || Bid > OrderStopLoss() + TS + step))
         myOrderModify(OrderTicket(), Bid - TS, 0);
      else if(type == OP_SELL && (!aboveBE || Ask < OrderOpenPrice() - TS - aboveBEval) && (NormalizeDouble(OrderStopLoss(), Digits()) <= 0 || Ask < OrderStopLoss() - TS - step))
         myOrderModify(OrderTicket(), Ask + TS, 0);
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
      MaxSlippage *= 10;
     }
   //initialize LotDigits
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if(NormalizeDouble(LotStep, 3) == round(LotStep))
      LotDigits = 0;
   else if(NormalizeDouble(10*LotStep, 3) == round(10*LotStep))
      LotDigits = 1;
   else if(NormalizeDouble(100*LotStep, 3) == round(100*LotStep))
      LotDigits = 2;
   else LotDigits = 3;
   Lot = Lot; //initialize to input
   int i;
   //initialize crossed
   for (i = 0; i < ArraySize(crossed); i++)
      crossed[i] = true;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
  
  //--------------
  void CloseSELL() //close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
  {
   
     {
      myOrderClose(OP_BUY, 100, "");
      myOrderClose(OP_SELL, 100, "");
     }
  }
  void CloseBUY() //close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
  {
   
     {
      myOrderClose(OP_BUY, 100, "");
      myOrderClose(OP_SELL, 100, "");
     }
  }
  //--------------------
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int ticket = -1;
   double price;   
   double SL;
   double TP;

   CloseTradesAtPL(SLALL);
   
   
  
   
   //Open Buy Order
   if(SellNenNamTrongEMA
  
 // && Low[1] < iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick Low < Moving Average
  // && High[1] < iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick High > Moving Average
   && Open[0] > Close[0]
   
    //Price crosses above Candlestick High
  && TradesCount(OP_SELL) >=1 //Short Trades is equal to fixed value
  && Bid<LastTradePrice(1) - 1
  && Bid<LastTradePrice(2) - 1
  && Bid<LastTradePrice(3) - 1
  && Bid<LastTradePrice(4) - 1
  && Bid<LastTradePrice(5) - 1
  && Bid<LastTradePrice(6) - 1
  && Bid<LastTradePrice(7) - 1
  && Bid<LastTradePrice(8) - 1
  && Bid<LastTradePrice(9) - 1
  && Bid<LastTradePrice(10) - 1
  && Bid<LastTradePrice(1) + 1
  && Bid<LastTradePrice(2) + 1
  && Bid<LastTradePrice(3) + 1
  && Bid<LastTradePrice(4) + 1
  && Bid<LastTradePrice(5) + 1
  && Bid<LastTradePrice(6) + 1
  && Bid<LastTradePrice(7) + 1
  && Bid<LastTradePrice(8) + 1
  && Bid<LastTradePrice(9) + 1
  && Bid<LastTradePrice(10) + 1
  
   )
     {
      RefreshRates();
      price = Bid;
      
    // myOrderClose(OP_BUY, 100, "");
      SL = SL_ * myPoint; //Stop Loss = value in points (relative to price)
      TP = TP_ * myPoint; //Take Profit = value in points (relative to price)
      if(TimeCurrent() - LastOpenTime() < NextOpenTradeAfterMinutes * 5) return; //next open trade after time after previous trade's open   
      if(IsTradeAllowed())
        {
        
      
         ticket = myOrderSend(OP_SELL, price, Lot, "");
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      myOrderModifyRel(ticket, SL, 0);
      myOrderModifyRel(ticket, 0, TP);
     }
      
   //Open Buy Order
  if(BuyNenNamTrongEMA
  //&& Low[1] > iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick Low < Moving Average
 //&& High[1] > iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick High > Moving Average
   && Open[0] < Close[0]
   && Ask<LastTradePrice(1) + 1
  && Ask<LastTradePrice(2) + 1
  && Ask<LastTradePrice(3) + 1
  && Ask<LastTradePrice(4) + 1
  && Ask<LastTradePrice(5) + 1
  && Ask<LastTradePrice(6) + 1
  && Ask<LastTradePrice(7) + 1
  && Ask<LastTradePrice(8) + 1
  && Ask<LastTradePrice(9) + 1
  && Ask<LastTradePrice(10) + 1
  
  && Ask<LastTradePrice(1) - 1
  && Ask<LastTradePrice(2) - 1
  && Ask<LastTradePrice(3) - 1
  && Ask<LastTradePrice(4) - 1
  && Ask<LastTradePrice(5) - 1
  && Ask<LastTradePrice(6) - 1
  && Ask<LastTradePrice(7) - 1
  && Ask<LastTradePrice(8) - 1
  && Ask<LastTradePrice(9) - 1
  && Ask<LastTradePrice(10) - 1
  
   
    //Price crosses above Candlestick High
  && TradesCount(OP_BUY) >= 1  //Long Trades is equal to fixed value
   )
     {
      RefreshRates();
      price = Ask;
     // myOrderClose(OP_SELL, 100, "");
      
      SL = SL_ * myPoint; //Stop Loss = value in points (relative to price)
      TP = TP_ * myPoint; //Take Profit = value in points (relative to price)
      if(TimeCurrent() - LastOpenTime() < NextOpenTradeAfterMinutes * 5) return; //next open trade after time after previous trade's open   
      if(IsTradeAllowed())
        {
       
      
         ticket = myOrderSend(OP_BUY, price, Lot, "");
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      myOrderModifyRel(ticket, SL, 0);
      myOrderModifyRel(ticket, 0, TP);
     }
     //------------------------------------------------
     
     if(SellNenNamTrongEMA
  
 // && Low[1] < iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick Low < Moving Average
  // && High[1] < iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick High > Moving Average
   && Open[0] > Close[0]
   
    //Price crosses above Candlestick High
  && TradesCount(OP_SELL) == 0 //Short Trades is equal to fixed value
  
  
   )
     {
      RefreshRates();
      price = Bid;
      
    // myOrderClose(OP_BUY, 100, "");
      SL = SL_ * myPoint; //Stop Loss = value in points (relative to price)
      TP = TP_ * myPoint; //Take Profit = value in points (relative to price)
      if(TimeCurrent() - LastOpenTime() < NextOpenTradeAfterMinutes * 5) return; //next open trade after time after previous trade's open   
      if(IsTradeAllowed())
        {
        
      
         ticket = myOrderSend(OP_SELL, price, Lot, "");
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      myOrderModifyRel(ticket, SL, 0);
      myOrderModifyRel(ticket, 0, TP);
     }
      
   //Open Buy Order
  if(BuyNenNamTrongEMA
  //&& Low[1] > iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick Low < Moving Average
 //&& High[1] > iMA(NULL, PERIOD_CURRENT, EMA, 0, MODE_EMA, PRICE_CLOSE, 1) //Candlestick High > Moving Average
   && Open[0] < Close[0]
   
  
   
    //Price crosses above Candlestick High
  && TradesCount(OP_BUY) == 0  //Long Trades is equal to fixed value
   )
     {
      RefreshRates();
      price = Ask;
     // myOrderClose(OP_SELL, 100, "");
      
      SL = SL_ * myPoint; //Stop Loss = value in points (relative to price)
      TP = TP_ * myPoint; //Take Profit = value in points (relative to price)
      if(TimeCurrent() - LastOpenTime() < NextOpenTradeAfterMinutes * 5) return; //next open trade after time after previous trade's open   
      if(IsTradeAllowed())
        {
       
      
         ticket = myOrderSend(OP_BUY, price, Lot, "");
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      myOrderModifyRel(ticket, SL, 0);
      myOrderModifyRel(ticket, 0, TP);
     }
     //------------------------------------------------
    
    
    
    
     
     
     }
     
   //Open Buy Order, instant signal is tested first
 
     //Open Buy Order, instant signal is tested first
  
   //Open Sell Order
   
   
   
   
//+------------------------------------------------------------------+