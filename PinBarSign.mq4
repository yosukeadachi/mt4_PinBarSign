//+------------------------------------------------------------------+
//|                                                   PinBarSign.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 Aqua

//インジケーターバッファーの宣言
double Arrow_Up[];
double Arrow_Down[];
double Real_Body[];
double Upper_Shadow[];
double Lower_Shadow[];

//変数の宣言
extern int Highest_Period = 20;
extern int Lowest_Period = 20;
extern int Magnification = 3;
extern int Minimum_Length = 30;

double Pips = 0;

//関数の定義
double AdjustPoint(string Currency) {
  int Symbol_Digits = (int)MarketInfo(Symbol(),MODE_DIGITS);
  double Calculated_Point = 0.0;
  if((Symbol_Digits == 2) || (Symbol_Digits == 3)) {
    Calculated_Point = 0.01;
  } else if((Symbol_Digits == 4) || (Symbol_Digits == 5)) {
    Calculated_Point = 0.001;
  }
  return Calculated_Point;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
  //--- additional buffers
  IndicatorBuffers(5);
  //---- indicator buffers
  SetIndexBuffer(0,Arrow_Up);
  SetIndexBuffer(1,Arrow_Down);
  SetIndexBuffer(2,Real_Body);
  SetIndexBuffer(3,Upper_Shadow);
  SetIndexBuffer(4,Lower_Shadow);

  SetIndexLabel(0,NULL);
  SetIndexLabel(1,NULL);

  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,233);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexArrow(1,234);

  Pips = AdjustPoint(Symbol());

  return(INIT_SUCCEEDED);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {
                

  int limit = Bars - IndicatorCounted();
  // limit = 10;
  // printf("limit:%d", limit);
  // printf("Highest_Period:%d", Highest_Period);
  // printf("Lowest_Period:%d", Lowest_Period);
  // printf("Bars:%d", Bars);
  if(Bars < Highest_Period || Bars < Lowest_Period) {
    return(0);
  }

  int i = 0;
  //実体の計算
  for(i = limit - 1; i >= 0; i--) {
    Real_Body[i] = MathAbs(Open[i] - Close[i]);

    if(Real_Body[i] == 0) {
       Real_Body[i] += Pips; 
    }
  }

  //上ヒゲの計算
  for(i = limit - 1; i >= 0; i--) {
    Upper_Shadow[i] = MathMin(High[i] - Open[i], High[i] - Close[i]);
  }

  //下ヒゲの計算
  for(i = limit - 1; i >= 0; i--) {
    Lower_Shadow[i] = MathMin(Open[i] - Low[i], Close[i] - Low[i]);
  }

  //矢印の設定
  for(i = limit - 1; i >= 0; i--) {
    //上矢印の設定
    // printf("%d",i);
    // printf("Real_Body[i] * Magnification:%f",Real_Body[i] * Magnification);
    // printf("Lower_Shadow[i]:%f",Lower_Shadow[i]);
    // printf("Minimum_Length * Pips:%f",Minimum_Length * Pips);
    // printf("Low[i]:%f",Low[i]);
    // printf("iLowest(NULL,0,MODE_LOW,Lowest_Period,i+1):%f",iLowest(NULL,0,MODE_LOW,Lowest_Period,i+1));
    if(Real_Body[i] * Magnification <= Lower_Shadow[i] &&
     Minimum_Length * Pips <= Lower_Shadow[i] &&
     Low[i] < Low[iLowest(NULL,0,MODE_LOW,Lowest_Period,i+1)]) {
       printf("!!!!^%d^!!!!",i);
       Arrow_Up[i] = Low[i] - Pips;
     }

    //下矢印の設定
    if(Real_Body[i] * Magnification <= Upper_Shadow[i] && 
    Minimum_Length * Pips <= Upper_Shadow[i] &&
    High[i] > High[iHighest(NULL,0,MODE_HIGH,Highest_Period,i+1)]) {
       printf("!!!!_%d_!!!!",i);
      Arrow_Down[i] = High[i] + Pips;
    }
  }

  return(0);
}



//+------------------------------------------------------------------+
