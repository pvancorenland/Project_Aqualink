//=================//
//=== SPA COMMS ===//
//=================//

final int CMD_SPA_STATUS    = CMD_STATUS;   //0x02
final int CMD_SPA_MSG       = CMD_MSG;      //0x03
final int CMD_SPA_MSG_LONG  = CMD_MSG_LONG; //0x04
final int CMD_SPA_0x50      = 0x50; //
final int CMD_SPA_0x51      = 0x51; //
final int CMD_SPA_0x52      = 0x52; //
final int CMD_SPA_0x53      = 0x53; //
final int CMD_SPA_0x59      = 0x59; //
final int CMD_SPA_0x60      = 0x60; //
final int CMD_SPA_0x61      = 0x61; //


// SPA BUTTON LIGHT STATUS
final int SPA_STAT_BUT1[] = { 
  0, 0x10
};
final int SPA_STAT_BUT1_BLINK[] = { 
  0, 0x20
};
final int SPA_STAT_BUT2[] = { 
  0, 0x04
};
final int SPA_STAT_BUT3[] = { 
  0, 0x01
};


int processSPACommand(int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_STATUS) :
    logTxt("STATUS ", LOGTXT_TYPE);
    logTxt(checkSPAButtonStatus(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_SPA_MSG) :
    logTxt("MESSAGE", LOGTXT_TYPE);
    logTxt("ARG="+reportVal(processDataValues[2], 2)+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_SPA_MSG_LONG) :
    logTxt("MESSAGE LONG", LOGTXT_TYPE);
    logTxt("ARG="+reportVal(processDataValues[2], 2)+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    return 1;
  default:
    return 0;
  }
}

int processSPAResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  //String initString = "";
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case (CMD_SPA_STATUS):
    checkSPAButtonResponse(startNr, endNr);
    return 1;
    case(CMD_SPA_MSG):
    logTxt("MSG", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_SPA_0x50):
    processValidGenericACK_Response(CMD_SPA_0x50, startNr, endNr);
    return 1;
    case(CMD_SPA_0x51):
    processValidGenericACK_Response(CMD_SPA_0x51, startNr, endNr);
    return 1;
    case(CMD_SPA_0x52):
    processValidGenericACK_Response(CMD_SPA_0x52, startNr, endNr);
    return 1;
    case(CMD_SPA_0x53):
    processValidGenericACK_Response(CMD_SPA_0x53, startNr, endNr);
    return 1;
    case(CMD_SPA_0x59):
    processValidGenericACK_Response(CMD_SPA_0x59, startNr, endNr);
    return 1;
    case(CMD_SPA_0x60):
    processValidGenericACK_Response(CMD_SPA_0x60, startNr, endNr);
    return 1;
    case(CMD_SPA_0x61):
    processValidGenericACK_Response(CMD_SPA_0x61, startNr, endNr);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

String checkSPAButtonResponse(int startPos, int endPos) {
  String returnVal = "";
  if ( buttStat(SPA_RESPONSE_EXPECTED_BUTTSTAT_BYTES, SPA_STAT_BUT1, startPos, endPos) == 1) {
    returnVal += "SPA " ;
  }
  if ( returnVal == "" ) {
    return "NIL";
  } 
  return returnVal;
}

String checkSPAButtonStatus(int startPos, int endPos) {
  String returnVal = "";
  if ( buttStat(SPA_EXPECTED_BUTTSTAT_BYTES, SPA_STAT_BUT1, startPos, endPos) == 1) {
    returnVal += "SPA " ;
  }
  if ( buttStat(SPA_EXPECTED_BUTTSTAT_BYTES, SPA_STAT_BUT1_BLINK, startPos, endPos) == 1) {
    returnVal += "SPA BLINK " ;
  }
  if ( buttStat(SPA_EXPECTED_BUTTSTAT_BYTES, SPA_STAT_BUT2, startPos, endPos) == 1) {
    returnVal += "HEAT " ;
  }  
  if ( buttStat(SPA_EXPECTED_BUTTSTAT_BYTES, SPA_STAT_BUT3, startPos, endPos) == 1) {
    returnVal += "SPILLWAY " ;
  }  
  if ( returnVal == "" ) {
    return "NIL";
  } 
  return returnVal;
}

//000160 / 002003 ____ ==> SPA        0: (02) PROBE        
//049536 / 002004 ____ ==> MASTER     0: (04) ACK           
//032715 / 002008 ____ ==> SPA        0: (07) STATUS        NIL
//000281 / 002009 ____ ==> MASTER     0: (04) ACK           
//050331 / 002010 ____ ==> SPA        0: (19) MSG           ==> 00 30 46 46 00 20 00 00 00 01 00 00 00 03 00 00 00  == 
//000315 / 002011 ____ ==> MASTER     0: (04) ACK           