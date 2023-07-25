//+------------------------------------------------------------------+
//|                                                GuardianAngel.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>

CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
string input aa = "------------------SETTINGS----------------------";
string input BOT_NAME = "GuardianAngel";
int input    EXPERT_MAGIC = 2023869;
double input PASS_CRITERIA = 220000.;

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   m_trade.SetExpertMagicNumber(EXPERT_MAGIC);
   printf(BOT_NAME + " initialized!");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   printf(BOT_NAME + " exited, exit code: %d", reason);
  }

//+------------------------------------------------------------------+
//| Clear all positions and orders                                   |
//+------------------------------------------------------------------+
void ClearAll()
  {
   Print("Clear all orders and positions");
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);
      if(OrderSelect(orderTicket))
        {
         m_trade.OrderDelete(orderTicket);
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      m_trade.PositionClose(posTicket);
     }
  }

//+------------------------------------------------------------------+
//| Get current server time function                                 |
//+------------------------------------------------------------------+
bool isDailyLimit()
  {
   double DAILY_LOSS_LIMIT = 2000;

   MqlDateTime date_time;
   TimeToStruct(TimeCurrent(), date_time);
   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;

// Current balance
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);

// today closed trades PL
   HistorySelect(0, TimeCurrent());
   int orders = HistoryDealsTotal();

   double PL = 0.0;
   for(int i = orders - 1; i >= 0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         Print("ERROR: no trade history");
         break;
        }

      double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
      if(profit != 0)  // If deal is trade exit with profit or loss
        {
         // Get deal datetime
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

// Get today starting balance
   double starting_balance = current_balance - PL;

// Get current equity
   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);

   double loss = starting_balance - current_equity;

// Return result
   bool result = current_equity < starting_balance - DAILY_LOSS_LIMIT;
   if(result)
     {
      Alert("Daily loss limited! current_equity=" + (string) current_equity + " starting_balance=" + (string)starting_balance + " loss="+ (string)loss);
     }

   return result;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Success()
  {
   return AccountInfoDouble(ACCOUNT_EQUITY) > PASS_CRITERIA;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeSymbol(ulong ticket)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);
      if(ticket == orderTicket)
        {
         if(OrderSelect(orderTicket))
           {
            m_trade.OrderDelete(orderTicket);
            Comment("-----------------------------GuardianAngel: (OrderDelete)" + (string) orderTicket +  " Symbol: " + OrderGetString(ORDER_SYMBOL));
           }
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong positionTicket = PositionGetTicket(i);

      if(positionTicket == ticket)
        {
         m_trade.PositionClose(positionTicket);
         Comment("-----------------------------GuardianAngel: (PositionClose)" + (string) positionTicket +  " Symbol: " + PositionGetString(POSITION_SYMBOL));
        }
     }
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int n_close_trade_file_handle = FileOpen("Data//CloseSymbols.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);
   if(n_close_trade_file_handle != INVALID_HANDLE)
     {
      for(int Count=0; Count<99; Count++)
        {
         if(FileIsEnding(n_close_trade_file_handle))
            break;

         ulong ticket = (ulong)FileReadString(n_close_trade_file_handle,0);
         closeSymbol(ticket);
        }

      FileClose(n_close_trade_file_handle);
     }
   else
     {
      // Alert("n_close_trade_file_handle Error " + (string) GetLastError());
     }
//------------------------------------------------------------
   if(isDailyLimit())
     {
      Alert("Loss more than 2000$. Stop trading today!");
     }


//---
   double Loss_In_Money = -200;     // loss in money $
   double Profit_In_Money = 500;    // profit in money $

   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
     {
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         double profit = m_position.Commission() + m_position.Swap() + m_position.Profit();

         if(profit < Loss_In_Money)
           {
            m_trade.PositionClose(m_position.Ticket());
            Alert("PositionClose=" + (string) m_position.Ticket() + " Loss_In_Money="+ (string)profit);
           }

         if(profit > Profit_In_Money)
           {
            m_trade.PositionClose(m_position.Ticket());
            Alert("PositionClose=" + (string) m_position.Ticket() + " Profit_In_Money="+ (string)profit);
           }

        }
     }


//+------------------------------------------------------------------+
  }
//+------------------------------------------------------------------+
