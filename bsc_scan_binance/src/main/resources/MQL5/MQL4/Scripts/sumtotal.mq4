//--------------------------------------------------------------------
// sumtotal.mq4
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
int start()                          // ����������� ������� start()
  {
//--------------------------------------------------------------------
   int
   Nom_1,                               // ����� ������� ��������
   Nom_2,                               // ����� ������� ��������
   Sum,                                 // ����� �����
   i;                                   // �������� �������� (�������)
//--------------------------------------------------------------------
   Nom_1=3;                              // ����� ��������� ��������
   Nom_2=7;                              // ����� ��������� ��������
   for(i=Nom_1; i<=Nom_2; i++)           // ��������� ��������� �����
     {                                   // ������ ������ ���� �����
      Sum=Sum + i;                       // ����� �������������
      Alert("i=",i,"  Sum=",Sum);        // ��������� �� �����
     }                                   // ������ ����� ���� �����
//--------------------------------------------------------------------
   Alert("����� ������ �� ����� i=",i,"  Sum=",Sum);// ����� �� �����
   return;                               // ����� �� start()
  }
//--------------------------------------------------------------------