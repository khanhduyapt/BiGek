//EA交易     =>  ...\MT4\MQL4\Experts

#property  copyright "Life Changer EA"
#property  link      "www.lifechangerea.com"
#property version    "1.00"
#property strict

//enum ENUM_TIMEFRAMES      {PERIOD_CURRENT = 0, PERIOD_M1 = 1, PERIOD_M2 = 2, PERIOD_M3 = 3, PERIOD_M4 = 4, PERIOD_M5 = 5, PERIOD_M6 = 6, PERIOD_M10 = 10, PERIOD_M12 = 12, PERIOD_M15 = 15, PERIOD_M20 = 20, PERIOD_M30 = 30, PERIOD_H1 = 60, PERIOD_H2 = 120, PERIOD_H3 = 180, PERIOD_H4 = 240, PERIOD_H6 = 360, PERIOD_H8 = 480, PERIOD_H12 = 720, PERIOD_D1 = 1440, PERIOD_W1 = 10080, PERIOD_MN1 = 43200, };


//------------------
 extern string 以下设置起始手数=""  ;
 extern double FixLot=0.01  ;   
 extern string 以下设置获利点数=""  ;
 extern double TakeProfit=30  ;   

 string    总_st_1  =  "Change The Life With Life Changer EA";
 string    总_st_2  =  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
 bool      总_bo_3 = false;
 double    总_do_4 = 0.2;
 int       总_in_5 = 0;
 bool      总_bo_6 = true;
 int       总_in_7 = 70;
 int       总_in_8 = 50;
 int       总_in_9 = 1;
 extern string 以下设置加仓倍率=""  ;
 extern double    总_do_10 = 1.23;
 string    总_st_11  =  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
 double    总_do_12 = 12.0;
 double    总_do_13 = 5.0;
 int       总_in_14 = 300;
 int       总_in_15 = 20;
 int       总_in_16 = 2345678;//1234567;
 string    总_st_17  =  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
 bool      总_bo_18 = true;
 double    总_do_19 = 12.0;
 int       总_in_20 = 1;
 extern string 以下可交易货币对=""  ;
 extern string    总_st_21  =  "USDCHF";
 extern string    总_st_22  =  "GBPUSD";
 extern string    总_st_23  =  "AUDJPY";
 extern string    总_st_24  =  "EURUSD";
 extern string    总_st_25  =  "AUDUSD";
 extern string    总_st_26  =  "USDCAD";
 extern string    总_st_27  =  "NZDUSD";
 extern string    总_st_28  =  "EURAUD";
 extern string    总_st_29  =  "NZDJPY";
 extern string    总_st_30  =  "GBPJPY";
 extern string    总_st_31  =  "EURGBP";
 extern string    总_st_32  =  "EURJPY";
 extern string    总_st_33  =  "USDJPY";
 string    总_st_34  =  "";
 string    总_st_35  =  "";
 string    总_st_36  =  "";
 string    总_st_37  =  "";
 string    总_st_38  =  "";
 string    总_st_39  =  "";
 string    总_st_40  =  "";
 string    总_st_41  =  "";
 string    总_st_42  =  "";
 string    总_st_43  =  "";
 string    总_st_44  =  "";
 string    总_st_45  =  "";
 string    总_st_46  =  "";
 string    总_st_47  =  "";
 string    总_st_48  =  "";
 string    总_st_49  =  "";
 string    总_st_50  =  "";
 int       总_in_51 = 2;
 string    总_st_52  =  "";
 int       总_in_53 = 0;
 int       总_in_54 = 0;
 bool      总_bo_55 = false;
 double    总_do_56 = 20.0;
 double    总_do_57 = 5.0;
 string    总_st_58  =  "【炒金子】Life Changer EA ";
 bool      总_bo_59 = true;
 bool      总_bo_60 = true;
 int       总_in_61 = 20;
 string    总_st_62  =  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
 bool      总_bo_63 = true;
 string    总_st_64  =  "00:00";
 string    总_st_65  =  "23:59";
 double    总_do_66 = 0.0;
 double    总_do_67 = 0.0;
 double    总_do_68 = 0.0;
 uint      总_ui_69 = 0;
 uint      总_ui_70 = 0;
 double    总_do_71 = 0.0;
 double    总_do_72 = 0.0;
 double    总_do_73 = 0.0;
 double    总_do_74 = 0.0;
 double    总_do_75 = 0.0;
 double    总_do_76 = 0.0;
 int       总_in_77 = 0;
 int       总_in_78 = 0;
 int       总_in_79 = 0;
 double    总_do_80 = 0.0;
 double    总_do_81 = 0.0;
 int       总_in_82 = 1;
 int       总_in_83 = 12;
 uint      总_ui_84 = Lime;
 double    总_do_85 = 0.0;
 double    总_do_86 = 0.0;
 double    总_do_87 = 0.0;
 double    总_do_88 = 0.0;
 double    总_do_89 = 0.0;
 double    总_do_90 = 0.0;
 double    总_do_91 = 0.0;
 double    总_do_92 = 0.0;
 double    总_do_93 = 0.0;
 uint      总_ui_94 = 0;
 uint      总_ui_95 = 0;
 string    总_st_96;
 string    总_st_97;
 string    总_st_98;
 string    总_st_99;
 string    总_st_100;
 string    总_st_101;
 string    总_st_102;
 string    总_st_103;
 string    总_st_104;
 string    总_st_105;
 double    总_do_106 = 0.0;
 double    总_do_107 = 0.0;
 double    总_do_108 = 0.0;
 double    总_do_109 = 0.0;
 int       总_in_110 = 0;
 int       总_in_111 = 0;
 int       总_in_112 = 0;
 int       总_in_113 = 0;
 double    总_do_114 = 0.0;
 double    总_do_115 = 0.0;
 double    总_do_116 = 0.0;
 double    总_do_117 = 0.0;
 double    总_do_118 = 0.0;
 double    总_do_119 = 0.0;
 double    总_do_120 = 0.0;
 double    总_do_121 = 0.0;
 double    总_do_122 = 0.0;
 double    总_do_123 = 0.0;
 double    总_do_124 = 0.0;
 double    总_do_125 = 0.0;
 double    总_do_126 = 0.0;
 int       总_in_127 = 0;
 bool      总_bo_128 = true;
 string    总_st_129  =  "MONDAY";
 string    总_st_130  =  "TUESDAY";
 string    总_st_131  =  "WEDNESDAY";
 string    总_st_132  =  "THURSDAY";
 string    总_st_133  =  "FRIDAY";
 string    总_st_134  =  "SATURDAY";
 string    总_st_135  =  "SUNDAY";
 string    总_st_136;
 double    总_do_137 = 0.0;
 double    总_do_138 = 0.0;
 double    总_do_139 = 0.0;
 double    总_do_140 = 0.0;
 double    总_do_141 = 0.0;
 double    总_do_142 = 0.0;
 double    总_do_143 = 0.0;
 double    总_do_144 = 0.0;
 double    总_do_145 = 0.0;
 int       总_in_146 = 0;
 int       总_in_147 = 0;
 int       总_in_148 = 0;
 int       总_in_149 = 0;
 double    总_do_150 = 0.0;
 double    总_do_151 = 0.0;
 double    总_do_152 = 0.0;
 double    总_do_153 = 0.0;
 double    总_do_154 = 0.0;
 double    总_do_155 = 0.0;
 double    总_do_156 = 0.0;
 double    总_do_157 = 0.0;
 double    总_do_158 = 0.0;
 double    总_do_159 = 0.0;
 double    总_do_160 = 0.0;
 double    总_do_161 = 0.0;
 double    总_do_162 = 0.0;
 double    总_do_163 = 0.0;
 double    总_do_164 = 0.0;
 double    总_do_165 = 0.0;
 double    总_do_166 = 0.0;
 double    总_do_167 = 0.0;
 double    总_do_168 = 0.0;
 double    总_do_169 = 0.0;
 double    总_do_170 = 0.0;
 double    总_do_171 = 0.0;
 double    总_do_172 = 0.0;
 double    总_do_173 = 0.0;
 double    总_do_174 = 0.0;
 double    总_do_175 = 0.0;
 double    总_do_176 = 0.0;
 double    总_do_177 = 0.0;
 double    总_do_178 = 0.0;
 double    总_do_179 = 0.0;
 double    总_do_180 = 0.0;
 double    总_do_181 = 0.0;
 double    总_do_182 = 0.0;
 double    总_do_183 = 0.0;
 double    总_do_184 = 0.0;
 double    总_do_185 = 0.0;
 double    总_do_186 = 0.0;
 double    总_do_187 = 0.0;
 double    总_do_188 = 0.0;
 int       总_in_189 = 0;
 double    总_do_190 = 0.0;
 double    总_do_191 = 0.0;
 double    总_do_192 = 0.0;
 datetime  总_da_193 = 0;
 datetime  总_da_194 = 0;
 datetime  总_da_195 = 0;
 int       总_in_196 = 0;
 double    总_do_197 = 0.0;
 double    总_do_198 = 0.0;
 double    总_do_199 = 0.0;
 double    总_do_200 = 0.0;
 double    总_do_201 = 0.0;
 double    总_do_202 = 0.0;
 double    总_do_203 = 0.0;
 double    总_do_204 = 0.0;
 double    总_do_205 = 0.0;
 double    总_do_206 = 0.0;
 double    总_do_207 = 0.0;
 double    总_do_208 = 0.0;
 double    总_do_209 = 0.0;
 double    总_do_210 = 0.0;
 double    总_do_211 = 0.0;
 double    总_do_212 = 0.0;
 int       总_in_213 = 0;
 int       总_in_214 = 0;
 int       总_in_215 = 0;
 datetime  总_da_216 = 0;
 datetime  总_da_217 = 0;
 string    总_st_218;
 string    总_st_219;
 double    总_do_220 = 0.0;
 double    总_do_221 = 0.0;
 double    总_do_222 = 0.0;
 double    总_do_223 = 0.0;
 double    总_do_224 = 0.0;
 double    总_do_225 = 0.0;
 int       总_in_226 = 0;
 string    总_st_227ko[];
 string    总_st_228;
 double    总_do_229 = 0.0;
 double    总_do_230 = 0.0;
 double    总_do_231 = 0.0;


 int OnInit ()
 {
 string      子_st_1;
 datetime    子_da_2;
 bool        子_bo_3;
 bool        子_bo_4;

//----------------------------

 EventSetMillisecondTimer(1); 
 子_st_1 = "2018.03.26 23:55" ;
 子_da_2 = StringToTime(子_st_1) ;
 if ( TimeCurrent() >= 子_da_2 )
  {
 // Alert("Free Trial Expired For Paid Version Visit www.lifechangerea.com"); 
  //return(1); 
  }
 if ( IsTesting() )
  {
 // Alert("EA can\'t backtesting"); 
 // return(1); 
  }
 子_bo_3 = true ;
 子_bo_4 = true ;
 总_st_52 = StringSubstr(Symbol(),6,StringLen(Symbol())  - 6) ;
 总_in_226 = 0 ;
 if ( 总_st_21  !=  "" )
  {
  总_in_226 = 1 ;
  ArrayResize(总_st_227ko,1,0); 
  总_st_227ko[1 - 1] = 总_st_21 + 总_st_52;
  }
 if ( 总_st_22  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_22 + 总_st_52;
  }
 if ( 总_st_23  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_23 + 总_st_52;
  }
 if ( 总_st_24  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_24 + 总_st_52;
  }
 if ( 总_st_25  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_25 + 总_st_52;
  }
 if ( 总_st_26  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_26 + 总_st_52;
  }
 if ( 总_st_27  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_27 + 总_st_52;
  }
 if ( 总_st_28  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_28 + 总_st_52;
  }
 if ( 总_st_29  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_29 + 总_st_52;
  }
 if ( 总_st_30  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_30 + 总_st_52;
  }
 if ( 总_st_31  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_31 + 总_st_52;
  }
 if ( 总_st_32  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_32 + 总_st_52;
  }
 if ( 总_st_33  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_33 + 总_st_52;
  }
 if ( 总_st_34  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_34 + 总_st_52;
  }
 if ( 总_st_35  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_35 + 总_st_52;
  }
 if ( 总_st_36  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_36 + 总_st_52;
  }
 if ( 总_st_37  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_37 + 总_st_52;
  }
 if ( 总_st_38  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_38 + 总_st_52;
  }
 if ( 总_st_39  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_39 + 总_st_52;
  }
 if ( 总_st_40  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_40 + 总_st_52;
  }
 if ( 总_st_41  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_41 + 总_st_52;
  }
 if ( 总_st_42  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_42 + 总_st_52;
  }
 if ( 总_st_43  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_43 + 总_st_52;
  }
 if ( 总_st_44  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_44 + 总_st_52;
  }
 if ( 总_st_45  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_45 + 总_st_52;
  }
 if ( 总_st_46  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_46 + 总_st_52;
  }
 if ( 总_st_47  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_47 + 总_st_52;
  }
 if ( 总_st_48  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_48 + 总_st_52;
  }
 if ( 总_st_49  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_49 + 总_st_52;
  }
 if ( 总_st_50  !=  "" )
  {
  总_in_226=总_in_226 + 1;
  ArrayResize(总_st_227ko,总_in_226,0); 
  总_st_227ko[总_in_226 - 1] = 总_st_50 + 总_st_52;
  }
 总_in_53 = 总_in_16 ;
 总_in_54 = 总_in_16 ;
 return(0); 
 }
//OnInit
//---------------------  ----------------------------------------

 void OnTick ()
 {
 string      子_st_1ko[];
 int         子_in_2;
 bool        子_bo_3;
 int         子_in_4;
 bool        子_bo_5;
 int         子_in_6;
 int         子_in_7;
 double      子_do_8;

//----------------------------
 bool       临_bo_1;
 double     临_do_2;
 double     临_do_3;
 double     临_do_4;
 int        临_in_5;
 int        临_in_6;
 double     临_do_7;
 double     临_do_8;
 int        临_in_9;
 bool       临_bo_10;
 double     临_do_11;
 double     临_do_12;
 double     临_do_13;
 int        临_in_14;
 int        临_in_15;
 double     临_do_16;
 double     临_do_17;
 int        临_in_18;
 bool       临_bo_19;
 bool       临_bo_20;


//---------------------------

 子_in_2 = 0 ;
 for (总_in_77=OrdersTotal() - 1 ; 总_in_77 >= 0 ; 总_in_77=总_in_77 - 1)
  {
  总_do_114 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
  if ( ( OrderMagicNumber()  !=  总_in_53 && OrderMagicNumber() != 总_in_54 ) )   continue;
  for (总_in_213 = 0 ; 总_in_213 < 总_in_226 ; 总_in_213=总_in_213 + 1)
   {
   if ( OrderSymbol() != 总_st_227ko[总_in_213] )   continue;
   子_bo_3 = true ;
   for (子_in_4 = 0 ; 子_in_4 < 子_in_2 ; 子_in_4 = 子_in_4 + 1)
    {
    if ( 子_st_1ko[子_in_4] != OrderSymbol() )   continue;
    子_bo_3 = false ;
    }
   if ( !(子_bo_3) )   continue;
   子_in_2 = 子_in_2 + 1;
   ArrayResize(子_st_1ko,子_in_2,0); 
   子_st_1ko[子_in_2 - 1] = OrderSymbol();
   }
  }
 for (总_in_213 = 0 ; 总_in_213 < 总_in_226 ; 总_in_213=总_in_213 + 1)
  {
  总_st_228 = 总_st_227ko[总_in_213] ;
  子_bo_5 = false ;
  if ( 子_in_2 <  总_in_51 )
   {
   子_bo_5 = true ;
   }
  else
   {
   for (子_in_6 = 0 ; 子_in_6 < 子_in_2 ; 子_in_6 = 子_in_6 + 1)
    {
    if ( 总_st_228 != 子_st_1ko[子_in_6] || 子_in_6 >= 总_in_51 )   continue;
    子_bo_5 = true ;
    }
   }
  子_in_7 = MarketInfo(总_st_228,12) ;
  子_do_8 = MarketInfo(总_st_228,11) ;
  总_do_152 = NormalizeDouble(MarketInfo(总_st_228,16),子_in_7) ;
  总_in_110 = 0 ;
  总_in_111 = 0 ;
  总_in_214 = 0 ;
  总_in_215 = 0 ;
  总_do_137 = 0.0 ;
  总_do_138 = 0.0 ;
  总_do_139 = 0.0 ;
  总_do_140 = 0.0 ;
  总_in_147 = 0 ;
  总_do_150 = 0.0 ;
  总_do_151 = 0.0 ;
  总_do_175 = 0.0 ;
  总_do_176 = 0.0 ;
  总_do_177 = 0.0 ;
  总_do_90 = 0.0 ;
  总_do_179 = 0.0 ;
  总_do_180 = 0.0 ;
  总_do_181 = 0.0 ;
  总_do_182 = 0.0 ;
  总_do_183 = 0.0 ;
  总_do_184 = 0.0 ;
  总_da_217 = 0 ;
  总_da_216 = 0 ;
  for (总_in_77 = 0 ; 总_in_77 < OrdersTotal() ; 总_in_77=总_in_77 + 1)
   {
   总_do_114 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
   if ( OrderSymbol() == 总_st_228 && OrderMagicNumber() == 总_in_53 )
    {
    总_in_214=总_in_214 + 1;
    }
   if ( OrderSymbol() == 总_st_228 && OrderMagicNumber() == 总_in_54 )
    {
    总_in_215=总_in_215 + 1;
    }
   if ( OrderSymbol() == 总_st_228 && OrderMagicNumber() == 总_in_53 && OrderType() == 0 )
    {
    总_do_157 = OrderLots() ;
    总_in_110=总_in_110 + 1;
    总_do_179 = 总_do_179 + OrderProfit() ;
    总_do_211 = OrderOpenPrice() ;
    总_do_142 = OrderStopLoss() ;
    总_do_143 = OrderTakeProfit() ;
    总_do_137 = 总_do_137 + OrderOpenPrice() ;
    总_do_139 = NormalizeDouble(总_do_137 / 总_in_110,子_in_7) ;
    总_do_181 = 总_do_181 + OrderLots() ;
    总_do_183 = NormalizeDouble(总_do_179 / 总_do_181 / 总_do_152,子_in_7) ;
    总_da_217 = OrderOpenTime() ;
    }
   if ( OrderSymbol() != 总_st_228 || OrderMagicNumber() != 总_in_54 || OrderType() != 1 )   continue;
   总_in_111=总_in_111 + 1;
   总_do_158 = OrderLots() ;
   总_do_212 = OrderOpenPrice() ;
   总_do_141 = OrderStopLoss() ;
   总_do_144 = OrderTakeProfit() ;
   总_do_138 = 总_do_138 + OrderOpenPrice() ;
   总_do_140 = NormalizeDouble(总_do_138 / 总_in_111,子_in_7) ;
   总_do_182 = 总_do_182 + OrderLots() ;
   总_do_180 = 总_do_180 + OrderProfit() ;
   总_do_184 = NormalizeDouble(总_do_180 / 总_do_182 / 总_do_152,子_in_7) ;
   总_da_216 = OrderOpenTime() ;
   }
  if ( ( 子_in_7 == 5 || 子_in_7 == 3 ) && ( 总_st_228 != "XAU" || 总_st_228 != "XAUUSDcheck" || 总_st_228 != "XAUUSD" || 总_st_228  !=  "GOLD" ) )
   {
   总_in_146 = 10 ;
   }
  else
   {
   总_in_146 = 1 ;
   }
  if ( 子_in_7 == 3 && ( 总_st_228 == "XAU" || 总_st_228 == "XAUUSDcheck" || 总_st_228 == "XAUUSD" || 总_st_228 == "GOLD" ) )
   {
   总_in_146 = 100 ;
   }
  else
   {
   总_in_146 = 10 ;
   }
  if ( 子_do_8==0.0 || 总_in_146 == 0 )   continue;
  总_do_87 = NormalizeDouble(((MarketInfo(总_st_228,10) - MarketInfo(总_st_228,9)) / 子_do_8) / 总_in_146,2) ;
  总_do_230 = MarketInfo(总_st_228,23) ;
  总_do_231 = MarketInfo(总_st_228,25) ;
  if ( 总_do_230==0.01 )
   {
   总_in_5 = 2 ;
   }
  if ( 总_do_230==0.1 )
   {
   总_in_5 = 1 ;
   }
  if ( 总_do_230==1.0 )
   {
   总_in_5 = 0 ;
   }
  HideTestIndicators(true); 
  if ( DayOfWeek() == 1 )
   {
   总_st_136 = 总_st_129 ;
   }
  if ( DayOfWeek() == 2 )
   {
   总_st_136 = 总_st_130 ;
   }
  if ( DayOfWeek() == 3 )
   {
   总_st_136 = 总_st_131 ;
   }
  if ( DayOfWeek() == 4 )
   {
   总_st_136 = 总_st_132 ;
   }
  if ( DayOfWeek() == 5 )
   {
   总_st_136 = 总_st_133 ;
   }
  if ( DayOfWeek() == 6 )
   {
   总_st_136 = 总_st_134 ;
   }
  if ( DayOfWeek() == 7 )
   {
   总_st_136 = 总_st_135 ;
   }
  if ( ( 子_in_7 == 3 || 子_in_7 == 5 ) )
   {
   总_in_127=总_in_61 * 10;
   }
  else
   {
   总_in_127 = 总_in_61 ;
   }
  if ( 总_in_9 == 0 )
   {
   总_do_178 = 1000.0 ;
   }
  if ( 总_in_9 == 1 )
   {
   总_do_178 = 30.0 ;
   }
  总_do_222 = ((总_in_7 - iHighest(总_st_228,0,MODE_HIGH,总_in_7,总_in_9) + 总_in_9) * 100.0) / 总_in_7 ;
  总_do_223 = ((总_in_7 - iLowest(总_st_228,0,MODE_LOW,总_in_7,总_in_9) + 总_in_9) * 100.0) / 总_in_7 ;
  总_do_224 = ((总_in_7 - iHighest(总_st_228,0,MODE_HIGH,总_in_7,总_in_9 + 1) + 总_in_9 + 1) * 100.0) / 总_in_7 ;
  总_do_225 = ((总_in_7 - iLowest(总_st_228,0,MODE_LOW,总_in_7,总_in_9 + 1) + 总_in_9 + 1) * 100.0) / 总_in_7 ;
  总_do_220 = 总_do_222 - 总_do_223 ;
  总_do_221 = 总_do_224 - 总_do_225 ;
  if ( 总_do_220>总_in_8 && 总_do_221<总_in_8 )
   {
   总_st_218 = "BUY" ;
   }
  else
   {
   总_st_218 = "NOBUY" ;
   }
  if ( 总_do_220< -(总_in_8) && 总_do_221> -(总_in_8) )
   {
   总_st_219 = "SELL" ;
   }
  else
   {
   总_st_219 = "NOSELL" ;
   }
  if ( 总_in_14 > 0 && 总_in_14 * 总_in_146>MarketInfo(总_st_228,14) )
   {
   总_do_106 = MarketInfo(总_st_228,10) - 总_in_14 * 总_in_146 * 子_do_8 ;
   总_do_107 = 总_in_14 * 总_in_146 * 子_do_8 + MarketInfo(总_st_228,9) ;
   }
  if ( ( 总_in_14 == 0 || 总_in_14 * 总_in_146<=MarketInfo(总_st_228,14) ) )
   {
   总_do_106 = 0.0 ;
   总_do_107 = 0.0 ;
   }
  if ( TakeProfit>0.0 && TakeProfit * 总_in_146>MarketInfo(总_st_228,14) )
   {
   总_do_108 = TakeProfit * 总_in_146 * 子_do_8 + MarketInfo(总_st_228,10) ;
   总_do_109 = MarketInfo(总_st_228,9) - TakeProfit * 总_in_146 * 子_do_8 ;
   }
  if ( ( TakeProfit==0.0 || TakeProfit * 总_in_146<=MarketInfo(总_st_228,14) ) )
   {
   总_do_108 = 0.0 ;
   总_do_109 = 0.0 ;
   }
  if ( 子_bo_5 && 总_in_214 == 0 )
   {
   if ( 总_bo_63 )
    {
    if ( TimeCurrent() >= StringToTime(总_st_64) && TimeCurrent() <  StringToTime(总_st_65) )
     {
     临_bo_1 = true;
     }
    else
     {
     临_bo_1 = false;
    }}
   else
    {
    临_bo_1 = true;
    }
   if ( 临_bo_1 && 总_st_218 == "BUY" )
    {
    临_do_2 = AccountFreeMargin();
    临_do_3 = MarketInfo(总_st_228,32);
    总_do_229 = FixLot ;
    if ( FixLot<总_do_230 )
     {
     总_do_229 = 总_do_230 ;
     }
    if ( 总_do_229>总_do_231 )
     {
     总_do_229 = 总_do_231 ;
     }
    if ( 总_bo_3 == true )
     {
     MarketInfo(总_st_228,23); 
     临_do_4 = AccountBalance() / 200.0;
     临_do_4 = MathFloor(临_do_4);
     临_do_4 = 临_do_4 * 0.01;
     if ( 临_do_4>MarketInfo(总_st_228,25) )
      {
      临_do_4 = MarketInfo(总_st_228,25);
      }
     if ( 临_do_4>临_do_4 )
      {
      临_do_4 = 临_do_4;
      }
     临_in_5 = 0;
     if ( MarketInfo(总_st_228,24)>=1.0 )
      {
      临_in_5 = 0;
      }
     else
      {
      if ( MarketInfo(总_st_228,24)>=0.1 )
       {
       临_in_5 = 1;
       }
      else
       {
       if ( MarketInfo(总_st_228,24)>=0.01 )
        {
        临_in_5 = 2;
        }
       else
        {
        临_in_5 = 3;
      }}}
     临_do_4 = NormalizeDouble(临_do_4,临_in_5);
     总_do_229 = 临_do_4 ;
     if ( 临_do_4<总_do_230 )
      {
      总_do_229 = 总_do_230 ;
      }
     if ( 总_do_229>总_do_231 )
      {
      总_do_229 = 总_do_231 ;
     }}
    if ( 临_do_2<临_do_3 * 总_do_229 )
     {
     Print("No Enougt Money to Open NextOrder or Volume size is Over Maximum Lot."); 
     ArrayFree(子_st_1ko);
     return;
     }
    临_in_6=总_in_61 * 总_in_146; 
    临_do_7 = MarketInfo(总_st_228,10);
    总_do_229 = FixLot ;
    if ( FixLot<总_do_230 )
     {
     总_do_229 = 总_do_230 ;
     }
    if ( 总_do_229>总_do_231 )
     {
     总_do_229 = 总_do_231 ;
     }
    if ( 总_bo_3 == true )
     {
     MarketInfo(总_st_228,23); 
     临_do_8 = AccountBalance() / 200.0;
     临_do_8 = MathFloor(临_do_8);
     临_do_8 = 临_do_8 * 0.01;
     if ( 临_do_8>MarketInfo(总_st_228,25) )
      {
      临_do_8 = MarketInfo(总_st_228,25);
      }
     if ( 临_do_8>临_do_8 )
      {
      临_do_8 = 临_do_8;
      }
     临_in_9 = 0;
     if ( MarketInfo(总_st_228,24)>=1.0 )
      {
      临_in_9 = 0;
      }
     else
      {
      if ( MarketInfo(总_st_228,24)>=0.1 )
       {
       临_in_9 = 1;
       }
      else
       {
       if ( MarketInfo(总_st_228,24)>=0.01 )
        {
        临_in_9 = 2;
        }
       else
        {
        临_in_9 = 3;
      }}}
     临_do_8 = NormalizeDouble(临_do_8,临_in_9);
     总_do_229 = 临_do_8 ;
     if ( 临_do_8<总_do_230 )
      {
      总_do_229 = 总_do_230 ;
      }
     if ( 总_do_229>总_do_231 )
      {
      总_do_229 = 总_do_231 ;
     }}
    总_do_115 = OrderSend(总_st_228,OP_BUY,总_do_229,临_do_7,临_in_6,总_do_106,总_do_108,总_st_58,总_in_53,0,Blue) ;
    ArrayFree(子_st_1ko);
    return;
   }}
  if ( 子_bo_5 && 总_in_215 == 0 )
   {
   if ( 总_bo_63 )
    {
    if ( TimeCurrent() >= StringToTime(总_st_64) && TimeCurrent() <  StringToTime(总_st_65) )
     {
     临_bo_10 = true;
     }
    else
     {
     临_bo_10 = false;
    }}
   else
    {
    临_bo_10 = true;
    }
   if ( 临_bo_10 && 总_st_219 == "SELL" && iVolume(总_st_228,0,0)<总_do_178 )
    {
    临_do_11 = AccountFreeMargin();
    临_do_12 = MarketInfo(总_st_228,32);
    总_do_229 = FixLot ;
    if ( FixLot<总_do_230 )
     {
     总_do_229 = 总_do_230 ;
     }
    if ( 总_do_229>总_do_231 )
     {
     总_do_229 = 总_do_231 ;
     }
    if ( 总_bo_3 == true )
     {
     MarketInfo(总_st_228,23); 
     临_do_13 = AccountBalance() / 200.0;
     临_do_13 = MathFloor(临_do_13);
     临_do_13 = 临_do_13 * 0.01;
     if ( 临_do_13>MarketInfo(总_st_228,25) )
      {
      临_do_13 = MarketInfo(总_st_228,25);
      }
     if ( 临_do_13>临_do_13 )
      {
      临_do_13 = 临_do_13;
      }
     临_in_14 = 0;
     if ( MarketInfo(总_st_228,24)>=1.0 )
      {
      临_in_14 = 0;
      }
     else
      {
      if ( MarketInfo(总_st_228,24)>=0.1 )
       {
       临_in_14 = 1;
       }
      else
       {
       if ( MarketInfo(总_st_228,24)>=0.01 )
        {
        临_in_14 = 2;
        }
       else
        {
        临_in_14 = 3;
      }}}
     临_do_13 = NormalizeDouble(临_do_13,临_in_14);
     总_do_229 = 临_do_13 ;
     if ( 临_do_13<总_do_230 )
      {
      总_do_229 = 总_do_230 ;
      }
     if ( 总_do_229>总_do_231 )
      {
      总_do_229 = 总_do_231 ;
     }}
    if ( 临_do_11<临_do_12 * 总_do_229 )
     {
     Print("No Enougt Money to Open NextOrder or Volume size is Over Maximum Lot."); 
     ArrayFree(子_st_1ko);
     return;
     }
    临_in_15=总_in_61 * 总_in_146; 
    临_do_16 = MarketInfo(总_st_228,9);
    总_do_229 = FixLot ;
    if ( FixLot<总_do_230 )
     {
     总_do_229 = 总_do_230 ;
     }
    if ( 总_do_229>总_do_231 )
     {
     总_do_229 = 总_do_231 ;
     }
    if ( 总_bo_3 == true )
     {
     MarketInfo(总_st_228,23); 
     临_do_17 = AccountBalance() / 200.0;
     临_do_17 = MathFloor(临_do_17);
     临_do_17 = 临_do_17 * 0.01;
     if ( 临_do_17>MarketInfo(总_st_228,25) )
      {
      临_do_17 = MarketInfo(总_st_228,25);
      }
     if ( 临_do_17>临_do_17 )
      {
      临_do_17 = 临_do_17;
      }
     临_in_18 = 0;
     if ( MarketInfo(总_st_228,24)>=1.0 )
      {
      临_in_18 = 0;
      }
     else
      {
      if ( MarketInfo(总_st_228,24)>=0.1 )
       {
       临_in_18 = 1;
       }
      else
       {
       if ( MarketInfo(总_st_228,24)>=0.01 )
        {
        临_in_18 = 2;
        }
       else
        {
        临_in_18 = 3;
      }}}
     临_do_17 = NormalizeDouble(临_do_17,临_in_18);
     总_do_229 = 临_do_17 ;
     if ( 临_do_17<总_do_230 )
      {
      总_do_229 = 总_do_230 ;
      }
     if ( 总_do_229>总_do_231 )
      {
      总_do_229 = 总_do_231 ;
     }}
    总_do_115 = OrderSend(总_st_228,OP_SELL,总_do_229,临_do_16,临_in_15,总_do_107,总_do_109,总_st_58,总_in_54,0,Red) ;
    ArrayFree(子_st_1ko);
    return;
   }}
  if ( 总_in_110 > 0 )
   {
   总_do_191 = NormalizeDouble(总_do_157 * 总_do_10,总_in_5) ;
   }
  总_do_169 = 总_do_142 ;
  总_do_170 = 总_do_141 ;
  if ( 总_bo_6 )
   {
   if ( 总_in_110 > 0 && 总_in_110 <  总_in_15 )
    {
    if ( 总_bo_60 )
     {
     if ( MarketInfo(总_st_228,10)<=总_do_211 - 总_do_12 * 总_in_146 * MarketInfo(总_st_228,11) )
      {
      临_bo_19 = true;
      }
     else
      {
      临_bo_19 = false;
     }}
    else
     {
     临_bo_19 = true;
     }
    if ( 临_bo_19 )
     {
     if ( AccountFreeMargin()<MarketInfo(总_st_228,32) * lizong_6() )
      {
      Print("No Enougt Money to Open NextOrder or Volume size is Over Maximum Lot."); 
      ArrayFree(子_st_1ko);
      return;
      }
     总_do_115 = OrderSend(总_st_228,OP_BUY,lizong_6(),MarketInfo(总_st_228,10),总_in_61 * 总_in_146,总_do_142,0.0,总_st_58,总_in_53,0,Aqua) ;
    }}
   if ( 总_in_111 > 0 && 总_in_111 <  总_in_15 )
    {
    if ( 总_bo_60 )
     {
     if ( MarketInfo(总_st_228,9)>=总_do_12 * 总_in_146 * MarketInfo(总_st_228,11) + 总_do_212 )
      {
      临_bo_20 = true;
      }
     else
      {
      临_bo_20 = false;
     }}
    else
     {
     临_bo_20 = true;
     }
    if ( 临_bo_20 )
     {
     if ( AccountFreeMargin()<MarketInfo(总_st_228,32) * lizong_7() )
      {
      Print("No Enougt Money to Open NextOrder or Volume size is Over Maximum Lot."); 
      ArrayFree(子_st_1ko);
      return;
      }
     总_do_115 = OrderSend(总_st_228,OP_SELL,lizong_7(),MarketInfo(总_st_228,9),总_in_61 * 总_in_146,总_do_141,0.0,总_st_58,总_in_54,0,Magenta) ;
   }}}
  总_do_68 = (总_in_20 + 总_do_19) * 总_in_146 ;
  if ( 总_bo_18 )
   {
   for (总_in_77=OrdersTotal() - 1 ; 总_in_77 >= 0 ; 总_in_77=总_in_77 - 1)
    {
    总_in_112 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
    if ( OrderSymbol() != 总_st_228 || OrderMagicNumber() != 总_in_16 )   continue;
    
    if ( OrderType() == 0 && 总_in_214 == 1 )
     {
     if ( !(总_do_19>0.0) || !(总_do_19 * 总_in_146>MarketInfo(总_st_228,14)) || !(MarketInfo(总_st_228,9) - OrderOpenPrice()>=子_do_8 * 总_do_19 * 总_in_146) || ( !(OrderStopLoss()<=MarketInfo(总_st_228,9) - 子_do_8 * 总_do_68) && !(OrderStopLoss()==0.0) ) )   continue;
     总_in_113 = OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(总_st_228,9) - 子_do_8 * 总_do_19 * 总_in_146,OrderTakeProfit(),0,Lime) ;
     ArrayFree(子_st_1ko);
     return;
     }
    if ( OrderType() != 1 || 总_in_215 != 1 || !(总_do_19>0.0) || !(总_do_19 * 总_in_146>MarketInfo(总_st_228,14)) || !(OrderOpenPrice() - MarketInfo(总_st_228,10)>=子_do_8 * 总_do_19 * 总_in_146) || ( !(OrderStopLoss()>=子_do_8 * 总_do_68 + MarketInfo(总_st_228,10)) && !(OrderStopLoss()==0.0) ) )   continue;
    总_in_113 = OrderModify(OrderTicket(),OrderOpenPrice(),子_do_8 * 总_do_19 * 总_in_146 + MarketInfo(总_st_228,10),OrderTakeProfit(),0,Red) ;
    ArrayFree(子_st_1ko);
    return;
    }
   }
  if ( 总_in_110 > 0 )
   {
   总_do_67 = NormalizeDouble(MarketInfo(总_st_228,9) - 总_do_183 * 子_do_8,子_in_7) ;
   总_do_204 = NormalizeDouble(总_do_13 * 总_in_146 * 子_do_8 + NormalizeDouble(MarketInfo(总_st_228,9) - 总_do_183 * 子_do_8,子_in_7),子_in_7) ;
   }
  if ( 总_in_111 > 0 )
   {
   总_do_66 = NormalizeDouble(总_do_184 * 子_do_8 + MarketInfo(总_st_228,10),子_in_7) ;
   总_do_205 = NormalizeDouble(NormalizeDouble(总_do_184 * 子_do_8 + MarketInfo(总_st_228,10),子_in_7) - 总_do_13 * 总_in_146 * 子_do_8,子_in_7) ;
   }
  if ( 总_bo_59 == true && 总_do_13>0.0 )
   {
   for (总_in_77=OrdersTotal() - 1 ; 总_in_77 >= 0 ; 总_in_77=总_in_77 - 1)
    {
    总_do_114 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
    if ( OrderSymbol() != 总_st_228 || OrderMagicNumber() != 总_in_54 || OrderType() != 1 || 总_in_111 <= 1 || !(总_do_144==0.0) )   continue;
    总_in_79 = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(总_do_66 - 总_do_13 * 总_in_146 * 子_do_8,子_in_7),0,Yellow) ;
    }
   }
  if ( 总_bo_59 == true && 总_do_13>0.0 )
   {
   总_in_77 = 0 ;
   for (总_in_77=OrdersTotal() - 1 ; 总_in_77 >= 0 ; 总_in_77=总_in_77 - 1)
    {
    总_do_114 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
    if ( OrderSymbol() != 总_st_228 || OrderMagicNumber() != 总_in_53 || OrderType() != 0 || 总_in_110 <= 1 || !(总_do_143==0.0) )   continue;
    总_in_79 = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(总_do_13 * 总_in_146 * 子_do_8 + 总_do_67,子_in_7),0,Yellow) ;
    }
   }
  if ( 总_bo_55 == true )
   {
   for (总_in_77=OrdersTotal() - 1 ; 总_in_77 >= 0 ; 总_in_77=总_in_77 - 1)
    {
    总_do_114 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
    if ( OrderSymbol() != 总_st_228 || OrderMagicNumber() != 总_in_54 || ( ( OrderType() != 1 || 总_in_111 != 1 || !(MarketInfo(总_st_228,10)<=总_do_212 - 总_do_56 * 总_in_146 * 子_do_8) ) && (OrderType() != 1 || 总_in_111 <= 1 || !(MarketInfo(总_st_228,10)<=总_do_66 - 总_do_57 * 总_in_146 * 子_do_8)) ) )   continue;
    总_do_116 = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),总_in_61,Red) ;
    }
   }
  if ( 总_bo_55 == true )
   {
   for (总_in_77=OrdersTotal() - 1 ; 总_in_77 >= 0 ; 总_in_77=总_in_77 - 1)
    {
    总_do_114 = OrderSelect(总_in_77,SELECT_BY_POS,MODE_TRADES) ;
    if ( OrderSymbol() != 总_st_228 || OrderMagicNumber() != 总_in_53 || ( ( OrderType() != 0 || 总_in_110 != 1 || !(MarketInfo(总_st_228,9)>=总_do_56 * 总_in_146 * 子_do_8 + 总_do_211) ) && (OrderType() != 0 || 总_in_110 <= 1 || !(MarketInfo(总_st_228,9)>=总_do_57 * 总_in_146 * 子_do_8 + 总_do_67)) ) )   continue;
    总_do_116 = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),总_in_61,Blue) ;
    }
   }
  if ( iVolume(总_st_228,0,0) % 2 == 0 )
   {
   总_ui_69 = Lime ;
   }
  else
   {
   总_ui_69 = Red ;
   }
  if ( AccountEquity()>AccountBalance() )
   {
   总_ui_70 = Blue ;
   }
  else
   {
   总_ui_70 = Magenta ;
   }
  总_do_86 = NormalizeDouble(((iHigh(总_st_228,PERIOD_D1,0) - iLow(总_st_228,PERIOD_D1,0)) / 子_do_8) / 总_in_146,2) ;
  总_do_87 = (MarketInfo(总_st_228,10) - MarketInfo(总_st_228,9)) / 子_do_8 ;
  if ( !(总_bo_128) )   continue;
  ObjectCreate("hari",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("hari",OBJPROP_CORNER,1.0); 
  ObjectSet("hari",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("hari",OBJPROP_YDISTANCE,18.0); 
  ObjectSet("hari",OBJPROP_BACK,1.0); 
  ObjectSetText("hari",总_st_136 + ", " + DoubleToString(Day(),0) + " - " + DoubleToString(Month(),0) + " - " + DoubleToString(Year(),0) + " " + IntegerToString(Hour(),0,32) + ":" + IntegerToString(Minute(),0,32) + ":" + IntegerToString(Seconds(),0,32),总_in_83 + 1,"Impact",Yellow); 
  ObjectSet("hari",OBJPROP_CORNER,总_in_82); 
  ObjectCreate("Balance",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("Balance",OBJPROP_CORNER,1.0); 
  ObjectSet("Balance",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("Balance",OBJPROP_YDISTANCE,35.0); 
  ObjectSet("Balance",OBJPROP_BACK,1.0); 
  ObjectSetText("Balance","Balance   : " + DoubleToString(AccountBalance(),2),总_in_83,"Cambria",总_ui_84); 
  ObjectSet("Balance",OBJPROP_CORNER,总_in_82); 
  ObjectCreate("Equity",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("Equity",OBJPROP_CORNER,1.0); 
  ObjectSet("Equity",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("Equity",OBJPROP_YDISTANCE,50.0); 
  ObjectSet("Equity",OBJPROP_BACK,1.0); 
  ObjectSetText("Equity","Equity     : " + DoubleToString(AccountEquity(),2),总_in_83,"Cambria",总_ui_70); 
  ObjectSet("Equity",OBJPROP_CORNER,总_in_82); 
  ObjectCreate("AF",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("AF",OBJPROP_CORNER,1.0); 
  ObjectSet("AF",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("AF",OBJPROP_YDISTANCE,65.0); 
  ObjectSet("AF",OBJPROP_BACK,1.0); 
  ObjectSetText("AF","Free Margin     : " + DoubleToString(AccountFreeMargin(),2),总_in_83,"Cambria",总_ui_70); 
  ObjectSet("AF",OBJPROP_CORNER,总_in_82); 
  总_do_87 = NormalizeDouble((MarketInfo(Symbol(),10) - MarketInfo(Symbol(),9)) / Point(),2) ;
  ObjectCreate("Spread",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("Spread",OBJPROP_CORNER,1.0); 
  ObjectSet("Spread",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("Spread",OBJPROP_YDISTANCE,80.0); 
  ObjectSet("Spread",OBJPROP_BACK,1.0); 
  ObjectSetText("Spread","Spread   : " + DoubleToString(总_do_87,1),总_in_83,"Cambria",总_ui_84); 
  ObjectSet("Spread",OBJPROP_CORNER,总_in_82); 
  总_do_86 = NormalizeDouble(((iHigh(Symbol(),PERIOD_D1,0) - iLow(Symbol(),PERIOD_D1,0)) / 子_do_8) / 总_in_146,2) ;
  ObjectCreate("Range",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("Range",OBJPROP_CORNER,1.0); 
  ObjectSet("Range",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("Range",OBJPROP_YDISTANCE,95.0); 
  ObjectSet("Range",OBJPROP_BACK,1.0); 
  ObjectSetText("Range","Range : " + DoubleToString(总_do_86,1),总_in_83,"Cambria",总_ui_84); 
  ObjectSet("Range",OBJPROP_CORNER,总_in_82); 
  ObjectCreate("Price",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("Price",OBJPROP_CORNER,1.0); 
  ObjectSet("Price",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("Price",OBJPROP_YDISTANCE,120.0); 
  ObjectSet("Price",OBJPROP_BACK,1.0); 
  ObjectSetText("Price","Price : " + DoubleToString(MarketInfo(Symbol(),9),子_in_7),总_in_83,"Cambria",总_ui_69); 
  ObjectSet("Price",OBJPROP_CORNER,总_in_82); 
  if ( 总_in_111 > 0 )
   {
   ObjectCreate("sell",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
   ObjectSet("sell",OBJPROP_CORNER,1.0); 
   ObjectSet("sell",OBJPROP_XDISTANCE,5.0); 
   ObjectSet("sell",OBJPROP_YDISTANCE,155.0); 
   ObjectSet("sell",OBJPROP_BACK,1.0); 
   ObjectSetText("sell","Sell Order : " + DoubleToString(总_in_111,0) + " | Sell Lot : " + DoubleToString(总_do_182,2),总_in_83,"Cambria",总_ui_84); 
   ObjectSet("sell",OBJPROP_CORNER,总_in_82); 
   }
  else
   {
   ObjectDelete("Tps"); 
   ObjectDelete("SLs"); 
   ObjectDelete("sell"); 
   }
  if ( 总_in_110 > 0 )
   {
   ObjectCreate("buy",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
   ObjectSet("buy",OBJPROP_CORNER,1.0); 
   ObjectSet("buy",OBJPROP_XDISTANCE,5.0); 
   ObjectSet("buy",OBJPROP_YDISTANCE,140.0); 
   ObjectSet("buy",OBJPROP_BACK,1.0); 
   ObjectSetText("buy","Buy Order : " + DoubleToString(总_in_110,0) + " |Buy Lot : " + DoubleToString(总_do_181,2),总_in_83,"Cambria",总_ui_84); 
   ObjectSet("buy",OBJPROP_CORNER,总_in_82); 
   }
  else
   {
   ObjectDelete("Tp"); 
   ObjectDelete("SL"); 
   ObjectDelete("buy"); 
   }
  ObjectCreate("EA_NAME",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
  ObjectSet("EA_NAME",OBJPROP_CORNER,1.0); 
  ObjectSet("EA_NAME",OBJPROP_XDISTANCE,5.0); 
  ObjectSet("EA_NAME",OBJPROP_YDISTANCE,5.0); 
  ObjectSet("EA_NAME",OBJPROP_BACK,1.0); 
  ObjectSetText("EA_NAME",总_st_1,总_in_83 + 3,"Impact",总_ui_70); 
  ObjectSet("EA_NAME",OBJPROP_CORNER,3.0); 
  }
 ArrayFree(子_st_1ko);
 }
//OnTick
//---------------------  ----------------------------------------

 void OnDeinit (const int 木_0)
 {

//----------------------------

 ObjectDelete("EA_NAME"); 
 ObjectDelete("expiredlabel"); 
 ObjectDelete("expiredlabel"); 
 ObjectDelete("Contact_Me"); 
 ObjectDelete("Key_Word2"); 
 ObjectDelete("Key_Word1"); 
 ObjectDelete("Spread"); 
 ObjectDelete("Leverage"); 
 ObjectDelete("Equity"); 
 ObjectDelete("Balance"); 
 ObjectDelete("Price"); 
 ObjectDelete("Profit"); 
 ObjectDelete("EA Trial"); 
 ObjectDelete("Trade_Mode"); 
 ObjectDelete("Lot"); 
 ObjectDelete("EnterLot"); 
 ObjectDelete("Spread"); 
 ObjectDelete("EA Expired"); 
 ObjectDelete("Range"); 
 ObjectDelete("hari"); 
 ObjectDelete("sell"); 
 ObjectDelete("Tps"); 
 ObjectDelete("SLs"); 
 ObjectDelete("SL"); 
 ObjectDelete("Tp"); 
 ObjectDelete("buy"); 
 ObjectDelete("BEP_XXX"); 
 ObjectDelete("BEP_XXX2"); 
 ObjectDelete("Check_Info"); 
 ObjectDelete("AF"); 
 ObjectDelete("MX"); 
 ObjectDelete("Diff_B"); 
 ObjectDelete("Total_Profit_X"); 
 ObjectDelete("Diff_S"); 
 ObjectDelete("Total_Profit_Y"); 
 EventKillTimer(); 
 }
//OnDeinit
//---------------------  ----------------------------------------

 double lizong_6()
 {

//----------------------------
 double     临_do_1;
 int        临_in_2;

 总_do_229 = FixLot ;
 if ( FixLot<总_do_230 )
  {
  总_do_229 = 总_do_230 ;
  }
 if ( 总_do_229>总_do_231 )
  {
  总_do_229 = 总_do_231 ;
  }
 if ( 总_bo_3 == true )
  {
  MarketInfo(总_st_228,23); 
  临_do_1 = AccountBalance() / 200.0;
  临_do_1 = MathFloor(临_do_1);
  临_do_1 = 临_do_1 * 0.01;
  if ( 临_do_1>MarketInfo(总_st_228,25) )
   {
   临_do_1 = MarketInfo(总_st_228,25);
   }
  if ( 临_do_1>临_do_1 )
   {
   临_do_1 = 临_do_1;
   }
  临_in_2 = 0;
  if ( MarketInfo(总_st_228,24)>=1.0 )
   {
   临_in_2 = 0;
   }
  else
   {
   if ( MarketInfo(总_st_228,24)>=0.1 )
    {
    临_in_2 = 1;
    }
   else
    {
    if ( MarketInfo(总_st_228,24)>=0.01 )
     {
     临_in_2 = 2;
     }
    else
     {
     临_in_2 = 3;
   }}}
  临_do_1 = NormalizeDouble(临_do_1,临_in_2);
  总_do_229 = 临_do_1 ;
  if ( 临_do_1<总_do_230 )
   {
   总_do_229 = 总_do_230 ;
   }
  if ( 总_do_229>总_do_231 )
   {
   总_do_229 = 总_do_231 ;
  }}
 总_do_191 = NormalizeDouble(总_do_229,总_in_5) ;
 if ( NormalizeDouble(总_do_229,总_in_5)<总_do_230 )
  {
  总_do_191 = 总_do_230 ;
  }
 if ( 总_do_191>总_do_231 )
  {
  总_do_191 = 总_do_231 ;
  }
 if ( 总_do_10<1.5 )
  {
  if ( 总_in_110 == 1 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 2 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 3 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 4 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 5 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 6 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 7 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 8 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 9 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 10 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 11 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 12 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 13 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 14 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 15 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 16 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 17 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 18 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 19 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 19 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 == 20 )
   {
   总_do_191 = NormalizeDouble(总_do_191 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_110 > 20 )
   {
   总_do_191 = NormalizeDouble(总_do_157 * 总_do_10,总_in_5) ;
   }
  if ( 总_do_191>总_do_231 )
   {
   总_do_191 = 总_do_231 ;
   }
  if ( 总_do_191<总_do_230 )
   {
   总_do_191 = 总_do_230 ;
  }}
 if ( 总_do_10>=1.5 )
  {
  if ( 总_in_110 > 0 )
   {
   总_do_191 = NormalizeDouble(总_do_157 * 总_do_10,总_in_5) ;
   }
  if ( 总_do_191>总_do_231 )
   {
   总_do_191 = 总_do_231 ;
   }
  if ( 总_do_191<总_do_230 )
   {
   总_do_191 = 总_do_230 ;
  }}
 return(总_do_191); 
 }
//lizong_6
//---------------------  ----------------------------------------

 double lizong_7()
 {

//----------------------------
 double     临_do_1;
 int        临_in_2;

 总_do_229 = FixLot ;
 if ( FixLot<总_do_230 )
  {
  总_do_229 = 总_do_230 ;
  }
 if ( 总_do_229>总_do_231 )
  {
  总_do_229 = 总_do_231 ;
  }
 if ( 总_bo_3 == true )
  {
  MarketInfo(总_st_228,23); 
  临_do_1 = AccountBalance() / 200.0;
  临_do_1 = MathFloor(临_do_1);
  临_do_1 = 临_do_1 * 0.01;
  if ( 临_do_1>MarketInfo(总_st_228,25) )
   {
   临_do_1 = MarketInfo(总_st_228,25);
   }
  if ( 临_do_1>临_do_1 )
   {
   临_do_1 = 临_do_1;
   }
  临_in_2 = 0;
  if ( MarketInfo(总_st_228,24)>=1.0 )
   {
   临_in_2 = 0;
   }
  else
   {
   if ( MarketInfo(总_st_228,24)>=0.1 )
    {
    临_in_2 = 1;
    }
   else
    {
    if ( MarketInfo(总_st_228,24)>=0.01 )
     {
     临_in_2 = 2;
     }
    else
     {
     临_in_2 = 3;
   }}}
  临_do_1 = NormalizeDouble(临_do_1,临_in_2);
  总_do_229 = 临_do_1 ;
  if ( 临_do_1<总_do_230 )
   {
   总_do_229 = 总_do_230 ;
   }
  if ( 总_do_229>总_do_231 )
   {
   总_do_229 = 总_do_231 ;
  }}
 总_do_192 = NormalizeDouble(总_do_229,总_in_5) ;
 if ( NormalizeDouble(总_do_229,总_in_5)<总_do_230 )
  {
  总_do_192 = 总_do_230 ;
  }
 if ( 总_do_192>总_do_231 )
  {
  总_do_192 = 总_do_231 ;
  }
 if ( 总_do_10<1.5 )
  {
  if ( 总_in_111 == 1 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 2 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 3 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 4 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 5 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 6 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 7 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 8 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 9 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 10 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 11 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 12 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 13 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 14 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 15 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 16 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 17 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 18 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 19 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 19 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 == 20 )
   {
   总_do_192 = NormalizeDouble(总_do_192 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10 * 总_do_10,总_in_5) ;
   }
  if ( 总_in_111 > 20 )
   {
   总_do_192 = NormalizeDouble(总_do_158 * 总_do_10,总_in_5) ;
   }
  if ( 总_do_192>总_do_231 )
   {
   总_do_192 = 总_do_231 ;
   }
  if ( 总_do_192<总_do_230 )
   {
   总_do_192 = 总_do_230 ;
  }}
 if ( 总_do_10>=1.5 )
  {
  if ( 总_in_111 > 0 )
   {
   总_do_192 = NormalizeDouble(总_do_158 * 总_do_10,总_in_5) ;
   }
  if ( 总_do_192>总_do_231 )
   {
   总_do_192 = 总_do_231 ;
   }
  if ( 总_do_192<总_do_230 )
   {
   总_do_192 = 总_do_230 ;
  }}
 return(总_do_192); 
 }
//lizong_7
//---------------------  ----------------------------------------

