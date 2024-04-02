//--------------------------------------------------------------------
// conditions.mq4 
// Предназначен для использования в качестве примера в учебнике MQL4.
//--------------------------------------------------------------------
int start()                                      // Спец.функция start
  {
   Alert(Symbol(),"  Sell = ",AccountFreeMargin()// При продаже
         -AccountFreeMarginCheck(Symbol(),OP_SELL,1));
   Alert(Symbol(),"  Buy = ",AccountFreeMargin() // При покупке
         -AccountFreeMarginCheck(Symbol(),OP_BUY,1));
   return;                                       // Выход из start()
  }
//--------------------------------------------------------------------