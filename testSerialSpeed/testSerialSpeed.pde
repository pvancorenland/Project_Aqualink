import processing.serial.*;

Serial readPort;
Serial writePort;

String readComPortName = "/dev/tty.usbserial-AL00R5KS";
String writeComPortName = "/dev/tty.usbserial-AL00R69H";
int serialSpeed = 9600;
volatile long timeStart;
long time1, time2, time3;
int TIMEOUT = 1000;
int RXStartuptime = 2000;
int bytesSent = 0;
volatile int bytesReceived = 0;
long sentTimes[]     = new long[1024];
long receivedTimes[] = new long[1024];
int receivedData[]   = new int[1024];

int totBytes=256;
int totSequences = 1;
int delayBetweenSequences = 250;

void setup() {
  //println("Ports: ");
  //printArray(Serial.list());
  println("Opening COM ports");
  readPort  = new Serial(this, readComPortName, serialSpeed);
  writePort = new Serial(this, writeComPortName, serialSpeed);
  println("Allowing receiver to settle");
  delay(RXStartuptime);
}

void draw() {
  bytesReceived = 0;
  bytesSent     = 0;
  int totBytesToBeSent = totBytes/2;
  println("\nSending: "+totSequences+" sequences of "+totBytesToBeSent+" Bytes");
  timeStart = millis();
  // START SENDING
  for ( int seqVal = 0; seqVal < totSequences; seqVal++ ) {
    // SEND
    println("");
    for ( int bytePos=0; bytePos< totBytesToBeSent; bytePos++ ) {
      writePort.write(seqVal);
      sentTimes[bytesSent++] = millis()-timeStart;
      writePort.write(bytePos);
      sentTimes[bytesSent++] = millis()-timeStart;
      delay(5);
      print("X"+hex(seqVal, 2)+" "+hex(bytePos, 2)+" ");
    }
    delay(delayBetweenSequences);
  }
  delay(3000);
  int txBps = round(bytesSent*8000/(sentTimes[bytesSent-1] - sentTimes[0]));
  int rxBps = round(bytesReceived*8000/(receivedTimes[bytesReceived-1] - receivedTimes[0]));
  print("\nTX: ");
  for ( int tx=0; tx< bytesSent; tx++ ) {
    print(sentTimes[tx]+" ");
  }
  print("\nRX: ");
  for ( int rx=0; rx< bytesReceived; rx++ ) {
    print(receivedTimes[rx]+" ");
  }
  println("");
  println("\nSent "+bytesSent+" Bytes @ "+txBps+"bps+, Received "+bytesReceived+" Bytes @ "+rxBps+"bps");
  delay(10000);
}


void serialEvent(Serial p) { 
  if ( p == readPort ) {
    receivedData[bytesReceived] = readPort.read();
    print("R"+hex(receivedData[bytesReceived], 2)+" ");
    receivedTimes[bytesReceived++] = millis() - timeStart;
  }
}