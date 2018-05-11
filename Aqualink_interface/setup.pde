void readSetupValues() {
  //===============//
  // debug options //
  //===============//  
  // debug                       |= DEBUG_ON ;                 
  // debug                       |= DEBUG_DETAILS ;            
  // debug                       |= DEBUG_WRITEDEBUG2LOG ;     
  // debug                       |= DEBUG_CHANGEREADOUTSTATUS ;
  // debug                       |= DEBUG_RECEIVELINE ;        
  // debug                       |= DEBUG_SHOWPROCESSINCOMING ;
  // debug                       |= DEBUG_SHOWEMULATORINFO ;
  // debug                       |= DEBUG_SHOWWHENDATAISDROPPED ;
  // debug                       |= DEBUG_SHOWDISPLAYOPTIONINFO;
  // debug                       |= DEBUG_PULSEDRAWWITHZEROS;
  // debug                       |= DEBUG_SHOWTIMESTAMPWITHRAWDATA;
  // debug                       |= DEBUG_ALWAYSPRINTLOGTXTSTRINGNUMBERS;

  verboseDataDebugLevel    = 0;
  dontOverWriteOutputFiles = true;

  //=================//
  // Display Options //
  //=================//
  displayOptionNameList = "Display options           = \"";
  setDisplayOption("showUnprocessedData", false);  // Show the incoming hex bytes before they are processed
  setDisplayOption("showRawIncomingHexData", false);  // Show incoming data (in HEX) as it is being read
  setDisplayOption("showVerboseDataInLog", true);  // Show Verbose Data in the log file
  setDisplayOption("suppressChecksumErrors", false);  // Don't complain about Checksum errors
  setDisplayOption("showDroppedData", true);  // Show the dropped data (due to checksum errors, colissions,...)
  setDisplayOption("dontShowZeroACKData", false);  // Don't show the data values following an ACK if they're all 0
  setDisplayOption("onlyShowNewStrings", false);  // Only show decoded data if it is new
  setDisplayOption("dontShowEmptyProbes", true);  // Don't show probes that have not been responded to
  setDisplayOption("showTimeDeltas", true);  // Show time delta since last data
  setDisplayOption("suppressReadoutWarnings", false);  // Suppress warnings about the readout (Dropped packets,...) 
  setDisplayOption("suppressReadoutInfo", false);  // Suppress info about the readout (LOGTXT_INFO lines)
  setDisplayOption("suppressReadoutErrors", true);  // Suppress errors about the readout (Dropped packets,...)
  setDisplayOption("showCommandResponse", true);  // Show the response to the MASTER
  setDisplayOption("addSpaceBetweenDevices", false);  // Add extra line between device outputs
  setDisplayOption("showProcessedBytesStatistics", true);  // Show Statistics about the processed bytes
  setDisplayOption("pulseDrawWithZeros", false);  // Send 0x00 on serial port (if applicable) everytime the draw() loop restarts
  setDisplayOption("addCSValueToLogTxt", false);  // Show checksum values in logTxt prints
  setDisplayOption("reportDataInDecimal", false); // Report data in decimal instead of hex
  setDisplayOption("printDataToScreen", true); // Report data in decimal instead of hex
  setDisplayOption("useSteppedReplay", false); // 
  setDisplayOption("toggleSteppedReplay", false); // 
  setDisplayOption("printReplayStatistics", false); // 
  setDisplayOption("onlyReportNewValuesinLog", true); // 
  setDisplayOption("useRefreshTime", true); // 
  setDisplayOption("showMemoryStatistics", false); // 

  displayOptionNameList += "\"";

  showDisplayOptions = 0;
  showInfoTextCanvas = 1;
  showPlayButton     = 1;
  showValuesCanvas   = 1;

  //========================//
  // CUSTOMIZE THIS SECTION //
  //========================//

  // Record or read data to/from file
  readFileData = READFILEDATA_CREATE;       // Default mode - read the data, process and record it
  // readFileData = READFILEDATA_READ ;        // reread and potentially fix the file, but don't process
  // readFileData = READFILEDATA_READ_PROCESS; // reread and process the file
  // readFileData = READFILEDATA_REPLAY_ONCE;  // reread and replay once
  // readFileData = READFILEDATA_REPLAY_LOOP;  // reread and loop a replay

  replayDelay                = 50; // Delay between replayed Commands or Responses
  powerCenterEmulatorTimeout = 50;
  // rawLogFileReadNameBase = "Jandy_log_94201518599_Jacy_Chemlink"; 
  // rawLogFileReadNameBase = "Jandy_log_942015185411_Jacy1";
  // rawLogFileReadNameBase = "POOL_REFILL";
  // rawLogFileReadNameBase = "ONETOUCH_STARTUP";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY_2";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY_3";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY_SHORT";
  // rawLogFileReadNameBase = "ONETOUCH_LINES_INVERTED";
  // rawLogFileReadNameBase = "ONETOUCH_HIGHLIGHT_LINES";
  // rawLogFileReadNameBase = "Onetouch_on_Live_System";
  // rawLogFileReadNameBase = "Onetouch_Showing_ABOUT_with_Highlight";
  // rawLogFileReadNameBase = "System_Restart_Couldnt_find_Chemlink";
  // rawLogFileReadNameBase = "System_Restart_Couldnt_find_Chemlink_SHORT";
  // rawLogFileReadNameBase = "POOL_REFILL_SHORT";
  // rawLogFileReadNameBase = "POOL_REFILL";
  // rawLogFileReadNameBase = "Jandy_log_94201518599_Jacy_Chemlink";
  //rawLogFileReadNameBase = "Jandy_log_2016-04-02_09-03-43-000";
  //rawLogFileReadNameBase = "Jandy_log_2016-03-31_15-03-43-000";
  //rawLogFileReadNameBase = "Jandy_log_2016-04-10_10-34-19-000";
  //rawLogFileReadNameBase = "Jandy_log_2016-04-17_03-30-01-362";
  //rawLogFileReadNameBase = "Jandy_log_2016-03-04_23-46-19-607";
  //rawLogFileReadNameBase = "Jandy_log_2016-04-17_03-30-01-362";
  //rawLogFileReadNameBase = "Jandy_log_2016-03-04_23-46-19-607";
  rawLogFileReadNameBase = "Jandy_log_2016-09-10_18-11-40-381";

  useLogFileNameBase = "";  // If this is "", the logFile name Base will be date derived

  //===============================================//
  // Display only the Communications from some IDs //
  //===============================================//
  // If no specific device display masks are set, all devices are shown.
  // Only show devices with this address. Device masks > 0xFF are for Intelliflo pumps
  // addDeviceDisplayMask(0x80);
  // addDeviceDisplayMask(0x33);
  // addDeviceDisplayMask{emulatePowerCenterIDs[0]);
  // addDeviceDisplayMask{emulateID);
  // addDeviceDisplayMask(DEV_CTL_MASK);
  // addDeviceDisplayMask(DEV_AQUALINK_MASK);
  // addDeviceDisplayMask(DEV_AQUARITE_MASK+1);
  // addDeviceDisplayMask(DEV_PCDOCK_MASK);
  // addDeviceDisplayMask(DEV_CHEMLINK_MASK);
  // addDeviceDisplayMask(DEV_RPC_MASK);
  // addDeviceDisplayMask(DEV_SPA_MASK);
  // addDeviceDisplayMask(DEV_AQUALINK_2_MASK+3);
  // addDeviceDisplayMask(DEV_ONETOUCH_MASK+3);
  // addDeviceDisplayMask(DEV_CHEMLINK_MASK);
   addDeviceDisplayMask(0x160); // Intelliflo pump
  //addDeviceDisplayMask(0xFF);  // Don't show any devices (just warnings, errors,...)

  //==========================================//
  // Emulate PowerCenter to check for devices //
  //==========================================//
  // addEmulatePowerCenterID(DEV_AQUALINK_MASK);
  // addEmulatePowerCenterID(DEV_AQUARITE_MASK);
  // addEmulatePowerCenterID(DEV_ONETOUCH_MASK+1);
  // addEmulatePowerCenterID(DEV_CHEMLINK_MASK);
  // addEmulatePowerCenterID(DEV_AQUALINK_2_MASK);
  // addEmulatePowerCenterID(DEV_ONETOUCH_MASK+3);
  // addEmulatePowerCenterID(POWERCENTER_PROBE_ALL_DEVICES);  

  //=================//
  // Emulate Devices //
  //=================//
  // addEmulatDeviceID(DEV_AQUALINK_MASK);
  // addEmulatDeviceID(DEV_CHEMLINK_MASK);

  //======================================//
  // Set up COM port for RS485 connection //
  //======================================//
  // The blackListPorts will not be used
  blackListPorts.add("/dev/cu.Bluetooth-Incoming-Port");
  blackListPorts.add("/dev/cu.Bluetooth-Modem");
  blackListPorts.add("/dev/tty.Bluetooth-Incoming-Port");
  blackListPorts.add("/dev/tty.Bluetooth-Modem");
  blackListPorts.add("/dev/cu.usbserial-AL00R5L9");
  blackListPorts.add("/dev/tty.usbserial-AL00R5L9");
  blackListPorts.add("/dev/cu.usbserial-DA00U8Q4");
  blackListPorts.add("/dev/cu.SLAB_USBtoUART");
  blackListPorts.add("/dev/cu.usbserial-A600eJmj");
  blackListPorts.add("/dev/cu.usbserial-FTE5IHLD");
  blackListPorts.add("/dev/tty.usbserial-FTE5IHLD");
  blackListPorts.add("/dev/ttyAMA0");
  blackListPorts.add("/dev/ttyS0");

  // If readComPortName is set, it will be the COM port that is used
  // readComPortName            = "COM6";      // Active COM port connected to Simulator or RS485 port
  // readComPortName            = "/dev/tty.usbserial-DA00U8Q4"
  // readComPortName            = "/dev/tty.wchusbserial14130";
  // readComPortName            = "/dev/tty.wchusbserial801330";
  // readComPortName            = "/dev/tty.wchusbserial14530";
  // readComPortName            = "/dev/tty.usbmodem80131";
  // readComPortName            = "/dev/tty.SLAB_USBtoUART";
  // readComPortName            = "/dev/tty.SLAB_USBtoUART8";
  // readComPortName            = "COM12";      // Active COM port connected to Simulator or RS485 port
  // readComPortName            = "COM7";      // Active COM port connected to Simulator or RS485 port
  // readComPortName            = "/dev/tty.usbserial-FTE5IHLD";
  // readComPortName            = "/dev/tty.usbserial-DA00U8Q4";
  // readComPortName            = "/dev/tty.wchusbserial14530";
  // readComPortName            = "/dev/tty.wchusbserial14520";
  // readComPortName            = "/dev/tty.wchusbserial14530";
  // readComPortName            = "/dev/tty.wchusbserial14110";
  // readComPortName            = "/dev/tty.usbserial-AL00R5KS";
  // readComPortName            = "/dev/tty.wchusbserial141230";
  // readComPortName            = "/dev/cu.wchusbserial801130";
  // readComPortName            = "/dev/tty.wchusbserial14130";
  // readComPortName            = "/dev/tty.wchusbserial145310";
  // readComPortName            = "/dev/tty.wchusbserial145310";
  // readComPortName            = "/dev/tty.wchusbserial14120";
  serialSpeed                   = 9600;

  //========================//
  // Extract and log values //
  //========================//
  addValueToLogfile(LOG_ORP_INCLUDE);
  addValueToLogfile(LOG_PH_INCLUDE);
  addValueToLogfile(LOG_SALTPPM_INCLUDE);
  addValueToLogfile(LOG_SALTPCT_INCLUDE);
  addValueToLogfile(LOG_PUMPGPM_INCLUDE);
  addValueToLogfile(LOG_PUMPRPM_INCLUDE);
  addValueToLogfile(LOG_PUMPWATT_INCLUDE);
  addValueToLogfile(LOG_AIRTEMP_INCLUDE);
  addValueToLogfile(LOG_POOLTEMP_INCLUDE);
  addValueToLogfile(LOG_SPATEMP_INCLUDE);
  addValueToLogfile(LOG_DEVICES_LIST_INCLUDE);

  //==============================//
  // No more customizations below //
  //==============================//
  setupLogFiles();
  //=======================================//
  //=== Report ============================//
  //=======================================//

  initDeviceDisplayMasks();
  initEmulatePowerCenterIDs();
  debugMasksList = "DEBUG Mask                          = "+reportVal(debug, 2);
  reportValuesInLogfileList = "REPORT Values in logFile = "+binary(reportValuesInLogfile, 16);
  logValueGroupsEnabled = "LOG Values groups            = "+logValueGroupsEnabled;
  if ( showDisplayOptions + showInfoTextCanvas + showPlayButton + showValuesCanvas == 0 ) {
    enableGUI = false;
  }
  addSpaceBetweenDevicesOptionSelected = displayThisOption("addSpaceBetweenDevices"); //store this value
}

void processPassedArguments() {
  if ( args != null ) {
    for (int i=0; i<args.length; i++) {
      println("ARG #"+i+" = "+(String)args[i]);
    }
  }
}

boolean areWeReadingReadFile() {
  return ( readFileData != READFILEDATA_CREATE );
}

//=======================================================================================================//
//=======================================================================================================//
//=======================================================================================================//
void initSerialPort() {
  if (( areWeReadingRawLogFile() )&( areWeEmulatingPowerCenter())) {
    logTxtLn("Turning off Power Center Emulation because readFileData="+readFileData, LOGTXT_INFO);
    emulatePowerCenterIDsCtr = 0;
  }
  if ( (!areWeReadingReadFile()) ) {
    //===========================//
    // Check for valid COM Ports //
    //===========================//
    if ( readComPortName.equals("") ) {
      print("Available COM Ports:");
      // Use first (non-blacklisted) port)
      boolean OK = true;
      String testPort = "";
      for ( int portNr=0; portNr< Serial.list().length; portNr++ ) {
        testPort = Serial.list()[portNr];
        //print("TEST "+testPort);
        // Check if this port is blacklisted
        OK = true;
        for ( int blackListPortNr = 0; blackListPortNr < blackListPorts.size(); blackListPortNr++ ) {
          //print ("BLP"+blackListPorts.get(blackListPortNr)+" ");
          if ( blackListPorts.get(blackListPortNr).equals(testPort) ) {
            OK = false;
            //print(" ==> BAD");
          }
        }
        print(" "+testPort);
        if ( OK ) {
          if ( readComPortName.equals("") ) {
            print(" [OK]");
            // We haven't found a port yet
            readComPortName = Serial.list()[portNr];
            //print("AAA=="+readComPortName+"==BB");
          }
        } else {
          print(" [BLACK]");
        }
        //println("<==");
      }
      println("");
      //println(Serial.list());
      logTxt("Opening COM port "+readComPortName, LOGTXT_INFO );
      currentOpenPort = new Serial(this, readComPortName, serialSpeed);
      logTxtLn(" ==> "+currentOpenPort, LOGTXT_INFO );
      /*
      println("Dumping buffer");
       int dumpCnt = 0;
       while (currentOpenPort.read() >=0 ) {
       dumpCnt++;
       };
       println("Done Dumping "+dumpCnt+" values");
       */
    }
  }
  processDataValuesCtr  = 0;
  incomingDataValuesCtr = 0;
  checkSumDataValuesCtr = 0;
}


void setupLogFiles() {
  logFilesPath =   sketchPath() +"/"+logFilesPath; 
  if ( areWeReadingRawLogFile()) {
    //===============================//
    // Create log file basename list //
    //===============================//
    rawLogFileReadNameBaseNr = 0;
    rawLogFileReadNameBaseNrOfFiles = 0;
    boolean rawLogFileReadNameBaseIsEmpty = true;
    //if ( rawLogFileReadNameBase != "" ) {
    //}
    //for ( int i = 0; i< rawLogFileReadNameBase.length(); i++ ) {
    if ( rawLogFileReadNameBase != "" ) {
      rawLogFileReadNameBaseList.add(rawLogFileReadNameBase);
      rawLogFileReadNameBaseNrOfFiles++;
      rawLogFileReadNameBaseIsEmpty = false;
      dontOverWriteOutputFiles = false;
    }
    //}
    if ( rawLogFileReadNameBaseIsEmpty ) {
      processSingleRAWFile = false;
      //logFilesPath = "/Users/pjvancor/Dropbox (Personal)/My documents/Processing/Project_Aqualink/logFiles";
      //boolean foundAtleastOneFile = false;
      println("Getting files for path: "+logFilesPath);
      println("CWD: "+sketchPath());
      File logFilesDir = new File(logFilesPath);
      String[] fileNames = logFilesDir.list();
      int baseListNr = 0;
      if (fileNames == null) {
        println("No LOG Files found!");
        rawLogFileReadNameBaseNrOfFiles = 0;
      } else {
        for (int fileNr=0; fileNr<fileNames.length; fileNr++ ) {
          if ( fileNames[fileNr].endsWith(RAWLogFileExtension) ) {
            if ( showDebug(DEBUG_DETAILS) ) {
              println("F: "+fileNames[fileNr]);
            }
            rawLogFileReadNameBaseList.add(fileNames[fileNr].replace(RAWLogFileExtension, ""));
            baseListNr++;
            //foundAtleastOneFile = false;
          }
        }
        rawLogFileReadNameBaseNrOfFiles = baseListNr;
      }
    }
  }
}

void readAndStartReplayOfRAWLogFile() {
  if ( areWeProcessingRAWLogFile() ) {
    readRawLogFile();
    RAWLogFileRead.dataPosition = 0;
  }
}
