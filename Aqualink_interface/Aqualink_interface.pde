//==========================================================================================//
//===== DESCRIPTION ========================================================================//
//==========================================================================================//
/* This will read communication with devices from a Jandy Automation system 
 Currently supported:
 -) Hayward Aquarite (most communications)
 -) Aqualink SPA control
 -) Aqualink controller (like RS-8)
 -) Aqualink Onetouch (Some display messages)
 -) Intelliflo VF and VS 
 -) Onetouch display (short and long messages)
 -) Jandy Chemlink (tested on C1900)
 
 //==========//
 // Emulator //
 //==========//
 // These emulators communicate to the serial port
 // Aqualink Touch
 // AqualinkPC
 // One Touch PC
 // PC Docking Station
 // Power Center
 // simple Allbutton panel
 // Simple Onetouch panel
 //=================================================
 
 //=============//
 // CONNECTIONS //
 //=============//
 RS485 - USB conector (like this one (02/15): 
 http://www.amazon.com/KEDSUM%C2%AE-Converter-Adapter-ch340T-Support/dp/B009SIDMNM/ref=sr_1_3?s=pc&ie=UTF8&qid=1425011500&sr=1-3 )
 AQUALINK <--> RS485 
 |=============================|
 | RED      <--> Not Connected |
 | BLACK    <--> D+            |
 | YELLOW   <--> D-            |
 | GREEN    <--> Not Connected |
 |=============================|
 
 AQUALINK SIMULATOR <--> USB/RS232
 CONNECT TX to RX and RX to TX
 */
import controlP5.*;
import processing.serial.*;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

//============================================================================//
//============================================================================//
//============================================================================//
//============================================================================//

void setup() {
  //println(sketch);
  //println("PATH: "+sketchPath());
  size(1000, 1000);
  //========================//
  // Set up display options //
  //========================//
  initDisplayOptions();
  //===================//
  // Read Setup Values //
  //===================//
  readSetupValues();
  //============================//
  // Processed passed arguments //
  //============================//
  processPassedArguments();
  //=====//
  // GUI //
  //=====//
  initGUI();
  if ( !areWeReadingRawLogFile() ) {
    //=========//
    // Cleanup //
    //=========//  
    initValues();
    //======//
    // LOGS //
    //======//
    if ( initLogFiles() ) {
      //==============//
      // Serial Ports //
      //==============//
      initSerialPort();
      //======================//
    }
  }

  // FROM PROCESSVALUESFILES
  createLogFilesList();
}

void draw324345() {
  //=================================
  // createReducedLogFiles
  String fileLength   = "";
  String fileInterval = "";
  for ( int i=0; i< outPutConfig.length; i++ ) {
    String[] dataLine = outPutConfig[i];
    fileLength = dataLine[0];
    println("Creating files with length "+fileLength+" = "+dataLine[1]);
    for ( int j=2; j< dataLine.length; j++ ) {
      fileInterval = dataLine[j];
      println("  Using interval "+fileInterval);
      //createReducedLogFiles(fileLength, fileInterval, false);
    }
    println("");
  }

  //=================================
  // splitRAWLogFile
  for ( int i = 0; i< maxRawLogFileNr; i++ ) {
//    if ( showDebug(DEBUG_DETAILS) ) {
      println("##########################################");
      println("Splitting FILE: "+logFilesPath+rawLogFileNames[i]);
      println("    =====>");
//    }
    delay(1);
    //splitRAWLogFile(logFilesPath+rawLogFileNames[i]);
  }
  println(" =====> DONE!");
  exit();
}



void draw67869() {
  //splitRAWLogFile("/Users/pjvancor/Dropbox (Personal)/My documents/Processing/Project_Aqualink/logFiles/Jandy_log_03-26-2016_21:03:33_RAW.txt");
  //splitRAWLogFile("/Users/pjvancor/Dropbox (Personal)/My documents/Processing/Project_Aqualink/logFiles/Jandy_log_04-10-2016_10:34:19.075_RAW.txt");
  //splitRAWLogFile("/Users/pjvancor/Dropbox (Personal)/My documents/Processing/Project_Aqualink/logFiles/Jandy_log_02-22-2016_12:02:12.000_RAW.txt");
  //splitRAWLogFile("/Users/pjvancor/Dropbox (Personal)/My documents/Processing/Project_Aqualink/logFiles/Jandy_log_04-17-2016_08:30:01.362_RAW.txt");
}  



void draw() {
  if ( !areWeReadingRawLogFile() ) {
    //=========================//
    // Read from RS485 Adapter //
    //=========================//  
    //==================================//
    // Emulate Power Center and Devices //
    //==================================//
    powerCenterEmulateNext(areWeEmulatingPowerCenter()); 
    // Process the emulator data first, both from Power Center and Individual Devices
    emulateAllAvailableData(); 
    processAllIncomingData();
  } else {
    //================================//
    // Read from RAW Log File Adapter //
    //================================//  
    switch (drawMode) {
    case DRAW_INIT_FILES : 
      {
        // Turn off the spaces between lines //
        setDisplayOption("addSpaceBetweenDevices", false); 
        //=========//
        // Cleanup //
        //=========//  
        initValues(); 
        //======//
        // LOGS //
        //======//
        if ( initLogFiles() ) {
          //==============//
          // Serial Ports //
          //==============//
          initSerialPort(); 
          //======================//
          // Process RAW Log File //
          //======================//
          readAndStartReplayOfRAWLogFile(); 
          // Restore setting for spaces between devices //
          setDisplayOption("addSpaceBetweenDevices", addSpaceBetweenDevicesOptionSelected); // Restore this option
          setDrawMode(DRAW_RUN);
        } else {
          gotoNextRawLogFile();
        }
      }
      break; 
    case DRAW_RUN : 
      {
        //============================================================//
        // Process/Replay from log file for REFRESHTIMEMICROUPDATE us //
        //============================================================// 
        processRAWLogFileUntilRefreshTimeMicroUpdate();
      }
      break; 
    case DRAW_FINISH_FILES : 
      reportAndDropUnprocessedData(0); 
      closeLogFiles(); 
      gotoNextRawLogFile();
    }
  }
  showMemory(); 
  flushLogFiles(); 
  runDrawDebugStuff();
}

//==========================================================
//==========================================================
//==========================================================
//==========================================================
//==========================================================
//==========================================================
//==========================================================
//======================= TEST =============================

void draw2() {
  for ( int data=0; data<256; data++ ) {
    currentOpenPort.write(data);
  }
  delay(100);
}

void drawPROBE() {
  currentOpenPort.write(0x10); 
  currentOpenPort.write(0x02); 
  currentOpenPort.write(0x80); 
  currentOpenPort.write(0x00); 
  currentOpenPort.write(0x92); 
  currentOpenPort.write(0x10); 
  currentOpenPort.write(0x03); 
  delay(1000);
}


void drawTest() {
  //Measured speed: 766Bps
  //Jandy runs at 491Bps
  for ( int i=0; i< 30; i++ ) {
    //timeStamp("EMULATE");
    // Send a total of 20 bytes
    // Should take 18.75ms each
    sendRun(DEV_AQUARITE_MASK); //Send "Set Aquarite Status" command
    //delay(500);
    sendAquariteStatus(i+10, STAT_AQUARITE_HISALT); 
    emulateAllAvailableData(); 
    //delay(10);
  }
}
//delay(10);




//==========================//
// TODO
//
// Using the replayer Arduino, no _RAW files are generated

// Replay of a file has the _Values be of by 1 millisecond
// Proliferate unknownResponse command

// DEBUG: ========================================================================
// ONETOUCH_GO_TO_CLEANING_CYCLE_SCREEN_UNRESPONSIVE_RAW
// Deal with large files like Jandy_log_94201518599_Jacy_Chemlink
// Get rid of the 0 and 1 lines in this case:
//                      1696 WARNING!:Unknown AQUALINK Response H01 to command: H24
//                           0>H10 H02 H33 H24 H00 H01 H00 H08 H46 H49 H4C H54 H45 H52 H00 H50 H55 H4D H50 H00 H7A H10 H03  == H10/H02/3$H00/H01/H00/H08/FILTERH00/PUMPH00/zH10/H03/ | 
//                           1>
// PURGE Serial port before starting to read it
// Checksum for PUMP data
// PRIMING ERROR CODE IS NOT CORRECT
// CHECK ON DROPPED PACKETS
// Make "      loggedTxtStrings[nrLoggedNewTextStrings] = logTxtStringTmp;" into a circular buffer
//===============================================================================
// Add global counter of processed bytes, so dropped bytes can be referenced as (Byte 2034 - 2036)
// Debug warnings when replaying file "test" and why not all of the dropped data is shown
// Incorrect Nr 12 of data bytes for buttStat() START = 2 END = 14
// processdatabytes needs to return a status value
// Do not emulate new command if the last one was not sent out
// setreceivelinebusy is not working well
// When data goes from Equipment to pump, separate them, eg ==> SPA: ..... should only show reponses to master from SPA, not PUMP

// ==================================================================================
// ==== DONE ========================================================================
// ==================================================================================
// CONVERT processRPC_0x09_response to a generic response function
// Checksums are not verified!!!!!!!!!!!!!
// FIX processCHEMLINKResponse to use command
// FIX createToggle()
// Converting a RAW file (without replay) seems slow, like there is a delay)
// replaydelay should work on command/reponses, not individual bytes
// Responses to wrong master are not verified
// Move all of the ACK data processing to the individul tabs, rather than processACKData()
// Consider adding state LOOKINGFORPUMPDATAFF2 ==> Doesn't ake sense
// When reading a RAW file, it seems to add he filename to the first line!
/*
STILL CRASHES:
 ==> Turned out to be a bad file
 drwxr-xr-x@   15 pjvancor  pjvancor_      510 Nov 19 14:54 ..
 -rw-r--r--@    1 pjvancor  pjvancor_   106496 Nov 19 19:57 Jandy_log_26201517438_RAW.txt
 -rw-r--r--@    1 pjvancor  pjvancor_   942080 Nov 19 19:57 Jandy_log_262015175420_RAW.txt
 -rw-r--r--@    1 pjvancor  pjvancor_        0 Nov 19 19:58 Jandy_log_26201517438_Values.txt
 -rw-r--r--@    1 pjvancor  pjvancor_        0 Nov 19 19:58 Jandy_log_262015175420_Values.txt
 -rw-r--r--@    1 pjvancor  pjvancor_  6404872 Nov 19 19:58 Jandy_log_26201517438_Output.txt
 drwxr-xr-x@   14 pjvancor  pjvancor_      476 Nov 19 19:58 .
 -rw-r--r--@    1 pjvancor  pjvancor_  2017861 Nov 19 19:58 Jandy_log_262015175420_Output.txt
 mac0010716:logFiles pjvancor$ less Jandy_log_262015175420_Output.txt 
 mac0010716:logFiles pjvancor$ less Jandy_log_262015175420_Output.txt 
 mac0010716:logFiles pjvancor$ 
 */


/* Info
 http://forums.indigodomo.com/viewtopic.php?t=3212
 */