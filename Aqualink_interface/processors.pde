//==========================//
//=== GENERAL PROCESSING ===//
//==========================//
/* 
 // Storage Structure
 // incomingDataValues[incomingDataValuesCtr]       ==> Holds the DATA + CHECKSUM DATA
 // incomingDataValuesCtr                           ==> Keeps track of array position of the next DATA byte
 // void processInputData() {
 // processDataValues[]                       ==> Contains incomingDataValues[] after processInputData has been run;
 // processDataValuesCtr                      ==> incomingDataValuesCtr after processInputData has been run;
 // processEquipmentData() {
 // processReadChecksumData() {
 // checkSumDataValues[]          ==> Contains processDataValues[] after processReadChecksumData() or processSendChecksumData()
 // checkSumDataValuesCtr         ==> Contains processDataValuesCtr after processReadChecksumData() or processSendChecksumData()
 // }
 // }
 // processPumpData() {
 // }
 // }
 // unprocessedData[unprocessedDataBufferNr]        ==> Keeps track of the unprocessed data. 
 // Gets cleared when unprocessedDataBufferNr == NRUNPROCESSEDDATABUFFERS
 // droppedPackets[droppedCtr]                      ==> Keeps track of the dropped packets, as registered by recordDroppedPacket()
 // Reset by reportDroppedData()
 */
boolean processIncomingData(long timestamp, int readData ) {
  if ( displayThisOption("showRawIncomingHexData") ) {
    String displayVal = "";
    if ( debugThis( DEBUG_SHOWTIMESTAMPWITHRAWDATA) ) {
      displayVal += timestamp+" ";
    }
    displayVal += "r"+reportVal(readData, 2);
    //displayVal += getASCIIString(readData);
    displayVal += " ";
    print(displayVal);
    logFileHandle.print(displayVal);
    rawIncomingDataNeedsNewline = 1;
  }
  boolean foundCommandResponse = false;
  countProcessedBytes();
  if ( debugThis( DEBUG_RECEIVELINE )||debugThis( DEBUG_SHOWPROCESSINCOMING )) {
    print(reportVal(readData, 2)+" ");
  }
  setReceiveLineBusy(1);
  if ( weAreEmulatingPowerCenter() == 1 ) {
    currentEmulatorTime = getAccurateMilliTime();
    logFilePrintln(3, "PINCD TIM: "+currentEmulatorTime+" DELTA "+(currentEmulatorTime - newEmulatorActionTime));
    newEmulatorActionTime = currentEmulatorTime + powerCenterEmulatorTimeout;
  }
  //==================//
  //===== REPORT =====//
  //==================//
  readData &=RS485INCDATAMASK;
  // Set timestamp and update "Current time"
  timestamp = updateCurrentByteTimestamp(timestamp);
  if ( (logRawData == 1) ) {
    rawLogFileHandle.print(timestamp+" ");
    rawLogFileHandle.print(readData+" ");
  }
  if ( showDebug(DEBUG_ON) == 1 ) {
    logTxt(reportVal(readData, 2)+" ", LOGTXT_DEBUG);
  }
  if ( !recordUnprocessedData(readData) ) {
    // This happens if we overflow the unprocessedData buffer
    return foundCommandResponse;
  }
  //===================//
  //===== PROCESS =====//
  //===================//
  switch(readOutStatus) {
    //===========//
    // EQUIPMENT //
    //===========//
    case(LOOKINGFORCTL):
    // We stay here until we find a DLE character
    switch(readData) {
      case(DLEChar) :
      if ( reportAndDropUnprocessedData(-1) == 0 ) {
        reportDroppedData("LOOKINGFORCTL ==> DLE");
      }
      changeReadOutStatus(LOOKINGFORSTX);
      break;
      case(FFChar):
      if ( reportAndDropUnprocessedData(-1) == 0 ) {
        reportDroppedData("LOOKINGFORCTL ==> FF");
      }
      changeReadOutStatus(LOOKINGFORPUMPDATANUL);
      break;
    default:
      recordDroppedPacket(readData);
      break;
    }
    break;
    case(LOOKINGFORSTX) :
    // See if we receive an STX after the DLE char
    switch(readData) {
      case(STXChar) :
      // Start reading the data
      //reportAndDropUnprocessedData(-2);
      changeReadOutStatus(LOOKINGFORDATA);
      break;
      case(ETXChar) :
      // We found ETX, but were looking for STX.
      // Most likely, we had garbled data and the DLE-STX sequence got messed up
      // Purge if we aleady received a command
      logTxt("Found "+reportVal(readData, 2)+" while LOOKINGFORSTX: ", LOGTXT_WARNING);      
      resetProcessIncomingData("LOOKINGFORSTX ==> DEFAULT", 0, DEFAULTREADOUTSTATUS);
      logTxtLn(LOGTXT_RESP);
      break;
    default:
      // We didn't find an STX, so we need to go back to looking for a DLE
      logTxt("Found "+reportVal(readData, 2)+" while LOOKINGFORSTX: ", LOGTXT_WARNING);
      resetProcessIncomingData("LOOKINGFORSTX ==> DEFAULT", 0, DEFAULTREADOUTSTATUS);
      break;
    }
    break;
    case(LOOKINGFORETX) :
    // See if we receive an ETX after the DLE char
    switch(readData) {
      case(ETXChar) :
      // Done with the data
      processInputData(EQUIPMENTDATA);
      foundCommandResponse = true;
      break;
      case(STXChar) :
      // We found an STX after a DLE, but we were actually looking for an ETX ==> Reset and start reading the data
      logTxt("Found STX while LOOKINGFORETX: ", LOGTXT_WARNING);
      //logTxtLn(LOGTXT_WARNING);
      resetProcessIncomingData("LOOKINGFORETX ==> LOOKINGFORDATA", -2, LOOKINGFORDATA);
      break;
      case(NULChar) :
      // A 0x0h is inserted after a DLE in case it's part of the command/data, we need to remove it
      // Increase ctl position to include the last (dropped) char
      changeReadOutStatus(LOOKINGFORDATA);
      incomingDataValuesCtr++;
      break;
    default:
      // We didn't find an STX/NUL, so we need to go back to looking for a DLE
      logTxt("Found "+reportVal(readData, 2)+" while LOOKINGFORETX: ", LOGTXT_WARNING);
      resetProcessIncomingData("LOOKINGFORETX ==> DEFAULT", 0, DEFAULTREADOUTSTATUS);
      break;
    }
    break;
    case(LOOKINGFORDATA) :
    incomingDataValues[incomingDataValuesCtr] = int(readData);
    if ( readData == DLEChar ) {
      changeReadOutStatus(LOOKINGFORETX);
      // Do not increase incomingDataValuesCtr, this will only be done if there is a NULCHAR (escape) after the DLECHAR
    } else {
      incomingDataValuesCtr++;
      if ( incomingDataValuesCtr >= MAXNROFINCOMINGDATAVALUES ) {
        reportAndDropUnprocessedData(0);
        resetProcessIncomingData("MAXNROFINCOMINGDATAVALUES ==> DEFAULT", 0, DEFAULTREADOUTSTATUS);
      }
    }
    break;
    //======//
    // PUMP //
    //======//
    case(LOOKINGFORPUMPDATAFF) :
    switch(readData) {
      case(FFChar) :
      changeReadOutStatus(LOOKINGFORPUMPDATANUL);
      break;
      case(DLEChar) :
      logTxt("Found DLE while LOOKINGFORPUMPDATAFF: ", LOGTXT_WARNING);
      if ( reportAndDropUnprocessedData(-1) == 0 ) {
        reportDroppedData("LOOKINGFORPUMPDATAFF ==> DLE");
      }
      changeReadOutStatus(LOOKINGFORSTX);
      break;
      case(NULChar) :
      logTxt("Found NUL while LOOKINGFORPUMPDATAFF: ", LOGTXT_WARNING);
      if ( reportAndDropUnprocessedData(0) == 0 ) {
        reportDroppedData("LOOKINGFORPUMPDATAFF ==> NUL");
      }
      //reportDroppedData("LOOKINGFORPUMPDATAFF ==> NUL");
      changeReadOutStatus(DEFAULTREADOUTSTATUS);
      break;
    default:
      logTxt("Found unknown data while LOOKINGFORPUMPDATAFF: "+reportVal(readData, 2)+" ", LOGTXT_WARNING);
      reportAndDropUnprocessedData(0);
      changeReadOutStatus(DEFAULTREADOUTSTATUS);
      break;
    }
    break;
    case(LOOKINGFORPUMPDATANUL) :
    switch(readData) {
      case(NULChar) :
      changeReadOutStatus(LOOKINGFORPUMPDATAFF);
      break;
      case(PUMPChar):
      changeReadOutStatus(LOOKINGFORPUMPDATASUB);
      pumpDestination   = -1;
      pumpSource        = -1;
      pumpCommand       = -1;
      pumpCommandLength = -1;
      break;
      case(DLEChar) :
      logTxt("Found DLE while LOOKINGFORPUMPDATANUL: ", LOGTXT_WARNING);
      if ( reportAndDropUnprocessedData(-1) == 0 ) {
        reportDroppedData("LOOKINGFORPUMPDATANUL ==> DLE");
      }
      changeReadOutStatus(LOOKINGFORSTX);
      break;
    default:
      reportAndDropUnprocessedData(0);
      changeReadOutStatus(DEFAULTREADOUTSTATUS);
      break;
    }
    break;
    case(LOOKINGFORPUMPDATASUB) :
    switch(readData) {
      case(NULChar) :
      changeReadOutStatus(LOOKINGFORPUMPDATADST);
      break;
    default:
      logTxtLn("Found unknown data while LOOKINGFORPUMPDATASUB: "+readData+" while LOOKINGFORPUMPDATASUB", LOGTXT_WARNING);
      reportAndDropUnprocessedData(0);
      // DO WE NEED SOMETHING LIKE THIS????????
      changeReadOutStatus(DEFAULTREADOUTSTATUS);
      //
      break;
    }
    break;
    case(LOOKINGFORPUMPDATADST) :
    pumpDestination = readData;
    changeReadOutStatus(LOOKINGFORPUMPDATASRC);
    break;
    case(LOOKINGFORPUMPDATASRC) :
    pumpSource = readData;
    changeReadOutStatus(LOOKINGFORPUMPDATACMD);
    break;
    case(LOOKINGFORPUMPDATACMD) :
    pumpCommand = readData;
    changeReadOutStatus(LOOKINGFORPUMPDATALEN);
    break;
    case(LOOKINGFORPUMPDATALEN) :
    pumpCommandLength = readData;
    if ( pumpCommandLength > MAXNRPUMPCOMMANDDATA ) {
      resetProcessIncomingData("pumpCommandLength > MAXNRPUMPCOMMANDDATA", 0, DEFAULTREADOUTSTATUS);
    } else {
      pumpCommandDataCtr = 0;
      changeReadOutStatus(LOOKINGFORPUMPDATAVAL);
    }
    break;
    case(LOOKINGFORPUMPDATAVAL) :
    if ( pumpCommandDataCtr < pumpCommandLength ) {
      //println(" CTR= "+pumpCommandDataCtr+" DATA = "+readData);  
      pumpCommandData[pumpCommandDataCtr] = readData;
      pumpCommandDataCtr++;
    } else {
      pumpCommandCKH = readData;
      changeReadOutStatus(LOOKINGFORPUMPDATACKL);
    }
    break;
    case(LOOKINGFORPUMPDATACKL) :
    pumpCommandCKL = readData;
    processInputData(PUMPDATA);
    foundCommandResponse = true;
    break;
  default:
    logTxtLn("##########UNKNOWN Data ", LOGTXT_WARNING);
    reportAndDropUnprocessedData(0);
    break;
  }
  return foundCommandResponse;
}

void resetProcessIncomingData(String reason, int stopVal, int readOutStatus) {
  logFilePrintln(1, "resetProcessIncomingData "+reason+" "+stopVal+" "+readOutStatus);
  reportDroppedData(reason);
  reportAndDropUnprocessedData(stopVal);
  changeReadOutStatus(readOutStatus);
  // Reset the bytes counter
  incomingDataValuesCtr = 0;
  lastDestination = DEV_UNKNOWN_MASK;
}

void processAllIncomingData() {
  while (currentOpenPort.available () > 0) {
    processIncomingData(-1, currentOpenPort.read());
  }
}

void recordDroppedPacket(int data) {
  if ( debugThis(DEBUG_SHOWWHENDATAISDROPPED) ) {
    logFilePrintln(0, " ==>DROP: "+reportVal(data, 2)+" ");
  }
  droppedPackets[droppedCtr] = data;
  droppedCtr++;
  if ( droppedCtr >= MAXNRDROPPEDPACKETS-1 ) {
    logTxtLn("## MAX #DROPPED PACKETS EXCEEDED! ", LOGTXT_WARNING);
    reportDroppedData("## MAX #DROPPED PACKETS EXCEEDED! ");
  }
}

void setReceiveLineBusy(int val) {
  if ( debugThis( DEBUG_RECEIVELINE )) {
    switch(val) {
    case 1:
      println("BUSY");
      break;
    case 0:
      println("NOT BUSY");
      break;
    }
  }
  receiveLineBusy = val;



  receiveLineBusy = 0;
}

void countProcessedBytes() {
  String ProcessedBytesLine = "";
  processedByteCounter++; // We are processing a new Byte, keep track of how many
  processedByteCounterTotal++; // We are processing a new Byte, keep track of how many
  long currentprocessedBytesTime = getAccurateMilliTime();
  if ( newProcessedByteCounterTime < currentprocessedBytesTime ) {
    // Printout Statistics
    processedBps = processedByteCounter * 1000 / ( currentprocessedBytesTime - (newProcessedByteCounterTime - PROCESSEDBYTESMINTIME)  );
    ProcessedBytesLine += "Received: "+processedByteCounter+" Bytes @"+processedBps+" Bps";
    newProcessedByteCounterTime = currentprocessedBytesTime + PROCESSEDBYTESMINTIME;
    processedByteCounter = 0;
    if ( (emulatePowerCenterIDsCtr > 0)  ) {
      ProcessedBytesLine += " - Unanswered commands: "+unansweredCommands+"/"+sentCommands;
      if ( sentCommands > 0 ) {
        ProcessedBytesLine += " ("+unansweredCommands/sentCommands*100+"%)";
      }
    }
    ProcessedBytesLine += "\n";
    unansweredCommands = 0;
    sentCommands       = 0;
    if ( displayThisOption("showProcessedBytesStatistics") ) {
      print(ProcessedBytesLine);
    }
    updateInfoText(ProcessedBytesLine);
  }
}

void processInputData(int datatype) {  
  logFilePrintln(2, "processInputData CSDATAVALCTR="+str(checkSumDataValuesCtr));
  reportDroppedData("PROCESSINPUTDATA");
  // Copy the incoming data to the processing buffer
  for ( int i=0; i< incomingDataValuesCtr; i++ ) {
    processDataValues[i] = incomingDataValues[i];
  }
  processDataValuesCtr = incomingDataValuesCtr;
  incomingDataValuesCtr = 0;
  reportDroppedData("PROCESSINPUTDATA");
  // Update new emulator action time
  setReceiveLineBusy(0);
  newEmulatorActionTime = getAccurateMilliTime() + powerCenterEmulatorTimeout;
  switch(datatype) {
  case EQUIPMENTDATA:
    {
      processEquipmentData();
    }
    break;
  case PUMPDATA:
    {
      processPumpData();
    }
    break;
  }
  // Add time info and check if we need  to print
  // Update times
  // this needs to happen AFTER processXXXX() since it uses the nowDecodingResponse value
  updateProcessedTimeDelta();
  // Log the unprocessed data
  logPrintUnprocessedData(0);
  if (nowDecodingResponse == 1 ) {
    // We just decoded a response, so write the CMD/RESP pair
    logTxtLn(LOGTXT_RESP);
  }
  // Clean up
  clearUnprocessedData(0);
  changeReadOutStatus(DEFAULTREADOUTSTATUS);
}

void reportDroppedData(String reason) {
  if ( displayThisOption("showDroppedData") ) {
    if ( droppedCtr > 0 ) {
      int showDropped = 0;
      for (int i=0; i< droppedCtr; i++ ) {
        if ( droppedPackets[i] != 0 ) {
          showDropped = 1;
        }
      }
      if ( showDropped == 1 ) {
        logTxt(reason+": DROPPED PACKETS: ", LOGTXT_WARNING);
        for (int i=0; i< droppedCtr; i++ ) {
          logTxt(reportVal(droppedPackets[i], 2)+" ", LOGTXT_WARNING);
        }
        // Show binary version of packets
        int maxNum = 0;
        if ( maxNum > 0 ) {
          logTxt(" == ", LOGTXT_WARNING);
          for (int i=0; i< maxNum; i++ ) {
            logTxt("0b"+binary(droppedPackets[i], 8)+" ", LOGTXT_WARNING);
          }
        }
        // Show text version of dropped packets
        logTxt(" == ", LOGTXT_WARNING);
        for (int i=0; i< droppedCtr; i++ ) {
          logTxt(getASCIIString(droppedPackets[i]), LOGTXT_WARNING);
        }
        logTxtLn(LOGTXT_WARNING);
      }
    }
  }
  clearDroppedPackets();
}

void clearDroppedPackets() {
  droppedCtr = 0;
}

int processEquipmentData() {
  logFilePrintln(2, "processEquipmentData");
  int status = -1;
  if ( processDataValuesCtr > 2 ) {
    // Strip the Checksum data
    processDataValuesCtr--;
    checkSumIn = processDataValues[processDataValuesCtr];
    logFilePrintln(3, "CS IN:"+reportVal(checkSumIn, 2));
    int calculatedChecksum = processReadChecksumData() ;
    int destination = processDataValues[0];
    //println("PROCDATABYTES DEST="+reportVal(destination, 2)+" CS="+reportVal(checkSumIn, 2));
    if ( destination < 8 ) {
      // Destination == MASTER , so this is a response
      logFilePrintln(3, "DECRESP");
      status = decodeResponse(destination, processDataValues[1]);
    } else {
      logFilePrintln(3, "DECCOMM");
      status = decodeCommand(destination, processDataValues[1]);
    }
    //checkSumError = checkSumError;
    if ( checkSumError == 1 ) {
      logTxt(checkSumErrorString, LOGTXT_CHECKSUMERROR);
    } 
    logTxt(reportVal(checkSumIn, 2)+"/"+reportVal(calculatedChecksum, 2), LOGTXT_CHECKSUM);
  } else {
    logTxtLn("NOT ENOUGH DATA TO PROCESS BYTES: "+processDataValuesCtr, LOGTXT_WARNING);
  }
  return status;
}

int showDebug(int debugMask) {
  if ( (debugMask&debug) == debugMask) {
    return 1;
  } else {
    return 0;
  }
}

void changeReadOutStatus(int statusID) {
  logFilePrintln(3, "changeReadOutStatus: "+statusID);
  String optString = reportReadOutStatus();
  readOutStatus = statusID;
  optString += " ==> " + reportReadOutStatus();
  String debugLine = reportReadOutStatus();
  if ( showDebug(DEBUG_CHANGEREADOUTSTATUS) == 1) {
    if ( !debugLine.equals("") ) {
      logTxtLn(" ==> Status: "+optString, LOGTXT_DEBUG);
    }
  }
  if ( readOutStatus == DEFAULTREADOUTSTATUS) {
    incomingDataValuesCtr = 0;
  }
}

String reportReadOutStatus() {
  String debugLine = "";
  switch(readOutStatus) {
    case(LOOKINGFORCTL):
    debugLine += "Looking for CTL";
    break;
    case(LOOKINGFORSTX):
    debugLine += "Looking for STX";
    break;
    case(LOOKINGFORETX):
    debugLine += "Looking for ETX";
    break;
    case(LOOKINGFORDATA):
    debugLine += "Looking for DATA";
    break;
    case(LOOKINGFORPUMPDATACKL):
    debugLine += "Looking for PUMP DATA CKL";
    break;
    case(LOOKINGFORPUMPDATANUL):
    debugLine += "Looking for PUMP DATA NUL";
    break;
    case(LOOKINGFORPUMPDATAFF):
    debugLine += "Looking for PUMP DATA FF";
    break;
    case(LOOKINGFORPUMPDATASUB):
    debugLine += "Looking for PUMP DATA SUB";
    break;
    case(LOOKINGFORPUMPDATADST):
    debugLine += "Looking for PUMP DATA DEST";
    break;
    case(LOOKINGFORPUMPDATASRC):
    debugLine += "Looking for PUMP DATA SRC";
    break;
    case(LOOKINGFORPUMPDATACMD):
    debugLine += "Looking for PUMP DATA CMD";
    break;
    case(LOOKINGFORPUMPDATALEN):
    debugLine += "Looking for PUMP DATA LEN";
    break;
    case(LOOKINGFORPUMPDATAVAL):
    debugLine += "Looking for PUMP DATA VAL";
    break;
  default:
    debugLine += "##########UNKNOWN: "+readOutStatus;
    break;
  }
  debugLine = addSpaces(debugLine, 28);
  return debugLine;
}

int convertIDToMask (int ID) {
  return ID&0xF8;
}

int decodeDestination(int dest) {
  // Returns the mask corresponding to the destination of the message
  // And sets the destinationID
  //destinationID   = dest&0x03;
  //int destinationMask = dest&0xFC;
  destinationID   = dest&0x07;
  int destinationMask = convertIDToMask(dest);
  int returnVal = -1;
  if ( destinationMask == DEV_MASTER_MASK ) {
    // MASTER                  00-03  0b0 0000 0XX    
    returnVal = DEV_MASTER_MASK;
  } else {
    switch (destinationMask) {
      // CTL 0b0 0001 0XX
      case ( DEV_CTL_MASK ) :
      returnVal = DEV_CTL_MASK;
      // XXXXX DEVICE            10-13  0b0 0010 0XX
      // XXXXX DEVICE            18-1b  0b0 0011 0XX
      break;
      // SPA 0b0 0100 0XX
      case ( DEV_SPA_MASK ) :
      returnVal = DEV_SPA_MASK;
      break;
      // RPC 0b0 0101 0XX
      case ( DEV_RPC_MASK ) :
      returnVal = DEV_RPC_MASK;
      break;
      // AQUALINK   0b0 0110 0XX
      case ( DEV_AQUALINK_MASK ) :
      returnVal = DEV_AQUALINK_MASK;
      break;
      // LX_HTR   0b0 0111 0XX
      case ( DEV_LX_HTR_MASK ) :
      returnVal = DEV_LX_HTR_MASK;
      break;
      // ONETOUCH DEVICE         40-43  0b0 1000 0XX
      case ( DEV_ONETOUCH_MASK ) :
      returnVal = DEV_ONETOUCH_MASK;
      break;
      case ( DEV_AQUARITE_MASK ) :
      returnVal = DEV_AQUARITE_MASK;
      break;
      case ( DEV_PCDOCK_MASK ) :
      returnVal = DEV_PCDOCK_MASK;
      break;
      case ( DEV_PDA_JDA_MASK ) :
      returnVal = DEV_PDA_JDA_MASK;
      break;
      case ( DEV_LXI_LRZE_MASK ) :
      returnVal = DEV_LXI_LRZE_MASK;
      break;
      case ( DEV_HEATPUMP_MASK ) :
      returnVal = DEV_HEATPUMP_MASK;
      break;
      case ( DEV_CHEMLINK_MASK ) :
      returnVal = DEV_CHEMLINK_MASK;
      break;
      case ( DEV_AQUALINK_2_MASK ) :
      returnVal = DEV_AQUALINK_2_MASK;
      break;
    default:
      returnVal = -1;
    }
  }
  lastDestinationName = getDestinationName(dest);
  //logTxt(addSpaces(lastDestinationName, LOGTXT_DESTNAMELENGTH)+" ID:"+destinationID, LOGTXT_DEST);
  if ( dest != 0 ) {
    logTxt(addSpaces(lastDestinationName, LOGTXT_DESTNAMELENGTH)+" ("+reportVal(dest, 2)+")", LOGTXT_DEST);
  } else {
    logTxt(addSpaces(lastDestinationName, LOGTXT_DESTNAMELENGTH)+" ", LOGTXT_DEST);
  }
  logTxtDestination(dest);
  return returnVal;
}

String getDestinationName(int dest) {
  int destinationMask = convertIDToMask(dest);
  String name = "UNK????";
  switch (destinationMask) {
    case ( DEV_MASTER_MASK ) :
    name = "MASTER";
    break;
    case ( DEV_CTL_MASK ) :
    name = "HOME CTL";
    break;
    case ( DEV_SPA_MASK ) :
    name = "SPA";
    break;
    case ( DEV_RPC_MASK ) :
    name = "RPC";
    break;
    case ( DEV_AQUALINK_MASK ) :
    name = "AQUALINK";
    break;
    case ( DEV_LX_HTR_MASK ) :
    name = "LX HEATER";
    break;
    case ( DEV_ONETOUCH_MASK ) :
    name = "1TOUCH";
    break;
    case ( DEV_AQUARITE_MASK ) :
    name = "AQUARITE";
    break;
    case ( DEV_PCDOCK_MASK ) :
    name = "PC DOCK ";
    break;
    case ( DEV_PDA_JDA_MASK ) :
    name = "AQUAPALM";
    break;
    case ( DEV_LXI_LRZE_MASK ) :
    name = "LXI_LRZE";
    break;
    case ( DEV_HEATPUMP_MASK ) :
    name = "HEATPUMP";
    break;
    case ( DEV_CHEMLINK_MASK ) :
    name = "CHEMLINK";
    break;
    case ( DEV_AQUALINK_2_MASK ) :
    name = "AQUALINK-2";
    break;
    case ( DEV_UNKNOWN_MASK ) :
    name = "UNKNOWN";
    break;
  default:
    name = " UNK "+reportVal(destinationMask, 2)+"";
  }
  return name;
}

String printDataBytes(int printHexValues, int printASCIIValues, int startNr, int endNr) {
  String optString = "";
  if ( startNr != endNr ) {
    // Print out the HEX values
    if ( printHexValues == 1 ) {
      for (int i=startNr; i<endNr; i++ ) {
        optString += ""+reportVal(processDataValues[i], 2)+" ";
      }
    }
    if ( printHexValues*printASCIIValues == 1 ) {
      optString += " == ";
    }
    // Print out the ASCII values
    if ( printASCIIValues == 1 ) {
      optString += "\"";
      for (int i=startNr; i<endNr; i++ ) {
        optString += getASCIIString(processDataValues[i]);
      }
      optString += "\"";
    }
  } 
  return optString;
}

int decodeResponse(int destination, int response) {
  logFilePrintln(2, "decodeResponse PROCDATABYTES RESPONSE");
  setNowDecodingResponse(1);
  if ( destination != DEV_MASTER_MASK ) {
    // We received an incorrect response
    // The Checksum could still be fine if for some reason the 0x00 Byte for the MASTER destination was dropped
    logTxt("ERROR! Received response to incorrect destination! "+reportVal(destination, 2), LOGTXT_OTHERERROR);
  }
  //int destination_MASK = decodeDestination(destination);
  logTxtArgs(processDataValuesCtr-2);
  int responseWasDecoded = processResponseToMASTER(response, destination);
  return responseWasDecoded;
}

int decodeCommand(int destination, int command) {
  //println("DECCOMM");
  lastDestination    = destination;
  lastCommand        = command;
  //println("DECODECOMMAND LASTDEST = "+reportVal(lastDestination,2));
  setNowDecodingResponse(0);
  int destination_MASK = decodeDestination(destination);
  logTxtArgs(processDataValuesCtr-2);
  int commandWasDecoded = 0;
  //println("PROCDATABYTES COMMAND + MASK="+reportVal(destination_MASK, 2));
  switch(destination_MASK) {
  case DEV_CTL_MASK:
    commandWasDecoded = processCTLCommand(command, destination);
    break;
  case DEV_SPA_MASK:
    commandWasDecoded = processSPACommand(command, destination);
    break;
  case DEV_RPC_MASK:
    commandWasDecoded = processRPCCommand(command, destination);
    break;
  case DEV_AQUALINK_MASK:
    commandWasDecoded = processAQUALINKCommand(command, destination);  
    break; 
  case DEV_LXI_LRZE_MASK:
    commandWasDecoded = processLXI_LRZECommand(command, destination);  
    break; 
  case DEV_LX_HTR_MASK:
    commandWasDecoded = processLX_HTRCommand(command, destination);  
    break; 
  case DEV_ONETOUCH_MASK:
    commandWasDecoded = processONETOUCHCommand(command, destination);
    break;
  case DEV_AQUARITE_MASK:
    commandWasDecoded = processAQUARITECommand(command, destination); 
    break; 
  case DEV_PCDOCK_MASK:
    commandWasDecoded = processPCDOCKCommand(command, destination);  
    break; 
  case DEV_PDA_JDA_MASK:
    commandWasDecoded = processPDA_JDACommand(command, destination);  
    break;
  case DEV_HEATPUMP_MASK:
    commandWasDecoded = processHEATPUMPCommand(command, destination);
    break;
  case DEV_CHEMLINK_MASK:
    commandWasDecoded = processCHEMLINKCommand(command, destination);
    break;
  case DEV_AQUALINK_2_MASK:
    commandWasDecoded = processAQUALINK_2NDCommand(command, destination);
    break;
  default:  
    if ( command == CMD_PROBE ) {
      logTxtProbe();
      return 1;
    } else {
      logTxt("Received command "+reportVal(command, 2)+" for unconfigured destination "+reportVal(destination, 2)+" with MASK: "+reportVal(destination_MASK, 2), LOGTXT_TYPE );
      logTxtData(2, processDataValuesCtr);
      return 0;
    }
  }
  if ( commandWasDecoded == 0 ) {  
    logTxt("Received command "+reportVal(command, 2)+" for destination "+lastDestinationName, LOGTXT_TYPE );
    logTxtData(2, processDataValuesCtr);
  }
  return commandWasDecoded;
}

int processReadChecksumData() {
  for ( int i=0; i<processDataValuesCtr; i++ ) {
    checkSumDataValues[i] = processDataValues[i];
  }
  checkSumDataValuesCtr = processDataValuesCtr;
  int checkSum = processChecksumData(1);
  if ( showDebug(DEBUG_ON) == 1 ) {
    logTxtLn("CALC CS = "+reportVal(checkSum, 2)+" READ CS = "+reportVal(checkSumIn, 2), LOGTXT_DEBUG);
  }
  return checkSum;
}

int processSendChecksumData(int destination) {
  checkSumDataValues[0] = destination;
  for (int i=1; i<=sendDataValuesCtr; i++ ) {
    checkSumDataValues[i] = sendDataValues[i-1];
  }
  checkSumDataValuesCtr = sendDataValuesCtr+1;
  return processChecksumData(0);
}

int processChecksumData(int validateCSValue) {
  checkSumError = 0;
  int checkSum = checkSumStart;
  checkSumErrorString = "";
  //checkSumErrorString += "CSCALC: "+reportVal(checkSum, 2);
  String CheckSumErrorTmp;
  for (int i=0; i < checkSumDataValuesCtr; i++ ) {
    checkSum += int(checkSumDataValues[i]);
    //checkSumErrorString += "+ "+reportVal(checkSumDataValues[i], 2)+" = "+reportVal(checkSum, 2);
  }
  // Cap checksum to 1 byte
  checkSum &= RS485DATAMASK;
  checkSumErrorString += reportVal(checkSum, 2)+"(C)<-->"+reportVal(checkSumIn, 2)+"(I)";
  if ( (checkSum != checkSumIn)&(validateCSValue == 1)) {
    CheckSumErrorTmp = "CHECKSUM ERROR!!! ("+checkSumDataValuesCtr+" bytes): ";
    //for (int i=0; i<checkSumDataValuesCtr; i++ ) {
    //  CheckSumErrorTmp += reportVal(checkSumDataValues[i], 2)+" ";
    //}
    checkSumErrorString = CheckSumErrorTmp+checkSumErrorString;
    checkSumError = 1;
  }
  return checkSum;
}

void logTxt(String txt, int logTxtID) {
  logTxtStrings[logTxtID][nowDecodingResponse] += txt;
  String Spaces1 = "";
  String Spaces2 = "";
  if ( nowDecodingResponse == 0 ) {
    Spaces1 = " ";
    Spaces2 = "  ";
  } else {
    Spaces1 = "  ";
    Spaces2 = " ";
  }
  logFilePrintln(2, "   logTxt "+findLogTxtID(logTxtID)+Spaces1+"nowDecodingResponse= "+nowDecodingResponse+Spaces2+" ==> "+txt);
}

boolean recordUnprocessedData( int data ) {
  logFilePrintln(3, "LOGUNPROC["+unprocessedDataBufferNr+"] ="+reportVal(data, 2));
  unprocessedData[unprocessedDataBufferNr] = data;
  unprocessedDataBufferNr++;
  if ( unprocessedDataBufferNr == NRUNPROCESSEDDATABUFFERS ) {
    //println("\nTOO MUCH UNPROC");
    reportAndDropUnprocessedData(0);
    incomingDataValuesCtr = 0;
    changeReadOutStatus(DEFAULTREADOUTSTATUS);
    return false;
  }
  return true;
}

String logPrintUnprocessedData(int stopVal) {
  logFilePrintln(3, "logPrintUnprocessedData "+nowDecodingResponse);
  String optString = printUnprocessedData(stopVal);
  if ( logTxtStrings[LOGTXT_UNPROCESSEDDATA][nowDecodingResponse] != "" ) {
    //logFilePrintln(1,"LTSUP "+logTxtStrings[LOGTXT_UNPROCESSEDDATA][nowDecodingResponse]);
    //logTxt(" | ", LOGTXT_UNPROCESSEDDATA);
    optString += " | ";
  }
  logTxt(optString, LOGTXT_UNPROCESSEDDATA);
  return optString;
}

void clearUnprocessedData(int stopVal) {  
  //  for ( int i = 0; i< unprocessedDataBufferNr; i++ ) {
  //    unprocessedData[i] = 0;
  //  }
  logFilePrintln(2, "clearUnprocessedData unprocessedDataBufferNr:"+unprocessedDataBufferNr+" STOPVAL="+stopVal);
  int i = 0;
  int bufferNr = unprocessedDataBufferNr+stopVal;
  int value ;
  String str;
  if ( (bufferNr < 0)&&(stopVal < 0) ) {
    logFilePrintln(1, "clearUnprocessedData unprocessedDataBufferNr:"+unprocessedDataBufferNr+" STOPVAL="+stopVal);
  }
  while ( (stopVal+i) < 0 ) {
    value = unprocessedData[bufferNr];
    str = "I:["+i+"]"+reportVal(unprocessedData[i], 2) + "==> ["+bufferNr+"]"+reportVal(value, 2);
    unprocessedData[i] = value;
    logFilePrintln(3, str);
    i++;
    bufferNr++;
  }  
  unprocessedDataBufferNr = i;
  // for ( int j=0; j< 2; j++ ) {
  //   logTxtStrings[LOGTXT_UNPROCESSEDDATA][j] = "";
  // }
}

int reportAndDropUnprocessedData(int stopVal) {
  logFilePrintln(2, "reportAndDropUnprocessedData "+unprocessedDataBufferNr);
  String optString = printUnprocessedData(stopVal);
  if ( optString != "" ) {
    logTxtLn("Dropping unprocessed data ("+str(unprocessedDataBufferNr+stopVal)+" Byte(s)): "+optString, LOGTXT_WARNING);
  }
  dropUnprocessedData(stopVal);
  clearDroppedPackets();
  if ( optString != "" ) {
    return 1;
  } 
  return 0;
}

void dropUnprocessedData(int stopVal) {
  logFilePrintln(2, "dropUnprocessedData "+stopVal);
  clearUnprocessedData(stopVal);
}

String printUnprocessedData(int stopVal) {
  String opt = "";
  int optIsEmpty = 1;
  logFilePrintln(2, "printUnprocessedData ("+unprocessedDataBufferNr+" + "+stopVal+" Bytes)");
  for ( int i=0; i< unprocessedDataBufferNr+stopVal; i++ ) {
    //logFilePrintln(2, "PRINTUNPROCDATA I"+i+" = "+reportVal(unprocessedData[i], 2));
    if ( unprocessedData[i] != 0x00 ) {
      optIsEmpty = 0;
    }
    opt += reportVal(unprocessedData[i], 2)+" ";
  }
  if ( optIsEmpty == 0 ) {
    opt += " == ";
    for (int i=0; i< unprocessedDataBufferNr+stopVal; i++ ) {
      opt += getASCIIString(unprocessedData[i]);
    }
    return opt;
  } else {
    return "";
  }
}

void logTxtProbe() {
  logTxt("PROBE", LOGTXT_TYPE);
  logTxtData(2, processDataValuesCtr);
}

void logTxtProbeACK() {
  logTxt("PROBE ACK", LOGTXT_TYPE);
  logTxtData(2, processDataValuesCtr);
}

void logTxtData(int startNr, int endNr) {
  if ( endNr > startNr) {
    logTxt("DATA: ", LOGTXT_DATA);
    logTxt(printDataBytes(1, 1, startNr, endNr), LOGTXT_DATA);
  }
}

void logTxtDataASCII(int startNr, int endNr) {
  if ( endNr > startNr) {
    logTxt("DATA: ", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, startNr, endNr), LOGTXT_DATA);
  }
}

void logTxtArgs( int nrArgs) {
  if ( nrArgs > 0 ) {
    logTxt("ARGS: "+nf(nrArgs, 2)+" ", LOGTXT_DETAILS);
  }
}

String getASCIIString(int txtVal) {
  String optString = "";
  if ( (txtVal > 31)&&(txtVal < 127)) {
    optString += char(txtVal);
  } else {
    optString += reportVal(txtVal, 2)+"/";
  }
  return optString;
}

void processLastBytes() {
  // Process the last bytes that were sent to processIncomingData()
  //setNowDecodingResponse(1);
  if ( logTxtStrings[LOGTXT_DEST][0] != "" ) {
    // There is data left
    logTxtLn(LOGTXT_RESP);
  }
}

void setNowDecodingResponse(int value ) {
  logFilePrintln(3, "SETNOWDECODINGRESP "+value);
  switch(value) {
  case 0:
    {
      // New status = decoding CMD, so process previous one if previous situation was the same 
      // This happens when a command (PROBE) was sent, but there was no response
      if ( nowDecodingResponse == 0 ) {
        logFilePrintln(3, "NOW DECODING ==> logTxtLn");
        logTxtLn(LOGTXT_RESP);
      }
    }
    break;
  case 1:
    {
    }
    break;
  }
  nowDecodingResponse = value;
  logFilePrintln(3, "NOW DECODING RESPONSE= "+nowDecodingResponse);
}

void logTxtDestination(int value) {
  logTxtDestinationValue[nowDecodingResponse] = value;
}

String getLogTxtStringUnprocessedCmdResp(int cmdRespCtr) {
  return logTxtStrings[LOGTXT_UNPROCESSEDDATA][cmdRespCtr];
}

void logTxtLn(String txt, int logTxtType) {
  logTxt(txt, logTxtType);
  logTxtLn(logTxtType);
}

void logTxtLn(int logTxtType) {
  logFilePrintln(2, "logTxtLn "+findLogTxtID(logTxtType));
  //------------------------------------------------------------------------------//
  //     DEST             DETAILS   TYPE         DATA                             //
  //------------------------------------------------------------------------------//
  //\==> CHEMLINK    (80) ARGS:01   CMD 0x18     DATA: H01  == "/0x01/"           //
  //\==> MASTER           ARGS:02   ACK          DATA: H18 H00  == "/0x18//0x00/" //
  //------------------------------------------------------------------------------//
  String logTxtStringCmdResp[]            = new String[2];
  String logTxtCheckSum     = "";
  String logTxtStringUnprocessedCmdResp[] = new String[2];
  //String DEST_DETAILS_Spaces = addSpaces("", LOGTXT_DESTLENGTH+LOGTXT_DETAILSLENGTH);
  String DEST_DETAILS_Spaces = addSpaces("", LOGTXT_DESTLENGTH-1) + printNumber(logTxtStringNr, MAXTXTSTRINGNRSIZE) ;
  String DEST_NODETAILS_Spaces = addSpaces("", LOGTXT_DESTLENGTH-1+MAXTXTSTRINGNRSIZE)  ;
  int showString    = 1;
  int printThisLine = 1 ;
  int thisIsNotEmptyProbe = 1;
  int containsChecksumError = 0;
  int timeStampNeeded = 0;
  switch(logTxtType) {
  case LOGTXT_RESP:
    // Check if we have empty strings (readout collisions can cause garbage data)
    //println("DEST0: >"+logTxtStrings[LOGTXT_DEST][0]+"< ==>"+logTxtStrings[LOGTXT_DEST][0].equals("")+" DEST1: >"+logTxtStrings[LOGTXT_DEST][1]+"<");
    if ( logTxtStrings[LOGTXT_DEST][0].equals("") ) {
      if (logTxtStrings[LOGTXT_DETAILS][1].equals("") ) {
        showString = 0;
      } else {
        // We found a response, but no command
        logTxtStrings[LOGTXT_DEST][0] = "NO COMMAND FOUND";
      }
    }
    // Don't show unresponded probe commands
    if ( (displayThisOption("dontShowEmptyProbes") )&&(logTxtStrings[LOGTXT_TYPE][0].equals("PROBE"))&&(nowDecodingResponse == 0) ) {
      thisIsNotEmptyProbe    = 0;
    }
    timeStampNeeded = 1;
    int noErrorinCmdResp;
    for ( int cmdRespCtr = 0; cmdRespCtr < 2; cmdRespCtr++ ) {
      noErrorinCmdResp = 1;
      logTxtStringCmdResp[cmdRespCtr]     = logTxtStringTxtCmdResp[cmdRespCtr]+"=> ";
      // Check for CheckSumErrors
      if ( !logTxtStrings[LOGTXT_CHECKSUMERROR][cmdRespCtr].equals("") ) {
        // We have a CMD checksum error, don't decode stuff
        noErrorinCmdResp      = 0;
        containsChecksumError = 1;
        logTxtStringCmdResp[cmdRespCtr]             += addSpaces(logTxtStrings[LOGTXT_DEST][cmdRespCtr]+" ", LOGTXT_DESTLENGTH) + logTxtStrings[LOGTXT_CHECKSUMERROR][cmdRespCtr];
      } 
      // Check for other errors
      if ( !logTxtStrings[LOGTXT_OTHERERROR][cmdRespCtr].equals("") ) {
        // We have a CMD checksum error, don't decode stuff
        if ( noErrorinCmdResp == 0 ) {
          // We already have an error recorded, start a newline
          logTxtStringCmdResp[cmdRespCtr]             += "\n"+logTxtStringTxtCmdResp[cmdRespCtr]+"=> ";
        }
        noErrorinCmdResp = 0;
        logTxtStringCmdResp[cmdRespCtr]             += logTxtStrings[LOGTXT_OTHERERROR][cmdRespCtr];
      }
      if ( noErrorinCmdResp == 1 ) {
        logTxtStringCmdResp[cmdRespCtr]             += addSpaces(logTxtStrings[LOGTXT_DEST][cmdRespCtr]+" ", LOGTXT_DESTLENGTH)+addSpaces(logTxtStrings[LOGTXT_DETAILS][cmdRespCtr]+" ", LOGTXT_DETAILSLENGTH) + addSpaces(logTxtStrings[LOGTXT_TYPE][cmdRespCtr]+" ", LOGTXT_TYPELENGTH) + logTxtStrings[LOGTXT_DATA][cmdRespCtr];
      }
      if ( displayThisOption("addCSValueToLogTxt") ) {
        logTxtStringCmdResp[cmdRespCtr]             += " CS=" + logTxtStrings[LOGTXT_CHECKSUM][cmdRespCtr]+" ";
      }
      logTxtStringUnprocessedCmdResp[cmdRespCtr]    = getLogTxtStringUnprocessedCmdResp(cmdRespCtr);
      logTxtCheckSum                                += " "+logTxtStrings[LOGTXT_CHECKSUM][cmdRespCtr];
    }
    logTxtString                = logTxtStringCmdResp[0]+logTxtStringCmdResp[1];
    // Clear all the logTxt strings
    for ( int i=0; i< 2; i++ ) {
      logTxtStrings[LOGTXT_UNPROCESSEDDATA][i] = "";
      logTxtStrings[LOGTXT_DEST][i]            = "";
      logTxtStrings[LOGTXT_DETAILS][i]         = "";
      logTxtStrings[LOGTXT_TYPE][i]            = "";
      logTxtStrings[LOGTXT_DATA][i]            = "";
      logTxtStrings[LOGTXT_CHECKSUMERROR][i]   = "";
      logTxtStrings[LOGTXT_CHECKSUM][i]        = "";
      logTxtStrings[LOGTXT_OTHERERROR][i]      = "";
    }
    showString &= displayThisDevice(logTxtDestinationValue[0]);
    if ( (displayThisOption("suppressChecksumErrors") )&&( containsChecksumError == 1) ) {
      showString = 0 ;
    }
    // Don't show empty probe commands
    showString &= thisIsNotEmptyProbe;
    // Write values to Value log file
    writeValuesToLogFile(0);
    break;
  case LOGTXT_INFO:
    if ( !displayThisOption("suppressReadoutInfo") ) {
      logTxtString = DEST_DETAILS_Spaces + " INFO:  "+logTxtStrings[LOGTXT_INFO][nowDecodingResponse];
      // Clear  the logTxt strings
      for ( int i=0; i< 2; i++ ) {
        logTxtStrings[LOGTXT_INFO][i] = "";
      }
    } else {
      printThisLine = 0;
    }

    break;
  case LOGTXT_ERROR:
    if ( !displayThisOption("suppressReadoutErrors")  ) {
      logTxtString = DEST_DETAILS_Spaces + " ERROR!:"+logTxtStrings[LOGTXT_ERROR][nowDecodingResponse];
    } else {
      printThisLine = 0;
    }
    // Clear  the logTxt strings
    for ( int i=0; i< 2; i++ ) {
      logTxtStrings[LOGTXT_ERROR][i] = "";
    }
    break;
  case LOGTXT_WARNING:
    if ( !displayThisOption("suppressReadoutWarnings") ) {
      if ( logTxtStrings[LOGTXT_UNPROCESSEDDATA][nowDecodingResponse] == "" ) {
        logFilePrintln(2, "UPDATE PRINTUNPROCDATA FOR LOGTXT_WARNING!");
        logPrintUnprocessedData(0);
      }
      logTxtString =  DEST_DETAILS_Spaces + " WARNING!:"+logTxtStrings[LOGTXT_WARNING][nowDecodingResponse]+"\n";
      logTxtString += DEST_NODETAILS_Spaces + " 0>" + getLogTxtStringUnprocessedCmdResp(0) + "\n";
      logTxtString += DEST_NODETAILS_Spaces + " 1>" + getLogTxtStringUnprocessedCmdResp(1) ;
    } else {
      printThisLine = 0;
    }
    // Clear  the logTxt strings
    for ( int i=0; i< 2; i++ ) {
      logTxtStrings[LOGTXT_WARNING][i] = "";
    }
    break;
  case LOGTXT_DEBUG:
    logTxtString = DEST_DETAILS_Spaces + " DEBUG:"+logTxtStrings[LOGTXT_DEBUG][nowDecodingResponse];
    // Clear  the logTxt strings
    for ( int i=0; i< 2; i++ ) {
      logTxtStrings[LOGTXT_DEBUG][i] = "";
    }
    break;
  default:
    logTxtString = "!!!ERROR!!!: Unknown logTxtType:"+logTxtType;
  }

  // Add time info and check if we need  to print
  // Update times
  //if ( timeStampNeeded == 1 ) {
  //  updateProcessedTimeDelta();
  //}
  // Check for repeat strings
  String nrLoggedNewTextStringsNrString = "____";
  String logTxtStringTmp = logTxtString+logTxtCheckSum;
  if ((displayThisOption("onlyShowNewStrings") )&&(logTxtType != LOGTXT_DEBUG)) {
    for ( int i=0; i< nrLoggedNewTextStrings; i++ ) {
      if ( logTxtStringTmp.equals(loggedTxtStrings[i]) == true ) {
        showString =0;
      }
    }
    if ( showString == 1 ) {
      nrLoggedNewTextStringsNrString = printNumber(nrLoggedNewTextStrings, MAXTXTSTRINGNRSIZE);
      loggedTxtStrings[nrLoggedNewTextStrings] = logTxtStringTmp;
      nrLoggedNewTextStrings++;
      if ( nrLoggedNewTextStrings >= MAXNRLOGGEDTXTSTRINGS ) {
        nrLoggedNewTextStrings = 0;
      }
    }
  }
  if ( showString == 1 ) {
    // compile time and log text strings
    // Update times
    String logTimeStr = "";
    if ( timeStampNeeded == 1 ) {
      updateShowtime();
      if ( displayThisOption("showTimeDeltas") ) {
        //"    37 /      26 /"
        logTimeStr += printNumber(int(showTimeMicroDelta)/TIMESTAMPMULTIPLIER, MAXTIMEDELTASIZE)+" / "+printNumber(int(processedTimeDelta[0])/TIMESTAMPMULTIPLIER, MAXTIMEDELTASIZE)+" / ";
      }    
      //"    37 /      26 /      8 /    8 "
      logTimeStr += printNumber(logTxtStringNr, MAXTXTSTRINGNRSIZE)+" / "+nrLoggedNewTextStringsNrString+" | ";
    }
    String logTimeStrSpaces;
    if ( displayThisOption("showTimeDeltas") ) {
      logTimeStrSpaces = addSpaces(addSpaces("", MAXTIMEDELTASIZE+3)+printNumber(int(processedTimeDelta[1])/TIMESTAMPMULTIPLIER, MAXTIMEDELTASIZE)+"", logTimeStr.length());
    } else {
      logTimeStrSpaces = addSpaces("", logTimeStr.length());
    }
    String logTimeStrSpacesEmpty = addSpaces("", logTimeStr.length()-2);
    if ( displayThisOption("showRawIncomingHexData") ) {
      if ( rawIncomingDataNeedsNewline == 1 ) {
        logTimeStr = "\n"+logTimeStr;
        rawIncomingDataNeedsNewline = 0;
      }
    }
    if ( logTxtType== LOGTXT_RESP ) {
      // Add unprocessed string values
      // ADD COMMAND VALUES
      logTxtString = logTimeStr;
      if ( displayThisOption("showUnprocessedData") ) {
        logTxtString += logTxtStringUnprocessedCmdResp[0]+"\n"+logTimeStrSpacesEmpty+" \\";
      }
      logTxtString += logTxtStringCmdResp[0];
      if ( displayThisOption("showCommandResponse") ) { 
        // ADD RESPONSE VALUES
        if (nowDecodingResponse == 1 ) {
          logTxtString += "\n"+logTimeStrSpaces;
          if ( displayThisOption("showUnprocessedData") ) {
            logTxtString += logTxtStringUnprocessedCmdResp[1]+"\n"+logTimeStrSpacesEmpty+" \\";
          }
          logTxtString += logTxtStringCmdResp[1];
        } else {
          unansweredCommands += 1;
        }
      }
    } else {
      logTxtString = logTimeStr+logTxtString;
    }
    if ( displayThisOption("addSpaceBetweenDevices") ) {
      logTxtString += "\n";
    }
    if ( debugThis(DEBUG_ALWAYSPRINTLOGTXTSTRINGNUMBERS) ) { 
      logFilePrintln(1, "#==> "+logTxtStringLnCount+ " "+processedByteCounterTotal+"B");
      logTxtStringLnCount++;
    }
    if ( printThisLine == 1 ) {
      if ( displayThisOption("printDataToScreen") ) {
        println(logTxtString);
      }
      logFileHandle.println(logTxtString);
    } else {
      if ( showDebug(DEBUG_ON) == 1 ) {
        logFileHandle.println("logTxtLn PRINTTHISLINE = 0");
      }
    }
  }
  logTxtString = "";
  if ( logTxtType== LOGTXT_RESP ) {
    logTxtStringNr++;
  }
}

void logFilePrintln(int debugLevel, String txt) {
  logFilePrint(debugLevel, txt+"\n");
}

void logFilePrint(int debugLevel, String txt) {
  if ( displayThisOption("showVerboseDataInLog")) {
    if ( verboseDataDebugLevel >= debugLevel ) {
      if ( rawIncomingDataNeedsNewline == 1 ) {
        txt = "\n"+txt;
        rawIncomingDataNeedsNewline = 0;
      }
      print(txt);
      logFileHandle.print(txt);
    }
  }
}

String printNumber(int num, int length) {
  String numStr = str(num);
  return addSpaces("", length-numStr.length())+num;
}

int displayThisDevice( int destination ) {
  logFilePrint(2, "displayThisDevice DEST = "+reportVal(destination, 2));
  int displayDevice = 0;
  if (deviceDisplayMasksCtr == 0) {
    displayDevice = 1;
  } else {
    for (int i=0; i< deviceDisplayMasks.length; i++ ) {
      if ( deviceDisplayMasks[i] == destination ) {
        displayDevice = 1;
      }
    }
  }
  logFilePrintln(2, " ==> " + displayDevice);
  return displayDevice;
}

String addSpaces(String Str, int nrOfSpaces) {
  int nrSpacesAdded = nrOfSpaces-Str.length();
  for (int i=0; i< nrSpacesAdded; i++ ) {
    Str += " ";
  }
  return Str;
}

void timeStamp(String str) {
  currentMicroTimeStamp = getAccurateMicroTime();
  timeStampDelta = currentMicroTimeStamp-lastMicroTimeStamp;
  lastMicroTimeStamp = currentMicroTimeStamp;
  logFilePrintln(0, " TimeStamp Delta: "+addSpaces(str(timeStampDelta), 7)+" ==> "+str);
  println(" TimeStamp Delta: "+addSpaces(str(timeStampDelta), 7)+" ==> "+str);
}

int buttStat(int expectedDataSize, int[] buttonTest, int startPos, int endPos ) {
  int buttonPos  = buttonTest[0];
  int buttonMask = buttonTest[1]; 
  int dataSize = endPos - startPos;
  // Only accept 'expectedDataSize' data Bytes, anything else means there's an issue
  if ( dataSize != expectedDataSize ) {
    logTxtLn("Incorrect Nr "+dataSize+" of data bytes for buttStat() START = "+startPos+" END = "+endPos, LOGTXT_WARNING);
    return 0;
  }
  int testVal = int((processDataValues[buttonPos+startPos] & buttonMask) != 0 );
  return testVal ;
}

boolean debugThis(int debugType) {
  if ( (debug & debugType) == debugType ) {
    return true;
  } else {
    return false;
  }
}

void addDeviceDisplayMask(int displayMask) {
  if ( deviceDisplayMasksCtr == MAXNRDEVICEDISPLAYMASKS ) {
    println("Warning! Max # Device Display Masks ("+MAXNRDEVICEDISPLAYMASKS+") exceeded!");
  } else {
    deviceDisplayMasks[deviceDisplayMasksCtr] = displayMask;
    deviceDisplayMasksCtr++;
  }
}

void initDeviceDisplayMasks() {
  deviceDisplayMasksList = "Device Display Masks      = ";
  for ( int i = 0; i< deviceDisplayMasksCtr; i++ ) {
    deviceDisplayMasksList += reportVal(deviceDisplayMasks[i], 2) + " ";
  }
}

long updateCurrentByteTimestamp(long timeStampMicro) {
  //print("TS: "+timeStampMicro);
  if ( timeStampMicro < 0 ) {
    // Generate timestamp for log
    currentByteTimeStampMicroTime  = getAccurateMicroTime()   - initByteTimeStampMicroTime;
    logTimeStampMicroDelta         = currentByteTimeStampMicroTime - lastLogTimeStampMicroTime;
    lastLogTimeStampMicroTime      = currentByteTimeStampMicroTime;
  } else {
    logTimeStampMicroDelta         = timeStampMicro;
    currentByteTimeStampMicroTime += logTimeStampMicroDelta;
    //print("CBTST: "+currentByteTimeStampMicroTime);
  }
  //print(" DELTA: "+logTimeStampMicroDelta);
  // Update "Current time"
  lastReceivedByteTimeMicro += logTimeStampMicroDelta;
  //println("LRBT: "+lastReceivedByteTimeMicro);
  return logTimeStampMicroDelta;
}

void updateShowtime() {
  lastShowTimeMicro    = currentShowTimeMicro;
  currentShowTimeMicro = lastReceivedByteTimeMicro;
  //println("LST: "+lastShowTimeMicro+" CST: "+currentShowTimeMicro);
  showTimeMicroDelta   = lastReceivedByteTimeMicro-lastShowTimeMicro;
  //println("UPDSHOWTIME "+showTimeMicroDelta+" LRBT: "+lastReceivedByteTimeMicro);
}

void updateProcessedTimeDelta() {
  processedTimeDelta[nowDecodingResponse]            = lastReceivedByteTimeMicro - previouslastReceivedByteTimeMicro ;
  previouslastReceivedByteTimeMicro  = lastReceivedByteTimeMicro;
  //println("PROCTIMEDELTA: "+nowDecodingResponse+" ==> "+processedTimeDelta[nowDecodingResponse]+" LRBT: "+lastReceivedByteTimeMicro);
}

void addValueToLogfile(int valueID) {
  reportValuesInLogfile |= valueID;
}

void writeValuesToLogFile(int init) {
  String logStringTime;
  String logString ="";
  String readOutValuesText = "";

  if ( init == 0) {
    logStringTime = addSpaces(str(currentByteTimeStampMicroTime), LOG_VALUE_TIMESTAMPWIDTH);
  } else {
    logStringTime = addSpaces(LOG_TIME_NAME, LOG_VALUE_TIMESTAMPWIDTH);
  }
  if ( includeValueinLogFile(LOG_ORP_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += "ORP  = " + addSpaces(LOG_ORP_VAL + " " + LOG_ORP_UNIT, LOG_VAL_SPACES)+ "\n";
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_ORP_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_ORP_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( includeValueinLogFile(LOG_PH_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += "PH   = " + addSpaces(LOG_PH_VAL + LOG_PH_UNIT, LOG_VAL_SPACES);
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PH_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PH_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }   
  if ( LOG_SALT_ENABLED ) {
    readOutValuesText += "\nSALT = ";
  }
  if ( includeValueinLogFile(LOG_SALTPPM_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += addSpaces(LOG_SALTPPM_VAL + " " + LOG_SALTPPM_UNIT + " ", LOG_VAL_SPACES);
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_SALTPPM_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_SALTPPM_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( includeValueinLogFile(LOG_SALTPCT_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += addSpaces(LOG_SALTPCT_VAL + LOG_SALTPCT_UNIT, LOG_VAL_SPACES);
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_SALTPCT_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_SALTPCT_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( LOG_PUMP_ENABLED ) {
    readOutValuesText += "\nPUMP = ";
  }
  if ( includeValueinLogFile(LOG_PUMPGPM_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += addSpaces(LOG_PUMPGPM_VAL+ " " + LOG_PUMPGPM_UNIT + " ", LOG_VAL_SPACES) ;
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PUMPGPM_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PUMPGPM_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( includeValueinLogFile(LOG_PUMPRPM_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += addSpaces(LOG_PUMPRPM_VAL + " " + LOG_PUMPRPM_UNIT + " ", LOG_VAL_SPACES);
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PUMPRPM_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PUMPRPM_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( includeValueinLogFile(LOG_PUMPWATT_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += " " + addSpaces(LOG_PUMPWATT_VAL + " " + LOG_PUMPWATT_UNIT, LOG_VAL_SPACES);
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PUMPWATT_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_PUMPWATT_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( LOG_TEMP_ENABLED ) {
    readOutValuesText += "\n";
  }
  if ( includeValueinLogFile(LOG_AIRTEMP_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += "AIR  = " + addSpaces(LOG_AIRTEMP_VAL + " " + LOG_AIRTEMP_UNIT + " ", LOG_VAL_SPACES) + "\n";
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_AIRTEMP_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_AIRTEMP_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( includeValueinLogFile(LOG_POOLTEMP_INCLUDE) ) {
    if ( init == 0) {
      readOutValuesText += "POOL = " + addSpaces(LOG_POOLTEMP_VAL + " " + LOG_POOLTEMP_UNIT, LOG_VAL_SPACES);
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_POOLTEMP_VAL, LOG_VALUE_COLUMWIDTH);
    } else {
      logString += LOG_VALUE_SEPARATOR+addSpaces(LOG_POOLTEMP_NAME, LOG_VALUE_COLUMWIDTH);
    }
  }
  if ( (displayThisOption("onlyReportNewValuesinLog") == false) | (logString.equals(lastValuesLogString) == false) ) {
    valuesLogFileHandle.println(logStringTime + logString);
  }
  lastValuesLogString = logString;
  if ( init == 0 ) {
    updateReadoutValuesText(readOutValuesText);
  }
//  println("LS: "+logString);
}

boolean includeValueinLogFile(int valueMask) {
  
  if ( (reportValuesInLogfile&valueMask) == valueMask ) {
    return true;
  } else {
    return false;
  }
}

String reportVal(int value, int nr) {
  String opt = "";
  if ( !displayThisOption("reportDataInDecimal") ) {
    opt = "H"+hex(value, nr);
  } else {
    opt = "D"+nf(value, nr);
  }
  return opt;
}

String reportValx(int value, int nr) {
  String opt = "";
  opt = "0x"+hex(value, nr);
  return opt;
}

boolean areWeEmulatingPowerCenter() {
  if ( emulatePowerCenterIDsCtr > 0 ) {
    return true;
  } else {
    return false;
  }
}

boolean areWeReadingRawLogFile() {
  if ( readFileData > 0 ) {
    return true;
  } else {
    return false;
  }
}

boolean areWeReplayingRawLogFile() {
  if ( readFileData > 1 ) {
    return true;
  } else {
    return false;
  }
}

void readRawLogFile() {
  logTxtLn("Reading and processing RAW log File", LOGTXT_INFO);
  rawLogFileHasBeenRead = 1;
  rawLogFileHasTimestamp = 0;
  try {
    rawLogFileReadLine = logFileReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    rawLogFileReadLine = null;
  }
  int noData = 0;
  if (rawLogFileReadLine == null) {
    // Something is wrong
    println("Whoops, the file "+logFileNameBase+RAWLogFileExtension+" seems to be empty!");
    noData = 1;
  } else {
    if ( rawLogFileReadLine.equals(RAWLOGFILEHEADER) ) {
      rawLogFileHasTimestamp = 1;
      try {
        rawLogFileReadLine = logFileReader.readLine();
      } 
      catch (IOException e) {
        println("Oh Oh!");
        e.printStackTrace();
        rawLogFileReadLine = null;
      }
      if (rawLogFileReadLine == null) {
        // Something is wrong
        println("Whoops, the file "+logFileNameBase+RAWLogFileExtension+" seems to be empty past the TIMESTAMP header!");
        noData = 1;
      }
    }
    if ( noData == 1 ) {
      rawLogFileNrBytes = 0;
      rawLogFileDataLength = 0;
    } else {
      rawLogFileData = split(rawLogFileReadLine, " ");
      if ( rawLogFileHasTimestamp == 1 ) {
        rawLogFileIncr = 2;
        // Make the data length number even
        rawLogFileNrBytes = rawLogFileData.length/2;
        logTxtLn("Reading "+showHumanReadable(rawLogFileNrBytes)+" RAW log file entries with timestamp", LOGTXT_INFO);
        rawLogFileDataLength = rawLogFileNrBytes*2;
      } else {
        rawLogFileIncr = 1;
        rawLogFileNrBytes = rawLogFileData.length;
        rawLogFileDataLength = rawLogFileNrBytes;
        logTxt("Reading "+showHumanReadable(rawLogFileNrBytes)+" RAW log file entries without timestamp", LOGTXT_INFO);
        logTxtLn(" INCR: "+rawLogFileIncr, LOGTXT_INFO);
      }
    }
  }
}

long getAccurateMilliTime() {
  long accuTime = System.nanoTime()/1000000;
  return accuTime;
}

long getAccurateMicroTime() {
  long accuTime = System.nanoTime()/1000;
  return accuTime;
}

void processRAWLogFileUntilRefreshTimeMicroUpdate() {
  nextRefreshTimeMicro = getAccurateMicroTime() + REFRESHTIMEMICROUPDATE;
  initReplayStatistics();
  if ( (displayThisOption("useRefreshTime"))&&(processSingleRAWFile)) {
  }
  if ( (displayThisOption("useRefreshTime"))) {
    while ( (getAccurateMicroTime () < nextRefreshTimeMicro)&&(processNextRAWLogFilePortion()) ) {
      // Keep looping until we break for a timeout or processNextRAWLogFilePortion() returns false (button click or EOF)
    }
  } else {
    while (processNextRAWLogFilePortion() ) {
        flushLogFiles();
    };
  }
  printReplayStatistics();
}

boolean processNextRAWLogFilePortion() {
  // Retuns tue if we aren't finished and need to continue the loop
  int processedCommandResponse = 0;
  // Are we still waiting on a delay?
  if ( waitingForReplayDelay ) {
    if ( getAccurateMilliTime() > replayDelayEndTime ) {
      //println("D");
      waitingForReplayDelay = false;
    } else {
      return true; // Waiting
    }
  }
  // Waiting for a Click?
  if ( waitingForNextStepClick == 0 ) {
    long nrProcessedAtOnce = 0;
    // Process the data until the end of a command/response is reached
    while ( (rawLogFileDataPosition < rawLogFileDataLength )&( processedCommandResponse == 0)&(nrProcessedAtOnce < MAXNRPROCESSEDATONCE) ) {
      //println("RLP: "+rawLogFileDataPosition+" RLFDL: "+rawLogFileDataLength+" PRCR: "+processedCommandResponse);
      if ( rawLogFileHasTimestamp == 1) {
        rawLogFileTimestampDelta = Long.parseLong(rawLogFileData[rawLogFileDataPosition]);
        rawLogFileDataVal = int(rawLogFileData[rawLogFileDataPosition+1]);
      } else {
        rawLogFileTimestampDelta = TIMESTAMPMULTIPLIER;
        //println("INT: "+rawLogFileData[rawLogFileDataPosition]+" ==> "+int(rawLogFileData[rawLogFileDataPosition]));
        rawLogFileDataVal = int(rawLogFileData[rawLogFileDataPosition]);
      }
      rawLogFileDataPosition += rawLogFileIncr;
      if ( readFileData > 1 ) {
        // We are replaying the previous logFile
        currentOpenPort.write(rawLogFileDataVal);
      }
      if ( processIncomingData(rawLogFileTimestampDelta, rawLogFileDataVal) ) {
        // We finished a Command or Response
        processedCommandResponse = 1;
        if ( readFileData > 1 ) {
          startReplayDelay();
        }
        if ( showDisplayOptions == 1 ) {
          if ( displayThisOption("useSteppedReplay") ) {
            if ( displayThisOption("toggleSteppedReplay") ) {
              waitingForNextStepClick = 1-displayToggleButtonState;
            } else { 
              waitingForNextStepClick = 1;
            }
          }
        }
      }
      nrProcessedAtOnce++;
    }
    if ( rawLogFileDataPosition >= rawLogFileDataLength ) {
      // End of Log File
      finishProcessingRAWLogFile();
      return false;
    } else {
      if (nrProcessedAtOnce >= MAXNRPROCESSEDATONCE) {
        return false;
      } else {
        // processedCommandResponse == 1
        // We can keep going
        return true;
      }
    }
  }
  // Waiting for next click, so return fals, which breaks the draw() loop
  return false;
}

void startReplayDelay() {
  //println("SRPDL "+getAccurateMilliTime());
  waitingForReplayDelay = true;
  replayDelayEndTime = getAccurateMilliTime() + replayDelay;
}

void finishProcessingRAWLogFile() {
  // We reached the end of the logFileData
  processLastBytes();
  logTxtLn("Processed "+showHumanReadable(rawLogFileNrBytes)+"B of pool data", LOGTXT_INFO );
  setDrawMode(DRAW_FINISH_FILES);
}

String showLastDigits(long value, int numbers) {
  long divider = round(pow(10, numbers));
  long tmp     = value / divider;
  //print("V: "+value+" T1 "+tmp+" D: "+divider+" T2 "+tmp+" ");
  tmp          = tmp * divider;
  return  printNumber(int(value - tmp), numbers);
}

int compareMessage( int startPos, int msgLength, String message ) {
  int validMessage = 1;
  for ( int i = 0; i < msgLength; i++ ) {
    if ( char(incomingDataValues[i + startPos]) != message.charAt(i) ) {

      //Serial.print(char(incomingDataValues[i+startPos]));
      //Serial.print("!=");
      //Serial.println(message[i]);

      validMessage = 0;
    }
  }
  return validMessage;
}

int readTemp ( int startPos ) {
  int temp;
  temp = ascii2Value(incomingDataValues[startPos]) * 100;
  startPos ++;
  temp += ascii2Value(incomingDataValues[startPos]) * 10;
  startPos ++;
  temp += ascii2Value(incomingDataValues[startPos]);
  return temp;
}

int ascii2Value(int asciiVal) {
  if ( asciiVal == ASCIISPACECHAR ) {
    // This is a space
    return 0;
  } else {
    asciiVal -= 0x30;
    return asciiVal;
  }
}

String findLogTxtID(int id ) {
  String opt;
  switch(id) {
    case(LOGTXT_UNPROCESSEDDATA):
    opt = "LOGTXT_UNPROCESSEDDATA";
    break;
    case(LOGTXT_DEST):
    opt = "LOGTXT_DEST";
    break;
    case(LOGTXT_DETAILS):
    opt = "LOGTXT_DETAILS";
    break;
    case(LOGTXT_TYPE):
    opt = "LOGTXT_TYPE";
    break;
    case(LOGTXT_DATA):
    opt = "LOGTXT_DATA";
    break;
    case(LOGTXT_RESP):
    opt = "LOGTXT_RESP";
    break;
    case(LOGTXT_CHECKSUMERROR):
    opt = "LOGTXT_CHECKSUMERROR";
    break;
    case(LOGTXT_CHECKSUM):
    opt = "LOGTXT_CHECKSUM";
    break;
    case(LOGTXT_OTHERERROR):
    opt = "LOGTXT_OTHERERROR";
    break;
    case(LOGTXT_WARNING):
    opt = "LOGTXT_WARNING";
    break;
    case(LOGTXT_ERROR):
    opt = "LOGTXT_ERROR";
    break;
    case(LOGTXT_INFO):
    opt = "LOGTXT_INFO";
    break;
    case(LOGTXT_DEBUG):
    opt = "LOGTXT_DEBUG";    
    break;
  default:
    opt = "UNKNOWN ID";
  }
  return addSpaces(opt, 22);
}

void initReplayStatistics() {
  if ( displayThisOption("printReplayStatistics") ) {
    long replayTime0Delta = replayTime0;
    replayTime0 = getAccurateMicroTime();
    replayTime0Delta = replayTime0 - replayTime0Delta;
    println("SRPL T0: "+replayTime0+" ==> "+showLastDigits(replayTime0, 6)+" (+"+printNumber(int(replayTime0Delta), 6)+") ");
  }
}

void printReplayStatistics() {
  if ( displayThisOption("printReplayStatistics") ) {
    long replayTimeD = getAccurateMicroTime();
    print(" T1: "+replayTimeD+" ==> "+showLastDigits(replayTimeD, 6));
    replayTimeD -= replayTime0;
    println(" DELTA: "+replayTimeD+" (RPL DEL= "+replayDelay+")" );
  }
}

void runDrawDebugStuff() {
  if ( displayThisOption("pulseDrawWithZeros") ) {
    currentOpenPort.write(0x00);
    if ( debugThis(DEBUG_PULSEDRAWWITHZEROS) ) {
      println("==== DRAW ====");
    }
  }
}

void setDrawMode(int mode) {
  //println("SDRWM: "+mode);
  drawMode = mode;
}

void gotoNextRawLogFile() {
  if ( rawLogFileReadNameBaseNr < rawLogFileReadNameBaseNrOfFiles ) {
    setDrawMode(DRAW_INIT_FILES);
  } else {
    if ( readFileData == 3 ) {
      //Repeat
      rawLogFileReadNameBaseNr = 0;
      setDrawMode(DRAW_INIT_FILES);
    } else {
      println("DONE!");
      noLoop();
    }
  }
}

int doNothing(int doNothingWithThisValue) {
  return doNothingWithThisValue;
}