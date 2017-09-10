long getLocalTimeStamp( String line ) {
  String tmp = trim(line.substring(0, line.indexOf(LOG_VALUE_SEPARATOR)));
  //float tmpVal = Float.parseFloat(tmp);
  tmp = String.format("%.0f", Float.parseFloat(tmp));
  long tmpVal = Long.parseLong(tmp);
  //  long timeStamp = long();
  //long timeStamp = 1;
  //return timeStamp;
  return tmpVal;
}

long getLogFileTimeStamp(String rawLogFileReadLine, String header) {
  if ( rawLogFileReadLine.indexOf(header) == 0 ) {
    rawLogFileReadLine += " -1";
    rawLogFileReadLine = rawLogFileReadLine.substring(header.length());
    String[] tmpVals = split(rawLogFileReadLine, " ");
    if ( (tmpVals.length < 4)||(tmpVals[3] == "-1") ) {
      return -1;
    } else {
      return Long.valueOf(tmpVals[1]);
    }
  }
  return -1;
}

String addSpaces(String Str, int nrOfSpaces) {
  int nrSpacesAdded = nrOfSpaces-Str.length();
  for (int i=0; i< nrSpacesAdded; i++ ) {
    Str += " ";
  }
  return Str;
}

String readNextLogLine(BufferedReader readerID) {
  String line;
  try {
    line = readerID.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  return line;
}

String printLong (long val) {
  return String.valueOf(val);
  /*
  String opt ="";
  long divisor = 10000000L;
  long valMS   = val/divisor;
  int valMSint = int(valMS);
  long tmp = divisor*valMSint;
  long valLS = val - tmp;
  int valLSint = int(valLS);
  //opt = str(tmp)+"==>"+str(valMS)+"="+str(valMSint)+" "+str(valLS)+"="+str(valLSint);
  if ( valMSint > 0 ) {
  opt = str(valMSint)+str(valLSint);
  } else {
  opt = str(valLSint);
  }
  return opt;
  */
}