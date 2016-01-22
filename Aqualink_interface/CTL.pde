//=================//
//=== CTL COMMS ===//
//=================//
//=======================//
//===== Key Presses =====//
// Commands //
final int CMD_CTL_PROBE     = CMD_PROBE;    //0x00
final int CMD_CTL_STATUS    = CMD_STATUS;   //0x02
final int CMD_CTL_MSG       = CMD_MSG;      //0x03
final int CMD_CTL_MSG_LONG  = CMD_MSG_LONG; //0x04

final int CMD_CTL_0x08       = 0x08;
/* KEYPRESS CODES */
final int CTL_ACK_NOBUTTON   = 0x00;
final int CTL_ACK_PUMP       = 0x02;
final int CTL_ACK_SPA        = 0x01;
final int CTL_ACK_AUX1       = 0x05;
final int CTL_ACK_AUX2       = 0x0a;
final int CTL_ACK_AUX3       = 0x0f;
final int CTL_ACK_AUX4       = 0x06;
final int CTL_ACK_AUX5       = 0x0b;
final int CTL_ACK_AUX6       = 0x10;
final int CTL_ACK_AUX7       = 0x15;
final int CTL_ACK_EXTRA      = 0x1D;

final int CTL_ACK_HTR_POOL   = 0x12;
final int CTL_ACK_HTR_SPA    = 0x17;
final int CTL_ACK_HTR_SOLAR  = 0x1c;

final int CTL_ACK_MENU       = 0x09;
final int CTL_ACK_CANCEL     = 0x0e;
final int CTL_ACK_LEFT       = 0x13;
final int CTL_ACK_RIGHT      = 0x18;

final int CTL_ACK_HOLD       = 0x19;
final int CTL_ACK_OVERRIDE   = 0x1e;

// CONTROL BUTTON STATUS SETUP
final int CTL_STAT_AUX7[]        = {
  0, 0x01
};
final int CTL_STAT_AUX3[]        = {
  0, 0x10
};
final int CTL_STAT_AUX2[]        = {
  0, 0x40
};

final int CTL_STAT_AUX1[]        = {
  1, 0x01
};
final int CTL_STAT_SPA[]         = {
  1, 0x04
};
final int CTL_STAT_PUMP[]        = {
  1, 0x10
};
final int CTL_STAT_PUMP_BLINK[]  = {
  1, 0x20
};
final int CTL_STAT_AUX5[]        = {
  1, 0x40
};


final int CTL_STAT_AUX4[]        = {
  2, 0x01
};

final int CTL_STAT_AUX6[]        = {
  2, 0x40
};


final int CTL_STAT_HTR_POOL_ON[] = {
  3, 0x10
};
final int CTL_STAT_HTR_POOL_EN[] = {
  3, 0x40
};


final int CTL_STAT_HTR_SPA_ON[]  = {
  4, 0x01
};
final int CTL_STAT_HTR_SPA_EN[]  = {
  4, 0x04
};
final int CTL_STAT_HTR_SOL_ON[]  = {
  4, 0x10
};
final int CTL_STAT_HTR_SOL_EN[]  = {
  4, 0x40
};

//final String CTLPOOLTEMPMSG = "POOL TEMP"; // rev R
//final String CTLAIRTEMPMSG  = " AIR TEMP"; // rev R
final String CTLPOOLTEMPMSG = "Pool Temp";
final String CTLAIRTEMPMSG  = " Air Temp";
final int CTLTEMPMSGLENGTH  = 9;
//int poolTemp;
//int airTemp;

int processCTLCommand (int command, int destination) {
  doNothing(destination);
  switch(command) {
    case(CMD_CTL_PROBE):
    logTxtProbe();
    return 1;
    case(CMD_CTL_STATUS) :
    logTxt("STATUS", LOGTXT_TYPE);
    logTxt(checkCTLButtonStatus(2, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_CTL_MSG) :
    logTxt("MESSAGE", LOGTXT_TYPE);
    logTxt("ARG="+reportVal(processDataValues[2], 2)+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    if ( compareMessage( 3, CTLTEMPMSGLENGTH, CTLPOOLTEMPMSG) == 1) {
      int poolTemp = readTemp(CTLTEMPMSGLENGTH + 4);
      //print("POOL TEMP:");
      //print(poolTemp);
      //println("F");
      LOG_POOLTEMP_VAL = str(poolTemp);
    }
    if ( compareMessage( 3, CTLTEMPMSGLENGTH, CTLAIRTEMPMSG) == 1 ) {
      int airTemp = readTemp(CTLTEMPMSGLENGTH + 3);
      /*
      print("AIR TEMP:");
       print(airTemp);
       println("F");
       */
      LOG_AIRTEMP_VAL = str(airTemp);
    }
    return 1;
    case(CMD_CTL_MSG_LONG) :
    logTxt("MESSAGE LONG", LOGTXT_TYPE);
    logTxt("ARG="+reportVal(processDataValues[2], 2)+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    return 1;
    case(CMD_CTL_0x08):
    logTxt("CMD 0x08", LOGTXT_TYPE);
    logTxt("ARG="+reportVal(processDataValues[2], 2)+" DATA:", LOGTXT_DATA);
    logTxt(printDataBytes(0, 1, 3, processDataValuesCtr), LOGTXT_DATA);
    return 1;
  default:
    return 0;
  }
}

int processCTLResponse(int deviceID, int command, int response, int startNr, int endNr) {
  doNothing(deviceID);
  //String initString = "";
  switch(command) {
    case(CMD_PROBE):
    processPROBEResponse(lastDestination);
    return 1;
    case (CMD_CTL_STATUS):
    processCTLButtonData(startNr, endNr);
    return 1;
    case(CMD_CTL_MSG):
    logTxt("CMD 0x03", LOGTXT_TYPE);
    logTxtData(startNr, endNr);
    return 1;
    case(CMD_CTL_MSG_LONG):
    logTxt("CMD 0x04", LOGTXT_TYPE);
    logTxtData(startNr, endNr);
    return 1;
  default:
    unknownResponse( deviceID, command, response, startNr, endNr);
    return 0;
  }
}

void processCTLButtonData( int startNr, int endNr) {
  int ACKValue = 0;
  String initString = "";
  for ( int i=startNr; i< endNr; i++ ) {
    ACKValue += processDataValues[i];
  }
  switch (ACKValue) {
    case (CTL_ACK_AUX1):
    initString += "AUX1 BUTTON";
    break;
    case (CTL_ACK_AUX2):
    initString += "AUX2 BUTTON";
    break;
    case (CTL_ACK_AUX3):
    initString += "AUX3 BUTTON";
    break;
    case (CTL_ACK_AUX4):
    initString += "AUX4 BUTTON";
    break;
    case (CTL_ACK_AUX5):
    initString += "AUX5 BUTTON";
    break;
    case (CTL_ACK_AUX6):
    initString += "AUX6 BUTTON";
    break;
    case (CTL_ACK_AUX7):
    initString += "AUX7 BUTTON";
    break;
    case (CTL_ACK_EXTRA):
    initString += "EXTRA AUX BUTTON";
    break;
    case (CTL_ACK_PUMP):
    initString += "PUMP BUTTON";
    break;
    case (CTL_ACK_SPA):
    initString += "SPA BUTTON";
    break;
    case (CTL_ACK_HTR_POOL):
    initString += "POOL HEAT BUTTON";
    break;
    case (CTL_ACK_HTR_SPA):
    initString += "SPA HEAT BUTTON";
    break;
    case (CTL_ACK_HTR_SOLAR):
    initString += "SOLAR HEAT BUTTON";
    break;
    case (CTL_ACK_MENU):
    initString += "MENU BUTTON";
    break;
    case (CTL_ACK_CANCEL):
    initString += "CANCEL BUTTON";
    break;
    case (CTL_ACK_LEFT):
    initString += "LEFT BUTTON";
    break;
    case (CTL_ACK_RIGHT):
    initString += "RIGHT BUTTON";
    break;
    case (CTL_ACK_HOLD):
    initString += "HOLD BUTTON";
    break;
    case (CTL_ACK_OVERRIDE):
    initString += "OVERRIDE BUTTON";
    break;
    case (CTL_ACK_NOBUTTON):
    break;
  default:
    initString += "UNKNOWN BUTTON "+reportVal(ACKValue, 2);
    break;
  }
  logTxt(initString, LOGTXT_DATA);
}

String checkCTLButtonStatus ( int startPos, int endPos) {
  String returnVal = "";
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX1, startPos, endPos) == 1) {
    returnVal += "SPILLWAY " ;
  }
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX2, startPos, endPos) == 1) {
    returnVal += "AIR " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX3, startPos, endPos) == 1) {
    returnVal += "AUX3 " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX4, startPos, endPos) == 1) {
    returnVal += "SPA_LIGHT " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX5, startPos, endPos) == 1) {
    returnVal += "POOL_LIGHT " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX6, startPos, endPos) == 1) {
    returnVal += "AUX6 " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_AUX7, startPos, endPos) == 1) {
    returnVal += "AUX7 " ;
  }
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_PUMP, startPos, endPos) == 1) {
    returnVal += "FILTER " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_PUMP_BLINK, startPos, endPos) == 1) {
    returnVal += "PUMP_BLINK " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_SPA, startPos, endPos) == 1) {
    returnVal += "SPA " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_HTR_POOL_EN, startPos, endPos) == 1) {
    returnVal += "POOL_HEAT_EN " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_HTR_POOL_ON, startPos, endPos) == 1) {
    returnVal += "POOL_HEAT_ON " ;
  }  
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_HTR_SPA_ON, startPos, endPos) == 1) {
    returnVal += "SPA_HEAT_ON " ;
  }
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_HTR_SOL_EN, startPos, endPos) == 1) {
    returnVal += "SOL_HEAT_EN " ;
  }
  if ( buttStat(CTL_EXPECTED_BUTTSTAT_BYTES, CTL_STAT_HTR_SOL_ON, startPos, endPos) == 1) {
    returnVal += "SOL_HEAT_ON " ;
  }
  if ( returnVal == "" ) {
    return "NIL";
  } 
  return returnVal;
}