//======================//
//=== AQUARITE COMMS ===//
//======================//

// Aquarite Commands
final int CMD_AQUARITE_STAT       = 0x11; // Responds with Status (PPM, FLOW,...)
final int CMD_AQUARITE_IDENT      = 0x14; // Responds with MSG "BOOST for all arguments except for "1", where it responds with its name (Aquapure, ...)
final int CMD_AQUARITE_STAT2      = 0x15; // Responds with Status (PPM, FLOW,...)

// Aquarite responses to Master
final int RESP_AQUARITE_IDENT     = 0x03;
final int RESP_AQUARITE_STAT      = 0x16;

// Aquarite Status
final int STAT_AQUARITE_OK        = 0x00;
final int STAT_AQUARITE_NOFLOW    = 0x01;
final int STAT_AQUARITE_LOSALT    = 0x02;
final int STAT_AQUARITE_HISALT    = 0x04;
final int STAT_AQUARITE_GENERAL   = 0x08;

// Variables
final int AQRppm                  = 30;
final int AQRStatus               = STAT_AQUARITE_HISALT;

//==================//
// PROCESS COMMANDS //
//==================//
int processAQUARITECommand(int command, int destination) {
  int validCommand = processAQUARITECommandIsValid(command);
  if ( validCommand == 1 ) {
    emulateAQUARITE(command, destination);
  }
  return validCommand;
}

int processAQUARITECommandIsValid (int command) {
  switch(command) {
    case(CMD_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_AQUARITE_IDENT):
    logTxt("AQUARITE ID", LOGTXT_TYPE);
    logTxtData(2, processDataValuesCtr);
    return 1;
    case(CMD_AQUARITE_STAT):
    processAquariteSettings( 2, processDataValuesCtr);
    return 1;
  default:
    return 0;
  }
}

void processAquariteSettings(int startNr, int endNr) {
  doNothing(endNr);
  int saltPercentage = processDataValues[startNr];
  // 101% is Boost
  // 255% is when the Power Cente ris in Service mode
  LOG_SALTPCT_VAL = str(saltPercentage);
  logTxt("SET", LOGTXT_TYPE);
  logTxt(saltPercentage+"% ", LOGTXT_DATA);
}

//=========//
// EMULATE //
//=========//
void emulateAQUARITE(int command, int destination) {
  if ( emulateThisDevice(destination) == 1) {
    switch(command) {
      case(CMD_PROBE):
      send_ACK("AQUARITE", 2);
      break;
      case(RESP_AQUARITE_STAT):
      sendAquariteStatus(AQRppm, AQRStatus);
      break;
    default:
      logTxtLn("UNKNOWN EMU COMMAND!! "+reportVal(command, 2)+" DEST: "+reportVal(destination, 2), LOGTXT_WARNING);
    }
  }
}

void sendAquariteStatus(int ppmVal, int Status) {
  sendDataValues[0] = RESP_AQUARITE_STAT;
  sendDataValues[1] = ppmVal;
  sendDataValues[2] = Status;
  sendDataValues[3] = (0x00);
  sendDataValues[4] = (0x00);
  //  sendDataValues[5] = (0x00);
  sendEmulatorData(DEV_MASTER_MASK, 5);
  emulatorInfo("<== EMU CHEMLINK STATUS COMMAND");
}

//==================//
// PROCESS RESPONSE //
//==================//

int processAquariteResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  doNothing(response);
  switch(command) {
    case(CMD_AQUARITE_STAT) :
    processAquariteResponse_Status(startNr, endNr);
    return 1;
    case(CMD_AQUARITE_IDENT) :
    processAquariteResponse_Ident(startNr, endNr);
    return 1;
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

void processAquariteResponse_Status( int startNr, int endNr) {
  int saltPPM = processDataValues[startNr]*100;
  LOG_SALTPPM_VAL = str(saltPPM);
  logTxt("STATUS: ", LOGTXT_TYPE);
  startNr++;
  int aquaRiteStatus = byte(processDataValues[startNr]);
  logTxt("PPM: "+saltPPM+" "+"STATUS: "+reportVal(aquaRiteStatus, 2), LOGTXT_DATA);
  if ( (aquaRiteStatus&STAT_AQUARITE_NOFLOW) == STAT_AQUARITE_NOFLOW ) {
    logTxt(" NO FLOW", LOGTXT_DATA);
  } 
  if ( (aquaRiteStatus&STAT_AQUARITE_HISALT) == STAT_AQUARITE_HISALT ) {
    logTxt(" HIGH SALT", LOGTXT_DATA);
  }
  if ( (aquaRiteStatus&STAT_AQUARITE_LOSALT) == STAT_AQUARITE_LOSALT ) {
    logTxt(" LOW SALT", LOGTXT_DATA);
  } 
  if ( (aquaRiteStatus&STAT_AQUARITE_GENERAL) == STAT_AQUARITE_GENERAL ) {
    logTxt(" GENERAL FAULT", LOGTXT_DATA);
  } 
  if ( aquaRiteStatus == STAT_AQUARITE_OK ) {
    logTxt(" OK", LOGTXT_DATA);
  } 
  logTxt(" ", LOGTXT_DATA);
  startNr++;
  logTxtData(startNr, endNr);
}

void processAquariteResponse_Ident( int startNr, int endNr) {
  //000177 / 002312 ____ Found 19 bytes: 00 03 01 41 71 75 61 50 75 72 65 00 00 00 00 00 00 00 00  ==> 
  String optStr = "ID: \"";
  for ( int i=startNr; i< endNr; i++ ) {
    optStr += getASCIIString(processDataValues[i]);
  }
  logTxt(optStr+"\"", LOGTXT_TYPE);
}