#$GPGSA,A,1,,,,,,,,,,,,,,,*1E
#$GPGSV,3,1,09,29,77,253,,25,67,102,29,31,49,291,,02,30,052,35*76
#$GPGSV,3,2,09,12,29,108,38,21,12,192,,05,09,094,,10,08,045,*78
#$GPGSV,3,3,09,14,05,233,*42
#$GPRMC,071842.713,V,4818.9438,N,01621.4179,E,1.83,294.15,041014,,,N*76


proc convert2Degree { nWGS84 cQuadrant } {
  set fDegree [ expr int ($nWGS84/100) ]
  set fMin [ expr $nWGS84 - $fDegree*100 ]
  set fDegree [ expr $fDegree + $fMin/60 ]
  if { ($cQuadrant=="S") || ($cQuadrant=="W") } {
    set fDegree [ expr -$fDegree ]
  }	
  return $fDegree
}

proc convertDateTime { strNMEATime strNMEADate strISO8601 strCSV } {
  upvar $strISO8601 strDatISO8601
  upvar $strCSV strDatCSV
  #ISO8601 Format:  "%Y-%m-%dT%H:%M:%S"
  #CSV Fomat:       "%Y-%m-%d %H:%M:%S"
  regexp "(\[0-9]\[0-9])(\[0-9]\[0-9])(\[0-9]\[0-9])\." $strNMEATime ignore hrs min sec
  regexp "(\[0-9]\[0-9])(\[0-9]\[0-9])(\[0-9]\[0-9])" $strNMEADate ignore day mon yrs
  
  set yrs [expr $yrs + 2000]
  set strDatISO8601 "[format "%04d-%02d-%02dT%02d:%02d:%02d" $yrs $mon $day $hrs $min $sec]"
  set strDatCSV "[format "%04d-%02d-%02d %02d:%02d:%02d" $yrs $mon $day $hrs $min $sec]"
}

proc ReadGPSPos { fLat fLon fSpeed nCourse strDate strDesc } {
  upvar $fLat fLocLat
  upvar $fLon fLocLon
  upvar $fSpeed fLocSpeed
  upvar $nCourse nLocCourse
  upvar $strDate strLocDate
  upvar $strDesc strLocDesc

  set strGPRMC "GPRMC,(.*),(\[AV\]),(.*),(\[NS\]),(.*),(\[EW\]),(.*),(.*),(.*),,,\[A-Z\]\\*"
  set strGPGSV "GPGSV,(\[0-9]),(\[0-9]),(\[0-9]+),(.*)\\*"

  set fLocLat 0.0
  set fLocLon 0.0 
  set fLocSpeed 0.0
  set nLocCourse 0
  set strISO8601Date "1970-01-0-01T00:00:00"
  set strLocDate "1970-01-0-01 00:00:00"
  set bValid 0

  expect {
    -re $strGPRMC { 
	  #puts "Recommended Minimum Sentence C: $expect_out(0,string)" 
      if { $expect_out(2,string)=="A"} {
        set bValid 1
      }		  
	  set fLocLat [convert2Degree  $expect_out(3,string) $expect_out(4,string)]
	  set fLocLon [convert2Degree  $expect_out(5,string) $expect_out(6,string)]
	  set fLocSpeed $expect_out(7,string)
	  set nLocCourse [expr int ($expect_out(8,string))]
	  convertDateTime $expect_out(1,string) $expect_out(9,string) strISO8601Date strLocDate
	}
	#-re $strGPGSV {
	#  puts "Satellites in view: $expect_out(0,string)" 
	#  puts "No Frames: $expect_out(1,string)"
	#  puts "Frame Idx: $expect_out(2,string)"
	#  puts "No. Sat:   $expect_out(3,string)"
	#  puts "Signals:   $expect_out(4,string)"
    #}
    timeout {puts "no GPS minimum dataset received" }
  }
  set strLocDesc "[format "%s Pos: %8.5f/%8.5f deg, Speed: %5.2f, Course: %3d" $strISO8601Date $fLocLat $fLocLon $fLocSpeed $nLocCourse]"
  if { $bValid == 0 } { append strLocDesc " INVALID!!!" }
  return $bValid
}
