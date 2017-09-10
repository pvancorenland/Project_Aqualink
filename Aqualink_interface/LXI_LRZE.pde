//LXI_LRZE commands
final int CMD_LXI_LRZE_PROBE  = CMD_PROBE;  // 0x00
final int CMD_LXI_LRZE_STATUS = CMD_STATUS; // 0x02s
final int CMD_LXI_LRZE_PING   = 0x0C;

// LXI_LRZE responses to Master
final int RESP_LXI_LRZE_PONG  = 0x0D;

int processLXI_LRZECommand(int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_LXI_LRZE_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_LXI_LRZE_STATUS) :
    logTxt("STATUS  ", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_LXI_LRZE_PING):
    logTxt("PING", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
  default:
    return 0;
  }
}

int processLXI_LRZEResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  switch(command) {
    case(CMD_LXI_LRZE_PING) :
    switch(response) {
      case(RESP_LXI_LRZE_PONG) :
      logTxt("PONG", LOGTXT_TYPE);
      logTxtData(startNr, endNr);
      return 1;  
    default:
      logTxt("UNKNOWN RESPONSE FROM LXI_LRZE TO CMD_LXI_LRZE_PING ", LOGTXT_TYPE);
      logTxtData(startNr, endNr);
      return 0;
    }
    case(CMD_LXI_LRZE_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

//0000033 / 011313 ____ ==> LXI_LRZE   0: (06) Received command 0x0C for destination LXI_LRZE   Data:
//0000033 / 011314 ____ ==> MASTER     0: (05) Received command 0x0D for destination MASTER     Data: