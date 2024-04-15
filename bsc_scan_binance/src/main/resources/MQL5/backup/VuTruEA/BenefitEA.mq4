#define MB_YESNO		0x00000004
#define IDYES			6

bool   ECN=true;//set true if using ECN broker. If true then EA will open orders with SL=0 and TP=0 and will modify these parameters after order(including pending) is executed
extern string _0_="================ Base settings ================";
extern bool   New_Cycle=true;
extern bool   Auto_Detect_5_Digit_Brokers=false;
extern int    MAGIC=222;
extern double Slippage=3;
extern double Max_Trades=17;
extern double Max_Lot=100;

extern string _1_ = "================ Time filter settings ================";
extern bool   Time_Filters=false;
extern string Trading_Time_1_Start="00:00";
extern string Trading_Time_1_End="06:00";
extern string Trading_Time_2_Start="13:00";
extern string Trading_Time_2_End="13:00";

extern string _2_ = "================ TP settings ================";
extern double TP=50;
extern double TP1=50;
extern bool   VTP=true;
extern double Tral_Start=10;
extern double Tral_Size=5;

extern string _3_            =  "================ Risk Reduction System ================";
extern bool   RRS            =  false;
extern int    RRS_nOrder         =  5;
extern double RRS_TP          =  50;
extern double RRS_Tral_Start  =  10;
extern double RRS_Tral_Size   =  5;
extern double RRS_Profit_Percent  =  15;

extern string _4_            =  "================ Buy settings ================";
extern double Step_Buy=5;
extern double Step_Coef_Buy=0;
extern int    Step_Coef_Start_Order_Buy=4;
extern string Step_Mass_Buy="60,60,60,60,60,60,80,80,90,120,120,120,150,150,150,200";
extern double Min_Lot_Buy=0.01;
extern double Lot_Exp_Buy=1.8;

extern string _5_            =  "================ Sell settings ================";
extern double Step_Sell=5;
extern double Step_Coef_Sell=0;
extern int    Step_Coef_Start_Order_Sell=4;
extern string Step_Mass_Sell="60,60,60,60,60,60,80,80,90,120,120,120,150,150,150,200";
extern double Min_Lot_Sell=0.01;
extern double Lot_Exp_Sell=1.8;

extern string _6_            =  "================ Color settings ================";
extern color  Buy_BE_Color=RoyalBlue;
extern color  Sell_BE_Color=Tomato;
extern color  Buy_TP_Color=DarkBlue;
extern color  Sell_TP_Color=Red;
extern color  Buy_Trall_Color=Yellow;
extern color  Sell_Trall_Color=Magenta;
extern color  Buy_LOT_Trall_Color=Yellow;
extern color  Sell_LOT_Trall_Color=Magenta;
extern color  RRS_Color_Sell   =  Purple;
extern color  RRS_Color_Buy    =  OrangeRed;

 double SL=0;


int x=1;
double Orders[2][100][10];// first dimension: 0 - buys, 1 - sells
                         // second dimension: orders according to magic number
                         // third dimension: 0 - OrderTicket, 1 - OrderType, 2 - OrderLots, 3 - OrderOpenPrice, 
                         // 4 - OrderStopLoss, 5 - OrderTakeProfit, 6 - point cost accroding to lot
int TotalOrders[2];
double lastPriceBuy, lastPriceSell;
double TrallBuys=-1, TrallSells=-1, LotTrallBuys=-1, LotTrallSells=-1;
double BuysBE, SellsBE, BuysTP, SellsTP, LOTBuysBE, LOTSellsBE, LOTBuysTP, LOTSellsTP;
//+-----------------------------------------------------------------+
//| Creates Label object on the chart                               |
//+-----------------------------------------------------------------+ 
bool ObjectCreateEx(string objname,int YOffset, int XOffset=0,int objType=23,int corner=0, bool background=false)
{
   bool needNUL=false;
   if(ObjectFind(objname)==-1)
   {
      needNUL=true;
      ObjectCreate(objname,objType,0,0,0,0,0);
   }
   
   ObjectSet(objname,103,YOffset);
   ObjectSet(objname,102,XOffset);
   ObjectSet(objname,101,corner);
   ObjectSet(objname, OBJPROP_BACK, background);
   if(needNUL) ObjectSetText(objname,"",14,"Tahoma",Gray);
}


int BuyObj[2], SellObj[2];
//+------------------------------------------------------------------+
//| EA initialization function                                       |
//+------------------------------------------------------------------+
int init()
{
  if(RRS_Tral_Size>RRS_Tral_Start) 
  {
     RRS_Tral_Size=RRS_Tral_Start;
     Alert("RRS_Tral_Size>RRS_Tral_Start. Please check EA settings");
  }
  if(Tral_Size>Tral_Start) 
  {
     Tral_Size=Tral_Start;
     Alert("Tral_Size>Tral_Start. Please check EA settings");
  }
  if(Auto_Detect_5_Digit_Brokers && (Digits==3 || Digits==5)) x=10;
  TP=TP*Point*x;
  TP1=TP1*Point*x;
  SL=SL*Point*x;
  RRS_TP=RRS_TP*Point*x;
  RRS_Tral_Size=RRS_Tral_Size*Point*x;
  RRS_Tral_Start=RRS_Tral_Start*Point*x;
  Tral_Size=Tral_Size*Point*x;
  Tral_Start=Tral_Start*Point*x;
  
  BuyObj[0]=350;
  BuyObj[1]=22;
  SellObj[0]=350;
  SellObj[1]=322;  
  
  ObjectCreateEx("_Benefit_error", 20, 20);
  ObjectCreateEx("_Benefit_OpenBuy", BuyObj[1], BuyObj[0], 23, 0, false);
  ObjectCreateEx("_Benefit_OpenSell", SellObj[1], SellObj[0], 23, 0, false);
  
  ObjectSetText("_Benefit_OpenBuy","5",20,"Webdings",RoyalBlue);
  ObjectSetText("_Benefit_OpenSell","6",20,"Webdings",Tomato);
  
       ObjectCreate("_Benefit_BuyBE", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_BuyBE", OBJPROP_COLOR, Buy_BE_Color);
       ObjectSet   ("_Benefit_BuyBE", OBJPROP_WIDTH, 1);          
       ObjectSet   ("_Benefit_BuyBE", OBJPROP_BACK, 1);            
   
       ObjectCreate("_Benefit_SellBE", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_SellBE", OBJPROP_COLOR, Sell_BE_Color);
       ObjectSet   ("_Benefit_SellBE", OBJPROP_WIDTH, 1);                 
       ObjectSet   ("_Benefit_SellBE", OBJPROP_BACK, 1);    
       
       ObjectCreate("_Benefit_LotTPBuy", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_LotTPBuy", OBJPROP_COLOR, RRS_Color_Buy);
       ObjectSet   ("_Benefit_LotTPBuy", OBJPROP_WIDTH, 2);          
       ObjectSet   ("_Benefit_LotTPBuy", OBJPROP_BACK, 1);       
       
       ObjectCreate("_Benefit_LotTPSell", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_LotTPSell", OBJPROP_COLOR, RRS_Color_Sell);
       ObjectSet   ("_Benefit_LotTPSell", OBJPROP_WIDTH, 2);         
       ObjectSet   ("_Benefit_LotTPSell", OBJPROP_BACK, 1);        
       
       ObjectCreate("_Benefit_BuyTP", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_BuyTP", OBJPROP_COLOR, Buy_TP_Color);
       ObjectSet   ("_Benefit_BuyTP", OBJPROP_WIDTH, 2);            
       ObjectSet   ("_Benefit_BuyTP", OBJPROP_BACK, 1);     
       
       ObjectCreate("_Benefit_SellTP", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_SellTP", OBJPROP_COLOR, Sell_TP_Color);
       ObjectSet   ("_Benefit_SellTP", OBJPROP_WIDTH, 2);          
       ObjectSet   ("_Benefit_SellTP", OBJPROP_BACK, 1);     
       
       ObjectCreate("_Benefit_SellTrall", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_SellTrall", OBJPROP_COLOR, Sell_Trall_Color);
       ObjectSet   ("_Benefit_SellTrall", OBJPROP_WIDTH, 1);          
       ObjectSet   ("_Benefit_SellTrall", OBJPROP_BACK, 1);   
       
       ObjectCreate("_Benefit_BuyTrall", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_BuyTrall", OBJPROP_COLOR, Buy_Trall_Color);
       ObjectSet   ("_Benefit_BuyTrall", OBJPROP_WIDTH, 1);          
       ObjectSet   ("_Benefit_BuyTrall", OBJPROP_BACK, 1); 
               
       ObjectCreate("_Benefit_SellLOTTrall", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_SellLOTTrall", OBJPROP_COLOR, Sell_LOT_Trall_Color);
       ObjectSet   ("_Benefit_SellLOTTrall", OBJPROP_WIDTH, 1);           
       ObjectSet   ("_Benefit_SellLOTTrall", OBJPROP_BACK, 1);  
       
       ObjectCreate("_Benefit_BuyLOTTrall", OBJ_HLINE, 0, 0, 0);                      
       ObjectSet   ("_Benefit_BuyLOTTrall", OBJPROP_COLOR, Buy_LOT_Trall_Color);
       ObjectSet   ("_Benefit_BuyLOTTrall", OBJPROP_WIDTH, 1);              
       ObjectSet   ("_Benefit_BuyLOTTrall", OBJPROP_BACK, 1);     
}


bool MyBreakPointFlag=false;


//+------------------------------------------------------------------+
//| BreakPoint function for EA debug                                 |
//+------------------------------------------------------------------+
void MyBreakPoint()
{
   if(!IsVisualMode())return;
   MyBreakPointFlag=true;
   if(ObjectFind("MyBreakPointLabel")<0)
   {
      ObjectCreate("MyBreakPointLabel",23,0,0,0,0,0);
      ObjectSet("MyBreakPointLabel",103,2*(20)+28);
      ObjectSet("MyBreakPointLabel",102,10*(20)+28);
      ObjectSetText("MyBreakPointLabel","BreakPoint at "+TimeToStr(TimeCurrent())+". Delete this text to continue.",14,"Tahoma",Red);
   }

  while(ObjectFind("MyBreakPointLabel")!=-1)Sleep(100);
}

//+------------------------------------------------------------------+
//| EA start function                                                |
//+------------------------------------------------------------------+
int start()
{
//=======================================Some variables initialization
   double sl,tp,op,lot;
   int magic, ticket, i, j;
   ObjectSetText("_Benefit_error","",14,"Tahoma",Gray);
   double Level=MathMax(MarketInfo(Symbol(),MODE_FREEZELEVEL),MarketInfo(Symbol(),MODE_STOPLEVEL))*Point*x;
//=======================================(Some variables initialization)

//==========================================Filling array Orders of opened trades information
   ArrayInitialize(Orders,-1);
   ArrayInitialize(TotalOrders,0);
   int NeedCloseAll=-1;
   lastPriceBuy=0; lastPriceSell=0;
   double highestBuy=-1, lowestBuy=-1, highestSell=-1, lowestSell=-1;
   double profitBuys=0, profitSells=0;
   int buys=0, sells=0;
   double lotsBuys=0, lotsSells=0;
   int firstBuyTime=-1, firstSellTime=-1;
   
   for(i=OrdersTotal()-1;i>=0;i--)
     if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol())
     {
        if(OrderMagicNumber()==MAGIC+1)
        {
           NeedCloseAll=OrderTicket();
           continue;
        }
        
        if(OrderMagicNumber()!=MAGIC) continue;
        
        int index=0;
        if(OrderType()==1)
          index=1;
        
        if(NO(lastPriceBuy)==0 && OrderType()==0) lastPriceBuy=OrderOpenPrice();
        if(NO(lastPriceSell)==0 && OrderType()==1) lastPriceSell=OrderOpenPrice();
        
        if(OrderType()==0)
        {
           if(NO(highestBuy)<0 || NO(OrderOpenPrice())>NO(highestBuy)) highestBuy=OrderOpenPrice();
           if(NO(lowestBuy)<0 || NO(OrderOpenPrice())<NO(lowestBuy)) lowestBuy=OrderOpenPrice();
           profitBuys+=(OrderProfit()+OrderCommission()+OrderSwap());
           lotsBuys+=OrderLots();
           buys++;
           if(firstBuyTime<0 || OrderOpenTime()<firstBuyTime) firstBuyTime=OrderOpenTime();
        }
        if(OrderType()==1)
        {
           if(NO(highestSell)<0 || NO(OrderOpenPrice())>NO(highestSell)) highestSell=OrderOpenPrice();
           if(NO(lowestSell)<0 || NO(OrderOpenPrice())<NO(lowestSell)) lowestSell=OrderOpenPrice();
           profitSells+=(OrderProfit()+OrderCommission()+OrderSwap());
           lotsSells+=OrderLots();
           sells++;
           if(firstSellTime<0 || OrderOpenTime()<firstSellTime) firstSellTime=OrderOpenTime();
        }
        
        Orders[index][TotalOrders[index]][0]=OrderTicket();
        Orders[index][TotalOrders[index]][1]=OrderType();
        Orders[index][TotalOrders[index]][2]=OrderLots();
        Orders[index][TotalOrders[index]][3]=OrderOpenPrice();
        Orders[index][TotalOrders[index]][4]=OrderStopLoss();
        Orders[index][TotalOrders[index]][5]=OrderTakeProfit(); 
        Orders[index][TotalOrders[index]][6]=PointCost(OrderLots());
        TotalOrders[index]++;
     }
     
     if(TotalOrders[0]<1)
     {
        LotTrallBuys=-1;
        TrallBuys=-1;
     }
     
     if(TotalOrders[1]<1)
     {
        LotTrallSells=-1;
        TrallSells=-1;
     }
//==========================================(Filling array Orders of opened trades information)

//==========================================Closing current cycle and deleting close/delete signal order
   bool NeedReturn=false;
   if(NeedCloseAll>=0 && OrderSelect(NeedCloseAll,SELECT_BY_TICKET))
   {
      index=-1;
      if(OrderType()==4 && TotalOrders[0]>0) index=0;
      if(OrderType()==5 && TotalOrders[1]>0) index=1;
      if(OrderType()==2 && TotalOrders[1]+TotalOrders[0]>0) index=2;
      
      if(index==0 || index==2)
      {
         for(i=0;i<TotalOrders[0];i++)
         {
            if(Orders[0][i][0]<0) continue;
            if(!OrderSelect(StrToInteger(DoubleToStr(Orders[0][i][0],0)),SELECT_BY_TICKET))continue;
            if(OrderSymbol()!=Symbol())continue;
            color col2=DarkBlue;
            if(OrderType()==1) col2=Red;
            if(OrderType()<2)OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3, col2);
            if(OrderType()>1)OrderDelete(OrderTicket());
         }
           
         NeedReturn=true;
      }
      
      if(index==1 || index==2)
      {
         for(i=0;i<TotalOrders[1];i++)
         {
            if(Orders[1][i][0]<0) continue;
            if(!OrderSelect(StrToInteger(DoubleToStr(Orders[1][i][0],0)),SELECT_BY_TICKET))continue;
            if(OrderSymbol()!=Symbol())continue;
            if(OrderType()<2)OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
            if(OrderType()>1)OrderDelete(OrderTicket());
         }
         
         NeedReturn=true;
      }
      
      if(NeedReturn)
        return;
   }
   
   if(NeedCloseAll>=0)
   {
      OrderDelete(NeedCloseAll);
      return;
   }
//==========================================(Closing current cycle and deleting close/delete signal order)

//==========================================Check for close all && count history profit
   int closeBuys=0, closeSells=0;
   double historyProfitBuys=0, historyProfitSells=0;
   bool countBuys=true, countSells=true;
   double dayProfit=0, weekProfit=0;
   
   for(int tr=OrdersHistoryTotal()-1;tr>=0;tr--)
   { 
      if(!OrderSelect(tr,SELECT_BY_POS,MODE_HISTORY)) 
        {Alert("!!!Can\'t select history order!!!");return(-100500);}
      if(OrderSymbol()!=Symbol()) 
        continue;
        
      if(OrderMagicNumber()!=MAGIC && OrderMagicNumber()!=MAGIC+1)
        continue;
      
      if(OrderMagicNumber()==MAGIC+1)
      {
         if(OrderType()==4) countBuys=false;
         if(OrderType()==5) countSells=false;
      }
      
      
      
      if(OrderOpenTime()>=iTime(NULL, 1440, 0))
        dayProfit+=(OrderProfit()+OrderCommission()+OrderSwap());
      
      if(OrderOpenTime()>=iTime(NULL, 10080, 0))
        weekProfit+=(OrderProfit()+OrderCommission()+OrderSwap());
      
      if(!countSells && !countBuys && OrderOpenTime()<iTime(NULL, 10080, 0)) break;  
      
      if(OrderType()==0 && countBuys)
      {
         closeBuys++;
      }
      
      if(OrderType()==1 && countSells)
      {
         closeSells++;
      }
      
      if(OrderType()==0 && OrderOpenTime()>firstBuyTime && firstBuyTime>-1) 
        historyProfitBuys=historyProfitBuys+(OrderProfit()+OrderCommission()+OrderSwap());
      
      if(OrderType()==1 && OrderOpenTime()>firstSellTime && firstSellTime>-1) 
        historyProfitSells=historyProfitSells+(OrderProfit()+OrderCommission()+OrderSwap());
        
   }
   
  /* if(closeBuys>0 || closeSells>0)
   {
      if(closeBuys>0) int ortype=4;
      if(closeSells>0) ortype=5;
      if(closeSells>0 && closeBuys>0) ortype=2;
      PutServiceOrder(ortype, MAGIC+1);
      
      return;
   }*/
//==========================================(Check for close all)

//==========================================Signal determination
   bool Buy=false, Sell=false;
   j=TotalOrders[0]-Step_Coef_Start_Order_Buy+2;
   if(j<0) j=0;
   double buystep=Step_Buy*MathPow(Step_Coef_Buy, j);
   if(NO(Step_Coef_Buy)==0) buystep=ParseStepMass(TotalOrders[0], 0);
   
   Buy=(((TotalOrders[0]==0 && NO(Close[2])>NO(Open[2]) && NO(Close[1])>NO(Open[1])) || TotalOrders[0]>0) 
        && (!ThereIsOrderOnThisBar(Time[0], 0) && (lastPriceBuy-Ask>=buystep*Point*x || NO(lastPriceBuy)==0)));
   
   
   j=TotalOrders[1]-Step_Coef_Start_Order_Sell+2;
   if(j<0) j=0;
   double sellstep=Step_Sell*MathPow(Step_Coef_Sell, j);
   if(NO(Step_Coef_Sell)==0) sellstep=ParseStepMass(TotalOrders[1], 1);
   
   Sell=(((TotalOrders[1]==0 && NO(Close[2])<NO(Open[2]) && NO(Close[1])<NO(Open[1])) || TotalOrders[1]>0) 
        && (!ThereIsOrderOnThisBar(Time[0], 1) && (Bid-lastPriceSell>=sellstep*Point*x || NO(lastPriceSell)==0)));
        
   if(TotalOrders[0]<1 && (!New_Cycle || !TradeWasInTime(TimeCurrent()))) Buy=false;
   if(TotalOrders[1]<1 && (!New_Cycle || !TradeWasInTime(TimeCurrent()))) Sell=false;
   
   if(ObjectGet("_Benefit_OpenBuy", OBJPROP_XDISTANCE)!=BuyObj[0] || ObjectGet("_Benefit_OpenBuy", OBJPROP_YDISTANCE)!=BuyObj[1])
   {
      if(MessageBox("Вы действительно хотите открыть следующее колено Buy лотом "+DoubleToStr(GetLot(0, TotalOrders[0]+1), 2)+"?", "Подтвердите", MB_YESNO)==IDYES)
        Buy=true;
      ObjectSet("_Benefit_OpenBuy", OBJPROP_XDISTANCE, BuyObj[0]);
      ObjectSet("_Benefit_OpenBuy", OBJPROP_YDISTANCE, BuyObj[1]);
   }
   
   if(ObjectGet("_Benefit_OpenSell", OBJPROP_XDISTANCE)!=SellObj[0] || ObjectGet("_Benefit_OpenSell", OBJPROP_YDISTANCE)!=SellObj[1])
   {
      if(MessageBox("Вы действительно хотите открыть следующее колено Sell лотом "+DoubleToStr(GetLot(1, TotalOrders[1]+1), 2)+"?", "Подтвердите", MB_YESNO)==IDYES)
        Sell=true;
      ObjectSet("_Benefit_OpenSell", OBJPROP_XDISTANCE, SellObj[0]);
      ObjectSet("_Benefit_OpenSell", OBJPROP_YDISTANCE, SellObj[1]);
   }
//==========================================(Signal determination)

//==========================================Расчет и отрисовка БУ   
   SellsTP=0; BuysTP=0;
   //---------Для баев
   double TheSumm=0, TheSumm2=0, dTemp=0;
   BuysBE=0; SellsBE=0; LOTSellsBE=-1; LOTBuysBE=-1;
   ObjectSet("_Benefit_BuyBE",OBJPROP_PRICE1,0);
   if(TotalOrders[0]>0) 
   {
      for(int cikl=0;cikl<=(highestBuy-lowestBuy)/Point;cikl++)
      {
         BuysBE=lowestBuy+cikl*Point;
         TheSumm=0;
         TheSumm2=0;
         for(i=0;i<TotalOrders[0];i++)
         {
            dTemp=(BuysBE-Orders[0][i][3])/Point*Orders[0][i][6];
            TheSumm=TheSumm+dTemp;
            if(i<2) TheSumm2=TheSumm2+dTemp;
         }
         
         if(NO(TheSumm2)>=0.0 && LOTBuysBE<0) LOTBuysBE=BuysBE;
         
         if(NO(TheSumm)>=0.0)
         {
            ObjectSet("_Benefit_BuyBE",OBJPROP_PRICE1,BuysBE);
            if(NO(TP1)!=0.0) BuysTP=BuysBE+TP1; else BuysTP=0;
            if(TotalOrders[0]>1 && NO(TP)!=0.0) BuysTP=BuysBE+TP;
            break;
         }
      }
   }
    
    //---------Для селов
    ObjectSet("_Benefit_SellBE",OBJPROP_PRICE1,0);
    if(TotalOrders[1]>0) 
    {
       for(cikl=(highestSell-lowestSell)/Point;cikl>=0;cikl--)
       {
          SellsBE=lowestSell+cikl*Point;
          TheSumm=0;
          TheSumm2=0;
          for(i=0;i<TotalOrders[1];i++)
          {
             dTemp=(Orders[1][i][3]-SellsBE)/Point*Orders[1][i][6];
             TheSumm=TheSumm+dTemp;
             if(i<2) TheSumm2=TheSumm2+dTemp;
             //Print(i, " ", lowestSell, " ", dTemp);
          }
          
          if(NO(TheSumm2)>=0.0 && LOTSellsBE<0) LOTSellsBE=SellsBE;
          //Print(SellsBE, " ", TheSumm2, " ", LOTSellsBE);
          
          if(NO(TheSumm)>=0.0)
          {
             ObjectSet("_Benefit_SellBE",OBJPROP_PRICE1,SellsBE);
             if(NO(TP1)!=0.0) SellsTP=SellsBE-TP1; else SellsTP=0;
             if(TotalOrders[1]>1 && NO(TP)!=0.0) SellsTP=SellsBE-TP;
             break;
          }
       }
    }
    
    LOTBuysTP=LOTBuysBE+RRS_TP;
    LOTSellsTP=LOTSellsBE-RRS_TP;
    
    ObjectSet("_Benefit_LotTPBuy",OBJPROP_PRICE1,0);
    ObjectSet("_Benefit_LotTPSell",OBJPROP_PRICE1,0);
    
    ObjectSet("_Benefit_BuyTP",OBJPROP_PRICE1,0);
    ObjectSet("_Benefit_SellTP",OBJPROP_PRICE1,0);
    
    if(NO(BuysTP)>0) ObjectSet("_Benefit_BuyTP",OBJPROP_PRICE1,BuysTP);
    if(NO(SellsTP)>0) ObjectSet("_Benefit_SellTP",OBJPROP_PRICE1,SellsTP);
    
    if(LOTBuysBE>0 && TotalOrders[0]>=RRS_nOrder && RRS) ObjectSet("_Benefit_LotTPBuy",OBJPROP_PRICE1,LOTBuysTP);
    if(LOTSellsBE>0 && TotalOrders[1]>=RRS_nOrder && RRS) ObjectSet("_Benefit_LotTPSell",OBJPROP_PRICE1,LOTSellsTP);
    //Comment(LOTSellsTP, " ",LOTSellsBE, " ", RRS_TP);
//==========================================(Расчет и отрисовка БУ)

//==========================================Info panel
   double maxlot=AccountFreeMargin()/MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   //=======================================Table1 draw
   if(!IsTesting() || (IsTesting() && IsVisualMode()))
   {
      int Yt[3]={50, 350, 200}, Xt[3]={110, 110, 110};
      color textColor=White;
      ObjectCreateEx("_Benefit_t1_body", Yt[0]-30, Xt[0]-5, 23, 0, true);
      ObjectSetText("_Benefit_t1_body", "ggg", 110, "Webdings", C'62,62,62'); //Тело таблицы баев
      ObjectCreateEx("_Benefit_t1_Header", Yt[0]-25, Xt[0]+110, 23, 0);
      ObjectSetText("_Benefit_t1_Header", "BUY-SIDE", 16, "Dungeon", White); //Заголовок Buy
      //-------------------Первый столбец
      ObjectCreateEx("_Benefit_t1_1_1", Yt[0], Xt[0], 23, 0);
      ObjectSetText("_Benefit_t1_1_1", "Ордеров: "+DoubleToStr(buys, 0), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t1_1_2", Yt[0]+15, Xt[0], 23, 0);
      ObjectSetText("_Benefit_t1_1_2", "Объем: "+DoubleToStr(lotsBuys, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t1_1_3", Yt[0]+15*2, Xt[0], 23, 0);
      ObjectSetText("_Benefit_t1_1_3", "Уровень ТП: "+DoubleToStr(BuysTP, Digits), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t1_1_4", Yt[0]+15*3, Xt[0], 23, 0);
      ObjectSetText("_Benefit_t1_1_4", "Уровень LTP:"+DoubleToStr(LOTBuysTP, Digits), 10, "Courier New", textColor);
      //-------------------Второй столбец
      ObjectCreateEx("_Benefit_t1_2_1", Yt[0]+15*0, Xt[0]+160, 23, 0);
      ObjectSetText("_Benefit_t1_2_1", "Profit: "+DoubleToStr(profitBuys, 2), 10, "Courier New", textColor);
      //ObjectCreateEx("_Benefit_t1_2_2", Yt[0]+15*1, Xt[0]+160, 23, 0);
      //ObjectSetText("_Benefit_t1_2_2", "StopOut: "+DoubleToStr(0, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t1_2_3", Yt[0]+15*1, Xt[0]+160, 23, 0);
      ObjectSetText("_Benefit_t1_2_3", "Уровень БУ: "+DoubleToStr(BuysBE, Digits), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t1_2_4", Yt[0]+15*2, Xt[0]+160, 23, 0);
      ObjectSetText("_Benefit_t1_2_4", "Lot Profit: "+DoubleToStr(historyProfitBuys/(AccountBalance()-historyProfitBuys)*100, 2)+"%", 10, "Courier New", textColor);
      
      double w1;
      double loclot=0;
      int next=Xt[0];
      int y=Yt[0];
      col2=textColor;
      string tStr="";
      for(i=0; i<16; i++)
      {
         j=i-Step_Coef_Start_Order_Buy+2;
         if(j<0) j=0;
         w1=Step_Buy*MathPow(Step_Coef_Buy, j);
         //if(i+1<Step_Coef_Start_Order-1) w1=Step;
         if(NO(Step_Coef_Buy)==0) w1=ParseStepMass(i+1, 0);
         ObjectCreateEx("_Benefit_t1_3_"+DoubleToStr(i, 0), y+15*5, next, 23, 0);
         col2=textColor;
         if(TotalOrders[0]>=i+1) col2=RoyalBlue; //Цвет открытых колен Бай
         dTemp=GetLot(0, i+1);
         loclot+=dTemp;
         //if(NO(loclot)>NO(maxlot)) col2=Black;
         ObjectSetText("_Benefit_t1_3_"+DoubleToStr(i, 0), "|"+DoubleToStr(w1, 0), 7, "Arial", col2);
         ObjectCreateEx("_Benefit_t1_3L_"+DoubleToStr(i, 0), y+15*6, next, 23, 0);
         ObjectSetText("_Benefit_t1_3L_"+DoubleToStr(i, 0), "|"+DoubleToStr(dTemp, 2), 7, "Arial", col2);
         /*if(w1<10) next+=10;
         if(w1>9 && w1<100) next+=13;
         if(w1>99 && w1<1000) next+=20;
         if(w1>999) */next+=27;
         //if(i==9) {next=Xt[0]; y+=15;}
      }
   }
   //=======================================(Table1 draw)
   
   
   //=======================================Table2 draw
   
   if(!IsTesting() || (IsTesting() && IsVisualMode()))
   {
      textColor=White;
      ObjectCreateEx("_Benefit_t2_body", Yt[1]-30, Xt[1]-5, 23, 0, true);
      ObjectSetText("_Benefit_t2_body", "ggg", 110, "Webdings", C'62,62,62');//Тело таблицы баев
      ObjectCreateEx("_Benefit_t2_Header", Yt[1]-25, Xt[1]+110, 23, 0);
      ObjectSetText("_Benefit_t2_Header", "SELL-SIDE", 16, "Dungeon", textColor);//Заголовок Sell
      //-------------------Первый столбец
      ObjectCreateEx("_Benefit_t2_1_1", Yt[1], Xt[1], 23, 0);
      ObjectSetText("_Benefit_t2_1_1", "Ордеров: "+DoubleToStr(sells, 0), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t2_1_2", Yt[1]+15, Xt[1], 23, 0);
      ObjectSetText("_Benefit_t2_1_2", "Объем: "+DoubleToStr(lotsSells, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t2_1_3", Yt[1]+15*2, Xt[1], 23, 0);
      ObjectSetText("_Benefit_t2_1_3", "Уровень ТП: "+DoubleToStr(SellsTP, Digits), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t2_1_4", Yt[1]+15*3, Xt[1], 23, 0);
      ObjectSetText("_Benefit_t2_1_4", "Уровень LTP:"+DoubleToStr(LOTSellsTP, Digits), 10, "Courier New", textColor);
      //-------------------Второй столбец
      ObjectCreateEx("_Benefit_t2_2_1", Yt[1]+15*0, Xt[1]+160, 23, 0);
      ObjectSetText("_Benefit_t2_2_1", "Profit: "+DoubleToStr(profitSells, 2), 10, "Courier New", textColor);
     // ObjectCreateEx("_Benefit_t2_2_2", Yt[0]+15*1, Xt[0]+160, 23, 0);
     // ObjectSetText("_Benefit_t2_2_2", "StopOut: "+DoubleToStr(0, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t2_2_3", Yt[1]+15*1, Xt[1]+160, 23, 0);
      ObjectSetText("_Benefit_t2_2_3", "Уровень БУ: "+DoubleToStr(/*AccountFreeMargin()*/SellsBE, Digits), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t2_2_4", Yt[1]+15*2, Xt[1]+160, 23, 0);
      ObjectSetText("_Benefit_t2_2_4", "Lot Profit: "+DoubleToStr(historyProfitSells/(AccountBalance()-historyProfitSells)*100, 2)+"%", 10, "Courier New", textColor);
      
       next=Xt[0];
       col2=textColor;
       
      y=Yt[1];
      loclot=0;
      dTemp=0;
      for(i=0; i<16; i++)
      {
         j=i-Step_Coef_Start_Order_Sell+2;
         if(j<0) j=0;
         w1=Step_Sell*MathPow(Step_Coef_Sell, j);
         //if(i+1<Step_Coef_Start_Order-1) w1=Step;
         if(NO(Step_Coef_Sell)==0) w1=ParseStepMass(i+1, 1);
         ObjectCreateEx("_Benefit_t2_3_"+DoubleToStr(i, 0), y+15*5, next, 23, 0);
         col2=textColor;
         if(TotalOrders[1]>=i+1) col2=Tomato; //Цвет открытых колен Селл
         dTemp=GetLot(1, i+1);
         loclot+=dTemp;
         //if(NO(loclot)>NO(maxlot)) col2=Black;
         ObjectSetText("_Benefit_t2_3_"+DoubleToStr(i, 0), "|"+DoubleToStr(w1, 0), 7, "Arial", col2);
         ObjectCreateEx("_Benefit_t2_3L_"+DoubleToStr(i, 0), y+15*6, next, 23, 0);
         ObjectSetText("_Benefit_t2_3L_"+DoubleToStr(i, 0), "|"+DoubleToStr(dTemp, 2), 7, "Arial", col2);
         /*if(w1<10) next+=10;
         if(w1>9 && w1<100) next+=13;
         if(w1>99 && w1<1000) next+=20;
         if(w1>999)*/ next+=27;
         //if(i==9) {next=Xt[0]; y+=15;}
      }
   }
   //=======================================(Table2 draw)
   
   
   //=======================================Table3 draw
   if(!IsTesting() || (IsTesting() && IsVisualMode()))
   {
      textColor=White;
      tStr="";
  
      ObjectCreateEx("_Benefit_t3_body", Yt[2]-30, Xt[2]-5, 23, 0, true);
      ObjectSetText("_Benefit_t3_body", "ggg", 110, "Webdings", C'62,62,62'); //Тело центровой таблицы 
      ObjectCreateEx("_Benefit_t3_Header", Yt[2]-25, Xt[2]+0, 23, 0);
      ObjectSetText("_Benefit_t3_Header", Symbol()+", M"+DoubleToStr(Period(), 0), 14, "Dungeon", textColor);
      
      string sbase = ":...:...:...:...:";
      int lenbase = StringLen(sbase);
      int sec = TimeCurrent()-Time[0];        // время в секундах от начала бара
      i = (lenbase-1)*sec/(Period()*60);  // позиция ползунка
      double pc = 100.0*sec/(Period()*60);       // время от начала бара в процентах
      if (i>lenbase-1) i = lenbase-1;     // возможно излишний контроль границы
      string s_beg="", s_end="";
      if (i>0) s_beg = StringSubstr(sbase,0,i);
      if (i<lenbase-1) s_end = StringSubstr(sbase,i+1,lenbase-i-1); if (pc>100) {pc=100;}
      s_end = StringConcatenate(s_beg,"|",s_end," ",DoubleToStr(pc,0),"%");
      ObjectCreateEx("_Benefit_t3_BarTimer", Yt[2]-25, Xt[2]+160, 23, 0);
      ObjectSetText("_Benefit_t3_BarTimer", s_end, 14, "Dungeon", textColor);
   
      //-------------------Первый столбец
      ObjectCreateEx("_Benefit_t3_1_1", Yt[2], Xt[2], 23, 0);
      tStr="VTP: ON"; 
      if(!VTP) tStr="VTP: OFF";
      ObjectSetText("_Benefit_t3_1_1", tStr, 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_1_2", Yt[2]+15, Xt[1], 23, 0);
      tStr="RRS: ON"; 
      if(!RRS) tStr="RRS: OFF";
      ObjectSetText("_Benefit_t3_1_2", tStr, 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_1_3", Yt[2]+15*2, Xt[2], 23, 0);
      ObjectSetText("_Benefit_t3_1_3", "СПРЕД: "+DoubleToStr((Ask-Bid)/Point, 0), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_1_4", Yt[2]+15*3, Xt[2], 23, 0);
      ObjectSetText("_Benefit_t3_1_4", "RRS BUY: "+DoubleToStr(Min_Lot_Buy, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_1_5", Yt[2]+15*4, Xt[2], 23, 0);
      ObjectSetText("_Benefit_t3_1_5", "RRS EXP BUY: "+DoubleToStr(Lot_Exp_Buy, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_1_6", Yt[2]+15*5, Xt[2], 23, 0);
      ObjectSetText("_Benefit_t3_1_6", "RRS SELL: "+DoubleToStr(Min_Lot_Sell, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_1_7", Yt[2]+15*6, Xt[2], 23, 0);
      ObjectSetText("_Benefit_t3_1_7", "RRS EXP SELL: "+DoubleToStr(Lot_Exp_Sell, 2), 10, "Courier New", textColor);
      //-------------------Второй столбец
      ObjectCreateEx("_Benefit_t3_2_1", Yt[2]+15*0, Xt[2]+160, 23, 0);
      ObjectSetText("_Benefit_t3_2_1", "Баланс: "+DoubleToStr(AccountBalance(), 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_2_2", Yt[2]+15*1, Xt[2]+160, 23, 0);
      ObjectSetText("_Benefit_t3_2_2", "Средства: "+DoubleToStr(AccountEquity(), 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_2_3", Yt[2]+15*2, Xt[2]+160, 23, 0);
      tStr="Просадка: 0%";
      if(AccountEquity()<AccountBalance()) tStr="Просадка: "+DoubleToStr((AccountBalance()-AccountEquity())*100/AccountBalance(), 2)+"%";
      ObjectSetText("_Benefit_t3_2_3", tStr, 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_2_4", Yt[2]+15*3, Xt[2]+160, 23, 0);
      ObjectSetText("_Benefit_t3_2_4", "PROFIT DAY: "+DoubleToStr(dayProfit, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_2_5", Yt[2]+15*4, Xt[2]+160, 23, 0);
      ObjectSetText("_Benefit_t3_2_5", "PROFIT WEEK: "+DoubleToStr(weekProfit, 2), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_2_6", Yt[2]+15*5, Xt[2]+160, 23, 0);
      dTemp=GetStopLevel(lotsBuys-lotsSells);
      ObjectSetText("_Benefit_t3_2_6", "StopOut Level: "+DoubleToStr(dTemp, Digits), 10, "Courier New", textColor);
      ObjectCreateEx("_Benefit_t3_2_7", Yt[2]+15*6, Xt[2]+160, 23, 0);
      tStr=" пунктов вверх";
      if(dTemp<Ask) tStr=" пунктов вниз";
      ObjectSetText("_Benefit_t3_2_7", "До слива "+DoubleToStr(MathAbs(dTemp-Ask)/Point, 0)+tStr, 10, "Courier New", textColor);
      
   }
   //=======================================(Table3 draw)
//==========================================(Info panel)
   
//==========================================Трейлинг
   if(VTP)
   {
      if(TotalOrders[0]>0 && Ask-BuysTP>Tral_Start && (TrallBuys<0 || Ask-Tral_Size>TrallBuys)) TrallBuys=Ask-Tral_Size;
      if(TotalOrders[1]>0 && SellsTP-Bid>Tral_Start && (TrallSells<0 || Bid+Tral_Size<TrallSells)) TrallSells=Bid+Tral_Size;
      
      if(RRS && TotalOrders[0]>=RRS_nOrder && Ask-LOTBuysTP>RRS_Tral_Start && (LotTrallBuys<0 || Ask-RRS_Tral_Size>LotTrallBuys)) LotTrallBuys=Ask-RRS_Tral_Size;
      if(RRS && TotalOrders[1]>=RRS_nOrder && LOTSellsTP-Bid>RRS_Tral_Start && (LotTrallSells<0 || Bid+RRS_Tral_Size<LotTrallSells)) LotTrallSells=Bid+RRS_Tral_Size;
      
      if(!IsTesting() || (IsTesting() && IsVisualMode()))
      {
         if(TrallBuys<0) 
           ObjectSet("_Benefit_BuyTrall",OBJPROP_PRICE1,0);
         else
           ObjectSet("_Benefit_BuyTrall",OBJPROP_PRICE1,TrallBuys);
           
         if(TrallSells<0) 
           ObjectSet("_Benefit_SellTrall",OBJPROP_PRICE1,0);
         else
           ObjectSet("_Benefit_SellTrall",OBJPROP_PRICE1,TrallSells);
           
         if(LotTrallBuys<0) 
           ObjectSet("_Benefit_BuyLOTTrall",OBJPROP_PRICE1,0);
         else
           ObjectSet("_Benefit_BuyLOTTrall",OBJPROP_PRICE1,LotTrallBuys);
           
         if(LotTrallSells<0) 
           ObjectSet("_Benefit_SellLOTTrall",OBJPROP_PRICE1,0);
         else
           ObjectSet("_Benefit_SellLOTTrall",OBJPROP_PRICE1,LotTrallSells);
      }
      
      if(Ask<TrallBuys && TrallBuys>0)
      {
         PutServiceOrder(4, MAGIC+1);
         return;
      }
      
      if(Bid>TrallSells && TrallSells>0)
      {
         PutServiceOrder(5, MAGIC+1);
         return;
      }
      
      if(Ask<LotTrallBuys && LotTrallBuys>0)
      {
         while(true)
         {
            if(!OrderSelect(Orders[0][0][0], SELECT_BY_TICKET)) continue;
            if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)) break;
         }
         
         while(true)
         {
            if(!OrderSelect(Orders[0][1][0], SELECT_BY_TICKET)) continue;
            if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)) break;
         }
         
         LotTrallBuys=-1;
      }
      
      if(Bid>LotTrallSells && LotTrallSells>0)
      {
         while(true)
         {
            if(!OrderSelect(Orders[1][0][0], SELECT_BY_TICKET)) continue;
            if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)) break;
         }
         
         while(true)
         {
            if(!OrderSelect(Orders[1][1][0], SELECT_BY_TICKET)) continue;
            if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)) break;
         }
         
         LotTrallSells=-1;
      }
      
   }
//==========================================(Трейлинг)

//==========================================Закрытие сетки если СЛ или ТП зацеплен(виртуально). И закрытие по RRS
   //BalanceBuy  = AccountBalance() - ProfitBuyN/*профит из истории*/;
   //if (RRS && (ProfitBuyN + profitbuy/*профит всех открытых баев*/)>=BalanceBuy *RRS_Profit_Percent/100)  closeBUYorders();
   
   if(RRS && (historyProfitBuys+profitBuys)>=(AccountBalance()-historyProfitBuys)*RRS_Profit_Percent/100)
   {
      PutServiceOrder(4, MAGIC+1);
      return;
   }
   
   if(RRS && (historyProfitSells+profitSells)>=(AccountBalance()-historyProfitSells)*RRS_Profit_Percent/100)
   {
      PutServiceOrder(5, MAGIC+1);
      return;
   }
   
  /* if(VTP)
   {
      if(NO(SellsTP)>0.0 && NO(Bid)<NO(SellsTP))
      {
         PutServiceOrder(5, MAGIC+1);
         return;
      }
      
      if(NO(BuysTP)>0.0 && NO(Ask)>NO(BuysTP))
      {
         PutServiceOrder(4, MAGIC+1);
         return;
      }
   }*/
    
//==========================================(Закрытие сетки если СЛ или ТП зацеплен(виртуально).

//Modify SL/TP of orders (for ECN)

   if(ECN && !VTP) 
     SetSLTPifNULL();
//

//==========================================Open orders
   if(Buy && TotalOrders[0]<Max_Trades)
   {
      op=Ask;
      if(NO(SL)!=0.0)sl=op-SL;else sl=0;
      if(NO(TP)!=0.0)tp=op+TP;else tp=0;
      if(ECN)
      {
         tp=0;
         sl=0;
      }
      
      lot=GetLot(0, TotalOrders[0]+1);
      if(OrderSend(Symbol(),0,Lots(lot),NO(op),Slippage,NO(sl),NO(tp),Symbol()+"_Benefit_Buy_"+DoubleToStr(TotalOrders[0]+1, 0),MAGIC,0, DarkBlue)<0)
        ObjectSetText("_Benefit_error","Can\'t open Buy. Error - "+DoubleToStr(GetLastError(),0)+" "+DoubleToStr(op,Digits)+" "+DoubleToStr(sl,Digits)+" "+DoubleToStr(tp,Digits),14,"Tahoma",Red);
   }
 
   if(Sell && TotalOrders[1]<Max_Trades)
   {
      op=Bid;
      if(NO(SL)!=0.0)sl=op+SL;else sl=0;
      if(NO(TP)!=0.0)tp=op-TP;else tp=0;
      if(ECN)
      {
         tp=0;
         sl=0;
      }
      
      lot=GetLot(1, TotalOrders[1]+1);
      if(OrderSend(Symbol(),1,Lots(lot),NO(op),Slippage,NO(sl),NO(tp),Symbol()+"_Benefit_Sell_"+DoubleToStr(TotalOrders[1]+1, 0),MAGIC,0, Red)<0)
        ObjectSetText("_Benefit_error","Can\'t open Sell. Error - "+DoubleToStr(GetLastError(),0)+" "+DoubleToStr(op,Digits)+" "+DoubleToStr(sl,Digits)+" "+DoubleToStr(tp,Digits),14,"Tahoma",Red);
   }
//==========================================(Open orders)
}

bool TradeWasInTime(int timeOfTrade)
{
   if(!Time_Filters)
     return(true);
      
   int TimeH=TimeHour(timeOfTrade);
   int TimeM=TimeMinute(timeOfTrade);
   
    
   int h1=StrToInteger(StringSubstr(Trading_Time_1_Start, 0, 2));
   int m1=StrToInteger(StringSubstr(Trading_Time_1_Start, 3, 2));
   int h2=StrToInteger(StringSubstr(Trading_Time_1_End, 0, 2));
   int m2=StrToInteger(StringSubstr(Trading_Time_1_End, 3, 2));
   if((TimeH>h1 || (TimeH==h1 && TimeM>=m1)) && (TimeH<h2 || (TimeH==h2 && TimeM<m2)))
     if(Trading_Time_1_Start!=Trading_Time_1_End)
       return(true);
 
   h1=StrToInteger(StringSubstr(Trading_Time_2_Start, 0, 2));
   m1=StrToInteger(StringSubstr(Trading_Time_2_Start, 3, 2));
   h2=StrToInteger(StringSubstr(Trading_Time_2_End, 0, 2));
   m2=StrToInteger(StringSubstr(Trading_Time_2_End, 3, 2));
   if((TimeH>h1 || (TimeH==h1 && TimeM>=m1)) && (TimeH<h2 || (TimeH==h2 && TimeM<m2)))
     if(Trading_Time_1_Start!=Trading_Time_1_End)
        return(true);

   return(false);
}

double GetStopLevel(double dLots) //разность лотов бай-селл
{
   if(NO(dLots)==0.0) return(0);
   double freemargin = AccountFreeMargin();                               //имеющиеся на счету свободных средств
   double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);               //цена одного пункта
   double equity = AccountEquity();                                       //имеющиеся на счету средства
   double stop_out = AccountStopoutLevel();                               //Stop Out (принудительное закрытие позиций)
   
   double dZM = freemargin / (tickvalue * dLots);       //расстояние от цены до уровня нулевой маржи
   double dZF = equity / (tickvalue * dLots);           //расстояние от цены до полного слива
   double dDZ = dZF - dZM;                              //размер "мертвой" зоны
   double dSO = dZF - dDZ * stop_out / 100;             //расстояние от цены до уровня принудительного закрытия ордеров
   double UrSO;
   
   if (dLots > 0) UrSO = Bid - dSO * Point;      //значение уровня принудительного закрытия ордеров - StopOut
   if (dLots < 0) UrSO = Ask - dSO * Point;      //значение уровня принудительного закрытия ордеров - StopOut
  
   if(dLots != 0.0) 
     return(UrSO);

}

double GetLot(int posType, int orderNumber)
{
   double llot=0;
   
   if(posType==0)
   { 
      llot=Min_Lot_Buy*MathPow(Lot_Exp_Buy, orderNumber-2);
      if(orderNumber<=2) llot=Min_Lot_Buy;
   }
   
   if(posType==1)
   { 
      llot=Min_Lot_Sell*MathPow(Lot_Exp_Sell, orderNumber-2);
      if(orderNumber<=2) llot=Min_Lot_Sell;
   }
   return(llot);
}

bool PutServiceOrder(int orderType, int mmagic)
{
   double op, sl, tp;
   double priceRange=500;
   
   if(orderType==2)
   {
      op=Ask-priceRange*Point*x;
      sl=op-25*Point*x;
      tp=op+25*Point*x;
      if(ECN) {sl=0;tp=0;}
      if(OrderSend(Symbol(),2,MarketInfo(Symbol(),MODE_MINLOT),NO(op),3,NO(sl),NO(tp),"",mmagic)<0)
        ObjectSetText("_Benefit_error","Can\'t open Close grid Order. Error - "+DoubleToStr(GetLastError(),0)+" "+DoubleToStr(op,Digits)+" "+DoubleToStr(sl,Digits)+" "+DoubleToStr(tp,Digits),14,"Tahoma",Red);
   }
   
   if(orderType==5)
   {
      op=Ask-priceRange*Point*x;
      sl=op+25*Point*x;
      tp=op-25*Point*x;
      if(ECN){sl=0;tp=0;}
      if(OrderSend(Symbol(),5,MarketInfo(Symbol(),MODE_MINLOT),NO(op),3,NO(sl),NO(tp),"",mmagic)<0)
         ObjectSetText("_Benefit_error","Can\'t open Close grid Order. Error - "+DoubleToStr(GetLastError(),0)+" "+DoubleToStr(op,Digits)+" "+DoubleToStr(sl,Digits)+" "+DoubleToStr(tp,Digits),14,"Tahoma",Red);
   }
   
   if(orderType==4)
   {
      op=Ask+priceRange*Point*x;
      sl=op-25*Point*x;
      tp=op+25*Point*x;
      if(ECN){sl=0;tp=0;}
      if(OrderSend(Symbol(),4,MarketInfo(Symbol(),MODE_MINLOT),NO(op),3,NO(sl),NO(tp),"",mmagic)<0)
         ObjectSetText("_Benefit_error","Can\'t open Close grid Order. Error - "+DoubleToStr(GetLastError(),0)+" "+DoubleToStr(op,Digits)+" "+DoubleToStr(sl,Digits)+" "+DoubleToStr(tp,Digits),14,"Tahoma",Red);
   }
}

double PointCost(double lotes)
{
   double StoimTik=MarketInfo(Symbol(),MODE_TICKVALUE)/(MarketInfo(Symbol(),MODE_TICKSIZE)/MarketInfo(Symbol(),MODE_POINT))/100;
   double count=NormalizeDouble(lotes/0.01,2);
   double value=NormalizeDouble(count*StoimTik,2);
   if(NO(value)==0.00) value=0.01;
   return(value);
}

double ParseStepMass(int till, int type)
{
   if(till==0) return(0);
   
   int pos=0, newPos=0;
   int step=0;
   string mass=Step_Mass_Buy+",";
   if(type==1) mass=Step_Mass_Sell+",";
   
   for(int i=1; i<=till; i++)
   {
      pos=StringFind(mass, ",", newPos);
      if(pos<0) break;
      step=StrToDouble(StringSubstr(mass, newPos, pos-newPos));
      newPos=pos+1;
   }
   
   if(step<=0) Alert("Ошибка! Step=0");
   
   return(step);
}

bool ThereIsOrderOnThisBar(int barTime, int orType)
{
   for(int i=OrdersTotal()-1;i>=0;i--)
     if(OrderSelect(i,SELECT_BY_POS) && OrderMagicNumber()==MAGIC && OrderSymbol()==Symbol())
     {
        if(OrderType()!=orType) continue;
        if(OrderOpenTime()>=barTime) return(true);
     }
   
   return(false);  
}

//+-------------------------------------------------------------------+
//| Function sets SL/TP for orders if them equal 0. (for ECN Brokers) |
//+-------------------------------------------------------------------+
bool SetSLTPifNULL()
{
   double op,sl,tp;
   for(int i=0;i<TotalOrders[0];i++)
    if(OrderSelect(DtI(Orders[0][i][0]), SELECT_BY_TICKET))
    {
       if(RRS && i<2 && TotalOrders[0]>=RRS_nOrder)
         tp=LOTBuysTP;
       else       
         tp=BuysTP;
       
       if(NO(sl)!=NO(OrderStopLoss()) || NO(tp)!=NO(OrderTakeProfit()))
         OrderModify(OrderTicket(),OrderOpenPrice(),NO(sl),NO(tp),0);
    }
   
   for(i=0;i<TotalOrders[1];i++)
    if(OrderSelect(DtI(Orders[1][i][0]), SELECT_BY_TICKET))
    {
       if(RRS && i<2 && TotalOrders[1]>=RRS_nOrder)
         tp=LOTSellsTP;
       else       
         tp=SellsTP;
       
       if(NO(sl)!=NO(OrderStopLoss()) || NO(tp)!=NO(OrderTakeProfit()))
         OrderModify(OrderTicket(),OrderOpenPrice(),NO(sl),NO(tp),0);
    }
}

double NO(double pp){return(NormalizeDouble(pp,Digits));}

//+-------------------------------------------------------------------+
//| Returns normalized Lot amount                                     |
//+-------------------------------------------------------------------+
double Lots(double initialLot)
{
   double lot;
   if(initialLot==-1)
     return(-1);
   lot=NormalizeDouble(initialLot,2);
   //double ostatok=MathMod(lot,MarketInfo(Symbol(),MODE_LOTSTEP));
   //if(NO(ostatok)!=0.0)lot=lot-ostatok;
   lot=MathMin(MarketInfo(Symbol(),MODE_MAXLOT),lot);
   lot=MathMax(MarketInfo(Symbol(),MODE_MINLOT),lot);
   
  // if(MarketInfo(Symbol(),MODE_MINLOT)>Lot)
    // {Alert(Symbol()+" Minimal allowed lot="+MarketInfo(Symbol(),MODE_MINLOT)+" more than Lot="+Lot);return(-1);}
   if(lot>Max_Lot) lot=Max_Lot;
   return(NormalizeDouble(lot,2));
}

int DtI(double digit)
{
   return(StrToInteger(DoubleToStr(digit,0)));
}

int deinit()
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string oName=ObjectName(i);
      if(StringFind(oName, "_Benefit")>-1)
        ObjectDelete(oName);
   }  
}