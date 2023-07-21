//+------------------------------------------------------------------+
//|                                          MaxiProfitGuardians.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

CPositionInfo  m_position;
COrderInfo     m_order;

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
string input aa = "------------------SETTINGS----------------------";
string input BOT_NAME = "MaxiProfitGuardians";
int input    EXPERT_MAGIC = 250286;
double input PASS_CRITERIA = 105100.;


//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(120); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   trade.SetExpertMagicNumber(EXPERT_MAGIC);
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
         trade.OrderDelete(orderTicket);
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      trade.PositionClose(posTicket);
     }
  }

//+------------------------------------------------------------------+
//| Get current server time function                                 |
//+------------------------------------------------------------------+
bool isDailyLimit()
  {
   double DAILY_LOSS_LIMIT = 3000;

   MqlDateTime date_time;
   TimeToStruct(TimeCurrent(), date_time);
   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;

// Current balance
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);

// Get today's closed trades PL
   HistorySelect(0, TimeCurrent());
   int orders = HistoryDealsTotal();

   double PL = 0.0;
   for(int i = orders - 1; i >= 0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         Print("HistoryDealGetTicket failed, no trade history");
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
      Alert("daily loss limited! current_equity=" + (string) current_equity + " starting_balance=" + (string)starting_balance + " loss="+ (string)loss);
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// isDailyLimit();
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
            trade.OrderDelete(orderTicket);
            // Alert("OrderDelete " + (string) orderTicket +  " Symbol: " + OrderGetString(ORDER_SYMBOL));
           }
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong positionTicket = PositionGetTicket(i);

      if(positionTicket == ticket)
        {
         trade.PositionClose(positionTicket);
         // Alert("PositionClose " + (string) positionTicket +  " Symbol: " + PositionGetString(POSITION_SYMBOL));
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
//|//String EPIC, String ORDER_TYPE, BigDecimal lots, BigDecimal entry, BigDecimal stop_loss
//+------------------------------------------------------------------+
void openTrade(string line)
  {
   bool exit = true;
   if(exit)
     {
      // return;
     }


// Alert("openTrade: " + line);
   string result[];
   int k=StringSplit(line,'\t',result);
   if(k != 7)
     {
      return ;
     }

   string cash = toLower("US30.cash_US100.cash_EU50.cash_GER40.cash_FRA40.cash_SPN35.cash_UK100.cash_USOIL.cash_AUS200.cash");

   string epic = toLower(result[0]);
   string type = toLower(result[1]);
   double volume = StringToDouble(result[2]);
   double price = StringToDouble(result[3]);
   double stop_loss = StringToDouble(result[4]);
   double tp = StringToDouble(result[5]);
   string comment = result[6];

   string trade_symbol = result[0];
   string lowcase_symbol = epic;
   if(StringFind(cash, epic, 0) >= 0)
     {
      lowcase_symbol = epic + ".cash";
      trade_symbol = trade_symbol + ".cash";
     }

   /*
      Alert("lowcase_symbol: " + lowcase_symbol);
      Alert("EPIC: " + epic);
      Alert("ORDER_TYPE: " + result[1]);
      Alert("lots: " + result[2]);
      Alert("entry: " + result[3]);
      Alert("stop_loss: " + result[4]);
   */

   bool not_found = true;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      if(lowcase_symbol == order_symbol)
        {
         // Alert(type + " order_symbol: " + order_symbol + " lowcase_symbol:" + lowcase_symbol);
         not_found = false;
         break;
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         // Alert(type + " order_symbol: " + order_symbol + " lowcase_symbol:" + lowcase_symbol);
         not_found = false;
         break;
        }
     }

   if(not_found == false)
     {
      // Alert(type + " " + trade_symbol + " REALLY EXIST.");
     }



   if(not_found)
     {
      // Alert(type + " " + trade_symbol + " ADDED ORDER.");
      int    digits=(int)SymbolInfoInteger(trade_symbol,SYMBOL_DIGITS);    // number of decimal places
      double point=SymbolInfoDouble(trade_symbol,SYMBOL_POINT);            // point

      price=NormalizeDouble(price,digits);                                 // normalizing open price
      stop_loss=NormalizeDouble(stop_loss, digits);                        // normalizing Stop Loss
      tp=NormalizeDouble(tp, digits);                                      // normalizing TP
      // tp=0.0;
      // stop_loss=0.0;
      datetime expiration=TimeTradeServer()+PeriodSeconds(PERIOD_D1);



      if(type== "buy")
        {
         //--- open position
         if(!trade.PositionOpen(trade_symbol, ORDER_TYPE_BUY, volume, price, stop_loss, tp, comment))
            Alert("Duydk: BUY: ", trade_symbol, " ERROR:", trade.ResultRetcodeDescription());
            // trade.PositionOpen(trade_symbol, ORDER_TYPE_BUY, volume, price, 0.0, 0.0, comment);
        }

      if(type== "buy_limit")
        {
         if(!trade.BuyLimit(volume, price, trade_symbol, 0.0, 0.0, ORDER_TIME_GTC, expiration, comment))
            Alert("Duydk: BUY LIMIT: ", trade_symbol, " ERROR:", trade.ResultRetcodeDescription());
        }

      if(type== "sell")
        {
         //--- open position
         if(!trade.PositionOpen(trade_symbol, ORDER_TYPE_SELL, volume, price, stop_loss, tp, comment))
            Alert("Duydk: SELL: ", trade_symbol, " ERROR:", trade.ResultRetcodeDescription());
            // trade.PositionOpen(trade_symbol, ORDER_TYPE_SELL, volume, price, 0.0, 0.0, comment);
        }

      if(type== "sell_limit")
        {
         if(!trade.SellLimit(volume, price, trade_symbol, 0.0, 0.0, ORDER_TIME_GTC, expiration, comment))
            Alert("Duydk: SELL LIMIT: ", trade_symbol, " ERROR:", trade.ResultRetcodeDescription());
        }

     }

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Comment("-----------------------------FTMOSafeGuard: (Forex)" + (string)TimeLocal() + " (Symbol):"+ Symbol());

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
   int n_open_trade_file_handle = FileOpen("Data//OpenTrade.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\n', CP_UTF8);
   if(n_open_trade_file_handle != INVALID_HANDLE)
     {
      for(int Count=0; Count<99; Count++)
        {
         if(FileIsEnding(n_open_trade_file_handle))
            break;

         string DataItem = FileReadString(n_open_trade_file_handle,0);
         openTrade(DataItem);
        }

      FileClose(n_open_trade_file_handle);
     }
   else
     {
      // Alert("n_open_trade_file_handle Error " + (string) GetLastError());
     }
//------------------------------------------------------------
   if(Success())
     {
      ClearAll();
      Alert("Congratulations!. You have passed the FTMO Challenge!");
     }
   if(isDailyLimit())
     {
      ClearAll();
      Alert("Your daily loss limit have been exceeded. Stop trading today!");
     }
  }
//+------------------------------------------------------------------+