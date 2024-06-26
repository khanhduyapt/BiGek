/*+------------------------------------------------------------------+
 | fibo
 | Author: Copyright © 2006,
 |
 |
 +------------------------------------------------------------------+*/
#property copyright "Copyright © 2006,"
#property link      "http://www.metaquotes.net"

extern int Magic_Number=12345,OpenOrdersLimit=1;
extern double Lots=0.1;

double PrevDayHiBuffer[];
double PrevDayLoBuffer[];
double PrevDayOpenBuffer[];
double PrevDayCloseBuffer[];


int fontsize=11;
double PrevDayHi, PrevDayLo, PrevDayOpen , PrevDayClose,fb,fs,fe,tp1,tp2,tp3;
double LastHigh,LastLow,LastOpen,LastClose,x;
double ri,re1,re2,re3,ra1,ra2,ra3;




//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here


   ObjectDelete("PrevDayHi");
   ObjectDelete("PrevDayLo");
   ObjectDelete("PrevDayOpen");
   ObjectDelete("PrevDayClose");
   ObjectDelete("fe");ObjectDelete("fe Line");
   ObjectDelete("fs");ObjectDelete("fs Line");
   ObjectDelete("tp3");ObjectDelete("tp3 Line");
   ObjectDelete("tp2");ObjectDelete("tp2 Line");
   ObjectDelete("tp1");ObjectDelete("tp1 Line");
   ObjectDelete("fb");ObjectDelete("fb Line");
  //   ObjectsDeleteAll();
//  Not a good idea to use ObjectDeleteAll function.
// It will delete ALL object on the chart
// not just the ones created by this indicator
//
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
   string short_name;


//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);

   SetIndexBuffer(0, PrevDayHiBuffer);
   SetIndexBuffer(1, PrevDayLoBuffer);
   SetIndexBuffer(2, PrevDayOpenBuffer);
   SetIndexBuffer(3, PrevDayCloseBuffer);

//---- name for DataWindow and indicator subwindow label
   short_name="Prev Hi-Lo levels";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);

//----
   SetIndexDrawBegin(0,1);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

   int    counted_bars=IndicatorCounted();

   int limit, i;
//---- indicator calculation
   if (counted_bars==0)
   {
   //---- last counted bar will be recounted
   //   if(counted_bars>0) counted_bars--;
   }
   limit=(Bars-counted_bars)-1;

   for (i=limit; i>=0;i--)
   {

     LastHigh=High[Highest(NULL,0,MODE_HIGH,i+1)];
     LastLow=Low[Lowest(NULL,0,MODE_LOW,i+1)];
     if (Open[i+1]>LastOpen) LastOpen=Open[i+1];

//Print("TimeDay(Time[i]=",TimeDay(Time[i]),"TimeDay(Time[i+1])",TimeDay(Time[i+1]));
     if (TimeDay(Time[i])!=TimeDay(Time[i+1]))
     {
       RefreshRates( ) ;

       PrevDayHi=LastHigh;
       PrevDayLo=LastLow;
       PrevDayOpen=LastClose;
       PrevDayClose=Open[i];

       LastLow=Open[i];
       LastHigh=Open[i];
       LastOpen=Open[i];
       LastClose=Open[i];

    }

     PrevDayHiBuffer[i]=PrevDayHi;
     PrevDayLoBuffer[i]=PrevDayLo;
     PrevDayOpenBuffer[i]=PrevDayOpen;
     PrevDayCloseBuffer[i]=PrevDayClose;

   }

// BUY
   if (Ask > LastClose) {
     fb= PrevDayHi-(PrevDayHi-PrevDayLo)*0.382;
     fe= PrevDayHi-(PrevDayHi-PrevDayLo)*0.618;
     tp1=((PrevDayHi-PrevDayLo)*0.618)+fb;
     tp2=(PrevDayHi-PrevDayLo)+fb;
     tp3=1.618*(PrevDayHi-PrevDayLo)+fb;
     ri=MathRound((+fb-fe)*10000)/10000;
     re1=MathRound((+tp1-fb)*10000)/10000;
     re2=MathRound((+tp2-fb)*10000)/10000;
     re3=MathRound((+tp3-fb)*10000)/10000;
     ra1=MathRound((+re1/ri)*10)/10;
     ra2=MathRound((+re2/ri)*10)/10;
     ra3=MathRound((+re3/ri)*10)/10;

if (Bid > fb)
{
int count = 0;
for (int j=OrdersTotal()-1; j >= 0; j--)
if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
{
    if (OrderSymbol() == Symbol())
    if (OrderMagicNumber() == Magic_Number)
    {
        count++;
    }
}
if (count < OpenOrdersLimit)
{
       int ticket;
       ticket = OrderSend(Symbol(), OP_BUY,Lots,Ask,4,0,0, "Ultima_fibo",Magic_Number,0,Red);
       for (i=OrdersTotal()-1; i >= 0; i--)
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
       {
        if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number)
        {
         bool ret = OrderModify(OrderTicket(), OrderOpenPrice(),fe,tp1, 0, Red);
        }
       }
}
}
     RefreshRates( ) ;
     if(ObjectFind("fb") != 0)
     {
        ObjectCreate("fb", OBJ_TEXT, 0, Time[0], fb);
        ObjectSetText("fb", " BUY LEVEL", 14, "Arial Black", White);
     }
     else
     {
        ObjectMove("fb",fb, Time[0], fb);
     }
     if(ObjectFind("fb Line") != 0)
     {
        ObjectCreate("fb Line", OBJ_HLINE, 0, Time[0],fb);
        ObjectSet("fb Line", OBJPROP_STYLE, STYLE_DASHDOT);
        ObjectSet("fb Line", OBJPROP_COLOR, Blue);
     }
     else
     {
        ObjectMove("fb Line",0, Time[0], fb);
     }


     if((ra1>2)&&(ra2>2)&&(ra3>2))
        Comment("Owner : ", AccountName()," Account number : ", AccountNumber(),
        "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was UP ",
        "\nBUY @ ",fb ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
        " Risk/Reward Ratio : ", ra1 ," OK Trade ","\nTakeProit 2 ",tp2 ,
        " Risk/Reward Ratio : ", ra2 ," OK Trade ","\nTakeProit 3 ",tp3,
        " Risk/Reward Ratio : ", ra3 ," OK Trade ");
     else
        Comment("Owner : ", AccountName()," Account number : ", AccountNumber(),
        "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was UP ",
        "\nBUY @ ",fb ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
        " Risk/Reward Ratio : ", ra1 ," NO TRADE ","\nTakeProit 2 ",tp2 ,
        " Risk/Reward Ratio : ", ra2 ," NO TRADE ","\nTakeProit 3 ",tp3,
        " Risk/Reward Ratio : ", ra3 ," NO TRADE ");
   }

// SELL
   if (Bid < LastClose) {
     fs=(PrevDayHi-PrevDayLo)*0.382+(PrevDayLo);
     fe=(PrevDayHi-PrevDayLo)*0.618+(PrevDayLo);
     tp1=((PrevDayLo-PrevDayHi)*0.618)+fs;
     tp2=(PrevDayLo-PrevDayHi)+fs;
     tp3=1.618*(PrevDayLo-PrevDayHi)+fs;
     ri=MathRound((+fs-fe)*10000)/10000;
     re1=MathRound((+tp1-fs)*10000)/10000;
     re2=MathRound((+tp2-fs)*10000)/10000;
     re3=MathRound((+tp3-fs)*10000)/10000;
     ra1=MathRound((+re1/ri)*10)/10;
     ra2=MathRound((+re2/ri)*10)/10;
     ra3=((+re3/ri)*10)/10;

if (Bid < fs)
{
count = 0;
for (j=OrdersTotal()-1; j >= 0; j--)
if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
{
    if (OrderSymbol() == Symbol())
    if (OrderMagicNumber() == Magic_Number)
    {
        count++;
    }
}
if (count < OpenOrdersLimit)
{
       ticket = OrderSend(Symbol(), OP_SELL,Lots,Bid,4,0,0, "Ultima_fibo",Magic_Number, 0,Red);
       for (i=OrdersTotal()-1; i >= 0; i--)
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
       {
        if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number)
        {
         ret = OrderModify(OrderTicket(), OrderOpenPrice(),fe,tp1, 0, Red);
        }
       }
}
}
     RefreshRates( ) ;
     if(ObjectFind("fs") != 0)
     {
        ObjectCreate("fs", OBJ_TEXT, 0, Time[0], fs);
        ObjectSetText("fs", " SELL LEVEL", 14, "Arial Black", White);
     }
     else
     {
        ObjectMove("fs",fs, Time[0], fs);
     }
     if(ObjectFind("fs Line") != 0)
     {
        ObjectCreate("fs Line", OBJ_HLINE, 0, Time[0],fs);
        ObjectSet("fs Line", OBJPROP_STYLE, STYLE_DASHDOT);
        ObjectSet("fs Line", OBJPROP_COLOR, Red);
     }
     else
     {
        ObjectMove("fs Line",0, Time[0], fs);
     }
     if((ra1>2)&&(ra2>2)&&(ra3>2))
        Comment("Owner : ", AccountName(),"Account number : ", AccountNumber(),
        "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was Down ",
        "\nSELL @ ",fs ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
        " Risk/Reward Ratio : ", ra1 ," OK Trade ","\nTakeProit 2 ",tp2 ,
        " Risk/Reward Ratio : ", ra2 ," OK Trade ","\nTakeProit 3 ",tp3,
        " Risk/Reward Ratio : ", ra3 ," OK Trade ");
     else
        Comment("Owner : ", AccountName(),"Account number : ", AccountNumber(),
        "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was Down ",
        "\nSELL @ ",fs ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
        " Risk/Reward Ratio : ", ra1 ," NO TRADE ","\nTakeProit 2 ",tp2 ,
        " Risk/Reward Ratio : ", ra2 ," NO TRADE ","\nTakeProit 3 ",tp3,
        " Risk/Reward Ratio : ", ra3 ," NO TRADE ");
   }
     if(ObjectFind("fe") != 0)
     {
        ObjectCreate("fe", OBJ_TEXT, 0, Time[0], fe);
        ObjectSetText("fe", " STOPLOSS LEVEL", 11, "Arial", White);
     }
     else
     {
        ObjectMove("fe",fe, Time[0], fe);
     }
     if(ObjectFind("fe Line") != 0)
     {
        ObjectCreate("fe Line", OBJ_HLINE, 0, Time[0],fe);
        ObjectSet("fe Line", OBJPROP_STYLE, STYLE_DASHDOT);
        ObjectSet("fe Line", OBJPROP_COLOR,OrangeRed );
     }
     else
     {
        ObjectMove("fe Line",0, Time[0], fe);
     }

     if(ObjectFind("tp1") != 0)
     {
        ObjectCreate("tp1", OBJ_TEXT, 0, Time[0], tp1);
        ObjectSetText("tp1", " PROFIT TARGET 1", 11, "Arial", White);
     }
     else
     {
        ObjectMove("tp1",tp1, Time[0],tp1 );
     }

     if(ObjectFind("tp1 Line") != 0)
     {
        ObjectCreate("tp1 Line", OBJ_HLINE, 0, Time[0],tp1);
        ObjectSet("tp1 Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("tp1 Line", OBJPROP_COLOR,SpringGreen );
     }
     else
     {
        ObjectMove("tp1 Line",0, Time[0],tp1 );
     }

     if(ObjectFind("tp2") != 0)
     {
        ObjectCreate("tp2", OBJ_TEXT, 0, Time[0], tp2);
        ObjectSetText("tp2", " PROFIT TARGET 2", 11, "Arial", White);
     }
     else
     {
        ObjectMove("tp2",tp2, Time[0],tp2);
     }
     if(ObjectFind("tp2 Line") != 0)
     {
        ObjectCreate("tp2 Line", OBJ_HLINE, 0, Time[0],tp2);
        ObjectSet("tp2 Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("tp2 Line", OBJPROP_COLOR,SpringGreen );
     }
     else
     {
        ObjectMove("tp2 Line",0, Time[0],tp2);
     }

     if(ObjectFind("tp3") != 0)
     {
        ObjectCreate("tp3", OBJ_TEXT, 0, Time[0], tp3);
        ObjectSetText("tp3", " PROFIT TARGET 3", 11, "Arial", White);
     }
     else
     {
        ObjectMove("tp3",tp3, Time[0],tp3);
     }
     if(ObjectFind("tp3 Line") != 0)
     {
        ObjectCreate("tp3 Line", OBJ_HLINE, 0, Time[0],tp3);
        ObjectSet("tp3 Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("tp3 Line", OBJPROP_COLOR,SpringGreen );
     }
     else
     {
        ObjectMove("tp3 Line",0, Time[0],tp3);
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+

