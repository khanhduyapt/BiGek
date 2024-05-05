//--------------------------------------------------------------------
// modifystoploss.mq4
// Предназначен для использования в качестве примера в учебнике MQL4.
//--------------------------------------------------------------------
extern int Tral_Stop=10;                        // Дист. преследования
//--------------------------------------------------------------- 1 --
int start()                                     // Спец. функция start
  {
   string Symb=Symbol();                        // Финанс. инструмент
//--------------------------------------------------------------- 2 --
   for(int i=1; i<=OrdersTotal(); i++)          // Цикл перебора ордер
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // Если есть следующий
        {                                       // Анализ ордеров:
         int Tip=OrderType();                   // Тип ордера
         if(OrderSymbol()!=Symb||Tip>1)continue;// Не наш ордер
         double SL=OrderStopLoss();             // SL выбранного орд.
         //------------------------------------------------------ 3 --
         while(true)                            // Цикл модификации
           {
            double TS=Tral_Stop;                // Исходное значение
            int Min_Dist=MarketInfo(Symb,MODE_STOPLEVEL);//Миним. дист
            if (TS<Min_Dist)                    // Если меньше допуст.
               TS=Min_Dist;                     // Новое значение TS
            //--------------------------------------------------- 4 --
            bool Modify=false;                  // Не назначен к модифи
            switch(Tip)                         // По типу ордера
              {
               case 0 :                         // Ордер Buy
                  if (NormalizeDouble(SL,Digits)< // Если ниже желаем.
                     NormalizeDouble(Bid-TS*Point,Digits))
                    {
                     SL=Bid-TS*Point;           // то модифицируем его
                     string Text="Buy ";        // Текст для Buy 
                     Modify=true;               // Назначен к модифи.
                    }
                  break;                        // Выход из switch
               case 1 :                         // Ордер Sell
                  if (NormalizeDouble(SL,Digits)> // Если выше желаем.
                     NormalizeDouble(Ask+TS*Point,Digits)
                     || NormalizeDouble(SL,Digits)==0)//или равно нулю
                    {
                     SL=Ask+TS*Point;           // то модифицируем его
                     Text="Sell ";              // Текст для Sell 
                     Modify=true;               // Назначен к модифи.
                    }
              }                                 // Конец switch
            if (Modify==false)                  // Если его не модифи
               break;                           // Выход из while
            //--------------------------------------------------- 5 --
            double TP    =OrderTakeProfit();    // TP выбранного орд.
            double Price =OrderOpenPrice();     // Цена выбранн. орд.
            int    Ticket=OrderTicket();        // Номер выбранн. орд.

            Alert ("Модификация ",Text,Ticket,". Ждём ответ..");
            bool Ans=OrderModify(Ticket,Price,SL,TP,0);//Модифи его!
            //--------------------------------------------------- 6 --
            if (Ans==true)                      // Получилось :)
              {
               Alert ("Ордер ",Text,Ticket," модифицирован:)");
               break;                           // Из цикла модифи.
              }
            //--------------------------------------------------- 7 --
            int Error=GetLastError();           // Не получилось :(
            switch(Error)                       // Преодолимые ошибки
              {
               case 130:Alert("Неправильные стопы. Пробуем ещё раз.");
                  RefreshRates();               // Обновим данные
                  continue;                     // На след. итерацию
               case 136:Alert("Нет цен. Ждём новый тик..");
                  while(RefreshRates()==false)  // До нового тика
                     Sleep(1);                  // Задержка в цикле
                  continue;                     // На след. итерацию
               case 146:Alert("Подсистема торгов занята.Пробуем ещё");
                  Sleep(500);                   // Простое решение
                  RefreshRates();               // Обновим данные
                  continue;                     // На след. итерацию
                  // Критические ошибки
               case 2 : Alert("Общая ошибка.");
                  break;                        // Выход из switch
               case 5 : Alert("Старая версия клиентского терминала.");
                  break;                        // Выход из switch
               case 64: Alert("Счет заблокирован.");
                  break;                        // Выход из switch
               case 133:Alert("Торговля запрещена");
                  break;                        // Выход из switch
               default: Alert("Возникла ошибка ",Error);//Др. ошибки
              }
            break;                              // Из цикла модифи.
           }                                    // Конец цикла модифи.
         //------------------------------------------------------ 8 --
        }                                       // Конец анализа орд.
     }                                          // Конец перебора орд.
//--------------------------------------------------------------- 9 --
   return;                                      // Выход из start()
  }
//-------------------------------------------------------------- 10 --