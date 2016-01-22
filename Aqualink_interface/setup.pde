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

  verboseDataDebugLevel = 0;

  displayOptionNameList = "Display options           = \"";
  setDisplayOption("showUnprocessedData", false);  // Show the incoming hex bytes before they are processed
  setDisplayOption("showRawIncomingHexData", false);  // Show incoming data (in HEX) as it is being read
  setDisplayOption("showVerboseDataInLog", true);  // Show Verbose Data in the log file
  setDisplayOption("suppressChecksumErrors", false);  // Don't complain about Checksum errors
  setDisplayOption("showDroppedData", true);  // Show the dropped data (due to checksum errors, colissions,...)
  setDisplayOption("dontShowZeroACKData", false);  // Don't show the data values following an ACK if they're all 0
  setDisplayOption("onlyShowNewStrings", false);  // Only show decoded data if it is new
  setDisplayOption("dontShowEmptyProbes", false);  // Don't show probes that have not been responded to
  setDisplayOption("showTimeDeltas", true);  // Show time delta since last data
  setDisplayOption("suppressReadoutWarnings", false);  // Suppress warnings about the readout (Dropped packets,...) 
  setDisplayOption("suppressReadoutInfo", false);  // Suppress info about the readout (LOGTXT_INFO lines)
  setDisplayOption("suppressReadoutErrors", false);  // Suppress errors about the readout (Dropped packets,...)
  setDisplayOption("showCommandResponse", true);  // Show the response to the MASTER
  setDisplayOption("addSpaceBetweenDevices", true);  // Add extra line between device outputs
  setDisplayOption("showProcessedBytesStatistics", false);  // Show Statistics about the processed bytes
  setDisplayOption("pulseDrawWithZeros", false);  // Send 0x00 on serial port (if applicable) everytime the draw() loop restarts
  setDisplayOption("addCSValueToLogTxt", false);  // Show checksum values in logTxt prints
  setDisplayOption("reportDataInDecimal", false); // Report data in decimal instead of hex
  setDisplayOption("printDataToScreen", true); // Report data in decimal instead of hex
  setDisplayOption("useSteppedReplay", false); // 
  setDisplayOption("toggleSteppedReplay", false); // 
  setDisplayOption("printReplayStatistics", false); // 
  setDisplayOption("onlyReportNewValuesinLog", true); // 
  setDisplayOption("useRefreshTime", true); // 


  displayOptionNameList += "\"";

  showDisplayOptions = 0;
  showInfoTextCanvas = 0;
  showPlayButton     = 0;
  showValuesCanvas   = 1;

  //==========================//
  //   CUSTOMIZE THIS SECTION //
  //==========================//
  //logFilesPath           = "/Users/pjvancor/logFiles/";

  // Record or read data to/from file
  readFileData               = 0;  // Read data from a previously recorded file (name defined by rawLogFileReadNameBase below)
  // If this value == 1, it will reread and process the file
  // if this value == 2, it will reread and replay once
  // If this value == 3, it will reread and loop a replay
  replayDelay                = 50; // Delay between replayed Commands or Responses
  powerCenterEmulatorTimeout = 50;
  // rawLogFileReadNameBase = "Jandy_log_94201518599_Jacy_Chemlink"; // Read from this file if readFileData==1
  // rawLogFileReadNameBase = "Jandy_log_942015185411_Jacy1";
  // rawLogFileReadNameBase = "Jandy_log_2192014151950";
  // rawLogFileReadNameBase = "Jandy_log_1542015215916";
  // rawLogFileReadNameBase = "home_Capture_051015";
  // rawLogFileReadNameBase = "Home_Capture_051815";
  // rawLogFileReadNameBase = "Jandy_log_225201515402";
  // rawLogFileReadNameBase = "OneLinkTouch_Chemlink";
  // rawLogFileReadNameBase = "Jandy_log_106201512942";
  // rawLogFileReadNameBase = "Jandy_log_2162015124241";
  // rawLogFileReadNameBase = "POOL_REFILL";
  // rawLogFileReadNameBase = "test";
  // rawLogFileReadNameBase = "test2";
  // rawLogFileReadNameBase = "test3";
  // rawLogFileReadNameBase = "ONETOUCH_STARTUP";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY_2";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY_3";
  // rawLogFileReadNameBase = "ONETOUCH_DISPLAY_SHORT";
  // rawLogFileReadNameBase = "ONETOUCH_LINES_INVERTED";
  // rawLogFileReadNameBase = "ONETOUCH_HIGHLIGHT_LINES";
  // rawLogFileReadNameBase = "Onetouch_on_Live_System";
  // rawLogFileReadNameBase = "Onetouch_Showing_ABOUT_with_Highlight";
  // rawLogFileReadNameBase = "INCREASING_NUMBERS";
  // rawLogFileReadNameBase = "Jandy_log_192015231128" ;
  // rawLogFileReadNameBase = "ONETOUCH_STARTUP_SCROLL";
  // rawLogFileReadNameBase = "ONETOUCH_SCROLL_UP";
  // rawLogFileReadNameBase = "ONETOUCH_INDIVIDUAL_HIGHLIGHTS_ON_CHEMLINK";
  // rawLogFileReadNameBase = "ONETOUCH_HIGHLIGHT_SECTIONS";
  // rawLogFileReadNameBase = "ONETOUCH_HIGHLIGHT_ORP_SETUP";
  // rawLogFileReadNameBase = "Jandy_log_392015195127";
  // rawLogFileReadNameBase = "Jandy_log_2892015235515";
  // rawLogFileReadNameBase = "Jandy_log_299201519540";
  // rawLogFileReadNameBase = "Jandy_log_3102015224816";
  // rawLogFileReadNameBase = "Jandy_log_310201511346";
  // rawLogFileReadNameBase = "Jandy_log_310201511346_SHORT";
  // rawLogFileReadNameBase = "Jandy_log_2892015235515"; // HUGE file
  // rawLogFileReadNameBase = "Jandy_log_4102015164750";
  // rawLogFileReadNameBase = "Jandy_log_4102015164750_SMALL";
  // rawLogFileReadNameBase = "Jandy_log_2292015232447";
  // rawLogFileReadNameBase = "Jandy_log_111201510522";
  // rawLogFileReadNameBase = "test";
  // rawLogFileReadNameBase = "Jandy_log_2112015223543_SHORT";
  // rawLogFileReadNameBase = "Jandy_log_2112015204650";
  // rawLogFileReadNameBase = "System_Restart_Couldnt_find_Chemlink";
  // rawLogFileReadNameBase = "System_Restart_Couldnt_find_Chemlink_SHORT";
  // rawLogFileReadNameBase = "Jandy_log_111201510522";
  // rawLogFileReadNameBase = "Jandy_log_10520150014";
  // rawLogFileReadNameBase = "Jandy_log_2292015232447";
  // rawLogFileReadNameBase = "Jandy_log_2552015174829";
  // rawLogFileReadNameBase = "Jandy_log_116201501124";
  // rawLogFileReadNameBase = "Jandy_log_2362015142933";
  // rawLogFileReadNameBase = "Jandy_log_1112015204457";
  // rawLogFileReadNameBase = "Jandy_log_229201520163";
  // rawLogFileReadNameBase = "Jandy_log_1472015122917";
  // rawLogFileReadNameBase = "POOL_REFILL_SHORT";
  // rawLogFileReadNameBase = "POOL_REFILL";
  // rawLogFileReadNameBase = "Jandy_log_1082015161644";
  // rawLogFileReadNameBase = "Jandy_log_1112015204457";
  //rawLogFileReadNameBase = "Jandy_log_262015175420";
  // rawLogFileReadNameBase = "Jandy_log_27-12-2015_12:56:07";
  rawLogFileReadNameBase = "Jandy_log_94201518599_Jacy_Chemlink";

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
  // addDeviceDisplayMask(DEV_AQUALINK_MASK);
  // addDeviceDisplayMask(DEV_AQUARITE_MASK+1);
  // addDeviceDisplayMask(DEV_PCDOCK_MASK);
  // addDeviceDisplayMask(DEV_CHEMLINK_MASK);
  // addDeviceDisplayMask(DEV_RPC_MASK);
  // addDeviceDisplayMask(DEV_SPA_MASK);
  // addDeviceDisplayMask(DEV_AQUALINK_2_MASK+3);
  // addDeviceDisplayMask(DEV_ONETOUCH_MASK+3);
  addDeviceDisplayMask(DEV_CHEMLINK_MASK);
  // addDeviceDisplayMask(0x160); // Intelliflo pump
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

  setupLOGFiles();

  //=======================================//
  //=== Report ============================//
  //=======================================//

  initDeviceDisplayMasks();
  initEmulatePowerCenterIDs();
  debugMasksList = "DEBUG Mask                = "+reportVal(debug, 2);
  reportValuesInLogfileList = "REPORT Values in Log File: "+binary(reportValuesInLogfile, 16);
  logValueGroupsEnabled = "LOG Values groups: "+logValueGroupsEnabled;
  if ( showDisplayOptions + showInfoTextCanvas + showPlayButton + showValuesCanvas == 0 ) {
    enableGUI = false;
  }
  addSpaceBetweenDevicesOptionSelected = displayThisOption("addSpaceBetweenDevices"); //store this value
}

void initSerialPort() {
  if (( areWeReadingRawLogFile() )&( areWeEmulatingPowerCenter())) {
    logTxtLn("Turning off Power Center Emulation because readFileData="+readFileData, LOGTXT_INFO);
    emulatePowerCenterIDsCtr = 0;
  }
  if ( (readFileData != 1) ) {
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
    }
  }
  processDataValuesCtr  = 0;
  incomingDataValuesCtr = 0;
  checkSumDataValuesCtr = 0;
}


void setupLOGFiles() {
  if ( readFileData != 0 ) {
    //===============================//
    // Create log file basename list //
    //===============================//
    rawLogFileReadNameBaseNr = 0;
    rawLogFileReadNameBaseNrOfFiles = 0;
    logFilesPath =   sketchPath() +"/"+logFilesPath; 
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
            println("F: "+fileNames[fileNr]);
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
  if ( areWeReadingRawLogFile() ) {
    readRawLogFile();
    rawLogFileDataPosition = 0;
  }
}