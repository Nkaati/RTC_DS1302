{
  RTC DS1302 Control Demo
  Nathan Torkaman
  tinyit@gmail.com
  Created 4/12/2014
  Updated 4/4/2015
  
}
CON
        _clkmode = xtal1 + pll16x      'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        CLK_PIN = 20 '5
        DAT_PIN = 19 '6
        RST_PIN = 18 '7
        topHeading = $02

VAR
  long second,minute,hour,date,day,month,year
  long RST,SCLK,IO
  long stack[30]
  byte test1
   
OBJ
  Ser   : "FullDuplexSerial"
  RTC   : "RTC_DS1302"
  
PUB main
  test1 := %0011_1000
  cognew(getRTCdata, @stack[0])

  waitcnt(cnt + (1 * clkfreq))
  Ser.Start(31,30,0,9_600)
  
  REPEAT
    serialDisplay
    waitcnt(cnt + (1 * clkfreq)) 


PUB serialDisplay  
  'start the FullDuplexSerial object
                      'requires 1 cog for operation
                        
  Ser.Str(STRING(1,1,"Testing the FullDuplexSerial object."))     'print a test string
  newline                                                 'print a new line
  
  Ser.Str(STRING("All Done!"))
  newline

  Ser.Str(STRING("Test Byte:"))
  Ser.Dec((test1&($01<<6))>>6)
  newline
  
  Ser.Str(STRING("RSTpin:"))
  Ser.Dec(RST)
  newline
  Ser.Str(STRING("SCLKpin:"))
  Ser.Dec(SCLK)
  newline
  Ser.Str(STRING("IOpin:"))
  Ser.Dec(IO)
  newline

  Ser.Str(STRING("Sec:"))
  Ser.Dec(second)
  newline
  Ser.Str(STRING("Min:"))
  Ser.Dec(minute)
  newline
  Ser.Str(STRING("Hour:"))
  Ser.Dec(hour)
  newline
  Ser.Str(STRING("Date:"))
  Ser.Dec(date)
  newline
  Ser.Str(STRING("Day:"))
  Ser.Dec(day)
  newline
  Ser.Str(STRING("Month:"))
  Ser.Dec(month)
  newline
  Ser.Str(STRING("Year:"))
  Ser.Dec(year)
  


PUB newline
  Ser.Tx($0D)

PUB getRTCdata

  RTC.init(RST_PIN,CLK_PIN,DAT_PIN)                    ' initialize pins for RTC DS1302


  
  ' set the clock :)
  RTC.setWP(0)
  RTC.setSec(0,0)
  RTC.setMin(23)
  RTC.setHour(1, 0, 23)
  RTC.setDate(3)
  RTC.setMonth(3) 
  RTC.setDay(21) ' of the week
  RTC.setYear(17)
  RTC.setWP(1)
  

  REPEAT
    RST := RTC.getRST
    SCLK := RTC.getSCLK
    IO := RTC.getIO
    
    second := RTC.getSec
    minute := RTC.getMin
    hour := RTC.getHour
    date := RTC.getDate
    day := RTC.getDay
    month := RTC.getMonth
    year := RTC.getYear