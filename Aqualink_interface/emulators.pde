int emulateThisDevice(int destination) {
  if ( readFileData == 1 ) {
    return 0;
  }
  for ( int i = 0; i<emulateDeviceIDsCtr; i++ ) {
    if ( destination == emulateDeviceIDs[i]) {
      return 1;
    }
  }
  return 0;
}

void send_ACK(String ackDevice, int nrACKZeros) {
  sendDataValues[0] = CMD_ACK;
  for ( int i=1; i<= nrACKZeros; i++ ) {
    sendDataValues[i] = NULChar;
  }
  sendEmulatorData(DEV_MASTER_MASK, nrACKZeros+1);
  emulatorInfo("<== EMU ACK: "+ackDevice);
}

void sendByte(int val ) {
  emulatorDataValues[emulatorDataValuesCtr] = val;
  emulatorDataValuesCtr++;
}

void emulateAllAvailableData() {
  if ( (receiveLineBusy == 1 )&&(getAccurateMilliTime() < lastReceivedByteTimeMicro + LINEBUSYTIMEOUT)) {
    if ( debugThis(DEBUG_RECEIVELINE) ) {
      print("Waiting for busy line");
    }
  } else {  
    while ( emulatorDataValuesCtr > 0 ) {
      // Process the emulator data first
      int data = processEmulatorData();
      // This takes about 1.34ms in order to send the Serial data
      if ( readFileData == 0 ) {
        // We're not reading (or replaying) a logFile
        if ( debugThis( DEBUG_RECEIVELINE )) {
          print(char(data)+"="+reportVal(data, 2)+" ");
        }
        currentOpenPort.write(data);
      } 
      processIncomingData(-1, data);
    }
    emulatorCommandsInQueue = 0;
  }
}

void sendEmulatorData(int destination, int dataSize) {
  //timeStamp("SEDSTART");
  //println("SENDEM LD "+lastDestination+" DE: "+destination);
  sendDataValuesCtr = dataSize;
  int checkSum = processSendChecksumData( destination);
  int stuffZeros = 0;
  if ( stuffZeros == 1 ) {
    sendByte(NULChar);
    sendByte(NULChar);
  }
  sendByte(DLEChar);
  sendByte(STXChar);
  sendByte(destination);
  if ( destination == DLEChar ) {
    sendByte(NULChar); // Send escape Char
  }
  for (int i=0; i<dataSize; i++ ) {
    sendByte(sendDataValues[i]) ;
    if ( sendDataValues[i] == DLEChar ) {
      sendByte(NULChar); // Send escape Char
    }
  }
  sendByte(checkSum);
  if ( checkSum == DLEChar) {
    //print(" ESC ");
    sendByte(NULChar);
  }      
  // Send the endchars
  sendByte(DLEChar);
  sendByte(ETXChar);
  //timeStamp("SEDEND");
}

int processEmulatorData() {
  // Read next emulated value
  // Print if necessary
  // Return it as a value
  int val = emulatorDataValues[emulatorDataValuesCtrCurrent];
  // Send the response
  //if ( readFileData == 0 ) {
  //  currentOpenPort.write(val);
  //} 
  if ( displayThisOption("showRawIncomingHexData") ) {
    logFileHandle.print("E");
  }
  emulatorDataValuesCtrCurrent++;
  if (emulatorDataValuesCtrCurrent == emulatorDataValuesCtr ) {
    // We're done
    emulatorDataValuesCtr = 0;
    emulatorDataValuesCtrCurrent = 0;
  }
  return val;
}

void emulatorInfo(String str) {
  if ( debugThis(DEBUG_SHOWEMULATORINFO) ) {
    logTxtLn(str, LOGTXT_INFO);
  }
}

//==========================
// Power Center emulation
//==========================

void powerCenterEmulateNext(boolean emulatePowerCenter) {
  if ( emulatePowerCenter ) {
    // Do not start a new command if there is still one in the queue
    currentEmulatorTime = getAccurateMilliTime();
    if ( currentEmulatorTime > newEmulatorActionTime ) {
      if ( (emulatorCommandsInQueue < MAXNROFEMULATORCOMMANDSINQUEUE ) ) {
        //logFileHandle.println("TIM: "+currentEmulatorTime+" DELTA "+(currentEmulatorTime - newEmulatorActionTime));
        //println("TIM: "+currentEmulatorTime+" DELTA "+(currentEmulatorTime - newEmulatorActionTime));
        newEmulatorActionTime = currentEmulatorTime + powerCenterEmulatorTimeout;
        sentCommands += 1;
        switch(powerCenterEmulateStage[powerCenterEmulatorNextNr]) {
        case POWERCENTEREMULATE_STARTUP:
          sendProbe(emulatePowerCenterIDs[powerCenterEmulatorNextNr]);
          break;
        case POWERCENTEREMULATE_INIT:
          sendInit(emulatePowerCenterIDs[powerCenterEmulatorNextNr]);
          break;
        case POWERCENTEREMULATE_RUN:
          sendRun(emulatePowerCenterIDs[powerCenterEmulatorNextNr]);
          break;
        }
        emulatorCommandsInQueue += 1;
      } else {
        if ( debugThis( DEBUG_RECEIVELINE )) {
          println("There is still an emulator command in the queue");
        }
      }
      powerCenterEmulatorNextNr++;
      if ( powerCenterEmulatorNextNr==emulatePowerCenterIDsCtr ) {
        powerCenterEmulatorNextNr = 0;
      }
    }
  }
}

void setEmulatorInitStage(int deviceID, int stage) {
  // Make sure we're emulating first
  if ( weAreEmulatingPowerCenter() == 1 ) {
    if ( debugThis(DEBUG_SHOWEMULATORINFO2) == true) {
      logTxtLn("SET INIT for ID "+reportVal( deviceID, 2)+" ==> "+stage, LOGTXT_DEBUG);
    }
    emulatorInitStage[findEmulatePowerCenterIDsNr(deviceID)] = stage;
  }
}

void setEmulatorRunStage(int deviceID, int stage) {
  if ( weAreEmulatingPowerCenter() == 1 ) {
    if ( debugThis(DEBUG_SHOWEMULATORINFO2) == true) {
      logTxtLn("SET RUN  for ID "+reportVal(deviceID, 2)+" ==> "+stage, LOGTXT_DEBUG);
    }
    emulatorRunStage[findEmulatePowerCenterIDsNr(deviceID)] = stage;
  }
}

void setPowerCenterEmulateStage(int deviceID, int stage ) {
  if ( weAreEmulatingPowerCenter() == 1 ) {
    int emulatePowerCenterIDsNr = findEmulatePowerCenterIDsNr(deviceID);
    if ( emulatePowerCenterIDsNr >=0 ) {
      powerCenterEmulateStage[emulatePowerCenterIDsNr] = stage;
      switch(stage) {
      case POWERCENTEREMULATE_INIT:
        setEmulatorInitStage(deviceID, 1);
        break;
      case POWERCENTEREMULATE_RUN:
        setEmulatorRunStage(deviceID, 1);
        break;
      }
    }
  }
}

void sendProbe(int emulateProbeID) {
  setEmulatorInitStage(emulateProbeID, 0);
  setEmulatorRunStage(emulateProbeID, 0);
  //0x10 0x02   0x80 0x00                                                                    0x92 0x10 0x03 
  sendDataValues[0] = CMD_PROBE;
  if ( emulateProbeID == POWERCENTER_PROBE_ALL_DEVICES ) {
    powerCenterEmulatorIsProbingAll = 1;
    sendEmulatorData(currentPowerCenterIDBeingProbed, 1);
    emulatorInfo("<== EMU PROBE SCAN: "+reportVal(currentPowerCenterIDBeingProbed, 2));
    currentPowerCenterIDBeingProbed++;
    if ( currentPowerCenterIDBeingProbed > 0xFE ) {
      currentPowerCenterIDBeingProbed = DEV_CTL_MASK;
    }
  } else {
    powerCenterEmulatorIsProbingAll = 0;
    sendEmulatorData(emulateProbeID, 1);
    emulatorInfo("<== EMU PROBE: "+reportVal(emulateProbeID, 2));
  }
}

void sendInit(int emulateInitID) {
  int powerCenterEmulatorNr = findEmulatePowerCenterIDsNr(emulateInitID);
  int emulateInitIDMASK = convertIDToMask(emulateInitID);
  //println("SENDINIT "+emulateInitID+" NR="+powerCenterEmulatorNr);
  switch(emulateInitIDMASK) {
  case DEV_CHEMLINK_MASK:
    switch(emulatorInitStage[powerCenterEmulatorNr]) {
    case 1:
      // GET ORP
      sendDataValues[0] = CMD_CHEMLINK_GETPH;
      sendEmulatorData(emulateInitID, 1);
      emulatorInfo("<== EMU INIT GET ORP: "+reportVal(emulateInitID, 2));
      break;
    case 2:
      // GET PH
      sendDataValues[0] = CMD_CHEMLINK_GETORP;
      sendEmulatorData(emulateInitID, 1);
      emulatorInfo("<== EMU INIT GET PH: "+reportVal(emulateInitID, 2));
      break;
    case 3:
      // CMD 0x09
      sendDataValues[0] = CMD_CHEMLINK_0x09;
      sendDataValues[1] = 0x00;
      sendEmulatorData(emulateInitID, 2);
      emulatorInfo("<== EMU INIT CMD 0x09: "+reportVal(emulateInitID, 2));
      break;
    }
    break;
  case DEV_AQUALINK_MASK:
    switch(emulatorInitStage[powerCenterEmulatorNr]) {
    case 1:
      // CMD 0x29
      sendDataValues[0] = CMD_AQUALINK_0x29;
      sendEmulatorData(emulateInitID, 1);
      emulatorInfo("<== EMU INIT CMD 0x29: "+reportVal(emulateInitID, 2));
      break;
    case 2:
      // CMD 0x30
      sendDataValues[0] = CMD_AQUALINK_0x30;
      sendEmulatorData(emulateInitID, 1);
      emulatorInfo("<== EMU INIT CMD 0x30: "+reportVal(emulateInitID, 2));
      break;
    }
    break;
  case DEV_AQUARITE_MASK:
    switch(emulatorInitStage[powerCenterEmulatorNr]) {
    case 1:
      sendDataValues[0] = CMD_AQUARITE_STAT;
      sendDataValues[1] = AQRppm;
      sendEmulatorData(emulateInitID, 2);
      emulatorInfo("<== EMU INIT STAGE 1 "+reportVal(emulateInitID, 2));
      break;
    default:
      println("Unknown emulator init stage "+emulatorInitStage[powerCenterEmulatorNr]+" for ID "+reportVal(emulateInitID, 2));
      break;
    }
  case DEV_ONETOUCH_MASK:
    switch(emulatorInitStage[powerCenterEmulatorNr]) {
    case 1:
      sendDataValues[0] = CMD_ONETOUCH_STATUS;
      sendDataValues[1] = 0;
      sendDataValues[2] = 0;
      sendDataValues[3] = 0;
      sendDataValues[4] = 0;
      sendDataValues[5] = 0;
      sendEmulatorData(emulateInitID, 6);
      emulatorInfo("<== EMU INIT STAGE 1 "+reportVal(emulateInitID, 2));
      break;
    case 2:
      sendDataValues[0] = CMD_ONETOUCH_0x05;
      sendEmulatorData(emulateInitID, 1);
      emulatorInfo("<== EMU INIT STAGE 2 "+reportVal(emulateInitID, 2));
      break;
    default:
      println("Unknown emulator init stage "+emulatorInitStage[powerCenterEmulatorNr]+" for ID "+reportVal(emulateInitID, 2));
      break;
    }
    break;
  default:
    println("Unknown sendInit ID: "+reportVal(emulateInitID, 2));
  }
}

void sendRun(int emulateRunID) {
  int powerCenterEmulatorNr = findEmulatePowerCenterIDsNr(emulateRunID);
  int emulateRunIDMASK = convertIDToMask(emulateRunID);
  switch(emulateRunIDMASK) {
  case DEV_CHEMLINK_MASK:
    switch(emulatorRunStage[powerCenterEmulatorNr]) {
    case 1:
      // CMD 0x02
      sendDataValues[0] = CMD_STATUS;
      sendEmulatorData(emulateRunID, 1);
      emulatorInfo("<== EMU RUN CMD STATUS: "+reportVal(emulateRunID, 2));
      break;
    case 2:
      // CMD 0x18
      sendDataValues[0] = CMD_CHEMLINK_0x18;
      sendDataValues[1] = 0x00;
      sendEmulatorData(emulateRunID, 2);
      emulatorInfo("<== EMU RUN CMD 0x18: "+reportVal(emulateRunID, 2));
      break;
    }
    break;
  case DEV_AQUARITE_MASK:
    //H10 H02 H50 H11 H14 H87 H10 H03 
    sendDataValues[0] = CMD_AQUARITE_STAT;
    sendDataValues[1] = 0x14;
    sendEmulatorData(emulateRunID, 2);
    emulatorInfo("<== EMU RUN AQUARITE STAT: "+reportVal(emulateRunID, 2));
    break;
  case DEV_AQUALINK_MASK:
    switch(emulatorRunStage[powerCenterEmulatorNr]) {
    case 1:
      sendDataValues[0] = CMD_AQUALINK_0x29;
      sendDataValues[1] = 0x0C;
      sendEmulatorData(emulateRunID, 2);
      emulatorInfo("<== EMU RUN CMD 0x29: "+reportVal(emulateRunID, 2));
      break;
    case 2:
      sendDataValues[0] = CMD_AQUALINK_0x30;
      sendDataValues[1] = 0x30;
      sendEmulatorData(emulateRunID, 2);
      emulatorInfo("<== EMU RUN CMD 0x29: "+reportVal(emulateRunID, 2));
      break;
    }
    break;
  case DEV_ONETOUCH_MASK:
    switch(emulatorRunStage[powerCenterEmulatorNr]) {
    case 1:
      // CLEAR SCREEN 0x02
      sendDataValues[0] = CMD_ONETOUCH_CLEAR;
      sendDataValues[1] = 0;
      sendDataValues[2] = 0;
      sendEmulatorData(emulateRunID, 3);
      emulatorInfo("<== EMU RUN CMD STATUS: "+reportVal(emulateRunID, 2));
      break;
    case 2:
      sendONETOUCHMessage(emulateRunID, ONETOUCHEMUMessageLineNr, "EMU Line "+ONETOUCHEMUMessageLineNr);
      break;
    case 3:
      sendONETOUCHHighLight(emulateRunID, ONETOUCHEMUHighlightLineNr);
      break;
    case 4:
      sendDataValues[0] = CMD_ONETOUCH_STATUS;
      sendDataValues[1] = 0;
      sendDataValues[2] = 0;
      sendDataValues[3] = 0;
      sendDataValues[4] = 0;
      sendDataValues[5] = 0;
      sendEmulatorData(emulateRunID, 6);
      emulatorInfo("<== EMU RUN CMD STATUS: "+reportVal(emulateRunID, 2));
      break;
    }
    break;

  default:
    println("Unknown Run Stage "+emulatorRunStage[powerCenterEmulatorNr]+" for ID: "+reportVal(emulateRunID, 2));
  }
}

int findEmulatePowerCenterIDsNr(int emulatorID) {
  if ( emulatePowerCenterIDsCtr == 0 ) {
    // We're not emulating
    return -1;
  }
  if ( emulatePowerCenterIDs[powerCenterEmulatorNextNr] == POWERCENTER_PROBE_ALL_DEVICES ) {
    //FLAKY, GET BETTER SOLUTION FOR PROBE ALL DEVICES
    return powerCenterEmulatorNextNr;
  }
  for ( int i = 0; i< emulatePowerCenterIDsCtr; i++ ) {
    if ( emulatePowerCenterIDs[i] == emulatorID ) {
      return i;
    }
  }
  println("Unknown findEmulatePowerCenter ID "+reportVal(emulatorID, 2)+" in findEmulatePowerCenterIDsNr");
  return -1;
}

void addEmulatePowerCenterID(int emulatePowerCenterMask) {
  if ( emulatePowerCenterIDsCtr == MAXNREMULATEPOWERCENTERIDS ) {
    println("Warning! Max # Emulate Power Center IDs ("+MAXNREMULATEPOWERCENTERIDS+") exceeded!");
  } else {
    emulatePowerCenterIDs[emulatePowerCenterIDsCtr] = emulatePowerCenterMask;
    emulatePowerCenterIDsCtr++;
  }
}

void initEmulatePowerCenterIDs() {
  powerCenterEmulatorIDsList = "Power Center Emulator IDs = ";
  for ( int i = 0; i< emulatePowerCenterIDsCtr; i++ ) {
    powerCenterEmulatorIDsList += reportVal(emulatePowerCenterIDs[i], 2) + " ";
    powerCenterEmulateStage[i] = POWERCENTEREMULATE_STARTUP;
  }
}

int weAreEmulatingPowerCenter() {
  if ( emulatePowerCenterIDsCtr > 0 ) {
    return 1;
  } else {
    return 0;
  }
}

void addEmulatDeviceID(int emulateDeviceMask) {
  if ( emulateDeviceIDsCtr == MAXNREMULATEPOWERCENTERIDS ) {
    println("Warning! Max # Emulate Device IDs ("+MAXNREMULATEDEVICEIDS+") exceeded!");
  } else {
    emulateDeviceIDs[emulateDeviceIDsCtr] = emulateDeviceMask;
    emulateDeviceIDsCtr++;
  }
}