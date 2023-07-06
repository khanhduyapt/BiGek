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
   FileDelete("Data//Trade.csv");
   int nfile_handle = FileOpen("Data//Trade.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

   if(nfile_handle != INVALID_HANDLE)
     {
      FileWrite(nfile_handle, "Symbol", "Ticket", "TypeDescription", "PriceOpen",  "StopLoss", "TakeProfit",  "Profit",  "Comment", "Volume", "CurrPrice");

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

         FileWrite(nfile_handle, m_position.Symbol(), m_position.Ticket(), m_position.TypeDescription(), m_position.PriceOpen(),  m_position.StopLoss(), m_position.TakeProfit(),  m_position.Profit(), " " + m_position.Comment(), m_position.Volume(), m_position.PriceCurrent());
        }


      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if(m_order.SelectByIndex(i))
           {
            FileWrite(nfile_handle, m_order.Symbol(), m_order.Ticket(), m_order.TypeDescription(), m_order.PriceOpen(), m_order.StopLoss(), m_order.TakeProfit(), "0.0", " " + m_order.Comment(), m_order.VolumeCurrent(), m_order.PriceCurrent());
           }
        }
      //--------------------------------------------------------------------------------------------------------------------
      FileClose(nfile_handle);

      Comment("-----------------------------TradeList: (Buy)" + (string)count_buys + " (Sell):"+ (string)count_sells);
     }
   else
     {
      Print("(Data2Csv) Failed to get history data.");
     }
  }
//+------------------------------------------------------------------+
