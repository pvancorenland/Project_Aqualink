final int CMD_AQUALINK_2_STATUS    = CMD_STATUS;   //0x02

final int CMD_AQUALINK_2_0x50  = 0x50;
final int CMD_AQUALINK_2_0x51  = 0x51;
final int CMD_AQUALINK_2_0x52  = 0x52;
final int CMD_AQUALINK_2_0x53  = 0x53;
final int CMD_AQUALINK_2_0x59  = 0x59;
final int CMD_AQUALINK_2_0x61  = 0x61;
final int CMD_AQUALINK_2_0x73  = 0x73;

int processAQUALINK_2NDCommand (int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_AQUALINK_2_0x51):
    logTxt("CMD 0x51", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_2_0x52):
    logTxt("CMD 0x52", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_2_0x53):
    logTxt("CMD 0x53", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_2_0x50):
    logTxt("CMD 0x50", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_2_0x59):
    logTxt("CMD 0x59", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_2_0x61):
    logTxt("CMD 0x61", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUALINK_2_0x73):
    logTxt("CMD 0x73", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  default:
    return 0;
  }
}

int processAQUALINK_2NDResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  //String initString = "";
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case (CMD_AQUALINK_2_STATUS):
    checkSPAButtonStatus(startNr, endNr);
    return 1;
    case(CMD_AQUALINK_2_0x53):
    processValidGenericACKResponse(CMD_AQUALINK_2_0x53, startNr, endNr);
    return 1;
    case(CMD_AQUALINK_2_0x73):
    processValidGenericACKResponse(CMD_AQUALINK_2_0x73, startNr, endNr);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}