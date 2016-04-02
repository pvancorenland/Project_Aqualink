//===================//
//===== Devices =====//
//==========================================================================================//
final int DEV_MASTER_MASK     =     0x00; // MASTER(S???0               00-03  0b0 0000 0XX //
final int DEV_CTL_MASK        =     0x08; // HOME CONTROLLER (RS-8?)    08-0b  0b0 0001 0XX //
//                                  0x10; // XXXXX DEVICE               10-13  0b0 0010 0XX //
//                                  0x18; // XXXXX DEVICE               18-1b  0b0 0011 0XX //
final int DEV_SPA_MASK        =     0x20; // SPA DEVICE                 20-23  0b0 0100 0XX //
final int DEV_RPC_MASK        =     0x28; // REMOTE POWER CENTER DEVICE 28-2b  0b0 0101 0XX //
final int DEV_AQUALINK_MASK   =     0x30; // AQUALINK DEVICE            30-33  0b0 0110 0XX //
final int DEV_LX_HTR_MASK     =     0x38; // LX HEATER                  38-3b  0b0 0111 0XX //
final int DEV_ONETOUCH_MASK   =     0x40; // XXXXX ONE TOUCH DEVICE     40-43  0b0 1000 0XX //
//                                  0x48; // XXXXX DEVICE               48-4b  0b0 1001 0XX //
final int DEV_AQUARITE_MASK   =     0x50; // AQUARITE DEVICE            50-53  0b0 1010 0XX //
final int DEV_PCDOCK_MASK     =     0x58; // PCDOCK DEVICE              58-5b  0b0 1011 0XX //
final int DEV_PDA_JDA_MASK    =     0x60; // AQUAPALM DEVICE            60-63  0b0 1100 0XX //
final int DEV_LXI_LRZE_MASK   =     0x68; // LXi/LZRE DEVICE            68-6b  0b0 1101 0XX //
final int DEV_HEATPUMP_MASK   =     0x70; // HEAT PUMP DEVICE           70-73  0b0 1110 0XX //
final int JANDY_EPUMP_MASK    =     0x78; // EPUMP DEVICE               78-7b  0b0 1111 0XX //
final int DEV_CHEMLINK_MASK   =     0x80; // CHEMLINK DEVICE            80-83  0b1 0000 0XX //
//                                  0x88; // XXXXX DEVICE               88-8b  0b1 0001 0XX //
//                                  0x90; // XXXXX DEVICE               90-93  0b1 0010 0XX //
//                                  0x98; // XXXXX DEVICE               98-9b  0b1 0011 0XX //
final int DEV_AQUALINK_2_MASK =     0xA0; // AQUALINK 2                 A0-A3  0b1 0100 0XX //
final int DEV_UNKNOWN_MASK    =     0xF8; // Unknown mask, used to reset values
final int POWERCENTER_PROBE_ALL_DEVICES = 0xFF;
//==========================================================================================//
//==========================================================================================//
//===========//
// CONSTANTS //
//===========//
/*
CMD_COMMAND data is:
 <status> <keypress>
 status is 0 if idle, 1 if display is busy
 keypress is 0, or a keypress code
 CMD_STATUS is sent in response to all probes from DEV_MASTER
 DEV_MASTER continuously sends CMD_COMMAND probes for all devices
 until it discovers a particular device.
 
 CMD_STATUS data is 5 bytes long bitmask
 defined as STAT_* below
 
 CMD_MSG data is <line> followed by <msg>
 <msg> is ASCII message up to 16 chars (or null terminated).
 <line> is NUL if single line message, else
 1 meaning it is first line of multi-line message,
 if so, next two lines come as CMD_MSG_LONG with next byte being
 2 or 3 depending on second or third line of message.
 */
// Protocol:
// 1START/8DATA/NO PARITY/2 STOP @ 19.2kbps
// NUL | DLE | STX | Dest[0]/Command[0]/Args[0-??(61?)] | Checksum | DLE | ETX | NUL | NUL
final int DLEChar  = 0x10;
final int STXChar  = 0x02;
final int ETXChar  = 0x03;
final int NULChar  = 0x00;
final int PUMPChar = 0xA5;
final int FFChar   = 0xFF;
final int checkSumStart        = DLEChar+STXChar;

final int TIMESTAMPMULTIPLIER = 1000;

/* COMMANDS */
final int CMD_PROBE      = 0x00;
final int CMD_ACK        = 0x01;
final int CMD_STATUS     = 0x02;
final int CMD_MSG        = 0x03;
final int CMD_MSG_LONG   = 0x04;

final int DEBUG_OFF                            = 0x00;
final int DEBUG_ON                             = 0x01;
final int DEBUG_DETAILS                        = 0x02;
final int DEBUG_WRITEDEBUG2LOG                 = 0x04;
final int DEBUG_CHANGEREADOUTSTATUS            = 0x08;
final int DEBUG_RECEIVELINE                    = 0x10;
final int DEBUG_SHOWPROCESSINCOMING            = 0x20;
final int DEBUG_SHOWEMULATORINFO               = 0x40;
final int DEBUG_SHOWEMULATORINFO2              = 0x80;
final int DEBUG_SHOWWHENDATAISDROPPED          = 0x100;
final int DEBUG_SHOWDISPLAYOPTIONINFO          = 0x200;
final int DEBUG_PULSEDRAWWITHZEROS             = 0x400;
final int DEBUG_SHOWTIMESTAMPWITHRAWDATA       = 0x800;
final int DEBUG_ALWAYSPRINTLOGTXTSTRINGNUMBERS = 0x1000;

final int DRAW_INIT_FILES      = 0;
final int DRAW_RUN             = 1;
final int DRAW_FINISH_FILES    = 2;

final int PUMPGPM          = 0x01;
final int PUMPPANELCTL     = 0x04;
final int PUMPSETMODE      = 0x05;
final int PUMPSTART        = 0x06;
final int PUMPSTAT         = 0x07;
final int PUMPMASTER       = 0x10;
final int PUMPDEVICE       = 0x60;
final int PUMPMODEFEATURE1 = 0x06;

final int POWERCENTEREMULATE_STARTUP    = 1;
final int POWERCENTEREMULATE_INIT       = 2;
final int POWERCENTEREMULATE_RUN        = 3;

final String RAWLogFileExtension = "_RAW.txt";
final String valuesFileExtension = "_Values.txt";
final String outputFileExtension = "_Output.txt";

final int RS485INCDATAMASK = 0x000000FF;   // Incoming Data
final int RS485DATAMASK    = 0x000000FF;   // checksum mask

final int LOOKINGFORCTL          = 0;
final int LOOKINGFORSTX          = 1;
final int LOOKINGFORETX          = 2;
final int LOOKINGFORDATA         = 3;
//final int LOOKINGFORENDZERO1     = 4;
//final int LOOKINGFORENDZERO2     = 5;
final int LOOKINGFORPUMPDATACKL  = 10;
final int LOOKINGFORPUMPDATAFF   = 11;
final int LOOKINGFORPUMPDATANUL  = 12;
final int LOOKINGFORPUMPDATASUB  = 13;
final int LOOKINGFORPUMPDATADST  = 14;
final int LOOKINGFORPUMPDATASRC  = 15;
final int LOOKINGFORPUMPDATACMD  = 16;
final int LOOKINGFORPUMPDATALEN  = 17;
final int LOOKINGFORPUMPDATAVAL  = 18;
final int DEFAULTREADOUTSTATUS   = LOOKINGFORCTL;
final int MAXNROFINCOMINGDATAVALUES = 512;

final int LOGTXT_UNPROCESSEDDATA  = 0;
final int LOGTXT_DEST             = 1;
final int LOGTXT_DETAILS          = 2;
final int LOGTXT_TYPE             = 3;
final int LOGTXT_DATA             = 4;
final int LOGTXT_RESP             = 5;
final int LOGTXT_CHECKSUMERROR    = 6;
final int LOGTXT_CHECKSUM         = 7;
final int LOGTXT_OTHERERROR       = 8;
final int LOGTXT_WARNING          = 9;
final int LOGTXT_ERROR            = 10;
final int LOGTXT_INFO             = 11;
final int LOGTXT_DEBUG            = 12;
final int NRLOGTXTTYPES           = 13;
final int LOGTXT_DESTNAMELENGTH   = 14;
final int LOGTXT_DESTLENGTH       = LOGTXT_DESTNAMELENGTH+7;
final int LOGTXT_DETAILSLENGTH    = 10;
final int LOGTXT_TYPELENGTH       = 13;

// Values extracted to log file
final int LOG_ORP_INCLUDE      =  1;
final int LOG_PH_INCLUDE       =  2;
final int LOG_SALTPPM_INCLUDE  =  4;
final int LOG_SALTPCT_INCLUDE  =  8;
final int LOG_PUMPGPM_INCLUDE  = 16;
final int LOG_PUMPRPM_INCLUDE  = 32;
final int LOG_PUMPWATT_INCLUDE = 64;
final int LOG_AIRTEMP_INCLUDE  = 128;
final int LOG_POOLTEMP_INCLUDE = 256;

final String LOG_TIME_NAME     = "TIME";
final String LOG_ORP_NAME      = "ORP ";
final String LOG_PH_NAME       = "PH  ";
final String LOG_SALTPCT_NAME  = "PCT ";
final String LOG_SALTPPM_NAME  = "PPM ";
final String LOG_PUMPGPM_NAME  = "GPM ";
final String LOG_PUMPRPM_NAME  = "RPM ";
final String LOG_PUMPWATT_NAME = "WATT";
final String LOG_AIRTEMP_NAME  = "AIR ";
final String LOG_POOLTEMP_NAME = "POOL";

final String LOG_ORP_UNIT      = "mV";
final String LOG_PH_UNIT       = "";
final String LOG_SALTPPM_UNIT  = "PPM";
final String LOG_SALTPCT_UNIT  = "%";
final String LOG_PUMPGPM_UNIT  = "GPM";
final String LOG_PUMPRPM_UNIT  = "RPM";
final String LOG_PUMPWATT_UNIT = "W";
final String LOG_AIRTEMP_UNIT  = "F";
final String LOG_POOLTEMP_UNIT = "F";

final String logTxtStringTxtCmdResp[] = {"C", "R"};
final int ASCIISPACECHAR    = 0x20;

final int LOG_VAL_SPACES       = 9;

final String LOG_VALUE_SEPARATOR   = ",";
final int LOG_VALUE_COLUMWIDTH     = 6;
final int LOG_VALUE_TIMESTAMPWIDTH = 16;


final int EQUIPMENTDATA = 0;
final int PUMPDATA      = 1;

final String RAWLOGFILEHEADER = "#RAW LOG FILE WITH TIMESTAMP";

final int CTL_EXPECTED_BUTTSTAT_BYTES = 5;
final int SPA_EXPECTED_BUTTSTAT_BYTES = 2;


final int MAXNRPROCESSEDATONCE = 2560;
final int MAXNRDEVICEDISPLAYMASKS = 8;
final int DATABUFFERSIZE = 1280; //61 command/data bytes + 2 checksum bytes + 2 potential 0x0h insertions
final int MAXNREMULATEPOWERCENTERIDS   = 8;
final int MAXNREMULATEIDS              = 8;
final int MAXNREMULATEDEVICEIDS        = 8;
final int ONETOUCHMSGLENGTH            = 16;
final int MAXNROFEMULATORCOMMANDSINQUEUE = 1;
final int MAXNRPUMPCOMMANDDATA = 128;
final int MAXNRDROPPEDPACKETS       = 512;
final int NRUNPROCESSEDDATABUFFERS = 512;
final int MAXNRLOGGEDTXTSTRINGS = 8096;
final int MAXTIMEDELTASIZE    = 7;
final int MAXTXTSTRINGNRSIZE  = 6;
final int PROCESSEDBYTESMINTIME  = 3000; //Update every X milliseconds
final long REFRESHTIMEMICROUPDATE = 10000;
final int LINEBUSYTIMEOUT                  = 100;


final int UNKNOWN_COMMAND = 0xFF;

class displayOptions {
  boolean value;
  String name;
  String description;
  displayOptions(boolean value, String name, String description) {
    this.value = value;
    this.name  = name;
    this.description = description;
  }
}

ArrayList<displayOptions> displayOptionsList = new ArrayList<displayOptions>();

//=========//
// General //
//=========//
String sketch = Thread.currentThread().getStackTrace()[1].getClassName();
int drawMode = DRAW_INIT_FILES;
boolean addSpaceBetweenDevicesOptionSelected;
// Define directory to store the log files
int     debug                        = 0;  // Control debugging info
int verboseDataDebugLevel = 0;

int rawLogFileIncr;
int rawLogFileDataLength;
int rawLogFileNrBytes;
String[] rawLogFileData;
long rawLogFileTimestampDelta ;
int rawLogFileDataVal;
int rawLogFileDataPosition ;
boolean stillProcessingRAWLogFile ;
boolean waitingForReplayDelay ;
long replayDelayEndTime ;
long replayTime0;
long replayTimeD;
int displayToggleButtonState ;
String displayOptionNameList  ;
String deviceDisplayMasksList ;
String powerCenterEmulatorIDsList ;
String debugMasksList ;
long nextRefreshTimeMicro;
int rawIncomingDataNeedsNewline ;

//===============================//
// LOG FILE HANDLES              //
//===============================//
String logFilesPath           = "../logFiles/"; // Base directory where logfiles are stored
PrintWriter    logFileHandle;
PrintWriter    rawLogFileHandle;
PrintWriter    valuesLogFileHandle;
BufferedReader logFileReader;
long           rawLogFileValuesWritten = 0;
long           rawLogFileValuesWrittenMax = 16384;
boolean        newLogFilesNeeded = false;
long           rawLogFileStartTimestamp;
    //SimpleDateFormat rawLogFileDateFormat = new SimpleDateFormat("MM-dd-yyyy_HH:mm:ss");
    //SimpleDateFormat rawLogFileDateFormatLong = new SimpleDateFormat("MM-dd-yyyy_HH:mm:ss.SSS");
    SimpleDateFormat rawLogFileDateFormat = new SimpleDateFormat("MM-dd-yyyy_HH:mm:ss.SSS");
    SimpleDateFormat rawLogFileDateFormatShort = new SimpleDateFormat("MM-dd-yyyy_HH:mm:ss");
Date noDateFound = new Date();

  
//======================================//
// Set up COM port for RS485 connection //
//======================================//
Serial currentOpenPort;
String readComPortName = ""; 
int serialSpeed                    = 9600;
ArrayList<String> blackListPorts = new ArrayList();

//==================//
// Processor arrays //
//==================//
int processDataValues[] = new int[DATABUFFERSIZE];
int processDataValuesCtr = -1;
int incomingDataValues[] = new int[DATABUFFERSIZE];
int incomingDataValuesCtr = -1;
int checkSumDataValues[] = new int[DATABUFFERSIZE];
int checkSumDataValuesCtr = -1;
byte emulatorCommandsInQueue         = -1;
int emulatorDataValuesCtr            = -1;
int emulatorDataValuesCtrCurrent     = -1;
int emulatorDataValues[]             = new int[DATABUFFERSIZE];
int sendDataValues[]                 = new int[DATABUFFERSIZE];
int sendDataValuesCtr                = -1;
int lastDestination = -1;


// Record or read data to/from file
int readOutStatus                ;
int readFileData; 
int replayDelay;
String rawLogFileReadNameBase       = ""; // Read from this file if readFileData==1
ArrayList<String> rawLogFileReadNameBaseList = new ArrayList();
int rawLogFileReadNameBaseNr            = -1;
int rawLogFileReadNameBaseNrOfFiles     = -1;
String useLogFileNameBase               = "";
int rawLogFileHasBeenRead ;
String logFileNameBase;
int rawLogFileHasTimestamp ;
long lastLogTimeStampMicroTime     ;
long currentByteTimeStampMicroTime ;
long initByteTimeStampMicroTime    ;
long logTimeStampMicroDelta;
String rawLogFileReadLine = "";
int destinationID             ;
String lastDestinationName   ;


//=================//
// VALUES LOG FILE //
//=================//
String LOG_ORP_VAL      = "NA";
String LOG_PH_VAL       = "NA";
String LOG_SALTPCT_VAL  = "NA";
String LOG_SALTPPM_VAL  = "NA";
String LOG_PUMPGPM_VAL  = "NA";
String LOG_PUMPRPM_VAL  = "NA";
String LOG_PUMPWATT_VAL = "NA";
String LOG_AIRTEMP_VAL  = "NA";
String LOG_POOLTEMP_VAL = "NA";
boolean LOG_SALT_ENABLED       = false;
boolean LOG_PUMP_ENABLED       = false;
boolean LOG_TEMP_ENABLED       = false;
int reportValuesInLogfile ;
String lastValuesLogString ;
String reportValuesInLogfileList ;
String logValueGroupsEnabled = "";

String WATERTEMP ="" ;
String BOXTEMP = "";

//===========//
// GUI SETUP //
//===========//
ControlP5 guiWin;
controlP5.Label l;
controlP5.Toggle toggles;
controlP5.Textarea infoTextArea;
controlP5.Textarea valuesTextArea;
CallbackListener steppedEmulator;
PFont pfont;
ControlFont guiWinFont ;
int toggleNr = 0;
boolean enableGUI = true;
int fontSize                 = 24;
int toggleButtonYSize        = fontSize + 6;
int toggleButtonXSize        = toggleButtonYSize;
int toggleButtonLabelXOffset = 5;
int toggleButtonYOffset      = 5;
int toggleButtonLabelYOffset = 17 - fontSize;
int xPosToggle               = 10;
int yPosToggle               = toggleButtonYOffset;
int DisplayOptionsCanvasXSize;
int DisplayOptionsCanvasYSize;
int infoCanvasXSize;
int infoCanvasYSize;
int ValuesCanvasXsize;
int ValuesCanvasYsize;
int showDisplayOptions = 1;
int showInfoTextCanvas = 1;
int showPlayButton     = 1;
int showValuesCanvas   = 1;
String enabledCanvasOptions = "Enabled Canvas options    =";

int waitingForNextStepClick ; //Used as a boolean to step through the emulator
boolean dontOverWriteOutputFiles = true;
boolean processSingleRAWFile = true;



//=================//
// Emulate Devices //
//=================//
int emulateID               = 0;

//===============================================//
// Display only the Communications from some IDs //
//===============================================//
int deviceDisplayMasksCtr = 0;
int deviceDisplayMasks[] = new int[MAXNRDEVICEDISPLAYMASKS]; // Only show devices with this address mask


//==========================================//
// Emulate PowerCenter to check for devices //
//==========================================//
int emulatePowerCenterIDsCtr           = 0;
int emulatePowerCenterIDs[]            = new int[MAXNREMULATEPOWERCENTERIDS]; // Only show devices with this address mask
int emulatorInitStage[]                = new int[MAXNREMULATEPOWERCENTERIDS];
int emulatorRunStage[]                 = new int[MAXNREMULATEPOWERCENTERIDS];
int powerCenterEmulateStage[]          = new int[MAXNREMULATEPOWERCENTERIDS];
//final int powerCenterEmulatorTimeout = 75; // Should be a minimum of 32bytes *  1.32ms ~= 45ms 
int powerCenterEmulatorTimeout = 500; // Should be a minimum of 32bytes *  1.32ms ~= 45ms 
long currentEmulatorTime               ;
long newEmulatorActionTime             ;
int powerCenterEmulatorNextNr          ;
int currentPowerCenterIDBeingProbed    ; 
int powerCenterEmulatorIsProbingAll    ;
int emulateDeviceIDsCtr                ;
int emulateDeviceIDs[]                 = new int[MAXNREMULATEPOWERCENTERIDS]; // Only show devices with this address mask
int ONETOUCHEMUMessageLineNr           ;
int ONETOUCHEMUHighlightLineNr         ;


int pumpGPMVal;
int pumpDestination    ;
int pumpSource         ;
int pumpCommand        ;
int pumpCommandLength  ;
int[] pumpCommandData  = new int[MAXNRPUMPCOMMANDDATA];
int pumpCommandDataCtr ;
int pumpCommandCKH     ;
int pumpCommandCKL     ;
int pumpMODEVal        ;
int pumpSTARTVal       ;



int checkSumIn;
String checkSumErrorString;
int checkSumError;
int logRawData                           = 1;
int droppedCtr                           = 0;
int[] droppedPackets                     = new int[MAXNRDROPPEDPACKETS];
long previouslastReceivedByteTimeMicro   = 0;
long lastReceivedByteTimeMicro           = 0;
long[] processedTimeDelta                = new long[2];
long lastShowTimeMicro     = 0;
long currentShowTimeMicro  = 0;
long showTimeMicroDelta    = 0;
long lastMicroTimeStamp    = getAccurateMicroTime();
long currentMicroTimeStamp = getAccurateMicroTime();
long timeStampDelta   = 0;
int lastCommand;
long processedByteCounter;
long processedByteCounterTotal;
long newProcessedByteCounterTime ;
float processedBps;

//======================//
// Output LOG Variables //
//======================//
String[][] logTxtStrings           = new String[NRLOGTXTTYPES][2]; // Holds the different types of logTxt values
int[] logTxtDestinationValue       = new int[2];
int[] unprocessedData           = new int[NRUNPROCESSEDDATABUFFERS]; // Holds Command, Response and potential pump data
int logTxtStringLnCount;

String logTxtString           = "";
String[] loggedTxtStrings     = new String[MAXNRLOGGEDTXTSTRINGS];
int nrLoggedNewTextStrings    ;
int logTxtStringNr            ;
int unprocessedDataBufferNr   ;
int nowDecodingResponse       ;

int sentCommands;
int unansweredCommands;
int receiveLineBusy ;
int lastChemlinkValuesHadExtendedData = 0;
boolean foundExtendedChemlinkData = false;

void initDisplayOptions() {
  displayOptionsList.add( new displayOptions(false, "showUnprocessedData", "Show Unprocessed Data"   ) ); // Show the incoming hex bytes before they are processed
  displayOptionsList.add( new displayOptions(false, "showRawIncomingHexData", "Show Raw Incoming Hex Data" ) ); // Show incoming data (in HEX) as it is being read
  displayOptionsList.add( new displayOptions(false, "showVerboseDataInLog", "Show Verbose Data in Log file" ) ); // Show verbose comments in the log file
  displayOptionsList.add( new displayOptions(false, "suppressChecksumErrors", "Suppress Checksum Errors"   ) ); // Don't complain about Checksum errors
  displayOptionsList.add( new displayOptions(true, "showDroppedData", "Show Dropped Data"   ) ); // Show the dropped data (due to checksum errors, colissions,...)
  displayOptionsList.add( new displayOptions(false, "dontShowZeroACKData", "Don't Show Zero ACK Data" ) ); // Don't show the data values following an ACK if they're all 0
  displayOptionsList.add( new displayOptions(false, "onlyShowNewStrings", "Only Show New Strings"  ) ); // Only show decoded data if it is new
  displayOptionsList.add( new displayOptions(false, "dontShowEmptyProbes", "Don't Show Empty Probes" ) ); // Don't show probes that have not been responded to
  displayOptionsList.add( new displayOptions(true, "showTimeDeltas", "Show Time Deltas"   ) ); // Show time delta since last data
  displayOptionsList.add( new displayOptions(false, "suppressReadoutWarnings", "Suppress Readout Warnings"    ) ); // Suppress warnings about the readout (Dropped packets,...) 
  displayOptionsList.add( new displayOptions(false, "suppressReadoutInfo", "Suppress Readout Info"    ) ); // Suppress info about the readout
  displayOptionsList.add( new displayOptions(false, "suppressReadoutErrors", "Suppress Readout Errors"   ) ); // Suppress errors about the readout (Dropped packets,...)
  displayOptionsList.add( new displayOptions(true, "showCommandResponse", "Show Command Response"   ) ); // Show the response to the MASTER
  displayOptionsList.add( new displayOptions(true, "addSpaceBetweenDevices", "Add Space Between Devices"  ) ); // Add extra line between device outputs
  displayOptionsList.add( new displayOptions(true, "showProcessedBytesStatistics", "Print Processed Bytes Statistics"  ) ); // Show Statistics about the processed bytes
  displayOptionsList.add( new displayOptions(false, "pulseDrawWithZeros", "Pulse Draw With Zeros"  ) ); // Send 0x00 on serial port (if applicable) everytime the draw() loop restarts
  displayOptionsList.add( new displayOptions(false, "addCSValueToLogTxt", "Add CS Value To Log Txt") ); // Show checksum values in logTxt prints
  displayOptionsList.add( new displayOptions(false, "reportDataInDecimal", "Report Data In Decimal"  ) ); // Report values in decimal
  displayOptionsList.add( new displayOptions(true, "printDataToScreen", "Print processed data on the screen"  ) ); // 
  displayOptionsList.add( new displayOptions(true, "useSteppedReplay", "Use Button to step through Replay"  ) ); // 
  displayOptionsList.add( new displayOptions(true, "toggleSteppedReplay", "Keep replaying while button is pressed"  ) ); //
  displayOptionsList.add( new displayOptions(true, "printReplayStatistics", "Show Replay Statistics"  ) ); //
  displayOptionsList.add( new displayOptions(true, "onlyReportNewValuesinLog", "Only log new values to _VALUES file"  ) ); //
  displayOptionsList.add( new displayOptions(true, "useRefreshTime", "Process Bytes for refreshTime us"  ) ); //
}