//+------------------------------------------------------------------+
//|                                             Choppiness index.mq4 |
//|                                                           mladen |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_level1  61.8
#property indicator_level2  38.2
#property strict


//
//
//
//
//

extern int    CILength     = 14;             // Chopines index period
extern double LevelUp      = 61.8;           // Level up
extern double LevelDn      = 38.2;           // Level dowm
extern color  ColorNu      = clrSilver;      // Color for nuetral
extern color  ColorUp      = clrSandyBrown;  // Color for chopy
extern color  ColorDown    = clrLimeGreen;   // Color for trending
extern int    LineWidth    = 2;              // Main line width

double chop[],chopDa[],chopDb[],chopUa[],chopUb[],trend[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0, chop);     SetIndexStyle(0,EMPTY,EMPTY,LineWidth,ColorNu);
   SetIndexBuffer(1, chopUa);   SetIndexStyle(1,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(2, chopUb);   SetIndexStyle(2,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(3, chopDa);   SetIndexStyle(3,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(4, chopDb);   SetIndexStyle(4,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(5, trend);
      SetLevelValue(0,LevelUp);
      SetLevelValue(1,LevelDn);
   IndicatorShortName("Choppiness index ("+(string)CILength+")");
   return(0);
}
int deinit()
{
   return(0);
}

//
//
//
//
//

int start()
{
   double _log = MathLog(CILength)/100.00;
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1); 
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   if (trend[limit] ==-1) CleanPoint(limit,chopDa,chopDb);
   if (trend[limit] == 1) CleanPoint(limit,chopUa,chopUb);
   for (int i=limit; i>=0; i--)
   {  
      double atrSum =    0.00;
      double maxHig = High[i];
      double minLow =  Low[i];
               
         for (int k = 0; k < CILength && (i+k+1)<Bars; k++)
         {
            atrSum += MathMax(High[i+k],Close[i+k+1])-MathMin(Low[i+k],Close[i+k+1]);
            maxHig  = MathMax(maxHig,MathMax(High[i+k],Close[i+k+1]));
            minLow  = MathMin(minLow,MathMin( Low[i+k],Close[i+k+1]));
         }
         chop[i]   = (maxHig!=minLow) ? MathLog(atrSum/(maxHig-minLow))/_log : 0;
         chopDa[i] = EMPTY_VALUE;
         chopDb[i] = EMPTY_VALUE;
         chopUa[i] = EMPTY_VALUE;
         chopUb[i] = EMPTY_VALUE;
         trend[i]  = (chop[i]>LevelUp) ? 1 : (chop[i]<LevelDn) ? -1 : 0;
            if (trend[i] == 1) PlotPoint(i,chopUa,chopUb,chop);
            if (trend[i] ==-1) PlotPoint(i,chopDa,chopDb,chop);
   }         
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}