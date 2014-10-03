package require Expect
package require cmdline
package require textutil

set basedir D:/Development/FieldFox/tcl_scripts

source $basedir/envir.tcl
source $basedir/settings.tcl


proc ExpectFloat {} {
  expect -re "\[\\-\]\*\[0-9\]\[.\]\[0-9E+\\-\]\*\\n"
  scan $expect_out(0,string) "%f" floatValue
  return $floatValue
}

proc WaitForPrompt {} {
  expect "SCPI>"
  #puts "Prompt Received <$expect_out(buffer)>"
}

proc SendCommand {cmd comment verbose} {
  if {$verbose > 0} {
    puts "$comment --> Sending: $cmd"
  }
  set bDidWork 0
  for { set nRetryCnt 3 } {($nRetryCnt>0) && ($bDidWork==0)} {incr nRetryCnt -1} {
    send "$cmd \r\n"
    expect {
      $cmd { 
        #puts "fine!" 
        set bDidWork 1
      }
      { 
        puts "Did not work!" 
      }
    }
  }
}

proc Init {} {
  SendCommand "TRAC1:TYPE CLRW" "Trace1 to clear/write" 0
  SendCommand "TRAC2:TYPE MAXH" "Trace2 to max" 0
  SendCommand "TRAC3:TYPE MINH" "Trace3 to min" 0
  SendCommand "CALC:MARK2:TRAC 2" "Marker 2 to Trace 2" 1
  SendCommand "CALC:MARK3:TRAC 3" "Marker 3 to Trace 3" 1
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

puts "N9912A SA Control"
puts "Connecting via: $telnet to: $myhost"

spawn $telnet $myhost

expect "Welcome"
WaitForPrompt
puts "connected to $myhost\n"

Init

for { set nRepeat 5 } {$nRepeat>0} {incr nRepeat -1} {
  StartMeasure
  sleep 8
  #ReadValueOld
  ReadMaxValue 2 nFreqMax nLevelMax
  PlaceMarker 3 $nFreqMax
  ReadValue 3 nFreqMin nLevelMin
  set strClock [clock format [clock seconds] -format "%Y%m%d %H:%M:%S"]
  puts "$strClock: [format "%f MHz" $nFreqMax] max: [format "%5.1f dBm" $nLevelMax] min: [format "%5.1f dBm" $nLevelMin]"

}

puts "**** READY FREDDY ***"
expect "*"
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""

return

