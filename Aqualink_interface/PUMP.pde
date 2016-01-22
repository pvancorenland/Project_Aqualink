//==================//
//=== PUMP COMMS ===//
//==================//
// PUMP Commands
final int CMD_INTELLIFLO_1      = 0x53;

void processPumpData() {
  logFilePrintln(2, "processPumpData");
  int checkSum = pumpCommandCKL + pumpCommandCKH*256;
  switch ( pumpDestination ) {
    case(PUMPMASTER):
    setNowDecodingResponse(1);
    logTxt(addSpaces("MASTER", LOGTXT_DESTNAMELENGTH)+" ID:0", LOGTXT_DEST);
    logTxt("STATUS:", LOGTXT_TYPE);
    break;
    case(PUMPDEVICE):
    setNowDecodingResponse(0);
    logTxt(addSpaces("INTELLIFLO", LOGTXT_DESTNAMELENGTH)+" ID:0", LOGTXT_DEST);
    logTxt("SET", LOGTXT_TYPE);
    break;
  default:
    logTxt("UNK PUMP DEST "+pumpDestination, LOGTXT_DEST);
    break;
  }
  logTxtDestination(0x100+pumpDestination);
  logTxtArgs(pumpCommandLength);
  String commandTxt = "";
  switch(pumpCommand) {
    case(PUMPPANELCTL):
    switch (pumpCommandData[0]) {
      case(0xff):
      commandTxt = "PUMP PANEL CTL OFF";
      break;
      case(0x00):
      commandTxt = "PUMP PANEL CTL ON";
      break;
    default:
      commandTxt = "UNKNOWN PUMP PANEL DATA "+pumpCommandData[0];
    }
    break;
    case(PUMPGPM):
    switch ( pumpDestination ) {
      // Should add command decoding here!
      case(0x10):
      pumpGPMVal = pumpCommandData[0]*256 + pumpCommandData[1];
      //for ( int i =0; i< pumpCommandLength; i++ ) {
      //  println("DAT("+i+") = "+reportVal(pumpCommandData[i], 2));
      //}
      break;
      case(0x60):
      pumpGPMVal = pumpCommandData[2]*256 + pumpCommandData[3];
      break;
    }
    commandTxt ="GPM: "+pumpGPMVal;
    break;
    case(PUMPSETMODE):
    pumpMODEVal = pumpCommandData[0];
    switch (pumpMODEVal) {
      case (PUMPMODEFEATURE1):
      commandTxt = "MODE: Feature 1";
      break;
    default:
      commandTxt = "UNKNOWN MODE: "+reportVal(pumpMODEVal, 2);
    }
    break;
    case(PUMPSTART):
    pumpSTARTVal = pumpCommandData[0];
    commandTxt = "START : "+reportVal(pumpSTARTVal, 2);
    break;
    case(PUMPSTAT):
    commandTxt = "PUMP STAT ";
    if ( pumpDestination == PUMPMASTER ) {
      //for ( int i =0; i< pumpCommandLength; i++ ) {
      //  commandTxt +=  ""+reportVal(pumpCommandData[i], 2)+" ";
      //}
      commandTxt += ": ";
      commandTxt += decodePumpstatus();
    } else {
      commandTxt += "?";
    }
    break;
  default:
    commandTxt += "("+nf(pumpCommandLength, 2)+")"+" CMD = "+reportVal(pumpCommand, 2)+" DATA = ";
    for ( int i =0; i< pumpCommandLength; i++ ) {
      commandTxt +=  ""+reportVal(pumpCommandData[i], 2)+" ";
    }
    commandTxt +=" CK = "+reportVal(checkSum, 4);
    break;
  }
  logTxt(commandTxt+ " ", LOGTXT_DATA);
}

String decodePumpstatus() {
  String opt ="";
  int dataCtr = 0;
  switch (pumpCommandData[dataCtr] ) {
    case(0x0A) :
    opt += "STARTED ";
    break;
    case(0x04) :
    opt += "PRIMING ERROR ";
    break;
  default:
    opt += "??"+reportVal(pumpCommandData[dataCtr], 2)+" ";
    break;
  }
  dataCtr ++;
  switch (pumpCommandData[dataCtr] ) {
    case(0x06) :
    opt += "FEATURE 1 ";
    break;
  default:
    opt += "??"+reportVal(pumpCommandData[dataCtr], 2)+" ";
    break;
  }
  dataCtr ++;
  opt += "STATE: "+reportVal(pumpCommandData[dataCtr], 2)+" ";
  dataCtr ++;
  int pumpWatt = pumpCommandData[dataCtr]*256;
  dataCtr ++;
  pumpWatt += pumpCommandData[dataCtr];
  LOG_PUMPWATT_VAL = str(pumpWatt);
  opt += pumpWatt+"WATT ";
  dataCtr ++;
  int pumpRPM = pumpCommandData[dataCtr]*256;
  LOG_PUMPRPM_VAL = str(pumpRPM);
  dataCtr ++;
  pumpRPM += pumpCommandData[dataCtr];
  opt += pumpRPM+"RPM ";
  dataCtr ++;
  int pumpGPM = pumpCommandData[dataCtr];
  LOG_PUMPGPM_VAL = str(pumpGPM);
  opt += pumpGPM+"GPM ";
  dataCtr ++;
  opt += pumpCommandData[dataCtr]+"% ";
  dataCtr ++;
  int err = pumpCommandData[dataCtr];
  if ( err != 0 ) {
    opt += "ERR : "+reportVal(err, 2);
  } else {
    opt += "OK ";
  }
  dataCtr ++;
  opt += "??"+reportVal(pumpCommandData[dataCtr], 2)+"?? ";
  dataCtr ++;
  opt += pumpCommandData[dataCtr]+"MIN ";
  dataCtr ++;
  opt += nf(pumpCommandData[dataCtr], 2)+":";
  dataCtr ++;
  opt += nf(pumpCommandData[dataCtr], 2)+" ";
  return opt;
}