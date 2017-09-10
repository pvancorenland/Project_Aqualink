//TODO:
//  315 /       0 /    448 / ____ | H00 H10 H02 H41 H10 H00 <ESCAPE H00 H0D H0F H02 H81 H10 H03 
//                                     \==> 1TOUCH         (H41) ARGS:04   Received command 0xH10 for destination 1TOUCH DATA: H00 H0D H0F H02  == "H00/H0D/H0F/H02/"
// After turning the heater on
// 9769 /     119 /   2116 /     24 | ==> 1TOUCH         (H41) ARGS:05   STATUS       DATA: H00 H00 H00 H10 H01  == "H00/H00/H00/H10/H01/"
//              0                     ==> MASTER               ARGS:02   ACK          DATA: H00 H00  == "H00/H00/"
// Turning the heater off
// 7367 /     124 /    451 /     20 | ==> 1TOUCH         (H41) ARGS:05   STATUS       DATA: H00 H00 H00 H00 H00  == "H00/H00/H00/H00/H00/"
//              0                     ==> MASTER               ARGS:02   ACK          DATA: H00 H00  == "H00/H00/"

//Onetouch command 0x10
// Arg0: line#
// Arg1: start textpos
// Arg2: end textpos
// Arg3: 0x00 = clear
//       0x04 = highlight
// ONETOUCH Commands
final int CMD_ONETOUCH_PROBE          = CMD_PROBE;    //0x00
final int CMD_ONETOUCH_STATUS         = CMD_STATUS;   //0x02
final int CMD_ONETOUCH_MSG            = CMD_MSG;      //0x03
final int CMD_ONETOUCH_MSG_LONG       = CMD_MSG_LONG; //0x04
final int CMD_ONETOUCH_0x05           = 0x05;
final int CMD_ONETOUCH_HIGHLIGHT      = 0x08;
final int CMD_ONETOUCH_CLEAR          = 0x09;
final int CMD_ONETOUCH_SHIFTLINES     = 0x0F;
final int CMD_ONETOUCH_HIGHLIGHTCHARS = 0x10;

int processONETOUCHCommand(int command, int destination) {
  int validCommand = processONETOUCHCommandIsValid(command);
  if ( validCommand == 1 ) {
    emulateONETOUCH(command, destination);
  }
  return validCommand;
}

int processONETOUCHCommandIsValid(int command) {
  switch(command) {
    case(CMD_ONETOUCH_PROBE):
    logTxtProbe();
    return 1;
  case CMD_ONETOUCH_MSG_LONG:
    logTxt("MESSAGE", LOGTXT_TYPE);
    logTxt("LINE "+processDataValues[2]+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    return 1;
  case CMD_ONETOUCH_STATUS:
    logTxt("STATUS", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  case CMD_ONETOUCH_0x05:
    logTxt("CMD 0x05", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  case CMD_ONETOUCH_HIGHLIGHT:
    logTxt("HIGHLIGHT", LOGTXT_TYPE);
    logTxt(checkONETOUCHDisplayStatus(2, processDataValuesCtr), LOGTXT_DATA);
    logTxtData(3, processDataValuesCtr);
    return 1;
  case CMD_ONETOUCH_CLEAR:
    logTxt("CLEAR SCREEN", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  case CMD_ONETOUCH_SHIFTLINES:
    logTxt("SHIFT LINES", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  case CMD_ONETOUCH_HIGHLIGHTCHARS:
    logTxt("HIGHLIGHT CHARS", LOGTXT_TYPE);
    logTxt(processONETOUCHHighlightChars(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
  default:
    return 0;
  }
}

String checkONETOUCHDisplayStatus( int startPos, int endPos) {
  doNothing(endPos);
  String returnVal = "";
  int highLightLineNr = processDataValues[startPos];
  if ( highLightLineNr > 0) {
    returnVal += "Highlight Line #"+highLightLineNr+" ";
  }
  return returnVal;
}

int processONETOUCHResponse(int deviceID, int command, int response, int startNr, int endNr) {
  int emulatePowerCenterIDsNr = findEmulatePowerCenterIDsNr(deviceID);
  // IS THIS NEEDED??????????
  /*
  if ( emulatePowerCenterIDsNr >=0 ) {
   return 0;
   }
   */
  //println("processONETOUCHResponse "+reportVal(deviceID, 2)+" "+reportVal(command, 2)+" "+reportVal(response, 2));
  //String initString = "";
  switch(command) {
    case (CMD_ONETOUCH_0x05):
    if ( response == CMD_ACK) {
      return processONETOUCH_0x05_response(deviceID, startNr, endNr);
    } else {
      unknownResponse( deviceID, command, response, startNr, endNr);
      return 0;
    }
    case (CMD_ONETOUCH_MSG_LONG):
    if ( response == CMD_ACK) {
      if ( weAreEmulatingPowerCenter() == 1 ) {
        ONETOUCHEMUMessageLineNr++;
        if ( ONETOUCHEMUMessageLineNr == 12 ) {
          ONETOUCHEMUMessageLineNr = 0;
          setEmulatorRunStage(deviceID, 3);
        }
      }
      return 1;
    } else {
      unknownResponse( deviceID, command, response, startNr, endNr);
      return 0;
    }
    case (CMD_ONETOUCH_HIGHLIGHT):
    if ( response == CMD_ACK) {
      setEmulatorRunStage(deviceID, 4);
      return 1;
    } else {
      unknownResponse( deviceID, command, response, startNr, endNr);
      return 0;
    }
    case (CMD_ONETOUCH_HIGHLIGHTCHARS):
    if ( response == CMD_ACK) {
      //??????????????????? NEEDED?
      setEmulatorRunStage(deviceID, 4);
      return 1;
    } else {
      unknownResponse( deviceID, command, response, startNr, endNr);
      return 0;
    }
    case (CMD_ONETOUCH_STATUS):
    processONETOUCHButtonData(response, startNr, endNr);
    if ( emulatePowerCenterIDsNr >=0 ) {
      switch(powerCenterEmulateStage[emulatePowerCenterIDsNr]) {
        case (POWERCENTEREMULATE_INIT) :
        setEmulatorInitStage(deviceID, 2);
        return 1;
        case(POWERCENTEREMULATE_RUN):
        // Stay here unless we need to change something
        return 1;
      default:
        return 0;
      }
    }
    case(CMD_ONETOUCH_CLEAR):
    setEmulatorRunStage(deviceID, 2);
    return 1;
    case(CMD_ONETOUCH_SHIFTLINES):
    return 1;
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

void processONETOUCHButtonData( int response, int startNr, int endNr) {
  doNothing(response);
  // Make this dependent on the original command
  int buttonPressed = processDataValues[startNr+1];
  if ( buttonPressed > 0 ) {
    logTxt("Button #"+buttonPressed+" ", LOGTXT_DATA);
  } else {
    processACK(startNr, endNr);
  }
}

int processONETOUCH_0x05_response(int deviceID, int startNr, int endNr) {
  doNothing(endNr);
  int val1 = processDataValues[startNr];
  int val2 = processDataValues[startNr+1];
  logFilePrintln(2, "ONETOUCH Response: "+reportVal(val1, 2)+" "+reportVal(val2, 2));
  setPowerCenterEmulateStage(deviceID, POWERCENTEREMULATE_RUN);
  return 1;
}

String processONETOUCHHighlightChars( int startNr, int endNr) {
  doNothing(endNr);
  String returnVal = "Line: ";
  returnVal += processDataValues[startNr];
  startNr++;
  returnVal += " Chars: ";
  returnVal += processDataValues[startNr];
  startNr++;
  returnVal += " to ";
  returnVal += processDataValues[startNr];
  startNr++;
  returnVal += " Highlight: ";
  returnVal += processDataValues[startNr];
  returnVal += " ";
  return returnVal;
}

void emulateONETOUCH(int command, int destination) {
  if ( emulateThisDevice(destination) == 1) {
    switch(command) {
    default:
    }
  }
}

void sendONETOUCHHighLight(int deviceID, int lineNr) {
  sendDataValues[0] = CMD_ONETOUCH_HIGHLIGHT;
  sendDataValues[1] = lineNr;
  sendEmulatorData(deviceID, 2);
  emulatorInfo("<== EMU RUN CMD HIGHLIGHT: "+reportVal(deviceID, 2));
}

void sendONETOUCHMessage(int deviceID, int lineNr, String txt) {
  int strLen = txt.length();
  sendDataValues[0] = CMD_ONETOUCH_MSG_LONG;
  sendDataValues[1] = lineNr;
  for ( int i=0; i< ONETOUCHMSGLENGTH; i++ ) {
    if (i<strLen ) {
      sendDataValues[i+2] = txt.charAt(i);
    } else { 
      sendDataValues[i+2] = 0x20;
    }
  }
  sendEmulatorData(deviceID, ONETOUCHMSGLENGTH+2);
  emulatorInfo("<== EMU RUN CMD STATUS: "+reportVal(deviceID, 2));
}

/*

 
 Button status only reported on status Command, not on MSG_LONG
 
 ===== START ====
 D00 D00 D16 D02 D67 D00 D85 D16 D03 
 \==> 1TOUCH         (43)            PROBE        
 D00 D00 D16 D02 D00 D01 D00 D00 D19 D16 D03 
 \==> MASTER               ARGS:02      
 ====== INIT =======================================
 D00 D00 D16 D02 D67 D02 D00 D00 D00 D00 D00 D87 D16 D03 
 \==> 1TOUCH         (43)  ARGS:05   STATUS       DATA: D00 D00 D00 D00 D00  == "/0x00//0x00//0x00//0x00//0x00/"
 D00 D00 D16 D02 D00 D01 D00 D00 D19 D16 D03 
 \==> MASTER               ARGS:02      
 D00 D00 D16 D02 D67 D05 D90 D16 D03 
 \==> 1TOUCH         (43)            CMD 0x05     
 D00 D00 D16 D02 D00 D01 D128 D00 D147 D16 D03 
 \==> MASTER               ARGS:02             
 ======== RUN =================================================
 D00 D00 D16 D02 D67 D09 D00 D00 D94 D16 D03 
 \==> 1TOUCH         (43)  ARGS:02   CLEAR SCREEN DATA: D00 D00  == "/0x00//0x00/"
 D00 D00 D16 D02 D00 D01 D128 D00 D147 D16 D03 
 \==> MASTER               ARGS:02                
 D00 D00 D16 D02 D67 D04 D04 D32 D32 D32 D32 D66 D48 D48 D50 D57 D50 D50 D49 D32 D32 D32 D32 D255 D16 D03 
 \==> 1TOUCH         (43)  ARGS:17   MESSAGE      LINE 4 DATA:"    B0029221    "
 D00 D00 D16 D02 D00 D01 D128 D00 D147 D16 D03 
 \==> MASTER               ARGS:02                
 D00 D00 D16 D02 D67 D04 D05 D32 D32 D32 D82 D83 D45 D56 D32 D67 D111 D109 D98 D111 D32 D32 D32 D56 D16 D03 
 \==> 1TOUCH         (43)  ARGS:17   MESSAGE      LINE 5 DATA:"   RS-8 Combo   "
 D00 D00 D16 D02 D00 D01 D128 D00 D147 D16 D03 
 \==> MASTER               ARGS:02                
 D00 D00 D16 D02 D67 D04 D07 D32 D32 D32 D82 D69 D86 D32 D84 D46 D48 D46 D49 D32 D32 D32 D32 D94 D16 D03 
 \==> 1TOUCH         (43)  ARGS:17   MESSAGE      LINE 7 DATA:"   REV T.0.1    "
 D00 D00 D16 D02 D00 D01 D128 D00 D147 D16 D03 
 \==> MASTER               ARGS:02              
 
 D00 D00 D16 D02 D67 D02 D00 D00 D00 D00 D00 D87 D16 D03 
 \==> 1TOUCH         (43)  ARGS:05   STATUS       DATA: D00 D00 D00 D00 D00  == "/0x00//0x00//0x00//0x00//0x00/"
 D00 D00 D16 D02 D00 D01 D128 D00 D147 D16 D03 
 \==> MASTER               ARGS:02     
 
 ==> SHIFT DOWN BY ONE
 6216 /     119 /   7911 /     44 | H10 H02 H43 H0F H02 H09 H01 H70 H10 H03 
 \==> 1TOUCH         (43)  ARGS:03   Received command 0x0F for destination 1TOUCH DATA: H02 H09 H01  == "/0x02//0x09//0x01/"
 33                     H00 H10 H02 H00 H01 H00 H00 H13 H10 H03   
 \==> MASTER               ARGS:02      
 ==> SHIFT UP BY ONE
 151 /     101 /    259 /     11 | ==> 1TOUCH         (43)  ARGS:03   SHIFT LINES  DATA: H02 H09 HFF  == "/0x02//0x09//0xFF/"
 49                     ==> MASTER               ARGS:02      
 
 */