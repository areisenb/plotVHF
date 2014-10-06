set myhost "FieldFox"
set gpsConn "BT_GPS"
set nDefTimeout 4
set nMinFrequency 156900000
set nMaxFrequency 157000000

#carrier must be lower than this level to be detected as off after on
set nMaxLevelDet -80    
#carrier must be higher than this level to be detected as on after off should be higher
# than the value before to achieve an hysteresis
set nMinLevelDet -100	
set TOTestInterval 5
set nTestCount 5
