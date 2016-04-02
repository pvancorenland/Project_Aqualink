void initGUI() {
  surface.setResizable(true);
  pfont = createFont("Arial", fontSize, false); // use true/false for smooth/no-smooth
  guiWinFont = new ControlFont(pfont, fontSize);
  String guiEnabled = "GUI is ";
  if ( enableGUI ) {
    guiEnabled += "ENABLED";
  } else {
    guiEnabled += "DISABLED";
  }
  logFilePrintln(2, guiEnabled);
  //println(guiEnabled);
  if ( enableGUI ) {
    //=================================================
    // DisplayOptionsCanvasXSize  || infoCanvasXSize //
    //=================================================
    //
    // DisplayOptionsCanvasYSize  || infoCanvasYSize
    //
    // Init Display section
    DisplayOptionsCanvasXSize = 500 * showDisplayOptions;
    DisplayOptionsCanvasYSize = (yPosToggle + (displayOptionsList.size ())*(toggleButtonYSize+toggleButtonYOffset)) * showDisplayOptions;
    // Info Screen
    infoCanvasXSize = 480 * showInfoTextCanvas;
    infoCanvasYSize = 200 * showInfoTextCanvas;
    ValuesCanvasXsize = 480 * showValuesCanvas;
    ValuesCanvasYsize = 320 * showValuesCanvas;

    int playButtonXSize = 100 * showPlayButton;
    int playButtonYSize = 50 * showPlayButton;
    int canvasXSize = DisplayOptionsCanvasXSize + max(infoCanvasXSize, playButtonXSize, ValuesCanvasXsize);
    int canvasYSize = max(DisplayOptionsCanvasYSize, infoCanvasYSize + playButtonYSize + ValuesCanvasYsize);
    int currentXPos = 0;
    int currentYPos = 0;
    canvasXSize = max(canvasXSize, 1);
    canvasYSize = max(canvasYSize, 1);
    //logFilePrintln(2, "Setting canvas size X="+canvasXSize+" Y="+canvasYSize);
    println("Setting canvas size X="+canvasXSize+" Y="+canvasYSize);
    guiWin = new ControlP5(this);

    // Set up canvas
    surface.setSize(canvasXSize, canvasYSize);
    background(0);

    // Add Display Options
    if ( showDisplayOptions == 1 ) {
      enabledCanvasOptions += " DISPLAY OPTIONS";
      rect(currentXPos, currentYPos, DisplayOptionsCanvasXSize, DisplayOptionsCanvasYSize);
      currentXPos += DisplayOptionsCanvasXSize;
      currentYPos = 0 ;
      createToggles();
    }

    // Output text
    if ( showInfoTextCanvas == 1 ) {
      enabledCanvasOptions += " INFOTEXT";
      infoTextArea = guiWin.addTextarea("infoTxt")
        .setPosition(currentXPos, currentYPos)
        .setSize(infoCanvasXSize, infoCanvasYSize)
        .setFont(createFont("arial", 24))
        .setLineHeight(14)
        .setColor(0xffffffff)
        .setColorBackground(color(0, 0))
        .setColorForeground(color(255, 100));
      currentYPos += infoCanvasYSize;
    }

    // PLAY Button text
    if ( showPlayButton == 1 ) {
      enabledCanvasOptions += " PLAYBUTTON";
      if ( areWeReadingRawLogFile() ) {
        Button replayFile = guiWin.addButton("click");
        replayFile.setPosition(currentXPos, currentYPos);
        replayFile.setSize(playButtonXSize, playButtonYSize);
        steppedEmulator = new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {
            switch(theEvent.getAction()) {
              case(ControlP5.ACTION_PRESS): 
              enableSteppedEmulator();
              break;
              case(ControlP5.ACTION_RELEASE): 
              disableSteppedEmulator();
              break;
            default:
              //println("UNKNOWN ACTION_BUTTON STATE");
              break;
            }
          }
        };
        guiWin.addCallback(steppedEmulator);
        currentYPos += playButtonYSize;
      }
    }
    // Readout Values
    if ( showValuesCanvas == 1 ) {
      enabledCanvasOptions += " VALUES";
      valuesTextArea = guiWin.addTextarea("readoutValues")
        .setPosition(currentXPos, currentYPos)
        .setSize(ValuesCanvasXsize, ValuesCanvasYsize)
        .setFont(createFont("Courier", 24))
        .setLineHeight(26)
        .setColor(0xffffffff)
        .setColorBackground(color(0, 0))
        .setColorForeground(color(255, 100));
      currentYPos += ValuesCanvasYsize;
      // Set up some text variables
      if ( includeValueinLogFile(LOG_SALTPPM_INCLUDE) || includeValueinLogFile(LOG_SALTPCT_INCLUDE) ) {
        logValueGroupsEnabled += "SALT ";
        LOG_SALT_ENABLED = true;
      }
      if ( includeValueinLogFile(LOG_PUMPGPM_INCLUDE) || includeValueinLogFile(LOG_PUMPRPM_INCLUDE) || includeValueinLogFile(LOG_PUMPWATT_INCLUDE) ) {
        LOG_PUMP_ENABLED = true;
        logValueGroupsEnabled += "PUMP ";
      }
      if ( includeValueinLogFile(LOG_AIRTEMP_INCLUDE) || includeValueinLogFile(LOG_POOLTEMP_INCLUDE) ) {
        LOG_TEMP_ENABLED = true;
        logValueGroupsEnabled += "TEMP ";
      }
    }
    //println("GRPS: "+logValueGroupsEnabled);
    if ( areWeEmulatingPowerCenter() ) {
      frameRate(10000); // Go Fast!
    }
  } else {
    surface.setSize(1, 1);
  }
}

void enableSteppedEmulator() {
  waitingForNextStepClick = 0;
  displayToggleButtonState = 1;
}

void disableSteppedEmulator() {
  //if ( !displayThisOption("toggleSteppedReplay") ) {
  //  waitingForNextStepClick = 1;
  //}
  displayToggleButtonState = 0;
}

void updateInfoText(String text) {
  if ( showInfoTextCanvas == 1) {
    infoTextArea.setText(text);
  }
}

void updateReadoutValuesText(String text) {
  if ( showValuesCanvas == 1) {
    valuesTextArea.setText(text);
  }
}

boolean displayThisOption( String optionName ) {
  for ( int i=0; i< displayOptionsList.size (); i++ ) {
    //println(displayOptionsList.get(i).name+" <==> "+optionName);
    if ( displayOptionsList.get(i).name == optionName) {
      //println("   ====>");
      return displayOptionsList.get(i).value;
    }
  }
  println("Error! Checking non-existent option "+optionName+" in displayThisOption");
  return false;
}

boolean setDisplayOption(String optionName, boolean value) {
  if ( value ) {
    displayOptionNameList += optionName + " ";
  }
  for ( int i=0; i< displayOptionsList.size (); i++ ) {
    if ( displayOptionsList.get(i).name == optionName) {
      //println("   ====>");
      displayOptionsList.get(i).value = value;
      return true;
    }
  }
  println("Error! Checking non-existent option "+optionName+" in setDisplayOption");
  return false;
}

void createToggle(boolean value, String name, String description) {
  //toggles = guiWin.addToggle(name, xPosToggle, yPosToggle + toggleNr*(toggleButtonYSize + toggleButtonYOffset), toggleButtonXSize, toggleButtonYSize)
  toggles = guiWin.addToggle(name)
    .setPosition(xPosToggle, yPosToggle + toggleNr*(toggleButtonYSize + toggleButtonYOffset))
    .setSize(toggleButtonXSize, toggleButtonYSize)
    .setValue(value)
    .setMode(ControlP5.DEFAULT)
    .setLabel(description)
    .setId(toggleNr);
  l = toggles.getCaptionLabel()
    .toUpperCase(false)
    .setFont(guiWinFont)
    .align(LEFT, CENTER)
    .setPaddingX(toggleButtonXSize+toggleButtonLabelXOffset);
  toggleNr++;
}

void createToggles() {  
  for ( int i=0; i< displayOptionsList.size (); i++ ) {
    createToggle(displayOptionsList.get(i).value, displayOptionsList.get(i).name, displayOptionsList.get(i).description);
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    if ( debugThis(DEBUG_SHOWDISPLAYOPTIONINFO) ) {
      print("control event from : "+theEvent.getController().getName());
      println(", value : "+theEvent.getController().getValue());
    }
    for ( int i=0; i< displayOptionsList.size (); i++ ) {
      if (theEvent.getController().getName() == displayOptionsList.get(i).name) {
        if ( debugThis(DEBUG_SHOWDISPLAYOPTIONINFO) ) {
          println(i+" <=="+displayOptionsList.get(i).name);
        }
        if ( theEvent.getController().getValue() > 0.5 ) {
          displayOptionsList.get(i).value = true;
        } else {
          displayOptionsList.get(i).value = false;
        }
      }
    }
  }
}


/*
    
 */