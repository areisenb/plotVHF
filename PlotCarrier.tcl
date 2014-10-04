package require Expect
package require cmdline
package require textutil

set basedir D:/Development/FieldFox/tcl_scripts


source $basedir/envir.tcl
source $basedir/settings.tcl
source $basedir/N9912A.tcl
source $basedir/utlNMEA.tcl

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
set spwnN9912 $spawn_id

if { [Connect $myhost] == 0} return

Init

set outFileName "[clock format [clock seconds] -format "%Y-%m-%dT%H_%M_%S"].csv"
puts "Writing File $basedir/$outFileName\n"
set outfile [open "$basedir/$outFileName" "w"]

puts $outfile "time;frq max;maxLevel;frq min;minLevel;GPSTime;Lat;Lon;Speed;Course;GPSValid"

spawn $telnet $gpsConn
set spwnGPS $spawn_id


for { set nRepeat 5 } {$nRepeat>0} {incr nRepeat -1} {
  set spawn_id $spwnN9912
  StartMeasure
  sleep 8
  ReadMaxValue 2 nFreqMax nLevelMax
  ReadMaxValue 3 nFreqMin nLevelMin
  
  set spawn_id $spwnGPS
  set bValid [ReadGPSPos fLat fLon fSpeed nCourse strDate strGPSDesc]


  set strClock [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
  puts "$strClock: [format "%f MHz" $nFreqMax] max: [format "%5.1f dBm" $nLevelMax] min: [format "%5.1f dBm" $nLevelMin]"
  puts "$strGPSDesc"
  set strClock [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

  set strTempOut "$strClock;[format "%f" $nFreqMax];[format "%5.1f" $nLevelMax];"
  append strTempOut "[format "%f" $nFreqMin];[format "%5.1f" $nLevelMin];"
  append strTempOut "$strDate;[format "%f;%f;%f;%d;%d;" $fLat $fLon $fSpeed $nCourse $bValid]"
  set strTempOut [ string map { . , } $strTempOut ] 
  puts $outfile $strTempOut
  
  #puts -nonewline $outfile "$strClock;[format "%f" $nFreqMax];[format "%5.1f" $nLevelMax];"
  #puts -nonewline $outfile "[format "%f" $nFreqMin];[format "%5.1f" $nLevelMin];"
  #puts -nonewline $outfile "$strDate;[format "%f;%f;%f;%d;%d;" $fLat $fLon $fSpeed $nCourse $bValid]"
  #puts $outfile "" 

}

close $outfile
set spawn_id $spwnGPS
close 

puts "**** READY FREDDY ***"

puts ""
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""

return

