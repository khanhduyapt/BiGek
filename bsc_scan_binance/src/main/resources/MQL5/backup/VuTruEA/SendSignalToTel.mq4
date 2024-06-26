//+------------------------------------------------------------------+
//|                                              SendSignalToTel.mq4 |
//|                                             Copyright 2021, annt |
//|                                                 anbk08@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, annt"
#property link      "anbk08@gmail.com"
#property version   "1.00"
#property strict
#include <Telegram\Telegram.mqh>

//--- input parameters
string InpChannelName="";//Channel Name
string InpChatId="";
string InpToken="";//Token

//--- global variables
CCustomBot bot;
bool checked;
datetime _opened_last_time = TimeCurrent();
datetime _closed_last_time = TimeCurrent();

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   bot.Token(InpToken);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(reason==REASON_PARAMETERS ||
         reason==REASON_RECOMPILE ||
         reason==REASON_ACCOUNT)
   {
      checked=false;
   }

  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!checked)
   {
      if(StringLen(InpChannelName)==0)
      {
         Print("Error: Channel name is empty");
         Sleep(10000);
         return;
      }

      int result=bot.GetMe();
      if(result==0)
      {
         Print("Bot name: ",bot.Name());
         checked=true;
      }
      else
      {
         Print("Error: ",GetErrorDescription(result));
         Sleep(10000);
         return;
      }
   }
   
   int total = OrdersTotal();
   datetime max_time = 0;
   double day_profit = 0;   

// Gui tin nhan toi lenh OPEN
   for(int pos=0;pos<total;pos++)
     {  // Current orders -----------------------
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderOpenTime() <= _opened_last_time) continue;
      string msg = StringFormat
       (
         "Time (GTM+0): %s\nOPEN %s %s lots \n%s @ %s\nTakeProfit: %s\nStopLoss: %s\n",
            TimeToString(OrderOpenTime(),TIME_DATE|TIME_SECONDS),
            order_type(),
            DoubleToStr(OrderLots(),2),
            OrderSymbol(),
            DoubleToStr(OrderOpenPrice(),MarketInfo(Symbol(),MODE_DIGITS)),        
            DoubleToStr(OrderTakeProfit(),MarketInfo(Symbol(),MODE_DIGITS)),
            DoubleToStr(OrderStopLoss(),MarketInfo(Symbol(),MODE_DIGITS))
         );
       int res=bot.SendMessage(InpChannelName,msg);
       if(res!=0)
          Print("Error: ",GetErrorDescription(res));

       max_time = MathMax(max_time,OrderOpenTime());
     }

   _opened_last_time = MathMax(max_time,_opened_last_time);

// gui tin nhan Gain/ Lost và Total profit   
   max_time = 0;
   bool is_closed = false;
   total = OrdersHistoryTotal();
   for(int pos=0;pos<total;pos++)
     {  // Total Profit orders----------------------- 
      if( TimeDay(TimeCurrent()) == TimeDay(OrderCloseTime()) ) 
        {
         day_profit += OrderProfit();
        }     
     // History  orders -----------------------
      if(OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY)==false) continue;
      if(OrderCloseTime() <= _closed_last_time) continue;
      is_closed = true;
      string msg = StringFormat
       (
         "Time (GTM+0): %s\nCLOSE %s %s lots %s\nOpen Price: %s\nClose Price: %s\nGain/Lost: %s USD\n---TOTAL PROFIT TODAY---\n   %s USD\n",
            TimeToString(OrderCloseTime(),TIME_DATE|TIME_SECONDS),
            order_type(),
            DoubleToStr(OrderLots(),2),
            OrderSymbol(),
            DoubleToStr(OrderOpenPrice(),MarketInfo(Symbol(),MODE_DIGITS)),        
            DoubleToStr(OrderClosePrice(),MarketInfo(Symbol(),MODE_DIGITS)),
            DoubleToStr(OrderProfit(),MarketInfo(Symbol(),MODE_DIGITS)),
            DoubleToStr(day_profit,2)
         );
      int res=bot.SendMessage(InpChannelName,msg);
      if(res!=0)
          Print("Error: ",GetErrorDescription(res));   
      max_time = MathMax(max_time,OrderCloseTime());
     } 
  _closed_last_time = MathMax(max_time,_closed_last_time);  
  
  
  }
//+------------------------------------------------------------------+
string order_type ()
   {
   
   if(OrderType() == OP_BUY)        return "BUY";
   if(OrderType() == OP_SELL)       return "SELL";
   if(OrderType() == OP_BUYLIMIT)   return "BUYLIMIT";
   if(OrderType() == OP_SELLLIMIT)  return "SELLLIMIT";
   if(OrderType() == OP_BUYSTOP)    return "BUYSTOP";
   if(OrderType() == OP_SELLSTOP)   return "SELLSTOP";
   
   return "";
   }