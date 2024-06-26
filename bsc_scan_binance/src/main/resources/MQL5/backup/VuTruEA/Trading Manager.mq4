//+------------------------------------------------------------------+
//|                               me_SimpleTradingDashboard v1.0.mq4 |
//|                                       Copyright © 2017, qK Code. |
//|                                   http://www.facebook.com/qkcode
//
//  Reverseb & Break Even & Button color options : Phylo-File45
//  eess: Added the functionality of SL+1,Delete SL, Change SL and 
//         Change TP.
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, qK Code. (www.facebook.com/qkcode)"
#property link      "http://www.facebook.com/qkcode"
#property strict

int extern SubWindow = 0;
input ENUM_BASE_CORNER Corner = 2;

extern double Lots = 0.01; // Lot
extern double LotsClose = 0.01; // Lot Close
input int StopLoss      = 0;
input int TakeProfit    = 0;
input int RrEv = 10; //BreakEven Points 
input double  Koeff = 1; //Reverse Koeff

input int Move_X = 0;
input int Move_Y = 0;
input int slip  = 5; // Slippage
input string B00001 = "====================";
int Button_Width = 100;
input string Font_Type = "Arial Bold";
input int Font_Size = 8; 
input color Font_Color = White;
input color CL = clrDimGray; // Lots
input color CB = clrDarkGreen; // Buy & Close All Buy
input color CS = clrCrimson; // Sell & Close All Sell
input color CA = clrBlue; // Close All
input color CR = clrDarkSlateGray; // Reverse
input color CBE = clrMaroon; // Break Even
input color CP = clrBlue; // Close_Percent
input color CSL = clrCrimson; // SL + 1
input color CTP = clrDarkGreen; // Edit TP
input color CBR = clrNONE; // Border btn
input color CDA = clrTeal; // Delete all btn
input color CBS = clrDarkGreen;
input color CLS = clrRed;
int ticket, itotal,pp;

double Pekali;



int sl=0,tp=0;
//+------------------------------------------------------------------+         
int OnInit()
  {
  
   double Lot=DoubleToStr(Lots,2);
   double LotCl=DoubleToStr(LotsClose,2);
   
   CreateButtons();
   ToolTips_Text ("Lot_00000_btn");
   ToolTips_Text ("Buy_00000_btn");
   ToolTips_Text ("Sell_0000_btn");
   ToolTips_Text ("Close_Buy_btn");
   ToolTips_Text ("Close_Sel_btn");
   ToolTips_Text ("Close_All_btn");
   ToolTips_Text ("Break_Even_btn");
   ToolTips_Text ("Reverse_btn");
   ToolTips_Text  ("Close_Percent_btn");
   ToolTips_Text ("Delete_All___btn");
   ToolTips_Text ("Sell_Limit_1_btn");
   ToolTips_Text ("Buy__Limit_1_btn");
   ToolTips_Text ("Sell_Stop__1_btn");
   ToolTips_Text ("Buy__Stop__1_btn");
/*   ToolTips_Text ("Modify_SL____btn");
   ToolTips_Text ("Modify_TP____btn");*/
   
   ObjectCreate ("Lot_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet ("Lot_Edit", OBJPROP_CORNER, Corner);
   ObjectSet ("Lot_Edit", OBJPROP_XSIZE, Button_Width - 065);
   ObjectSet ("Lot_Edit", OBJPROP_YSIZE, Font_Size*5);
   ObjectSet ("Lot_Edit", OBJPROP_XDISTANCE, 038 + Move_X);
   ObjectSet ("Lot_Edit", OBJPROP_YDISTANCE, 044 + Move_Y);
   ObjectSetText ("Lot_Edit", Lot, 13, Font_Type, Font_Color);
   
   ObjectCreate ("Lot_Close", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet ("Lot_Close", OBJPROP_CORNER, Corner);
   ObjectSet ("Lot_Close", OBJPROP_XSIZE, Button_Width - 065);
   ObjectSet ("Lot_Close", OBJPROP_YSIZE, Font_Size*5);
   ObjectSet ("Lot_Close", OBJPROP_XDISTANCE, 137 + Move_X);
   ObjectSet ("Lot_Close", OBJPROP_YDISTANCE, 044 + Move_Y);
   ObjectSetText ("Lot_Close", LotCl, 13, Font_Type, Font_Color);
   
   ObjectCreate ("SL_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet ("SL_Edit", OBJPROP_CORNER, Corner);
   ObjectSet ("SL_Edit", OBJPROP_XSIZE, Button_Width*0.50 + 007);
   ObjectSet ("SL_Edit", OBJPROP_YSIZE, Font_Size*2.3);
   ObjectSet ("SL_Edit", OBJPROP_XDISTANCE, 883 + Move_X);
   ObjectSet ("SL_Edit", OBJPROP_YDISTANCE, 044 + Move_Y);
   ObjectSet ("SL_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet ("SL_Edit", OBJPROP_COLOR, CSL);
   ObjectSetText ("SL_Edit", DoubleToStr (Bid, Digits), 13, Font_Type, Font_Color);
   
   ObjectCreate ("TP_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet ("TP_Edit", OBJPROP_CORNER, Corner);
   ObjectSet ("TP_Edit", OBJPROP_XSIZE, Button_Width*0.50 + 007);
   ObjectSet ("TP_Edit", OBJPROP_YSIZE, Font_Size*2.3);
   ObjectSet ("TP_Edit", OBJPROP_XDISTANCE, 883 + Move_X);
   ObjectSet ("TP_Edit", OBJPROP_YDISTANCE, 022 + Move_Y);
   ObjectSet ("TP_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet ("TP_Edit", OBJPROP_COLOR, CTP);
   ObjectSetText ("TP_Edit", DoubleToStr (Bid, Digits), 13, Font_Type, Font_Color);
   
   ObjectCreate ("Price_1_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet    ("Price_1_Edit", OBJPROP_CORNER, Corner);
   ObjectSet    ("Price_1_Edit", OBJPROP_XSIZE, Button_Width*0.50 + 015);
   ObjectSet    ("Price_1_Edit", OBJPROP_YSIZE, Font_Size*2.3);
   ObjectSet    ("Price_1_Edit", OBJPROP_XDISTANCE, 425 + Move_X);
   ObjectSet    ("Price_1_Edit", OBJPROP_YDISTANCE, 44 + Move_Y);
   ObjectSet    ("Price_1_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet    ("Price_1_Edit", OBJPROP_COLOR, CTP);
   ObjectSetText("Price_1_Edit", DoubleToStr (Bid, Digits), 13, Font_Type, Font_Color);
   
   ObjectCreate ("Lot___1_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet    ("Lot___1_Edit", OBJPROP_CORNER, Corner);
   ObjectSet    ("Lot___1_Edit", OBJPROP_XSIZE, Button_Width*0.50 + 015);
   ObjectSet    ("Lot___1_Edit", OBJPROP_YSIZE, Font_Size*2.3);
   ObjectSet    ("Lot___1_Edit", OBJPROP_XDISTANCE, 493 + Move_X);
   ObjectSet    ("Lot___1_Edit", OBJPROP_YDISTANCE, 44 + Move_Y);
   ObjectSet    ("Lot___1_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet    ("Lot___1_Edit", OBJPROP_COLOR, CTP);
   ObjectSetText("Lot___1_Edit", DoubleToStr (0.01, 2), 13, Font_Type, Font_Color);
      
   ObjectCreate ("Step__1_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet    ("Step__1_Edit", OBJPROP_CORNER, Corner);
   ObjectSet    ("Step__1_Edit", OBJPROP_XSIZE, Button_Width*0.50 + 015);
   ObjectSet    ("Step__1_Edit", OBJPROP_YSIZE, Font_Size*2.3);
   ObjectSet    ("Step__1_Edit", OBJPROP_XDISTANCE, 425 + Move_X);
   ObjectSet    ("Step__1_Edit", OBJPROP_YDISTANCE, 22 + Move_Y);
   ObjectSet    ("Step__1_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet    ("Step__1_Edit", OBJPROP_COLOR, CTP);
   ObjectSetText("Step__1_Edit", DoubleToStr (1.5, 1), 13, Font_Type, Font_Color);
   
   ObjectCreate ("Max___1_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet    ("Max___1_Edit", OBJPROP_CORNER, Corner);
   ObjectSet    ("Max___1_Edit", OBJPROP_XSIZE, Button_Width*0.50 + 015);
   ObjectSet    ("Max___1_Edit", OBJPROP_YSIZE, Font_Size*2.3);
   ObjectSet    ("Max___1_Edit", OBJPROP_XDISTANCE, 493 + Move_X);
   ObjectSet    ("Max___1_Edit", OBJPROP_YDISTANCE, 22 + Move_Y);
   ObjectSet    ("Max___1_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet    ("Max___1_Edit", OBJPROP_COLOR, CTP);
   ObjectSetText("Max___1_Edit", DoubleToStr (5, 0), 13, Font_Type, Font_Color);
   
   ObjectDelete ("Price_1_Text");
   ObjectDelete ("Lot___1_Text");
   ObjectDelete ("Gap___1_Text");
   ObjectDelete ("Max___1_Text");
   

   return(INIT_SUCCEEDED);
 
  }
//+------------------------------------------------------------------+  
int start()
  {
   ObjectCreate ("Price_1_Text", OBJ_LABEL, SubWindow, 0, 0);
   ObjectSet    ("Price_1_Text", OBJPROP_CORNER, Corner);
   ObjectSet    ("Price_1_Text", OBJPROP_COLOR, clrBlack);
   ObjectSet    ("Price_1_Text", OBJPROP_BACK, FALSE);
   ObjectSet    ("Price_1_Text", OBJPROP_ANGLE, 90);
   ObjectSet    ("Price_1_Text", OBJPROP_XDISTANCE, 490 + Move_X);
   ObjectSet    ("Price_1_Text", OBJPROP_YDISTANCE, 29 + Move_Y);
   ObjectSetText("Price_1_Text", "$$", 7, "Arial", clrDimGray);
  
   ObjectCreate ("Lot___1_Text", OBJ_LABEL, SubWindow, 0, 0);
   ObjectSet    ("Lot___1_Text", OBJPROP_CORNER, Corner);
   ObjectSet    ("Lot___1_Text", OBJPROP_COLOR, clrBlack);
   ObjectSet    ("Lot___1_Text", OBJPROP_BACK, FALSE);
   ObjectSet    ("Lot___1_Text", OBJPROP_ANGLE, 90);
   ObjectSet    ("Lot___1_Text", OBJPROP_XDISTANCE, 555 + Move_X);
   ObjectSet    ("Lot___1_Text", OBJPROP_YDISTANCE, 29 + Move_Y);
   ObjectSetText("Lot___1_Text", "Lot", 7, "Arial", clrDimGray);  
  
   ObjectCreate ("Gap___1_Text", OBJ_LABEL, SubWindow, 0, 0);
   ObjectSet    ("Gap___1_Text", OBJPROP_CORNER, Corner);
   ObjectSet    ("Gap___1_Text", OBJPROP_COLOR, clrBlack);
   ObjectSet    ("Gap___1_Text", OBJPROP_BACK, FALSE);
   ObjectSet    ("Gap___1_Text", OBJPROP_ANGLE, 90);
   ObjectSet    ("Gap___1_Text", OBJPROP_XDISTANCE, 490 + Move_X);
   ObjectSet    ("Gap___1_Text", OBJPROP_YDISTANCE, 4 + Move_Y);
   ObjectSetText("Gap___1_Text", "Step", 6, "Arial", clrDimGray);
     
   ObjectCreate ("Max___1_Text", OBJ_LABEL, SubWindow, 0, 0);
   ObjectSet    ("Max___1_Text", OBJPROP_CORNER, Corner);
   ObjectSet    ("Max___1_Text", OBJPROP_COLOR, clrBlack);
   ObjectSet    ("Max___1_Text", OBJPROP_BACK, FALSE);
   ObjectSet    ("Max___1_Text", OBJPROP_ANGLE, 90);
   ObjectSet    ("Max___1_Text", OBJPROP_XDISTANCE, 555 + Move_X);
   ObjectSet    ("Max___1_Text", OBJPROP_YDISTANCE, 4 + Move_Y);
   ObjectSetText("Max___1_Text", "Max", 6, "Arial", clrDimGray);

    /* Comment ("Bismillah..." + "   " + "\n",
                "            " + "   " + "\n"
                );
    */   
                
   return(0);
  }  
  
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteButtons();
   ObjectDelete ("Lot_Edit");
   ObjectDelete ("Lot_Close");
   ObjectDelete("SL_Edit");
   ObjectDelete("TP_Edit");
   ObjectDelete ("Price_1_Edit");
   ObjectDelete ("Lot___1_Edit");
   ObjectDelete ("Step__1_Edit");
   ObjectDelete ("Max___1_Edit");
   
   ObjectDelete ("SL______Edit");
   ObjectDelete ("TP______Edit");
   
   ObjectDelete ("Price_1_Text");
   ObjectDelete ("Lot___1_Text");
   ObjectDelete ("Gap___1_Text");
   ObjectDelete ("Max___1_Text");
   
  }
//+------------------------------------------------------------------+
void OnChartEvent (const int id, const long &lparam, const double &dparam, const string &sparam)
    {
     ResetLastError();
     if (id == CHARTEVENT_OBJECT_CLICK) {if (ObjectType (sparam) == OBJ_BUTTON) {ButtonPressed (0, sparam);}}
    }
//+------------------------------------------------------------------+    
void CreateButtons()
    {
     //int Button_Height = Font_Size*2.8;
     int Button_Height = Font_Size*2.3;
     if (!ButtonCreate (0, "Lot_Plus_btn", 0, 010 - 005 + Move_X, 010 + 034 + Move_Y, Button_Width - 070, Button_Height, Corner, "+", Font_Type, Font_Size+3 , Font_Color, CL, CBR)) return;
     if (!ButtonCreate (0, "Lot_Minus_btn", 0, 010 - 005 + Move_X, 010 + 012 + Move_Y, Button_Width - 070, Button_Height, Corner, "-", Font_Type, Font_Size+3 , Font_Color, CL, CBR)) return;
     if (!ButtonCreate (0, "Buy_00000_btn", 0, 010 + 065 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height, Corner, "BUY", Font_Type, Font_Size, Font_Color, CB, CBR)) return;
     if (!ButtonCreate (0, "Sell_0000_btn", 0, 010 + 065 + Move_X, 010 + 012 + Move_Y, Button_Width - 040, Button_Height, Corner, "SELL", Font_Type, Font_Size, Font_Color, CS, CBR)) return;    
     if (!ButtonCreate (0, "Reverse_btn", 0, 010 + 615 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height+22, Corner, "Reverse", Font_Type, Font_Size, Font_Color, CR, CBR)) return;    
     if (!ButtonCreate (0, "Close_Percent_btn", 0, 010 + 164 + Move_X, 012 + 010 + Move_Y, Button_Width - 040, Button_Height, Corner, "Lot Close", Font_Type, Font_Size, Font_Color, CP, CBR)) return;
     if (!ButtonCreate (0, "Close_Buy_btn", 0, 010 + 227 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height, Corner, "Close Buy", Font_Type, Font_Size, Font_Color, CA, CBR)) return;
     if (!ButtonCreate (0, "Close_Sel_btn", 0, 010 + 227 + Move_X, 010 + 012 + Move_Y, Button_Width - 040, Button_Height, Corner, "Close Sell", Font_Type, Font_Size, Font_Color, CA, CBR)) return;
     if (!ButtonCreate (0, "Close_All_btn", 0, 010 + 164 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height, Corner, "Close All", Font_Type, Font_Size, Font_Color, CA, CBR)) return;     
     if (!ButtonCreate (0, "Break_Even_btn", 0, 010 + 680 + Move_X, 010 + 034 + Move_Y, Button_Width - 035, Button_Height, Corner, "Break Even", Font_Type, Font_Size, Font_Color, CBE, CBR)) return; 
     if (!ButtonCreate (0, "ChangeBE_btn", 0, 010 + 680 + Move_X, 010 + 012 + Move_Y, Button_Width - 035, Button_Height, Corner, "SL = BE",Font_Type, Font_Size, Font_Color, CBE, CBR)) return;
     if (!ButtonCreate (0, "SLplusOnebtn", 0, 010 + 750 + Move_X, 010 + 012 + Move_Y, Button_Width - 040, Button_Height, Corner, "SL + 1",Font_Type, Font_Size, Font_Color, CSL, CBR)) return;
     if (!ButtonCreate (0, "DeleteSL_btn", 0, 010 + 750 + Move_X, 010 + 034 + Move_Y, Button_Width*0.65 - 005, Button_Height, Corner, "Delete SL",Font_Type, Font_Size, Font_Color, CSL, CBR)) return;
     if (!ButtonCreate (0, "ChangeSL_btn", 0, 010 + 813 + Move_X, 010 + 034 + Move_Y, Button_Width*0.50 + 010, Button_Height, Corner, "Edit SL >>",Font_Type, Font_Size, Font_Color, CSL, CBR)) return;
     if (!ButtonCreate (0, "ChangeTP_btn", 0, 010 + 813 + Move_X, 010 + 012 + Move_Y, Button_Width*0.50 + 010, Button_Height, Corner, "Edit TP >>",Font_Type, Font_Size, Font_Color, CTP, CBR)) return;

     if (!ButtonCreate (0, "Delete_All___btn", 0, 010 + 290 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height+22, Corner, "Delete All",Font_Type, Font_Size, Font_Color, CDA, clrYellow)) return;
     if (!ButtonCreate (0, "Buy__Limit_1_btn", 0, 010 + 353 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height, Corner, "Buy Limit",Font_Type, Font_Size, Font_Color, CBS, clrYellow)) return;
     if (!ButtonCreate (0, "Sell_Limit_1_btn", 0, 010 + 353 + Move_X, 010 + 012 + Move_Y, Button_Width - 040, Button_Height, Corner, "Sell Limit",Font_Type, Font_Size, Font_Color, CLS, clrYellow)) return;
     
     if (!ButtonCreate (0, "Buy__Stop__1_btn", 0, 010 + 550 + Move_X, 010 + 034 + Move_Y, Button_Width - 040, Button_Height, Corner, "Buy Stop",Font_Type, Font_Size, Font_Color, CBS, clrYellow)) return;
     if (!ButtonCreate (0, "Sell_Stop__1_btn", 0, 010 + 550 + Move_X, 010 + 012 + Move_Y, Button_Width - 040, Button_Height, Corner, "Sell Stop",Font_Type, Font_Size, Font_Color, CLS, clrYellow)) return;
      ChartRedraw();
    }
//+------------------------------------------------------------------+
void DeleteButtons()
    {
     ButtonDelete (0, "Buy_00000_btn");
     ButtonDelete (0, "Sell_0000_btn");
     ButtonDelete (0, "Close_Buy_btn");
     ButtonDelete (0, "Close_Sel_btn");
     ButtonDelete (0, "Close_All_btn");
     ButtonDelete (0, "Lot_Plus_btn");
     ButtonDelete (0, "Lot_Minus_btn");
     ButtonDelete (0, "Break_Even_btn");
     ButtonDelete (0, "Reverse_btn");
     ButtonDelete (0, "Close_Percent_btn");
     ButtonDelete (0, "ChangeBE_btn");
     ButtonDelete (0, "SLplusOnebtn");
     ButtonDelete (0, "DeleteSL_btn");
     ButtonDelete (0, "ChangeSL_btn");
     ButtonDelete (0, "ChangeTP_btn");
     
     ButtonDelete (0, "Delete_All___btn");
     ButtonDelete (0, "Sell_Limit_1_btn");
     ButtonDelete (0, "Buy__Limit_1_btn");
     ButtonDelete (0, "Sell_Stop__1_btn");
     ButtonDelete (0, "Buy__Stop__1_btn");

     
    
    }
//+------------------------------------------------------------------+
void ButtonPressed (const long chartID, const string sparam)
    {
     ObjectSetInteger (chartID, sparam, OBJPROP_BORDER_COLOR, CBR); // button pressed
     if (sparam == "Buy_00000_btn") Buy_00000_Button (sparam);
     if (sparam == "Sell_0000_btn") Sell_0000_Button (sparam);
     if (sparam == "Close_Buy_btn") Close_Buy_Button (sparam);
     if (sparam == "Close_Sel_btn") Close_Sell_Button (sparam);
     if (sparam == "Close_All_btn") Close_All_Button (sparam);
     if (sparam == "Lot_Plus_btn") Lot_Plus_Button (sparam);
     if (sparam == "Lot_Minus_btn") Lot_Minus_Button (sparam);
     if (sparam == "Break_Even_btn") Break_Even_Button (sparam);
     if (sparam == "Reverse_btn") Reverse_Button (sparam);
     if (sparam == "Close_Percent_btn") Close_Percent_Button (sparam);
     if (sparam == "ChangeBE_btn") ChangeBE_Button (sparam);
     if (sparam == "SLplusOnebtn") SLplus1__Button (sparam);
     if (sparam == "DeleteSL_btn") DeleteSL_Button (sparam);
     if (sparam == "ChangeSL_btn") ChangeSL_Button (sparam);
     if (sparam == "ChangeTP_btn") ChangeTP_Button (sparam);
     
     if (sparam == "Delete_All___btn") Delete_All___btn (sparam);
     if (sparam == "Sell_Limit_1_btn") Sell_Limit_1_btn (sparam);
     if (sparam == "Buy__Limit_1_btn") Buy__Limit_1_btn (sparam);
     
     if (sparam == "Sell_Stop__1_btn") Sell_Stop__1_btn (sparam);
     if (sparam == "Buy__Stop__1_btn") Buy__Stop__1_btn (sparam);
     
/*     if (sparam == "Modify_SL____btn") Modify_SL____btn (sparam);
     if (sparam == "Modify_TP____btn") Modify_TP____btn (sparam);*/

     Sleep (100);
     ObjectSetInteger (chartID, sparam, OBJPROP_BORDER_COLOR, CBR); // button unpressed
     ObjectSetInteger (chartID, sparam, OBJPROP_STATE, false); // button unpressed
     ChartRedraw();
    }
//+------------------------------------------------------------------+    
void ToolTips_Text(const string sparam)
  {
   if (sparam == "Lot_Plus_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Lot To Plus");}
   if (sparam == "Lot_Minus_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Lot To Minus");}
   if (sparam == "Buy_00000_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Open BUY Order");}
   if (sparam == "Sell_0000_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Open SELL Order");}
   if (sparam == "Close_Buy_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Close All BUY Orders");}
   if (sparam == "Close_Sel_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Close All SELL Orders");}
   if (sparam == "Close_All_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Close All Open Orders");}
   if (sparam == "Break_Even_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Break Even");}
   if (sparam == "Reverse_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Reverse");}
   if (sparam == "Close_Percent_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Close Percent");}
   
   if (sparam == "ChangeBE_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Set SL to BE for ALL Open Order(s) on **Current Chart** ONLY");}
   if (sparam == "SLplusOnebtn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Add 1 pip to current SL price for ALL Open Order(s) on **Current Chart** ONLY");}
   if (sparam == "DeleteSL_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Remove current SL value for ALL Open Order(s) on **Current Chart** ONLY");}
   if (sparam == "ChangeSL_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Change SL value for ALL Open Order(s) on **Current Chart** ONLY");}
   if (sparam == "ChangeTP_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Change TP value for ALL Open Order(s) on **Current Chart** ONLY");}

   
   if (sparam == "Delete_All___btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Delete ALL Pending Order(s) for **Current Chart** ONLY");}
//   if (sparam == "Modify_SL____btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Modify the SL for ALL Order(s) on **Current Chart** ONLY");}
//   if (sparam == "Modify_TP____btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Modify the TP for ALL Order(s) on **Current Chart** ONLY");}
   if (sparam == "Sell_Limit_1_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Layer Sell Limit Orders from a price point on **Current Chart** ONLY");}
   if (sparam == "Buy__Limit_1_btn") {ObjectSetString (0, sparam, OBJPROP_TOOLTIP, "Layer Buy Limit Orders from a price point on **Current Chart** ONLY");}

  }
  
 int ChangeBE_Button (const string action)
  {
   double Gigits = MarketInfo (Symbol(), MODE_DIGITS);
   if (Gigits == 2) Pekali = 100;
   if (Gigits == 3) Pekali = 100;
   if (Gigits == 4) Pekali = 10000;
   if (Gigits == 5) Pekali = 10000;
   
   double Sel_BE_Price = 0;
   double Buy_BE_Price = 0;
   double Total_Sell_Size = 0;
   double Total_Buy_Size = 0;
   
   for (int k = 0; k < OrdersTotal(); k++)
      {
       OrderSelect (k, SELECT_BY_POS, MODE_TRADES);
       if (OrderSymbol() == Symbol())
         {
          if (OrderType() == OP_BUY)
            {
             Buy_BE_Price += OrderOpenPrice()*OrderLots();
             Total_Buy_Size += OrderLots();
            }
          if (OrderType() == OP_SELL)
            {
             Sel_BE_Price += OrderOpenPrice()*OrderLots();
             Total_Sell_Size += OrderLots();
            }
      }
   }
      
   if (Buy_BE_Price > 0) {Buy_BE_Price /= Total_Buy_Size;}
   if (Sel_BE_Price > 0) {Sel_BE_Price /= Total_Sell_Size;}

   int ticket;
   if (OrdersTotal() == 0) return(0);
   for (int m = OrdersTotal() - 1; m >= 0; m--)
      {
       if (OrderSelect (m, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == OP_BUY && OrderSymbol() == Symbol())
            {
             ticket = OrderModify (OrderTicket(), 0, Buy_BE_Price + 0/Pekali, OrderTakeProfit(), 0, clrNONE);
             if (ticket == -1) Print ("Error : ", GetLastError());
             if (ticket >   0) Print ("SL Position for ", OrderTicket() ," modified.");
            }
          if (OrderType() == OP_SELL && OrderSymbol() == Symbol())
            {
             ticket = OrderModify (OrderTicket(), 0, Sel_BE_Price - 0/Pekali, OrderTakeProfit(), 0, clrNONE);
             if (ticket == -1) Print ("Error : ",  GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
            }
         }
      }
   return(0);
  }
  
 int SLplus1__Button (const string sparam)
  {
   double Gigits = MarketInfo (Symbol(), MODE_DIGITS);
   if (Gigits == 2) Pekali = 100;
   if (Gigits == 3) Pekali = 100;
   if (Gigits == 4) Pekali = 10000;
   if (Gigits == 5) Pekali = 10000;

   int ret;
   if (OrdersTotal() == 0) return(0);
   for (int m = OrdersTotal() - 1; m >= 0; m--)
      {
       if (OrderSelect (m, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
            {
             ret = OrderModify (OrderTicket(), 0, OrderStopLoss() + 1/Pekali, OrderTakeProfit(), 0, clrNONE);
             if (ret == -1) Print ("Error : ", GetLastError());
             if (ret >   0) Print ("SL Position for ", OrderTicket() ," modified.");
            }
          if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
            {
             ret = OrderModify (OrderTicket(), 0, OrderStopLoss() - 1/Pekali, OrderTakeProfit(), 0, clrNONE);
             if (ret == -1) Print ("Error : ",  GetLastError());
             if (ret >   0) Print ("Position ", OrderTicket() ," closed");
            }            
         }
      }
   return(0);
  } 
  
  int DeleteSL_Button (const string sparam)
  {
   int ret;
   if (OrdersTotal() == 0) return(0);
   for (int n = OrdersTotal() - 1; n >= 0; n--)
      {
       if (OrderSelect (n, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
            {
             ret = OrderModify (OrderTicket(), 0, 0, OrderTakeProfit(), 0, clrNONE);
             if (ret == -1) Print ("Error : ", GetLastError());
             if (ret >   0) Print ("SL Position for ", OrderTicket() ," modified.");
            }
          if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
            {
             ret = OrderModify (OrderTicket(), 0, 0, OrderTakeProfit(), 0, clrNONE);
             if (ret == -1) Print ("Error : ",  GetLastError());
             if (ret >   0) Print ("Position ", OrderTicket() ," closed");
            }            
         }
      }
   return(0);
  }
  
 int ChangeSL_Button (const string sparam)
  {
   double SL_Extract = StrToDouble (ObjectGetString (0, "SL_Edit", OBJPROP_TEXT, 0));
   int ret;
   if (OrdersTotal() == 0) return(0);
   for (int n = OrdersTotal() - 1; n >= 0; n--)
      {
       if (OrderSelect (n, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == OP_BUY && OrderSymbol() == Symbol())
            {
             ret = OrderModify (OrderTicket(), 0, SL_Extract, OrderTakeProfit(), 0, clrNONE);
             if (ret == -1) Print ("Error : ", GetLastError());
             if (ret >   0) Print ("SL Position for ", OrderTicket() ," modified.");
            }
          if (OrderType() == OP_SELL && OrderSymbol() == Symbol())
            {
             ret = OrderModify (OrderTicket(), 0, SL_Extract, OrderTakeProfit(), 0, clrNONE);
             if (ret == -1) Print ("Error : ",  GetLastError());
             if (ret >   0) Print ("Position ", OrderTicket() ," closed");
            }            
         }
      }
   return(0);
  } 
  
  int ChangeTP_Button (const string sparam)
  {
   double TP_Extract = StrToDouble (ObjectGetString (0, "TP_Edit", OBJPROP_TEXT, 0));
   int ret;
   if (OrdersTotal() == 0) return(0);
   for (int n = OrdersTotal() - 1; n >= 0; n--)
      {
       if (OrderSelect (n, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == OP_BUY && OrderSymbol() == Symbol())
            {
             ret = OrderModify (OrderTicket(), 0, OrderStopLoss(), TP_Extract, 0, clrNONE);
             if (ret == -1) Print ("Error : ", GetLastError());
             if (ret >   0) Print ("SL Position for ", OrderTicket() ," modified.");
            }
          if (OrderType() == OP_SELL && OrderSymbol() == Symbol())
            {
             ret = OrderModify (OrderTicket(), 0, OrderStopLoss(), TP_Extract, 0, clrNONE);
             if (ret == -1) Print ("Error : ",  GetLastError());
             if (ret >   0) Print ("Position ", OrderTicket() ," closed");
            }            
         }
      }
   return(0);
  }
  
//+------------------------------------------------------------------+
int Lot_Plus_Button (const string sparam)
  {
  double Lot_Extract = NormalizeDouble(StrToDouble (ObjectGetString (0, "Lot_Edit", OBJPROP_TEXT, 0)),2);
  ObjectSetText ("Lot_Edit", DoubleToStr(Lot_Extract+0.01,2) , 13, Font_Type, Font_Color);
  PlaySound("click.wav");
   return(0);
  }
//+------------------------------------------------------------------+  
int Lot_Minus_Button (const string sparam)
  {
  double Lot_Extract = NormalizeDouble(StrToDouble (ObjectGetString (0, "Lot_Edit", OBJPROP_TEXT, 0)),2);
  if (Lot_Extract>=0.02) ObjectSetText ("Lot_Edit", DoubleToStr(Lot_Extract-0.01,2) , 13, Font_Type, Font_Color);
  PlaySound("click.wav");
   return(0);
  }
//+------------------------------------------------------------------+
int Close_Buy_Button (const string sparam)
  {   
   if (OrdersTotal() == 0) return(0);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
       if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == 0 && OrderSymbol() == Symbol())
            {
             ticket = OrderClose (OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
             if (ticket == -1) Print ("Error: ", GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
             PlaySound("click.wav");
            }
         }
      }
   return(0);
  }
//+------------------------------------------------------------------+
int Close_Sell_Button (const string sparam)
  {   
   if (OrdersTotal() == 0) return(0);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
       if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == 1 && OrderSymbol() == Symbol())
            {
             ticket = OrderClose (OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
             if (ticket == -1) Print ("Error: ",  GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
             PlaySound("click.wav");
            }   
         }
      }
   return(0);
  }
//+------------------------------------------------------------------+
int Close_All_Button (const string sparam)
  {   
   if (OrdersTotal() == 0) return(0);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
       if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderType() == 0 && OrderSymbol() == Symbol())
            {
             ticket = OrderClose (OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
             if (ticket == -1) Print ("Error: ", GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
             PlaySound("click.wav");
            }
          if (OrderType() == 1 && OrderSymbol() == Symbol())
            {
             ticket = OrderClose (OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
             if (ticket == -1) Print ("Error: ",  GetLastError());
             if (ticket >   0) Print ("Position ", OrderTicket() ," closed");
             PlaySound("click.wav");
            }   
         }
      }
   return(0);
  }
//+------------------------------------------------------------------+
int Buy_00000_Button (const string sparam)
  {
   double Lot_Extract = StrToDouble (ObjectGetString (0, "Lot_Edit", OBJPROP_TEXT, 0));
   ticket = OrderSend (Symbol(), OP_BUY, Lot_Extract, Ask, 0, 0, 0, "BUY", 12345601, 0, CLR_NONE);
   SlTp();
   PlaySound("click.wav");  
   return(0);
  }
//+------------------------------------------------------------------+
int Sell_0000_Button (const string sparam)
  {
   double Lot_Extract = StrToDouble (ObjectGetString (0, "Lot_Edit", OBJPROP_TEXT, 0));
   ticket = OrderSend (Symbol(), OP_SELL, Lot_Extract, Bid, 0, 0, 0, "SELL", 12345602, 0, CLR_NONE);
   SlTp();
   PlaySound("click.wav");
   return(0);
  }
//+------------------------------------------------------------------+  
int Reverse_Button (const string sparam)
{ 
   int total=OrdersTotal();
   int i = 0;
   for(i = total; i >=0; i--)
   {
     if(OrderSelect(i,SELECT_BY_POS) &&  OrderSymbol()==Symbol())
     {
       if(OrderType()==OP_BUY)
       { 
          ticket = OrderSend(Symbol(),OP_SELL,OrderLots()*Koeff,Bid,slip,0,0,"Reverse Sell",0,0,clrNONE);
          ticket = OrderClose(OrderTicket(),OrderLots(),Bid,slip,clrNONE);
          PlaySound("click.wav");
          SlTp();         
       }
                         
       else if(OrderType()==OP_SELL)
       {
         ticket = OrderSend(Symbol(),OP_BUY,OrderLots()*Koeff,Ask,slip,0,0,"Reverse Buy",0,0,clrNONE);
         ticket = OrderClose(OrderTicket(),OrderLots(),Ask,slip,clrNONE);
         PlaySound("click.wav");
         SlTp();
       } 
     }
   }
   return(0);
}
//+------------------------------------------------------------------+ 
int Break_Even_Button (const string sparam)
{
   itotal=OrdersTotal();
   
   for(int cnt=itotal-1;cnt>=0;cnt--) 
   {
     if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      
     if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && Bid < OrderOpenPrice())
     {
       Alert("Unable to place SL Break Even - Bid below Order Open Price - Trade in Loss");
       return(0);
     }   
      
     if(OrderSymbol()==Symbol() && OrderType()==OP_SELL  && Ask > OrderOpenPrice())
     {
       Alert("Unable to place SL Break Even - Ask above Order Open Price - Trade in Loss");
       return(0);
     }   
        
     if (OrderSymbol()==Symbol() && OrderType()==OP_BUY)
     {
       ModifyStopLoss(OrderOpenPrice()+RrEv*_Point);    
       PlaySound("click.wav"); 
     }
      
     if (OrderSymbol()==Symbol() && OrderType()==OP_SELL)
     {
        ModifyStopLoss(OrderOpenPrice()-RrEv*_Point);     
        PlaySound("click.wav");  
     }    
   }
  return(0);
}
//+------------------------------------------------------------------+
int Close_Percent_Button (const string sparam)
{ 
   int total=OrdersTotal();
   double Lot_Extract = NormalizeDouble(StrToDouble (ObjectGetString (0, "Lot_Close", OBJPROP_TEXT, 0)),2);
   int i = 0;
   for(i = total; i >=0; i--)
   {
     if(OrderSelect(i,SELECT_BY_POS) &&  OrderSymbol()==Symbol())
     {
       if(OrderType()==OP_BUY)
       { 
          ticket = OrderClose(OrderTicket(),Lot_Extract,MODE_BID,slip,clrNONE);
          SlTp();
          PlaySound("click.wav");         
       }
            
       if(OrderType()==OP_SELL)
       {
         ticket = OrderClose(OrderTicket(),Lot_Extract,MODE_ASK,slip,clrNONE);
         SlTp();
         PlaySound("click.wav");         
       }
     }
   }
   return(0); 
}

/////////////
int Delete_All___btn (const string sparam)
  {   
   int ticket;
   if (OrdersTotal() == 0) return(0);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
       if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderSymbol() == Symbol()) 
            {
             if (OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
               {
                ticket = OrderDelete (OrderTicket(), clrNONE);
                if (ticket == -1) Print ("Error : ",  GetLastError());
                if (ticket >   0) Print ("Position ", OrderTicket(), " closed");
               }
             }  
         }
      }
   return(0);
  }

/*int Modify_SL____btn (const string sparam)
  {
   double SL = StrToDouble (ObjectGetString (0, "SL______Edit", OBJPROP_TEXT, 0));
   int ticket;
   if (OrdersTotal() == 0) return(0);
   for (int n = OrdersTotal() - 1; n >= 0; n--)
      {
       if (OrderSelect (n, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderSymbol() == Symbol()) 
            {
             if (OrderType() == OP_BUY || OrderType() == OP_SELL || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
               {
                ticket = OrderModify (OrderTicket(), OrderOpenPrice(), NormalizeDouble (SL, Digits), OrderTakeProfit(), 0, clrNONE);
                if (ticket == -1) Print ("Error : ",  GetLastError());
                if (ticket >   0) Print ("SL Position for ", OrderTicket(), " modified.");
               }
             }  
         }
      }
   return(0);
  }

int Modify_TP____btn (const string sparam)
  {
   double TP = StrToDouble (ObjectGetString (0, "TP______Edit", OBJPROP_TEXT, 0));
   int ticket;
   if (OrdersTotal() == 0) return(0);
   for (int n = OrdersTotal() - 1; n >= 0; n--)
      {
       if (OrderSelect (n, SELECT_BY_POS, MODE_TRADES) == true)
         {
          if (OrderSymbol() == Symbol()) 
            {
             if (OrderType() == OP_BUY || OrderType() == OP_SELL || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
               {
                ticket = OrderModify (OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble (TP, Digits), 0, clrNONE);
                if (ticket == -1) Print ("Error : ",  GetLastError());
                if (ticket >   0) Print ("TP Position for ", OrderTicket() , " modified.");
               }
             }  
         }
      }   
   return(0);
  }*/

int Sell_Limit_1_btn (const string sparam)
  {
   int Max = StrToInteger (ObjectGetString (0, "Max___1_Edit", OBJPROP_TEXT, 0));
   double Lot = StrToDouble (ObjectGetString (0, "Lot___1_Edit", OBJPROP_TEXT, 0));
   double Gap = StrToDouble (ObjectGetString (0, "Step__1_Edit", OBJPROP_TEXT, 0));
   double Price = StrToDouble (ObjectGetString (0, "Price_1_Edit", OBJPROP_TEXT, 0));
   
   double Gigits = MarketInfo (Symbol(), MODE_DIGITS);
   if (Gigits == 2 || Gigits == 3) Pekali = 100;
   if (Gigits == 4 || Gigits == 5) Pekali = 10000;
   
   int ticket;
   for (int i = Max - 1; i >= 0; i--)
      {
       ticket = OrderSend (Symbol(), OP_SELLLIMIT, Lot, NormalizeDouble (Price + Gap*i/Pekali, Digits), 0, 0, 0, "", 12345612, 0, clrNONE);
       if (ticket == -1) Print ("Error : ",  GetLastError());
       if (ticket >   0) Print ("Sell Limit #", IntegerToString (Max - i, 0), " succesfuly placed.");
      }
   return(0);
  }

int Buy__Limit_1_btn (const string sparam)
  {
   int    Max   = StrToInteger (ObjectGetString (0, "Max___1_Edit", OBJPROP_TEXT, 0));
   double Lot   = StrToDouble  (ObjectGetString (0, "Lot___1_Edit", OBJPROP_TEXT, 0));
   double Gap   = StrToDouble  (ObjectGetString (0, "Step__1_Edit", OBJPROP_TEXT, 0));
   double Price = StrToDouble  (ObjectGetString (0, "Price_1_Edit", OBJPROP_TEXT, 0));
   
   double Gigits = MarketInfo (Symbol(), MODE_DIGITS);
   if (Gigits == 2 || Gigits == 3) Pekali = 100;
   if (Gigits == 4 || Gigits == 5) Pekali = 10000;
   
   int ticket;
   for (int i = Max - 1; i >= 0; i--)
      {
       ticket = OrderSend (Symbol(), OP_BUYLIMIT, Lot, NormalizeDouble (Price-(Max*Gap/Pekali) + Gap*i/Pekali, Digits), 0, 0, 0, "", 12345612, 0, clrNONE);
       if (ticket == -1) Print ("Error : ",  GetLastError());
       if (ticket >   0) Print ("Buy Limit #", IntegerToString (Max - i, 0), " succesfuly placed.");
      }
   return(0);
  }

int Sell_Stop__1_btn (const string sparam)
  {
   int Max = StrToInteger (ObjectGetString (0, "Max___1_Edit", OBJPROP_TEXT, 0));
   double Lot = StrToDouble (ObjectGetString (0, "Lot___1_Edit", OBJPROP_TEXT, 0));
   double Gap = StrToDouble (ObjectGetString (0, "Step__1_Edit", OBJPROP_TEXT, 0));
   double Price = StrToDouble (ObjectGetString (0, "Price_1_Edit", OBJPROP_TEXT, 0));
   
   double Gigits = MarketInfo (Symbol(), MODE_DIGITS);
   if (Gigits == 2 || Gigits == 3) Pekali = 100;
   if (Gigits == 4 || Gigits == 5) Pekali = 10000;
   
   int ticket;
   for (int i = Max - 1; i >= 0; i--)
      {
       ticket = OrderSend (Symbol(), OP_SELLSTOP, Lot, NormalizeDouble (Price-((Max-1)*Gap/Pekali) + Gap*i/Pekali, Digits), 0, 0, 0, "", 12345612, 0, clrNONE);
       if (ticket == -1) Print ("Error : ",  GetLastError());
       if (ticket >   0) Print ("Sell Limit #", IntegerToString (Max - i, 0), " succesfuly placed.");
      }
   return(0);
  }

int Buy__Stop__1_btn (const string sparam)
  {
   int    Max   = StrToInteger (ObjectGetString (0, "Max___1_Edit", OBJPROP_TEXT, 0));
   double Lot   = StrToDouble  (ObjectGetString (0, "Lot___1_Edit", OBJPROP_TEXT, 0));
   double Gap   = StrToDouble  (ObjectGetString (0, "Step__1_Edit", OBJPROP_TEXT, 0));
   double Price = StrToDouble  (ObjectGetString (0, "Price_1_Edit", OBJPROP_TEXT, 0));
   
   double Gigits = MarketInfo (Symbol(), MODE_DIGITS);
   if (Gigits == 2 || Gigits == 3) Pekali = 100;
   if (Gigits == 4 || Gigits == 5) Pekali = 10000;
   
   int ticket;
   for (int i = Max - 1; i >= 0; i--)
      {
       ticket = OrderSend (Symbol(), OP_BUYSTOP, Lot, NormalizeDouble (Price + Gap*i/Pekali, Digits), 0, 0, 0, "", 12345612, 0, clrNONE);
       if (ticket == -1) Print ("Error : ",  GetLastError());
       if (ticket >   0) Print ("Buy Limit #", IntegerToString (Max - i, 0), " succesfuly placed.");
      }
   return(0);
  }

/////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
bool ButtonCreate (const long chart_ID=0, const string name="Button", const int sub_window=0, const int x=0, const int y=0, const int width=500,
                   const int height=18, int corner=0, const string text="Button", const string font="Arial Bold",
                   const int font_size=14, const color clr=clrBlack, const color back_clr=clrBlack, const color border_clr=clrNONE,
                   const bool state=false, const bool back=false, const bool selection=false, const bool hidden=true, const long z_order=0)
  {
   ResetLastError();
   if (!ObjectCreate (chart_ID,name, OBJ_BUTTON, SubWindow, 0, 0))
     {
      Print (__FUNCTION__, ": failed to create the button! Error code = ", GetLastError());
      return(false);
     }
   ObjectSetInteger (chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger (chart_ID, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger (chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger (chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetInteger (chart_ID, name, OBJPROP_CORNER, corner);
   ObjectSetInteger (chart_ID, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger (chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger (chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger (chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
   ObjectSetInteger (chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger (chart_ID, name, OBJPROP_STATE, state);
   ObjectSetInteger (chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger (chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger (chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger (chart_ID, name, OBJPROP_ZORDER,z_order);
   ObjectSetString  (chart_ID, name, OBJPROP_TEXT, text);
   ObjectSetString  (chart_ID, name, OBJPROP_FONT, font);
   return(true);
  }
//+------------------------------------------------------------------+  
bool ButtonDelete (const long chart_ID=0, const string name="Button")
  {
   ResetLastError();
   if (!ObjectDelete (chart_ID,name))
     {
      Print (__FUNCTION__, ": Failed to delete the button! Error code = ", GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+  
 void ModifyStopLoss(double ldStopLoss) 
{
   bool fmSL;
   fmSL=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
} 
//+------------------------------------------------------------------+
void SlTp()
  {
   int TotalModified=0;
   for(int i=OrdersTotal()-1; i>=0; i--){
   
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         continue;
      } 

      if(OrderSymbol()!=Symbol()) continue;
      
      double TakeProfitPrice=0;
      double StopLossPrice=0;
      double OpenPrice=OrderOpenPrice();
      RefreshRates();
      if(OrderType()==OP_BUY){
      if (TakeProfit > 0) TakeProfitPrice=NormalizeDouble(OpenPrice+TakeProfit*_Point,Digits);
      else TakeProfitPrice=0;
      if (StopLoss > 0) StopLossPrice=NormalizeDouble(OpenPrice-StopLoss*_Point,Digits);
      else StopLossPrice=0;
      } 
      if(OrderType()==OP_SELL){
      if (TakeProfit > 0) TakeProfitPrice=NormalizeDouble(OpenPrice-TakeProfit*_Point,Digits);
      else TakeProfitPrice=0;
      if (StopLoss > 0) StopLossPrice=NormalizeDouble(OpenPrice+StopLoss*_Point,Digits);
      else StopLossPrice=0;      
      }
         
      //Try to modify the order
      if(OrderModify(OrderTicket(),OpenPrice,StopLossPrice,TakeProfitPrice,0,clrNONE)){
         TotalModified++;
      }
      else{
         Print("Order failed to update with error - ",GetLastError());
      }      
   }
   Print("Total orders modified = ",TotalModified);
  }