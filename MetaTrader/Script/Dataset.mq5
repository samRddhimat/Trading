//+------------------------------------------------------------------+
//|                                          DownloadCandleData.mq5   |
//| Downloads historical data for a currency pair and writes to CSV   |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//--- Input parameters

//input string InpSymbol = "XAUUSDm";       // Currency Pair
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_H1; // Timeframe
input datetime InpStartDate = D'2025.01.01'; // Start Date
input datetime InpEndDate = D'2025.07.07';   // End Date
input string InpFileName = "";          // File Name (leave empty for auto-generated)
string pairs[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF","XAUUSD"};
//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
  {
   // Validate inputs
   if(InpStartDate >= InpEndDate)
     {
      Print("Error: Start date must be earlier than end date.");
      return;
     }

for(int i=0; i<ArraySize(pairs); i++)
   {
   
   // Generate file name if not provided
   string fileName = "";
   if(fileName == "")
     {
      string timeframeStr = TimeframeToString(InpTimeframe);
      fileName = pairs[i] + "m_" + timeframeStr + "_" + 
                 TimeToString(InpStartDate, TIME_DATE) + "_" + 
                 TimeToString(InpEndDate, TIME_DATE) + ".csv";
     }
   Print(fileName);
   // Open file for writing
   int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_CSV | FILE_COMMON, ","); 
   //FILE_COMMON writes the file to C:\Users\<UserName>\AppData\Roaming\MetaQuotes\Terminal\Common\Files
   //Excluding it writes it under C:\Users\<UserName>\AppData\Roaming\MetaQuotes\Terminal\..\MQL5\Scripts
   if(fileHandle == INVALID_HANDLE)
     {
      Print("Error: Failed to open file ", fileName, ". Error code: ", GetLastError());
      return;
     }

   // Write CSV header
   FileWrite(fileHandle, "Datetime,Open,Close,High,Low,Volume");

   // Copy historical data
   MqlRates rates[];
   int copied = CopyRates(pairs[i]+"m", InpTimeframe, InpStartDate, InpEndDate, rates);
   if(copied <= 0)
     {
      Print("Error: Failed to copy rates. Error code: ", GetLastError());
      FileClose(fileHandle);
      return;
     }

   // Write data to CSV
   for(int i = 0; i < copied; i++)
     {
      FileWrite(fileHandle, 
                TimeToString(rates[i].time, TIME_DATE|TIME_MINUTES),
                DoubleToString(rates[i].open, _Digits),
                DoubleToString(rates[i].close, _Digits),
                DoubleToString(rates[i].high, _Digits),
                DoubleToString(rates[i].low, _Digits),
                rates[i].tick_volume);
     }

   // Close file
   FileClose(fileHandle);
   Print("Success: Data written to ", fileName, ". ", copied, " bars exported.");
  }
   
}

   
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Convert timeframe to string for file naming                       |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return "Unknown";
     }
     
  }
