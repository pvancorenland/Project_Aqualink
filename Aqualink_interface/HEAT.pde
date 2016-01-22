int processHEATPUMPCommand (int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
  default:
    return 0;
  }
}