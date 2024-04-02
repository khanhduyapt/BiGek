//--------------------------------------------------------------------
// deleteorder.mq4 
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------- 1 --
int start()                                     // ����.������� start
  {
   string Symb=Symbol();                      // ������. ����������
   double Dist=1000000.0;                     // �������������
   int Limit_Stop=-1;                         // ���� ���������� ���
   double Win_Price=WindowPriceOnDropped();     // ����� ������ ������
//--------------------------------------------------------------- 2 --
   for(int i=1; i<=OrdersTotal(); i++)         // ���� �������� �����
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // ���� ���� ���������
        {                                      // ������ �������:
         //------------------------------------------------------ 3 --
         if (OrderSymbol()!= Symb) continue;    // �� ��� ���.�������.
         int Tip=OrderType();                 // ��� ������
         if (Tip<2) continue;                   // �������� �����  
         //------------------------------------------------------ 4 --
         double Price=OrderOpenPrice();       // ���� ������
         if (NormalizeDouble(MathAbs(Price-Win_Price),Digits)< //�����
            NormalizeDouble(Dist,Digits))       // ������ �������� ���       
           {
            Dist=MathAbs(Price-Win_Price);      // ����� ��������
            Limit_Stop=Tip;                   // ���� �������. �����
            int Ticket=OrderTicket();         // ����� ������
           }                                   // ����� if
        }                                      //����� ������� ������
     }                                         // ����� �������� ���.
//--------------------------------------------------------------- 5 --
   switch(Limit_Stop)                          // �� ���� ������
     {
      case 2: string Text= "BuyLimit ";         // ����� ��� BuyLimit
         break;                            // ����� �� switch
      case 3: Text= "SellLimit ";               // ����� ��� SellLimit
         break;                            // ����� �� switch
      case 4: Text= "BuyStopt ";                // ����� ��� BuyStopt
         break;                            // ����� �� switch
      case 5: Text= "SellStop ";                // ����� ��� SellStop
         break;                            // ����� �� switch
     }
//--------------------------------------------------------------- 6 --
   while(true)                                 // ���� �������� ���.
     {
      if (Limit_Stop==-1)                     // ���� ���������� ���
        {
         Alert("�� ",Symb," ���������� ������� ���");
         break;                                 // ����� �� ����� ����        
        }
      //--------------------------------------------------------- 7 --
      Alert("������� ������� ",Text," ",Ticket,". �������� ������..");
      bool Ans=OrderDelete(Ticket);             // �������� ������
      //--------------------------------------------------------- 8 --
      if (Ans==true)                            // ���������� :)
        {
         Alert ("����� ����� ",Text," ",Ticket);
         break;                                 // ����� �� ����� ����
        }
      //--------------------------------------------------------- 9 --
      int Error=GetLastError();               // �� ���������� :(
      switch(Error)                            // ����������� ������
        {
         case  4: Alert("�������� ������ �����. ������� ��� ���..");
            Sleep(3000);                  // ������� �������
            continue;                     // �� ����. ��������
         case 137:Alert("������ �����. ������� ��� ���..");
            Sleep(3000);                  // ������� �������
            continue;                     // �� ����. ��������
         case 146:Alert("���������� �������� ������. ������� ���..");
            Sleep(500);                   // ������� �������
            continue;                     // �� ����. ��������
        }
      switch(Error)                            // ����������� ������
        {
         case 2 : Alert("����� ������.");
            break;                        // ����� �� switch
         case 64: Alert("���� ������������.");
            break;                        // ����� �� switch
         case 133:Alert("�������� ���������");
            break;                        // ����� �� switch
         case 139:Alert("����� ������������ � ��� ��������������");
            break;                        // ����� �� switch
         case 145:Alert("����������� ���������. ",
                              "����� ������� ������ � �����");
            break;                        // ����� �� switch
         default: Alert("�������� ������ ",Error);//������ ��������   
        }
      break;                                    // ����� �� ����� ����
     }
//-------------------------------------------------------------- 10 --
   Alert ("������ �������� ������ -----------------------------");
   return;                                      // ����� �� start()
  }
//-------------------------------------------------------------- 11 --