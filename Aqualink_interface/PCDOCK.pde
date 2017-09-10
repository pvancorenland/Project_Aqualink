//============================//
//=== REMOTE PC DOCK COMMS ===//
//============================//

final int CMD_PCDOCK_STATUS   = CMD_STATUS;   //0x02
final int CMD_PCDOCK_0x03     = 0x03;
final int CMD_PCDOCK_0x08     = 0x08;
final int CMD_PCDOCK_0x1A     = 0x1A;

int processPCDOCKCommand(int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_PCDOCK_STATUS) :
    logTxt("STATUS  ", LOGTXT_TYPE);
    logTxt(checkCTLButtonStatus(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_PCDOCK_0x1A):
    logTxt("CMD 0x1A", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;

  default:
    return 0;
  }
}

int processPCDOCKResponse(int deviceID, int command, int response, int startNr, int endNr) {
  //String initString = "";
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case (CMD_PCDOCK_STATUS):
    checkSPAButtonStatus(2, processDataValuesCtr);
    return 1;
    case(CMD_PCDOCK_0x03):
    processValidGenericACK_Response(CMD_PCDOCK_0x03, startNr, endNr);
    return 1;
    case(CMD_PCDOCK_0x08):
    processValidGenericACK_Response(CMD_PCDOCK_0x08, startNr, endNr);
    return 1;
    case(CMD_PCDOCK_0x1A) :
    processPCDOCK_0x1A_response( startNr, endNr);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

void processPCDOCK_0x1A_response(int startNr, int endNr) {
  logTxt("CMD 0x1A ", LOGTXT_TYPE);
  logTxtData(startNr, endNr);
}