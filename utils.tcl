
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
