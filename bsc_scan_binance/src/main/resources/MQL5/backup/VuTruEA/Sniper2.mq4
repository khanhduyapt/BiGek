//+------------------------------------------------------------------+
//|                                                    Sigma Scalper |
//|                                    Copyright 2018, Jhon Anderson |
//|                                             jhandervel@gmail.com |
//+------------------------------------------------------------------+
#property strict

#property copyright "Jhon Anderson"
#property link      "jhandervel@gmail.com"

#include <stderror.mqh>
#include <stdlib.mqh>

string Ordercomment="FX_EA";
int    Slippage=5;
int    Retries=10;
bool   ecnBroker=false;

input int    MagicID=123;
input double SL=50;
input double TP=11;
input bool   UseAutoLots=true;
input double FixedLots=0.01;

double Lots;

int    currentTicket=0;

double vPoint=0.0001;
string orderstr,datapath;
int    previousBar=0;
int    hst_handle;
int    BytesToRead=0;
double data[][2];

#import "kernel32.dll"
int CreateFileW(string,uint,int,int,int,int,int);
int GetFileSize(int,int);
int SetFilePointer(int,int,int&[],int);
int ReadFile(int,uchar&[],int,int&[],int);
int CloseHandle(int);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
union Price
  {
   uchar             buffer[8];
   double            close;
  };

Price price;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadFileHst(string Filename)
  {

   int j=0;

   string strFileContents="";
   int Handle=CreateFileW(Filename,0x80000000,3,0,3,0,0);

   if(Handle==-1)
     {
      Print("Error open history!");
      return ("");
     }

   else
     {
      int LogFileSize=GetFileSize(Handle,0);

      if(LogFileSize<=0)
        {
         return ("");
        }

      else
        {

         int movehigh[1];

         SetFilePointer(Handle,148,movehigh,0);

         uchar buffer[];
         BytesToRead=(LogFileSize-148)/60;

         ArrayResize(data,BytesToRead);

         int nNumberOfBytesToRead=60;

         ArrayResize(buffer,nNumberOfBytesToRead);
         int read[1];

         for(int i=0;i<BytesToRead;i++)
           {
            ReadFile(Handle,buffer,nNumberOfBytesToRead,read,0);
            if(read[0]==nNumberOfBytesToRead)
              {
               string result="";
               result=StringFormat("0x%02x%02x%02x%02x%02x%02x%02x%02x",buffer[7],buffer[6],buffer[5],buffer[4],buffer[3],buffer[2],buffer[1],buffer[0]);

               price.buffer[0]=buffer[32];
               price.buffer[1]=buffer[33];
               price.buffer[2]=buffer[34];
               price.buffer[3]=buffer[35];
               price.buffer[4]=buffer[36];
               price.buffer[5]=buffer[37];
               price.buffer[6]=buffer[38];
               price.buffer[7]=buffer[39];

               double mm=price.close;

               data[j][0]=StrToDouble(result);
               data[j][1]=mm;
               j++;

               strFileContents=TimeToStr((datetime)StrToDouble(result),TIME_DATE|TIME_MINUTES)+" "+DoubleToStr(mm,8);
              }
            else
              {
               CloseHandle(Handle);
               return ("");
              }
           }
        }

      CloseHandle(Handle);
     }

   strFileContents=TimeToStr((datetime)(data[j-1][0]),TIME_DATE|TIME_MINUTES)+" "+DoubleToStr(data[j-1][1],8)+" "+
                   TimeToStr((datetime)(data[j-2][0]),TIME_DATE|TIME_MINUTES)+" "+DoubleToStr(data[j-2][1],8);

   return strFileContents;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fnGetLotDigit()
  {
   double l_LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(l_LotStep == 1)      return(0);
   if(l_LotStep == 0.1)    return(1);
   if(l_LotStep == 0.01)   return(2);
   if(l_LotStep == 0.001)  return(3);
   if(l_LotStep == 0.0001) return(4);
   return(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Digits==3)
     {
      vPoint=0.01;
     } else {
      if(Digits==5)
        {
         vPoint=0.0001;
        } else {
         vPoint=Point;
        }
     }

   string account_server=AccountInfoString(ACCOUNT_SERVER);
   if(account_server=="") account_server="default";
   datapath=TerminalInfoString(TERMINAL_DATA_PATH)+"\\history\\"+account_server+"\\"+Symbol()+"240"+".hst";

   string result=ReadFileHst(datapath);

   previousBar=Bars;

   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   ChartRedraw(0);

   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckBuyOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
            break;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckSellOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
            break;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckTotalBuyOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckTotalSellOrders(int magic)
  {
   int op=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=magic) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketSellOrders()
  {
   int op=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=MagicID) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_SELL)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckMarketBuyOrders()
  {
   int op=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      int status=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()!=MagicID) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            op++;
           }
        }
     }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MainOrders(int a_cmd_0,double price_24,double price_TP,double price_SL)
  {
   color color_8=Black;
   int bClosed;
   int nAttemptsLeft=Retries;
   int cmd=0;

   if(a_cmd_0 ==OP_BUY||a_cmd_0 ==OP_BUYSTOP)   cmd=0;
   if(a_cmd_0 ==OP_SELL||a_cmd_0 ==OP_SELLSTOP) cmd=1;

   if(a_cmd_0==OP_BUYLIMIT || a_cmd_0==OP_BUY)
     {
      color_8=Blue;
        } else {
      if(a_cmd_0==OP_SELLLIMIT || a_cmd_0==OP_SELL)
        {
         color_8=Red;
        }
     }

   double lots_32=NormalizeDouble(Lots,fnGetLotDigit());

   if(lots_32==0.0) return(0);

   double gd_532 = MarketInfo(Symbol(), MODE_MAXLOT);
   double gd_540 = MarketInfo(Symbol(), MODE_MINLOT);

   if(lots_32 > gd_532) lots_32 = gd_532;
   if(lots_32 < gd_540) lots_32 = gd_540;

   bClosed=false;

   while((bClosed==false) && (nAttemptsLeft>=0))
     {
      nAttemptsLeft--;
      RefreshRates();

      if(!ecnBroker)
         bClosed=OrderSend(Symbol(),a_cmd_0,lots_32,price_24,Slippage,price_SL,price_TP,Ordercomment,MagicID,0,color_8);
      else
         bClosed=OrderSend(Symbol(),a_cmd_0,lots_32,price_24,Slippage,0,0,Ordercomment,MagicID,0,color_8);

      if(bClosed<=0)
        {
         int nErrResult=GetLastError();

         if(a_cmd_0==0)
           {
            Print("FX EA Open New Buy FAILED : Error "+IntegerToString(nErrResult)+" ["+ErrorDescription(nErrResult)+".]");
            Print(IntegerToString(a_cmd_0)+" "+DoubleToString(lots_32,2)+" "+DoubleToString(price_24,Digits));
           }
         else
           {
            if(a_cmd_0==1)
              {
               Print("FX EA Open New Sell FAILED : Error "+IntegerToString(nErrResult)+" ["+ErrorDescription(nErrResult)+".]");
               Print(IntegerToString(a_cmd_0)+" "+DoubleToString(lots_32,2)+" "+DoubleToString(price_24,Digits));
              }
           }

         if(nErrResult == ERR_TRADE_CONTEXT_BUSY ||
            nErrResult == ERR_NO_CONNECTION)
           {
            Sleep(50);
            continue;
           }
        }

      currentTicket=bClosed;

      bClosed=true;

     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(UseAutoLots)
     {
      Lots=AccountEquity()/10000;
      if(Lots<MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
      if(Lots>MarketInfo(Symbol(), MODE_MAXLOT)) Lots = MarketInfo(Symbol(), MODE_MAXLOT);
        } else {Lots=FixedLots;
     }

   if(previousBar!=Bars)
     {
      previousBar=Bars;
     }
   else
     {
      return;
     }

   if(BytesToRead>0)
     {
      int pos=-1;
      for(int i=0;i<BytesToRead;i++)
        {
         if(data[i][0]>=Time[0])
           {
            pos=i;
            break;
           }

        }

      if(pos>0)
        {

         if(CheckMarketBuyOrders()==0 && CheckMarketSellOrders()==0)
           {
            if(data[pos][1]>Open[0])
              {
               double BuySL=NormalizeDouble(Ask - SL*vPoint,Digits);
               double BuyTP=NormalizeDouble(Ask + TP*vPoint,Digits);
               MainOrders(0,Ask,BuyTP,BuySL);
              }

            if(data[pos][1]<Open[0])
              {
               double SellSL=NormalizeDouble(Bid + SL*vPoint,Digits);
               double SellTP=NormalizeDouble(Bid - TP*vPoint,Digits);
               MainOrders(1,Bid,SellTP,SellSL);
              }
           }

        }

     }

   return;
  }
//+------------------------------------------------------------------+
