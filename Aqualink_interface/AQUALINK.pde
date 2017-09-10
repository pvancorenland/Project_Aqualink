//======================//
//=== AQUALINK COMMS ===//
//======================//
// AQUALINK Commands
final int CMD_AQUALINK_0x23    = 0x23;
final int CMD_AQUALINK_DISP    = 0x24;
final int CMD_AQUALINK_MSG     = 0x25;
final int CMD_AQUALINK_UPD     = 0x26;
final int CMD_AQUALINK_DATE    = 0x28;
final int CMD_AQUALINK_0x29    = 0x29;
final int CMD_AQUALINK_0x2B    = 0x2B;
final int CMD_AQUALINK_DIALOG  = 0x2C;
final int CMD_AQUALINK_0x2D    = 0x2D;
final int CMD_AQUALINK_0x30    = 0x30;
final int CMD_AQUALINK_0x31    = 0x31;
final int CMD_AQUALINK_0x32    = 0x32;
final int CMD_AQUALINK_0x33    = 0x33;
final int CMD_AQUALINK_0x40    = 0x40;
final int CMD_AQUALINK_0x41    = 0x41;
final int CMD_AQUALINK_0x70    = 0x70;
final int CMD_AQUALINK_0x71    = 0x71;
final int CMD_AQUALINK_0x72    = 0x72;

final String CMD_AQUALINK_DISP_TXT = "DISP";

final String AQUALINK_ICON_OFF = "OFF";
final String AQUALINK_ICON_ON  = "ON";

int processAQUALINKCommand(int command, int destination) {
  int validCommand = processAQUALINKCommandIsValid(command);
  if ( validCommand == 1 ) {
    emulateAQUALINK(command, destination);
  }
  return validCommand;
}

int processAQUALINKCommandIsValid(int command) {
  switch(command) {
    //==================================================================//
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_AQUALINK_0x23):
    logTxt("CMD 0x23", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_DISP):
    logTxt("DISPLAY", LOGTXT_TYPE);
    processAQUALINK_DISP_Command(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_UPD):
    logTxt("UPDATE ", LOGTXT_TYPE);
    logTxtDataASCII(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_MSG):
    logTxt("MESSAGE", LOGTXT_TYPE);
    logTxt("ARG="+reportVal(processDataValues[2], 2)+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_AQUALINK_DATE):
    processAQUALINK_TIME_Command(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x29):
    logTxt("CMD 0x29", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x2B):
    logTxt("CMD 0x2B", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_DIALOG):
    logTxt("DIALOG", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x2D):
    logTxt("CMD 0x2D", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x30):
    logTxt("CMD 0x30", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x31):
    logTxt("CMD 0x31", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x32):
    logTxt("CMD 0x32", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;    
    case(CMD_AQUALINK_0x33):
    logTxt("CMD 0x33", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x40):
    logTxt("CMD 0x40", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x41):
    logTxt("CMD 0x41", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x70):
    logTxt("CMD 0x70", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x71):
    logTxt("CMD 0x71", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_0x72):
    logTxt("CMD 0x72", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  default:
    return 0;
  }
}

int processAQUALINKResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  //int emulatePowerCenterIDsNr = findEmulatePowerCenterIDsNr(deviceID);
  //println("processAQUALINKResponse "+reportVal(deviceID, 2)+" "+reportVal(command, 2)+" "+reportVal(response, 2));
  //String initString = "";
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case(CMD_AQUALINK_0x23) :
    processValidGenericACK_Response(CMD_AQUALINK_0x23, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_DISP) :
    processAQUALINK_DISP_Response(startNr, endNr);
    return 1;
    case(CMD_AQUALINK_UPD) :
    processAQUALINK_UPD_Response(startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x29) :
    processValidGenericACK_Response(CMD_AQUALINK_0x29, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x2B) :
    processValidGenericACK_Response(CMD_AQUALINK_0x2B, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_DIALOG) :
    processAQUALINK_DIALOG_Response(startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x2D) :
    processValidGenericACK_Response(CMD_AQUALINK_0x2D, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x30) :
    processValidGenericACK_Response(CMD_AQUALINK_0x30, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x31) :
    processValidGenericACK_Response(CMD_AQUALINK_0x31, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x32) :
    processValidGenericACK_Response(CMD_AQUALINK_0x32, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x33) :
    processValidGenericACK_Response(CMD_AQUALINK_0x33, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x40) :
    processValidGenericACK_Response(CMD_AQUALINK_0x40, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x41) :
    processValidGenericACK_Response(CMD_AQUALINK_0x41, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_MSG) :
    processAQUALINK_MSG_Response(startNr, endNr);
    return 1;
    case(CMD_AQUALINK_DATE) :
    processAQUALINK_DATE_Response(startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x70) :
    processValidGenericACK_Response(CMD_AQUALINK_0x70, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x71) :
    processValidGenericACK_Response(CMD_AQUALINK_0x71, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_0x72) :
    processValidGenericACK_Response(CMD_AQUALINK_0x72, startNr, endNr);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

void processAQUALINK_DISP_Response(int startNr, int endNr) {
  //  logTxt("DISP ACK", LOGTXT_TYPE);
  //  verifyACKToCommand(CMD_AQUALINK_DISP, startNr, endNr);
  processValidGenericACK_Response(CMD_AQUALINK_DISP_TXT, CMD_AQUALINK_DISP, startNr, endNr);
}

void processAQUALINK_MSG_Response(int startNr, int endNr) {
  logTxt("MSG ACK", LOGTXT_TYPE);
  verifyACKToCommand(CMD_AQUALINK_MSG, startNr, endNr);
}

void processAQUALINK_UPD_Response(int startNr, int endNr) {
  logTxt("UPD ACK", LOGTXT_TYPE);
  verifyACKToCommand(CMD_AQUALINK_UPD, startNr, endNr);
}

void processAQUALINK_DIALOG_Response(int startNr, int endNr) {
  logTxt("DIALOG ACK", LOGTXT_TYPE);
  verifyACKToCommand(CMD_AQUALINK_DIALOG, startNr, endNr);
}

void processAQUALINK_DATE_Response(int startNr, int endNr) {
  logTxt("DATE ", LOGTXT_TYPE);
  logTxtData(startNr, endNr);
}

void processAQUALINK_DISP_Command(int startNr, int endNr) {
  String optString = "ICON "+processDataValues[startNr]+" ";
  startNr++;
  switch ( processDataValues[startNr]) {
  case 0:
    optString += AQUALINK_ICON_OFF;
    break;
  case 1:
    optString += AQUALINK_ICON_ON;
    break;
  default:
    optString += " /"+reportVal(processDataValues[startNr], 2);
  }
  startNr++;
  optString += "/"+reportVal(processDataValues[startNr], 2);  
  startNr++; 
  optString += "/"+reportVal(processDataValues[startNr], 2);  
  startNr++; 
  logTxt(optString+" ", LOGTXT_DATA);
  logTxtDataASCII(startNr, endNr);
}

void processAQUALINK_TIME_Command(int startNr, int endNr) {
  doNothing(endNr);
  logTxt("SET DATE", LOGTXT_TYPE);
  logTxt(processDataValues[startNr]+"/"+processDataValues[startNr+1]+"/"+processDataValues[startNr+2]+" "+nf(processDataValues[startNr+3], 2)+":"+nf(processDataValues[startNr+4], 2), LOGTXT_DATA);
}

//=========//
// EMULATE //
//=========//
void emulateAQUALINK(int command, int destination) {
  if ( emulateThisDevice(destination) == 1) {
    switch(command) {
      case(CMD_PROBE):
      send_ACK("<== EMU AQUALINK PROBE RESPONSE", 2, command);
      break;
      case(CMD_AQUALINK_DISP):
      send_ACK("<== EMU AQUALINK DISP RESPONSE", 2, command);
      break;
      case(CMD_AQUALINK_MSG):
      send_ACK("<== EMU AQUALINK MSG RESPONSE", 2, command);
      break;
    default:
      send_ACK("<== EMU AQUALINK CMD "+reportVal(command, 2)+" RESPONSE", 2, command);
      break;
      //    default:
      //      logTxtLn("UNKNOWN EMU COMMAND!! "+reportVal(command, 2)+" DEST: "+reportVal(destination, 2), LOGTXT_WARNING);
      //    }
    }
  }
}