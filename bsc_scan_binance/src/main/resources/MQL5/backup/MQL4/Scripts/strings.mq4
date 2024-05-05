//--------------------------------------------------------------------
// strings.mq4
// Предназначен для использования в качестве примера в учебнике MQL4.
//--------------------------------------------------------------- 1 --
extern int Quant_Bars=100;             // Количество баров
datetime   Time_On;
string     Prefix    ="Paint_";
//--------------------------------------------------------------- 2 --
int init()                             // Спец. функция init()
  {
   int Ind_Bar;                        // Индекс бара
   Time_On=Time [Quant_Bars];          // Время первого раскрашенного
   for(Ind_Bar=Quant_Bars-1; Ind_Bar>=0; Ind_Bar--)// Цикл по барам
     {
      Create(Ind_Bar,1);               // Нарисуем тонкую линию
      Create(Ind_Bar,2);               // Нарисуем толстую линию
     }
   WindowRedraw();                     // Перерисовка изображения 
   return;                             // Выход из init()
  }
//--------------------------------------------------------------- 3 --
int start()                            // Спец. функция start
  {
   datetime T1, T2;                    // 1 и 2 координаты времени
   int Error,Ind_Bar;                  // Код ошибки и индекс бара
   double P1, P2;                      // 1 и 2 координата цены
   color Col;                          // Цвет созданного объекта
//--------------------------------------------------------------- 4 --
   for(int Line=1; Line<=2; Line++)    // Цикл по видам линий
     {
      string Nom_Lin =Line + "_";      // Строка с номером линии
      //    string Nom_Lin  = DoubleToStr(Line,0)+"_";// Можно и так
      for(Ind_Bar=0; ;Ind_Bar++)       // Цикл по барам
        {
//--------------------------------------------------------------- 5 --
         datetime T_Bar= Time[Ind_Bar];// Время открытия бара
         if (T_Bar < Time_On) break;   // Заграничные не раскрашиваем
         string Str_Time=TimeToStr(T_Bar);       // Строка со временем
         string His_Name=Prefix+Nom_Lin+Str_Time;// Имя объекта
//--------------------------------------------------------------- 6 --
         T1=ObjectGet(His_Name,OBJPROP_TIME1);// Запрос коорд. t1
         Error=GetLastError();         // Получение кода ошибки
         if (Error==4202)              // Если объекта нет :(
           {
            Create(Ind_Bar,Line);      // Вызов ф-ии создания объек
            continue;                  // На следующую итерацию
           }
//--------------------------------------------------------------- 7 --
         T2 =ObjectGet(His_Name,OBJPROP_TIME2); // Запрос коорд. t2
         P1 =ObjectGet(His_Name,OBJPROP_PRICE1);// Запрос коорд. p1
         P2 =ObjectGet(His_Name,OBJPROP_PRICE2);// Запрос коорд. p1
         Col=ObjectGet(His_Name,OBJPROP_COLOR); // Запрос цвета
         if(T1!=T_Bar || T2!=T_Bar || // Не те координаты или цвет:
            (Line==1 && (P1!=High[Ind_Bar] || P2!=  Low[Ind_Bar])) ||
            (Line==2 && (P1!=Open[Ind_Bar] || P2!=Close[Ind_Bar])) ||
            (Open[Ind_Bar] <Close[Ind_Bar] && Col!=Blue) ||
            (Open[Ind_Bar] >Close[Ind_Bar] && Col!=Red)  ||
            (Open[Ind_Bar]==Close[Ind_Bar] && Col!=Green)  )
           {
            ObjectDelete(His_Name);    // Удаляем объект
            Create(Ind_Bar,Line);      // Создаём правильный объект
           }
//--------------------------------------------------------------- 8 --
        }
     }
   WindowRedraw();                     // Перерисовка изображения 
   return;                             // Выход из start()
  }
//--------------------------------------------------------------- 9 --
int deinit()                           // Спец. функция deinit()
  {
   string Name_Del[1];                 // Объявление массива
   int Quant_Del=0;                    // Количество удаляемых объекто
   int Quant_Objects=ObjectsTotal();   // Cтолько всего ВСЕХ объектов
   ArrayResize(Name_Del,Quant_Objects);// Необходимый размер массива
   for(int k=0; k<Quant_Objects; k++)  // По количеству объектов 
     {
      string Obj_Name=ObjectName(k);   // Запрашиваем имя объекта
      string Head=StringSubstr(Obj_Name,0,6);// Извлекаем первые 6 сим
      if (Head==Prefix)                // Найден объект, ..
        {                              // .. начинающийся с Paint_
         Quant_Del=Quant_Del+1;        // Колич имён к удалению
         Name_Del[Quant_Del-1]=Obj_Name;//Запоминаем имя удаляемого
        }
     }
   for(int i=0; i<=Quant_Del; i++)     // Удаляем объекты с именами,.. 
      ObjectDelete(Name_Del[i]);       // .. имеющимися в массиве
   return;                             // Выход из deinit()
  }
//-------------------------------------------------------------- 10 --
int Create(int Ind_Bar, int Line)      // Пользовательская функция..
  {                                    // ..создания объекта
   color Color;                        // Цвет объекта
   datetime T_Bar=Time [Ind_Bar];      // Время открытия бара
   double   O_Bar=Open [Ind_Bar];      // Цена открытия бара
   double   C_Bar=Close[Ind_Bar];      // Цена закрытия бара
   double   H_Bar=High [Ind_Bar];      // Максимальная цена бара
   double   L_Bar=Low  [Ind_Bar];      // Минимальная цена бара

   string Nom_Lin =Line + "_";         // Строка - номер линии
   // string Nom_Lin  = DoubleToStr(Line,0)+"_";// Можно и так
   string Str_Time=TimeToStr(T_Bar);   // Строка - время откр.     
   string His_Name=Prefix+Nom_Lin+Str_Time;// Имя созаваемого объект
   if (O_Bar < C_Bar) Color=Blue;      // Выбор цвета в зависимости..
   if (O_Bar > C_Bar) Color=Red;       // .. от характеристик бара
   if (O_Bar ==C_Bar) Color=Green;

   switch(Line)                        // Тонкая или толстая линия
     {
      case 1:                          // Тонкая линия
         ObjectCreate(His_Name,OBJ_TREND,0,T_Bar,H_Bar,T_Bar,L_Bar);
         break;                        // Выход из switch
      case 2:                          // Толстая линия
         ObjectCreate(His_Name,OBJ_TREND,0,T_Bar,O_Bar,T_Bar,C_Bar);
         ObjectSet(   His_Name, OBJPROP_WIDTH, 3);// Стиль     
     }
   ObjectSet(    His_Name, OBJPROP_COLOR, Color); // Цвет
   ObjectSet(    His_Name, OBJPROP_RAY,   false); // Луч
   ObjectSetText(His_Name,"Объект создан экспертом",10);// Описание
   return;                             // Выход из польз. ф-ии
  }
//-------------------------------------------------------------- 11 --