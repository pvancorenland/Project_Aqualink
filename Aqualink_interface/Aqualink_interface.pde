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

//============================================================================//
//============================================================================//
//============================================================================//
//============================================================================//

void setup() {
  println(sketch);
  println("PATH: "+sketchPath());
  size(1000, 1000);
  //========================//
  // Set up display options //
  //========================//
  initDisplayOptions();
  //===================//
  // Read Setup Values //
  //===================//
  readSetupValues();
  //=====//
  // GUI //
  //=====//
  initGUI();
  if ( readFileData == 0 ) {
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
}

void draw() {
  if ( readFileData == 0 ) {
    //=========================//
    // Read from RS485 Adapter //
    //=========================//  
    //==================================//
    // Emulate Power Center and Devices //
    //==================================//
    powerCenterEmulateNext(areWeEmulatingPowerCenter()) ;
    // Process the emulator data first, both from Power Center and Individual Devices
    emulateAllAvailableData();
    processAllIncomingData();
  } else {
    //================================//
    // Read from RAW Log File Adapter //
    //================================//  
    switch (drawMode) {
    case DRAW_INIT_FILES:
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
    case DRAW_RUN:
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