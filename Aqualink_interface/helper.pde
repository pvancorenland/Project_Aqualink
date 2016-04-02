void unknownResponse(int deviceID, int command, int response, int startNr, int endNr) {
  String commandDescription = "";
  if ( command == UNKNOWN_COMMAND ) {
    commandDescription = "\"Unknown Command\": ";
  }
  commandDescription += reportVal(command, 2);
  logTxtLn("Unknown "+getDestinationName(deviceID)+" ("+reportVal(deviceID, 2)+") Response: "+reportVal(response, 2)+" to command: "+commandDescription, LOGTXT_WARNING);
  logTxtData(startNr, endNr);
}

void processValidGenericACKResponse(String txt, int command, int startNr, int endNr) {
  logTxt(txt+" ACK", LOGTXT_TYPE);
  verifyACKToCommand(command, startNr, endNr);
}

void processValidGenericACKResponse(int command, int startNr, int endNr) {
  logTxt(reportValx(command, 2)+" ACK", LOGTXT_TYPE);
  verifyACKToCommand(command, startNr, endNr);
}

void verifyACKToCommand(int command, int startNr, int endNr ) {
  if ( processDataValues[startNr] == command ) {
    startNr++;
    if ( processDataValues[startNr] == 0x00 ) {
      startNr++;
    }
  }
  logTxtData(startNr, endNr);
}

void showMemory() {
  if ( !processSingleRAWFile ) {
    // The amount of memory allocated so far (usually the -Xms setting)
    long allocated = Runtime.getRuntime().totalMemory();

    // Free memory out of the amount allocated (value above minus used)
    long free = Runtime.getRuntime().freeMemory();

    // The maximum amount of memory that can eventually be consumed
    // by this application. This is the value set by the Preferences
    // dialog box to increase the memory settings for an application.
    long maximum = Runtime.getRuntime().maxMemory();
    String memStats = "Tot Memory: "+showHumanReadable(allocated) + " / Free Memory: "+showHumanReadable(free) + " / Max Memory: "+showHumanReadable(maximum);
    println(memStats);
    if (!(logFileHandle == null) ) {
      logTxtLn(memStats, LOGTXT_INFO);
    }
  }
}

String showHumanReadable( long iptNr) {
  String opt = "";
  if ( iptNr > 1000 ) {
    iptNr /= 1000;
    opt = "K";
  }
  if ( iptNr > 1000 ) {
    iptNr /= 1000;
    opt = "M";
  }
  if ( iptNr > 1000 ) {
    iptNr /= 1000;
    opt = "G";
  }
  return (str(iptNr)+opt);
}

File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

boolean initLogFiles() {
  // Initialize timing values
  initLogTimes();
//  Date d = new Date();
  Date d = noDateFound;
  //  for ( int i=0; i< 20; i++ ) {
  //    delay(1000);
  //d = Date();
  rawLogFileStartTimestamp = d.getTime();
  //    println(i+" "+rawLogFileStartTimestamp);
  //  }

  // Open Output and VALUES log files
  // Setup the file with the logs
  if ( areWeReadingRawLogFile() ) {
    logFileNameBase = getRawLogFileReadNameBase();
  } else {
    if ( useLogFileNameBase == "" ) {
      //logFileNameBase = "Jandy_log_"+nf(day(), 2)+nf(month(), 2)+year()+nf(hour(), 2)+nf(minute(), 2)+nf(second(), 2); // Record log data to this file
      // logFileNameBase = "Jandy_log_"+nf(day(), 2)+"-"+nf(month(), 2)+"-"+year()+"_"+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2); // Record log data to this file
      logFileNameBase = "Jandy_log_"+rawLogFileDateFormat.format(rawLogFileStartTimestamp); // Record log data to this file
    } else {
      logFileNameBase = useLogFileNameBase;
    }
  }

  if ( logFileNameBase == "" ) {
    println("logFileNameBase is empty, Aborting!");
    return false;
  }
  logFileNameBase = logFilesPath+logFileNameBase;
  // Default output log file//  
  String outputLogFileName = logFileNameBase+outputFileExtension;
  File fOutput = new File(dataPath(outputLogFileName));
  if ( (fOutput.exists())&(dontOverWriteOutputFiles) ) {
    println("Output logFile "+outputLogFileName+" already exists, skipping!");
    return false;
  }
  logFileHandle = createWriter(outputLogFileName);
  logTxtLn("Opened output logFile "+outputLogFileName+" ==> "+logFileHandle+" at: "+d+" = "+rawLogFileStartTimestamp, LOGTXT_INFO);

  // RAW data and timestamp output log //  
  if ( areWeReadingRawLogFile() ) {
    logRawData = 0;
  } 
  // Output Values File //
  String valuesFileName = logFileNameBase+valuesFileExtension;
  File fValues = new File(dataPath(valuesFileName));
  if ( (fValues.exists())&(dontOverWriteOutputFiles) ) {
    println("Output logFile "+valuesFileName+" already exists, skipping!");
    return false;
  }
  valuesLogFileHandle = createWriter(valuesFileName);
  writeValuesToLogFile(1);
  logTxtLn("Opened Values logFile "+valuesFileName+" ==> "+valuesLogFileHandle, LOGTXT_INFO);
  // RAW Data LogFile //
  String RAWLogFileName = logFileNameBase+RAWLogFileExtension;
  if ( logRawData == 1 ) {
    File fRAW = new File(dataPath(RAWLogFileName));
    if ( fRAW.exists() ) {
      println("Output logFile "+RAWLogFileName+" already exists, skipping!");
      return false;
    }
    rawLogFileHandle = createWriter(RAWLogFileName);
    rawLogFileValuesWritten = 0;
    logTxtLn("Opened RAW    logFile "+RAWLogFileName+" ==> "+rawLogFileHandle, LOGTXT_INFO);

    printToRawLogFile(RAWLOGFILEHEADER+" "+rawLogFileStartTimestamp+" "+rawLogFileDateFormat.format(rawLogFileStartTimestamp)+"\n");
  }
  if ( areWeReadingRawLogFile() ) {
    //======================//
    // Open the RAW logfile //
    //======================//
    logFileReader = createReader(RAWLogFileName);
    logTxtLn("Opened RAW    logFile "+RAWLogFileName, LOGTXT_INFO);
    //    String[] dateVals = match(RAWLogFileName, "Jandy_log_(.*?)-(.*?)-(.*?)_(.*?)_RAW.txt");
    //    String dateString = dateVals[1]+"/"+dateVals[2]+"/"+dateVals[3]
    String[] dateVals = match(RAWLogFileName, "Jandy_log_(.*?)_RAW.txt");

    Date df = getDateFromString(dateVals[1]);

    println("FOUND DATE ==>" +dateVals[1]+ " == "+df.getTime()+" == "+df+" ==> "+rawLogFileDateFormat.format(df.getTime()));
  }
  //====================//
  // Print general info //
  //====================//
  printSetupInfo();
  if ( areWeReadingRawLogFile() ) {
    println("\nProcessing file #"+rawLogFileReadNameBaseNr+" ==> "+logFileNameBase);
  }
  return true;
}

Date getDateFromString(String str) {
  Date df = new Date();
  try {
    // rawLogFileDateFormat = new SimpleDateFormat("dd-MM-yyyy_HH:mm:ss");
    df =  rawLogFileDateFormat.parse(str);
  }
  catch (Exception e) {
    //print("EXC: "+e);
    try {
      df =  rawLogFileDateFormatShort.parse(str);
    }
    catch (Exception eS) {
      print("EXC: "+eS);
    }
  }
  return df;
}

void printToRawLogFile( String str ) {
  //print("PRRWLF "+str+"<<");
  rawLogFileHandle.print(str);
  rawLogFileHandle.flush();
  rawLogFileValuesWritten++;
  if ( rawLogFileValuesWritten >= rawLogFileValuesWrittenMax ) {
    newLogFilesNeeded = true;
  }
}

String getRawLogFileReadNameBase() {
  String name = "";
  // rawLogFileReadNameBaseNrOfFiles = rawLogFileReadNameBaseList.size();
  // rawLogFileReadNameBaseNrOfFiles = 3;
  // Get name from the list
  if ( rawLogFileReadNameBaseNr < rawLogFileReadNameBaseList.size() ) {
    name = rawLogFileReadNameBaseList.get(rawLogFileReadNameBaseNr);
    rawLogFileReadNameBaseNr++;
  }
  return name;
}

void printSetupInfo() {
  logTxtLn(displayOptionNameList, LOGTXT_INFO);
  logTxtLn(deviceDisplayMasksList, LOGTXT_INFO);
  logTxtLn(powerCenterEmulatorIDsList, LOGTXT_INFO);
  logTxtLn(debugMasksList, LOGTXT_INFO);
  logTxtLn(enabledCanvasOptions, LOGTXT_INFO);
  logTxtLn(reportValuesInLogfileList, LOGTXT_INFO);
  logTxtLn(logValueGroupsEnabled, LOGTXT_INFO);
}


void initLogTimes() {
  updateCurrentByteTimestamp(-1);
  initByteTimeStampMicroTime = currentByteTimeStampMicroTime;
  updateCurrentByteTimestamp(-1);
  updateShowtime();
  updateProcessedTimeDelta();
  logTxtStringNr = 0;
}

void flushLogFiles() { 
  if (!(logFileHandle == null) ) {
    logFileHandle.flush();
  }
  if (!(valuesLogFileHandle == null) ) {
    valuesLogFileHandle.flush();
  }
}

void closeLogFiles() { 
  logTxtLn("Closing LOG Files", LOGTXT_INFO);
  if (!(logFileHandle == null) ) {
    logFileHandle.close();
  }
  if (!(valuesLogFileHandle == null) ) {
    valuesLogFileHandle.close();
  }
}

boolean startNewLogFiles() {
  closeLogFiles();
  return initLogFiles();
}





void initValues() {
  // Clear logTxtStrings
  for (int j=0; j< 2; j++ ) {
    for ( int k=0; k< NRLOGTXTTYPES; k++ ) {
      logTxtStrings[k][j] ="";
    }
  }
  logTxtStringLnCount = 0;
  // Clear unprocessedData
  for ( int i=0; i< NRUNPROCESSEDDATABUFFERS; i++ ) {
    unprocessedData[i] = 0;
  }
  // Clear loggedTxtStrings
  nrLoggedNewTextStrings = 0;
  //==================//
  // Log File Handles //
  //==================//
  logFileHandle       = null;
  valuesLogFileHandle = null;
  rawLogFileHandle    = null;

  emulatorCommandsInQueue          = 0;
  emulatorDataValuesCtr            = 0;
  emulatorDataValuesCtrCurrent     = 0;
  processDataValuesCtr  = 0;
  incomingDataValuesCtr = 0;
  checkSumDataValuesCtr = 0;
  lastDestination = DEV_UNKNOWN_MASK;

  LOG_ORP_VAL      = "NA";
  LOG_PH_VAL       = "NA";
  LOG_SALTPCT_VAL  = "NA";
  LOG_SALTPPM_VAL  = "NA";
  LOG_PUMPGPM_VAL  = "NA";
  LOG_PUMPRPM_VAL  = "NA";
  LOG_PUMPWATT_VAL = "NA";
  LOG_AIRTEMP_VAL  = "NA";
  LOG_POOLTEMP_VAL = "NA";


  WATERTEMP ="?" ;
  BOXTEMP = "?";

  toggleNr = 0;
  rawLogFileHasBeenRead = 0;
  rawLogFileHasTimestamp = 1;
  lastLogTimeStampMicroTime     = 0;
  currentByteTimeStampMicroTime = 0;
  initByteTimeStampMicroTime    = 0;
  rawLogFileReadLine = "";

  currentEmulatorTime               = getAccurateMilliTime();
  newEmulatorActionTime             = currentEmulatorTime + powerCenterEmulatorTimeout;
  powerCenterEmulatorNextNr          = 0;
  currentPowerCenterIDBeingProbed    = DEV_CTL_MASK; 
  powerCenterEmulatorIsProbingAll    = 0;
  emulateDeviceIDsCtr                = 0;
  ONETOUCHEMUMessageLineNr           = 0;
  ONETOUCHEMUHighlightLineNr         = 0;

  pumpGPMVal         = 0;
  pumpDestination    = -1;
  pumpSource         = -1;
  pumpCommand        = -1;
  pumpCommandLength  = -1;
  pumpCommandDataCtr = 0;
  pumpCommandCKH     = -1;
  pumpCommandCKL     = -1;
  pumpMODEVal        = -1;
  pumpSTARTVal       = -1;

  checkSumIn = -1;
  checkSumErrorString = "";
  checkSumError = -1;
  logRawData                      = 1;
  droppedCtr                      = 0;
  previouslastReceivedByteTimeMicro   = 0;
  lastReceivedByteTimeMicro           = 0;
  lastShowTimeMicro     = 0;
  currentShowTimeMicro  = 0;
  showTimeMicroDelta    = 0;
  lastMicroTimeStamp    = getAccurateMicroTime();
  currentMicroTimeStamp = getAccurateMicroTime();
  timeStampDelta        = 0;
  lastCommand           = UNKNOWN_COMMAND;
  processedByteCounter  = 0;
  processedByteCounterTotal = 0;
  newProcessedByteCounterTime = getAccurateMilliTime() + PROCESSEDBYTESMINTIME;
  processedBps          = 0;


  logTxtString           = "";
  nrLoggedNewTextStrings    = 0;
  logTxtStringNr            = 0;
  unprocessedDataBufferNr   = 0;
  nowDecodingResponse       = 1;

  readOutStatus                = DEFAULTREADOUTSTATUS;

  waitingForNextStepClick = 0; //Used as a boolean to step through the emulator

  rawLogFileIncr = 1;
  rawLogFileDataLength = 0;
  rawLogFileNrBytes = 0;
  rawLogFileTimestampDelta = 0;
  rawLogFileDataVal = 0;
  rawLogFileDataPosition = 0;
  stillProcessingRAWLogFile = true;
  waitingForReplayDelay = false;
  replayDelayEndTime = 0;
  displayToggleButtonState = 0;
  nextRefreshTimeMicro = 0;
  rawIncomingDataNeedsNewline = 0;

  receiveLineBusy                  = 0;
  logTxtStringLnCount  = 0;

  destinationID             = DEV_UNKNOWN_MASK;
  lastDestinationName    = "NOT SET";

  replayTime0 = 0;
  replayTimeD = 0;

  lastValuesLogString = "";

  try {
    noDateFound = rawLogFileDateFormat.parse("01-01-2000_00:00:00.000");
  } 
  catch (Exception e) {
    print("EXCEPTION: "+e);
  }
  //println("NO DATE: "+noDateFound);
}

String cleanText(float number, int afterComma, int total) {
  String val = nfc(number, afterComma);
  val = addSpaces("", total-val.length())+val;
  return val;
}