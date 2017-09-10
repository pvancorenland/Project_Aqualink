//========================================//
// Procs to clean up RAW and values files //
//========================================//

void splitRAWLogFile( String inputFilePath ) {
  long bytesRead = 0;
  long timeStamp = 0;
  long startTimeStamp;
  int spaceChar = 0x20;
  int newLineChar = 0x0A;
  int readingFirstLine = 1;
  String firstLine = "";
  int readingTime = 1;
  long timeVal = 0;
  int dataVal = 0;
  long elapsedTime=0;
  int dataNum;
  int data = 0;
  int needNewLogFile = 0;
  long totElapsedTme=0; // in us
  long MAXTIMEPERRAWLOGFILE = 1*60*60;
  String fileName = "";
  MAXTIMEPERRAWLOGFILE *= 6000000; // 6e6 = every 6 hrs
  int foundDLEChar = 0;
  //===========================================
  PrintWriter smallLogFileHandle = createWriter("JNK");
  println("Opening file "+inputFilePath);
  InputStream inputLogFileStream = createInput(inputFilePath);
  try {
    while (data != -1) {
      data = inputLogFileStream.read();
      bytesRead++;
      //print("("+data+")");
      //print(data+":"+char(data)+" ");
      //============//
      // TITLE LINE //
      //============//
      if ( readingFirstLine == 1 ) {
        firstLine += char(data);
        //print(char(data));
        if ( data == newLineChar ) {
          readingFirstLine = 0;
          timeStamp = getLogFileTimeStampMS(firstLine, RAWLOGFILEHEADER);
          //println("TS: "+timeStamp);
          if ( timeStamp == -1 ) {
            // No timestamp found
            File fileTest = new File(inputFilePath);
            String[] dateVals = match(inputFilePath, "(.*?)Jandy_log_(.*?)_RAW.txt");
            //println("SADA "+dateVals[2]);
            Date df = getDateFromString(dateVals[2], fileTest.lastModified());
            timeStamp = df.getTime();
            println("Found date from RAW logfilename/date ==> " +dateVals[2]+ " == "+df.getTime()+" == "+df+" ==> "+rawLogFileDateFormat.format(df.getTime()));
          }
          startTimeStamp = timeStamp;
          println("LINE: "+firstLine+" @"+timeStamp+"="+rawLogFileDateFormat.format(timeStamp));
          fileName = logFilesPath+getLogFileNameBase(timeStamp)+RAWLogFileExtension+"_DUP";
          try {
            smallLogFileHandle.close();
          }
          catch (Exception e) {
            print("EXC CLOSE: "+e);
          }
          smallLogFileHandle = createWriter(fileName);
          smallLogFileHandle.print(createLogFileHeader(RAWLOGFILEHEADER, timeStamp)+"\n");
          println("Opening small logFile: "+fileName);
        }
      } else {
        //========================//
        // We read a date or data //
        //========================//
        if ( (data == spaceChar)||(data == -1)||(data == newLineChar) ) {
          if ( readingTime == 1 ) {
            // We finished reading the time
            readingTime = 0;
            elapsedTime += timeVal;
            smallLogFileHandle.print(timeVal+" ");
            timeVal = 0;
            if ( elapsedTime > MAXTIMEPERRAWLOGFILE ) {
              needNewLogFile = 1;
            }
          } else {
            // We read Data
            readingTime = 1;
            smallLogFileHandle.print(dataVal+" ");
            if ( needNewLogFile == 1 ) {
              // Look for DLE/ETX combination
              if ( dataVal == DLEChar ) {
                foundDLEChar = 1;
              } else {
                if ( foundDLEChar == 1 ) {
                  if ( dataVal == ETXChar ) {
                    // We found the end of a command or Response
                    // Create new LOG file
                    timeStamp += elapsedTime/1000;
                    totElapsedTme += elapsedTime;
                    fileName = logFilesPath+getLogFileNameBase(timeStamp)+RAWLogFileExtension;
                    println("Need new logFile "+elapsedTime+" = "+fileName);
                    try {
                      smallLogFileHandle.close();
                    }
                    catch (Exception e) {
                      print("EXC CLOSE: "+e);
                    }
                    //File fOutput = new File(dataPath(fileName));
                    smallLogFileHandle = createWriter(fileName);
                    smallLogFileHandle.print(createLogFileHeader(RAWLOGFILEHEADER, timeStamp)+"\n");
                    println("Opening small logFile: "+fileName);
                    needNewLogFile = 0;
                    elapsedTime = 0;
                    foundDLEChar = 0;
                  } else {
                    // We didn't find a DLE/ETX combination
                    foundDLEChar = 0;
                  }
                }
              }
            }
            dataVal = 0;
          }
        } else {
          //============================//
          // Read next Date/Data number //
          //============================//
          dataNum = data-48; //Convert from ASCII to real value
          if ( readingTime == 1 ) {
            timeVal = 10*timeVal + dataNum;
            //print(" >"+char(data)+"+("+timeVal+")");
          } else {
            dataVal = 10*dataVal + dataNum;
          }
        }
      }
    }
  }
  catch (IOException e) {
    e.printStackTrace();
  }
  finally {
    try {
      inputLogFileStream.close();
      smallLogFileHandle.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  timeStamp += elapsedTime/1000;
  totElapsedTme += elapsedTime;
  float KBps = (1000*bytesRead)*pow(totElapsedTme, -1);
  println(" ==> TIMESTAMP: "+timeStamp+" = "+rawLogFileDateFormat.format(timeStamp));
  println("Elapsed time: "+totElapsedTme+" = "+printElapsedTime(totElapsedTme/1000)+" for "+showHumanReadable(bytesRead)+" = "+KBps+"KB/s");
}

void createLogFilesList() {
  Date d = new Date();
  processedLogFilesCreatedDate = rawLogFileDateFormat.format(d.getTime());
  int delayCountNr = 0;
  // Count the _RAW and _Values log files
  println("CWD: "+sketchPath());
  println("Grabbing log file names from "+logFilesPath);
  File logFilesDir = new File(logFilesPath);
  if (!logFilesDir.isDirectory()) {
    println("Whoops! This is not a directory!");
  }
  String[] logFileNames = logFilesDir.list();
  int FNlength = 0;
  if ( logFileNames != null ) {
    FNlength = logFileNames.length;
  }
  maxValuesLogFileNr = 0;
  maxRawLogFileNr   = 0;
  println("Checking "+FNlength+" log files");
  for ( int i = 0; i < FNlength; i++ ) {
    if ( isValuesFileName(logFileNames[i]) ) {
      maxValuesLogFileNr++;
    } else {
      if ( isRawFileName(logFileNames[i]) ) {
        maxRawLogFileNr++;
      }
    }
  }
  valuesLogFileNames = new String[maxValuesLogFileNr];
  println("Found "+maxValuesLogFileNr+" Values log files");
  rawLogFileNames = new String[maxRawLogFileNr];
  println("Found "+maxRawLogFileNr+" RAW log files");
  // Record the Values and RAW log files
  maxValuesLogFileNr = 0;
  maxRawLogFileNr    = 0;
  for ( int i = 0; i < FNlength; i++ ) {
    if ( isValuesFileName(logFileNames[i]) ) {
      if ( showDebug(DEBUG_DETAILS) == 1 ) {
        println("Adding Values FILE #"+maxValuesLogFileNr+" = Log File #"+i+"/"+FNlength+": "+logFilesPath+logFileNames[i]);
      }
      valuesLogFileNames[maxValuesLogFileNr++] = logFileNames[i];
      delayCountNr = delayOnceInAWhile(delayCountNr, 256, 8); // Delay 8ms every 256 names to catch up
    } else {
      if ( isRawFileName(logFileNames[i]) ) {
        if ( showDebug(DEBUG_DETAILS) == 1 ) {
          println("Adding RAW FILE #"+maxValuesLogFileNr+" = Log File #"+i+"/"+FNlength+": "+logFilesPath+logFileNames[i]);
        }
        rawLogFileNames[maxRawLogFileNr++] = logFileNames[i];
        delayCountNr = delayOnceInAWhile(delayCountNr, 256, 8); // Delay 8ms every 256 names to catch up
      }
    }
  }
  maxValuesLogFileNr-- ;
  maxRawLogFileNr--    ;

  if ( processMaxNrFiles > 0 ) {
    maxValuesLogFileNr = processMaxNrFiles-1;
    maxRawLogFileNr    = processMaxNrFiles-1;
  }
  // Get the timestamp of the last data point
  if ( maxValuesLogFileNr >= 0 ) {
    lastFoundTimeStampMS = getLastFoundTimeStamp(logFilesPath+valuesLogFileNames[maxValuesLogFileNr]);
  }
}

boolean isValuesFileName(String logFileName ) {
  if ((logFileName.endsWith(endsWithValuesLogFileNames))&&(logFileName.startsWith(startsWithValuesLogFileNames))) {
    return true;
  }
  return false;
}

boolean isRawFileName(String logFileName ) {
  if ((logFileName.endsWith(endsWithRawLogFileNames))&&(logFileName.startsWith(startsWithRawLogFileNames))) {
    return true;
  }
  return false;
}

long getLastFoundTimeStamp(String fileName) {
  println("Looking for ending timeStamp for processMaxNrFiles = "+processMaxNrFiles+" in "+fileName);
  ValuesLogFileReader = createReader(fileName);
  String ValuesLogFileReadLine   = "";
  currentLogFileStartTimestampMS = 0;
  ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
  if ( ValuesLogFileReadLine.indexOf(VALUESLOGFILEHEADER) == 0 ) {
    currentLogFileStartTimestampMS = getLogFileTimeStampMS(ValuesLogFileReadLine, VALUESLOGFILEHEADER);
  } else { 
    return 0;
  }
  while (ValuesLogFileReadLine != null) {
    //==============================//
    // Get timestamp from data line //
    //===============//
    // Read new line //
    ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
    if (( ValuesLogFileReadLine != null )&&(!isCommentedLine(ValuesLogFileReadLine))) {
      String tmp = trim(ValuesLogFileReadLine.substring(0, ValuesLogFileReadLine.indexOf(LOG_VALUE_SEPARATOR)));
      logFileDataLineTimeStampUS = Long.parseLong(tmp);
    }
  }
  try {
    ValuesLogFileReader.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  } 
  // Add 500us so the division is a ceil()
  logFileDataLineTimeStampUS+=500;
  long lastTimeStampMS = logFileDataLineTimeStampUS/1000+currentLogFileStartTimestampMS;
  println("Found ending timeStamp: "+logFileDataLineTimeStampUS/1000+" + "+currentLogFileStartTimestampMS+" = "+lastTimeStampMS+" = "+rawLogFileDateFormat.format(lastTimeStampMS));
  resetTimeStamps();
  return lastTimeStampMS;
}

void resetTimeStamps() {
  previousFullTimeStampUS = 0;
  fullTimeStampUS = 0;
}

void createReducedLogFiles(String fileLength, String fileInterval, boolean alignWithLastFoundTimestamp) {
  println("Creating reduced Log File(s)");
  long timeIntervalMS = getTimeNumber(fileInterval);
  long fileLengthMS   = getTimeNumber(fileLength);
  if ( (timeIntervalMS == 0 )||(fileLengthMS == 0)) {
    println("ERROR! fileInterval="+fileInterval+" timeIntervalMS="+timeIntervalMS+" fileLength="+fileLength+" fileLengthMS="+fileLengthMS);
    exit();
  }
  String reducedFileID = fileLength+"_"+fileInterval;
  splitLogFileLengthMS = fileLengthMS;
  resetTimeStamps();
  long tmpLastFoundTimeStampMS = startTimeStampMS(lastFoundTimeStampMS, timeIntervalMS, false)+timeIntervalMS +1;
  //println("Updating lastFoundTimeStampMS: "+lastFoundTimeStampMS+" ==> "+tmpLastFoundTimeStampMS);
  if ( alignWithLastFoundTimestamp ) {
    alignTimeStampOffsetMS = startTimeStampMS( tmpLastFoundTimeStampMS, splitLogFileLengthMS, true) + splitLogFileLengthMS - tmpLastFoundTimeStampMS;
  } else {
    alignTimeStampOffsetMS = 0;
  }
  println("End time alignment requested @ "+tmpLastFoundTimeStampMS+" = "+rawLogFileDateFormat.format(tmpLastFoundTimeStampMS)+" ==> Using alignment offset: "+alignTimeStampOffsetMS+" = "+formatTimeStampUS(alignTimeStampOffsetMS*1000));
  reducedValuesFileID = reducedFileID;
  for ( int i = 0; i <= maxValuesLogFileNr; i++ ) {
    println("##########################################");
    println("Processing FILE: "+logFilesPath+valuesLogFileNames[i]);
    print("    =====> ");
    tmpTimestampUS = readProcessReduceValuesFile(logFilesPath+valuesLogFileNames[i], lastLogFileEndTimeStampUS, timeIntervalMS);
    if ( tmpTimestampUS > 0 ) {   
      lastLogFileEndTimeStampUS = tmpTimestampUS;
    }
  }
  // No more files left, so close out
  recordAndResetSumTimes();
  println("Last recorded timestamp = "+newSplitFileTimeStampMS+" = "+rawLogFileDateFormat.format(newSplitFileTimeStampMS));
  // Close the last output file
  splitValuesLogFileHandle.close();
}

String getNextLogFileName() {
  if ( valueFileNr > maxValuesLogFileNr ) {
    return null;
  } else {
    return valuesLogFileNames[valueFileNr++];
  }
}

void recordAndResetSumTimes() {
  String outLine = "";
  String optVal = "";
  //print("MAXSUMTIME: "+maxSumTimesUS+" nrSumPts: "+nrSumPts);
  //Process and print values
  //=======//
  // DEBUG //
  //=======//
  if ( showDebug(DEBUG_DETAILS) == 1 ) {
    String debugLine = relativeTimeNowUS+" MAXSUMTIME: "+maxSumTimesUS+" nrSumPts: "+nrSumPts;
    for (int i=0; i< totDataseries; i++ ) {
      debugLine += ">"+sumDatavalues[i]+"/"+sumTimes[i]+"<";
    }
    writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, debugLine);
  }
  //=========//
  // PROCESS //
  //=========//
  // Lines loo like this:
  // 114149,500.3,7.82,3600,0,NA,NA,NA,NA,NA,NA,0,0,0,0,0,0,0,0,0,0,0,0,0
  for (int i=0; i<totDataseries; i++ ) {
    sumDatavalues[i] /= sumTimes[i];
    //print(sumDatavalues[i]+ " ");
    if ( i > 0 ) {
      outLine += ",";
    }
    optVal = formatDigits(sumDatavalues[i], nrDigits[i]);
    if ( !optVal.equals(oldSumDatavaluesString[i]) ) {
      outLine += optVal;
    }
    oldSumDatavaluesString[i] = optVal;
  }
  //println();
  writeNewValuesSplitLogLine(newSplitFileTimeStampMS, outLine);
  //=========//
  //Clean up //
  //=========//
  for (int i=0; i< totDataseries; i++ ) {
    sumDatavalues[i] = 0;
    sumTimes[i]      = 0;
  }
  nrSumPts    = 0;
  maxSumTimesUS = 0;
}

boolean nextPointISaJMP ( ) {
  boolean weHaveAJump = false;
  //=================//
  // Check for Jumps //
  //println("TIM1: "+currentLogFileStartTimeStampUS+" + "+logFileDataLineTimeStampUS+" ==> "+fullTimeStampUS+"us "+fullTimeStampMS+"ms ==> "+rawLogFileDateFormat.format(fullTimeStampMS));
  //println("DELTA: "+deltaTimeStampSinceLastFullDataPtUS+" == "+currentLogFileStartTimeStampUS+"+"+logFileDataLineTimeStampUS+" : "+fullTimeStampUS+" ==> "+rawLogFileDateFormat.format(fullTimeStampMS));
  if ( deltaTimeStampSinceLastFullDataPtUS > maxdeltaTimeStampUS ) {
    weHaveAJump = true;
    // We found a "Jump" in the timestamps. Don't include the current line in the ongoing sum calculations
    if ( !copyFileWritesToConsole ) {
      println("####JMP "+deltaTimeStampSinceLastFullDataPtUS+"US = " +deltaTimeStampSinceLastFullDataPtUS/1000+"MS");
    }
    writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, "#   JMP "+deltaTimeStampSinceLastFullDataPtUS+"US = " +formatTimeStampUS(deltaTimeStampSinceLastFullDataPtUS));
  }
  return weHaveAJump;
}

long getNewSplitFileTimeStampMS( long fullTimeStampMS, long timeIntervalMS) {
  long value = startTimeStampMS(fullTimeStampMS, timeIntervalMS, false)+timeIntervalMS ;
  if ( beVerbose ) {
    writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, "#   NEW SPLIT TIMESTAMP: "+fullTimeStampMS+"@"+timeIntervalMS+" ==> "+value+" = "+formatTimeStampUS(value*1000));
  }
  return value;
}

void grabDataLineTimeStamp(String readLine) {
  //===============//
  // Get timestamp from log File data line
  String tmp = trim(readLine.substring(0, readLine.indexOf(LOG_VALUE_SEPARATOR)));
  //tmp = String.format("%.0f", Float.parseFloat(tmp));
  logFileDataLineTimeStampUS = Long.parseLong(tmp);
  //println("TMP: "+tmp+" STAMP: "+logFileDataLineTimeStampUS);
  fullTimeStampUS = currentLogFileStartTimeStampUS + logFileDataLineTimeStampUS;
  fullTimeStampMS = fullTimeStampUS/1000;
  deltaTimeStampSinceLastFullDataPtUS = fullTimeStampUS - previousFullTimeStampUS;
  if ( beVerbose ) {
    writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, "#   "+readLine);
    writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, "#   DTS: "+logFileDataLineTimeStampUS+" ==> "+deltaTimeStampSinceLastFullDataPtUS+" = "+fullTimeStampUS+" - "+previousFullTimeStampUS+" ==> "+formatTimeStampUS(logFileDataLineTimeStampUS));
  }
  previousFullTimeStampUS = fullTimeStampUS;
}

boolean needNewSplitLogFileAtThisTimestamp(long timeStamp) {
  if ( nextSplitLogFileStartMS <= timeStamp ) {
    //println("SplitLogFileTimeStampExceeded: FTS "+timeStamp+" >= NSPLFS "+nextSplitLogFileStartMS );
    return true;
  } else {
    return false;
  }
}

void writeNewValuesSplitLogLine( long timeStampMS, String line) {
  // Write a line to the split log file
  // Open a new file if needed
  // ======================================
  // Add Original created date
  // Original created date: "#Full values Log File created @ "+processedLogFilesCreatedDate
  // Add nextendtime data and update
  // println("FTS: "+timeStampMS, "NSP: "+nextSplitLogFileStartMS+" NSP<=FTS: "+(nextSplitLogFileStartMS < timeStampMS));
  //============================================//
  // Check if we need to start a new split file //
  //============================================//
  if ( timeStampMS != DONTADDLOGTIMESTAMP ) {
    if (needNewSplitLogFileAtThisTimestamp(timeStampMS)) {  
      // Open a new file
      openNewSplitLogFile(timeStampMS);
    }
    //splitValuesLogFileHandlePrintln("#   writeNewValuesSplitLogLine: "+timeStampMS+" -- "+rawLogFileDateFormat.format(timeStampMS));
    if ( !lastValuesLogFileNameLineAdded ) {
      splitValuesLogFileHandlePrintln(lastValuesLogFileNameLine);
      lastValuesLogFileNameLineAdded = true;
    }
    // Write the line
    splitValuesLogFileHandlePrintln(timeStampMS+LOG_VALUE_SEPARATOR+line);
  } else {
    // Write the line
    splitValuesLogFileHandlePrintln(line);
  }
}

void splitValuesLogFileHandlePrintln(String line) {
  if ( copyFileWritesToConsole ) {
    println(line);
  }
  splitValuesLogFileHandle.println(line);
}

long getCurrentSplitLogFileStartMS(long fullTimeStampMS, long fileLength) {
  long timeStampMS = 0;
  //long NSPFSMS = 0;
  if ( fileLength >= YEARLENGTH ) {
    timeStampMS = thisYearStartTimeStampMS(fullTimeStampMS + alignTimeStampOffsetMS) - alignTimeStampOffsetMS ;
  } else {
    timeStampMS = startTimeStampMS(fullTimeStampMS + alignTimeStampOffsetMS, fileLength, true) - alignTimeStampOffsetMS ;
  }
  //println(" | FTS: "+fullTimeStampMS+" = "+rawLogFileDateFormat.format(fullTimeStampMS)+" LENGTH: "+fileLength);
  //println("   START: "+timeStampMS+" = "+rawLogFileDateFormat.format(timeStampMS)+" With offset "+alignTimeStampOffsetMS);
  return timeStampMS;
}

long getNextSplitLogFileStartMS(long fullTimeStampMS, long fileLength) {
  if ( fileLength == YEARLENGTH ) {
    return addOneYear(getCurrentSplitLogFileStartMS(fullTimeStampMS, fileLength));
  } else {
    return getCurrentSplitLogFileStartMS(fullTimeStampMS, fileLength)+fileLength;
  }
}

long getPreviousSplitLogFileStartMS(long fullTimeStampMS, long fileLength) {
  if ( fileLength == YEARLENGTH ) {
    return subtractOneYear(getCurrentSplitLogFileStartMS(fullTimeStampMS, fileLength));
  } else {
    return getCurrentSplitLogFileStartMS(fullTimeStampMS, fileLength)-fileLength;
  }
}

void openNewSplitLogFile(long fullTimeStampMS) {
  // Generate file name
  long currentSplitLogFileStartMS = getCurrentSplitLogFileStartMS(fullTimeStampMS, splitLogFileLengthMS);
  nextSplitLogFileStartMS = getNextSplitLogFileStartMS(fullTimeStampMS, splitLogFileLengthMS);
  //println(" | FTS: "+fullTimeStampMS+" = "+rawLogFileDateFormat.format(fullTimeStampMS)+" TSMS: "+currentSplitLogFileStartMS+" = "+rawLogFileDateFormat.format(currentSplitLogFileStartMS)+" NSPLFS: "+nextSplitLogFileStartMS+" = "+rawLogFileDateFormat.format(nextSplitLogFileStartMS));
  String splitValuesFileName = "";
  if ( useEpochTimeForSplitLogFileName ) {
    splitValuesFileName = logFilesPath+splitValuesFileRootName+reducedValuesFileID+"_"+currentSplitLogFileStartMS+".txt";
  } else {
    splitValuesFileName = logFilesPath+splitValuesFileRootName+reducedValuesFileID+"_"+rawLogFileDateFormat.format(currentSplitLogFileStartMS)+".txt";
  }
  String line = "Opening new split Log File:: "+splitValuesFileName+"\n# Good from "+currentSplitLogFileStartMS+" = "+rawLogFileDateFormat.format(currentSplitLogFileStartMS)+" through "+nextSplitLogFileStartMS+" = "+rawLogFileDateFormat.format(nextSplitLogFileStartMS);
  println(line);
  if ( splitValuesLogFileHandleHasBeenOpened ) {
    splitValuesLogFileHandlePrintln("#"+line);
    splitValuesLogFileHandle.close();
  }
  //Open the file
  splitValuesLogFileHandle = createWriter(splitValuesFileName);
  splitValuesLogFileHandlePrintln(createLogFileHeader(VALUESLOGFILEHEADER, currentSplitLogFileStartMS));
  if ( beVerbose ) {
    println("Adding "+maxLogFileHeadersNr+" header lines");
  }
  // Add the log file headers
  for ( int i=0; i< maxLogFileHeadersNr; i++ ) {
    //println(logFileHeaders[i]);
    splitValuesLogFileHandlePrintln(logFileHeaders[i]);
  }
  // Add the timestamps for all the alternative fileLengths
  splitValuesLogFileHandlePrintln("#PREVTIMESTAMPS"+generatePreviousTimeStamps(fullTimeStampMS));
  splitValuesLogFileHandlePrintln("#CURRTIMESTAMPS"+generateCurrentTimeStamps(fullTimeStampMS));
  splitValuesLogFileHandlePrintln("#NEXTTIMESTAMPS"+generateNextTimeStamps(fullTimeStampMS));
  splitValuesLogFileHandlePrintln(lastValuesLogFileNameLine);
  lastValuesLogFileNameLineAdded = true;
  splitValuesLogFileHandleHasBeenOpened = true;
}

long readProcessReduceValuesFile(String ValuesLogFileName, long minStartValueUS, long timeIntervalMS) {
  lastValuesLogFileNameLine = "#   Added From: "+ValuesLogFileName;
  lastValuesLogFileNameLineAdded = false;
  ValuesLogFileReader = createReader(ValuesLogFileName);
  String ValuesLogFileReadLine   = "";
  currentLogFileStartTimestampMS = -1;
  logFileDataLineTimeStampUS = 0;
  //===============//currentLogFileStartTimeStampUS
  // Start reading //
  //===============//
  ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
  if ( ValuesLogFileReadLine.indexOf(VALUESLOGFILEHEADER) == 0 ) {
    currentLogFileStartTimestampMS = getLogFileTimeStampMS(ValuesLogFileReadLine, VALUESLOGFILEHEADER);
    currentLogFileStartTimeStampUS = currentLogFileStartTimestampMS * 1000;
    logFileDataLineTimeStampUS = 0;
    println("START TIME: "+currentLogFileStartTimestampMS);
    ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
    //==============================================================
    // Check if we have already found a valid formatted header line
    //==============================================================
    if ( foundValuesLogHeaderFile == 0 ) {
      ValuesLogFileHeaderLine = ValuesLogFileReadLine;
      println("Found Header: "+ValuesLogFileHeaderLine);
      logFileHeaders[maxLogFileHeadersNr++] = ValuesLogFileHeaderLine;
      // Read the rest of the commented lines
      ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
      while ( isCommentedLine(ValuesLogFileReadLine) ) {
        // This is a comment
        // Extract the needed data from the first set of comment lines
        processCommentedLine(ValuesLogFileReadLine);
        println(ValuesLogFileReadLine);
        logFileHeaders[maxLogFileHeadersNr++] = ValuesLogFileReadLine;
        // Read the rest of the commented lines
        ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
      }
      //maxLogFileHeadersNr--;
      foundValuesLogHeaderFile = 1;
    } else {
      // We already established the headerline from file #0
      // Perform Sanity check
      if ( !ValuesLogFileHeaderLine.equals(ValuesLogFileReadLine) ) {
        println("LOG HEADER IS DIFFERENT!: >"+ValuesLogFileReadLine+"< != >"+ValuesLogFileHeaderLine+"<");
        exit();
      }
      //==================================
      // Ignore the lines with comments (this is needed for the 2nd through last file that is processed)
      while ( isCommentedLine(ValuesLogFileReadLine) ) {
        // Read the rest of the commented lines
        ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
      }
    }
    if ( previousFullTimeStampUS == 0 ) {
      println("NEW SETUP @"+currentLogFileStartTimestampMS);
      // previousFullTimeStampUS has not been set yet
      previousFullTimeStampUS = currentLogFileStartTimeStampUS;
      openNewSplitLogFile(currentLogFileStartTimestampMS);
      newSplitFileTimeStampMS = getNewSplitFileTimeStampMS(currentLogFileStartTimestampMS, timeIntervalMS) ;
    }
    //==================================
    // Process the data in the file
    //==================================
    //Read the rest of the lines past the header and commented lines
    while (ValuesLogFileReadLine != null) {
      //==============================//
      // Get timestamp from data line //
      grabDataLineTimeStamp(ValuesLogFileReadLine);
      //println("FTS: "+fullTimeStampMS+" > "+newSplitFileTimeStampMS);
      if ( fullTimeStampMS >= newSplitFileTimeStampMS ) {
        //Process the remaining time until the next split log timestamp
        long deltaEnd   = fullTimeStampUS - newSplitFileTimeStampMS*1000;
        long deltaStart = deltaTimeStampSinceLastFullDataPtUS - deltaEnd;
        if ( beVerbose ) {
          writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, "#   DELTASTART: "+deltaStart+" DELTAEND "+deltaEnd+" TOT: "+deltaTimeStampSinceLastFullDataPtUS+" NSPLTF: "+newSplitFileTimeStampMS+" = "+formatTimeStampUS(newSplitFileTimeStampMS*1000));
        }
        if ( !nextPointISaJMP() ) {
          // Include the next point in the sum
          grabAndSumNewDataValues(ValuesLogFileReadLine, deltaStart);
        } else {
          if (beVerbose ) {
            writeNewValuesSplitLogLine(DONTADDLOGTIMESTAMP, "#Skipping to next JMP Pt");
          }
        }
        // Spit out new split data point
        recordAndResetSumTimes();

        newSplitFileTimeStampMS = getNewSplitFileTimeStampMS(fullTimeStampMS, timeIntervalMS) ;
        // Process the remaining points (part of next split timestamp)
        grabAndSumNewDataValues(ValuesLogFileReadLine, deltaEnd);
      } else {
        //===================================================================//
        // We have not yet exceeded the timestamp for a new split data point
        // Update the summed data values //
        grabAndSumNewDataValues(ValuesLogFileReadLine, deltaTimeStampSinceLastFullDataPtUS);
      }
      //===============//
      // Read new line //
      ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
    }
    return fullTimeStampUS;
  } else {
    println("No Valid first Header line found! Aborting!!!");
  }
  return -1;
  //delay(3000);
}

void grabAndSumNewDataValues(String readLine, long deltaTimeStamp) {
  String[] dataPts = split(readLine, ",");
  for (int i=0; i< totDataseries; i++ ) {
    newDatavalues[i] = float(dataPts[i+1]);
    if (!Float.isNaN(newDatavalues[i])) {
      sumDatavalues[i] += deltaTimeStamp * newDatavalues[i];
      sumTimes[i]      += deltaTimeStamp;
      if ( sumTimes[i] > maxSumTimesUS ) {
        maxSumTimesUS = sumTimes[i];
      }
    }
  }
  //println(deltaTimeStampSinceLastFullDataPtUS+"==> "+readLine+" maxSumTimesUS="+maxSumTimesUS);
}


void processCommentedLine(String line) {
  String[] values = split(line, ",");
  totDataseries = values.length - 1;
  if ( values[0].equals(LOG_DIGITS_NAME) ) {
    //println(LOG_DIGITS_NAME+"==> "+totValues);
    for (int i=0; i < totDataseries; i++ ) {
      //print(i+"::"+values[i+1]);
      nrDigits[i] = int(values[i+1]);
      //println(i+" ==> "+nrDigits[i]);
    }
    println("Found "+totDataseries+" data series");
  }
}

String generatePreviousTimeStamps(long timeStampMS) {
  String optLine = "";
  // Go through all File lengths
  for ( int i=0; i< outPutConfig.length; i++ ) {
    String[] dataLine = outPutConfig[i];
    optLine += ","+getPreviousSplitLogFileStartMS(timeStampMS, getTimeNumber(dataLine[0]));
    ;
  }
  //println("LINE: "+optLine);
  return optLine;
}

String generateNextTimeStamps(long timeStampMS) {
  String optLine = "";
  // Go through all File lengths
  for ( int i=0; i< outPutConfig.length; i++ ) {
    String[] dataLine = outPutConfig[i];
    optLine += ","+getNextSplitLogFileStartMS(timeStampMS, getTimeNumber(dataLine[0]));
    ;
  }
  //println("LINE: "+optLine);
  return optLine;
}

String generateCurrentTimeStamps(long timeStampMS) {
  String optLine = "";
  // Go through all File lengths
  for ( int i=0; i< outPutConfig.length; i++ ) {
    String[] dataLine = outPutConfig[i];
    optLine += ","+getCurrentSplitLogFileStartMS(timeStampMS, getTimeNumber(dataLine[0]));
    ;
  }
  //println("LINE: "+optLine);
  return optLine;
}

int delayOnceInAWhile(int countNr, int delayEveryCount, int delayVal) {
  if ( countNr > delayEveryCount ) {
    delay(delayVal);
    countNr = 0;
  } else {
    countNr++;
  }
  return countNr;
}


long getTimeNumber(String timeNumberString ) {
  switch(timeNumberString) {
  case "1Y" : 
    return YEARLENGTH; // 366 days
  case "3M" : 
    return 7948800000L; // 31 days
  case "1M" : 
    return 2678400000L; // 31 days
  case "1WK" : 
    return 604800000L;
  case "2D" : 
    return 172800000L;
  case "1D" : 
    return 86400000L;
  case "3H" : 
    return 10800000L;
  case "1H" : 
    return 3600000L;
  case "1d" : 
    return 24*60*60*1000; // 1 day
  case "1h" : 
    return 60*60*1000; // 1 hour
  case "15m" : 
    return 15*60*1000; // 15 minutes
  case "5m" : 
    return 5*60*1000;  // 5 minutes
  case "1m" : 
    return 1*60*1000;  // 1 minute
  case "10s" : 
    return 10*1000;  // 10s
  case "1s" : 
    return 1*1000;  // 1s;
  default: 
    return 0;
  }
}

String readNextLogLine(BufferedReader readerID) {
  String line;
  try {
    line = readerID.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  } 
  if ((line == null)||(line.isEmpty())) {
    return null;
  } else {
    return line;
  }
}

long getTimeZoneDelta(long testTime) {
  String testDate = rawLogFileDateFormat.format(testTime);
  //print(testTime+" = "+testDate);
  rawLogFileDateFormat.setTimeZone(tzGMT);
  Date df = new Date();
  ;
  try {
    df =  rawLogFileDateFormat.parse(testDate);
  }
  catch (Exception e) {
    print("EXCEPTION: "+e);
  }
  //print(" == "+df.getTime());
  long timeZoneOffset = df.getTime() - testTime;
  //println(" ==> OFFSET: "+timeZoneOffset+" = "+timeZoneOffset/3600000+" Hrs");
  rawLogFileDateFormat.setTimeZone(tzLocal);
  return timeZoneOffset;
}


boolean isCommentedLine(String readLine) {
  //println("ISCRL: "+readLine);
  if ( readLine == null) {
    return false;
  }
  boolean ret = (readLine.charAt(0) == commentChar.charAt(0));
  return ret;
}

long startTimeStampMS(long timeStampMS, long timeStampMSInterval, boolean alignWithMidnight) {
  // Returns a timestamp before "timeStampMS" which is on an interval "timeStampMSInterval"
  // timeStampMSInterval = DAYLENGTH ==> Start of today
  // timeStampMSInterval = WEEKLENGTH ==> Start of 7 day period
  long offsetVal = getTimeZoneDelta(timeStampMS);
  if ( !alignWithMidnight ) {
    offsetVal = 0;
  }
  //print(" ->  CHG TS: "+timeStampMS+" = "+rawLogFileDateFormat.format(timeStampMS)+" ==> ");
  timeStampMS += offsetVal;
  //print(" +offset: "+offsetVal+" = "+timeStampMS+" = "+rawLogFileDateFormat.format(timeStampMS));
  long returnVal = timeStampMS/timeStampMSInterval;
  //print(" DIV: "+returnVal);
  returnVal = returnVal*timeStampMSInterval;
  //print(" FLOOR: "+returnVal+" = "+rawLogFileDateFormat.format(returnVal));
  returnVal = returnVal-offsetVal;
  //println(" TO: "+returnVal+" = "+rawLogFileDateFormat.format(returnVal));
  return returnVal;
}

long thisYearStartTimeStampMS( long timeStampMS) {
  long offsetVal = 0;
  /*
long offsetVal = getTimeZoneDelta(timeStampMS);
   if ( !alignWithMidnight ) {
   offsetVal = 0;
   }
   */
  //print(" ->  CHG TS: "+fullTimeStampMS+" = "+rawLogFileDateFormat.format(fullTimeStampMS)+" ==> ");
  long returnVal = yearStartTimeStamp(timeStampMS + offsetVal);
  returnVal += offsetVal;
  //println(" TO: "+returnVal+" = "+rawLogFileDateFormat.format(returnVal)+" OFFSET: "+offsetVal);
  return returnVal;
}

long nextDayTimeStampMS(long timeStampMS) {
  long nextDay = thisDayTimeStampMS(timeStampMS) + DAYLENGTH;
  return nextDay;
}

long thisDayTimeStampMS(long timeStampMS) {
  //print(" TDTS: "+timeStampMS);
  long thisDay = startTimeStampMS(timeStampMS, DAYLENGTH, true);
  //println("==> "+thisDay);
  return thisDay;
}

String formatDigits(float num, int nrDigits) {
  String formatStr = "%."+nrDigits+"f";
  String opt = String.format(formatStr, num);
  return opt;
}

long addOneYear(long fullTimeStampMS) {
  String year = rawLogFileDateFormatYear.format(fullTimeStampMS);
  String noYear = rawLogFileDateFormatNoYear.format(fullTimeStampMS);
  int nextYear = Integer.parseInt(year)+1;
  String nextYearString = str(nextYear)+"-"+noYear;
  //println("NYS: "+nextYearString);
  Date df = new Date();
  try {
    df =  rawLogFileDateFormat.parse(nextYearString);
  }
  catch (Exception e) {
    print("EXCEPTION: "+e);
  }
  long tmpTimeStamp = df.getTime();
  //println(" FTS: "+fullTimeStampMS+" TMPTS: "+tmpTimeStamp+" = "+rawLogFileDateFormat.format(tmpTimeStamp));
  return tmpTimeStamp;
}

long subtractOneYear(long fullTimeStampMS) {
  String year = rawLogFileDateFormatYear.format(fullTimeStampMS);
  String noYear = rawLogFileDateFormatNoYear.format(fullTimeStampMS);
  int prevYear = Integer.parseInt(year)-1;
  String prevYearString = str(prevYear)+"-"+noYear;
  Date df = new Date();
  try {
    df =  rawLogFileDateFormat.parse(prevYearString);
  }
  catch (Exception e) {
    print("EXCEPTION: "+e);
  }
  long tmpTimeStamp = df.getTime();
  //println(" FTS: "+fullTimeStampMS+" TMPTS: "+tmpTimeStamp+" = "+rawLogFileDateFormat.format(tmpTimeStamp));
  return tmpTimeStamp;
}

long nextYearStartTimeStampMS( long fullTimeStampMS) {
  return addOneYear(thisYearStartTimeStampMS(fullTimeStampMS));
}

long yearStartTimeStamp( long fullTimeStampMS) {
  String year = rawLogFileDateFormatYear.format(fullTimeStampMS);
  //println("TS:"+fullTimeStampMS+" = "+year);
  int yearVal = Integer.parseInt(year);
  Date df = new Date();
  try {
    df =  rawLogFileDateFormatYear.parse(str(yearVal));
  }
  catch (Exception e) {
    print("EXCEPTION: "+e);
  }
  long tmpTimeStamp = df.getTime();
  //println(" FTS: "+fullTimeStampMS+" TMPTS: "+tmpTimeStamp+" = "+rawLogFileDateFormat.format(tmpTimeStamp));
  return tmpTimeStamp;
}

String formatTimeStampUS(long deltaTimeStampSinceLastFullDataPtUS) {
  String opt = "";
  long remainder = deltaTimeStampSinceLastFullDataPtUS;
  long testVal = 0;
  long divisors[] = {31536000000000L, 86400000000L, 3600000000L, 60000000L, 1000000L, 1000L, 1L};
  String names[] = {"YR", "D", "HR", "MIN", "SEC", "MS", "US"};

  for ( int i = 0; i< 7; i++ ) {
    testVal = remainder/divisors[i];
    //println("I: " + i+ " DIV: "+divisors[i]+" TV: "+testVal+" REM: "+remainder);
    opt += printRemainder(testVal, names[i])+" ";
    remainder = remainder - testVal * divisors[i];
  }
  //    opt = rawLogFileDateFormat.format(deltaTimeStampSinceLastFullDataPtUS-getTimeZoneDelta(deltaTimeStampSinceLastFullDataPtUS));
  return opt;
}


String printRemainder(long value, String name) {
  //  println("VAL: "+value);
  String opt =  "";
  if ( value > 0 ) {
    opt += value+name;
  }
  return opt;
}