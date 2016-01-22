//LX_HTR commands
final int CMD_LX_HTR_PROBE  = CMD_PROBE;  // 0x00
final int CMD_LX_HTR_STATUS = CMD_STATUS; // 0x02

final int CMD_LX_HTR_PING   = 0x0C;
// LX_HTR responses to Master
final int RESP_LX_HTR_PONG  = 0x0D;

int processLX_HTRCommand (int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_LX_HTR_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_LX_HTR_STATUS) :
    logTxt("STATUS  ", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  default:
    return 0;
  }
}

int processLX_HTRResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  switch(command) {
    case(CMD_LX_HTR_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}