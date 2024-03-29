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
   EventSetTimer(30); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

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
//|                                                                  |
//+------------------------------------------------------------------+
double get_total_loss()
  {

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

   return loss;
  }
//+------------------------------------------------------------------+
//| Get current server time function                                 |
//+------------------------------------------------------------------+
bool isDailyLimit()
  {
   double DAILY_LOSS_LIMIT = 2500;
   double total_loss = get_total_loss();


// Return result
   bool result = total_loss > DAILY_LOSS_LIMIT;
   if(result)
     {
      //Alert("Stop trading today! total_loss="+ (string)total_loss);


      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong positionTicket = PositionGetTicket(i);
         double profit = PositionGetDouble(POSITION_PROFIT);
         string _symbol = PositionGetString(POSITION_SYMBOL);
         if(profit > 200)
           {
            Alert("Close Position: " + (string)positionTicket + " : " + _symbol + " Profit: " + (string) profit);
            m_trade.PositionClose(positionTicket);
           }
        }


      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong orderTicket = OrderGetTicket(i);
         string order_symbol = OrderGetString(ORDER_SYMBOL);
         Alert(" Close Order: " + (string)orderTicket + " : " + order_symbol);
         m_trade.OrderDelete(orderTicket);
        }

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
            //Comment("-----------------------------GuardianAngel: (OrderDelete)" + (string) orderTicket +  " Symbol: " + OrderGetString(ORDER_SYMBOL));
           }
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong positionTicket = PositionGetTicket(i);

      if(positionTicket == ticket)
        {
         m_trade.PositionClose(positionTicket);
         //Comment("-----------------------------GuardianAngel: (PositionClose)" + (string) positionTicket +  " Symbol: " + PositionGetString(POSITION_SYMBOL));
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_order()
  {
//   string opening = "__";
//   for(int i = PositionsTotal()-1; i >= 0; i--)
//     {
//      if(m_position.SelectByIndex(i))
//        {
//         opening += toLower(m_position.Symbol()) + "; ";
//        }
//     }
//
////Alert("GuardianAngel: opening(OrderDelete)" + (string) opening);
//
//   for(int i = OrdersTotal() - 1; i >= 0; i--)
//     {
//      if(m_order.Select(i))
//        {
//         string order_symbol = toLower(m_order.Symbol());
//         if(StringFind(opening, order_symbol) >= 0)
//           {
//            //m_trade.OrderDelete(orderTicket);
//            Alert("GuardianAngel: toLower(OrderDelete)" + (string) m_order.Ticket() +  " Symbol: " + order_symbol, " Opening: ", opening);
//           }
//        }
//     }
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
string openTrade(string line)
  {
   bool exit = true;
   if(exit)
     {
      // return;
     }


// Alert("openTrade: " + line);
   string result[];
   int k=StringSplit(line,'\t',result);
//Alert((string) k);


   if(k != 12)
     {
      return "";
     }

   string str_result = "";

   string cash = toLower("US30.cash_US100.cash_EU50.cash_GER40.cash_FRA40.cash_SPN35.cash_UK100.cash_USOIL.cash_AUS200.cash");

   string epic = toLower(result[0]);
   string type = toLower(result[1]);
   double volume = StringToDouble(result[2]);
   double entry1 = StringToDouble(result[3]);
   double stop_loss = StringToDouble(result[4]);
   double take_prifit_1 = StringToDouble(result[5]);
   string comment = result[6];
   double entry_2 = StringToDouble(result[7]);
   double take_prifit_2 = StringToDouble(result[8]);
   double entry_3 = StringToDouble(result[9]);
   double take_prifit_3 = StringToDouble(result[10]);
   int total_trade = (int)StringToInteger(result[11]);
//Alert("total_trade", (string) total_trade);

   string trade_symbol = result[0];
   string lowcase_symbol = epic;
   if(StringFind(cash, epic, 0) >= 0)
     {
      lowcase_symbol = epic + ".cash";
      trade_symbol = trade_symbol + ".cash";
     }


   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong orderTicket = OrderGetTicket(i);

      string order_symbol = OrderGetString(ORDER_SYMBOL);
      order_symbol = toLower(order_symbol);

      if(lowcase_symbol == order_symbol)
        {
         // Alert(type + " order_symbol: " + order_symbol + " lowcase_symbol:" + lowcase_symbol);
         count = count + 1;
        }
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trading_symbol = PositionGetSymbol(i);
      trading_symbol = toLower(trading_symbol);

      if(lowcase_symbol == trading_symbol)
        {
         // Alert(type + " order_symbol: " + order_symbol + " lowcase_symbol:" + lowcase_symbol);
         count = count + 1;
        }
     }


   bool allow_append_trade = false;
   if(count < total_trade)
     {
      allow_append_trade = true;
     }

   if(count > 1)
     {
      allow_append_trade = false;
     }

   if(allow_append_trade)
     {
      double LOSS_LIMIT = 2500;
      double total_loss = get_total_loss();
      if(total_loss > LOSS_LIMIT)
        {
         allow_append_trade = false;
        }
     }

   if(allow_append_trade && (1 <= total_trade) && (total_trade <= 2))
     {
      //Alert(type + " " + trade_symbol + " ADDED ORDER.");
      int    digits = (int)SymbolInfoInteger(trade_symbol,SYMBOL_DIGITS);     // number of decimal places
      double point  = SymbolInfoDouble(trade_symbol,SYMBOL_POINT);            // point

      stop_loss        = NormalizeDouble(stop_loss, digits);

      entry1           = NormalizeDouble(entry1, digits);
      take_prifit_1    = NormalizeDouble(take_prifit_1, digits);

      entry_2          = NormalizeDouble(entry_2, digits);
      take_prifit_2    = NormalizeDouble(take_prifit_2, digits);

      entry_3          = NormalizeDouble(entry_3, digits);
      take_prifit_3    = NormalizeDouble(take_prifit_3, digits);

      datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_D1);

      double price = SymbolInfoDouble(trade_symbol, SYMBOL_BID);

      double upper_h1_20_1[], middle_h1_20_1[], lower_h1_20_1[];
      CalculateBollingerBands(trade_symbol, PERIOD_H1, upper_h1_20_1, middle_h1_20_1, lower_h1_20_1, digits, 1);

      double hi_h1_20_1 = upper_h1_20_1[0];
      double mi_h1_20_0 = middle_h1_20_1[0];
      double lo_h1_20_1 = lower_h1_20_1[0];
      double amp = MathAbs(hi_h1_20_1 - mi_h1_20_0);

      double hi_h1_20_2 = hi_h1_20_1 + amp;
      double hi_h1_20_3 = hi_h1_20_2 + amp;

      double lo_h1_20_2 = lo_h1_20_1 - amp;
      double lo_h1_20_3 = lo_h1_20_2 - amp;

      bool cond_buy = false;
      if(type == "buy")
        {
         str_result += "Waiting(B): " + trade_symbol + "\n";
         if(price < lo_h1_20_1)
           {
            cond_buy = true;
           }
        }

      bool cond_sel = false;
      if(type == "sell")
        {
         str_result += "Waiting(S): " + trade_symbol + "\n";
         if(price > hi_h1_20_1)
           {
            cond_sel = true;
           }
        }



      if(cond_buy)
        {
         //if(!m_trade.PositionOpen(trade_symbol, ORDER_TYPE_BUY, volume, entry1, stop_loss, take_prifit_1, comment))
         //   Alert("Duydk: BUY: ", trade_symbol, " ERROR:", m_trade.ResultRetcodeDescription());
         //if((entry_2 > 0) && (take_prifit_2 > 0))
         //   m_trade.BuyLimit(volume, entry_2, trade_symbol, 0.0, take_prifit_2, 0, 0, "BUY_2");

         m_trade.Buy(volume, trade_symbol, 0.0, 0.0, hi_h1_20_1, comment + "_b1");
         m_trade.BuyLimit(volume, NormalizeDouble(lo_h1_20_2, digits), trade_symbol, 0.0, NormalizeDouble(mi_h1_20_0, digits), 0, 0, comment + "_b2");
         m_trade.BuyLimit(volume, NormalizeDouble(lo_h1_20_3, digits), trade_symbol, 0.0, NormalizeDouble(lo_h1_20_1, digits), 0, 0, comment + "_b3");

         Alert(TimeCurrent(), BOT_NAME, "  BUY: ", trade_symbol, "   price: ", price, "    tp1(hi_h1_20_1): ", hi_h1_20_1, "    vol:", volume);
         str_result = "";
        }

      if(cond_sel)
        {
         //         Alert(TimeCurrent(), "  SELL: ", trade_symbol, " vol:", volume);
         //         if(!m_trade.PositionOpen(trade_symbol, ORDER_TYPE_SELL, volume, entry1, stop_loss, take_prifit_1, comment))
         //            Alert("Duydk: SELL: ", trade_symbol, " ERROR:", m_trade.ResultRetcodeDescription());
         //         if((entry_2 > 0) && (take_prifit_2 > 0))
         //            m_trade.SellLimit(volume, entry_2, trade_symbol, 0.0, take_prifit_2, 0, 0, "SELL_2");

         m_trade.Sell(volume, trade_symbol, 0.0, 0.0, lo_h1_20_1, comment + "_s1");
         m_trade.SellLimit(volume, NormalizeDouble(hi_h1_20_2, digits), trade_symbol, 0.0, NormalizeDouble(mi_h1_20_0, digits), 0, 0, comment + "_s2");
         m_trade.SellLimit(volume, NormalizeDouble(hi_h1_20_3, digits), trade_symbol, 0.0, NormalizeDouble(lo_h1_20_1, digits), 0, 0, comment + "_s3");

         Alert(TimeCurrent(), BOT_NAME, " SELL: ", trade_symbol, "   price: ", price, "    tp1(lo_h1_20_1): ", lo_h1_20_1, "    vol:", volume);
         str_result = "";
        }

      // -----------------------------------------------------------------

      //if(type == "buy_limit")
      //  {
      //   if((entry_2 > 0) && (take_prifit_2 > 0))
      //      m_trade.BuyLimit(volume, entry_2, trade_symbol, 0.0, take_prifit_2, 0, 0, comment);
      //  }
      //if(type== "sell_limit")
      //  {
      //   if((entry_2 > 0) && (take_prifit_2 > 0))
      //      m_trade.SellLimit(volume, entry_2, trade_symbol, 0.0, take_prifit_2, 0, 0, comment);
      //  }

     }

   return str_result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trailingSL(string line)
  {
// Alert("trailingSL: " + line);
   string result[];
   int k=StringSplit(line,'\t',result);
   if(k != 3)
     {
      return ;
     }

   ulong  my_ticket = (ulong)(result[0]);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string trade_symbol = PositionGetSymbol(i);
      int    digits = (int)SymbolInfoInteger(trade_symbol,SYMBOL_DIGITS);     // number of decimal places

      ulong  cur_ticket = PositionGetTicket(i);

      // Alert("TrailingSL: my_ticket=" + (string)my_ticket + "  cur_ticket=" + (string)cur_ticket + " cur_sl=" + (string)cur_sl + " cur_tp=" + (string)cur_tp);

      if(my_ticket == cur_ticket)
        {
         double my_sl     = NormalizeDouble(StringToDouble(result[1]),digits);
         double my_tp     = NormalizeDouble(StringToDouble(result[2]),digits);

         double cur_sl    = NormalizeDouble(PositionGetDouble(POSITION_SL),digits);   // Stop Loss of the position
         double cur_tp    = NormalizeDouble(PositionGetDouble(POSITION_TP),digits);   // Take Profit of the position

         string my_key    = (string)cur_ticket + "_" + (string)my_sl  + "_" + (string)my_tp;
         string cur_key   = (string)cur_ticket + "_" + (string)cur_sl + "_" + (string)cur_tp;

         if(my_key != cur_key)
           {
            // Alert("TrailingSL: ticket=" + (string)my_ticket + "   " + trade_symbol + " SL:" + (string)cur_sl + "->" + (string)my_sl + "    TP:" + (string)cur_tp + "->" + (string)my_tp);

            m_trade.PositionModify(my_ticket, my_sl, my_tp);


            //Comment("----------------------------- TrailingSL: ticket=" + (string)my_ticket + "   " + trade_symbol + " SL:" + (string)cur_sl + "->" + (string)my_sl + "    TP:" + (string)cur_tp);
           }

         break;
        }
     }
  }


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   close_order();
//------------------------------------------------------------
   int n_trailing_sl_file_handle = FileOpen("Data//TrailingStoploss.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\n', CP_UTF8);
   if(n_trailing_sl_file_handle != INVALID_HANDLE)
     {
      for(int Count=0; Count<99; Count++)
        {
         if(FileIsEnding(n_trailing_sl_file_handle))
            break;

         string DataItem = FileReadString(n_trailing_sl_file_handle,0);
         trailingSL(DataItem);
        }

      FileClose(n_trailing_sl_file_handle);
     }
   else
     {
      // Alert("n_trailing_sl_file_handle Error " + (string) GetLastError());
     }
//------------------------------------------------------------
   double Loss_In_Money = -300;     // loss in money $
   double Profit_In_Money = 10000;  // profit in money $

   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
     {
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         double profit = m_position.Commission() + m_position.Swap() + m_position.Profit();
         //-------------------------------------------------
         if(profit < Loss_In_Money)
           {
            m_trade.PositionClose(m_position.Ticket());
            Alert(TimeCurrent(), "  PositionClose: " + m_position.Symbol(), "    Loss_In_Money="+ (string)profit);
           }
         //-------------------------------------------------
         if(profit > Profit_In_Money)
           {
            m_trade.PositionClose(m_position.Ticket());
            Alert(TimeCurrent(), "  PositionClose: " + m_position.Symbol(), "    Profit_In_Money="+ (string)profit);
           }
        }
     }
//------------------------------------------------------------
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
      // Alert("Loss more than 2000$. Stop trading today!");
     }
//------------------------------------------------------------
   string comments = "";
   int n_open_trade_file_handle = FileOpen("Data//OpenTrade.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\n', CP_UTF8);
   if(n_open_trade_file_handle != INVALID_HANDLE)
     {
      for(int Count=0; Count<99; Count++)
        {
         if(FileIsEnding(n_open_trade_file_handle))
            break;

         string DataItem = FileReadString(n_open_trade_file_handle,0);
         comments += openTrade(DataItem);
        }

      FileClose(n_open_trade_file_handle);
     }
   else
     {
      // Alert("n_open_trade_file_handle Error " + (string) GetLastError());
     }

   if(comments.Length()>0)
     {
      Comment("\n" + BOT_NAME + "\n" + comments + "\n");
     }
  }
//+------------------------------------------------------------------+
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

// Hàm tính toán Bollinger Bands
// double deviation = 2; // Độ lệch chuẩn cho Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits, double deviation = 2)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
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

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

