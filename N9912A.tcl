proc WaitForPrompt {} {
  expect "SCPI>"
  #puts "Prompt Received <$expect_out(buffer)>"
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

proc ReadValueOld {} {
  SendCommand "CALC:MARK1:FUNC:MAX" "Setting Marker to the MAX" 0
  WaitForPrompt
  SendCommand "CALC:MARK1:X?" "Request X Value" 0
  set xVal [ExpectFloat]
  set xVal [expr $xVal/1000000]
  SendCommand "CALC:MARK1:Y?" "Request Y Value" 0
  set yVal [ExpectFloat]
  puts "[format "%f MHz" $xVal] [format "%5.1f dBm" $yVal]"
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

