//+------------------------------------------------------------------+
//|                                                     TSI_MACD.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_maximum 110
#property indicator_minimum -110
#property indicator_level1 0
//---- input parameters
extern int Fast = 8;
extern int Slow = 21;
extern int Signal = 5;
extern int First_R = 20;
extern int Second_S = 5;
extern int SignalPeriod = 5;
extern int Mode_Smooth = 2;
input bool           alertsOn        = false;        // Turn alerts on?
input bool           alertsOnCurrent = false;         // Alerts on (still opened) bar true/false?
input bool           alertsMessage   = false;         // Alerts message true/false?
input bool           alertsSound     = false;        // Alerts sound true/false?
input bool           alertsPushNotif = false;        // Alerts push notification true/false?
input bool           alertsEmail     = false;        // Alerts email true/false?
input string         soundFile       = "alert2.wav"; // Sound file

//---- buffers
double TSI_Buffer[];
double SignalBuffer[];
double MTM_Buffer[];
double EMA_MTM_Buffer[];
double EMA2_MTM_Buffer[];
double ABSMTM_Buffer[];
double EMA_ABSMTM_Buffer[];
double EMA2_ABSMTM_Buffer[];
double trend[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(9);
   SetIndexBuffer(0, TSI_Buffer);   SetIndexLabel(0, "TSI_MACD");
   SetIndexBuffer(1, SignalBuffer);  SetIndexLabel(1, "Signal");
   SetIndexBuffer(2, MTM_Buffer);
   SetIndexBuffer(3, EMA_MTM_Buffer);
   SetIndexBuffer(4, EMA2_MTM_Buffer);
   SetIndexBuffer(5, ABSMTM_Buffer);
   SetIndexBuffer(6, EMA_ABSMTM_Buffer);
   SetIndexBuffer(7, EMA2_ABSMTM_Buffer);
   SetIndexBuffer(8, trend);
//----
   IndicatorShortName("TSI_MACD(" + Fast + ", " + Slow + ", " + Signal + "; " + 
                      First_R + ", " + Second_S + ", " + SignalPeriod + ")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted(); 
   int limit, i;
   limit = Bars - counted_bars - 1;
//----
   for(i = Bars - 1; i >= 0; i--)
     {
       MTM_Buffer[i] = iMACD(NULL, 0, Fast, Slow, Signal, PRICE_CLOSE, MODE_MAIN, i) - 
                       iMACD(NULL, 0, Fast, Slow, Signal, PRICE_CLOSE, MODE_MAIN, i+1);  
       ABSMTM_Buffer[i] = MathAbs(MTM_Buffer[i]);
     }
//----
   for(i=Bars-1;i>=0;i--)
     {
       EMA_MTM_Buffer[i] = iMAOnArray(MTM_Buffer, 0, First_R, 0, MODE_EMA, i);
       EMA_ABSMTM_Buffer[i] = iMAOnArray(ABSMTM_Buffer, 0, First_R, 0, MODE_EMA, i);
     }
//----
   for(i = Bars - 1; i >= 0; i--)
     {
       EMA2_MTM_Buffer[i] = iMAOnArray(EMA_MTM_Buffer, 0, Second_S, 0, MODE_EMA, i);
       EMA2_ABSMTM_Buffer[i] = iMAOnArray(EMA_ABSMTM_Buffer, 0, Second_S, 0, MODE_EMA, i);
     }
//----
   for(i = limit; i >= 0; i--)
      if (EMA2_ABSMTM_Buffer[i]!=0)
            TSI_Buffer[i] = 100.0*EMA2_MTM_Buffer[i] / EMA2_ABSMTM_Buffer[i];
      else  TSI_Buffer[i] = 0;
//----
   for(i = limit; i >= 0; i--)
     {
       SignalBuffer[i] = iMAOnArray(TSI_Buffer, 0, SignalPeriod, 0, Mode_Smooth, i);
       trend[i] = trend[i+1];
       if (TSI_Buffer[i]>SignalBuffer[i]) trend[i] = 1;
       if (TSI_Buffer[i]<SignalBuffer[i]) trend[i] =-1;
     }
   if (alertsOn)
   {
      int whichBar = (alertsOnCurrent) ? 0 : 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
            if (trend[whichBar] == 1) doAlert(" up");
            if (trend[whichBar] ==-1) doAlert(" down");       
      }         
   }      
//----
   return(0);
  }
//+------------------------------------------------------------------+

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" TSI MACD "+doWhat;
             if (alertsMessage)     Alert(message);
             if (alertsPushNotif )  SendNotification(message);
             if (alertsEmail)       SendMail(_Symbol+" TSI MACD ",message);
             if (alertsSound)       PlaySound(soundFile);
      }
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}