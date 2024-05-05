//--------------------------------------------------------------------
// improved.mq4 
// Предназначен для использования в качестве примера в учебнике MQL4.
//--------------------------------------------------------------------
int start()                                     // Спец. функция start
  {
   double bid   =MarketInfo("GBPUSD",MODE_BID); // Запрос значения Bid
   double ask   =MarketInfo("GBPUSD",MODE_ASK); // Запрос значения Ask
   double point =MarketInfo("GBPUSD",MODE_POINT);//Запрос Point
   // Открытие BUY
   OrderSend("GBPUSD",OP_BUY,0.1,ask,3,bid-15*Point,bid+15*Point);
   Alert (GetLastError());                      // Сообщение об ошибке
   return;                                      // Выход из start()
  }
//--------------------------------------------------------------------