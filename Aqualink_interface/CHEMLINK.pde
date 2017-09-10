//======================//
//=== CHEMLINK COMMS ===//
//======================//
//Jandy_log_05-30-2015_13:40:57.000_Output.txt:                     13084 WARNING!:Unknown CHEMLINK (H84) Response: H01 to command: H09


// CHEMLINK Commands
final int CMD_CHEMLINK_GETPH    = 0x01;
final int CMD_CHEMLINK_STATUS   = CMD_STATUS; // 0x02
final int CMD_CHEMLINK_SETORP   = 0x03;
final int CMD_CHEMLINK_SETPH    = 0x04;
final int CMD_CHEMLINK_ORPFEED  = 0x05;
final int CMD_CHEMLINK_PHFEED   = 0x06;
final int CMD_CHEMLINK_0x09     = 0x09;
final int CMD_CHEMLINK_0x0A     = 0x0A; //Turn level switch On/Off 
final int CMD_CHEMLINK_0x18     = 0x18;
final int CMD_CHEMLINK_GETORP   = 0x20; // Ident?

final String CMD_CHEMLINK_SETORP_TXT = "SET ORP";
final String CMD_CHEMLINK_SETPH_TXT  = "SET PH";
final String CMD_CHEMLINK_ORPFEED_TXT = "FEED ORP";
final String CMD_CHEMLINK_PHFEED_TXT  = "FEED PH";

// CHEMLINK responses to Master
final int RESP_CHEMLINK_0x21    = 0x21;
final int RESP_CHEMLINK_0x22    = 0x22;

// Variables
final int targetORP = 51;
final int targetPH  = 73; 

int processCHEMLINKCommand(int command, int destination) {
  int validCommand = processCHEMLINKCommandIsValid(command);
  if ( validCommand == 1 ) {
    emulateCHEMLINK(command, destination);
  }
  return validCommand;
}

int processCHEMLINKCommandIsValid(int command) {
  switch(command) {
    // STANDARD COMMANDS
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_CHEMLINK_STATUS) :
    logTxt("STATUS  ", LOGTXT_TYPE);
    logTxt(checkCHEMLINKStatus(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    // CHEMLINK SPECIFIC COMMANDS
    case(CMD_CHEMLINK_GETORP) :
    logTxt("GET ORP", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_CHEMLINK_SETORP) :
    logTxt(CMD_CHEMLINK_SETORP_TXT, LOGTXT_TYPE);
    logTxt(checkCHEMLINKORPSetup(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_CHEMLINK_SETPH) :
    logTxt(CMD_CHEMLINK_SETPH_TXT, LOGTXT_TYPE);
    logTxt(checkCHEMLINKPHSetup(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_CHEMLINK_ORPFEED) :
    logTxt("MAN FEED ORP:", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_CHEMLINK_PHFEED) :
    logTxt("MAN FEED PH:", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_CHEMLINK_0x09) :
    logTxt("CMD 0x09", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_CHEMLINK_0x0A) :
    logTxt("CMD 0x0A", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_CHEMLINK_0x18) :
    logTxt("CMD 0x18", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_CHEMLINK_GETPH) :
    logTxt("GET PH", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  default:
    return 0;
  }
}

int processCHEMLINKResponse(int deviceID, int command, int response, int startNr, int endNr) {
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case(CMD_CHEMLINK_GETORP) :
    processCHEMLINK_GETORP_response(deviceID, command, startNr, endNr);
    return 1;
    case(CMD_CHEMLINK_SETORP) :
    processValidGenericACK_Response(CMD_CHEMLINK_SETORP_TXT, CMD_CHEMLINK_SETORP, startNr, endNr);
    return 1;
    case(CMD_CHEMLINK_GETPH) :
    processCHEMLINK_GETPH_response(deviceID, command, startNr, endNr);
    return 1;
    case(CMD_CHEMLINK_SETPH) :
    processValidGenericACK_Response(CMD_CHEMLINK_SETPH_TXT, CMD_CHEMLINK_SETORP, startNr, endNr);
    return 1;
    case(CMD_STATUS) :
    processCHEMLINK_STATUS_response(deviceID, command, startNr, endNr);
    return 1;
  case CMD_CHEMLINK_ORPFEED:
    processValidGenericACK_Response(CMD_CHEMLINK_ORPFEED_TXT, CMD_CHEMLINK_ORPFEED, startNr, endNr);
    return 1;
  case CMD_CHEMLINK_PHFEED:
    processValidGenericACK_Response(CMD_CHEMLINK_PHFEED_TXT, CMD_CHEMLINK_PHFEED, startNr, endNr);
    return 1;
  case CMD_CHEMLINK_0x09:
    processCHEMLINK_0x09_response(deviceID, command, startNr, endNr);
    return 1;
  case CMD_CHEMLINK_0x0A:
    processValidGenericACK_Response(CMD_CHEMLINK_0x0A, startNr, endNr);
    return 1;
  case CMD_CHEMLINK_0x18:
    processValidGenericACK_Response(command, startNr, endNr);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    logTxtData(startNr, endNr);
    return 0;
  }
}

String checkCHEMLINKStatus( int startPos, int endPos ) {
  doNothing(endPos);
  String returnVal = "";
  for (int i=startPos; i<endPos; i++ ) {
    returnVal += reportVal(processDataValues[i], 2)+" ";
  }
  return returnVal;
}

String checkCHEMLINKORPSetup( int startPos, int endPos ) {
  doNothing(endPos);
  /* Bytes 0 - 10
   Byte #   | Value
   0        | Feeder      0=None 1=Gran 2=Liquid 3=ERO HP 4=MBV 5=ERO LP 6=Salt
   1        | Feed Tm
   2        | Delay OT
   3        | Set Point
   4        | Hi Alert`
   5        | Low Alert 
   6        | Wait PH    1 = Yes
   7        | Stop PH    0 = No
   8        | Next Cln   Month / Day
   */
  String optStr = "";
  optStr += "FEEDER: ";
  String feederStr = "";
  switch(processDataValues[startPos]) {
    case(0):
    feederStr = "NONE";
    break;
    case(1):
    feederStr = "Gran";
    break;
    case(2):
    feederStr = "Liquid";
    break;
    case(3):
    feederStr = "ERO HP";
    break;
    case(4):
    feederStr = "MBV";
    break;
    case(5):
    feederStr = "ERO LP";
    break;
    case(6):
    feederStr = "Salt";
    break;
  default:
    feederStr = str(processDataValues[startPos]);
    break;
  }
  optStr += addSpaces(feederStr, 7);
  // Time : 
  // Salt: 0x11 = Cont 
  // ERO LP : 0x0f = 10 min
  // Liquid: 0x09 = 30 sec
  // Gran: 0x05 = 5 sec
  optStr += " TIME: "+reportVal(processDataValues[startPos+1], 2);
  optStr += " OVER: ";
  switch(processDataValues[startPos+2]) {
  case 0:
    optStr += "OFF ";
    break;
  case 1:
    optStr += "4 HRS  ";
    break;
  case 2:
    optStr += "8 HRS  ";
    break;
  case 3:
    optStr += "12 HRS  ";
    break;
  case 4:
    optStr += "24 HRS  ";
    break;
  default:
    optStr += reportVal(processDataValues[startPos+2], 2);
    break;
  }
  String ORPVal    = getORPVal(processDataValues[startPos+3], 0);
  String ORPMAXVal = getORPVal(processDataValues[startPos+4], 0);
  String ORPMINVal = getORPVal(processDataValues[startPos+5], 0);
  optStr += " ORP="+ORPVal+" ("+ORPMINVal+" - "+ORPMAXVal+") ";

  optStr += " WAIT PH: ";
  switch(processDataValues[startPos+6]) {
  case 1:
    optStr += "YES";
    break;
  case 0:
    optStr += "NO ";
    break;
  }
  optStr += " STOP PH: ";
  switch(processDataValues[startPos+7]) {
  case 1:
    optStr += "YES";
    break;
  case 0:
    optStr += "NO ";
    break;
  }

  ///// REST OF processDataValues[startPos+6] still needs to be decoded

  optStr += " Next Clean: "+nf(processDataValues[startPos+8], 2)+"/"+nf(processDataValues[startPos+9], 2);
  optStr += " ";
  return optStr;
}

String checkCHEMLINKPHSetup( int startPos, int endPos ) {
  doNothing(endPos);
  /*
   Feeder      0=None  1=Gran  5=ERO 
   Feed Tm
   Delay OT
   Set Point
   Hi Alert
   Low Alert 
   ACID/BASE  0=ACID 1=BASE
   Next Cln   Month / Day
   Next CAL   Month / Day
   CAL AT PH
   */
  String optStr = "FEEDER: ";
  String feederStr = "";
  switch(processDataValues[startPos]) {
  case 6:
    feederStr += "Salt";
  default:
    feederStr += str(processDataValues[startPos]);
    break;
  }
  optStr += addSpaces(feederStr, 7);
  optStr += " TIME: "+reportVal(processDataValues[startPos+1], 2);
  optStr += " OVER: "+reportVal(processDataValues[startPos+2], 2);
  String PHVal    = getPHVal(processDataValues[startPos+3], 0);
  String PHMAXVal = getPHVal(processDataValues[startPos+4], 0);
  String PHMINVal = getPHVal(processDataValues[startPos+5], 0);
  optStr += "  PH= "+PHVal+" ("+PHMINVal+" - "+PHMAXVal+")";
  optStr += " TYPE: ";
  if ( processDataValues[startPos+6] == 0 ) {
    optStr += "Acid";
  } else {
    optStr += "Base";
  }
  optStr += " Next Clean: "+nf(processDataValues[startPos+7], 2)+"/"+nf(processDataValues[startPos+8], 2);
  optStr += " Next Cal: "+nf(processDataValues[startPos+9], 2)+"/"+nf(processDataValues[startPos+10], 2);
  optStr += " Cal at PH "+getPHVal(processDataValues[startPos+11], 0);
  return optStr;
}

String getPHVal(int PHMSD, int PHLSD) {
  int val = PHMSD*10 + PHLSD;
  float PHfloat = val/100.0;
  //return nf(PHfloat, 1, 3);
  return nfc(PHfloat, 2);
}

String getORPVal(int ORPMSD, int ORPLSD) {
  int val = ORPMSD*100 + ORPLSD;
  float ORPfloat = val/10.0;
  //return nf(ORPfloat, 3, 1);
  return nfc(ORPfloat, 1);
}

void processCHEMLINK_GETPH_response(int deviceID, int command, int startNr, int endNr) {
  doNothing(command);
  logTxt("PH SETUP: ", LOGTXT_TYPE);
  startNr++;
  logTxt(checkCHEMLINKPHSetup(startNr, endNr), LOGTXT_DATA);
  setEmulatorInitStage(deviceID, 3);
}

void processCHEMLINK_GETORP_response(int deviceID, int command, int startNr, int endNr) {
  doNothing(command);
  logTxt("ORP SETUP:", LOGTXT_TYPE);
  startNr++;
  logTxt(checkCHEMLINKORPSetup(startNr, endNr), LOGTXT_DATA);
  setEmulatorInitStage(deviceID, 2);
}

void processCHEMLINK_STATUS_response(int deviceID, int command, int startNr, int endNr) {
  doNothing(command);
  logTxt("STATUS: ", LOGTXT_TYPE);
  setEmulatorRunStage(deviceID, 2);
  startNr++;
  int ORPMSD = processDataValues[startNr];
  startNr += 2;
  int PHMSD  = processDataValues[startNr];
  int ORPLSD = 0;
  int PHLSD  = 0;
  if ( endNr >= 9) {
    lastChemlinkValuesHadExtendedData = 1;
    foundExtendedChemlinkData = true;
    startNr += 3;
    ORPLSD = processDataValues[startNr++];
    PHLSD = processDataValues[startNr++];
  } else {
    lastChemlinkValuesHadExtendedData--;
  }
  if ( endNr >= 11) {
    //WATERTEMP = nfc(processDataValues[startNr++]/5.0, 2, 1);
    //WATERTEMP = nfc(processDataValues[startNr++]/5.0, 1);
    WATERTEMP = cleanText(processDataValues[startNr++]/5.0, 1, 5);
    //println("BT: "+processDataValues[startNr]);
    //BOXTEMP = nfs(processDataValues[startNr++]/5.0, 2, 1);
    BOXTEMP = cleanText(processDataValues[startNr++]/5.0, 1, 5);
  }
  if ( foundExtendedChemlinkData ) {
    // Let's see if we had Extended data in a while
    if ( lastChemlinkValuesHadExtendedData < -4 ) {
      //We lost the extended data (for now)
      lastChemlinkValuesHadExtendedData = 0;
      foundExtendedChemlinkData = false;
    }
  }
  if ( (lastChemlinkValuesHadExtendedData == 1)||(!foundExtendedChemlinkData) ) {
    LOG_ORP_VAL = getORPVal(ORPMSD, ORPLSD);
    LOG_PH_VAL  = getPHVal(PHMSD, PHLSD);
  } 
  logFilePrintln(2, "ORP: "+ORPMSD+" + "+ORPLSD+" = "+LOG_ORP_VAL+" PH: "+PHMSD+" + "+PHLSD+" = "+LOG_PH_VAL);
  logTxt("ORP: "+LOG_ORP_VAL+printORPStatus(processDataValues[4])+" PH: "+LOG_PH_VAL+printPHStatus(processDataValues[6])+" TW:"+WATERTEMP+"C "+"TB:"+BOXTEMP + "C ", LOGTXT_DATA);
}

void processCHEMLINK_0x09_response(int deviceID, int command, int startNr, int endNr) {
  doNothing(deviceID);
  doNothing(command);
  doNothing(startNr);
  doNothing(endNr);
  logTxt("RESP0x21-09 ", LOGTXT_TYPE);
  logTxtData(startNr, endNr);
  setPowerCenterEmulateStage(findEmulatePowerCenterIDsNr(DEV_CHEMLINK_MASK), POWERCENTEREMULATE_RUN);
}

String printORPStatus(int status) {
  /*
   00: OK
   01: ORP EMPTY
   02: ORP LOW
   03: ---------------
   04: ORP FEEDING
   05:----------------
   06: ORP FEEDING
   07: ORP OVERFEED
   08: ORP FEEDING
   09:----------------
   10:----------------
   11:----------------
   13: ORP STOP
   25: crashes
   28: ORP 2 SEC
   29: ORP 3 SEC:
   32: ORP 10 SEC
   37: ORP 2 MIN
   43: ORP CONT
   */
  String optStr = " STAT: ";
  switch(status) {
  case 0: 
    optStr += "OK";
    break;
  case 1: 
    optStr += "ORP EMPTY";
    break;
  case 2: 
    optStr += "ORP LOW";
    break;
  case 3: 
    optStr += "OK(3)";
    break;
  case 4: 
    optStr += "ORP FEEDING";
    break;
  case 7: 
    optStr += "ORP OVERFEED";
    break;
  case 13: 
    optStr += "ORP STOP";
    break;
  case 28: 
    optStr += "ORP 2 SEC";
    break;
  case 29: 
    optStr += "ORP 3 SEC";
    break;
  case 32: 
    optStr += "ORP 10 SEC";
    break;
  case 37: 
    optStr += "ORP 2 MIN";
    break;
  case 43: 
    optStr += "ORP CONT";
    break;
  default:
    optStr += reportVal(status, 2);
    break;
  }
  return optStr;
}

String printPHStatus(int status) {
  String optStr = " STAT: ";
  switch(status) {
  case 3: 
    optStr += "OK(3)";
    break;
  default:
    optStr += reportVal(status, 2);
  }
  return optStr;
}

// Emulation
void emulateCHEMLINK(int command, int destination) {
  //println("DEST = "+destination+" EMU ID = "+emulateID+" ==> "+emulateThisDevice(destination));
  if ( emulateThisDevice(destination) == 1) {
    //println("EMU!! "+reportVal(command, 2));
    switch(command) {
      case(CMD_PROBE):
      send_ACK("CHEMLINK", 2, command);
      break;
      case(CMD_STATUS):
      respondCHEMLINKSTATUS();
      break;
      case(CMD_CHEMLINK_GETORP):
      respondCHEMLINK_GETPH();
      break;
      case(CMD_CHEMLINK_SETORP):
      respondCHEMLINK_ORP_SETUP();
      break;
      case(CMD_CHEMLINK_SETPH):
      respondCHEMLINK_PH_SETUP();
      break;
      case(CMD_CHEMLINK_ORPFEED):
      respondCHEMLINK_ORPFEED();
      break;
      case(CMD_CHEMLINK_PHFEED):
      respondCHEMLINK_PHFEED();
      break;
      case(CMD_CHEMLINK_0x09):
      respondCHEMLINK_CMD_09();
      break;
      case(CMD_CHEMLINK_0x0A):
      respondCHEMLINK_CMD_0A();
      break;
      case(CMD_CHEMLINK_0x18):
      respondCHEMLINK_CMD_18();
      break;
      case(CMD_CHEMLINK_GETPH):
      respondCHEMLINK_GETORP();
      break;
    default:
      logTxtLn("UNKNOWN EMU COMMAND!! "+reportVal(command, 2)+" DEST: "+reportVal(destination, 2), LOGTXT_WARNING);
    }
  }
}

void respondCHEMLINKSTATUS() {
  //  H10 H02 == H80 == H02                         == H94 == H10 H03 
  //\--> ==> CHEMLINK   0: (02) STATUS        02 
  //  H10 H02 == H00 == H21 H02 H3B H03 H4B H0E H02 == HCE == H10 H03 
  //\--> ==> MASTER     0: (08) Received command 0x21 for destination MASTER     DATA: H02 H3B H03 H4B H0E H02 
  // 0x02
  // RESP: 0x21 (RESP_CHEMLINK_STATUS)
  // DATA: H02 H3B H03 H4B H0E H02 
  // Verified
  sendDataValues[0] = RESP_CHEMLINK_0x21;
  sendDataValues[1] = CMD_STATUS;
  sendDataValues[2] = targetORP;
  sendDataValues[3] = 0x03;
  sendDataValues[4] = targetPH;
  //sendDataValues[5] = 0x0E;
  sendDataValues[5] = 0x0A ;
  //sendDataValues[6] = 0x02;
  sendDataValues[6]=(0x02);
  sendEmulatorData(DEV_MASTER_MASK, 7);
  emulatorInfo("<== EMU CHEMLINK STATUS COMMAND");
}

void respondCHEMLINK_ORP_SETUP() {
  sendDataValues[0]=CMD_ACK;
  sendDataValues[1]=CMD_CHEMLINK_SETORP;
  sendDataValues[2]=0x00;
  sendEmulatorData(DEV_MASTER_MASK, 3);
  emulatorInfo("<== EMU ORP SETUP COMMAND");
}

void respondCHEMLINK_PH_SETUP() {
  sendDataValues[0]=CMD_ACK;
  sendDataValues[1]=CMD_CHEMLINK_SETPH;
  sendDataValues[2]=0x00;
  sendEmulatorData(DEV_MASTER_MASK, 3);
  emulatorInfo("<== EMU PH SETUP COMMAND");
}

void respondCHEMLINK_ORPFEED() {
  sendDataValues[0]=CMD_ACK;
  sendDataValues[1]=CMD_CHEMLINK_ORPFEED;
  sendDataValues[2]=0x00;
  sendEmulatorData(DEV_MASTER_MASK, 3);
  emulatorInfo("<== EMU ORP FEED COMMAND");
}

void respondCHEMLINK_PHFEED() {
  sendDataValues[0]=CMD_ACK;
  sendDataValues[1]=CMD_CHEMLINK_PHFEED;
  sendDataValues[2]=0x00;
  sendEmulatorData(DEV_MASTER_MASK, 3);
  emulatorInfo("<== EMU PH FEED COMMAND");
}

void respondCHEMLINK_GETPH() {
  // 0x01
  // H01 H02 H0E H2D H4A H53 H47 H00 H03 H0B H08 H0C HF7
  sendDataValues[0]=RESP_CHEMLINK_0x22;
  sendDataValues[1]=CMD_CHEMLINK_GETORP;
  sendDataValues[2]  = 0x06; // Salt feeder
  sendDataValues[3]  = 0x11; // Continuous feeding
  sendDataValues[4]  = 0x02; // Overfeed: 2 MIN
  sendDataValues[5]  = 0x4B; // PH Set for 7.5
  sendDataValues[6]  = 0x50; // PH High Alert: 8.0
  sendDataValues[7]  = 0x46; // PH Low Alert: 7.0
  sendDataValues[8]  = 0x00; // ACID
  sendDataValues[9]  = 0x0A; // Next clean Month: October
  sendDataValues[10] = 0x0C; // Next clean Day: 12
  sendDataValues[11] = 0x07; // Next clean Month: July
  sendDataValues[12] = 0x0A; // Next clean Day: 10  
  sendDataValues[13] = 0x47; // Next cal at 7.1 
  sendEmulatorData(DEV_MASTER_MASK, 14);  
  emulatorInfo("<== EMU CHEMLINK 01 RESPONSE");
}

void respondCHEMLINK_CMD_09() {
  sendDataValues[0]=RESP_CHEMLINK_0x21;
  sendDataValues[1]=CMD_CHEMLINK_0x09;
  sendDataValues[2]=0x00;
  sendDataValues[3]=0x00;  
  sendDataValues[4]=0x00;  
  sendDataValues[5]=0x00;  
  sendDataValues[6]=0x00;
  sendEmulatorData(DEV_MASTER_MASK, 7);
  emulatorInfo("<== EMU CHEMLINK 09 RESPONSE");
}

void respondCHEMLINK_CMD_0A() {
  println("############# UNKNOWN EMULATOR COMMAND 0x0A REACHED###########");
  emulatorInfo("<== EMU CHEMLINK 09 RESPONSE");
}

void respondCHEMLINK_CMD_18() {
  //   H10 H02 == H80 == H18 H00     == HAA == H10 H03 
  //\--> ==> CHEMLINK   0: (03) CMD 18        
  //   H10 H02 == H00 == H01 H18 H00 == H2B == H10 H03 
  //\--> ==> MASTER     0: (04) ACK            DATA: H18 H00 
  // 0x18
  // RESP: 0x18 0x00
  // Verified
  sendDataValues[0]=CMD_ACK;
  sendDataValues[1]=CMD_CHEMLINK_0x18;
  sendDataValues[2]=0x00;
  sendEmulatorData(DEV_MASTER_MASK, 3);
  emulatorInfo("<== EMU CHEMLINK 18 RESPONSE");
}

void respondCHEMLINK_GETORP() {
  // H20 H02 H0F H0A H3A H55 H1E H01 H00 H08 H0C H00 H00
  sendDataValues[0]=RESP_CHEMLINK_0x22;
  sendDataValues[1]=CMD_CHEMLINK_GETPH;
  sendDataValues[2]  = 0x06; // Salt feeder
  sendDataValues[3]  = 0x11; // Continuous feeding
  sendDataValues[4]  = 0x02; // Overfeed: 8 HRS
  sendDataValues[5]  = 0x41; // ORP Set for 650
  sendDataValues[6]  = 0x47; // ORP High Alert: 710
  sendDataValues[7]  = 0x33; // ORP Low Alert: 510
  sendDataValues[8]  = 0x00; // Wait PH: NO
  sendDataValues[9]  = 0x01; // STOP PH: YES
  sendDataValues[10] = 0x09; // Next clean Month: September
  sendDataValues[11] = 0x0B; // Next clean Day: 11
  sendDataValues[12] = 0x00; // MIGHT NOT BE NEEDED!
  sendDataValues[13] = 0x00; // MIGHT NOT BE NEEDED!
  sendEmulatorData(DEV_MASTER_MASK, 14);
  emulatorInfo("<== EMU CHEMLINK GET ORP RESPONSE");
}

/*
0000138 / 0000138 / 002885 ____ ==> CHEMLINK    (80) ARGS:01   CMD 0x18     DATA: H00  == "/0x00/"
 ==> MASTER           ARGS:02   ACK          DATA: H18 H00  == "/0x18//0x00/"
 
 0000077 / 0001426 / 002913 ____ ==> CHEMLINK    (80)           STATUS       
 ==> MASTER           ARGS:06   RESP0x21-02  ORP: 590 STAT: 0x03 PH: 7.5 STAT: 0x0E DATA: H02  == "/0x02/"
 
 0000152 / 0000152 / 002914 ____ ==> CHEMLINK    (80) ARGS:01   CMD 0x18     DATA: H01  == "/0x01/"
 ==> MASTER           ARGS:02   ACK          DATA: H18 H00  == "/0x18//0x00/"
 
 0000082 / 0001143 / 002942 ____ ==> CHEMLINK    (80)           STATUS       
 ==> MASTER           ARGS:06   RESP0x21-02  ORP: 590 STAT: 0x03 PH: 7.5 STAT: 0x00 DATA: H00  == "/0x00/"
 */