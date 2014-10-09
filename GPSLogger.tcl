package require Expect
package require cmdline
package require textutil

set basedir D:/Development/FieldFox/tcl_scripts
log_user 0

source $basedir/envir.tcl
source $basedir/settings.tcl
source $basedir/utils.tcl
source $basedir/N9912A.tcl
source $basedir/utlNMEA.tcl

puts "GPS Logger with N9912A SA Control"
puts "Connecting via: $telnet to: $myhost"

spawn $telnet $myhost
set spwnN9912 $spawn_id

set bUseN9912 1
if { [Connect $myhost] == 0} { set bUseN9912 0 }

spawn $telnet $gpsConn
set spwnGPS $spawn_id

set outFileName "[clock format [clock seconds] -format "%Y-%m-%dT%H_%M_%S"].csv"
puts "Writing File $basedir/$outFileName\n"
set outfile [open "$basedir/$outFileName" "w"]

set logGPSLogFileName "[clock format [clock seconds] -format "%Y-%m-%dT%H_%M_%S"].log"
puts "Writing GPS LogFile $basedir/$logGPSLogFileName\n"
set gpsLogfile [open "$basedir/$logGPSLogFileName" "w"]

puts $outfile "time;frq max;maxLevel;frq min;minLevel;GPSTime;Lat;Lon;Speed;Course;GPSValid;"

set bAborted 0

while { $bAborted == 0 } {
	if { [ wasAborted $nDefTimeout ] > 0 } {
	  set bAborted = 1
	  break
	}

	EchoISO8601Date
	if { $bUseN9912 > 0 } {
      set spawn_id $spwnN9912
	  puts "  Measuring"
      Init
	  StartMeasure
	  sleep 2
	  ReadMaxValue 2 nFreqMax nLevelMax
	  ReadMaxValue 3 nFreqMin nLevelMin
	} else {
	  puts "  Skipping Measuring"
	  sleep 2
	  set nFreqMax 0
	  set nFreqMin 0 
	  set nLevelMax 0 
	  set nLevelMin 0 
	}
	
	set spawn_id $spwnGPS
	set bValid [ReadGPSPos fLat fLon fSpeed nCourse strDate strGPSDesc $gpsLogfile ]

	EchoISO8601Date
	puts "  [format "%f MHz" $nFreqMax] max: [format "%5.1f dBm" $nLevelMax] min: [format "%5.1f dBm" $nLevelMin]"
	puts "  $strGPSDesc"
	set strClock [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

	set strTempOut "$strClock;[format "%f" $nFreqMax];[format "%5.1f" $nLevelMax];"
	append strTempOut "[format "%f" $nFreqMin];[format "%5.1f" $nLevelMin];"
	append strTempOut "$strDate;[format "%f;%f;%f;%d;%d;" $fLat $fLon $fSpeed $nCourse $bValid]"
	set strTempOut [ string map { . , } $strTempOut ] 
	puts $outfile $strTempOut
	flush $outfile
	flush $gpsLogfile
}

close $outfile
close $gpsLogfile
set spawn_id $spwnGPS
close 

puts "**** READY ***"

puts ""
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""
puts ""

return

