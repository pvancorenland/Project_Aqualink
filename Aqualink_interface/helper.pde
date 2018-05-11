

void unknownResponse(int deviceID, int command, int response, int startNr, int endNr) {
  String commandDescription = "";
  if ( command == UNKNOWN_COMMAND ) {
    commandDescription = "\"Unknown Command\": ";
  }
  commandDescription += reportVal(command, 2);
  logTxtLn("Unknown "+getDestinationName(deviceID)+" ("+reportVal(deviceID, 2)+") Response: "+reportVal(response, 2)+" to command: "+commandDescription, LOGTXT_WARNING);
  logTxtData(startNr, endNr);
}

void processValidGenericACK_Response(String txt, int command, int startNr, int endNr) {
  logTxt(txt+" ACK", LOGTXT_TYPE);
  verifyACKToCommand(command, startNr, endNr);
}

void processValidGenericACK_Response(int command, int startNr, int endNr) {
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
  if ( (displayThisOption("showMemoryStatistics"))&&(processSingleRAWFile)) {
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
      if (!(outputLogFileHandle == null) ) {
        logTxtLn(memStats, LOGTXT_INFO);
      } else {
        println(memStats);
      }
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

String getLogFileNameBase(long timeStamp) {
  String opt = "Jandy_log_"+rawLogFileDateFormat.format(timeStamp);
  return opt;
}

boolean initLogFiles() {
  //=======================================//
  // Open Output, RAW and VALUES log files //
  //=======================================//
  // Initialize timing values
  initLogTimes();
  Date d = new Date();
  logFileStartTimestamp = d.getTime();
  //=======================================//
  // Setup the name base for the log files //
  //=======================================//
  if ( areWeReadingRawLogFile() ) {
    logFileNameBase = getRawLogFileReadNameBase();
  } else {
    if ( useLogFileNameBase == "" ) {
      logFileNameBase = getLogFileNameBase(logFileStartTimestamp); // Record log data to this file
    } else {
      logFileNameBase = useLogFileNameBase;
    }
  }
  if ( logFileNameBase == "" ) {
    logTxtLn("logFileNameBase is empty, Aborting!", LOGTXT_WARNING);
    return false;
  }
  //logFileNameBase = logFilesPath+logFileNameBase;
  //=================//
  // Output Log file //
  //=================//
  // Default output log file//  
  // This needs to be opened before all the others since it is used by logTxtLn()
  String outputLogFileName = logFileNameBase+outputFileExtension;
  File fOutput = new File(dataPath(logFilesPath+outputLogFileName));
  if ( (fOutput.exists())&(dontOverWriteOutputFiles) ) {
    println("Output logFile "+outputLogFileName+" already exists, skipping!");
    return false;
  }
  outputLogFileHandle = createWriter(logFilesPath+outputLogFileName);
  logTxtLn("Opened output logFile "+outputLogFileName+" at: "+d+" = "+logFileStartTimestamp, LOGTXT_INFO);
  //==============//
  // RAW Log file //
  //==============//
  // RAW data and timestamp output log //  
  // RAW Data LogFile //
  String RAWLogFileName = logFileNameBase+RAWLogFileExtension;
  if ( areWeReadingRawLogFile() ) {
    //==================================//
    // Open the RAW logfile for Reading //
    //==================================//
    verifyAndCorrectRAWLogFileRead(logFilesPath, RAWLogFileName, true);
  } else {
    //==================================//
    // Open the RAW logfile for Writing //
    //==================================//
    File fRAW = new File(dataPath(logFilesPath+RAWLogFileName));
    if ( fRAW.exists() ) {
      println("RAW logFile "+RAWLogFileName+" already exists, skipping!");
      RAWLogFileRead.errorCode = RAWLOGFILEALREADYEXISTS;
    } else {
      RAWLogFileWriterHandle = createWriter(logFilesPath+RAWLogFileName);
      RAWLogFileValuesWritten = 0;
      logTxtLn("Opened RAW logFile "+RAWLogFileName+" for up to "+RAWLogFileValuesWrittenMax+" values", LOGTXT_INFO);
      printToRawLogFile(createLogFileHeader(RAWLOGFILEHEADER, logFileStartTimestamp)+"\n", RAWLogFileWriterHandle);
    }
  }
  if (RAWLogFileRead.errorCode != RAWLOGFILEISGOOD ) {
    return false;
  }
  if ( areWeProcessingRAWLogFile() ) {
    //====================//
    // Output Values file //
    //====================//
    // Output Values File //
    String valuesFileName = logFileNameBase+valuesFileExtension;
    if (!testValuesFileNameForWriting(logFilesPath+valuesFileName) ) {
      return false;
    }
    valuesLogFileHandle = createWriter(logFilesPath+valuesFileName);
    printToValuesLogFile(createLogFileHeader(VALUESLOGFILEHEADER, logFileStartTimestamp)+"\n");
    printToValuesLogFile(RAWLOGFILEVERSION+"\n");
    writeValuesToLogFile(1);
    logTxtLn("Opened and initialized Values logFile "+valuesFileName+" for writing", LOGTXT_INFO);
    //====================//
    // Print general info //
    //====================//
    printSetupInfo();
    if ( areWeReadingRawLogFile() ) {
      println("\nProcessing file #"+rawLogFileReadNameBaseNr+" ==> "+logFileNameBase);
    }
  }
  return true;
}

String printLong(long val) {
  return String.valueOf(val);
  /*
  String opt ="";
   long divisor = 10000000L;
   long valMS   = val/divisor;
   int valMSint = int(valMS);
   long tmp = divisor*valMSint;
   long valLS = val - tmp;
   int valLSint = int(valLS);
   //opt = str(tmp)+"==>"+str(valMS)+"="+str(valMSint)+" "+str(valLS)+"="+str(valLSint);
   if ( valMSint > 0 ) {
   opt = str(valMSint)+str(valLSint);
   } else {
   opt = str(valLSint);
   }
   return opt;
   */
}

boolean testValuesFileNameForWriting(String fileName ) {
  File fValues = new File(dataPath(fileName));
  if ( (fValues.exists())&(dontOverWriteOutputFiles) ) {
    println("Output logFile "+fileName+" already exists, skipping!");
    return false;
  }
  return true;
}

//void openWriteLogFile(String fileBase, String fileName, String description) {
//}

void closeReadLogFile() {
  logTxtLn("Closing RAW logFile "+RAWLogFileRead.fileName, LOGTXT_INFO);
  try {
    RAWLogFileRead.handle.close();
  } 
  catch (IOException e) {
    println("Oh Oh!");
    e.printStackTrace();
  }
}

void closeWriteLogFile(PrintWriter fileHandle) {
  //try {
  fileHandle.close();
  //} 
  //catch (IOException e) {
  //  println("Oh Oh!");
  //  e.printStackTrace();
  //}
}

String readLogFileLine() {
  String readLine;
  try {
    readLine = RAWLogFileRead.handle.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    readLine = null;
  }  
  return readLine;
}

void verifyAndCorrectRAWLogFileRead(String filePath, String fileName, boolean dryRun ) {
  RAWLogFileRead.fileName = fileName;
  RAWLogFileRead.filePath = filePath;
  logTxtLn("Verifying RAW logFile "+RAWLogFileRead.fileName, LOGTXT_INFO);
  String fullFileNamePath = RAWLogFileRead.filePath+RAWLogFileRead.fileName;
  //=============================================//
  // Check if file exists and has the right name //
  //=============================================//
  File fRAW = new File(dataPath(fullFileNamePath));
  if ( !fRAW.exists() ) {
    logTxtLn("RAW logFile "+RAWLogFileRead.fileName+" does not exist. Aborting!", LOGTXT_WARNING);
    RAWLogFileRead.errorCode = RAWLOGFILEDOESNOTEXIST;
  } else {
    File fileTest = new File(fullFileNamePath);
    String[] dateVals = match(RAWLogFileRead.fileName, "Jandy_log_(.*?)_RAW.txt");
    Date df = getDateFromString(dateVals[1], fileTest.lastModified());
    logTxtLn("Date from RAW logFile name = " +dateVals[1]+ " == "+df.getTime()+" == "+df+" ==> "+rawLogFileDateFormat.format(df.getTime()), LOGTXT_INFO);
    // Create new logFileName
    String testFileName = getRAWLogFileName(df.getTime());
    // String testFileName = "Jandy_log_"+rawLogFileDateFormat.format(df.getTime())+RAWLogFileExtension; // Record log data to this file
    if ( !RAWLogFileRead.fileName.equals(testFileName) ) {
      logTxtLn("RAW logFile NAME NOT CONSISTENT! "+RAWLogFileRead.fileName+" <==>"+testFileName, LOGTXT_WARNING);
      // Update filename
      renameRAWLogFile(testFileName);
    }
    // Get log file start timestamp from existing RAW log file
    logFileStartTimestamp = df.getTime();
    if ( RAWLogFileRead.errorCode != RAWLOGFILEDOESNOTEXIST ) {
      RAWLogFileRead.handle = createReader(RAWLogFileRead.filePath+RAWLogFileRead.fileName);
      RAWLogFileRead.hasTimeStamp = 0;
      //=================================//
      // Read first line in RAW log file //
      //=================================//
      RAWLogFileRead.headerReadLine = readLogFileLine();
      if (RAWLogFileRead.headerReadLine == null) {
        // Something is wrong
        println("Whoops, the file "+logFileNameBase+RAWLogFileExtension+" seems to be empty!");
        RAWLogFileRead.errorCode = RAWLOGFILEISEMPTY;
      } else {
        if ( RAWLogFileRead.headerReadLine.indexOf(RAWLOGFILEHEADER) == 0 ) {
          long timeStamp = getLogFileTimeStampMS(RAWLogFileRead.headerReadLine, RAWLOGFILEHEADER);
          RAWLogFileRead.hasTimeStamp = 1;
          RAWLogFileRead.needsUpdate  = 0;
          if ( timeStamp == -1 ) {
            // No Date found
            logTxtLn("No Data found inside the RAW logFile, reusing the logFileStartTimestamp", LOGTXT_INFO);
            RAWLogFileRead.needsUpdate = 1;
            RAWLogFileRead.timeStamp   = logFileStartTimestamp;
          } else {
            RAWLogFileRead.timeStamp = timeStamp;
          }
          logTxtLn("Found date from Header "+RAWLogFileRead.timeStamp+" = "+rawLogFileDateFormat.format(RAWLogFileRead.timeStamp), LOGTXT_INFO);
          if ( logFileStartTimestamp != RAWLogFileRead.timeStamp ) {
            long deltaVal = RAWLogFileRead.timeStamp - logFileStartTimestamp;
            logTxtLn("logFileStartTimestamp="+logFileStartTimestamp+" != rawLogFileTimeStamp="+RAWLogFileRead.timeStamp+" Delta: "+deltaVal, LOGTXT_WARNING);
            renameRAWLogFile(getRAWLogFileName(RAWLogFileRead.timeStamp));
          }
          // Read the DATA line
          logTxtLn("Reading RAW logFile data line", LOGTXT_INFO);
          RAWLogFileRead.dataReadLine = readLogFileLine();
          closeReadLogFile();
          if (RAWLogFileRead.dataReadLine == null) {
            // Something is wrong
            println("Whoops, the file "+logFileNameBase+RAWLogFileExtension+" seems to be empty past the TIMESTAMP header!");
            RAWLogFileRead.errorCode = RAWLOGFILEISEMPTY;
          } else {
            if ( RAWLogFileRead.needsUpdate == 1 ) {
              //============================//
              //Rewrite Current RAW LogFile //
              //============================//
              closeReadLogFile();
              if ( !dryRun ) { 
                RAWLogFileWriterHandle = createWriter(RAWLogFileRead.filePath + RAWLogFileRead.fileName);
                logTxtLn("Rewriting RAW logFile "+RAWLogFileRead.fileName, LOGTXT_INFO);
                printToRawLogFile(createLogFileHeader(RAWLOGFILEHEADER, logFileStartTimestamp), RAWLogFileWriterHandle);
                //          printToRawLogFile(RAWLOGFILEHEADER+" "+logFileStartTimestamp+" "+rawLogFileDateFormat.format(logFileStartTimestamp)+"\n");
                printToRawLogFile(RAWLogFileRead.dataReadLine, RAWLogFileWriterHandle);
                closeWriteLogFile(RAWLogFileWriterHandle);
                println(" `--> Finished");
              }
            }
          }
        } else {
          RAWLogFileRead.errorCode = RAWLOGFILEWRONGHEADER;
        }
      }
    }
  }
}

String getRAWLogFileName(long timeStamp) {
  String fileName =getLogFileNameBase(timeStamp)+RAWLogFileExtension; // Record log data to this file
  return fileName;
}

void renameRAWLogFile(String newFileName ) {
  logTxtLn("Renaming RAW logFile! "+RAWLogFileRead.fileName+" ==> "+newFileName, LOGTXT_INFO);
  //logTxtLn("Renaming RAW logFile! "+RAWLogFileRead.filePath +RAWLogFileRead.fileName+" ==> "+RAWLogFileRead.filePath +newFileName, LOGTXT_INFO);
  File ff = new File(RAWLogFileRead.filePath + RAWLogFileRead.fileName);
  ff.renameTo(new File(RAWLogFileRead.filePath + newFileName));
  RAWLogFileRead.fileName = newFileName;
}

String createLogFileHeader(String header, long timeStamp) {
  String opt = header+" "+timeStamp+" "+rawLogFileDateFormat.format(timeStamp);
  return opt;
}

Date getDateFromString(String str, long backupDate) {
  //Date df = new Date();
  Date df = noDateFound;
  try {
    // rawLogFileDateFormat = new SimpleDateFormat("dd-MM-yyyy_HH:mm:ss");
    df =  rawLogFileDateFormat.parse(str);
  }
  catch (Exception e) {
    //print("EXC: "+e);
    try {
      df =  OLDrawLogFileDateFormatShort.parse(str);
    }
    catch (Exception eS) {
      try {
        df = OLDrawLogFileDateFormat.parse(rawLogFileDateFormat.format(backupDate));
      }
      catch (Exception eL) {
        //print("EXC: "+eL);
        logTxtLn("EXC: "+eL, LOGTXT_ERROR);
      }
    }
  }
  return df;
}

void printToRawLogFile( String str, PrintWriter fileHandle ) {
  //print("PRRWLF "+str+"<<");
  fileHandle.print(str);
  fileHandle.flush();
  RAWLogFileValuesWritten++;
  if ( RAWLogFileValuesWritten >= RAWLogFileValuesWrittenMax ) {
    newLogFilesNeeded = true;
  }
}

void printToValuesLogFile( String str ) {
  valuesLogFileHandle.print(str);
  valuesLogFileHandle.flush();
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
  if (!(outputLogFileHandle == null) ) {
    outputLogFileHandle.flush();
  }
  if (!(valuesLogFileHandle == null) ) {
    valuesLogFileHandle.flush();
  }
}

void closeLogFiles() { 
  logTxtLn("Closing logFiles", LOGTXT_INFO);
  if (!(outputLogFileHandle == null) ) {
    outputLogFileHandle.close();
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
  outputLogFileHandle          = null;
  valuesLogFileHandle    = null;
  RAWLogFileWriterHandle = null;

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
  LOG_SPATEMP_VAL  = "NA";
  LOG_POOLTEMP_VAL = "NA";
  // NEED TO ADD LOG_DEVICES_LIST

  WATERTEMP ="?" ;
  BOXTEMP = "?";

  toggleNr = 0;
  lastLogTimeStampMicroTime     = 0;
  currentByteTimeStampMicroTime = 0;
  initByteTimeStampMicroTime    = 0;
  RAWLogFileRead.dataReadLine = "";
  RAWLogFileRead.hasTimeStamp = 1;
  RAWLogFileRead.errorCode = RAWLOGFILEISGOOD;
  RAWLogFileRead.fileName = "";
  RAWLogFileRead.filePath = "";
  RAWLogFileRead.handle = null;
  RAWLogFileRead.timeStamp = 0;
  RAWLogFileRead.headerReadLine = "";
  RAWLogFileRead.dataReadLine = "";
  RAWLogFileRead.needsUpdate = 0;
  RAWLogFileRead.dataPosition = 0;
  RAWLogFileRead.dataLength = 0;
  RAWLogFileRead.nrBytes = 0;
  RAWLogFileRead.Incr = 0;

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

  rawLogFileTimestampDelta = 0;
  rawLogFileDataVal = 0;
  waitingForReplayDelay = false;
  replayDelayEndTime = 0;
  displayToggleButtonState = 0;
  nextRefreshTimeMicro = 0;
  rawIncomingDataNeedsNewline = 0;

  receiveLineBusy                  = 0;
  logTxtStringLnCount  = 0;

  destinationID       = DEV_UNKNOWN_MASK;
  lastDestinationName = "NOT SET";

  replayTime0 = 0;
  replayTimeD = 0;

  lastValuesLogString = "";
  lastValuesLogTime = "";
  lastValuesLogSkipped = 0;
  try {
    noDateFound = rawLogFileDateFormat.parse(rawLogFileDateFormat.format(0));
  } 
  catch (Exception e) {
    print("EXCEPTION: "+e);
  }
  //println("NO DATE: "+noDateFound);

  // Create a list of all CTL devices
  for ( int i = 0; i<CTL_EXPECTED_BUTTSTAT_BYTES; i++ ) {
    processDataValues[i] = 0xFF;
  }
  CTLDEVICESLIST = checkCTLButtonStatus(0, CTL_EXPECTED_BUTTSTAT_BYTES);
  CTLDEVICESLISTSPLIT = split(CTLDEVICESLIST, " ");
  LOG_DEVICES_LIST = new int[CTLDEVICESLISTSPLIT.length];
  //  for ( int i=0; i< CTLDEVICESLISTSPLIT.length; i++ ) {
  //    LOG_DEVICES_LIST[i] = 0;
  //  }

  TimeZone tz = TimeZone.getTimeZone("America/Los_Angeles");
  rawLogFileDateFormat.setTimeZone(tz);
  rawLogFileDateFormatShort.setTimeZone(tz);
  OLDrawLogFileDateFormat.setTimeZone(tz);
  OLDrawLogFileDateFormatShort.setTimeZone(tz);
  rawLogFileDateFormat.setTimeZone(tzLocal); // ??????????????? FROM PROCESSVALUESFILES
}

String cleanText(float number, int afterComma, int total) {
  String val = nfc(number, afterComma);
  val = addSpaces("", total-val.length())+val;
  return val;
}

String printElapsedTime(long elapsedTime) {
  String optStr = "";
  int printRest = 0;
  long days = elapsedTime/(1000*24*60*60);
  if ( days > 0 ) {
    optStr += days+"D ";
    elapsedTime -= days*1000*24*60*60;
    printRest = 1;
  }
  long hours = elapsedTime/(1000*60*60);
  if ((hours > 0 )||( printRest == 1 )) {
    optStr += hours+"H ";
    elapsedTime -= hours*1000*60*60;
    printRest = 1;
  }
  long minutes = elapsedTime/(1000*60);
  if ((minutes > 0)||( printRest == 1 ) ) {
    optStr += minutes+"M ";
    elapsedTime -= minutes*1000*60;
    printRest = 1;
  }
  long seconds = elapsedTime/(1000);
  if ((seconds > 0)||( printRest == 1 ) ) {
    optStr += seconds+"S ";
    elapsedTime -= seconds*1000;
    printRest = 1;
  }
  if ((elapsedTime > 0)||( printRest == 1 ) ) {
    optStr += elapsedTime+"mS ";
  }
  return optStr;
}

long getAccurateMilliTime() {
  long accuTime = System.nanoTime()/1000000;
  return accuTime;
}

long getAccurateMicroTime() {
  long accuTime = System.nanoTime()/1000;
  return accuTime;
}

long getLogFileTimeStampMS(String rawLogFileReadLine, String header) {
  // Returns the timestamp from the _Values.txt log file header in MS
  if ( rawLogFileReadLine.indexOf(header) == 0 ) {
    rawLogFileReadLine += " -1";
    rawLogFileReadLine = rawLogFileReadLine.substring(header.length());
    String[] tmpVals = split(rawLogFileReadLine, " ");
    if ( (tmpVals.length < 4)||(tmpVals[3] == "-1") ) {
      return -1;
    } else {
      return Long.valueOf(tmpVals[1]);
    }
  }
  return -1;
}

String addSpaces(String Str, int nrOfSpaces) {
  int nrSpacesAdded = nrOfSpaces-Str.length();
  for (int i=0; i< nrSpacesAdded; i++ ) {
    Str += " ";
  }
  return Str;
}