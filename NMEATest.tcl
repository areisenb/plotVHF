package require Expect
package require cmdline
package require textutil

set basedir D:/Development/FieldFox/tcl_scripts


source $basedir/envir.tcl
source $basedir/settings.tcl
source $basedir/utlNMEA.tcl

puts "GPLS Logger"

spawn $telnet $gpsConn

for { set nRepeat 8 } {$nRepeat>0} {incr nRepeat -1} {
  set timeout 4
  set bValid [ReadGPSPos fLat fLon fSpeed fCourse strDate strDesc]
  puts "$strDesc"
  puts ""
}

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

