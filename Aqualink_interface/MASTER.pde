//====================//
//=== MASTER COMMS ===//
//====================//

int processResponseToMASTER(int response, int destination) {
  if ( lastDestination == DEV_MASTER_MASK ) {
    logTxtLn("LAST DESTINATION WAS MASTER in processResponseToMASTER! ", LOGTXT_WARNING);
  }
    if ( destination != DEV_MASTER_MASK ) {
    logTxtLn("DESTINATION WAS NOT MASTER in processResponseToMASTER! ", LOGTXT_WARNING);
  }
  int lastDestinationMask = lastDestination&0xF8;
  //outputLogFileHandle.println("PROCMASTERRESPONSE COMM="+response+" LAST DEST: 0x"+reportVal(lastDestination, 2)+" ==>0x"+reportVal(lastDestinationMask, 2));
  switch(lastDestinationMask) {
    case ( DEV_AQUARITE_MASK ) :
    return processAquariteResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_PCDOCK_MASK ) :
    return processPCDOCKResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_LXI_LRZE_MASK ) :
    return processLXI_LRZEResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_CHEMLINK_MASK ) :
    return processCHEMLINKResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_ONETOUCH_MASK ) :
    return processONETOUCHResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_AQUALINK_MASK ) :
    return processAQUALINKResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_CTL_MASK ) :
    return processCTLResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_SPA_MASK ) :
    return processSPAResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_RPC_MASK ) :
    return processRPCResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
    case ( DEV_AQUALINK_2_MASK ) :
    return processAQUALINK_2_Response(lastDestination, lastCommand, response, 2, processDataValuesCtr);
  default:
    return processOTHERResponse(lastDestination, lastCommand, response, 2, processDataValuesCtr);
  }
}

int processOTHERResponse(int deviceID, int command, int response, int startNr, int endNr) {
  //String initString = "";
  switch(command) {
    case(CMD_ACK) :
    processACK( startNr, endNr);
    return 1;
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

void processPROBEResponse(int lastDestination) {
  logTxtProbeACK();
  if ( weAreEmulatingPowerCenter() == 1 ) {
    if ( powerCenterEmulatorIsProbingAll == 0 ) {
      //========================//
      // Power Center Emulation //
      //========================//
      // Check if we received an ACK when we're emulating a Power Center
      // CLEAN UP, MAKE SMARTER!!!! //
      /*
      int powerCenterEmulatorNr = findEmulatePowerCenterIDsNr(lastDestination);
       if ( powerCenterEmulatorNr >= 0 ) {
       if ( powerCenterEmulateStage[powerCenterEmulatorNr] == POWERCENTEREMULATE_STARTUP ) {
       // We got an ACK, so let's emulate the next stage
       setPowerCenterEmulateStage(lastDestination, POWERCENTEREMULATE_INIT);
       //          powerCenterEmulateStage[powerCenterEmulatorNr] = POWERCENTEREMULATE_INIT;
       } else {
       setPowerCenterEmulateStage(lastDestination, POWERCENTEREMULATE_RUN);
       //          powerCenterEmulateStage[powerCenterEmulatorNr] = POWERCENTEREMULATE_RUN;
       }
       }
       */
      // We got an ACK, so let's emulate the next stage
      setPowerCenterEmulateStage(lastDestination, POWERCENTEREMULATE_INIT);
    }
  }
}

void processACK(int startNr, int endNr) {
  //=====================//
  // Process the message //
  //=====================//
  // See if the ACK contained data
  int printBytes = 0;
  if ( !displayThisOption("dontShowZeroACKData") ) {
    printBytes = 1;
  }
  for ( int i=startNr; i< endNr; i++ ) {
    if ( processDataValues[i] != 0 ) {
      printBytes = 1;
    }
  }
  logTxt("ACK  ", LOGTXT_TYPE);
  if ( printBytes == 1) {
    logTxtData(startNr, endNr);
  }
}