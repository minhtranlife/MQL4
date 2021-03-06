//+------------------------------------------------------------------+
//|                                                         Base.mq4 |
//|                                      Copyright 2020, DeepCandle. |
//|                                       https://www.deepcandle.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, DeepCandle."
#property link      "https://www.deepcandle.com"
#property version   "1.00"
#property strict
enum ENUM_LOT_OR_RISK{
                            lot                       = 0,                 // Constant lot
                            risk                      = 1,                 // Risk in percent for a deal
};

enum ENUM_DAYOFWEEK{ 
                            all                       = 7,                 // ALL
                            mo                        = 1,                 // MONDAY
                            tu                        = 2,                 // TUESDAY
                            we                        = 3,                 // WEDNESDAY
                            th                        = 4,                 // THURSDAY
                            fr                        = 5,                 // FRIDAY
   
};
//--- input parameters
input string                ____Systems_Setting____;                    
input ENUM_DAYOFWEEK        InpDayOfWeek              = all;               // Day of week
input string                InpHoursString            = "9,10,11,12,15,16,17,18";   // Trading Hours (""or "24" = all time)
input int                   InpMinuteMin              = 0;                 // Minute Min 
input int                   InpMinuteMax              = 59;                // Minute Max 
input int                   InpMagic                  = 88888888;          // Magic number
//---
input string                ____Tradings_Setting____;
input ushort                InpBalanceStopPercent     = 50;                // Balance stop percents (0 = No Stop)
input bool                  InpReverse                = false;             // Reverse
input double                InpSpreadLimit            = 25;                // Spread Limit (in points)
input int                   InpSlippageLimit          = 25;                // Slippage Limit(in points)
//---
input string                ____Volumes_Setting____; 
input ENUM_LOT_OR_RISK      IntLotOrRisk              = risk;              // Money management: LOT or RISK
input double                InpVolumeLotOrRisk        = 1;                 // The value for "Money management"
//---
input string                 ____SLTP_Setting____; 
input ushort                InpStopLoss               = 50;                // Stop Loss (in pips)
input ushort                InpTakeProfit             = 100;                // Take Profit (in pips)
//---
input string                 ____Trailing_Stop_Setting____; 
input ushort                InpTrailingStop           = 0;                 // Trailing Stop (in pips. 0 = No trailing)
input ushort                InpTrailingStep           = 10;                // Trailing Step (in pips)
//---
input string                ____Copyright____                              = "Copyright © 2020 TraderFoo.Com";
//---
double                      ExtStopLoss               = 0.0;
double                      ExtTakeProfit             = 0.0;
double                      ExtTrailingStop           = 0.0;
double                      ExtTrailingStep           = 0.0;
double                      ExtBalanceTP              = 0.0;
double                      ExtBalanceSL              = 0.0; 
//---
double                      m_adjusted_point;                              // point value adjusted for 3 or 5 points
//---
bool                        m_need_open_buy           = false;
bool                        m_need_open_sell          = false;
bool                        m_waiting_transaction     = false;             // "true" -> it's forbidden to trade, we expect a transaction
ulong                       m_waiting_order_ticket    = 0;                 // ticket of the expected order
bool                        trading                   = true;
int                         order_ticket              = 0;
//---
MqlRates                    rates[];

string                      hours_array[];
//---
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
    RefreshRates();
    int digits_adjust = 1;
    if (_Digits == 3 || _Digits == 5)
        digits_adjust = 10;
    m_adjusted_point = _Point * digits_adjust;
    ExtStopLoss = InpStopLoss * m_adjusted_point;
    ExtTakeProfit = InpTakeProfit * m_adjusted_point;
    ExtTrailingStop = InpTrailingStop * m_adjusted_point;
    ExtTrailingStep = InpTrailingStep * m_adjusted_point;    
    ExtBalanceTP = AccountBalance() + (AccountBalance() * InpBalanceStopPercent/100);
    ExtBalanceSL = AccountBalance() - (AccountBalance() * InpBalanceStopPercent/100); 
//---
    InitHoursArray();
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|  Init                                                            |
//+------------------------------------------------------------------+
void InitHoursArray() {
    string sep=",";                // A separator as a character 
    ushort u_sep;                  // The code of the separator character 
    u_sep=StringGetCharacter(sep,0); 
    //--- Split the string to substrings 
    int k=StringSplit(InpHoursString,u_sep,hours_array); 
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
  
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
    if(CheckBalanceStop()){
        CloseAllPositions();
        trading = false;      
    }  
    //---      
    if(trading){
        Trade();      
    }
}
//+------------------------------------------------------------------+
void Trade(){ 
    if (m_waiting_transaction) {        
        m_need_open_buy = false; // "true" -> need to open BUY
        m_need_open_sell = false; // "true" -> need to open SELL
        m_waiting_transaction = false; // "true" -> it's forbidden to trade, we expect a transaction
        m_waiting_order_ticket = 0; // ticket of the expected order

    }
    if (m_need_open_buy) {
        double level;
        if (FreezeStopsLevels(level)) {
            m_waiting_transaction = true;
            OpenPosition("BUY", level);
        }
        //---
        return;
    }
    if (m_need_open_sell) {
        double level;
        if (FreezeStopsLevels(level)) {
            m_waiting_transaction = true;
            OpenPosition("SELL", level);
        }
        //---
        return;
    }
    //--- setup tradeing conditions
    SetupConditions();  
   
}

void SetupConditions(){
    double level;
    if(FreezeStopsLevels(level)){
        Trailing(level);
    }
    if(OrdersTotal() == 0){ 
        if(IsNewCandle()){
            if(CheckTimeOpenPosition()){  
                if(CheckSpread()){ 
                    int random_number = 10 + (int)MathRound((10000-10)*(MathRand()/32767.0));
                    if (random_number % 2 == 0){  
                        if(!InpReverse){
                            m_need_open_buy = true;
                        }else{
                            m_need_open_sell = true;
                        }
                    }else{
                        if(!InpReverse){
                           m_need_open_sell = true;
                        }else{
                           m_need_open_buy = true;
                        }
                    }                       
                    
                }   
            }
        }   
    }
}
void OpenPosition(string pos_type, double level){
    //---Buy
    if (pos_type == "BUY") {
        double price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
        double sl = (InpStopLoss == 0) ? 0.0 : price - ExtStopLoss;
        if (sl != 0.0 && ExtStopLoss < level) // check sl
            sl = price - level;
        double tp = (InpTakeProfit == 0) ? 0.0 : price + ExtTakeProfit;
        if (tp != 0.0 && ExtTakeProfit < level) // check price
            tp = price + level;
        OpenBuy(sl, tp);
    }
    //--- sell
    if (pos_type == "SELL") {
        double price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
        double sl = (InpStopLoss == 0) ? 0.0 : price + ExtStopLoss;
        if (sl != 0.0 && ExtStopLoss < level) // check sl
            sl = price + level;
        double tp = (InpTakeProfit == 0) ? 0.0 : price - ExtTakeProfit;
        if (tp != 0.0 && ExtTakeProfit < level) // check tp
            tp = price - level;
        OpenSell(sl, tp);
    }
}

double CalculateLotSize(double price, double sl){       
   
   double maxRisk = AccountBalance() * InpVolumeLotOrRisk/100;
   
   double riskPerPip = maxRisk/ CalculateRange(price, sl);
   
   double pipValue = 10 * SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   
   double lot = riskPerPip/pipValue;
   
   return NormalizeDouble(lot,2);
}

double CalculateRange(double X, double Y){
   double range = 0.0; 
   range = MathAbs(X - Y);
  
   double ranger = -1;
   if(_Digits == 2){
      ranger = range * 10;
   }   
   if(_Digits == 3){
      ranger = range * 100;
   }   
   if(_Digits == 5){
      ranger = range * 10000;
   }  
   return ranger;         
}

void OpenBuy(double sl, double tp){  
    double long_lot = 0.0;
    if(IntLotOrRisk == risk){
        long_lot = CalculateLotSize(Ask, sl);
    }else{
        long_lot = InpVolumeLotOrRisk;
    }
    Print(long_lot);
    double free_margin_check = AccountFreeMarginCheck(_Symbol, OP_BUY, long_lot);
    if(free_margin_check != 134){
        order_ticket = OrderSend(Symbol(), OP_BUY, long_lot, Ask, InpSlippageLimit, sl, tp, NULL, InpMagic, 0, Green);
        Print(order_ticket);
        if(order_ticket<0){
            m_waiting_transaction = false;
            Print("OrderSend failed with error #",GetLastError());
        }else{
            m_waiting_transaction = true; // "true" -> it's forbidden to trade, we expect a transaction
            m_waiting_order_ticket = order_ticket;
        }
    }else{
        m_waiting_transaction = false;
        return;
    }
}

void OpenSell(double sl, double tp){  
    double short_lot = 0.0;
    if(IntLotOrRisk == risk){
        short_lot = CalculateLotSize(Bid, sl);
    }else{
        short_lot = InpVolumeLotOrRisk;
    }
    Print(short_lot);
    double free_margin_check = AccountFreeMarginCheck(_Symbol, OP_SELL, short_lot);
    if(free_margin_check != 134){
        order_ticket = OrderSend(Symbol(), OP_SELL, short_lot, Bid, InpSlippageLimit, sl, tp, NULL, InpMagic, 0, Red);
        Print(order_ticket);
        if(order_ticket<0){
            m_waiting_transaction = false;
            Print("OrderSend failed with error #",GetLastError());
        }else{
            m_waiting_transaction = true; // "true" -> it's forbidden to trade, we expect a transaction
            m_waiting_order_ticket = order_ticket;
        }
    }else{
        m_waiting_transaction = false;
        return;
    }
}

//+------------------------------------------------------------------+
//| Check Conditions                                                 |
//+------------------------------------------------------------------+
bool CheckBalanceStop(){
   if(InpBalanceStopPercent > 0){
      if(AccountEquity() >= ExtBalanceTP){
         Print("Stop Trading TP ", ExtBalanceTP);
         return true;
      }
      if(AccountEquity() <= ExtBalanceSL){
         Print("Stop Trading SL ", ExtBalanceSL);
         return true;
      }
   }
   return false;
}

void CloseAllPositions() {
    for (int i = OrdersTotal() - 1; i >= 0; i--){ 
        if (OrderSelect(i,SELECT_BY_POS)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == InpMagic){
                int order_type=OrderType();
                if(order_type == 0){
                    if(OrderClose(OrderTicket(),OrderLots(),Ask,InpSlippageLimit,Red)){
                        Print("Close All Position");
                    }
                }
                if(order_type == 1){
                    if(OrderClose(OrderTicket(),OrderLots(),Bid,InpSlippageLimit,Red)){
                        Print("Close All Position");
                    }
                }
            }
        }
    }              
}


bool CheckHour(){
   MqlDateTime dt_struct;
   datetime dtSer=TimeCurrent(dt_struct);
   if(ArraySize(hours_array) == 0){
      return true; 
   }else if(ArraySize(hours_array) == 1){
       if(dt_struct.hour == (int)hours_array[0]){
            return true;
       }else if((int)hours_array[0] == 24){
            return true;
       }
   }else{   
      for(int i = 0; i< ArraySize(hours_array); i++){
         if(dt_struct.hour == (int)hours_array[i]){
            return true;
            break;
         }      
      } 
   }
   return false;
}

bool CheckMinute(){
   MqlDateTime dt_struct;
   datetime dtSer=TimeCurrent(dt_struct);
   if(_Period >= 16385){
      return true;
   }else if(dt_struct.min >= InpMinuteMin){
      if(dt_struct.min <= InpMinuteMax){
         return true;  
      }
   } 
   return false;
}

bool CheckDayOfWeek(){
   MqlDateTime dt_struct;
   datetime dtSer=TimeCurrent(dt_struct);
   if(InpDayOfWeek == all){
      return true;
   }else{
      if(dt_struct.day_of_week == InpDayOfWeek){
         return true;
      }   
   }  
   return false;
}

bool CheckTimeOpenPosition(){
    if(CheckDayOfWeek()){
        if(CheckHour()){
            if(CheckMinute()){
                return true;  
            }
        }    
    }    
    return false;
}

bool IsNewCandle(){
    ArraySetAsSeries(rates, true);
    CopyRates(_Symbol, _Period, 0, 1, rates);                    
    if(rates[0].open == rates[0].close && rates[0].open == rates[0].high && rates[0].open == rates[0].low){
        return true;
    }
    return false;
}

bool CheckSpread(){
   double bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   if(ask - bid <= InpSpreadLimit * _Point){
      return true;    
   }  
   return false;   
}

//+------------------------------------------------------------------+
//| Check Freeze and Stops levels                                    |
//+------------------------------------------------------------------+
bool FreezeStopsLevels(double & level) {
    //--- check Freeze and Stops levels
    /*
       Type of order/position  |  Activation price  |  Check
       ------------------------|--------------------|--------------------------------------------
       Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
       Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
       Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
       Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
       Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                               |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
       Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                               |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
                              
       Buying is done at the Ask price                 |  Selling is done at the Bid price
       ------------------------------------------------|----------------------------------
       TakeProfit        >= Bid                        |  TakeProfit        <= Ask
       StopLoss          <= Bid                        |  StopLoss          >= Ask
       TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
       Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
    */
    RefreshRates();
    //--- FreezeLevel -> for pending order and modification
    double freeze_level = MarketInfo(_Symbol, MODE_FREEZELEVEL) *_Point;
    if (freeze_level == 0.0)
        freeze_level = (Ask - Bid) * 3.0;
    freeze_level *= 1.1;
    //--- StopsLevel -> for TakeProfit and StopLoss
    double stop_level = MarketInfo(_Symbol, MODE_FREEZELEVEL) *_Point;
    if (stop_level == 0.0)
        stop_level = (Ask - Bid) * 3.0;
    stop_level *= 1.1;

    if (freeze_level <= 0.0 || stop_level <= 0.0)
        return (false);

    level = (freeze_level > stop_level) ? freeze_level : stop_level;
    //---
    return (true);
}

//+------------------------------------------------------------------+
//| Trailing stop function                                           |
//+------------------------------------------------------------------+
void Trailing(const double stop_level) {
    /*
       Buying is done at the Ask price                 |  Selling is done at the Bid price
       ------------------------------------------------|----------------------------------
       TakeProfit        >= Bid                        |  TakeProfit        <= Ask
       StopLoss          <= Bid                        |  StopLoss          >= Ask
       TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
       Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
    */
    if (InpTrailingStop == 0)
        return;
    for (int i = OrdersTotal() - 1; i >= 0; i--) // returns the number of open positions
        if (OrderSelect(i,SELECT_BY_POS))
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == InpMagic) {
                if (OrderType() == OP_BUY) {
                    if ( Bid - OrderOpenPrice() > ExtTrailingStop + ExtTrailingStep){
                        if (OrderStopLoss() < Bid - (ExtTrailingStop + ExtTrailingStep)){
                            if (ExtTrailingStop >= stop_level) {
                                if(!OrderModify(OrderTicket(), OrderOpenPrice(),(Bid - ExtTrailingStop), OrderTakeProfit(),0,Red)){                                 
                                    Print("Modify ", OrderTicket(),
                                        " Position -> false. Result Retcode: ",  GetLastError());
                                }        
                                RefreshRates();
                                int select = OrderSelect(i,SELECT_BY_POS);
                                continue;                                
                    
                            }
                        }
                    }
                }else {
                    if (OrderOpenPrice() - Ask > ExtTrailingStop + ExtTrailingStep)
                        if (OrderStopLoss() > Ask + (ExtTrailingStop + ExtTrailingStep)){
                            if (ExtTrailingStop >= stop_level) {                                
                                if(!OrderModify(OrderTicket(), OrderOpenPrice(),(Ask + ExtTrailingStop), OrderTakeProfit(),0,Blue)){            
                                    Print("Modify ", OrderTicket(),
                                        " Position -> false. Result Retcode: ",  GetLastError());
                                RefreshRates();
                                int select =OrderSelect(i,SELECT_BY_POS);
                                                                 
                            }
                        }
                    }
                }
            }
}