package require Expect
package require cmdline
package require textutil

set basedir D:/Development/FieldFox/tcl_scripts

source $basedir/envir.tcl
source $basedir/settings.tcl
source $basedir/N9912A.tcl

proc ExpectFloat {} {
  expect -re "\[\\-\]\*\[0-9\]\[.\]\[0-9E+\\-\]\*\\n"
  scan $expect_out(0,string) "%f" floatValue
  return $floatValue
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

