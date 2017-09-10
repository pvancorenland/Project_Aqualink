//==========================//
// TODO
//      if ( !!areWeReadingRawLogFile() ) { <== in emulators.pde
 
// Proliferate unknownResponse command
/*
Clean up checkSPAButtonResponse()
STILL CRASHES:
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
// ==== DONE ========================================================================
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