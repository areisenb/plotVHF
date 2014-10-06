
proc wasAborted { nDefTimeout } {
  set timeout 0
  set nAborted 0
  expect_user {
    -re ".+" { 
	  puts "aborted"
	  set nAborted 1
	  break
	}
  }  
  set timeout $nDefTimeout
  return $nAborted
}

proc EchoISO8601Date { } {
  set strClock [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
  puts "$strClock"
}

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
        set bDidWork 1
      }
      { 
        puts "Did not work!" 
      }
    }
  }
}

