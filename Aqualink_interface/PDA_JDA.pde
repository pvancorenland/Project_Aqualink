int processPDA_JDACommand (int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_STATUS) :
    logTxt("STATUS  ", LOGTXT_TYPE);
    logTxt(checkCTLButtonStatus(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
  default:
    return 0;
  }
}