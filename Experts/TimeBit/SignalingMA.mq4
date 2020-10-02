//+------------------------------------------------------------------+
//|                                                  SignalingMA.mq4 |
//|                                      Copyright 2020, DeepCandle. |
//|                                       https://www.deepcandle.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, DeepCandle."
#property link      "https://www.deepcandle.com"
#property version   "1.00"
#property strict

input string                ____GroupMA____                         ="Indicator MA Level 1";
input int                   InpMaLv1Period                          = 70;
input int                   InpMaLv1Shift                           = 0;
input ENUM_MA_METHOD        InpMaLv1Method                          = MODE_SMA;
input ENUM_APPLIED_PRICE    InpMaLv1AppliedPrice                    = PRICE_CLOSE;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
