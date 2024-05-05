BÀI 1:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(OrdersTotal()>0){return;}
      
      OrderSend(  Symbol(),OP_BUY,0.01,Ask,20,0,0,NULL,0,0,clrNONE );
      
     
      
      
  }
//+------------------------------------------------------------------+

BÀI 2:

//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      
       double khoiLuong;  
      khoiLuong = 0.1;
      double stoploss = 1.2927;
      double takeprofit = 1.28;
      string ghichu =  "hello";
      color maucualenh = clrRed;
      
      string sym = "USDJPY";
      
      int loaiLenh;      loaiLenh = OP_SELL;
      
      
     
    
      
     
      OrderSend(  sym,loaiLenh,khoiLuong,Bid,20,stoploss,takeprofit,ghichu,0,0,maucualenh );
      
   
      
      
  }
//+------------------------------------------------------------------+

BÀI 3:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


      extern double khoiLuong= 0.01;       
      double stoploss = 0;
      double takeprofit = 0;
    extern  string ghichu =  "hello";
      color maucualenh = clrRed;
      
     
      
     extern int loaiLenh = OP_BUY; 
     
      
      double giavaolenh=0; 


//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      
      
       
   //khoiLuong = 0.01;
      
      if(loaiLenh == OP_SELL){ giavaolenh = Bid;}
      if(loaiLenh ==OP_BUY){giavaolenh = Ask;}
  // Print(loaiLenh+"/"+giavaolenh);
      
      
     
      OrderSend(  Symbol(),loaiLenh,khoiLuong,giavaolenh,20,0,0,ghichu,0,0,maucualenh );
      
   
      
      
  }
//+------------------------------------------------------------------+

BÀI 4:

//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


      extern double khoiLuong= 0.01;       
      double stoploss = 0;
      double takeprofit = 0;
      extern  string ghichu =  "hello";
      color maucualenh = clrRed;
      extern int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;

//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- 
 
      if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
    //  if(iTime(Symbol(),15,0) == thoigiangiaodich){return;}  thoigiangiaodich = iTime(Symbol(),15,0);
 
      if( Close[1]>Open[1] ){ loaiLenh = OP_BUY; }
       if(Close[1]<Open[1] ){     loaiLenh= OP_SELL; }
    
      if(loaiLenh == OP_SELL)
      { 
         giavaolenh = Bid;
         stoploss = giavaolenh + 20*10*Point();
         takeprofit = giavaolenh - 60*10*Point();
      }
      if(loaiLenh ==OP_BUY)
      {
         giavaolenh = Ask;
         stoploss = giavaolenh - 20*10*Point();
         takeprofit = giavaolenh + 60*10*Point();
      }
      
      OrderSend(  Symbol(),loaiLenh,khoiLuong,giavaolenh,20,stoploss,takeprofit,ghichu,0,0,maucualenh );
  }
//+------------------------------------------------------------------+

BÀI 5:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


      extern double khoiLuong= 0.01;// 0       
      double stoploss = 0;
      double takeprofit = 0;
      extern  string ghichu =  "hello";
      color maucualenh = clrRed;
      extern int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |

//khai báo hàm ở đây
//+------------------------------------------------------------------+
void OnTick()
  {
//--- 
    /*  tinhlotsize();
      checkDKvaolenh();
      dinhdangLot();
      vaolenh();*/
      
      if(chophepGD == false){return;}
      if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
    //  if(iTime(Symbol(),15,0) == thoigiangiaodich){return;}  thoigiangiaodich = iTime(Symbol(),15,0);
 
      if( Close[1]>Open[1] ){ loaiLenh = OP_BUY; }
       if(Close[1]<Open[1] ){     loaiLenh= OP_SELL; }
    
      if(loaiLenh == OP_SELL)
      { 
         giavaolenh = Bid;
         stoploss = giavaolenh + 20*10*Point();
         takeprofit = giavaolenh - 60*10*Point();
      }
      if(loaiLenh ==OP_BUY)
      {
         giavaolenh = Ask;
         stoploss = giavaolenh - 20*10*Point();
         takeprofit = giavaolenh + 60*10*Point();
      }
   
      khoiLuong = dinhdangLot();
                     
      OrderSend(  Symbol(),loaiLenh,khoiLuong,giavaolenh,20,stoploss,takeprofit,ghichu,0,0,maucualenh );
  }
//+------------------------------------------------------------------+

double dinhdangLot()
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
  //  bằng 0 --> lot nhỏ nhất chấp nhận 0.01    0.001  0.1
    
    //9000 lot --> 50 lot  sô lot lớn nhất dc chấp nhận.
    
    //0.014875  -->  0.01 0.02
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}

//======================================================
void checkLisicen()
{
   
   if(AccountNumber() != 22629828 ){Alert("khong dung tai khoan");chophepGD= false;}
   
   if(AccountEquity()  < 1000 ){ Comment("tai khoan qua nho , rui ro cao"); }
   
   if(IsTradeAllowed() ==false   ){ Alert("hay click vao trade allow");}
   
}
//==========================================


BÀI 6:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


      extern double khoiLuong= 0.01;// 0       
      double stoploss = 0;
      double takeprofit = 0;
      extern  string ghichu =  "hello";
      color maucualenh = clrRed;
      extern int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  // checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     // if(chophepGD == false){return;}
    //  if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      if(demsolenh( Symbol() ) >0 ){return;}
      
      // cho chạy code ben dưới dòng này khi qua nến mới 
      
      if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
//=====================================================================      
// dieu kien vao lenh-------------- 
  
     double maxanh1 = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,1);
     double mado1   = iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,1);
     double maxanh2 = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,2);
     double mado2   = iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,2);
     // truong hop cat len tang gia --> buy
     if(maxanh1 > mado1 && maxanh2 < mado2 ){loaiLenh=OP_BUY;}
     if(maxanh1 < mado1 && maxanh2 > mado2 ){loaiLenh=OP_SELL;}
     

       //=====================================================
 //--------------------------------
      if(loaiLenh == OP_SELL)
      { 
         giavaolenh = Bid;
         stoploss = giavaolenh + 20*10*Point();
         takeprofit = giavaolenh - 60*10*Point();
      }
      if(loaiLenh ==OP_BUY)
      {
         giavaolenh = Ask;
         stoploss = giavaolenh - 20*10*Point();
         takeprofit = giavaolenh + 60*10*Point();
      }
   
      khoiLuong = dinhdangLot(khoiLuong);
                     
      OrderSend(  Symbol(),loaiLenh,khoiLuong,giavaolenh,20,stoploss,takeprofit,ghichu,magic,0,maucualenh );
  }
//+------------------------------------------------------------------+


//======================================================
void checkLisicen()
{
   
   if(AccountNumber() != 22629828 ){Alert("khong dung tai khoan");chophepGD= false;}
   
   if(AccountEquity()  < 1000 ){ Comment("tai khoan qua nho , rui ro cao"); }
   
   if(IsTradeAllowed() ==false   ){ Alert("hay click vao trade allow");}
   
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+


BÀI 8:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


      extern double khoiLuong= 0.01;// 0       
      double stoploss = 0;
      double takeprofit = 0;
      extern  string ghichu =  "hello";
      color maucualenh = clrRed;
      extern int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  // checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     // if(chophepGD == false){return;}
    //  if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      if(demsolenh( Symbol() ) >0 ){return;}
      
      // cho chạy code ben dưới dòng này khi qua nến mới 
      
      if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
//=====================================================================      
// dieu kien vao lenh-------------- 
  
  laygiatrinen();
  
     double maxanh1 = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,1);
     double mado1   = iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,1);
     double maxanh2 = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,2);
     double mado2   = iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,2);
     // truong hop cat len tang gia --> buy
     if(maxanh1 > mado1 && maxanh2 < mado2 ){loaiLenh=OP_BUY;}
     if(maxanh1 < mado1 && maxanh2 > mado2 ){loaiLenh=OP_SELL;}
     

       //=====================================================
 //--------------------------------
      if(loaiLenh == OP_SELL)
      { 
         giavaolenh = Bid;
         stoploss = giavaolenh + 20*10*Point();
         takeprofit = giavaolenh - 60*10*Point();
      }
      if(loaiLenh ==OP_BUY)
      {
         giavaolenh = Ask;
         stoploss = giavaolenh - 20*10*Point();
         takeprofit = giavaolenh + 60*10*Point();
      }
   
      khoiLuong = dinhdangLot(khoiLuong);
                     
      OrderSend(  Symbol(),loaiLenh,khoiLuong,giavaolenh,20,stoploss,takeprofit,ghichu,magic,0,maucualenh );
  }
//+------------------------------------------------------------------+

void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/




}
//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
   
   if(AccountNumber() != 22629828 ){Alert("khong dung tai khoan");chophepGD= false;}
   
   if(AccountEquity()  < 1000 ){ Comment("tai khoan qua nho , rui ro cao"); }
   
   if(IsTradeAllowed() ==false   ){ Alert("hay click vao trade allow");}
   
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+

BÀI 9:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


      extern double khoiLuong= 0.01;// 0       
      double stoploss = 20;
      double takeprofit = 40;
      extern  string Com   ;
      color maucualenh = clrRed;
      extern int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  // checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { string sym;
     // if(chophepGD == false){return;}
    //  if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      if(demsolenh( Symbol() ) >0 ){return;}
      // cho chạy code ben dưới dòng này khi qua nến mới 
      if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
//=====================================================================      
// dieu kien vao lenh-------------- 
//  laygiatrinen();
     double maxanh1 = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,1);
     double mado1   = iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,1);
     double maxanh2 = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,2);
     double mado2   = iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,2);
     // truong hop cat len tang gia --> buy
     if(maxanh1 > mado1 && maxanh2 < mado2 ){loaiLenh=OP_BUY;}
     if(maxanh1 < mado1 && maxanh2 > mado2 ){loaiLenh=OP_SELL;}
     
 //--------------------------------VAO LENH------------------
     vaoLenh(Symbol(),loaiLenh,khoiLuong,0,stoploss,takeprofit,magic,Com);
     
     /*
      if(loaiLenh == OP_SELL)
      { 
         giavaolenh = Bid;
         stoploss = giavaolenh + 20*10*Point();
         takeprofit = giavaolenh - 60*10*Point();
      }
      if(loaiLenh ==OP_BUY)
      {
         giavaolenh = Ask;
         stoploss = giavaolenh - 20*10*Point();
         takeprofit = giavaolenh + 60*10*Point();
      }
   
      khoiLuong = dinhdangLot(khoiLuong);
                     
      OrderSend(  Symbol(),loaiLenh,khoiLuong,giavaolenh,20,stoploss,takeprofit,ghichu,magic,0,maucualenh );
  */
  }
//+------------------------------------------------------------------+
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
  /*
  ECN  - LIEN NGAN HANG
  STP - LIEN NGAN HANG 
  1 , GUI LENH DI 
  2 , CHINH SUA SL TP
  
  OM LENH - OM LENH */

}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
   
   if(AccountNumber() != 22629828 ){Alert("khong dung tai khoan");chophepGD= false;}
   
   if(AccountEquity()  < 1000 ){ Comment("tai khoan qua nho , rui ro cao"); }
   
   if(IsTradeAllowed() ==false   ){ Alert("hay click vao trade allow");}
   
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+

BÀI 10:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
      double takeprofit = 40;
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       extern double risk = 5;
     extern double stoploss = 20;
 string sym;
//+------------------------------------------------------------------+
int OnInit()
  {
//---
       sym=Symbol();

  // checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
        // cho chạy code ben dưới dòng này khi qua nến mới 
    //  if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
     // if(chophepGD == false){return;}
     //if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 

//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
    //iWPR
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,magic,Com);
   
  }// end ontick
  //=====================================
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balance);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
  /*
  ECN  - LIEN NGAN HANG
  STP - LIEN NGAN HANG 
  1 , GUI LENH DI 
  2 , CHINH SUA SL TP
  
  OM LENH - OM LENH */

}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
   
   if(AccountNumber() != 22629828 ){Alert("khong dung tai khoan");chophepGD= false;}
   
   if(AccountEquity()  < 1000 ){ Comment("tai khoan qua nho , rui ro cao"); }
   
   if(IsTradeAllowed() ==false   ){ Alert("hay click vao trade allow");}
   
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+

BÀI 11:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
      double takeprofit = 40;
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       extern double risk = 5;
     extern double stoploss = 20;
 string sym;
//+------------------------------------------------------------------+
int OnInit()
  {
//---
       sym=Symbol();

  // checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
        // cho chạy code ben dưới dòng này khi qua nến mới 
    //  if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
     // if(chophepGD == false){return;}
     //if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 

//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
    //iWPR
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,magic,Com);
   
  }// end ontick
  //=====================================
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balance);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
  /*
  ECN  - LIEN NGAN HANG
  STP - LIEN NGAN HANG 
  1 , GUI LENH DI 
  2 , CHINH SUA SL TP
  
  OM LENH - OM LENH */

}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
   
   if(AccountNumber() != 22629828 ){Alert("khong dung tai khoan");chophepGD= false;}
   
   if(AccountEquity()  < 1000 ){ Comment("tai khoan qua nho , rui ro cao"); }
   
   if(IsTradeAllowed() ==false   ){ Alert("hay click vao trade allow");}
   
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+

BÀI 12:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
      double takeprofit = 40;
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 20;
     extern string giobatdau = "06:30";
     extern string giokethuc = "09:15";
 string sym;
 bool  active = false;
//+------------------------------------------------------------------+
int OnInit()
  {
//---
       sym=Symbol();

   checkLisicen();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
        // cho chạy code ben dưới dòng này khi qua nến mới 
    //  if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
     // if(chophepGD == false){return;}
     //if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
     if(active ==false){return;}
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 

//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
    //iWPR
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,magic,Com);
   
  }// end ontick
  //=====================================
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balance);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
  /*
  ECN  - LIEN NGAN HANG
  STP - LIEN NGAN HANG 
  1 , GUI LENH DI 
  2 , CHINH SUA SL TP
  
  OM LENH - OM LENH */

}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+

BÀI 13:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
      double takeprofit = 40;
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 20;
     extern string giobatdau = "06:30";
     extern string giokethuc = "09:15";
 string sym;
 bool  active = false;
//+------------------------------------------------------------------+
int OnInit()
  {
//---
       sym=Symbol();
   checkLisicen();
   SendNotification("hello thinh");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
        // cho chạy code ben dưới dòng này khi qua nến mới 
    //  if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
     // if(chophepGD == false){return;}
     //if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
     if(active ==false){return;}
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 

//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);

   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
   Comment(khoiLuong);
   ObjectCreate
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
    //iWPR
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,magic,Com);
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );
   
  }// end ontick
  //=====================================
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balance);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
  /*
  ECN  - LIEN NGAN HANG
  STP - LIEN NGAN HANG 
  1 , GUI LENH DI 
  2 , CHINH SUA SL TP
  
  OM LENH - OM LENH */

}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+

BÀI 14:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  Magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 50;
     extern  double takeprofit = 100;

     extern double  Trailling_pip = 10;
 string sym;
 
 
 bool  active = false;
 datetime ngayhethan = D'2020.08.01 00:00:00';  
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //kiem tra ban quyen --> active --> true
  // if( TimeCurrent() < ngayhethan    ){active = true;}
   
  //if(  IsDemo() == true ){ active = true;} 
  
  //if( IsDemo() == false && TimeCurrent() < ngayhethan    ){active = true;}// gioi han thoi gian su dung tk real
   
  if(  AccountNumber()  == "22631568"  ){active= true;}
  
  if(active == false ){  Alert("vui long lien he thinhle.free@gmail.com de lay duoc ban quyen day du"); }
  
  if( IsTradeAllowed() == false    ){Alert("hay bam F7, chon tab Common/ allow live trading");}
       sym=Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
  if(active ==false){return;}
        // cho chạy code ben dưới dòng này khi qua nến mới 
    //  if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}thoigiangiaodich =iTime(Symbol(),0,0) ;
     // if(chophepGD == false){return;}
     //if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
     
      Trailling(Trailling_pip) ;
      
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 

//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);

   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
    //iWPR
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,Magic,Com);
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );
   
  }// end ontick
  //=====================================
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balancee);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);//Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int Magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,Magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+
void Trailling(double trail) 
{
   double  NewSL; trail*= 10*Point;   // trail  = trail * 10*10*Point
   for(int i = OrdersTotal()-1; i >=0 ; i--) //OrdersHistoryTotal()
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;} //Neu khong tim duoc lenh thi tiep tuc lap
      
      if (OrderSymbol() != Symbol())         {continue;}
      if (OrderMagicNumber() != Magic) {continue;}
      
      if (OrderType() == OP_BUY) {NewSL = Ask - trail;}
      else if (OrderType() == OP_SELL) {NewSL = Bid + trail;}

      if (OrderType() == OP_BUY && OrderStopLoss()>=NewSL ) {continue;}
      if (OrderType() == OP_SELL && OrderStopLoss()<=NewSL) {continue;}
      Comment(NewSL);
      
      OrderModify(OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,CLR_NONE);
      if(GetLastError()!=0 && GetLastError()!=1) {Print("Loi Trailling: " + GetLastError());}
   }   
}

BÀI 15:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  Magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 50;
     extern  double takeprofit = 100;

     extern double  Trailling_pip = 10;
 string sym;
 
 
 bool  active = false;
 datetime ngayhethan = D'2020.08.01 00:00:00';  
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //kiem tra ban quyen --> active --> true
  // if( TimeCurrent() < ngayhethan    ){active = true;}
   
  //if(  IsDemo() == true ){ active = true;} 
  
  //if( IsDemo() == false && TimeCurrent() < ngayhethan    ){active = true;}// gioi han thoi gian su dung tk real
   
  if(  AccountNumber()  == "22631568"  ){active= true;}
  
  if(active == false ){  Alert("vui long lien he thinhle.free@gmail.com de lay duoc ban quyen day du"); }
  
  if( IsTradeAllowed() == false    ){Alert("hay bam F7, chon tab Common/ allow live trading");}
      
      
       sym=Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
  if(active ==false){return;}
        // cho chạy code ben dưới dòng này khi qua nến mới 
   if(IsTesting() == false || IsOptimization() == false )
         {  
            if(thoigiangiaodich == iTime(Symbol(),PERIOD_M1,0) ){return;}
            thoigiangiaodich =iTime(Symbol(),PERIOD_M1,0) ;
         }
     if(IsTesting() == true|| IsOptimization()  == false) 
     {
            if(thoigiangiaodich == iTime(Symbol(),0,0) ){return;}
            thoigiangiaodich =iTime(Symbol(),0,0) ;
     }
     // if(chophepGD == false){return;}
     //if(OrdersTotal()>0){return;}  // chi cho vao 1 lenh
     
      Trailling(Trailling_pip) ;
      
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 

//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);

   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
    //iWPR
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,Magic,Com);
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );
   
  }// end ontick
  //=====================================
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balancee);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);//Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int Magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,Magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+
void Trailling(double trail) 
{
   double  NewSL; trail*= 10*Point;   // trail  = trail * 10*10*Point
   for(int i = OrdersTotal()-1; i >=0 ; i--) //OrdersHistoryTotal()
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;} //Neu khong tim duoc lenh thi tiep tuc lap
      
      if (OrderSymbol() != Symbol())         {continue;}
      if (OrderMagicNumber() != Magic) {continue;}
      
      if (OrderType() == OP_BUY) {NewSL = Ask - trail;}
      else if (OrderType() == OP_SELL) {NewSL = Bid + trail;}

      if (OrderType() == OP_BUY && OrderStopLoss()>=NewSL ) {continue;}
      if (OrderType() == OP_SELL && OrderStopLoss()<=NewSL) {continue;}
      Comment(NewSL);
      
      OrderModify(OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,CLR_NONE);
      if(GetLastError()!=0 && GetLastError()!=1) {Print("Loi Trailling: " + GetLastError());}
   }   
}


BÀI 16:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  Magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 500;
     extern  double takeprofit = 1000;

     extern double  Trailling_pip = 10;
 string sym;
 
 
 bool  active = true;
 datetime ngayhethan = D'2020.08.01 00:00:00';  
//+------------------------------------------------------------------+
int OnInit()
  {
       sym=Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
      if(active ==false){return;}
        // cho chạy code ben dưới dòng này khi qua nến mới 
     // Trailling(Trailling_pip) ;
      if(demsolenh( sym ) >0 ){return;}
//===================================================================== 
//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,Magic,Com);
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );
 
 //==============================================
   double kiemtra =   check_dk_donglenh();
    // 0--> close buy , 1-->  close sell , -- >-1  ko lam gi ca , 3--> close all
   Comment("bien kiem tra = "+kiemtra );
   if(kiemtra == OP_BUY )
   { 
      DONGLENH_theo_type(OP_BUY);
   }
   if(kiemtra == OP_SELL )
   { 
      DONGLENH_theo_type(OP_SELL);
   }
   if(kiemtra == 3 )
   { 
      DONGLENH_ToanBo();
   }
   
   
   
  }// end ontick
  //=====================================
  
double check_dk_donglenh()
  {
      double kq =-1;
      double rsi = iRSI(Symbol(),0,21,PRICE_CLOSE,0);
      if(rsi > 70){kq =0; } //kq = OP_BUY;
      if(rsi < 30){kq =1 ;} //kq = OP_SELL;
      if( rsi > 90 || rsi < 10  ){kq = 3;}
  
      return (kq);
  }
  
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balancee);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);//Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int Magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,Magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+
void Trailling(double trail) 
{
   double  NewSL; trail*= 10*Point;   // trail  = trail * 10*10*Point
   for(int i = OrdersTotal()-1; i >=0 ; i--) //OrdersHistoryTotal()
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;} //Neu khong tim duoc lenh thi tiep tuc lap
      
      if (OrderSymbol() != Symbol())         {continue;}
      if (OrderMagicNumber() != Magic) {continue;}
      
      if (OrderType() == OP_BUY) {NewSL = Ask - trail;}
      else if (OrderType() == OP_SELL) {NewSL = Bid + trail;}

      if (OrderType() == OP_BUY && OrderStopLoss()>=NewSL ) {continue;}
      if (OrderType() == OP_SELL && OrderStopLoss()<=NewSL) {continue;}
      Comment(NewSL);
      
      OrderModify(OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,CLR_NONE);
      if(GetLastError()!=0 && GetLastError()!=1) {Print("Loi Trailling: " + GetLastError());}
   }   
}
//====================================================================   
void DONGLENH_ToanBo()
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()<2)  {DongLenh_Ticket(OrderTicket(), OrderLots());}
      else {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DONGLENH_theo_type(int op1)
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if( OrderType()>=2)                                 {continue;}
      if (OrderType()==op1) {DongLenh_Ticket(OrderTicket(), OrderLots());}
   }
}


void DONGLENH_motphan(int op1,double lot)
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
    //  if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()==op1)  {DongLenh_Ticket(OrderTicket(), lot);}
      //if ((OrderType()==op1||OrderType()==op2)&& OrderType()>2) {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DongLenh_Ticket(int ticket, double lott) 
{
  int Slippage = 3;
  if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {return;}
  if(lott==0){lott=OrderLots();}
  if(OrderType()>1){ OrderDelete(OrderTicket(),CLR_NONE);}
  if(OrderType()<=1)
  { 
  double priice; RefreshRates();
    if (OrderType() == OP_BUY) {priice = MarketInfo(OrderSymbol(),MODE_BID);}
     else {priice = MarketInfo(OrderSymbol(),MODE_ASK);}
    OrderClose(ticket, lott, priice, Slippage, Gold);
   // Sleep(100); 
  }  
  return;
}


BÀI 17:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY;
      double giavaolenh=0;
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  Magic =999;

       double lastLotsize ;
       int lasttype;

       double balance;// acc

       extern double risk = 5;
     extern double stoploss = 500;
     extern  double takeprofit = 1000;

     extern double  Trailling_pip = 10;
 string sym;


 bool  active = true;
 datetime ngayhethan = D'2020.08.01 00:00:00';
//+------------------------------------------------------------------+
int OnInit()
  {
       sym=Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      if(active ==false){return;}
        // cho chạy code ben dưới dòng này khi qua nến mới
     // Trailling(Trailling_pip) ;
     
//=====================================================================
//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh--------------
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
 //--------------------------------VAO LENH------------------
    if(demsolenh( sym ) ==0 ){  vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,Magic,Com);}
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );

 //==============================================
   double kiemtra =   check_dk_donglenh();
    // 0--> close buy , 1-->  close sell , -- >-1  ko lam gi ca , 3--> close all
   Comment("bien kiem tra = "+kiemtra );
   if(kiemtra == OP_BUY )
   {
      DONGLENH_theo_type(OP_BUY);
   }
   if(kiemtra == OP_SELL )
   {
      DONGLENH_theo_type(OP_SELL);
   }
   if(kiemtra == 3 )
   {
      DONGLENH_ToanBo();
   }



  }// end ontick
  //=====================================

double check_dk_donglenh()
  {
      double kq =-1;
      double rsi = iRSI(Symbol(),0,21,PRICE_CLOSE,0);
      if(rsi > 70){kq =0; } //kq = OP_BUY;
      if(rsi < 30){kq =1 ;} //kq = OP_SELL;
      if( rsi > 90 || rsi < 10  ){kq = 3;}

      return (kq);
  }


double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balancee);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);//Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
    if(OrderType()>1 ){continue;}

    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit();
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }

return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int Magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }

   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,Magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
}
//====================================================================
/*
void laygiatrinen()
{

  // tim  mo hinh enguffing

  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1);
     lowtruoc  = iLow(Symbol(),0,n+1);

     hightsau = iHigh(Symbol(),0,n);
     lowsau  = iLow(Symbol(),0,n);

     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }

  }

  */

  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat

  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....

  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if(
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */

  //ham chuyen doi
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;

 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
        dem ++;// dem dc 1 lenh
   }

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }

    khoiLuong = NormalizeDouble(khoiLuong,2);

     return(khoiLuong);// tra ve khoi da duoc dinh dang

}
//+==================================================================+
void Trailling(double trail)
{
   double  NewSL; trail*= 10*Point;   // trail  = trail * 10*10*Point
   for(int i = OrdersTotal()-1; i >=0 ; i--) //OrdersHistoryTotal()
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;} //Neu khong tim duoc lenh thi tiep tuc lap

      if (OrderSymbol() != Symbol())         {continue;}
      if (OrderMagicNumber() != Magic) {continue;}

      if (OrderType() == OP_BUY) {NewSL = Ask - trail;}
      else if (OrderType() == OP_SELL) {NewSL = Bid + trail;}

      if (OrderType() == OP_BUY && OrderStopLoss()>=NewSL ) {continue;}
      if (OrderType() == OP_SELL && OrderStopLoss()<=NewSL) {continue;}
      Comment(NewSL);

      OrderModify(OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,CLR_NONE);
      if(GetLastError()!=0 && GetLastError()!=1) {Print("Loi Trailling: " + GetLastError());}
   }
}
//====================================================================
void DONGLENH_ToanBo()
{
   for (int i=OrdersTotal()-1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()<2)  {DongLenh_Ticket(OrderTicket(), OrderLots());}
      else {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DONGLENH_theo_type(int op1)
{
   for (int i=OrdersTotal()-1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if( OrderType()>=2)                                 {continue;}
      if (OrderType()==op1) {DongLenh_Ticket(OrderTicket(), OrderLots());}
   }
}


void DONGLENH_motphan(int op1,double lot)
{
   for (int i=OrdersTotal()-1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
    //  if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()==op1)  {DongLenh_Ticket(OrderTicket(), lot);}
      //if ((OrderType()==op1||OrderType()==op2)&& OrderType()>2) {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DongLenh_Ticket(int ticket, double lott)
{
  int Slippage = 3;
  if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {return;}
  if(lott==0){lott=OrderLots();}
  if(OrderType()>1){ OrderDelete(OrderTicket(),CLR_NONE);}
  if(OrderType()<=1)
  {
  double priice; RefreshRates();
    if (OrderType() == OP_BUY) {priice = MarketInfo(OrderSymbol(),MODE_BID);}
     else {priice = MarketInfo(OrderSymbol(),MODE_ASK);}
    OrderClose(ticket, lott, priice, Slippage, Gold);
   // Sleep(100);
  }
  return;
}

BÀI 20:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+

enum chedo
{
highRisk  = 1,
lowRisk = 2,
};
//extern bool a 
extern chedo  mucdoruiro = highRisk;

//bool bientenlaA
extern ENUM_MA_METHOD maMode ;



 extern string noTradeinHourGMT   ="/2/3/4/";
 




//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  Magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 500;
     extern  double takeprofit = 1000;

     extern double  Trailling_pip = 10;
 string sym;
 
 
 bool  active = true;
 datetime ngayhethan = D'2020.08.01 00:00:00';  
//+------------------------------------------------------------------+
int OnInit()
  {
       sym=Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
      if(active ==false){return;}
        // cho chạy code ben dưới dòng này khi qua nến mới 
     // Trailling(Trailling_pip) ;
      if(demsolenh( sym ) >0 ){return;}
     if( StringFind(("/"+noTradeinHourGMT+"/"),("/"+ TimeHour(TimeGMT())+"/"),0) >=0   ){return;}
     //StringFind( "/2/3/4/","/2/", 0)          "/7/"
//===================================================================== 
//=========tinh khoi luong ===========
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,Magic,Com);
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );
 
 //==============================================
   double kiemtra =   check_dk_donglenh();
    // 0--> close buy , 1-->  close sell , -- >-1  ko lam gi ca , 3--> close all
   Comment("bien kiem tra = "+kiemtra );
   if(kiemtra == OP_BUY )
   { 
      DONGLENH_theo_type(OP_BUY);
   }
   if(kiemtra == OP_SELL )
   { 
      DONGLENH_theo_type(OP_SELL);
   }
   if(kiemtra == 3 )
   { 
      DONGLENH_ToanBo();
   }
   
   
   
  }// end ontick
  //=====================================
  
double check_dk_donglenh()
  {
      double kq =-1;
      double rsi = iRSI(Symbol(),0,21,PRICE_CLOSE,0);
      if(rsi > 70){kq =0; } //kq = OP_BUY;
      if(rsi < 30){kq =1 ;} //kq = OP_SELL;
      if( rsi > 90 || rsi < 10  ){kq = 3;}
  
      return (kq);
  }
  
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balancee);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);//Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int Magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,Magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+
void Trailling(double trail) 
{
   double  NewSL; trail*= 10*Point;   // trail  = trail * 10*10*Point
   for(int i = OrdersTotal()-1; i >=0 ; i--) //OrdersHistoryTotal()
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;} //Neu khong tim duoc lenh thi tiep tuc lap
      
      if (OrderSymbol() != Symbol())         {continue;}
      if (OrderMagicNumber() != Magic) {continue;}
      
      if (OrderType() == OP_BUY) {NewSL = Ask - trail;}
      else if (OrderType() == OP_SELL) {NewSL = Bid + trail;}

      if (OrderType() == OP_BUY && OrderStopLoss()>=NewSL ) {continue;}
      if (OrderType() == OP_SELL && OrderStopLoss()<=NewSL) {continue;}
      Comment(NewSL);
      
      OrderModify(OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,CLR_NONE);
      if(GetLastError()!=0 && GetLastError()!=1) {Print("Loi Trailling: " + GetLastError());}
   }   
}
//====================================================================   
void DONGLENH_ToanBo()
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()<2)  {DongLenh_Ticket(OrderTicket(), OrderLots());}
      else {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DONGLENH_theo_type(int op1)
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if( OrderType()>=2)                                 {continue;}
      if (OrderType()==op1) {DongLenh_Ticket(OrderTicket(), OrderLots());}
   }
}


void DONGLENH_motphan(int op1,double lot)
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
    //  if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()==op1)  {DongLenh_Ticket(OrderTicket(), lot);}
      //if ((OrderType()==op1||OrderType()==op2)&& OrderType()>2) {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DongLenh_Ticket(int ticket, double lott) 
{
  int Slippage = 3;
  if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {return;}
  if(lott==0){lott=OrderLots();}
  if(OrderType()>1){ OrderDelete(OrderTicket(),CLR_NONE);}
  if(OrderType()<=1)
  { 
  double priice; RefreshRates();
    if (OrderType() == OP_BUY) {priice = MarketInfo(OrderSymbol(),MODE_BID);}
     else {priice = MarketInfo(OrderSymbol(),MODE_ASK);}
    OrderClose(ticket, lott, priice, Slippage, Gold);
   // Sleep(100); 
  }  
  return;
}

BÀI 21:
//+------------------------------------------------------------------+
//|                                                       baiso1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+

enum chedo
{
highRisk  = 1,
lowRisk = 2,
};
//extern bool a 
extern chedo  mucdoruiro = highRisk;

//bool bientenlaA
extern ENUM_MA_METHOD maMode ;



 extern string noTradeinHourGMT   ="/2/3/4/";
 




//| Expert initialization function                                   |
// NOI KHAI BAO BIEN


       double khoiLuong= 0.01;// 0       
        string Com   ;
      color maucualenh = clrRed;
       int loaiLenh = OP_BUY; 
      double giavaolenh=0; 
      datetime thoigiangiaodich;
      bool chophepGD = true;
      int  Magic =999;
      
       double lastLotsize ;
       int lasttype;
       
       double balance;// acc
       
       extern double risk = 5;
     extern double stoploss = 500;
     extern  double takeprofit = 1000;

     extern double  Trailling_pip = 10;
 string sym;
 
 
 bool  active = true;
 datetime ngayhethan = D'2020.08.01 00:00:00';  
//+------------------------------------------------------------------+
int OnInit()
  {
       sym=Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
void donglenhchosauxphut(int sophut)
{
   for(.........)
   {
   ......
   .......
   ........
   
      OrderOpenTime()
      --> ??? bao nhieu nen  1 phut ?
   
   }


}
//+------------------------------------------------------------------+
void OnTick()
  { 
     /* if(active ==false){return;}
        // cho chạy code ben dưới dòng này khi qua nến mới 
     // Trailling(Trailling_pip) ;
      if(demsolenh( sym ) >0 ){return;}
     if( StringFind(("/"+noTradeinHourGMT+"/"),("/"+ TimeHour(TimeGMT())+"/"),0) >=0   ){return;}
     //StringFind( "/2/3/4/","/2/", 0)          "/7/"*/
//===================================================================== 
//=========tinh khoi luong ===========

   // trả về số cây nến        iBarShift(Symbol(),0, đầu ngày ,  false    );

//datetime mocthgian = D'2020.10.13 13:00:00'; 
//int sonen = iBarShift(Symbol(),0,mocthgian,false);
//Comment(sonen);
double giacaonhat,giathapnhat;

int x = iHighest(Symbol(),0,MODE_HIGH,100,0);// trả về cây nến có giá cao nhất
int y = iLowest (Symbol(),0,MODE_LOW,100,0);

giacaonhat = High[x];
giathapnhat = Low[y];
Comment(giacaonhat+"/"+giathapnhat);
return;
//////////////////////////
donglenhchosauxphut(int phut);
//================
balance = AccountEquity();
double slPoint= stoploss*10* MarketInfo(sym,MODE_POINT);
   khoiLuong = get_lot_from_money_point(sym,balance,risk,slPoint);
// dieu kien vao lenh-------------- 
    loaiLenh = MathRand()%2;// loai lenh ngau nhien
 //--------------------------------VAO LENH------------------
     vaoLenh(sym,loaiLenh,khoiLuong,0,stoploss,takeprofit,Magic,Com);
    // SendNotification("co lenh moi ne "+ sym+ " "+ khoiLuong );
 
 //==============================================
   double kiemtra =   check_dk_donglenh();
    // 0--> close buy , 1-->  close sell , -- >-1  ko lam gi ca , 3--> close all
   Comment("bien kiem tra = "+kiemtra );
   if(kiemtra == OP_BUY )
   { 
      DONGLENH_theo_type(OP_BUY);
   }
   if(kiemtra == OP_SELL )
   { 
      DONGLENH_theo_type(OP_SELL);
   }
   if(kiemtra == 3 )
   { 
      DONGLENH_ToanBo();
   }
   
   
   
  }// end ontick
  //=====================================
  
double check_dk_donglenh()
  {
      double kq =-1;
      double rsi = iRSI(Symbol(),0,21,PRICE_CLOSE,0);
      if(rsi > 70){kq =0; } //kq = OP_BUY;
      if(rsi < 30){kq =1 ;} //kq = OP_SELL;
      if( rsi > 90 || rsi < 10  ){kq = 3;}
  
      return (kq);
  }
  
  
double get_lot_from_money_point(string symm,double balancee,double risk,double slPoint)
  {
      double lotsize ;
      double   sotien = MathAbs(risk/100*balancee);  // 10000 * 5 /100
      double tickval = MarketInfo(symm , MODE_TICKVALUE);
      double ticksize = MarketInfo(symm , MODE_TICKSIZE);
      //========cong thuc chinh
    if(slPoint!=0 && ticksize !=0 && tickval !=0 )
    {  
     lotsize = sotien /(slPoint*tickval/ticksize);
    }
      // =========== 0.2568746655
    double lotstep = MarketInfo(symm,MODE_LOTSTEP);//Comment(lotstep);
    int step;
    if(lotstep==1){step = 0;}
    if(lotstep == 0.01){step =2;}
    if(lotstep == 0.001){step =3;}
    if(lotstep == 0.1 ){step =1;}
    lotsize = NormalizeDouble(lotsize,step);
    if (lotsize < MarketInfo(symm, MODE_MINLOT))            lotsize = MarketInfo(symm, MODE_MINLOT);         
    if (lotsize > MarketInfo(symm, MODE_MAXLOT))            lotsize = MarketInfo(symm, MODE_MAXLOT);   

      return(lotsize);
  }

//+------------------------------------------------------------------+
double lenhcuoicung(string symm)
{  double lastprofit;       datetime lasttime ;

   for(int i =0; i <= OrdersHistoryTotal()-1; i++)
   { 
    if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==False)  {continue;}
    if(OrderSymbol() != symm){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
    if(OrderType()>1 ){continue;}
    
    if(OrderCloseTime()> lasttime  )
         {
         lasttime = OrderCloseTime(); // 6h
         lastprofit = OrderProfit(); 
         lastLotsize = OrderLots();
         lasttype = OrderType();
         }
   }
   
return(lastprofit);
}
//======================================================================
void   vaoLenh(string symm, int typee, double lott, double pricee, double slpip,double tppip,int Magicc, string comm )
{
   if(lott ==0){return;}
   int normallotunit  ;
   if(MarketInfo(symm, MODE_MINLOT)== 0.01){normallotunit = 2;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.1){normallotunit = 1;}
   if(MarketInfo(symm, MODE_MINLOT)== 0.001){normallotunit = 3;}
   lott = NormalizeDouble(lott, normallotunit );
   //---------------------------
   double slprice, tpprice; color mau;
   if(typee== OP_BUY)
       {
         pricee = MarketInfo(symm,MODE_ASK);
         slprice = pricee - slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee + tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrBlue;
       }
       
   if(typee== OP_SELL)
       {
         pricee = MarketInfo(symm,MODE_BID);
         slprice = pricee + slpip*10*MarketInfo(symm ,MODE_POINT);
         tpprice = pricee - tppip*10*MarketInfo(symm ,MODE_POINT);
         mau = clrRed;
       }
   pricee = NormalizeDouble(pricee,MarketInfo(symm , MODE_DIGITS));
   slprice = NormalizeDouble(slprice,MarketInfo(symm , MODE_DIGITS));
   tpprice = NormalizeDouble(tpprice,MarketInfo(symm , MODE_DIGITS));
  //-----gui lenh
   double thanhcong = OrderSend(symm,typee,lott,pricee,20,0,0,comm,Magicc,0,mau);
  // ----- CHINH SL TP
  bool sucess =false; int dem;
  if(thanhcong >0 && slprice !=0 && tpprice!=0 )
      {
         while ( sucess == false && dem<20)
         {  sucess =  OrderModify(thanhcong,pricee,slprice,tpprice,0,clrNONE);
          dem++; Sleep(50);
         }
      int error = GetLastError();
      if(error !=0 && error !=1){ Print("bi loi: "+ error);}
      }
}
//====================================================================
/*
void laygiatrinen()
{
  
  // tim  mo hinh enguffing
  
  for(int n =500 ; n >=0; n--)
  {
      double highttruoc, lowtruoc , hightsau, lowsau ;
     highttruoc = iHigh(Symbol(),0,n+1); 
     lowtruoc  = iLow(Symbol(),0,n+1);
      
     hightsau = iHigh(Symbol(),0,n); 
     lowsau  = iLow(Symbol(),0,n); 
     
     if(highttruoc<hightsau && lowtruoc > lowsau)
     {
         Comment(n);// gan nhat cay nen so 0
         //break;
     }
     
  }
  
  */
  
  /*int caynencaonhat,caynenthapnhat;
  caynencaonhat= iHighest(Symbol(),0,MODE_HIGH,100,0);// tra ve cay nen cao nhat
  caynenthapnhat = iLowest(Symbol(),0,MODE_LOW,100,0);// tra ve cay nen thap nhat
  
  double giacaonhat = iHigh(Symbol(),0,caynencaonhat);//  lay gias hight cua ....
  double giathapnhat = iLow(Symbol(),0,caynenthapnhat);// lay low ....
 
  // Comment(caynencaonhat +" / "+ caynenthapnhat);

  Comment(giacaonhat +" / "+ giathapnhat);*/





//+==================================================================+
int  Order_Open(int ordType,string sym_,double lots,double price,double sl,double tp,int mag,string com,double bidask)
  {// int ticket;
  if(lots==0){return(0);}
   color col; double Stoploss,TakeProfit;
   double unit=1;   if(bidask!=0){unit= bidask;}
   if(ordType==OP_BUY) {price=MarketInfo(sym_,MODE_ASK);Stoploss=price-sl*unit; TakeProfit=price+tp*unit; col=Blue;}
   if(ordType==OP_SELL) {price=MarketInfo(sym_,MODE_BID);Stoploss=price+sl*unit; TakeProfit=price-tp*unit; col=Red;}
   price=NormalizeDouble(price,MarketInfo(sym_,MODE_DIGITS));
   int NormalizeLot;   if(MarketInfo(sym_,MODE_MINLOT)==0.1) {NormalizeLot=1;} else {NormalizeLot=2;}
   lots=NormalizeDouble(lots,NormalizeLot);
   int sucess=-1; int ross=0;int demm;
   sucess=OrderSend(sym_,ordType,lots,price,3,0,0,com,mag,0,col);Sleep(100);
   if(sucess>0 && (sl!=0 || tp!=0))
     {
      while(ross<=0 && demm<20){  ross=OrderModify(sucess,price,Stoploss,TakeProfit,0,clrNONE); demm++;Sleep(100);    }
     }
     int loi = GetLastError();
   if(loi!=0 && loi !=1 ){ Print("eror"+loi);          Print(sym_+ "/price "+ price+ " /op "+ordType+"/lot "+lots);
}
   return(sucess);
  }
//+------------------------------------------
//======================================================
void checkLisicen()
{
  /*datetime x =  iTime(Symbol(),PERIOD_D1,0);// thoi gian dau ngay
  // x=  TimeCurrent();// thoi gian hien tai
   //TimeHour(x);
  // TimeMinute()
 // dau ngay + 3 hour()?
  x= x +3*60*60;
   Comment(x);
   */


  if( 
        TimeYear( TimeCurrent())<=2020
     && TimeMonth( TimeCurrent())<=4
    ){active= true;}
  // --> file ex4 */
  
  //ham chuyen doi 
  /*datetime x = StrToTime(giobatdau);
  string a = "06";
  string b = "30";
  string c= a+ ":"+b;
  
 datetime d =  StrToTime(c)+60;
  Comment(d);
  StrToInteger*/
/*  string commentt = "| 5 (6)lenhdautien";
  int vitri=  StringFind(commentt,"(",0);
  string cat = StringSubstr(commentt,vitri+1,1);
  Comment(cat);*/
  //Str
}
//==========================================
int demsolenh(string captiencandem)
{
   int dem;
   for(int i = OrdersTotal()-1 ; i>=0; i--)
   {
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)==False)  {continue;}
    if(OrderSymbol() != captiencandem){continue;}
    if(OrderMagicNumber()!= Magic){continue;}
        dem ++;// dem dc 1 lenh
   } 

return(dem);
}
//====================================
//====================================
double dinhdangLot(double khoiLuong)
{
   if(khoiLuong==0){ khoiLuong = MarketInfo(Symbol(),MODE_MINLOT)   ; }
   if(khoiLuong> MarketInfo(Symbol(),MODE_MAXLOT)){ khoiLuong = MarketInfo(Symbol(),MODE_MAXLOT)   ; }
    
    khoiLuong = NormalizeDouble(khoiLuong,2);
     
     return(khoiLuong);// tra ve khoi da duoc dinh dang
     
}
//+==================================================================+
void Trailling(double trail) 
{
   double  NewSL; trail*= 10*Point;   // trail  = trail * 10*10*Point
   for(int i = OrdersTotal()-1; i >=0 ; i--) //OrdersHistoryTotal()
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {continue;} //Neu khong tim duoc lenh thi tiep tuc lap
      
      if (OrderSymbol() != Symbol())         {continue;}
      if (OrderMagicNumber() != Magic) {continue;}
      
      if (OrderType() == OP_BUY) {NewSL = Ask - trail;}
      else if (OrderType() == OP_SELL) {NewSL = Bid + trail;}

      if (OrderType() == OP_BUY && OrderStopLoss()>=NewSL ) {continue;}
      if (OrderType() == OP_SELL && OrderStopLoss()<=NewSL) {continue;}
      Comment(NewSL);
      
      OrderModify(OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,CLR_NONE);
      if(GetLastError()!=0 && GetLastError()!=1) {Print("Loi Trailling: " + GetLastError());}
   }   
}
//====================================================================   
void DONGLENH_ToanBo()
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()<2)  {DongLenh_Ticket(OrderTicket(), OrderLots());}
      else {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DONGLENH_theo_type(int op1)
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
      if (OrderMagicNumber()!=Magic)                     {continue;}
      if( OrderType()>=2)                                 {continue;}
      if (OrderType()==op1) {DongLenh_Ticket(OrderTicket(), OrderLots());}
   }
}


void DONGLENH_motphan(int op1,double lot)
{ 
   for (int i=OrdersTotal()-1; i >= 0; i--) 
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))   {continue;}
      if (OrderSymbol()!=Symbol())                       {continue;}
    //  if (OrderMagicNumber()!=Magic)                     {continue;}
      if (OrderType()==op1)  {DongLenh_Ticket(OrderTicket(), lot);}
      //if ((OrderType()==op1||OrderType()==op2)&& OrderType()>2) {int rec = OrderDelete(OrderTicket(),CLR_NONE);}
   }
}


void DongLenh_Ticket(int ticket, double lott) 
{
  int Slippage = 3;
  if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {return;}
  if(lott==0){lott=OrderLots();}
  if(OrderType()>1){ OrderDelete(OrderTicket(),CLR_NONE);}
  if(OrderType()<=1)
  { 
  double priice; RefreshRates();
    if (OrderType() == OP_BUY) {priice = MarketInfo(OrderSymbol(),MODE_BID);}
     else {priice = MarketInfo(OrderSymbol(),MODE_ASK);}
    OrderClose(ticket, lott, priice, Slippage, Gold);
   // Sleep(100); 
  }  
  return;
}



