//+------------------------------------------------------------------+
//|                                                    TradeList.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

CPositionInfo  m_position;
COrderInfo     m_order;

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

//+------------------------------------------------------------------+
//| TradeList
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTimer();

   EventSetTimer(120); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   return(INIT_SUCCEEDED);
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
// Calculate Positions and Pending Orders.mq5
// https://www.mql5.com/en/forum/378868                                                |
//+------------------------------------------------------------------+
void OnTimer()
  {
   get_history_today();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_history_today()
  {
   string filename = "History.log";
   FileDelete(filename);
   int nfile_history = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_history != INVALID_HANDLE)
     {
      FileWrite(nfile_history, AppendSpaces("deal_time", 10), AppendSpaces("symbol"), AppendSpaces("profit"), AppendSpaces("type"), AppendSpaces("ticket"), AppendSpaces("volume"), AppendSpaces("price"), AppendSpaces("status"), AppendSpaces("comment"));

      MqlDateTime date_time;
      TimeToStruct(TimeCurrent(), date_time);
      int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;
      int row_count = 0;
      // --------------------------------------------------------------------
      string pre_symbol = "";
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = toLower(arr_symbol[index]);
         int count_trade = 0;

         for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
           {
            // selects the position by index for further access to its properties
            if(m_position.SelectByIndex(i))
              {
               if(symbol == toLower(m_position.Symbol()))
                 {
                  count_trade += 1;
                  datetime deal_time   = m_position.Time();
                  ulong ticket         = m_position.Ticket();
                  string symbol        = m_position.Symbol();
                  double profit        = m_position.Commission() + m_position.Swap() + m_position.Profit();
                  string type          = m_position.TypeDescription();
                  double volume        = m_position.Volume();
                  double price         = m_position.PriceOpen();
                  int    digits        = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

                  StringToUpper(type);
                  StringReplace(symbol, ".cash", "");

                  string status = AppendSpaces("OPENING");
                  row_count += 1;
                  string comment = AppendSpaces((string)row_count) + "   https://www.tradingview.com/chart/r46Q5U5a/?symbol=" + symbol;

                  MqlDateTime struct_open_time;
                  TimeToStruct(TimeCurrent(), struct_open_time);

                  FileWrite(nfile_history
                            , AppendSpaces(count_trade) //date_time_to_string(struct_open_time)
                            , AppendSpaces(symbol)
                            , AppendSpaces(format_double_to_string(profit, 2))
                            , AppendSpaces(type)
                            , AppendSpaces((string)ticket)
                            , AppendSpaces(format_double_to_string(volume, digits))
                            , AppendSpaces(format_double_to_string(price, digits))
                            , AppendSpaces(status)
                            , AppendSpaces((string)comment));
                 }
              }
           }

         if(count_trade > 1)
            FileWrite(nfile_history, "");

        }
      // --------------------------------------------------------------------
      FileWrite(nfile_history, "");

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
            Print("ERROR: no trade history");
            break;
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

               string symbol  = HistoryDealGetString(ticket,   DEAL_SYMBOL);
               double volume  = HistoryDealGetDouble(ticket,   DEAL_VOLUME);
               double price   = HistoryDealGetDouble(ticket,   DEAL_PRICE);
               long deal_type  = HistoryDealGetInteger(ticket,  DEAL_TYPE);
               int digits     = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

               StringReplace(symbol, ".cash", "");

               string type = (string) deal_type;
               if(deal_type == 1)
                  type = "BUY";
               if(deal_type == 0)
                  type = "SELL";

               string status = AppendSpaces("CLOSED");
               row_count += 1;
               string comment = AppendSpaces((string)row_count) + "   https://www.tradingview.com/chart/r46Q5U5a/?symbol=" + symbol;


               FileWrite(nfile_history
                         , AppendSpaces(date_time_to_string(deal_time))
                         , AppendSpaces(symbol)
                         , AppendSpaces(format_double_to_string(profit, 2))
                         , AppendSpaces((string)type)
                         , AppendSpaces((string)ticket)
                         , AppendSpaces((string)volume)
                         , AppendSpaces(format_double_to_string(price, digits))
                         , AppendSpaces(status)
                         , AppendSpaces((string)comment));

              }
            else
               break;
           }
        }


      FileWrite(nfile_history, "");


      double starting_balance = current_balance - PL;
      double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
      double loss = current_equity - starting_balance;
      double swap = 0.0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(m_position.SelectByIndex(i))
           {
            swap += m_position.Swap();
           }
        } //for

      FileWrite(nfile_history, "CLOSED  : " + (string)format_double(PL, 5));
      FileWrite(nfile_history, "SWAP    : " + (string)format_double(swap, 5));
      FileWrite(nfile_history, "OPENING : " + (string)format_double(OpenPositionsProfit(), 5));
      FileWrite(nfile_history, "TOTAL   : " + (string)format_double(loss, 5));
      //--------------------------------------------------------------------------------------------------------------------

      FileClose(nfile_history);
     }
   else
     {
      //Print("(HistoryToday) Failed to get history data.");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trade_opening()
  {
   FileDelete("Trade.csv");
   int nfile_handle = FileOpen("Trade.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "Symbol", "Ticket", "TypeDescription", "PriceOpen",  "StopLoss", "TakeProfit",  "Profit",  "Comment", "Volume", "CurrPrice", "OpenTime", "CurrServerTime");

      int count_buys = 0;
      int count_sells = 0;
      for(int i=PositionsTotal()-1; i>=0; i--)
        {
         if(m_position.SelectByIndex(i))
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }

         FileWrite(nfile_handle
                   , m_position.Symbol()
                   , m_position.Ticket()
                   , m_position.TypeDescription()
                   , m_position.PriceOpen()
                   , m_position.StopLoss()
                   , m_position.TakeProfit()
                   , m_position.Profit()
                   , " " + m_position.Comment()
                   , m_position.Volume()
                   , m_position.PriceCurrent()
                   , m_position.Time()
                   , TimeCurrent());
        }


      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if(m_order.SelectByIndex(i))
           {
            FileWrite(nfile_handle
                      , m_order.Symbol()
                      , m_order.Ticket()
                      , m_order.TypeDescription()
                      , m_order.PriceOpen()
                      , m_order.StopLoss()
                      , m_order.TakeProfit()
                      , 0.0
                      , " " + m_order.Comment()
                      , m_order.VolumeCurrent()
                      , m_order.PriceCurrent()
                      , TimeCurrent()
                      , TimeCurrent());
           }
        }
      //--------------------------------------------------------------------------------------------------------------------
      FileClose(nfile_handle);
     }
   else
     {
      //Print("(Data2Csv) Failed to get history data.");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OpenPositionsProfit()
  {
   double allProfit = 0;
   if(PositionsTotal() > 0)
      for(int i = 0; i < PositionsTotal(); i++)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
            allProfit += PositionGetDouble(POSITION_PROFIT);
        }
   return allProfit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string date_time_to_string(const MqlDateTime &deal_time)
  {
   string result = (string)deal_time.year ;
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

//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   string formattedNumber = DoubleToString(number, 5);
   StringReplace(formattedNumber, "00000000001", "");
   StringReplace(formattedNumber, "99999999999", "");

   return NormalizeDouble(StringToDouble(formattedNumber), digits);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
string AppendSpaces(string inputString, int totalLength = 10)
  {

   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
     {
      return (inputString);
     }
   else
     {
      int spacesToAdd = totalLength - currentLength;
      string spaces = "";
      for(int index = 1; index <= spacesToAdd; index++)
        {
         spaces+= " ";
        }

      return (spaces + inputString);
     }
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
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+
