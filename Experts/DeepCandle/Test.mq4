//+------------------------------------------------------------------+
//|                                            EA_RWF_V1.0_Edit4.mq4 |
//|                                                         TimeBite |
//|                                              jackcoder@gmail.com |
//+------------------------------------------------------------------+
#property copyright "TimeBite"
#property link      "jackcoder@gmail.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern string Separator_1             = "*** EA RECOVERY WAVE FIBONACCI ***"; 
       int    MagicNumber             = 0;
extern int    TotalOrders_Level_1     = 4; 
extern int    TotalOrders_Level_2     = 7;              

extern string Separator_2             = "*** SETTING MONEY MANAGEMENT ***";
input double  Lot                     = 0.1;             // Lot
input string  Martingale_Sequence     = "1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597";

extern string Separator_3             = "*** SETTING SPREAD - SLIPPAGE ***";
input int     MaxSpread_New           = 20;              // MaxSpread: Open First (Point)
input int     MaxSpread_Next          = 20;              // MaxSpread: Open Next (Point)
input int     Slippage                = 10;              // MaxSlippage (Point)

extern string Separator_4             = "*** SETTING OPTION TREND ***";
extern int    Range_CD                = 15;              // Range CD_Min (Pip)
extern double FiboAB_1                = 10;              // Min Fibo AB (%)
extern double FiboAB_2                = 80;              // Max Fibo AB (%)
extern double Min_Distance_TP         = 10;              // Min Distance TP (Pip)

extern string Separator_5             = "*** SETTING TP1: TotalOrders <= TotalOrders_Level_1 ***";
extern double Fibo_TP_1               = 23.6;             // Fibo TakeProfit

extern string Separator_6             = "*** SETTING TP2: TotalOrders > TotalOrders_Level_2 ***";
extern double Fibo_TP_2               = 38.2;             // Fibo TakeProfit

extern string Separator_7             = "*** SETTING NEXT STEP ORDER ***"; 
extern double Step_Order              = 20;               // Step Order (Pips)
extern double Step_SL                 = 20;               // Step StopLoss (Pips)

extern string Separator_8             = "*** SETTING TF TREND ***";
input string  TimeFrame_Trend         = "M5";             // TimeFrame Trend 
extern int    ExtDepth_1              = 12;
extern int    ExtDeviation_1          = 5;
extern int    ExtBackstep_1           = 3;

extern string Separator_9             = "*** SETTING TF TRADE ***";
input string  TimeFrame_Trade         = "M1";             // TimeFrame Trade
extern int    ExtDepth_2              = 12;
extern int    ExtDeviation_2          = 5;
extern int    ExtBackstep_2           = 3;

extern string Separator_10            = "*** SETTING CLOSE  ORDERS WHEN REACHE MAXRISK ***";
extern double MaxRisk                 = 20;               // MaxRisk Follow Ballance (%)

 //-----------------------------------------  
string      OrderCommentSell, OrderCommentBuy, CommentString;
double      Pips2Double, Pips2Points  ; 

double      Z[5];
double      iZ[3];
int         BarZ[5];
double      Max_Ratio;
int         Ticket;

//Martingale globals:
double      MartFactor[];
int         MartDepth =0;
int         Mart_Idx  =0;
double      LotsToTrade;
int         TF_Trend, TF_Trade; 
double      AB, CD, Entry, TP,SL, MaxZ, MinZ;

//+------------------------------------------------------------------+
#define     NL                  "\n"
#define     Status_initializing "????? I N I T I A L I Z I N G ?????"
#define     Status_initialized  "..... I N I T I A L I Z E D ....."
#define     Status_trading      "+++++ T R A D I N G +++++"
#define     Status_not_trading  "!!!!! N O T  T R A D I N G  !!!!!"
string      TradingStatus;

//Misc stuff
string      comment;
string      DisabledMessage;
string      objPrefix      = "EA-RWF";  // Prefixes of London Breakout Indicator objects;
string      Gap="          ";
int         iBar, Val;
double      zHigh, zLow;
datetime    TimeZ[5], iTimeMaxZ, iTimeMinZ;
 //+------------------------------------------------------------------+
 //| expert initialization function                                   |
 //+------------------------------------------------------------------+
 int init() 
  { 
   /*
   //------------Check The Password
   if(PassWord == 0984491888) 
     {Print("EA ready run for Real");  Alert("EA ready run for Real");}
   else 
     {
      Print("Password is Wrong.");
      Alert("Password is Wrong.");
      Alert("Contact Mr:Jack - Email:jackcoderfx@gmail.com");
      ExpertRemove();
      return(0) ; 
     }

   //------------Check The name of the Account 
   if(AccountInfoString(ACCOUNT_NAME) != "Jack Capital")
     {
      Alert("ACCOUNT_NAME is Wrong.");
      Alert("Contact Mr:Jack - Email:jackcoderfx@gmail.com");
      ExpertRemove();
      return(0) ; 
     }    

   //------------Check The Account Login 
   if(AccountInfoInteger(ACCOUNT_LOGIN) != 123456)
     {
      Alert("ACCOUNT_LOGIN is Wrong.");
      Alert("Contact Mr:Jack - Email:jackcoderfx@gmail.com");
      ExpertRemove();
      return(0) ; 
     }  
   */     

   //------------Check  The Expired    
   if((Year() >=2021) || (Year() ==2020 && Month() >= 7) || (Year() ==2020 && Month() == 6 && Day()>=  16)) 
    {
     Alert("EA expired.");
     Alert("Contact Mr:Chanh - Email:jackcoderfx@gmail.com");
     ExpertRemove();
     return(0) ;
    }
  //---------------------  
  if (!IsTradeAllowed())
   {
    Comment("!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"--- TRADING NOT ALLOWED YET---\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           );
     return(0);
   }
   
   //---------------------
   if (!IsExpertEnabled()) 
    {
      Alert("You did not allow your expert to run live, change your settings and apply the expert again");
      ExpertRemove();
      return(0) ; 
    }
   
   //---------------------
   if(IsTesting() || IsDemo()) {Print("Done"); }
   else 
     {
      Print("This version only run to testing or demo.");
      Alert("This version only run to testing or demo.");
      return(0) ; 
     } 
            
   //--------------------
   //TraceRunning();
   
   //--------------------  
   TradingStatus = Status_initializing;
   DisplayUserFeedback(); 
   
   //--------------------
   SetPip();    
   TF_Trend   = TimeFrame(TimeFrame_Trend);
   TF_Trade   = TimeFrame(TimeFrame_Trade);
      
   //--------------------       
   MartDepth     = string_list_to_double_array(Martingale_Sequence, ",", MartFactor);

   //--------------------   
   //--- Create random magicnumber
   if (MagicNumber == 0) 
    {MagicNumber = create_MagicNumber("");}  

   OrderCommentSell = "EA_RWF: Sell_" + IntegerToString(MagicNumber,0);
   OrderCommentSell = "EA_RWF: Bur_" + IntegerToString(MagicNumber,0); 
       
   //--------------------
   TradingStatus = Status_initialized;
   DisplayUserFeedback();     
   return(0);
 }

 //+------------------------------------------------------------------+
 //| expert deinitialization function                                 |
 //+------------------------------------------------------------------+
 int deinit() 
  {
   ObjectDelete("ZZLabel_1");
   ObjectDelete("ZZLabel_2");
   ObjectDelete("ZZLabel_3");
   ObjectDelete("ZZLabel_4");  

   for( int k=1; k<=3; k++)
    {ObjectDelete("Line" +IntegerToString(k));}
    
   return(0);
  }

 //+------------------------------------------------------------------+
 //| expert start function                                            |
 //+------------------------------------------------------------------+
 int start() 
 {    
  //--------------------
  if (!IsTradeAllowed())
   {
    Comment("!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"--- TRADING NOT ALLOWED YET---\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           +"!!!!!!!!!!!!!!!!!!!!!!!!!\n"
           );
     return(0);
   }
     
   //--------------------
   //TraceRunning();       // Display information to check option when to code

   //--------------------
   // Display information when TotalOrders() =0
   if(iTotalOrders() ==0)
    {
     TradingStatus = Status_not_trading;
     DisplayUserFeedback();  
    }
    
   //--------------------
   // Display information when TotalOrders() > 0
   if(iTotalOrders() > 0)
    {
     TradingStatus = Status_trading;
     DisplayUserFeedback();  
    }
          
   //-------------------- 
   GetZigZagInfo_01(TF_Trend, ExtDepth_1, ExtDeviation_1, ExtBackstep_1);   // Get value zigzag on timeframe trend (TF M5) and save array double
   GetZigZagInfo_02(TF_Trade, ExtDepth_2, ExtDeviation_2, ExtBackstep_2);   // Get value zigzag on timeframe trade (TF M1) and save array double
      
   //--- Set Entry ------
   Set_TP();             // Set takeprofit
   Update_Min_Max();     // Update Min_Max on pattern ABCD

  //-----------------------------------------------------------------------
  if(iTotalOrders() ==0)
   { ShowZigZag();}      // Draw pattern ABCD when TotalOrders() =0
       
  //-----------------------------------------------------------------------       
  //------Buy- First Order.
  if(iTotalOrders() ==0 &&
     CheckTrend() == 10 &&            // Check pattern ABCD on  timeframe M5
     CheckSignal() == 10 &&           // Check signal on timefram M1
     CheckDistanceTP() == true &&     // Check distance from current price to takeprofit 
     CheckMaxSpread_New() == true)    // Check spread
     {
      ShowZigZag();                   // Draw pattern ABCD when TotalOrders() > 0       
      LotsToTrade = MartFactor[0] * Lot;                      
      Open_Orders(OP_BUY,LotsToTrade);      
              
      if(Ticket > 0) 
             {
               MaxZ      = Z[2];
               iTimeMaxZ = TimeZ[2];
               MinZ      = Z[1];
               iTimeMinZ = TimeZ[1];
             }        
       return(0);
     }

   //-----------------------------------------------------------------------  
   //------Sell - First Order.
   if(iTotalOrders() ==0 &&            
      CheckTrend() == 20 &&            // Check pattern ABCD on  timeframe M5
      CheckSignal() == 20 &&           // Check signal on timefram M1
      CheckDistanceTP() == true &&     // Check distance from current price to takeprofi
      CheckMaxSpread_New() == true)    // Check spread
      { 
       ShowZigZag();                          
       LotsToTrade = MartFactor[0] * Lot;       
       Open_Orders(OP_SELL,LotsToTrade);       
                     
       if(Ticket > 0) 
             {
               MinZ      = Z[2];
               iTimeMinZ = TimeZ[2];
               iTimeMaxZ = TimeZ[1];
               MaxZ      = Z[1];
             } 
                    
       return(0);
      }

  //-----------------------------------------------------------------------         
  // Open Next Order Buy
   if( TotalOrders(OP_BUY) >= 1 && 
       TotalOrders(OP_BUY) <= TotalOrders_Level_2 -1 &&
       DistanceToLastOrder() >= Step_Order &&
       //iTradeLastOrderBar() >= 2*ExtDepth &&
       CheckSignal() == 10 &&
       CheckMaxSpread_Next() == true) 
       {    
        LotsToTrade = MartFactor[TotalOrders(OP_BUY)] * Lot;
        Open_Orders(OP_BUY,LotsToTrade);       
       } 

  //-----------------------------------------------------------------------
  // Open Next Order Sell
   if( TotalOrders(OP_SELL) >= 1 &&
       TotalOrders(OP_SELL)  <= TotalOrders_Level_2 -1 &&
       DistanceToLastOrder() >= Step_Order &&
       //iTradeLastOrderBar() >= 2*ExtDepth &&
       CheckSignal() == 20 &&
       CheckMaxSpread_Next() == true) 
       {
        LotsToTrade = MartFactor[TotalOrders(OP_SELL)] * Lot;          
        Open_Orders(OP_SELL,LotsToTrade);       
       } 

   //-----------------------------------------------------------------------     
   //--- Modify SL- When = TotalOrders() = MaxOrder 
   if( iTotalOrders() == TotalOrders_Level_2)
    {
     Set_SL();          
     ModifySL();     
    }
     
  //-----------------------------------------------------------------------
  //--- Close- Order Buy When Price Reach TP
  if((TotalOrders(OP_BUY) >=1  && Bid >= TP) ||
     (TotalOrders(OP_SELL) >=1 && Ask <= TP))
      {CloseOrders();}
          
  //-----------------------------------------------------------------------
  //--- Close- Order Buy When Profit Reach Max Drawdown
  if((TotalOrders(OP_BUY) >=1  || TotalOrders(OP_SELL) >=1)&&
     GetProfit() < 0 &&
     MathAbs(GetProfit()) >= AccountBalance() * (MaxRisk/100))      
      {CloseOrders();}
           
  //-----------------------------------------------------------------------        
    return(0);
  }


  
  
//+------------------------------------------------------------------+
 void SetPip()
  {
   //Pip and point
   if (Digits % 2 == 1)
   {
      Pips2Double  = Point*10; 
      Pips2Points  = 10;
   } 
   else
   {    
      Pips2Double  = Point;
      Pips2Points  =  1;
   }
  } 

 //+-----------------------------------------------------------------------+     
 int TimeFrame(string Input)
   {
     int TF = Period();
     
     if(Input == "M1")
          TF = PERIOD_M1;
     
     else if ( Input == "M5")
          TF = PERIOD_M5;  
          
     else if ( Input == "M15")
          TF = PERIOD_M15;   
          
     else if ( Input == "M30")
          TF = PERIOD_M30;
          
     else if ( Input == "H1" )
          TF = PERIOD_H1;
          
     else if ( Input == "H4" )
          TF = PERIOD_H4;
          
     else if ( Input == "D1" )
          TF = PERIOD_D1;
          
     else if ( Input == "W1" )
          TF = PERIOD_W1;
          
     else if ( Input == "MN" )
           TF = PERIOD_MN1;             
     return(TF);
  }

  //+-----------------------------------------------------------------------+  
  int CheckTrend()            // Check pattern ABCD on timeframe M5
   {
    int iCheck = 0;
    
    //-----------------------------------------    
    AB = MathAbs(Z[4]-Z[3]);
    CD = MathAbs(Z[2]-Z[1]);

    if(Z[4]  > Z[3] && Z[2] >= Z[3] + AB* (FiboAB_1/100) && Z[2] <= Z[3] + AB*(FiboAB_2/100) && Z[3]  > Z[1] && 
       CD/Pips2Double  >= Range_CD)
     {return(10);} 
        
    if(Z[4]  < Z[3] && Z[2] <= Z[3] - AB* (FiboAB_1/100) && Z[2] >= Z[3] - AB*(FiboAB_2/100) && Z[3]  < Z[1] && 
       CD/Pips2Double  >= Range_CD)
     {return(20);}         
       
    return(iCheck);
   }  

  //+-----------------------------------------------------------------------+  
  int CheckSignal()          // Check signal on timeframe M1
   {
    int iCheck = 0;
    
    //-----------------------------------------    
    if(iZ[1] > iZ[2])
     {return(10);} 
        
    if(iZ[1] < iZ[2])
     {return(20);}         
       
    return(iCheck);
   }  

 //+-----------------------------------------------------------------------+
 bool CheckMaxSpread_New()  // Check spread on  first order
  {
   bool iCheck = true;
   
    //=== Check MaxSpread
   double SymSpread = MarketInfo(Symbol(), MODE_SPREAD);
   if(MaxSpread_New >= 0 && MaxSpread_New < SymSpread) 
    {
     Alert("Spread is too high.");
     Print("Spread is too high.");
     return(false);
    }
   SymSpread = SymSpread * Point;
      
   return(iCheck); 
  }
  
 //+-----------------------------------------------------------------------+
 bool CheckMaxSpread_Next()  // Check spread on 2st, 3st ... order
  {
   bool iCheck = true;
   
    //=== Check MaxSpread
   double SymSpread = MarketInfo(Symbol(), MODE_SPREAD);
   if(MaxSpread_Next >= 0 && MaxSpread_Next < SymSpread) 
    {
     Alert("Spread is too high.");
     Print("Spread is too high.");
     return(false);
    }
   SymSpread = SymSpread * Point; 
   
   return(iCheck); 
  } 
     
  //+-----------------------------------------------------------------------+  
  bool CheckDistanceTP()    // check distance from current price to takeprofit
   {
    bool iCheck = false;
    
    if(Z[2] <  Z[1] && (Bid -TP)/Pips2Double >= Min_Distance_TP) {return(true);}    
    if(Z[2] >  Z[1] && (TP-Ask)/Pips2Double >= Min_Distance_TP)  {return(true);}  
    
    return(iCheck);    
   }
     
  //+-----------------------------------------------------------------------+ 
  void Set_TP()
   {
    // Set TP when TotalOrders() =0
    if(iTotalOrders() ==0)
     {
      if( Z[2] <  Z[1]) 
       {
        TP = Z[1] - MathAbs(Z[1]-Z[2]) * (Fibo_TP_1/100);
        DrawTP();
       }
      if( Z[2] >  Z[1]) 
       {
        TP = Z[1] + MathAbs(Z[2]-Z[1]) * (Fibo_TP_1/100);
        DrawTP();      
       }    
     }
     
   //--- Set TP In DealBuy When TotalOrders() >0
   if( TotalOrders(OP_BUY) >=1)
    {
     //ReSetMin(MinZ);
     iBar = LastBarShift();
     Val  =  iLowest(Symbol(), NULL, MODE_LOW, iBar+1,0);
     zLow = iLow(Symbol(), NULL, Val);
  
     if(MinZ > zLow) 
      { 
       MinZ      = zLow;
       iTimeMinZ = Time[Val];
       ReDrawCD();
      }
       
     if(TotalOrders(OP_BUY) <= TotalOrders_Level_1 )
      {
       TP = MinZ + (Fibo_TP_1 /100) * MathAbs(MaxZ -MinZ);
       DrawTP();
      }
    
     if(TotalOrders(OP_BUY) > TotalOrders_Level_1 && TotalOrders(OP_BUY) <= TotalOrders_Level_2)
      {
       TP = MinZ + (Fibo_TP_2 /100) * MathAbs(MaxZ -MinZ);
       DrawTP();
      }    
    }
   
   //--- Set TP In DealSell When TotalOrders() > 0
   if( TotalOrders(OP_SELL) >=1)
    {
     //ReSetMax(MaxZ);
     iBar = LastBarShift();
     Val  =  iHighest(Symbol(), NULL, MODE_HIGH, iBar+1,0);
     zHigh = iHigh(Symbol(), NULL, Val);
  
     if(MaxZ < zHigh ) 
      { 
       MaxZ      = zHigh;
       iTimeMaxZ = Time[Val];
       ReDrawCD();
      }
    
     if(TotalOrders(OP_SELL) <= TotalOrders_Level_1 )
      {
       TP = MaxZ - (Fibo_TP_1 /100) * MathAbs(MaxZ -MinZ);
       DrawTP();
      }
    
     if(TotalOrders(OP_SELL) > TotalOrders_Level_1 && TotalOrders(OP_SELL) <= TotalOrders_Level_2)
      {
       TP = MaxZ - (Fibo_TP_2 /100) * MathAbs(MaxZ -MinZ);
       DrawTP();
      }      
    }             
   } 

 //+-----------------------------------------------------------------------+ 
 void Set_SL()
  {
     if(TotalOrders(OP_BUY) == TotalOrders_Level_2)
      {SL = TradeLastOrderOpen() - Step_SL *Pips2Double;}      
     if( TotalOrders(OP_SELL) == TotalOrders_Level_2)
      {SL = TradeLastOrderOpen() + Step_SL * Pips2Double;}
      
      return;  
  }
 

 //+-----------------------------------------------------------------------+ 
 int Open_Orders(int iType,double iLot)
  {
   int ticket=-1;
   
   //---------------------------------
   if(iType==0)
     {
      while(ticket==-1)
       {
        if((CheckMoneyForTrade(Symbol(),LotsOptimized(iLot),OP_BUY))==TRUE)
         if((CheckVolumeValue(LotsOptimized(iLot)))==TRUE)    
          Ticket = OrderSend(Symbol(), OP_BUY, LotsOptimized(iLot), Ask, Slippage, 0, 0, OrderCommentBuy, MagicNumber, 0, DodgerBlue);  
          
        if(Ticket > 0) 
             {
               if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                {
				      Print("BUY order opened : ", OrderOpenPrice());
                  SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
			         Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Buy Signal");
                  PlaySound("alert.wav");
			       }
			      else 
			       {Print("Error opening BUY order : ", ErrorDescription(GetLastError()));}
             }              
         break;           
        }
     }
   //---------------------------------
   if(iType==1)
    {
      ticket=-1;
      while(ticket==-1)
       {
        if((CheckMoneyForTrade(Symbol(),LotsOptimized(iLot),OP_SELL))==TRUE)
         if((CheckVolumeValue(LotsOptimized(iLot)))==TRUE)     
          Ticket = OrderSend(Symbol(), OP_SELL, LotsOptimized(iLot), Bid, Slippage, 0, 0, OrderCommentSell, MagicNumber, 0, DeepPink);    
                               
        if(Ticket > 0) 
             {
               if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                {
				      Print("SELL order opened : ", OrderOpenPrice());
                  SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Sell Signal");
			         Alert("[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + "Sell Signal");
                  PlaySound("alert.wav");
			       }
			      else 
			       {Print("Error opening SELL order : ", ErrorDescription(GetLastError()));}
             }        
          break;
         }
     }
   //--------------------------------- 
   return(0);
  }
  
 //+-----------------------------------------------------------------------+ 
 int CloseOrders()
  {
   int total  = OrdersTotal();
   int iTicket;
  
   for (int cnt = total-1 ; cnt >= 0 ; cnt--)
    {
     if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
     if ( OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
      {
       if (OrderType()==OP_BUY)
        {
         iTicket =OrderClose(OrderTicket(),OrderLots(),Bid,Slippage);
         if (iTicket <= 0)  {Print(Symbol(), " - ", GetLastError());}
        }
      
       if (OrderType()==OP_SELL)
        {
         iTicket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage);
         if (iTicket <= 0)  {Print(Symbol(), " - ", GetLastError());}
        }           
      }
    }
   return(0);
  }

 //+-----------------------------------------------------------------------+   
 //Take Bars of last opened order in trades, except pending order.
 int LastBarShift() 
  {
     int      BarShift =0 ;
     datetime dt = TimeCurrent();   
     for (int i = 0; i <= OrdersTotal()-1; i++)
     {    if((OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) && (OrderSymbol()==Symbol()) && (OrderType()== OP_BUY || OrderType()== OP_SELL) && OrderMagicNumber() == MagicNumber) 
          {
               if ( dt > OrderOpenTime() ) 
               {
                    dt       = (datetime)OrderOpenTime();  
                    BarShift = iBarShift(Symbol(),NULL, OrderOpenTime());                     

               }
          }     
     }
     return(BarShift);
  }
  
  //+-----------------------------------------------------------------------+ 
  void Update_Min_Max()
   {
    //-----------------------------------------------------------------------
    if(TotalOrders(OP_BUY) ==0 && TotalOrders(OP_SELL) ==0)
     {
       MaxZ = 0;
       MinZ = 0;
     }      
   }
     
 //+-----------------------------------------------------------------------+  
 int iTotalOrders()
  {
   int c=0;
   int total  = OrdersTotal();

   for (int cnt = 0 ; cnt < total ; cnt++)
    {
     if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES) &&  OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
      {c++;}
    }
   return(c);
  }

 //+-----------------------------------------------------------------------+  
 int TotalOrders(int iTicket)
  {
   int c=0;
   int total  = OrdersTotal();

   for (int cnt = 0 ; cnt < total ; cnt++)
    {
     if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES) &&  OrderSymbol()==Symbol() &&  OrderType()== iTicket && OrderMagicNumber() == MagicNumber )
      {c++;}
    }
   return(c);
  }


 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type, lots);
   //-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   //--- checking successful
   return(true);
  }

  
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized(double iLots)
  {
   double lots=iLots;
   
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     {
      lots=minlot;
      Print("Volume is less than the minimal allowed ,we use",minlot);
     }
     
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     {
      lots=maxlot;
      Print("Volume is greater than the maximal allowed,we use",maxlot);
     }
     
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {
      lots=ratio*volume_step;
      Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ",ratio*volume_step);
     }
     
   return(lots);
  }
    
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume/*,string &description*/)

  {
   double lot=volume;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>max_volume)

      Print("Volume is greater than the maximal allowed ,we use",max_volume);
//  return(false);

//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)

      Print("Volume is less than the minimal allowed ,we use",minlot);
//  return(false);

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {
      Print("Volume is not a multiple of the minimal step ,we use, the closest correct volume is %.2f",
            volume_step,ratio*volume_step);
      //   return(false);
     }
//  description="Correct volume value";
   return(true);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double iSL,double iTP)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
                  " not be nearer than %d points from the closing price",stops_level,stops_level);
     }
//---
   bool SL_check=false,TP_check=false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check=(Bid-iSL>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Bid-stops_level*_Point,Bid,stops_level);
         //--- check the TakeProfit
         TP_check=(iTP-Bid>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Bid+stops_level*_Point,Bid,stops_level);
         //--- return the result of checking
         return(SL_check&&TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check=(SL-Ask>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Ask+stops_level*_Point,Ask,stops_level);
         //--- check the TakeProfit
         TP_check=(Ask-TP>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Ask-stops_level*_Point,Ask,stops_level);
         //--- return the result of checking
         return(TP_check&&SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
  
//+------------------------------------------------------------------+
double NDTP(double val)
  {
   RefreshRates();
   double SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(val<StopLevel*Point+SPREAD*Point)
      val=StopLevel*Point+SPREAD*Point;
   return(NormalizeDouble(val, Digits));
// return(val);
  } 

 //+-----------------------------------------------------------------------+          
 double GetProfit()
  {
   double Profit = 0;
   for (int TradeNumber = OrdersTotal(); TradeNumber >= 0; TradeNumber--)
   {
     if ( OrderSelect(TradeNumber, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {Profit = Profit + OrderProfit() + OrderSwap()+ OrderCommission();}
   }
   return (Profit);
  }

 //+-----------------------------------------------------------------------+ 
 double MaxDrawDown()
  {
   double Ratio;
  
   Ratio = 100*(AccountEquity() / AccountBalance() - 1.0);
   if( Ratio < 0 && MathAbs(Ratio) > MathAbs(Max_Ratio)) Max_Ratio = Ratio;
   return(Max_Ratio);
  }

 //+-----------------------------------------------------------------------+  
 int string_list_to_double_array(string list, string sep, double &array[])
  {
   //create an array of double from a string containing the list of values
   //ex: n = string_list_to_double_array ("1,2,3,5,8" , "," , &array);

   int i=0,j=0,k =0;
   string ls;

   while (true) 
    {
   	j = StringFind(list,sep,i);
   	if (j<0) break;

 		ls = StringTrimRight(StringTrimLeft(StringSubstr(list,i,j-i)));
 		i  = j+1;
 		k++;
 		ArrayResize(array,k);
 		array[k-1]=StrToDouble(ls);
    }
   //last element in the list:
	ls=StringTrimRight(StringTrimLeft(StringSubstr(list,i)));
	k++;
	ArrayResize(array,k);
	array[k-1]=StrToDouble(ls);

   return (ArraySize(array));
  }//string_list_to_double_array


 //+-----------------------------------------------------------------------+  
 int create_MagicNumber(string s)
  {
   // create a magic number that is "unique" for a given {EA_name,Symbol,Period} combo
   int magic=0;
   s = s+WindowExpertName()+Symbol()+DoubleToStr(Period(),0)+objPrefix;
   magic = hash_string(s);
   while (magic < 10000) 
    {// magic number is not long enough, make another one
     s = s+  DoubleToStr(magic,0);
     magic = hash_string(s);
    }
   return (magic);
  }

 //+-----------------------------------------------------------------------+  
 int hash_string(string s)
  {
   // this is the djb2 string hash algo
   int h = 5381, l = StringLen(s), i;
   for (i=0; i<l; i++) h = h * 33 + StringGetChar(s,i);
   return (h);
  } /*hash_string()*/

 //+-----------------------------------------------------------------------+   
 //Take Bars of last opened order in trades, except pending order.
 void ReSetMin(double iMinZ) 
  {
     int      BarShift =0 ;
     double   iMin;
     datetime dt = TimeCurrent();   
     for (int i = 0; i <= OrdersTotal()-1; i++)
     {    if((OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) && (OrderSymbol()==Symbol()) && (OrderType()== OP_BUY || OrderType()== OP_SELL) && OrderMagicNumber() == MagicNumber) 
          {
               if ( dt > OrderOpenTime() ) 
               {
                    dt       = (datetime)OrderOpenTime();  
                    BarShift = iBarShift(Symbol(),NULL, OrderOpenTime());                     
                    iMin     = iLow(Symbol(),NULL, iLowest(Symbol(), NULL,MODE_LOW, BarShift+1,0));                       
                    if(iMinZ > iMin)       iMinZ = iMin;
               }
          }     
     }
     return;
  }

 //+-----------------------------------------------------------------------+ 
 int DistanceToLastOrder()
  {
     int DistancePips      = 0 ;
     int LastTradeTicket   = TradeLastOrderTicket();
     int LastTradeType     = TradeOrderType(LastTradeTicket);
     double LastTradePrice = TradeOrderOpenPrice(LastTradeTicket);     
     if(LastTradeType == OP_BUY)
     {
          DistancePips = (int)((LastTradePrice -Ask)/Pips2Double);
     }
     
     if(LastTradeType == OP_SELL )
     {
          DistancePips = (int)((Bid -LastTradePrice )/Pips2Double);
     }
     
     return(DistancePips);
  }

 //+-----------------------------------------------------------------------+  
 //Function 
 //Take ticket of last opened order in trades, except pending order.
 int TradeLastOrderTicket() 
  {
     int iTicket  = -1; //Mas_Ord_New[1][6];
     datetime dt = 0;
    
    for (int i = 0; i <= OrdersTotal()-1; i++)
     {    if((OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) && (OrderSymbol()==Symbol()) && (OrderType()== OP_BUY || OrderType()== OP_SELL) && OrderMagicNumber() == MagicNumber) 
          {
               if ( dt < OrderOpenTime() ) 
               {
                    dt     = (datetime)OrderOpenTime();  
                    iTicket = (int)OrderTicket();
                                
               }
          }     
     }
     //-------------------------
     return (iTicket);
  }


 //+-----------------------------------------------------------------------+ 
 int TradeOrderType(int iTicket )
  {
     int Type = -1;
          
     for (int i = 0; i <= OrdersTotal()-1; i++)
     {    if((OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) && (OrderSymbol()==Symbol()) && (OrderType()== OP_BUY || OrderType()== OP_SELL) && OrderMagicNumber() == MagicNumber) 
          {   
               
               if ( OrderTicket() == iTicket )
               {
                    Type = (int)OrderType();
                    break;
               }
          }
     }
     
     return(Type);
  }

 //+-----------------------------------------------------------------------+  
 double TradeOrderOpenPrice(int iTicket)
  {
     double OpenPrice = 0.0;
     for (int i = 0; i <= OrdersTotal()-1; i++)
     {    if((OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) && (OrderSymbol()==Symbol()) && (OrderType()== OP_BUY || OrderType()== OP_SELL) && OrderMagicNumber() == MagicNumber) 
          { 
               if ( OrderTicket() == iTicket )
               {
                    OpenPrice = OrderOpenPrice();
                    break;
               }
          }
     }
     return(OpenPrice);
  }
  
 //+-----------------------------------------------------------------------+  
 //Function 
 //Take ticket of last opened order in trades, except pending order.
 double TradeLastOrderOpen() 
  {
     double OpenPrice  = 0; 
     datetime dt = 0;
    
     for (int i = 0; i <= OrdersTotal()-1; i++)
      {    
       if((OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) && (OrderSymbol()==Symbol()) && (OrderType()== OP_BUY || OrderType()== OP_SELL) && OrderMagicNumber() == MagicNumber) 
               if ( dt < OrderOpenTime() ) 
               {
                    dt        = (datetime)OrderOpenTime() ; 
                    OpenPrice = OrderOpenPrice();              
               }
          }     
     //-------------------------
     return (OpenPrice);
  }

 //+-----------------------------------------------------------------------+ 
 int iTradeLastOrderBar()  
  {
     datetime dt = 0;
     int _dt =0;
    
     int total  = OrdersTotal();
   if( total >=1)
   {
     for (int cnt = total-1 ; cnt >= 0 ; cnt--)
     {
      if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES) == true && OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
          {
               if ( dt < OrderOpenTime() ) 
               {
                    dt      = OrderOpenTime();   
                    _dt = iBarShift(Symbol(),NULL, OrderOpenTime());            
               }
          }     
     }
    }
     return (_dt);
  } 
   

  //+-----------------------------------------------------------------------+      
  //--- Modify SL- When = TotalOrders() = MaxOrder 
  void ModifySL()
   {    
     int total  = OrdersTotal();
     for (int cnt = 0 ; cnt < total ; cnt++)
      {
        if ( OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES) == true && OrderSymbol()==Symbol() && OrderType()== OP_SELL && OrderMagicNumber() == MagicNumber)
        if(  OrderStopLoss() != SL)   
           {
            Ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL, OrderTakeProfit(),0,CLR_NONE);
            if (Ticket <= 0)  {Print(Symbol(), " - ", ErrorDescription(GetLastError()));}
           }                 
       }                            
   }

//+------------------------------------------------------------------+
void ShowZigZag()
 {
    double LabelPos4, LabelPos3, LabelPos2, LabelPos1;
    
    for( int k=1; k<=3; k++)
     {  
	   ObjectCreate("Line" +IntegerToString(k) , OBJ_TREND, 0, TimeZ[k], Z[k], TimeZ[k+1], Z[k+1]); 
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_TIME1, TimeZ[k]);
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_PRICE1, Z[k]);	
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_TIME2, TimeZ[k+1]);
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_PRICE2, Z[k+1]); 
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_COLOR, Blue);
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_WIDTH, 4);
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_STYLE, STYLE_DASH);
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_RAY, false);
	   ObjectSet   ("Line" +IntegerToString(k) , OBJPROP_BACK, false);   
	   
    //----------------------------- 
    int ib4=BarZ[4];
    if(Z[4]>Z[3]) LabelPos4=NormalizeDouble(Z[4]+ 0.8*iATR(NULL,0,10,ib4),Digits);
    else LabelPos4=NormalizeDouble(Z[4]- iATR(NULL,0,10,ib4),Digits);              	  
    ObjectDelete("ZZLabel_4");
    ObjectCreate("ZZLabel_4",OBJ_TEXT,0,TimeZ[4],LabelPos4);
    ObjectSetText("ZZLabel_4","A",14,"Arial",Red);	 
    
    int ib3=BarZ[3];
    if(Z[3]>Z[2]) LabelPos3=NormalizeDouble(Z[3]+ 0.8*iATR(NULL,0,10,ib3),Digits);
    else LabelPos3=Z[3];              	  
    ObjectDelete("ZZLabel_3");
    ObjectCreate("ZZLabel_3",OBJ_TEXT,0,TimeZ[3],LabelPos3);
    ObjectSetText("ZZLabel_3","B",14,"Arial",Red);	  

    int ib2=BarZ[2];
    if(Z[2]>Z[1]) LabelPos2=NormalizeDouble(Z[2]+ 0.8*iATR(NULL,0,10,ib2),Digits);
    else LabelPos2=Z[2];              	  
    ObjectDelete("ZZLabel_2");
    ObjectCreate("ZZLabel_2",OBJ_TEXT,0,TimeZ[2],LabelPos2);
    ObjectSetText("ZZLabel_2","C",14,"Arial",Red);
    
    int ib1=BarZ[1];
    if(Z[1]>Z[2]) LabelPos1=NormalizeDouble(Z[1]+ 0.8*iATR(NULL,0,10,ib1),Digits);
    else LabelPos1=Z[1];              	  
    ObjectDelete("ZZLabel_1");
    ObjectCreate("ZZLabel_1",OBJ_TEXT,0,TimeZ[1],LabelPos1);
    ObjectSetText("ZZLabel_1","D",14,"Arial",Red);   	   
	 } 
  return;
 }

  
 //+-----------------------------------------------------------------------+ 
 void ReDrawCD()
 {   
    double LabelPos1;
                 
	 ObjectCreate("Line" +IntegerToString(1) , OBJ_TREND, 0,iTimeMaxZ, MaxZ, iTimeMinZ, MinZ); 
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_TIME1, iTimeMaxZ);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_PRICE1, MaxZ);	
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_TIME2, iTimeMinZ);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_PRICE2, MinZ);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_COLOR, Blue);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_WIDTH, 2);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_STYLE, STYLE_DASH);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_RAY, false);
	 ObjectSet   ("Line" +IntegerToString(1) , OBJPROP_BACK, false); 
	 

    int ib1=BarZ[1];
    if(Z[1]>Z[2]) LabelPos1=NormalizeDouble(Z[1]+ 0.8*iATR(NULL,0,10,ib1),Digits);
    else LabelPos1=Z[1];              	  
    ObjectDelete("ZZLabel_1");
    ObjectCreate("ZZLabel_1",OBJ_TEXT,0,TimeZ[1],LabelPos1);
    ObjectSetText("ZZLabel_1","D",14,"Arial",Red); 
	 	   
 }  
 
 //+-----------------------------------------------------------------------+ 
 void DrawTP()
 {
  ObjectDelete("LineTP");
  ObjectCreate("LineTP", OBJ_HLINE, 0, 0, TP);
  ObjectSet("LineTP", OBJPROP_COLOR, Red);
  ObjectSet("LineTP", OBJPROP_STYLE, STYLE_DOT);
  ObjectSet("LineTP", OBJPROP_WIDTH, 1);
  ObjectSet("LineTP", OBJPROP_BACK, True); 	   
 } 
 
  
 //+-----------------------------------------------------------------------+ 
 void GetZigZagInfo_01(int iTF_Trend, int iExtDepth, int iExtDeviation, int iExtBackstep)
  {
  int j=0;
   ArrayInitialize(BarZ,EMPTY_VALUE);  
   
   //-----------------------------------------  
   int PointShift1 = 0;
   string ConfirmedPoint1 = "Not Found";
   string PointShiftDirection = "None";

   while (ConfirmedPoint1 != "Found")
    {
    double ZZ = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift1);
    if(iHigh(NULL, iTF_Trend, PointShift1) == ZZ || iLow(NULL, iTF_Trend, PointShift1) == ZZ)
      {
      ConfirmedPoint1 = "Found";
      if(iHigh(NULL, iTF_Trend, PointShift1) == ZZ)
         {
         PointShiftDirection = "High";
         break;
         }
      if(iLow(NULL, iTF_Trend, PointShift1) == ZZ)
         {
         PointShiftDirection = "Low";
         break;
         }
      }
    BarZ[1] = PointShift1;  
    PointShift1++;   
   }   
    while(iHigh(NULL, PERIOD_M1,j) != iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift1) && 
          iLow(NULL, PERIOD_M1,j) != iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift1))
          {j++;}            
    TimeZ[1] = iTime(NULL, PERIOD_M1,j);  
     
  //-----------------------------------------  
  int PointShift2 = PointShift1;
  string ConfirmedPoint2 = "Not Found";

  while (ConfirmedPoint2 != "Found")
   {
   double ZZ2 = iCustom(NULL,iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift2);
   if(iHigh(NULL, iTF_Trend, PointShift2) == ZZ2 && PointShiftDirection == "Low")
      {
      ConfirmedPoint2 = "Found";
      break;
      }
   if(iLow(NULL, iTF_Trend, PointShift2) == ZZ2 && PointShiftDirection == "High")
      {
      ConfirmedPoint2 = "Found";
      break;
      }  
   BarZ[2] = PointShift2;    
   PointShift2++;                  
   }
 
             
  //------------------------------------------   
  int PointShift3 = PointShift2;
  string ConfirmedPoint3 = "Not Found";

  while (ConfirmedPoint3 != "Found")
   {
   double ZZ3 = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift3);
   if(iHigh(NULL, iTF_Trend, PointShift3) == ZZ3 && PointShiftDirection == "High")
      {
      ConfirmedPoint3 = "Found";
      break;
      }
   if(iLow(NULL, iTF_Trend, PointShift3) == ZZ3 && PointShiftDirection == "Low")
      {
      ConfirmedPoint3 = "Found";
      break;
      }  
   BarZ[3] = PointShift3;    
   PointShift3++;  
   
  
   }     
  
  //------------------------------------------   
  int PointShift4 = PointShift3;
  string ConfirmedPoint4 = "Not Found";

  while (ConfirmedPoint4 != "Found")
   {
   double ZZ4 = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift4);
   if(iHigh(NULL, iTF_Trend, PointShift4) == ZZ4 && PointShiftDirection == "Low")
      {
      ConfirmedPoint4 = "Found";
      break;
      }
   if(iLow(NULL, iTF_Trend, PointShift4) == ZZ4 && PointShiftDirection == "High")
      {
      ConfirmedPoint4 = "Found";
      break;
      } 
   BarZ[4] = PointShift4;     
   PointShift4++;  
   
  
   }   
   
                                           
  //-----------------------------------------        
  Z[1]  = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift1);
  Z[2]  = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift2);
  Z[3]  = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift3);
  Z[4]  = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift4);  
  
  
  //TimeZ[1] = iTime(NULL, iTF_Trend,PointShift1); 
  TimeZ[2] = iTime(NULL, iTF_Trend,PointShift2);
  TimeZ[3] = iTime(NULL, iTF_Trend,PointShift3);
  TimeZ[4] = iTime(NULL, iTF_Trend,PointShift4);
  
  //-----------------------------------------
                
  return; 
 }

 //+-----------------------------------------------------------------------+ 
 void GetZigZagInfo_02(int iTF_Trend, int iExtDepth, int iExtDeviation, int iExtBackstep)
  {
  //-----------------------------------------  
  int PointShift1 = 0;
  string ConfirmedPoint1 = "Not Found";
  string PointShiftDirection = "None";

  while (ConfirmedPoint1 != "Found")
   {
   double ZZ = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift1);
   if(iHigh(NULL, iTF_Trend, PointShift1) == ZZ || iLow(NULL, iTF_Trend, PointShift1) == ZZ)
      {
      ConfirmedPoint1 = "Found";
      if(iHigh(NULL, iTF_Trend, PointShift1) == ZZ)
         {
         PointShiftDirection = "High";
         break;
         }
      if(iLow(NULL, iTF_Trend, PointShift1) == ZZ)
         {
         PointShiftDirection = "Low";
         break;
         }
      }
    PointShift1++;   
   }
   
  //-----------------------------------------  
  int PointShift2 = PointShift1;
  string ConfirmedPoint2 = "Not Found";

  while (ConfirmedPoint2 != "Found")
   {
   double ZZ2 = iCustom(NULL,iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift2);
   if(iHigh(NULL, iTF_Trend, PointShift2) == ZZ2 && PointShiftDirection == "Low")
      {
      ConfirmedPoint2 = "Found";
      break;
      }
   if(iLow(NULL, iTF_Trend, PointShift2) == ZZ2 && PointShiftDirection == "High")
      {
      ConfirmedPoint2 = "Found";
      break;
      }   
   PointShift2++;   
   }
                            
  //-----------------------------------------        
  iZ[1]  = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift1);
  iZ[2]  = iCustom(NULL, iTF_Trend, "ZigZag", iExtDepth, iExtDeviation, iExtBackstep, 0, PointShift2);          
  return; 
 }
                      
  //+-----------------------------------------------------------------------+ 
  void TraceRunning()
  {  
     double DistanceToLastOrder  = (-1)* DistanceToLastOrder();  
         
     CommentString = 
          "    --- EA RWF V1.0 ---    "
          
          + "\n+--------------------------------------------------+"
          + "\n MaxOrder :                      " + DoubleToStr(TotalOrders_Level_2,0)
          + "\n TF_Trend :                      " + DoubleToStr(TF_Trend,0)
          + "\n TF_Trade :                      " + DoubleToStr(TF_Trade,0)
                            
          + "\n+--------------------------------------------------+" 
          + "\n CheckTrend :                   " + DoubleToStr(CheckTrend(),0)
          + "\n CheckSignal :                   " + DoubleToStr(CheckSignal(),0)
          + "\n CheckDistanceTP :            " + DoubleToStr(CheckDistanceTP(),0)
          //+ "\n CheckMaxSpread_New :     " + CheckMaxSpread_New()
          //+ "\n CheckMaxSpread_Next :     " + CheckMaxSpread_Next()
                   
          + "\n+--------------------------------------------------+" 
          + "\n TotalOrders :                   " + DoubleToStr(iTotalOrders(),0)
          + "\n TP :                               " + DoubleToStr(TP,4)

          + "\n+--------------------------------------------------+" 
          + "\n DistanceToLastOrder :       " + DoubleToStr(DistanceToLastOrder,0)         
          + "\n TradeLastOrderOpen :       " + DoubleToStr(TradeLastOrderOpen(),4)


          + "\n+--------------------------------------------------+"
          + "\n AccountBalance                " + DoubleToStr(AccountBalance(), 1) 
          + "\n AccountEquity                  " + DoubleToStr(AccountEquity(), 1) 
          + "\n Profit S/L:                        " + DoubleToStr(AccountEquity() - AccountBalance(), 1) + " $" + " / " + DoubleToStr(100.0 * (AccountEquity() / AccountBalance() - 1.0), 1) + " %" 
          + "\n Max DrawDown               " + DoubleToStr(MaxDrawDown(),1) + " %"
           
          + "\n+--------------------------------------------------+";
     Comment (CommentString);      
     return;      
  }

 //+-----------------------------------------------------------------------+  
 void DisplayUserFeedback()
  {
   static bool alreadyPrinted = false;
   
   //if (IsTesting() && !IsVisualMode() && alreadyPrinted) return; // saves cpu time when backtesting
   
   comment = comment + Gap + " ----------------------- "  + NL;
   comment = Gap + "*** EA RECOVERY WAVE FIBONACCI ***"+  NL;
   
   comment = comment +  NL;
   comment = comment+Gap+ "Magic number = "+ DoubleToStr(MagicNumber,0)+ NL;
   
   comment = comment +  NL;
   comment = comment +Gap+ "OPENING MAX TRADES EACH DEAL:  " + DoubleToStr(TotalOrders_Level_2,0) + " (ORDERS)" +NL;   

   comment = comment+Gap+ "EA USED AUTO-MARTINGALE ENABLED " + NL;
    
   comment = comment +  NL;
   comment = comment +Gap+ "Total Orders is openning:   " + DoubleToStr(iTotalOrders(),0) + " (Orders)" +NL;
   comment = comment + Gap+ "AccountEquity = " +DoubleToStr(AccountEquity(),1) + "$" + " - Profit P/L = " + DoubleToStr(AccountEquity() - AccountBalance(), 1)+ "$" + " - Max DrawDown = "+ DoubleToStr(MaxDrawDown(),1) + " %" +NL;
      
   comment = comment +  NL;
   comment = comment +Gap + "Broker time: "+ TimeToStr(TimeCurrent())+ " - Current Bar time: "+ TimeToStr(Time[0])+ NL;
   
   comment = comment +  NL; 
   comment = comment+Gap+ " " + TradingStatus+ NL;
   
   /*   
   if (IsTesting() && !IsVisualMode()) 
    {
      Print(comment);
      alreadyPrinted = true;
      return;
    }
   */
   
   Comment(comment);
  }//void DisplayUserFeedback()

 //+-----------------------------------------------------------------------+ 
 string ErrorDescription(int ErrorCode)
  {
   //--- Local variable
   string ErrorMsg;

   switch(ErrorCode)
     {
      //--- Codes returned from trade server
      case 0:    ErrorMsg="No error returned.";                                             break;
      case 1:    ErrorMsg="No error returned, but the result is unknown.";                  break;
      case 2:    ErrorMsg="Common error.";                                                  break;
      case 3:    ErrorMsg="Invalid trade parameters.";                                      break;
      case 4:    ErrorMsg="Trade server is busy.";                                          break;
      case 5:    ErrorMsg="Old version of the client terminal.";                            break;
      case 6:    ErrorMsg="No connection with trade server.";                               break;
      case 7:    ErrorMsg="Not enough rights.";                                             break;
      case 8:    ErrorMsg="Too frequent requests.";                                         break;
      case 9:    ErrorMsg="Malfunctional trade operation.";                                 break;
      case 64:   ErrorMsg="Account disabled.";                                              break;
      case 65:   ErrorMsg="Invalid account.";                                               break;
      case 128:  ErrorMsg="Trade timeout.";                                                 break;
      case 129:  ErrorMsg="Invalid price.";                                                 break;
      case 130:  ErrorMsg="Invalid stops.";                                                 break;
      case 131:  ErrorMsg="Invalid trade volume.";                                          break;
      case 132:  ErrorMsg="Market is closed.";                                              break;
      case 133:  ErrorMsg="Trade is disabled.";                                             break;
      case 134:  ErrorMsg="Not enough money.";                                              break;
      case 135:  ErrorMsg="Price changed.";                                                 break;
      case 136:  ErrorMsg="Off quotes.";                                                    break;
      case 137:  ErrorMsg="Broker is busy.";                                                break;
      case 138:  ErrorMsg="Requote.";                                                       break;
      case 139:  ErrorMsg="Order is locked.";                                               break;
      case 140:  ErrorMsg="Buy orders only allowed.";                                       break;
      case 141:  ErrorMsg="Too many requests.";                                             break;
      case 145:  ErrorMsg="Modification denied because order is too close to market.";      break;
      case 146:  ErrorMsg="Trade context is busy.";                                         break;
      case 147:  ErrorMsg="Expirations are denied by broker.";                              break;
      case 148:  ErrorMsg="The amount of open and pending orders has reached the limit.";   break;
      case 149:  ErrorMsg="An attempt to open an order opposite when hedging is disabled."; break;
      case 150:  ErrorMsg="An attempt to close an order contravening the FIFO rule.";       break;
      //--- Mql4 errors
      case 4000: ErrorMsg="No error returned.";                                             break;
      case 4001: ErrorMsg="Wrong function pointer.";                                        break;
      case 4002: ErrorMsg="Array index is out of range.";                                   break;
      case 4003: ErrorMsg="No memory for function call stack.";                             break;
      case 4004: ErrorMsg="Recursive stack overflow.";                                      break;
      case 4005: ErrorMsg="Not enough stack for parameter.";                                break;
      case 4006: ErrorMsg="No memory for parameter string.";                                break;
      case 4007: ErrorMsg="No memory for temp string.";                                     break;
      case 4008: ErrorMsg="Not initialized string.";                                        break;
      case 4009: ErrorMsg="Not initialized string in array.";                               break;
      case 4010: ErrorMsg="No memory for array string.";                                    break;
      case 4011: ErrorMsg="Too long string.";                                               break;
      case 4012: ErrorMsg="Remainder from zero divide.";                                    break;
      case 4013: ErrorMsg="Zero divide.";                                                   break;
      case 4014: ErrorMsg="Unknown command.";                                               break;
      case 4015: ErrorMsg="Wrong jump (never generated error).";                            break;
      case 4016: ErrorMsg="Not initialized array.";                                         break;
      case 4017: ErrorMsg="Dll calls are not allowed.";                                     break;
      case 4018: ErrorMsg="Cannot load library.";                                           break;
      case 4019: ErrorMsg="Cannot call function.";                                          break;
      case 4020: ErrorMsg="Expert function calls are not allowed.";                         break;
      case 4021: ErrorMsg="Not enough memory for temp string returned from function.";      break;
      case 4022: ErrorMsg="System is busy (never generated error).";                        break;
      case 4023: ErrorMsg="Dll-function call critical error.";                              break;
      case 4024: ErrorMsg="Internal error.";                                                break;
      case 4025: ErrorMsg="Out of memory.";                                                 break;
      case 4026: ErrorMsg="Invalid pointer.";                                               break;
      case 4027: ErrorMsg="Too many formatters in the format function.";                    break;
      case 4028: ErrorMsg="Parameters count exceeds formatters count.";                     break;
      case 4029: ErrorMsg="Invalid array.";                                                 break;
      case 4030: ErrorMsg="No reply from chart.";                                           break;
      case 4050: ErrorMsg="Invalid function parameters count.";                             break;
      case 4051: ErrorMsg="Invalid function parameter value.";                              break;
      case 4052: ErrorMsg="String function internal error.";                                break;
      case 4053: ErrorMsg="Some array error.";                                              break;
      case 4054: ErrorMsg="Incorrect series array using.";                                  break;
      case 4055: ErrorMsg="Custom indicator error.";                                        break;
      case 4056: ErrorMsg="Arrays are incompatible.";                                       break;
      case 4057: ErrorMsg="Global variables processing error.";                             break;
      case 4058: ErrorMsg="Global variable not found.";                                     break;
      case 4059: ErrorMsg="Function is not allowed in testing mode.";                       break;
      case 4060: ErrorMsg="Function is not allowed for call.";                              break;
      case 4061: ErrorMsg="Send mail error.";                                               break;
      case 4062: ErrorMsg="String parameter expected.";                                     break;
      case 4063: ErrorMsg="Integer parameter expected.";                                    break;
      case 4064: ErrorMsg="Double parameter expected.";                                     break;
      case 4065: ErrorMsg="Array as parameter expected.";                                   break;
      case 4066: ErrorMsg="Requested history data is in updating state.";                   break;
      case 4067: ErrorMsg="Internal trade error.";                                          break;
      case 4068: ErrorMsg="Resource not found.";                                            break;
      case 4069: ErrorMsg="Resource not supported.";                                        break;
      case 4070: ErrorMsg="Duplicate resource.";                                            break;
      case 4071: ErrorMsg="Custom indicator cannot initialize.";                            break;
      case 4072: ErrorMsg="Cannot load custom indicator.";                                  break;
      case 4073: ErrorMsg="No history data.";                                               break;
      case 4074: ErrorMsg="No memory for history data.";                                    break;
      case 4075: ErrorMsg="Not enough memory for indicator calculation.";                   break;
      case 4099: ErrorMsg="End of file.";                                                   break;
      case 4100: ErrorMsg="Some file error.";                                               break;
      case 4101: ErrorMsg="Wrong file name.";                                               break;
      case 4102: ErrorMsg="Too many opened files.";                                         break;
      case 4103: ErrorMsg="Cannot open file.";                                              break;
      case 4104: ErrorMsg="Incompatible access to a file.";                                 break;
      case 4105: ErrorMsg="No order selected.";                                             break;
      case 4106: ErrorMsg="Unknown symbol.";                                                break;
      case 4107: ErrorMsg="Invalid price.";                                                 break;
      case 4108: ErrorMsg="Invalid ticket.";                                                break;
      case 4109: ErrorMsg="Trade is not allowed in the Expert Advisor properties.";         break;
      case 4110: ErrorMsg="Longs are not allowed in the Expert Advisor properties.";        break;
      case 4111: ErrorMsg="Shorts are not allowed in the Expert Advisor properties.";       break;
      case 4112: ErrorMsg="Automated trading disabled by trade server.";                    break;
      case 4200: ErrorMsg="Object already exists.";                                         break;
      case 4201: ErrorMsg="Unknown object property.";                                       break;
      case 4202: ErrorMsg="Object does not exist.";                                         break;
      case 4203: ErrorMsg="Unknown object type.";                                           break;
      case 4204: ErrorMsg="No object name.";                                                break;
      case 4205: ErrorMsg="Object coordinates error.";                                      break;
      case 4206: ErrorMsg="No specified subwindow.";                                        break;
      case 4207: ErrorMsg="Graphical object error.";                                        break;
      case 4210: ErrorMsg="Unknown chart property.";                                        break;
      case 4211: ErrorMsg="Chart not found.";                                               break;
      case 4212: ErrorMsg="Chart subwindow not found.";                                     break;
      case 4213: ErrorMsg="Chart indicator not found.";                                     break;
      case 4220: ErrorMsg="Symbol select error.";                                           break;
      case 4250: ErrorMsg="Notification error.";                                            break;
      case 4251: ErrorMsg="Notification parameter error.";                                  break;
      case 4252: ErrorMsg="Notifications disabled.";                                        break;
      case 4253: ErrorMsg="Notification send too frequent.";                                break;
      case 4260: ErrorMsg="FTP server is not specified.";                                   break;
      case 4261: ErrorMsg="FTP login is not specified.";                                    break;
      case 4262: ErrorMsg="FTP connection failed.";                                         break;
      case 4263: ErrorMsg="FTP connection closed.";                                         break;
      case 4264: ErrorMsg="FTP path not found on server.";                                  break;
      case 4265: ErrorMsg="File not found in the Files directory to send on FTP server.";   break;
      case 4266: ErrorMsg="Common error during FTP data transmission.";                     break;
      case 5001: ErrorMsg="Too many opened files.";                                         break;
      case 5002: ErrorMsg="Wrong file name.";                                               break;
      case 5003: ErrorMsg="Too long file name.";                                            break;
      case 5004: ErrorMsg="Cannot open file.";                                              break;
      case 5005: ErrorMsg="Text file buffer allocation error.";                             break;
      case 5006: ErrorMsg="Cannot delete file.";                                            break;
      case 5007: ErrorMsg="Invalid file handle (file closed or was not opened).";           break;
      case 5008: ErrorMsg="Wrong file handle (handle index is out of handle table).";       break;
      case 5009: ErrorMsg="File must be opened with FILE_WRITE flag.";                      break;
      case 5010: ErrorMsg="File must be opened with FILE_READ flag.";                       break;
      case 5011: ErrorMsg="File must be opened with FILE_BIN flag.";                        break;
      case 5012: ErrorMsg="File must be opened with FILE_TXT flag.";                        break;
      case 5013: ErrorMsg="File must be opened with FILE_TXT or FILE_CSV flag.";            break;
      case 5014: ErrorMsg="File must be opened with FILE_CSV flag.";                        break;
      case 5015: ErrorMsg="File read error.";                                               break;
      case 5016: ErrorMsg="File write error.";                                              break;
      case 5017: ErrorMsg="String size must be specified for binary file.";                 break;
      case 5018: ErrorMsg="Incompatible file (for string arrays-TXT, for others-BIN).";     break;
      case 5019: ErrorMsg="File is directory, not file.";                                   break;
      case 5020: ErrorMsg="File does not exist.";                                           break;
      case 5021: ErrorMsg="File cannot be rewritten.";                                      break;
      case 5022: ErrorMsg="Wrong directory name.";                                          break;
      case 5023: ErrorMsg="Directory does not exist.";                                      break;
      case 5024: ErrorMsg="Specified file is not directory.";                               break;
      case 5025: ErrorMsg="Cannot delete directory.";                                       break;
      case 5026: ErrorMsg="Cannot clean directory.";                                        break;
      case 5027: ErrorMsg="Array resize error.";                                            break;
      case 5028: ErrorMsg="String resize error.";                                           break;
      case 5029: ErrorMsg="Structure contains strings or dynamic arrays.";                  break;
      case 5200: ErrorMsg="Invalid URL.";                                                   break;
      case 5201: ErrorMsg="Failed to connect to specified URL.";                            break;
      case 5202: ErrorMsg="Timeout exceeded.";                                              break;
      case 5203: ErrorMsg="HTTP request failed.";                                           break;
      default:   ErrorMsg="Unknown error.";
     }
   return(ErrorMsg);
  }


  