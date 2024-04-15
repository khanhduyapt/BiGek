//+------------------------------------------------------------------+
//|                                                   EA_Closing.mq4 |
//|                              Copyright 2020, BlackBullTrader.com |
//|                                          www.blackbulltrader.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, BlackBullTrader.com"
#property link      "www.blackbulltrader.com"
#property version   "1.00"
#property strict
    input int     Password          = 0;
    enum TPModel{
       a=1, //JUMLAH OP 
       b=2,  //WAKTU 
       c=3  //MONEY
     };
    extern TPModel Jenis_TP   = 3;
    input int JumlahOP        = 3;
    input int SecondClose     = 3600;
    input double TPMoney      = 20;

//+------General Variable---+
  int       KodePassword = (AccountNumber()*2)+0220;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   return(INIT_SUCCEEDED);
  }
//--+
   void OnDeinit(const int reason){ }
//+-------+
   void OnTick(){
//---+ 
//Expire Date
  if (TimeCurrent() > D'07.07.2025 07:00') {
      Alert("EA Expired.. !!!!!!!");
      Print("EA Expired.. !!!!!!!");
      Comment("EA Expired..!!!!!!!");
      return ;
      }
   if (KodePassword != Password) {
         Alert("Maaf Boss, Password Anda Salah!");
         Print("Maaf Boss, Password Anda Salah!");
         return;
      }   
 //----+   
  bool type_acc = IsDemo();   
 if (!type_acc){
   if (!LiveAccountNumbers()){
         Comment("Maaf Boss, Nama Tidak Terdaftar" + " Gunakan Nama atau No Acc yang sama sewaktu membeli EA ini!");
         return;
      } 
   }  
//---+   
  if(Jenis_TP==1 &&(CountTrades()>=JumlahOP)){CloseAll();}
  if(Jenis_TP==2 && TimeCurrent()>=LastTimeOP()+SecondClose){CloseAll();}
  if(Jenis_TP==3 && ProfitBuySell()>=TPMoney){CloseAll();}
//---+   
  }
//+---------end of main program----------------+
//+----------+        
datetime LastTimeOP(){  
   int      iCount      =  0;
   datetime   LastOP    =  0;
                     
   for(iCount=0;iCount<OrdersTotal();iCount++){                  
     int cek=OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES);          
   if(OrderType()==OP_BUY || OrderType()==OP_SELL){
      if(LastOP==0) {LastOP=OrderOpenTime();}
      if(LastOP<OrderOpenTime()) {LastOP=OrderOpenTime();}  
      if(LastOP>OrderOpenTime()) {LastOP=LastOP;}                 
     }         
    }     
  return(LastOP);
 }  
//---+    
//--------------------+
// ORDERS CALCULATION +
//--------------------+  
int CountTrades(){
    int count=0;
    for(int tr=OrdersTotal()-1;tr>=0;tr--){
    int result=OrderSelect(tr,SELECT_BY_POS,MODE_TRADES);
    if(OrderType()==OP_SELL || OrderType()==OP_BUY){count++;}}
 return(count);}
//----+ 
//--------------------+
// PROFIT CALCULATION +
//--------------------+          
double ProfitBuySell(){  
   double bsprofit= 0;
   int result;
   for (int cbs = 0; cbs < OrdersTotal(); cbs++) {
      result=OrderSelect(cbs, SELECT_BY_POS, MODE_TRADES);
       if(OrderType()==OP_SELL || OrderType()==OP_BUY){
       bsprofit += OrderProfit()+OrderSwap()+OrderCommission();
     }
   } 
   return(bsprofit);
 }
//--------------------+
// CLOSE ORDERS       +
//--------------------+  
void CloseAll(){
  for (int i = OrdersTotal() - 1; i >= 0; i --){
      int res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_BUY) {res = OrderClose(OrderTicket(), OrderLots(),MarketInfo(Symbol(),MODE_BID),0, CLR_NONE);} 
         if(OrderType() == OP_SELL){res = OrderClose(OrderTicket(), OrderLots(),MarketInfo(Symbol(),MODE_ASK),0, CLR_NONE);}
         if(OrderType() == OP_SELLSTOP) {res = OrderDelete(OrderTicket());}  
         if(OrderType() == OP_BUYSTOP)  {res = OrderDelete(OrderTicket());}  
         Sleep(1000);
      }
   }  
//-----+  
//-------+       
bool LiveAccountNumbers() {
   if (AccountName() == "Riswan Haryadi" || AccountName() == "RISWAN HARYADI" || AccountName() == "riswan haryadi") return (TRUE);
   if (AccountNumber() ==35106418) return (TRUE); 
   if (AccountNumber() ==49053151) return (TRUE);
   if (AccountNumber() ==5181771) return (TRUE);
   if (AccountNumber() ==5178947) return (TRUE);
   return (FALSE);
   } 
//----+ 