proc WaitForPrompt {} {
  expect "SCPI>"
  #puts "Prompt Received <$expect_out(buffer)>"
}

proc Connect { myhost } {
  expect {
    "Welcome" { 
      WaitForPrompt
      puts "connected to $myhost\n"
      return 1
    }
    timeout { 
      puts "could not connect to $myhost\n"
      return 0 
    }
  }
  return 0
}

proc Init {} {
  SendCommand "TRAC1:TYPE CLRW" "Trace1 to clear/write" 0
  SendCommand "TRAC2:TYPE MAXH" "Trace2 to max" 0
  SendCommand "TRAC3:TYPE MINH" "Trace3 to min" 0
  SendCommand "CALC:MARK2:TRAC 2" "Marker 2 to Trace 2" 0
  SendCommand "CALC:MARK3:TRAC 3" "Marker 3 to Trace 3" 0
}

proc StartMeasure {} {
  SendCommand "TRAC1:TYPE CLRW" "Trace1 to clear/write" 0
  SendCommand "TRAC2:TYPE CLRW" "Trace2 to clear/write" 0
  SendCommand "TRAC2:TYPE MAXH" "Trace2 to max" 0
  SendCommand "TRAC3:TYPE CLRW" "Trace3 to clear/write" 0
  SendCommand "TRAC3:TYPE MINH" "Trace3 to min" 0
}

proc PlaceMarker { nMarker nFreq } {
  set nFreq [expr $nFreq*1000000]
  SendCommand "CALC:MARK$nMarker:X $nFreq" "Set X Value" 0
  WaitForPrompt
}

proc ReadValue { nMarker nFreq nLevel} {
  upvar $nFreq xVal
  upvar $nLevel yVal
  SendCommand "CALC:MARK$nMarker:X?" "Request X Value" 0
  set xVal [ExpectFloat]
  set xVal [expr $xVal/1000000]
  SendCommand "CALC:MARK$nMarker:Y?" "Request Y Value" 0
  set yVal [ExpectFloat]
}

proc ReadMaxValue { nMarker nFreqMax nLevelMax} {
  upvar $nFreqMax nFreq
  upvar $nLevelMax nLevel
  SendCommand "CALC:MARK$nMarker:FUNC:MAX" "Setting Marker to the MAX" 0
  WaitForPrompt
  ReadValue $nMarker nFreq nLevel
}

proc WaitForSignalAfterBreak { strPrefix nFreqMin nFreqMax nMaxCarrierLevel nMinCarrierLevel } {
  set nFrequMax 0.0
  set nLevelMax -90.0
  set bCarrierOn 1
  set bAborted 0
  global nDefTimeout
  
  SendCommand "TRAC1:TYPE CLRW" "Trace1 to clear/write" 0
  SendCommand "TRAC2:TYPE BLAN" "Trace2 off" 0
  SendCommand "TRAC3:TYPE BLAN" "Trace3 off" 0
  SendCommand "TRAC4:TYPE BLAN" "Trace4 off" 0

  SendCommand "FREQ:STAR $nFreqMin" "Setting Start Freq to $nFreqMin" 0
  SendCommand "FREQ:STOP $nFreqMax" "Setting Stop Freq to $nFreqMax" 0
  SendCommand "CALC:MARK1:TRAC 1" "Marker 1 to Trace 1" 0

  #loop until carrier is gone - level is below MaxCarrier Level
  while { $bCarrierOn > 0 } {
    ReadMaxValue 1 nFreqMax nLevelMax
	if { [ wasAborted $nDefTimeout ] > 0 } {
	  set bAborted = 1
	  break
	}
	if { $nLevelMax < $nMaxCarrierLevel } {
	   set bCarrierOn 0
	   puts "$strPrefix Carrier is OFF"
	}
  }
	
  if { $bAborted > 0 } {
    return 1
  }
  
  while { $bCarrierOn == 0 } {
    ReadMaxValue 1 nFreqMax nLevelMax
	if { [ wasAborted $nDefTimeout ] > 0 } {
	  set bAborted = 1
	  break
	}
	if { $nLevelMax > $nMinCarrierLevel } {
	   set bCarrierOn 1
	   puts "$strPrefix Carrier is ON"
	} 
  }	
  return $bAborted
}

