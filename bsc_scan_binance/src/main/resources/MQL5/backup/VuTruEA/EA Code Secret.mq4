//+------------------------------------------------------------------+
//|                                
//+------------------------------------------------------------------+
#property copyright "xxxxxxxxxxxx"
#property link      "https://uuuuuuuuuu"
#property version   "1.00"
#include <stdlib.mqh>

// LIMIT ACCOUNT DAN KADALUARSA

//  GANTI NOMOR ACCOUNT DENGAN NOMOR ACCOUNT KLIEN YANG BELI EA ANDA
//  JIKA = 0, MAKA SEMUA NOMOR ACCOUNT BISA DIPAKAI
//int     NomorAccount         = 0;

  
// GANTI TANGGAL DIBAWAH SESUAI DENGAN KADALUARSA YANG ANDA INGINKAN
// FORMAT TANGGAL ADALAH "TAHUN.BULAN.TANGGAL  JAM:MENIT"
//string  Kadaluarsa           = "2020.03.07 00:00"; 


string nama2   ="mmmmmmmm";
string email   ="https:/yyyyyyyyy";
string nohp    ="fgfgffgfgfgf";  
//=====================================================================================================||
string   v1           = IntegerToString(AccountNumber());
int      v2           = (StringLen(v1))-3;
string   v3           = StringSubstr(v1,v2,3);
int      _4digitAkun  = StrToInteger(v3);   // <<-- Mengambil 3 Digit no akun dari belakang

//=====================================================================================================||
int       KodePassword   = (_4digitAkun*0)+0; // Ganti Rumus password dis+ini + 3nomor akun terakhir*0+
//datetime  ExpiredDate    = D'31.12.2010'; // Ganti tanggal expired disini (Hari-Bulan-Tahun)  
//=====================================================================================================||

extern string   Owner       = "===== Copyright gfgfgfgfgfgf =====";//===
extern string _EA                            = "_____fgfgffgfg______";
//--- input parameters
extern string  Password       = "Ask @ nnnnnnnnn";
extern bool      Close_All             = false;  
extern int       TP_In_Money           = 200;
extern int       MagicNumber           = 12345;

extern bool      USE_COMPOUND          = true;
extern double    LOT_PROSEN            = 0.002;

extern double    Lots                  = 0.01;  

extern int       TakeProfit            = 60;
extern int       SL=1000;

extern bool      FITUR_TRAIL           = false;
extern int       TrailingStop          = 6;


extern int       Step                  = 20;
extern int       SlipPage              = 3;  
extern int       MaxSpread             = 70;
extern bool      UseMartingale         = True;
extern double    Multiplier            = 1.7;
extern int       MaxLevel              = 15;
int    gi_580 = 65535;



extern string _TIMEFILTER                    = "_______ TIME FILTER BROKER TIME _______";
extern bool    Use_TimeFilter                = true;
extern int     StartHour                     = 0;
extern int     EndHour                       = 24;
int    EndHour1, StartHour1, GMTOffset;
string comment1;
int convert;

double HARGA;

int prec=0;
bool CLOSE, DELETE;
int cnt;
double point,harga,i;

bool      UseSinglePairOrder=false;
bool bolehbuy=true, bolehsell=true;
double MinLots, MaxLots, minlot, TPBuy, SLBuy;
int    DIGIT, slippage=10, spread, stoplevel;
double last_lot_sell, last_price_sell, last_lot_buy, last_price_buy, last_price, last_lot;
int    last_type, pending, OpenOrders, openbuy, opensell;
datetime time;
double martilot;
double last_tp_buy, last_tp_sell;



double Lots()
{
   double lot=0;
   lot=NormalizeDouble((LOT_PROSEN*AccountBalance()/100), prec) ;
   if (lot>MarketInfo(Symbol(),MODE_MAXLOT)) { lot=MarketInfo(Symbol(),MODE_MAXLOT); }
   if (lot<minlot) { lot=minlot; }
   return (lot);
}
color  FontColorUp1 = Yellow;  
color  FontColorDn1 = Pink; 
color  FontColor = White;
color  FontColorUp2 = LimeGreen;  
color  FontColorDn2 = Red; 

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
    minlot=MarketInfo(Symbol(),MODE_MINLOT);
    if(minlot==0.01) prec=2;
    else
    if(minlot==0.1)  prec=1;
    else             prec=0;
    
    if (Digits==5 ||Digits==3) {convert=10;} else {convert=1;}


   if(Digits==3 || Digits==5) point=10*Point;
    else                       point=Point;
   return(0);
  }
int deinit()
  {
//----
    ObjectDelete("Market_Price_Label1"); 
    ObjectDelete("Market_Price_Label2"); 
    ObjectDelete("Market_Price_Label3"); 
    ObjectDelete("Market_Price_Label4"); 
    ObjectDelete("Market_Price_Label5"); 
    ObjectDelete("Market_Price_Label6"); 
    ObjectDelete("Market_Price_Label7"); 
    ObjectDelete("Market_Price_Label8"); 
    ObjectDelete("Market_Price_Label9"); 
    ObjectDelete("Market_Price_Label10"); 
    ObjectDelete("Market_Price_Label11"); 
    ObjectDelete("Market_Price_Label12"); 
    ObjectDelete("Market_Price_Label13"); 
    ObjectDelete("Market_Price_Label14"); 
    ObjectDelete("Market_Price_Label15"); 
    ObjectDelete("Market_Price_Label16"); 
    ObjectDelete("Market_Price_Label17"); 
    ObjectDelete("Market_Price_Label18"); 
    ObjectDelete("Market_Price_Label19"); 
    ObjectDelete("Market_Price_Label20"); 
    ObjectDelete("Market_Price_Label21"); 
    ObjectDelete("Market_Price_Label22"); 
    ObjectDelete("Market_Price_Label23"); 
    ObjectDelete("Market_Price_Label24"); 
    ObjectDelete("Market_Price_Label25"); 
    ObjectDelete("Market_Price_Label26"); 
    ObjectDelete("Market_Price_Label27"); 
    ObjectDelete("Market_Price_Label28"); 
    ObjectDelete("Market_Price_Label29"); 
    ObjectDelete("Market_Price_Label30"); 
    ObjectDelete("Market_Price_Label31"); 
    ObjectDelete("Market_Price_Label32"); 
    ObjectDelete("Market_Price_Label33"); 
    ObjectDelete("Market_Price_Label34"); 
    ObjectDelete("Market_Price_Label35"); 
    ObjectDelete("Market_Price_Label36"); 
    ObjectDelete("Market_Price_Label37"); 
    ObjectDelete("Market_Price_Label38"); 
    ObjectDelete("Market_Price_Label39"); 
    ObjectDelete("Market_Price_Label40"); 
    ObjectDelete("Market_Price_Label41"); 
    ObjectDelete("Market_Price_Label42"); 
    ObjectDelete("Market_Price_Label43"); 
    ObjectDelete("Market_Price_Label44"); 
    ObjectDelete("Market_Price_Label45"); 
    ObjectDelete("Market_Price_Label46"); 
    ObjectDelete("Market_Price_Label47"); 
    ObjectDelete("Market_Price_Label48"); 
    ObjectDelete("Market_Price_Label49"); 
    ObjectDelete("Market_Price_Label50");
    ObjectDelete("ObjLabel1");
    ObjectDelete("ObjLabel2");
    ObjectDelete("ObjLabel3");
    ObjectDelete("ObjLabel4");
    ObjectDelete("ObjLabel5");
    ObjectDelete("ObjLabel6");
    ObjectDelete("ObjLabel7");

//----
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start(){

string accnt = "EA desconhecido";

if (accnt != WindowExpertName())

{
Alert ("Dont rename EA.  More Info Contact vbvbvbvbvb!!!");
return(0);
}


   int Li_0;
   double iopen_8;
   int datetime_40;
   double Ld_44;
   double Ld_56;
   double Ld_57;
   double Ld_58;
   double Ld_59;
   double Ld_60;
   double Ld_64;
   double Ld_72;
   double Ld_80;
   double Ld_88;
   double Ld_96;
   
  

   if(KodePassword != Password ){wr();return(0);}

   string   st =(string)Year()+"."+(string)Month()+"."+(string)Day();
   datetime tg =StringToTime(st);
   datetime tg2=iTime(NULL,PERIOD_D1,1);
    
   string Market_Price6 =   "EA HolyGrail v3";
   
}

 

//bool kadaluarsa()
//{datetime kada  = StrToTime(Kadaluarsa); if (TimeCurrent()>kada) {Alert ("EA expired!Please Contact Telegram @EvoPROFX");return (false);} else {return (true);}}


//bool LoginNumber()
//{if (AccountNumber()==NomorAccount || NomorAccount == 0 ) {return (true);} else {Alert ("Wrong Acc!Please Contact Telegram @EvoPROFX "); return (false);}}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){}
  void wr(){
  ObjectsDeleteAll(0,-1,OBJ_LABEL);
   ObjectCreate("M6", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("M6","SORRY WRONG PASSWORD",14,"Thoma",clrYellow);
   ObjectSet("M6", OBJPROP_CORNER, 0);
   ObjectSet("M6", OBJPROP_XDISTANCE, 10);
   ObjectSet("M6", OBJPROP_YDISTANCE, 40);
   
   ObjectCreate("M7", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("M7","PLEASE CONTACT Telegram @ "+nama2,12,"Arial Bold",clrRed);
   ObjectSet("M7",OBJPROP_CORNER, 0);
   ObjectSet("M7",OBJPROP_XDISTANCE, 10);
   ObjectSet("M7",OBJPROP_YDISTANCE, 60);
   
   ObjectCreate("M8", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("M8","Telegram = "+nohp+" . Thank you.",10,"Arial Bold",clrYellow);
   ObjectSet("M8",OBJPROP_CORNER, 0);
   ObjectSet("M8",OBJPROP_XDISTANCE, 10);
   ObjectSet("M8",OBJPROP_YDISTANCE, 80);
}

