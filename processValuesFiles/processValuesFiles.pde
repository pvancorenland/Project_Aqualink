//
// Takes all of the _Values.txt files and merges them into one big file

import java.util.Date;
import java.text.SimpleDateFormat;

//======================================//
int createFullValuesLogFile  = 0;
int createSmallValuesLogFile = 1;
int enableDebug = 0;

String logFilesPath           = "/Users/pjvancor/Dropbox (Personal)/My documents/Processing/Project_Aqualink/logFiles/"; // Base directory where logfiles are stored
String valuesHeader;
BufferedReader ValuesLogFileReader;
BufferedReader fullValuesLogFileReader;
PrintWriter smallValuesLogFileWriter;
PrintWriter fullValuesLogFileHandle;
final String VALUESLOGFILEHEADER = "#VALUES LOG FILE WITH TIMESTAMP";
final String LOG_VALUE_SEPARATOR   = ",";

SimpleDateFormat rawLogFileDateFormat         = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss-SSS");

String ValuesLogFileHeaderLine = "";
int foundValuesLogHeaderFile = 0;
String fullValuesFileName = logFilesPath+"fullValues.txt";
long endTimeStamp = 0;
long deltaTimestamp;
long oldDeltaTimestamp;
long tmpTimestamp = 0;
String commentChar = "#"; //#
long fullLogFileStartTimestamp;
final int maxNrSumPts   = 1024;
final int maxSumTime5m   = 5*60*1000;  // 5 minutes
final int maxSumTime1h   = 60*60*1000; // 1 hour
final int maxNrDataPts   = 24;
final long maxDeltaTimestamp = 25*1000; // 25s as max time between valid points
final String LOG_DIGITS_NAME   = "#DIGITS";

float sumDatavalues[] = new float[maxNrDataPts];
float newDatavalues[] = new float[maxNrDataPts];
long sumTimes[] = new long[maxNrDataPts];
long tmpSumTimes[] = new long[maxNrDataPts];
long maxSumTimes;
int nrDigits[] = new int[maxNrDataPts];
int nrSumPts;
int outPts[];
int outTimes[];
int totDataseries;
long timeBefore = -1;
long timeNow = -1;

void setup() {
  Date d = new Date();
  fullLogFileStartTimestamp = d.getTime();
  if ( createFullValuesLogFile == 1 ) {
    fullValuesLogFileHandle = createWriter(fullValuesFileName);
    fullValuesLogFileHandle.println("#Full values Log File created @ "+rawLogFileDateFormat.format(fullLogFileStartTimestamp));
  }
}

void draw() {
  if ( createFullValuesLogFile == 1 ) {
    createFullValuesLogFile();
  }
  if ( createSmallValuesLogFile == 1 ) {
    createSmallValuesLogFile(logFilesPath+"fullValues.txt", logFilesPath+"fullValuesSmpl5m.txt", maxSumTime5m);
    createSmallValuesLogFile(logFilesPath+"fullValues.txt", logFilesPath+"fullValuesSmpl1h.txt", maxSumTime1h);
  }
  exit();
}

void createFullValuesLogFile() {
  File logFilesDir = new File(logFilesPath);
  String[] fileNames = logFilesDir.list();
  int FNlength = fileNames.length;
  if ( FNlength > 0 ) {
    for ( int i = 0; i < FNlength; i++ ) {
      if ( fileNames[i].endsWith("_Values.txt") ) {
        println("##########################################");
        println("Processing FILE: "+logFilesPath+fileNames[i]);
        println("    =====>");
        tmpTimestamp = readValuesFile(logFilesPath+fileNames[i], endTimeStamp);
        if ( tmpTimestamp > 0 ) {   
          endTimeStamp = tmpTimestamp;
        }
      }
    }
  } 
  fullValuesLogFileHandle.close();
  println("DONE creating the full Values Log File!");
}

void createSmallValuesLogFile(String inputFileName, String outputFileName, long timeInterval) {
  String ValuesLogFileReadLine   = commentChar;  
  println("Reading file "+inputFileName+" writing output to: "+outputFileName);
  try {
    fullValuesLogFileReader  = createReader(inputFileName);
    smallValuesLogFileWriter = createWriter(outputFileName);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  ValuesLogFileReadLine = readNextLogLine(fullValuesLogFileReader);
  while ( ValuesLogFileReadLine.charAt(0) == commentChar.charAt(0) ) {
    processCommentedLine(ValuesLogFileReadLine);
    println(ValuesLogFileReadLine);
    smallValuesLogFileWriter.println(ValuesLogFileReadLine);
    ValuesLogFileReadLine = readNextLogLine(fullValuesLogFileReader);
  }
  String[] items = split(ValuesLogFileReadLine, ",");
  totDataseries = items.length - 1;
  println("Found "+totDataseries+" data series");
  //========================
  // Start reading
  while ( ValuesLogFileReadLine != null ) {
    grabNewDataValues(ValuesLogFileReadLine);
    if ( deltaTimestamp > maxDeltaTimestamp ) {
      smallValuesLogFileWriter.println("#JMP "+deltaTimestamp);
      processNewSumtimesPt();
      grabNewDataValues(ValuesLogFileReadLine);
    }
    updateNewSumValues();
    if (( maxSumTimes >= timeInterval)||( nrSumPts >= maxNrSumPts)) {
      processNewSumtimesPt();
    }
    ValuesLogFileReadLine = readNextLogLine(fullValuesLogFileReader);
  }
  //=========================
  // Finish up
  try {
    fullValuesLogFileReader.close();
    smallValuesLogFileWriter.close();
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

void processNewSumtimesPt() {
  print("MAXSUMTIME: "+maxSumTimes+" nrSumPts: "+nrSumPts);
  //Process and print values
  if ( enableDebug == 1 ) {
    smallValuesLogFileWriter.print(timeNow+" MAXSUMTIME: "+maxSumTimes+" nrSumPts: "+nrSumPts);
    for (int i=0; i< totDataseries; i++ ) {
      smallValuesLogFileWriter.print(">"+sumDatavalues[i]+"/"+sumTimes[i]+"<");
    }
    smallValuesLogFileWriter.println("");
  }
  print(" T: "+timeNow+" ");
  smallValuesLogFileWriter.print(timeNow);
  for (int i=0; i< totDataseries; i++ ) {
    sumDatavalues[i] /= sumTimes[i];
    print(sumDatavalues[i]+ " ");
    smallValuesLogFileWriter.print(","+formatDigits(sumDatavalues[i], nrDigits[i]));
  }
  println();
  smallValuesLogFileWriter.println();
  //Clean up
  for (int i=0; i< totDataseries; i++ ) {
    sumDatavalues[i] = 0;
    sumTimes[i] = 0;
  }
  nrSumPts = 0;
  maxSumTimes = 0;
}

String formatDigits(float num, int nrDigits) {
  String formatStr = "%."+nrDigits+"f";
  String opt = String.format(formatStr, num);
  return opt;
}

void grabNewDataValues(String readLine) {
  if ( readLine.charAt(0) != commentChar.charAt(0) ) {
    String[] dataPts = split(readLine, ",");
    for (int i=0; i< totDataseries; i++ ) {
      newDatavalues[i] = float(dataPts[i+1]);
    }
    // Return timeStap
    timeBefore = timeNow;
    timeNow = Long.parseLong(dataPts[0]);
    if ( timeBefore == -1 ) {
      // No values set yet
      deltaTimestamp = maxDeltaTimestamp;
    } else {
      deltaTimestamp = timeNow - timeBefore;
    }
    //smallValuesLogFileWriter.println("#L: "+deltaTimestamp+" "+readLine);
  } else {
    smallValuesLogFileWriter.println(readLine);
  }
}

void updateNewSumValues() {
  for (int i=0; i<totDataseries; i++ ) {
    if (!Float.isNaN(newDatavalues[i])) {
      sumDatavalues[i] += deltaTimestamp * newDatavalues[i];
      sumTimes[i] += deltaTimestamp;
      if ( sumTimes[i] > maxSumTimes ) {
        maxSumTimes = sumTimes[i];
      }
    }
  }
  oldDeltaTimestamp = deltaTimestamp;
  nrSumPts++;
}

long readValuesFile(String ValuesLogFileName, long minStartValue) {
  ValuesLogFileReader = createReader(ValuesLogFileName);
  String ValuesLogFileReadLine   = "";
  long firstTimeStamp   = 0;
  long fullTimeStampUs = 0;
  long fullTimeStampMs = 0;
  long deltaTimeStamp;
  String readLineSubString;
  long currentLogFileStartTimestamp;
  long localTimeStamp;
  //===============//
  // Start reading //
  //===============//
  ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
  if ( ValuesLogFileReadLine.indexOf(VALUESLOGFILEHEADER) == 0 ) {
    currentLogFileStartTimestamp = getLogFileTimeStamp(ValuesLogFileReadLine, VALUESLOGFILEHEADER);
    localTimeStamp = 0;
    println("START TIME: "+currentLogFileStartTimestamp);
    ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
    // Check if we have a valid formatted header line
    if ( foundValuesLogHeaderFile == 0 ) {
      ValuesLogFileHeaderLine = ValuesLogFileReadLine;
      println("Found Header: "+ValuesLogFileHeaderLine);
      fullValuesLogFileHandle.println(ValuesLogFileHeaderLine);
      // Read the rest of the commented lines
      ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
      while ( ValuesLogFileReadLine.charAt(0) == commentChar.charAt(0) ) {
        // This is a comment
        fullValuesLogFileHandle.println(ValuesLogFileReadLine);
        // Read the rest of the commented lines
        ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
      }
      foundValuesLogHeaderFile = 1;
    } else {
      if ( !ValuesLogFileHeaderLine.equals(ValuesLogFileReadLine) ) {
        println("LOG HEADER IS DIFFERENT!: >"+ValuesLogFileReadLine+"< != >"+ValuesLogFileHeaderLine+"<");
        exit();
      }
    }
    //==================================
    // Ignore the lines with comments (this is needed for the 2nd through last file that is processed)
    while ( ValuesLogFileReadLine.charAt(0) == commentChar.charAt(0) ) {
      // Read the rest of the commented lines
      ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
    }
    //===================================
    // Add a (commented) note indicating the origin file
    fullValuesLogFileHandle.println(commentChar+ValuesLogFileName);
    //==================================
    //Read the rest of the lines past the header and commented lines
    while (ValuesLogFileReadLine != null) {
      localTimeStamp = getLocalTimeStamp(ValuesLogFileReadLine);
      fullTimeStampUs = currentLogFileStartTimestamp*1000;
      //print("TIM1: "+fullTimeStampUs);
      fullTimeStampUs += localTimeStamp;
      fullTimeStampMs = fullTimeStampUs/1000;
      //println(" + "+localTimeStamp+" ==> "+fullTimeStampUs);
      //println("TIME: "+currentLogFileStartTimestamp*1000+" + "+localTimeStamp+" ==> "+fullTimeStampMs+" ==> "+printLong(fullTimeStampMs));
      if ( firstTimeStamp  == 0 ) {
        firstTimeStamp = 1;
        deltaTimeStamp = fullTimeStampUs - minStartValue;
        if ( deltaTimeStamp < 0 ) {
          println("!!!!!!####!!!!! DELTA < 0 "+deltaTimeStamp);
        }
        print("DELTA: "+deltaTimeStamp+" == "+currentLogFileStartTimestamp*1000+"+"+localTimeStamp+" : "+fullTimeStampUs+" ==> ");
      }
      readLineSubString = ValuesLogFileReadLine.substring(ValuesLogFileReadLine.indexOf(LOG_VALUE_SEPARATOR));
      fullValuesLogFileHandle.println(printLong(fullTimeStampMs)+readLineSubString);
      ValuesLogFileReadLine = readNextLogLine(ValuesLogFileReader);
    }
    if ( firstTimeStamp  == 1 ) {
      println(currentLogFileStartTimestamp*1000+"+"+localTimeStamp+" : "+fullTimeStampUs+" ==> ");
      return fullTimeStampUs;
    }
  } else {
    println("No Valid first Header line found! Aborting!!!");
  }
  return -1;
  //delay(3000);
}

void processCommentedLine(String line) {
  String[] values = split(line, ",");
  int totValues = values.length - 1;
  if ( values[0].equals(LOG_DIGITS_NAME) ) {
    //println(LOG_DIGITS_NAME+"==> "+totValues);
    for (int i=0; i<totValues; i++ ) {
      //print(i+"::"+values[i+1]);
      nrDigits[i] = int(values[i+1]);
      //println(i+" ==> "+nrDigits[i]);
    }
  }
}