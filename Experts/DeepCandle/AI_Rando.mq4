//+------------------------------------------------------------------+
//|                                                     AI_Rando.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//---
input double            InpStopLoss          = 10;                //Stop Loss(in pips)
input double            InpTakeProfit        = 50;                //Take Profit (in pips)
input int               m_slippage           = 10;                //Slippage(in points)
input int               m_magic              = 88888888;          //Magic number
//---

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
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
void OnTick(){
//---
   string line = "";
   line += "Time = " + (string)TimeCurrent();
   line += "OrderTotal= " +  DoubleToStr(OrdersTotal());
   double handleMA = iMA(_Symbol,_Period,14,0,MODE_SMA, PRICE_CLOSE,0);
   line += "handleMa = " + DoubleToStr(handleMA);
   if(OrdersTotal()== 0){      
      int ticket = OrderSend(Symbol(), OP_BUY, 0.01, Ask, m_slippage, Ask - InpStopLoss * 10 * Point, Ask + InpTakeProfit * 10 * Point, NULL, m_magic, 0, Green);
      if(ticket<0){
         Print("OrderSend failed with error #",GetLastError());
      }else{
         Print("OrderSend placed successfully!!!Ticket",ticket );
      }
   }
   
   Comment(line);
}





//+------------------------------------------------------------------+
