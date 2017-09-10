//=================================//
//=== REMOTE POWER CENTER COMMS ===//
//=================================//

final int CMD_RPC_0x09     = 0x09;
final int CMD_RPC_STATUS    = CMD_STATUS;   //0x02

int processRPCCommand(int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_RPC_STATUS) :
    logTxt("STATUS  ", LOGTXT_TYPE);
    logTxt(checkCTLButtonStatus(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_RPC_0x09):
    logTxt("CMD 0x09", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;

  default:
    return 0;
  }
}

int processRPCResponse(int deviceID, int command, int response, int startNr, int endNr) {
  //String initString = "";
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case (CMD_RPC_STATUS):
    checkSPAButtonStatus(2, processDataValuesCtr);
    return 1;
    case(CMD_RPC_0x09) :
    processValidGenericACK_Response(command, startNr, endNr);
    return 1;
  default:
    unknownResponse(deviceID, command, response, startNr, endNr);
    return 0;
  }
}