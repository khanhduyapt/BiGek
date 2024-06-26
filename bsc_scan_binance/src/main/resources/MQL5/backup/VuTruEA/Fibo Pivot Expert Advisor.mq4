#property version "1.00"
#property strict

extern int     TP                      = 50;
extern int     SL                      = 25;
extern double  Lots                    = 0.01;
extern int     Magic                   = 69;
double slb,tpb,sls,tps,pt;
int res,wt,wk,tiket,ticet;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(Digits==3 || Digits==5) pt=10*Point;   else   pt=Point;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  { 
 double hd=iHigh(Symbol(),PERIOD_D1,1);
 double ld=iLow(Symbol(),PERIOD_D1,1);
 double cd=iClose(Symbol(),PERIOD_D1,1);
 double hw=iHigh(Symbol(),PERIOD_W1,1);
 double lw=iLow(Symbol(),PERIOD_W1,1);
 double cw=iClose(Symbol(),PERIOD_W1,1);
 double pp1=(hd+ld+cd)/3;
 double pp2=(hw+lw+cw)/3;
 double r1=pp1+0.382*(hd-ld);
 double s1=pp1-0.382*(hd-ld);
 double r2=pp1+0.618*(hd-ld);
 double s2=pp1-0.618*(hd-ld);
 double r3=pp1+1*(hd-ld);
 double s3=pp1-1*(hd-ld);
 
    //--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(Lots<min_volume)
     {
      Comment("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(Lots>max_volume)
     {
      Comment("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     } 
     
   
      if(totalorder(0)==0 && Ask==pp1 ){res=OrderSend(Symbol(), OP_BUY,Lots , Ask, 3, Ask-SL*10*Point,Ask+TP*10*Point, "", Magic, 0, Blue);}
  
      if(totalorder(1)==0 && Bid==pp1){res=OrderSend(Symbol(), OP_SELL,Lots , Bid, 3, Bid+SL*10*Point,Bid-TP*10*Point, "", Magic, 0, Red);}
        
   return(0);
  }
//+------------------------------------------------------------------+
int totalorder( int tipe)
{
int total=0;
for( int i=0; i<OrdersTotal(); i++)
  {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic || OrderType()!=tipe) continue;
     total++;
  }

return(total);
}

