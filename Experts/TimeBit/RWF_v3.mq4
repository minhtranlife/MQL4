//+------------------------------------------------------------------+
//|                                                       RWF_v3.mq4 |
//|                                      Copyright 2020, DeepCandle. |
//|                                       https://www.deepcandle.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, DeepCandle."
#property link      "https://www.deepcandle.com"
#property version   "3.00"
#property strict
//---
enum ENUM_TP_MODE{
                            auto                    = 0 ,                   //No
                            manual                  = 1                     //Yes
};
//---
input string                ____GroupGeneralInformation____                 ="General Information";
input int                   InpBalanceStopLoss      = 25;                   //Balance stop (in percent)
input int                   InpSleep                = 300000;               //Sleep (milliseconds)
//---
input double                InpAValue               = 0.01;                 // A value
input double                InpCapitalCoefficient   = 5;                    // He so von (F1)
input double                InpAmplitudeCoefficient = 2;                    // He so bien do (F2)
input string                InpCoefficientString    = "2,3,4,5,6,7,8,9,10,11"; // He so Volume Position 
//---
input ushort                InpM5RangeCD            = 70;                   //M5 Range CD (in pips)
input double                InpTPF236Distance       = 10;                   //Distance from fibo to open price (pips)
//---
input ushort                InpStopLoss             = 20;                   //Stop Loss last position (in pips)
input string                InpLastDistanceString   = "5,10,15,25,30,5,10,15,20"; // Distance from new open price to last open price (percent)
//---
input bool                  Inp2ndReverseCheck      = 1;                    //Next check reverse
//---
input ENUM_TP_MODE          InpTPModeCheck          = 0;                    // Optimize TP
input int                   InpTPDistance           = 3;                    // TP point plus

input string                ____GroupZigZagTrend____                        ="ZigZag Trend";
input ENUM_TIMEFRAMES       InpM5ZigZagTimeFrame    = PERIOD_M5;            // ZigZag TimeFrame   
input int                   InpM5ZigZagDepth        = 5;                    // ZigZag Depth
input int                   InpM5ZigZagDeviation    = 5;                    // ZigZag Deviation
input int                   InpM5ZigZagBackStep     = 3;                    // ZigZag Backstep
input color                 InpM5ZigZagABCDColor    = clrYellow;            // ZigZag ABCD Color
input int                   InpM5ZigZagABCDWidth    = 5;                    // ZigZag Width
input bool                  InpM5ZigZagDisplay      = 1;                    //Display ZigZag
input string                ____GroupZigZagM1____                           ="ZigZag M1";
input int                   InpM1ZigZagDepth        = 5;                    // M1 ZigZag Depth
input int                   InpM1ZigZagDeviation    = 5;                    // M1 ZigZag Deviation
input int                   InpM1ZigZagBackStep     = 3;                    // M1 ZigZag Backstep
input color                 InpM1ZigZagCDColor      = clrAliceBlue;         // M1 ZigZag CD Color
input int                   InpM1ZigZagCDWidth      = 3;                    // M1 ZigZag CD Width
input bool                  InpM1ZigZagDisplay      = 1;                    // Display M1 ZigZag

input string                ____GroupFiboM5CheckForBuy____                  ="Fibo Trend check for buy";
input double                InpM5FiboBuyPercentSmall = 10.0;                // Fibo AB (Small)
input double                InpM5FiboBuyPercentMiddle = 40.0;               // Fibo AB (Middle)
input double                InpM5FiboBuyPercentBig   = 80.0;                // Fibo AB  (Big)
input color                 InpM5FiboBuyColor        = clrAqua;             // Fibo AB Color
input bool                  InpM5FiboBuyDisplay      = 1;                   //Display Fibo AB 

input string                ____GroupFiboM5CheckForSell____                 ="Fibo Trend  check for sell";
input double                InpM5FiboSellPercentSmall = 10.0;               // Fibo CD (Small)
input double                InpM5FiboSellPercentMiddle = 40.0;              // Fibo AB (Middle)
input double                InpM5FiboSellPercentBig   = 80.0;               // Fibo CD (Big)
input color                 InpM5FiboSellColor        = clrMediumAquamarine;// Fibo CD Color
input bool                  InpM5FiboSellDisplay      = 1;                  // Display M5 Fibo CD

input string                ____GroupTPFiboM5____                           ="TP Fibo Trend";
input int                   InpTPLevelChange        = 4;                    // TP Level Change
input double                InpTPFiboLevel1         = 23.6;                 // TP Fibo Level 1   
input double                InpTPFiboLevel2         = 38.2;                 // TP Fibo Level 2
input color                 InpTPColor              = clrMagenta;           // TP Fibo Color
input bool                  InpTPDisplay            = 1;                    // Display TP Fibo 

input string                ____GroupSystem____                             ="System";
input int                   m_slippage              = 10;                   // Slippage (in points)
input int                   m_magic                 = 88888888;             // Magic number

//-----------------------------------------  

double                      m5_abcd_array[5];
datetime                    m5_time_array[5];

double                      m5_zz_a_price;
datetime                    m5_zz_a_time;
double                      m5_zz_b_price;
datetime                    m5_zz_b_time;
double                      m5_zz_c_price;
datetime                    m5_zz_c_time;
double                      m5_zz_d_price;
datetime                    m5_zz_d_time;

double                      m1_cd_array[3];
datetime                    m1_time_array[3];

//string                      volumes_array[];


bool                        positions_total_check       = true;
double                      last_open_price;
double                      last_tp_price;
int                         position_type;
double                      m5_zz_d_price_for_tp        = 0.0;
datetime                    m5_zz_d_time_for_tp; 
double                      last_price_distance;
bool                        tp_ad                       = false; 
//---Update v3
string                      last_distance_array[];
int                         position_biggest            = 0;
double                      first_volumes_position      = 0.0;
string                      coefficient_volumes_array[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
    //---
    //InitVolumesArray();
    InitLastDistanceArray();
    InitCoefficientVolumesArray();
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
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle(){
   datetime NewCandleTime= TimeCurrent();
 
   //If the time of the candle when the function last run
   //is the same as the time of the time this candle started
   //return false, because it is not a new candle
   if(NewCandleTime==iTime(Symbol(),0,0)) return false;
   
   //otherwise it is a new candle and return true
   else{
      //if it is a new candle then we store the new value
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
   }
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
    //--------------------
    string messege_log = "";
    GetM5ZZHighLowArray();
    GetM1CDArray(); 
    DrawM5ZZABCDDefault();
    /*messege_log += "M5A = " + DoubleToString(m5_abcd_array[4]) + " - M5B = " + DoubleToString(m5_abcd_array[3]) + " - M5C = " + DoubleToString(m5_abcd_array[2]) + " - M5D = " + DoubleToString(m5_abcd_array[1]);
    messege_log += "\n time M5A = " + m5_time_array[4] + " - time M5B = " + m5_time_array[3] + " - time M5C = " + m5_time_array[2] + " - time M5D = " + m5_time_array[1];
    messege_log += "\nC= " +  DoubleToString(m1_cd_array[2]) + " - D= " + DoubleToString(m1_cd_array[1]);
    messege_log += "\n time C = " + m1_time_array[2] + " - time D = " + m1_time_array[1];
    //messege_log += "\n Volume = "  + volumes_array[9];
    messege_log += "\n RangeM5CD = "  + CalculateM5RangeCD();*/
    
    if(InpM1ZigZagDisplay){
        DrawM1ZZCD();
    }   
    
    string signal = GetSignal();
    int positions_total = OrdersTotal(); 
    //---
    if(position_biggest == 1 && positions_total == 0){
        position_biggest = 0;
        Sleep(InpSleep);
        Print("Sleep ", InpSleep );
        
    }
    //---     
    
    if(positions_total < ArraySize(coefficient_volumes_array) + 1){
        positions_total_check = true;
    }else{
        positions_total_check = false;
    }
    if(IsNewCandle()){
        if(positions_total_check){           
            //---        
            if(positions_total == 0){
                ObjectDelete(0,"FIBOBUYORSELL"); 
                ObjectDelete(0,"M5LineAB");     
                ObjectDelete(0,"M5LineBC");
                ObjectDelete(0,"M5LineCD");
                ObjectDelete(0,"M5A");
                ObjectDelete(0,"M5B");
                ObjectDelete(0,"M5C");
                ObjectDelete(0,"M5D");
                ObjectDelete(0,"FIBOTP");
                double acc_equity = AccountEquity();
                first_volumes_position = (InpAValue * acc_equity * (MathAbs(m5_abcd_array[2] - m5_abcd_array[1])))/(InpCapitalCoefficient * InpAmplitudeCoefficient);
                position_biggest = 0;
               
                if(signal == "BUY"){
                    m5_zz_a_price = m5_abcd_array[4];
                    m5_zz_b_price = m5_abcd_array[3];
                    m5_zz_c_price = m5_abcd_array[2];
                    m5_zz_d_price = m5_abcd_array[1];
                    //---            
                    m5_zz_a_time = m5_time_array[4];
                    m5_zz_b_time = m5_time_array[3];
                    m5_zz_c_time = m5_time_array[2];
                    m5_zz_d_time = m5_time_array[1]; 
                    
                    if(InpM5ZigZagDisplay){
                        DrawM5ZZABCD();
                    }
                    if(InpM5FiboBuyDisplay){
                        DrawM5FiboBuySell(m5_zz_a_price, m5_zz_b_price, m5_zz_a_time, m5_zz_b_time, InpM5FiboBuyPercentSmall,  InpM5FiboBuyPercentMiddle, InpM5FiboBuyPercentBig, InpM5FiboBuyColor);
                    }                 
                    //---
                    if(InpTPModeCheck == 0){  
                        double tp = 0.0;
                        if(tp_ad){
                            tp = CalculateTP(m5_zz_a_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_a_price, m5_zz_d_price,m5_zz_a_time,m5_zz_d_time);
                            } 
                        }else{
                            tp = CalculateTP(m5_zz_c_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_c_price, m5_zz_d_price,m5_zz_c_time,m5_zz_d_time);
                            } 
                        }                   
                        int first_ticket = OrderSend(Symbol(), OP_BUY, first_volumes_position, Ask, m_slippage, 0,tp, NULL, m_magic, 0, Green);
                        if(first_ticket > 0){
                            last_open_price = Ask; 
                            last_tp_price = tp; 
                            position_biggest++;
                            
                        }
                    }
                    if(InpTPModeCheck == 1){
                        double tp = 0.0;
                        if(tp_ad){
                            tp = CalculateTP(m5_zz_a_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_a_price, m5_zz_d_price,m5_zz_a_time,m5_zz_d_time);
                            } 
                        }else{
                            tp = CalculateTP(m5_zz_c_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_c_price, m5_zz_d_price,m5_zz_c_time,m5_zz_d_time);
                            } 
                        }                          
                        int first_ticket = OrderSend(Symbol(), OP_BUY, first_volumes_position, Ask, m_slippage, 0,0, NULL, m_magic, 0, Green);
                        if(first_ticket > 0){
                            last_open_price = Ask;
                            last_tp_price = tp;
                            m5_zz_d_price_for_tp = m5_abcd_array[1];
                            m5_zz_d_time_for_tp = m5_time_array[1];
                            position_biggest++;
                            
                        }
                    }                
                    //---                
                    position_type = 0;
                }
                if(signal == "SELL") {
                    m5_zz_a_price = m5_abcd_array[4];
                    m5_zz_b_price = m5_abcd_array[3];
                    m5_zz_c_price = m5_abcd_array[2];
                    m5_zz_d_price = m5_abcd_array[1];
                    //---            
                    m5_zz_a_time = m5_time_array[4];
                    m5_zz_b_time = m5_time_array[3];
                    m5_zz_c_time = m5_time_array[2];
                    m5_zz_d_time = m5_time_array[1]; 
                    //---            
                    if(InpM5ZigZagDisplay){
                        DrawM5ZZABCD();
                    }                
                    if(InpM5FiboSellDisplay){
                        DrawM5FiboBuySell(m5_zz_a_price, m5_zz_b_price, m5_zz_a_time, m5_zz_b_time, InpM5FiboSellPercentSmall, InpM5FiboSellPercentMiddle,InpM5FiboSellPercentBig, InpM5FiboSellColor);
                    } 
                    //---            
                    //--- 
                    if(InpTPModeCheck == 0){               
                        double tp = 0.0;
                        if(tp_ad){
                            tp = CalculateTP(m5_zz_a_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_a_price, m5_zz_d_price,m5_zz_a_time,m5_zz_d_time);
                            } 
                        }else{
                            tp = CalculateTP(m5_zz_c_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_c_price, m5_zz_d_price,m5_zz_c_time,m5_zz_d_time);
                            } 
                        }              
                        int first_ticket = OrderSend(Symbol(), OP_SELL, first_volumes_position, Bid, m_slippage, 0,tp, NULL, m_magic, 0, Red);
                        if(first_ticket > 0){
                            last_tp_price = tp;
                            last_open_price = Bid;
                            position_biggest++; 
                           
                        }
                        
                    }
                    if(InpTPModeCheck == 1){
                        double tp = 0.0;
                        if(tp_ad){
                            tp = CalculateTP(m5_zz_a_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_a_price, m5_zz_d_price,m5_zz_a_time,m5_zz_d_time);
                            } 
                        }else{
                            tp = CalculateTP(m5_zz_c_price, m5_zz_d_price);
                            if(InpTPDisplay){
                                DrawM5FiboTP(m5_zz_c_price, m5_zz_d_price,m5_zz_c_time,m5_zz_d_time);
                            } 
                        }                 
                        int first_ticket = OrderSend(Symbol(), OP_SELL, first_volumes_position, Bid, m_slippage, 0,0, NULL, m_magic, 0, Red);
                        if(first_ticket > 0){
                            last_open_price = Bid;
                            last_tp_price = tp;
                            m5_zz_d_price_for_tp = m5_abcd_array[1];
                            m5_zz_d_time_for_tp = m5_time_array[1] ;
                            position_biggest++;
                            
                        }
                    }
                    //--- 
                    position_type = 1;
                }
                last_price_distance = (MathAbs(m5_zz_c_price - m5_zz_d_price)/100 ) * StringToDouble(last_distance_array[0]);                
            }
            //---
            //---    
            if(positions_total == 1 || positions_total == 2 || positions_total == 3 || positions_total == 4 || positions_total == 5
                ||positions_total == 6 || positions_total == 7 || positions_total == 8 || positions_total == 9 || positions_total == 10
                ||positions_total == 11 || positions_total == 12 || positions_total == 13 || positions_total == 14 || positions_total == 15
                ||positions_total == 16 || positions_total == 17 || positions_total == 18 || positions_total == 19 || positions_total == 20) {
                //---Update       
                if(positions_total > 1){
                     last_price_distance = (MathAbs(m5_zz_c_price - m5_zz_d_price_for_tp)/100 ) * StringToDouble(last_distance_array[positions_total - 1]);      
                }                         
                double volume_position = first_volumes_position * StringToDouble(coefficient_volumes_array[positions_total -1]); 
                //Comment(volume_position);
                //---Buy 
                if(position_type == 0){
                    if(last_open_price - last_price_distance >= Ask){
                        if(Inp2ndReverseCheck == 0){
                            if(InpTPModeCheck == 0){
                                double tp = 0.0;             
                                if(tp_ad){
                                    tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                }else{
                                    tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                    
                                }
                                                             
                                int last_ticket = OrderSend(Symbol(), OP_BUY, volume_position, Ask, m_slippage, 0,tp, NULL, m_magic, 0, Green);
                                if(last_ticket > 0){
                                    last_open_price = Ask;
                                    last_tp_price = tp;
                                    SetTP(tp, position_type);
                                    position_biggest ++;
                                }                             
                            }
                            if(InpTPModeCheck == 1){
                                double tp = 0.0;             
                                if(tp_ad){
                                    tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                }else{
                                    tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                    
                                }          
                                int last_ticket = OrderSend(Symbol(), OP_BUY, volume_position, Ask, m_slippage, 0,0, NULL, m_magic, 0, Green);
                                if(last_ticket > 0) {
                                    last_open_price = Ask;                                
                                    last_tp_price = tp;
                                    position_biggest++;
                                }                    
                            } 
                        }
                        //Check M1 Reverse
                        if(Inp2ndReverseCheck == 1){
                            if(m1_cd_array[2] < m1_cd_array[1]){
                                if(InpTPModeCheck == 0){
                                    double tp = 0.0;             
                                    if(tp_ad){
                                        tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                    }else{
                                        tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                        
                                    }        
                                    int last_ticket = OrderSend(Symbol(), OP_BUY, volume_position, Ask, m_slippage, 0,tp, NULL, m_magic, 0, Green);
                                    if(last_ticket > 0){
                                        last_open_price = Ask;
                                        last_tp_price = tp;
                                        SetTP(tp, position_type);
                                        position_biggest++;
                                    }                             
                                }
                                if(InpTPModeCheck == 1){
                                    double tp = 0.0;             
                                    if(tp_ad){
                                        tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                    }else{
                                        tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                        
                                    }            
                                    int last_ticket = OrderSend(Symbol(), OP_BUY, volume_position, Ask, m_slippage, 0,0, NULL, m_magic, 0, Green);
                                    if(last_ticket > 0) {
                                        last_open_price = Ask;                                    
                                        last_tp_price = tp;
                                        position_biggest++;
                                    }                    
                                } 
                            }
                        }                   
                    }
                    //Lấy ra đáy thấp nhất ZZ M5  
                    if(m5_abcd_array[1] < m5_zz_d_price_for_tp){
                        m5_zz_d_price_for_tp = m5_abcd_array[1];
                        m5_zz_d_time_for_tp = m5_time_array[1];
                        //---
                        
                    }              
                }
                //---Sell            
                if(position_type == 1){
                    if(Bid - last_open_price >= last_price_distance){
                        if(Inp2ndReverseCheck == 0){
                            if(InpTPModeCheck == 0){
                                double tp = 0.0;             
                                if(tp_ad){
                                    tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                }else{
                                    tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                    
                                }       
                                int last_ticket = OrderSend(Symbol(), OP_SELL, volume_position, Bid, m_slippage, 0,tp, NULL, m_magic, 0, Red);
                                if(last_ticket >0){
                                    last_open_price = Bid;
                                    last_tp_price = tp;
                                    SetTP(tp, position_type);
                                    position_biggest++;
                                }                                
                            }
                            if(InpTPModeCheck == 1){
                                double tp = 0.0;             
                                if(tp_ad){
                                    tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                }else{
                                    tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                    
                                }      
                                int last_ticket = OrderSend(Symbol(), OP_SELL,volume_position, Bid, m_slippage, 0,0, NULL, m_magic, 0, Red);
                                if(last_ticket > 0){
                                    last_open_price = Bid;
                                    last_tp_price = tp;
                                    position_biggest++;
                                }
                            }                    
                        }
                        //Check M1 Reverse
                        if(Inp2ndReverseCheck == 1){
                            if(m1_cd_array[2] > m1_cd_array[1]) {     
                                if(InpTPModeCheck == 0){
                                    double tp = 0.0;             
                                    if(tp_ad){
                                        tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                    }else{
                                        tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                    
                                    }          
                                    int last_ticket = OrderSend(Symbol(), OP_SELL, volume_position, Bid, m_slippage, 0,tp, NULL, m_magic, 0, Red);
                                    if(last_ticket >0){
                                        last_open_price = Bid;
                                        last_tp_price = tp;
                                        SetTP(tp, position_type);
                                        position_biggest++;
                                    }                                
                                }
                                if(InpTPModeCheck == 1){
                                    double tp = 0.0;             
                                    if(tp_ad){
                                        tp = CalculateTP(m5_zz_a_price, m5_abcd_array[0]);                                   
                                    }else{
                                        tp = CalculateTP(m5_zz_c_price, m5_abcd_array[0]);                                        
                                    }           
                                    int last_ticket = OrderSend(Symbol(), OP_SELL, volume_position, Bid, m_slippage, 0,0, NULL, m_magic, 0, Red);
                                    if(last_ticket > 0){
                                        last_open_price = Bid;
                                        last_tp_price = tp;
                                        position_biggest++;
                                    }
                                }
                            }    
                        }                    
                    }
                    //Lấy ra dinh cao nhất ZZ M5  
                    if(m5_abcd_array[1] > m5_zz_d_price_for_tp){
                        m5_zz_d_price_for_tp = m5_abcd_array[1];
                        m5_zz_d_time_for_tp = m5_time_array[1];
                        //--- 
                    }                   
                }        
            }
            //---        
        } 
    }   
    //--- Update TP - Close Position when Bid go TP
    if(positions_total == 1 || positions_total == 2 || positions_total == 3 || positions_total == 4 || positions_total == 5
        ||positions_total == 6 || positions_total == 7 || positions_total == 8 || positions_total == 9 || positions_total == 10
        ||positions_total == 11 || positions_total == 12 || positions_total == 13 || positions_total == 14 || positions_total == 15
        ||positions_total == 16 || positions_total == 17 || positions_total == 18 || positions_total == 19 || positions_total == 20) {
        if(InpTPModeCheck == 0){
            UpdateTP(last_tp_price, position_type);
        }
        if(InpTPModeCheck == 1){
            //---Buy
            if(position_type == 0){
                double tp_new = 0.0; 
                if(tp_ad){
                    tp_new = CalculateTP(m5_zz_a_price, m5_zz_d_price_for_tp);                                   
                }else{
                    tp_new = CalculateTP(m5_zz_c_price, m5_zz_d_price_for_tp);                    
                } 
                //Comment("New TP = " + DoubleToString(tp_new));
                if(m5_abcd_array[2] < m5_abcd_array[1]){                                    
                    if( Bid >= tp_new){                         
                        CloseAllPositions(position_type);
                    }
                    if(Bid <= tp_new + InpTPDistance *_Point && Bid >= tp_new - InpTPDistance *_Point){
                        CloseAllPositions(position_type);
                    }                    
                }
            }
            //---Sell
            if(position_type == 1){
                double tp_new = 0.0; 
                if(tp_ad){
                    tp_new = CalculateTP(m5_zz_a_price, m5_zz_d_price_for_tp);                                   
                }else{
                    tp_new = CalculateTP(m5_zz_c_price, m5_zz_d_price_for_tp);                    
                }       
                //Comment("TP = " + DoubleToString(tp_new));   
                if(m5_abcd_array[2] > m5_abcd_array[1]){                    
                    if(Bid <= tp_new){
                        CloseAllPositions(position_type);
                    }
                    if(Bid <= tp_new + InpTPDistance *_Point && Bid >= tp_new - InpTPDistance *_Point){                       
                        CloseAllPositions(position_type);
                    }
                }
            }
            if(tp_ad){                
                DrawM5FiboTP(m5_zz_a_price, m5_zz_d_price_for_tp, m5_zz_a_time, m5_zz_d_time_for_tp);                                     
            }else{            
                DrawM5FiboTP(m5_zz_c_price, m5_zz_d_price_for_tp, m5_zz_c_time, m5_zz_d_time_for_tp); 
            } 
        }
    }  
    //---Update SL
    if(positions_total == ArraySize(coefficient_volumes_array) + 1){
        double sl = 0.0;
        if(position_type == 0){
            sl = last_open_price - InpStopLoss *10 * _Point;   
        }
        if(position_type == 1){
            sl = last_open_price + InpStopLoss *10 * _Point;
        }
        UpdateSL(sl);
    }  
    //---Check Balance Stop
    if(CheckBalanceStop()){
        Print("Balance Stop");
        CloseAllPositions(position_type);        
    }
         
    //Comment(messege_log);
    
   
}

//+------------------------------------------------------------------+
//| Check Balance Stop                                               |
//+------------------------------------------------------------------+
bool CheckBalanceStop(){       
    double profit = 0.0;
    for(int i= OrdersTotal()-1;i>=0;i--){
        if (OrderSelect(i,SELECT_BY_POS)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == m_magic){
                profit += OrderProfit();                
            }
        }               
    }
    double balance = AccountBalance();
    //Comment("Profit = " + DoubleToString(profit) + "\nBalance = " + DoubleToString(balance));
    if(profit < 0){
        double curren_profit_percent = MathAbs(profit / balance) * 100;
        if(curren_profit_percent > InpBalanceStopLoss){
            Print("\nProfit = ", DoubleToString(profit)," - Blance = ", DoubleToString(balance)," - Profit percent = ", DoubleToString(curren_profit_percent) , "\n Close All Position!!!\n");    
            return true;           
        }
    }else{
        return false;
    } 
    return false;
}

//+------------------------------------------------------------------+
//| Update TP                                                        |
//+------------------------------------------------------------------+
void UpdateTP(double last_tp, int pos_type) {
    // Check gia hien tai co pha dinh/day D
    //calculate TP theo C vaf bid/ask hien tai
    //Print("Update TP");
    double new_tp = last_tp;    
    if(pos_type==0) {
        if(m5_zz_d_price > Ask ){          
            new_tp = CalculateTP(m5_zz_c_price,Ask);
        }
    }
    
    if(pos_type==1) {
        if(m5_zz_d_price < Bid){
            new_tp = CalculateTP(m5_zz_c_price, Bid);
        }
    }    
    SetTP(new_tp,pos_type);
}
//+------------------------------------------------------------------+
//| Set TP                                                           |
//+------------------------------------------------------------------+
void SetTP(double lastest_pos_tp, int pos_type) {  
    //Print("\nSet TP");
    for(int i = OrdersTotal() - 1; i >= 0; i--){ 
        if (OrderSelect(i,SELECT_BY_POS)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == m_magic){
                double currentSL = OrderStopLoss();                     
                double currentTP = OrderTakeProfit();
                //Print("currentTP= ",currentTP);
                //Print("last TP= ", lastest_pos_tp);
                if(currentTP != lastest_pos_tp) {
                    if(pos_type == 0){
                        if(lastest_pos_tp < currentTP){
                            if(OrderModify(OrderTicket(), OrderOpenPrice(),currentSL, lastest_pos_tp,0,Blue)){
                                last_tp_price = lastest_pos_tp;    
                            }                            
                        }
                    }
                    if(pos_type == 1){
                        if(lastest_pos_tp > currentTP){
                            if(OrderModify(OrderTicket(), OrderOpenPrice(),currentSL, lastest_pos_tp,0,Blue)){
                                last_tp_price = lastest_pos_tp;      
                            }
                        }
                    }            
                }
            }
        }
    }             
}
//+------------------------------------------------------------------+
//| Update SL                                                        |
//+------------------------------------------------------------------+
void UpdateSL(double lastest_pos_sl) {
    Print("Update SL");
    for(int i = OrdersTotal() - 1; i >= 0; i--){ 
        if (OrderSelect(i,SELECT_BY_POS)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == m_magic){                              
                double currentSL = OrderStopLoss();                     
                double currentTP = OrderTakeProfit();
                if(currentSL != lastest_pos_sl) {
                    if(OrderModify(OrderTicket(), OrderOpenPrice(),lastest_pos_sl, currentTP,0,Red)){
                        Print("Update SL All Position");
                    }                                         
                }
            }
        }
    }             
    
}
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions(int pos_type) {
    for (int i = OrdersTotal() - 1; i >= 0; i--){ 
        if (OrderSelect(i,SELECT_BY_POS)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == m_magic){
                if(pos_type == 0){
                    if(OrderClose(OrderTicket(),OrderLots(),Ask,m_slippage,Red)){
                        Print("Close All Position");
                    }
                }
                if(pos_type == 1){
                    if(OrderClose(OrderTicket(),OrderLots(),Bid,m_slippage,Red)){
                        Print("Close All Position");
                    }
                }
            }
        }
    }              
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSignal() {
    
    if(m5_abcd_array[4] > m5_abcd_array[3] && m5_abcd_array[4] > m5_abcd_array[2] && m5_abcd_array[4] > m5_abcd_array[1]) {
        if(m5_abcd_array[3] < m5_abcd_array[2]  && m5_abcd_array[3] > m5_abcd_array[1]) {
            if(m5_abcd_array[2] > m5_abcd_array[1]) {
                if(CalculateM5RangeCD() >= InpM5RangeCD){   
                    if(CheckM5FiboForBuy()) {
                        if(m1_cd_array[2] < m1_cd_array[1]) {
                            if(CheckTPConditionForBuy()) {
                                double price_at_fibo_middle = GetM5PriceAtFiboPercent(m5_abcd_array[4],m5_abcd_array[3],InpM5FiboBuyPercentMiddle);
                                if(m5_abcd_array[2] < price_at_fibo_middle){
                                    tp_ad = true;
                                }else{
                                    tp_ad = false;
                                }              
                                return "BUY"; 
                            }
                        }
                    }
                }
            }
        }
    }
    
    if(m5_abcd_array[4] < m5_abcd_array[3]  && m5_abcd_array[4] < m5_abcd_array[2] && m5_abcd_array[4] < m5_abcd_array[1]) {
        if(m5_abcd_array[3] > m5_abcd_array[2]  && m5_abcd_array[3] < m5_abcd_array[1]) {
            if(m5_abcd_array[2] < m5_abcd_array[1]) {
                if(CalculateM5RangeCD() >= InpM5RangeCD){
                    if(CheckM5FiboForSell()) {
                        if(m1_cd_array[2] > m1_cd_array[1]) {
                            if(CheckTPConditionForSell()) {
                                double price_at_fibo_middle = GetM5PriceAtFiboPercent(m5_abcd_array[4],m5_abcd_array[3],InpM5FiboBuyPercentMiddle);
                                if(m5_abcd_array[2] > price_at_fibo_middle){
                                    tp_ad = true;
                                }else{
                                    tp_ad = false;
                                }              
                                return "SELL";
                            }
                        }
                    }
                }
            }
        }
    }
    
    return "NO-TRADE";
}

//+------------------------------------------------------------------+
//|   Calculate M5 Range CD                                          |
//+------------------------------------------------------------------+
double CalculateM5RangeCD(){
   double rangeCD = -1;
   
   if(_Digits == 3){
      rangeCD = MathAbs(m5_abcd_array[2] - m5_abcd_array[1]) * 100;
   }   
   if(_Digits == 5){
      rangeCD = MathAbs(m5_abcd_array[2] - m5_abcd_array[1]) * 10000;
   }
   return rangeCD;
}
//+------------------------------------------------------------------+
//|   Get M5 Price At Fibo Percent                                   |
//+------------------------------------------------------------------+
double GetM5PriceAtFiboPercent(double price_at_x, double price_at_y, double percent_value_check){
    
    double price_at_percent = 0.0;
    
    double range_xy = MathAbs(price_at_x - price_at_y);
   
    if(price_at_x > price_at_y){
        price_at_percent = price_at_y + (percent_value_check/100) * range_xy;      
    }else if(price_at_x < price_at_y) {
        price_at_percent = price_at_y - (percent_value_check/100) * range_xy;
    }
    return price_at_percent;
}
//+------------------------------------------------------------------+
//|  Check M5 Fibo                                                                |
//+------------------------------------------------------------------+
bool CheckM5FiboForBuy(){
   double price_small = GetM5PriceAtFiboPercent(m5_abcd_array[4], m5_abcd_array[3], InpM5FiboBuyPercentSmall);
   double price_big = GetM5PriceAtFiboPercent(m5_abcd_array[4], m5_abcd_array[3], InpM5FiboBuyPercentBig);

   if(m5_abcd_array[2] > price_small && m5_abcd_array[2]  < price_big){
      return (true);
   }else{
      return (false);
   }
}

bool CheckM5FiboForSell(){
   double price_small = GetM5PriceAtFiboPercent(m5_abcd_array[4], m5_abcd_array[3], InpM5FiboSellPercentSmall);
   double price_big = GetM5PriceAtFiboPercent(m5_abcd_array[4], m5_abcd_array[3], InpM5FiboSellPercentBig);
   if(m5_abcd_array[2] < price_small && m5_abcd_array[2] >  price_big){
      return (true);
   }else{
      return (false);
   }
   return (false);
}
//+------------------------------------------------------------------+
//| Check TP condition                                               |
//+------------------------------------------------------------------+
bool CheckTPConditionForBuy() {
    //double f236 = GetM5PriceAtFiboPercent(m5_abcd_array[1], m5_abcd_array[0], InpM5FiboSellPercentSmall);
    double f236 = GetM5PriceAtFiboPercent(m5_abcd_array[2], m5_abcd_array[1], InpTPFiboLevel1);
    if(f236 - Ask >= InpTPF236Distance *10*_Point) {
        return true;
    }
    return false;
}

bool CheckTPConditionForSell() {    
    double f236 = GetM5PriceAtFiboPercent(m5_abcd_array[2], m5_abcd_array[1], InpTPFiboLevel1);
    if(Bid - f236 >= InpTPF236Distance *10*_Point) {
        return true;
    }
    return false;
}
//+------------------------------------------------------------------+
//| Calculate TP                                                                  |
//+------------------------------------------------------------------+
double CalculateTP(double price_at_x, double price_at_y){
    double tp = 0.0;
    if(OrdersTotal() <= InpTPLevelChange){
        tp = GetM5PriceAtFiboPercent(price_at_x, price_at_y, InpTPFiboLevel1);
    }else{
        tp = GetM5PriceAtFiboPercent(price_at_x, price_at_y, InpTPFiboLevel2);
    }
    return tp; 
}

//+------------------------------------------------------------------+
//|  Volume Array                                                    |
//+------------------------------------------------------------------+
/*void InitVolumesArray() {
    string sep=",";                // A separator as a character 
    ushort u_sep;                  // The code of the separator character 
    u_sep=StringGetCharacter(sep,0); 
    //--- Split the string to substrings 
    int k=StringSplit(InpVolumeString,u_sep,volumes_array); 
}*/

//+------------------------------------------------------------------+
//|  Coefficient Volumes Array update v3                                      |
//+------------------------------------------------------------------+
void InitCoefficientVolumesArray() {
    string sep=",";                // A separator as a character 
    ushort u_sep;                  // The code of the separator character 
    u_sep=StringGetCharacter(sep,0); 
    //--- Split the string to substrings 
    int k=StringSplit(InpCoefficientString,u_sep,coefficient_volumes_array); 
}

//+------------------------------------------------------------------+
//|  Last Distance String                                            |
//+------------------------------------------------------------------+
void InitLastDistanceArray() {
    string sep=",";                // A separator as a character 
    ushort u_sep;                  // The code of the separator character 
    u_sep=StringGetCharacter(sep,0); 
    //--- Split the string to substrings 
    int k=StringSplit(InpLastDistanceString,u_sep,last_distance_array); 
}
//+------------------------------------------------------------------+
//|   Get Value Indicator                                                               |
//+------------------------------------------------------------------+
void GetM5ZZHighLowArray(){
    int j=0;    
    //-----------------------------------------  
    int PointShift1 = 0;
    string ConfirmedPoint1 = "Not Found";
    string PointShiftDirection = "None";
    
    while (ConfirmedPoint1 != "Found"){
        double ZZ = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift1);
        if(iHigh(Symbol(), InpM5ZigZagTimeFrame, PointShift1) == ZZ || iLow(NULL, InpM5ZigZagTimeFrame, PointShift1) == ZZ){
            ConfirmedPoint1 = "Found";
            if(iHigh(Symbol(), InpM5ZigZagTimeFrame, PointShift1) == ZZ){
                PointShiftDirection = "High";
                break;
            }
            if(iLow(Symbol(), InpM5ZigZagTimeFrame, PointShift1) == ZZ){
                PointShiftDirection = "Low";
                break;
            }
        }        
        PointShift1++;   
    }   
    while(iHigh(Symbol(), InpM5ZigZagTimeFrame,j) != iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift1) && 
          iLow(Symbol(), InpM5ZigZagTimeFrame,j) != iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift1)){
        j++;
    }            
    m5_time_array[1] = iTime(Symbol(), InpM5ZigZagTimeFrame,j);  
     
    //-----------------------------------------  
    int PointShift2 = PointShift1;
    string ConfirmedPoint2 = "Not Found";
    
    while (ConfirmedPoint2 != "Found"){
        double ZZ2 = iCustom(Symbol(),InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift2);
        if(iHigh(Symbol(), InpM5ZigZagTimeFrame, PointShift2) == ZZ2 && PointShiftDirection == "Low"){
          ConfirmedPoint2 = "Found";
          break;
        }
        if(iLow(Symbol(), InpM5ZigZagTimeFrame, PointShift2) == ZZ2 && PointShiftDirection == "High"){
          ConfirmedPoint2 = "Found";
          break;
        }          
        PointShift2++;                  
    } 
             
    //------------------------------------------   
    int PointShift3 = PointShift2;
    string ConfirmedPoint3 = "Not Found";

    while (ConfirmedPoint3 != "Found"){
    double ZZ3 = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift3);
        if(iHigh(Symbol(), InpM5ZigZagTimeFrame, PointShift3) == ZZ3 && PointShiftDirection == "High"){
          ConfirmedPoint3 = "Found";
          break;
        }
        if(iLow(Symbol(), InpM5ZigZagTimeFrame, PointShift3) == ZZ3 && PointShiftDirection == "Low"){
          ConfirmedPoint3 = "Found";
          break;
        }          
        PointShift3++; 
    }     
  
    //------------------------------------------   
    int PointShift4 = PointShift3;
    string ConfirmedPoint4 = "Not Found";
    
    while (ConfirmedPoint4 != "Found") {
        double ZZ4 = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift4);
        if(iHigh(Symbol(), InpM5ZigZagTimeFrame, PointShift4) == ZZ4 && PointShiftDirection == "Low"){
            ConfirmedPoint4 = "Found";
            break;
        }
        if(iLow(Symbol(), InpM5ZigZagTimeFrame, PointShift4) == ZZ4 && PointShiftDirection == "High"){
            ConfirmedPoint4 = "Found";
            break;
        }
        
        PointShift4++;  
    } 
                                      
    //-----------------------------------------        
    m5_abcd_array[1]  = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift1);
    m5_abcd_array[2]  = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift2);
    m5_abcd_array[3]  = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift3);
    m5_abcd_array[4]  = iCustom(Symbol(), InpM5ZigZagTimeFrame, "ZigZag", InpM5ZigZagDepth, InpM5ZigZagDeviation, InpM5ZigZagBackStep, 0, PointShift4);
    //TimeZ[1] = iTime(NULL, InpM5ZigZagTimeFrame,PointShift1); 
    m5_time_array[2] = iTime(Symbol(), InpM5ZigZagTimeFrame,PointShift2);
    m5_time_array[3] = iTime(Symbol(), InpM5ZigZagTimeFrame,PointShift3);
    m5_time_array[4] = iTime(Symbol(), InpM5ZigZagTimeFrame,PointShift4);    
    //-----------------------------------------
}


void GetM1CDArray(){     
    //-----------------------------------------  
    int shift_m1_zz_1 = 0;
    string ConfirmedPoint1 = "Not Found";
    string PointShiftDirection = "None";
    
    while (ConfirmedPoint1 != "Found"){
        double ZZ = iCustom(Symbol(), PERIOD_M1, "ZigZag", InpM1ZigZagDepth, InpM1ZigZagDeviation, InpM1ZigZagBackStep, 0, shift_m1_zz_1);
        if(iHigh(Symbol(), PERIOD_M1, shift_m1_zz_1) == ZZ || iLow(NULL, PERIOD_M1, shift_m1_zz_1) == ZZ){
            ConfirmedPoint1 = "Found";
            if(iHigh(Symbol(), PERIOD_M1, shift_m1_zz_1) == ZZ){
                PointShiftDirection = "High";
                break;
            }
            if(iLow(Symbol(), PERIOD_M1, shift_m1_zz_1) == ZZ){
                PointShiftDirection = "Low";
                break;
            }
        }        
        shift_m1_zz_1++;   
    }
    int j=0;     
    while(iHigh(Symbol(), PERIOD_M1,j) != iCustom(Symbol(), PERIOD_M1, "ZigZag", InpM1ZigZagDepth, InpM1ZigZagDeviation, InpM1ZigZagBackStep, 0, shift_m1_zz_1) && 
          iLow(Symbol(), PERIOD_M1,j) != iCustom(Symbol(), PERIOD_M1, "ZigZag", InpM1ZigZagDepth, InpM1ZigZagDeviation, InpM1ZigZagBackStep, 0, shift_m1_zz_1)){
        j++;
    }            
    m1_time_array[1] = iTime(Symbol(), PERIOD_M1,j);  
     
    //-----------------------------------------  
    int shift_m1_zz_2 = shift_m1_zz_1;
    string ConfirmedPoint2 = "Not Found";
    
    while (ConfirmedPoint2 != "Found"){
        double ZZ2 = iCustom(Symbol(),PERIOD_M1, "ZigZag", InpM1ZigZagDepth, InpM1ZigZagDeviation, InpM1ZigZagBackStep, 0, shift_m1_zz_2);
        if(iHigh(Symbol(), PERIOD_M1, shift_m1_zz_2) == ZZ2 && PointShiftDirection == "Low"){
          ConfirmedPoint2 = "Found";
          break;
        }
        if(iLow(Symbol(), PERIOD_M1, shift_m1_zz_2) == ZZ2 && PointShiftDirection == "High"){
          ConfirmedPoint2 = "Found";
          break;
        } 
        shift_m1_zz_2++;                  
    } 
    //-----------------------------------------        
    m1_cd_array[1]  = iCustom(Symbol(), PERIOD_M1, "ZigZag", InpM1ZigZagDepth, InpM1ZigZagDeviation, InpM1ZigZagBackStep, 0, shift_m1_zz_1);
    m1_cd_array[2]  = iCustom(Symbol(), PERIOD_M1, "ZigZag", InpM1ZigZagDepth, InpM1ZigZagDeviation, InpM1ZigZagBackStep, 0, shift_m1_zz_2);    
    
    m1_time_array[2] = iTime(Symbol(), PERIOD_M1,shift_m1_zz_2);
}
//+------------------------------------------------------------------+
//| Draw                                                             |
//+------------------------------------------------------------------+
void DrawM5ZZABCD(){
    //---
    ObjectDelete(0, "M5LineAB");
    if(!ObjectCreate("M5LineAB" , OBJ_TREND, 0, m5_zz_a_time, m5_zz_a_price,m5_zz_b_time, m5_zz_b_price)){
        return;
    }
    ObjectSet("M5LineAB" , OBJPROP_RAY, false);
    ObjectSet("M5LineAB" , OBJPROP_BACK, false);   
    ObjectSet("M5LineAB" , OBJPROP_COLOR, InpM5ZigZagABCDColor);
    ObjectSet("M5LineAB" , OBJPROP_WIDTH, InpM5ZigZagABCDWidth);
    ObjectSet("M5LineAB" , OBJPROP_STYLE, STYLE_DOT);
    
    ObjectDelete(0, "M5LineBC");
    if(!ObjectCreate("M5LineBC" , OBJ_TREND, 0, m5_zz_b_time, m5_zz_b_price, m5_zz_c_time, m5_zz_c_price)){
        return;
    }
    ObjectSet("M5LineBC" , OBJPROP_RAY, false);
    ObjectSet("M5LineBC" , OBJPROP_BACK, false);  
    ObjectSet("M5LineBC" , OBJPROP_COLOR, InpM5ZigZagABCDColor);
    ObjectSet("M5LineBC" , OBJPROP_WIDTH, InpM5ZigZagABCDWidth);
    ObjectSet("M5LineBC" , OBJPROP_STYLE, STYLE_DOT); 
    
    ObjectDelete(0, "M5LineCD");
    if(!ObjectCreate("M5LineCD" , OBJ_TREND, 0, m5_zz_c_time, m5_zz_c_price, m5_zz_d_time, m5_zz_d_price)){
        return;
    }
    ObjectSet("M5LineCD" , OBJPROP_RAY, false);
    ObjectSet("M5LineCD" , OBJPROP_BACK, false);  
    ObjectSet("M5LineCD" , OBJPROP_COLOR, InpM5ZigZagABCDColor);
    ObjectSet("M5LineCD" , OBJPROP_WIDTH, InpM5ZigZagABCDWidth);
    ObjectSet("M5LineCD" , OBJPROP_STYLE, STYLE_DOT);  
   
        
    //-----------------------------                  	  
    ObjectDelete("M5A");
    ObjectCreate("M5A",OBJ_TEXT,0,m5_time_array[4],m5_abcd_array[4]);
    ObjectSetText("M5A","M5A",10,"Arial",InpM5ZigZagABCDColor);
         	  
    ObjectDelete("M5B");
    ObjectCreate("M5B",OBJ_TEXT,0,m5_time_array[3],m5_abcd_array[3]);
    ObjectSetText("M5B","M5B",10,"Arial",InpM5ZigZagABCDColor);	 
            	  
    ObjectDelete("M5C");
    ObjectCreate("M5C",OBJ_TEXT,0,m5_time_array[2],m5_abcd_array[2]);
    ObjectSetText("M5C","M5C",10,"Arial",InpM5ZigZagABCDColor);
             	  
    ObjectDelete("M5D");
    ObjectCreate("M5D",OBJ_TEXT,0,m5_time_array[1],m5_abcd_array[1]);
    ObjectSetText("M5D","M5D",10,"Arial",InpM5ZigZagABCDColor);  	   
	 
}

void DrawM1ZZCD(){
    //---
    ObjectDelete(0, "LineCD");
    if(!ObjectCreate(0, "LineCD", OBJ_TREND, 0,  m1_time_array[2], m1_cd_array[2], m1_time_array[1], m1_cd_array[1]))
      return;
    ObjectCreate("LineCD"  , OBJ_TREND, 0, m1_time_array[2], m1_cd_array[2], m1_time_array[1], m1_cd_array[1]); 
    ObjectSet   ("LineCD"  , OBJPROP_TIME1, m1_time_array[2]);
    ObjectSet   ("LineCD" , OBJPROP_PRICE1, m1_cd_array[2]);	
    ObjectSet   ("LineCD" , OBJPROP_TIME2, m1_time_array[1]);
    ObjectSet   ("LineCD" , OBJPROP_PRICE2, m1_cd_array[1]); 
    ObjectSet   ("LineCD" , OBJPROP_COLOR, InpM1ZigZagCDColor);
    ObjectSet   ("LineCD" , OBJPROP_WIDTH, InpM1ZigZagCDWidth);
    ObjectSet   ("LineCD" , OBJPROP_STYLE, STYLE_DASH);
    ObjectSet   ("LineCD" , OBJPROP_RAY, false);
    ObjectSet   ("LineCD" , OBJPROP_BACK, false);  
    
    //-----------------------------                  	  
                	  
    ObjectDelete("C");
    ObjectCreate("C",OBJ_TEXT,0,m1_time_array[2],m1_cd_array[2]);
    ObjectSetText("C","C",10,"Arial",InpM1ZigZagCDColor);
             	  
    ObjectDelete("D");
    ObjectCreate("D",OBJ_TEXT,0,m1_time_array[1],m1_cd_array[1]);
    ObjectSetText("D","D",10,"Arial",InpM1ZigZagCDColor);   
}

void DrawM5FiboBuySell(double A, double B, datetime TimeA, datetime TimeB, double fibo_percent_small, double fibo_percent_middle, double fibo_percent_big, color ColorFibo){
    ObjectDelete(0, "FIBOBUYORSELL");
    if(!ObjectCreate(0, "FIBOBUYORSELL", OBJ_FIBO, 0, TimeA, A, TimeB, B))
      return;
    ObjectSetInteger(0, "FIBOBUYORSELL", OBJPROP_LEVELCOLOR, ColorFibo);
    ObjectSetInteger(0, "FIBOBUYORSELL", OBJPROP_LEVELSTYLE, STYLE_SOLID);
    ObjectSetInteger(0, "FIBOBUYORSELL", OBJPROP_RAY_LEFT, true);
    ObjectSetInteger(0, "FIBOBUYORSELL", OBJPROP_LEVELS, 5);
    ObjectSetDouble(0,  "FIBOBUYORSELL", OBJPROP_LEVELVALUE, 0, 0.000);
    ObjectSetDouble(0,  "FIBOBUYORSELL", OBJPROP_LEVELVALUE, 1, fibo_percent_small/100);
    ObjectSetDouble(0,  "FIBOBUYORSELL", OBJPROP_LEVELVALUE, 2, fibo_percent_middle/100);
    ObjectSetDouble(0,  "FIBOBUYORSELL", OBJPROP_LEVELVALUE, 3, fibo_percent_big/100);
    ObjectSetDouble(0,  "FIBOBUYORSELL", OBJPROP_LEVELVALUE, 4, 1.000);
    ObjectSetString(0,  "FIBOBUYORSELL", OBJPROP_LEVELTEXT, 0, "0.0% (%$)");
    ObjectSetString(0,  "FIBOBUYORSELL", OBJPROP_LEVELTEXT, 1, DoubleToString(fibo_percent_small,1)+"% (%$)");
    ObjectSetString(0,  "FIBOBUYORSELL", OBJPROP_LEVELTEXT, 2, DoubleToString(fibo_percent_middle,1)+"% (%$)");
    ObjectSetString(0,  "FIBOBUYORSELL", OBJPROP_LEVELTEXT, 3, DoubleToString(fibo_percent_big,1) +"% (%$)");
    ObjectSetString(0,  "FIBOBUYORSELL", OBJPROP_LEVELTEXT, 4, "100.0% (%$)");
}

void DrawM5FiboTP(double A, double B, datetime TimeA, datetime TimeB){
   ObjectDelete(0, "FIBOTP");
   if(!ObjectCreate(0, "FIBOTP", OBJ_FIBO, 0, TimeA, A, TimeB, B))
      return;
   ObjectSetInteger(0, "FIBOTP", OBJPROP_LEVELCOLOR, InpTPColor);
   ObjectSetInteger(0, "FIBOTP", OBJPROP_LEVELSTYLE, STYLE_SOLID);
   ObjectSetInteger(0, "FIBOTP", OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, "FIBOTP", OBJPROP_LEVELS, 4);
   ObjectSetDouble(0,  "FIBOTP", OBJPROP_LEVELVALUE, 0, 0.000);
   ObjectSetDouble(0,  "FIBOTP", OBJPROP_LEVELVALUE, 1, InpTPFiboLevel1/100);
   ObjectSetDouble(0,  "FIBOTP", OBJPROP_LEVELVALUE, 2, InpTPFiboLevel2/100);
   ObjectSetDouble(0,  "FIBOTP", OBJPROP_LEVELVALUE, 3, 1.000);
   ObjectSetString(0,  "FIBOTP", OBJPROP_LEVELTEXT, 0, "0.0% (%$)");
   ObjectSetString(0,  "FIBOTP", OBJPROP_LEVELTEXT, 1, DoubleToString(InpTPFiboLevel1,1)+"% (%$)");
   ObjectSetString(0,  "FIBOTP", OBJPROP_LEVELTEXT, 2, DoubleToString(InpTPFiboLevel2,1) +"% (%$)");
   ObjectSetString(0,  "FIBOTP", OBJPROP_LEVELTEXT, 3, "100.0% (%$)");
}

void DrawM5ZZABCDDefault(){
    //---
    ObjectDelete(0, "M5LineABDefault");
    if(!ObjectCreate("M5LineABDefault" , OBJ_TREND, 0, m5_time_array[4], m5_abcd_array[4],m5_time_array[3], m5_abcd_array[3])){
        return;
    }
    ObjectSet("M5LineABDefault" , OBJPROP_RAY, false);
    ObjectSet("M5LineABDefault" , OBJPROP_BACK, false);   
    ObjectSet("M5LineABDefault" , OBJPROP_COLOR, clrRed);
    ObjectSet("M5LineABDefault" , OBJPROP_WIDTH, 1);
    ObjectSet("M5LineABDefault" , OBJPROP_STYLE, STYLE_DOT);
    
    ObjectDelete(0, "M5LineBCDefault");
    if(!ObjectCreate("M5LineBCDefault" , OBJ_TREND, 0, m5_time_array[3], m5_abcd_array[3], m5_time_array[2], m5_abcd_array[2])){
        return;
    }
    ObjectSet("M5LineBCDefault" , OBJPROP_RAY, false);
    ObjectSet("M5LineBCDefault" , OBJPROP_BACK, false);  
    ObjectSet("M5LineBCDefault" , OBJPROP_COLOR, clrRed);
    ObjectSet("M5LineBCDefault" , OBJPROP_WIDTH, 1);
    ObjectSet("M5LineBCDefault" , OBJPROP_STYLE, STYLE_DOT); 
    
    ObjectDelete(0, "M5LineCDDefault");
    if(!ObjectCreate("M5LineCDDefault" , OBJ_TREND, 0, m5_time_array[2], m5_abcd_array[2], m5_time_array[1], m5_abcd_array[1])){
        return;
    }
    ObjectSet("M5LineCDDefault" , OBJPROP_RAY, false);
    ObjectSet("M5LineCDDefault" , OBJPROP_BACK, false);  
    ObjectSet("M5LineCDDefault" , OBJPROP_COLOR, clrRed);
    ObjectSet("M5LineCDDefault" , OBJPROP_WIDTH, 1);
    ObjectSet("M5LineCDDefault" , OBJPROP_STYLE, STYLE_DOT);  
}

//+-----------------------------------------------------------------------+ 