#property link          "https://www.earnforex.com/metatrader-indicators/volume-profile/"
#property version       "1.00"
#property strict
#property copyright     "EarnForex.com - 2020-2021"
#property description   "The Volume Profile Indicator, also know as Market Profile"
#property description   "Shows you the price levels with most price action"
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   "Find More on EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_chart_window
#property indicator_buffers 3

enum ENUM_TRADE_SIGNAL
  {
   SIGNAL_BUY=1,     //BUY
   SIGNAL_SELL=-1,   //SELL
   SIGNAL_NEUTRAL=0  //NEUTRAL
  };

enum ENUM_CALCULATION_START_TIME
  {
   CALC_START_LAST=0,      //MOST RECENT CANDLE
   CALC_START_MANUAL=1     //MANUAL SELECTION
  };

enum ENUM_CALCULATION_MODE
  {
   CANDLE_WHOLE=0,         //CANDLE WHOLE
   CANDLE_OPEN=2,          //CANDLE OPEN
   CANDLE_CLOSE=3          //CANDLE CLOSE
  };

enum ENUM_CALCULATION_RANGE_TIMEFRAME
  {
   CALC_TF_MINUTES=PERIOD_M1,      //MINUTES
   CALC_TF_HOURS=PERIOD_H1,        //HOURS
   CALC_TF_DAYS=PERIOD_D1,         //DAYS
   CALC_TF_WEEKS=PERIOD_W1         //WEEKS
  };

enum ENUM_CANDLE_TO_CHECK
  {
   CURRENT_CANDLE=0,    //CURRENT CANDLE
   CLOSED_CANDLE=1      //PREVIOUS CANDLE
  };

enum ENUM_ALERT_SIGNAL
  {

  };

input string Comment1="========================";     //MQLTA Volume Profile
input int StartTimeDx = 0;                            //StartTimeDx
input string IndicatorName="Volx";                    //Indicator Short Name
input string Comment2="========================";     //Indicator Parameters
input ENUM_TIMEFRAMES VPTimeFrame=PERIOD_CURRENT;     //Volume Profile Time Frame Calculation
input ENUM_CALCULATION_MODE CalculationMode=CANDLE_WHOLE;      //Value To Use For Calculation
input bool UseVolume=true;                            //Use Volume In The Calculation
input int StepPointsExt=10;                           //Step In Points

input string Comment2a="========================";       //Time Range For Calculation
input ENUM_CALCULATION_START_TIME StartTimeType=CALC_START_LAST;  //Show Volume Profile Up To
input int UnitsToScan=3;                                 //Calculate With Previous (Number Of Units)
input ENUM_CALCULATION_RANGE_TIMEFRAME UnitType=CALC_TF_DAYS;     //Calculate With Previous (Type Of Units)

input string Comment4="========================";     //Volume Profile Graph Parameters
input int WindowSize=1;                               //Window Width Multiplier
input color WindowColor=clrGainsboro;                 //Window Color
input bool ShowLineLabel=true;                        //Show Vertical Line Label
input color LineLabelColor=clrRed;                    //Vertical Line Label Color
input bool CleanLineAtClose=true;                    //Delete Vertical Line At Close

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string Comment5="========================";     //Point Of Control (POC) Parameters
input bool ShowPOC=true;                        //Show POC Line
input int POCSize=2;                            //POC Line Width (1 to 5)
input color POCColor=clrRed;                    //POC Line Color


long VolumeProfile[];
int Steps;
int BarsToScan=0;
int WindowSizeMin=10;
int ChartScale;
double StepPoints;
double PriceMin;
double PriceMax;
datetime StartTime=TimeCurrent();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   IndicatorSetString(INDICATOR_SHORTNAME,IndicatorName);

   OnInitInitialization();
   if(!OnInitPreChecksPass())
     {
      return(INIT_FAILED);
     }

   InitialiseBuffers();
   VolumeProfileCalculate();
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   bool IsNewCandle=CheckIfNewCandle();
   int pos,upTo;

   pos=0;
   if(prev_calculated==0 || IsNewCandle)
      upTo=BarsToScan-1;
   else
      upTo=0;


   if(IsNewCandle && StartTimeType==CALC_START_LAST)
     {
      StartTime = StartTimeDx == 0 ? TimeCurrent() : iTime(Symbol(),PERIOD_D1, StartTimeDx-1);
      ObjectSetInteger(0,IndicatorName+"-VLINE-VP",OBJPROP_TIME,StartTime);
      VolumeProfileCalculate();
     }

   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CleanChart();
   EventKillTimer();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {


   if(id==CHARTEVENT_OBJECT_CLICK)
     {

     }

   if(id==CHARTEVENT_CHART_CHANGE)
     {
      ChartScale=(int)MathRound(ChartGetInteger(0,CHART_SCALE,0));
      DrawVolumeProfile();
     }
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      if(StringFind(sparam,IndicatorName+"-VLINE-VP",0)>=0)
        {
         StartTime=(datetime)ObjectGetInteger(0,IndicatorName+"-VLINE-VP",OBJPROP_TIME);
         VolumeProfileCalculate();
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   StartTime=(datetime)ObjectGetInteger(0,IndicatorName+"-VLINE-VP",OBJPROP_TIME);
   VolumeProfileCalculate();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInitInitialization()
  {
   StepPoints=StepPointsExt*Point();
   ChartScale=(int)MathRound(ChartGetInteger(0,CHART_SCALE,0));
   BarsToScan=PeriodSeconds((ENUM_TIMEFRAMES)UnitType)*UnitsToScan/PeriodSeconds(VPTimeFrame);
   ScanLines();
   CreateLine();
   StartTime=(datetime)ObjectGetInteger(0,IndicatorName+"-VLINE-VP",OBJPROP_TIME);
   if(StartTimeType==CALC_START_LAST)
     {
      EventSetTimer(10);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OnInitPreChecksPass()
  {
   if(iBars(Symbol(),VPTimeFrame)<BarsToScan)
     {
      Alert("Insufficient Historical Data, only ",iBars(Symbol(),VPTimeFrame)," found in the time frame requested");
      printf("Insufficient Historical Data, only ",iBars(Symbol(),VPTimeFrame)," found in the time frame requested");
      return false;
     }
   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanChart()
  {
   int Window=0;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1; i>=0; i--)
     {
      if(StringFind(ObjectName(0,i),IndicatorName,0)>=0 && (StringFind(ObjectName(0,i),"-VLINE-VP",0)<0 || CleanLineAtClose || StartTimeType==CALC_START_LAST))
        {
         ObjectDelete(0,ObjectName(0,i));
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitialiseBuffers()
  {
   IndicatorBuffers(3);
   IndicatorDigits(Digits);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime NewCandleTime=TimeCurrent();
bool CheckIfNewCandle()
  {
   if(NewCandleTime==iTime(Symbol(),0,0))
      return false;
   else
     {
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void VolumeProfileCalculate()
  {
   int BarStart=iBarShift(Symbol(),VPTimeFrame,StartTime);
   int PriceHighMode=MODE_CLOSE;
   int PriceLowMode=MODE_CLOSE;
   if(CalculationMode==CANDLE_WHOLE)
     {
      PriceHighMode=MODE_HIGH;
      PriceLowMode=MODE_LOW;
     }
   if(CalculationMode==CANDLE_CLOSE)
     {
      PriceHighMode=MODE_CLOSE;
      PriceLowMode=MODE_CLOSE;
     }
   if(CalculationMode==CANDLE_OPEN)
     {
      PriceHighMode=MODE_OPEN;
      PriceLowMode=MODE_OPEN;
     }
   PriceMin=MathFloor(iLow(Symbol(),VPTimeFrame,iLowest(Symbol(),VPTimeFrame,PriceLowMode,BarsToScan,BarStart))/StepPoints)*StepPoints;
   PriceMax=MathCeil(iHigh(Symbol(),VPTimeFrame,iHighest(Symbol(),VPTimeFrame,PriceHighMode,BarsToScan,BarStart))/StepPoints)*StepPoints;
   Steps=(int)MathCeil((PriceMax-PriceMin)/StepPoints)+1;
   ArrayResize(VolumeProfile,Steps);
   ArrayInitialize(VolumeProfile,0);
   for(int i=0; i<BarsToScan; i++)
     {
      int j=BarStart+i;
      double MinPrice=0;
      double MaxPrice=0;
      double CandleSteps=0;
      if(CalculationMode==CANDLE_WHOLE)
        {
         MinPrice=iLow(Symbol(),VPTimeFrame,j);
         MaxPrice=iHigh(Symbol(),VPTimeFrame,j);
        }
      if(CalculationMode==CANDLE_CLOSE)
        {
         MinPrice=iClose(Symbol(),VPTimeFrame,j);
         MaxPrice=iClose(Symbol(),VPTimeFrame,j);
        }
      if(CalculationMode==CANDLE_OPEN)
        {
         MinPrice=iOpen(Symbol(),VPTimeFrame,j);
         MaxPrice=iOpen(Symbol(),VPTimeFrame,j);
        }
      MinPrice=MathFloor(MinPrice/StepPoints)*StepPoints;
      MaxPrice=MathFloor(MaxPrice/StepPoints)*StepPoints;
      CandleSteps=MathRound((MaxPrice-MinPrice)/StepPoints);
      for(int k=0; k<=CandleSteps; k++)
        {
         double CalcPrice=MinPrice+StepPoints*k;
         int h=(int)MathRound((CalcPrice-PriceMin)/StepPoints);
         long Weight=1;
         if(UseVolume)
            Weight=iVolume(Symbol(),VPTimeFrame,j);
         //Print(Steps," - ",i," - ",k," - ",MinPrice," - ",MaxPrice," - ",PriceMin," - ",PriceMax," - ",CalcPrice," - ",CandleSteps," - ",h);
         VolumeProfile[h]+=Weight;
        }
     }
   DrawVolumeProfile();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVolumeProfile()
  {
   CleanVolumeProfile();
   long VolumeMax=VolumeProfile[ArrayMaximum(VolumeProfile)];
   long VolumeMin=VolumeProfile[ArrayMinimum(VolumeProfile)];
   long VolumeDiffMax=VolumeMax-VolumeMin;
   double PricePOC=PriceMin+StepPoints*ArrayMaximum(VolumeProfile)+StepPoints/2;
   int VolumeWidth=(int)MathRound(WindowSizeMin*WindowSize*(6-ChartGetInteger(0,CHART_SCALE)));
   for(int i=0; i<ArraySize(VolumeProfile); i++)
     {
      double PriceLow=PriceMin+StepPoints*i;
      double PriceHigh=PriceLow+StepPoints;
      datetime TimeRight=StartTime;
      int StartTimeShift=iBarShift(Symbol(),PERIOD_CURRENT,StartTime);
      long VolumeDiff=VolumeProfile[i]-VolumeMin;
      //int TimeStepsShift=(int)MathRound((VolumeWidth*VolumeDiff)/VolumeDiffMax);
      int TimeStepsShift=(int)MathRound(((VolumeWidth-1)*VolumeProfile[i])/VolumeMax);
      //Print(VolumeMax," - ",VolumeMin," - ",VolumeProfile[i]," - ",VolumeMin," - ",VolumeDiff," - ",TimeStepsShift);
      datetime TimeLeft=iTime(Symbol(),PERIOD_CURRENT,StartTimeShift+TimeStepsShift+1);
      string RectangleName=IndicatorName+"-VP-RECT-"+DoubleToString(PriceLow/Point(),0);
      ObjectCreate(0,RectangleName,OBJ_RECTANGLE,0,TimeRight,PriceLow,TimeLeft,PriceHigh);
      ObjectSetInteger(0,RectangleName,OBJPROP_COLOR,WindowColor);
      ObjectSetInteger(0,RectangleName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,RectangleName,OBJPROP_BACK,true);
      ObjectSetInteger(0,RectangleName,OBJPROP_HIDDEN,true);
     }
   if(ShowPOC)
     {
      string POCName=IndicatorName+"-VP-RECT-H-"+DoubleToString(PricePOC/Point(),0);
      ObjectCreate(0,POCName,OBJ_HLINE,0,0,PricePOC);
      ObjectSetInteger(0,POCName,OBJPROP_COLOR,POCColor);
      ObjectSetInteger(0,POCName,OBJPROP_WIDTH,POCSize);
      ObjectSetInteger(0,POCName,OBJPROP_SELECTABLE,false);
     }
   UpdateLineLabels();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanVolumeProfile()
  {
   int Window=0;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1; i>=0; i--)
     {
      if(StringFind(ObjectName(0,i),IndicatorName+"-VP-RECT-",0)>=0 || StringFind(ObjectName(0,i),IndicatorName+"-VLINE-LABEL",0)>=0)
        {
         ObjectDelete(0,ObjectName(0,i));
        }
     }
  }


int TotalLines=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ScanLines()
  {
   TotalLines=0;
   for(int i=0; i<ObjectsTotal(); i++)
     {
      if(StringFind(ObjectName(0,i),IndicatorName+"-VLINE-VP",0)>=0)
        {
         TotalLines++;
         StartTime=(datetime)ObjectGetInteger(0,IndicatorName+"-VLINE-VP",OBJPROP_TIME);
         break;
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLine()
  {
   string LineName=IndicatorName+"-VLINE-VP";
   if(TotalLines==0)
     {
      ObjectCreate(0,LineName,OBJ_VLINE,0,iTime(Symbol(),PERIOD_CURRENT,0),0);
     }
   ObjectSetInteger(0,LineName,OBJPROP_COLOR,WindowColor);
   ObjectSetInteger(0,LineName,OBJPROP_BACK,true);
   if(StartTimeType==CALC_START_LAST)
     {
      ObjectSetInteger(0,LineName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,LineName,OBJPROP_TIME,iTime(Symbol(),PERIOD_CURRENT,0));
     }
   else
     {
      ObjectSetInteger(0,LineName,OBJPROP_SELECTABLE,true);
     }
   ObjectSetInteger(0,LineName,OBJPROP_WIDTH,1);
   UpdateLineLabels();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateLineLabels()
  {
   if(!ShowLineLabel)
      return;
   string LabelName=IndicatorName+"-VLINE-LABEL";
   ObjectCreate(0,LabelName,OBJ_TEXT,0,0,0);
   ObjectSetDouble(0,LabelName,OBJPROP_ANGLE,90);
   ObjectSetInteger(0,LabelName,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   int Y=(int)MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0)-10);
   double PriceY=0;
   int SubW=0;
   string UnitString="";
   if(UnitType==CALC_TF_DAYS)
      UnitString="DAYS";
   if(UnitType==CALC_TF_HOURS)
      UnitString="HOURS";
   if(UnitType==CALC_TF_MINUTES)
      UnitString="MINUTES";
   if(UnitType==CALC_TF_WEEKS)
      UnitString="WEEKS";
   string LabelDescr=IndicatorName+"-VP- PREVIOUS "+IntegerToString(UnitsToScan)+" "+UnitString;
   datetime TimeTmp=TimeCurrent();
   ChartXYToTimePrice(0,0,Y,SubW,TimeTmp,PriceY);
   ObjectSetInteger(0,LabelName,OBJPROP_TIME,StartTime);
   ObjectSetDouble(0,LabelName,OBJPROP_PRICE,PriceY);
   ObjectSetInteger(0,LabelName,OBJPROP_HIDDEN,false);
   ObjectSetText(LabelName,LabelDescr,10,"Consolas",LineLabelColor);
   ObjectSetInteger(0,LabelName,OBJPROP_COLOR,clrNONE);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllLines()
  {
   int Window=0;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),IndicatorName,0)>=0 && StringFind(ObjectName(i),IndicatorName+"-VLINE-",0)>=0)
        {
         ObjectDelete(ObjectName(i));
        }
     }
  }
//+------------------------------------------------------------------+
