{
  RTC DS1302 Controls
  Nathan Torkaman
  tinyit@gmail.com
  Created 4/12/2014
  Updated 4/4/2015
  Spin Code
  
}
CON
  'Command Bytes
  WP_OFF = $00
  WP_ON = $80
  RAM_Select = $40
  CAL_Select = $00

  ' Read or Write
  cREAD = $01
  cWRITE = $00

  ' Register Addresses for time on the DS1302
  rSEC = $80
  rMIN = $82
  rHOUR = $84
  rDATE = $86
  rMONTH = $88
  rDAY = $8A
  rYEAR = $8C
  rCTRL = $8E

  ' Other Register Addresses
  rCharge = $90
  rCLKburst = $BE

  ' Trickle Charger Register Defines
  enCharger = $A0

  oneDiode = $04
  twoDiode = $08

  Res2k = $01
  Res4k = $02
  Res8k = $03

  us5 = 800'400 working at both 800 == 10us @ 80Mhz clkfreq
  us1 = 800'80
    

VAR
  long  RST,SCLK,IO

PUB init(_RST,_SCLK,_IO)
  RST := _RST
  SCLK := _SCLK
  IO := _IO

  ' Initialize as all outputs ( 1 output, 0 input)
  dira[RST] := 1
  dira[SCLK] := 1
  dira[IO] := 1

  ' Initialize low
  outa[RST] := 0
  outa[SCLK] := 0
  outa[IO] := 0

PRI start
  outa[RST] := 0
  outa[SCLK] := 0
  outa[IO] := 0
  waitcnt(us5+cnt)

  outa[RST] := 1
  waitcnt(us5+cnt)

PRI stop
  outa[RST] := 0
  waitcnt(us5+cnt)

PRI write(_data) | Index
  _data <-= 1
  REPEAT Index from 0 to 7
    outa[IO] := (_data ->= 1) & 1    ' Set data LSB sent first
    waitcnt(us1+cnt)
    outa[SCLK] := 1             ' Cycle the CLK to send bit
    waitcnt(us1+cnt)
    outa[SCLK] := 0
    waitcnt(us1+cnt)
    
PRI read : data | Index
  dira[IO] := 0 'Set IO to input to start reading pin
  waitcnt(us1+cnt)
  
  REPEAT Index from 0 to 7
    data |= INA[IO] << Index

    outa[SCLK] := 1
    waitcnt(us1+cnt)
    outa[SCLK] := 0
    waitcnt(us1+cnt)

  dira[IO] := 1 'Set back to output

  RETURN data

PRI bin2bcd(_data) : bcdNum
  IF _data > 99 | _data < 0
    _data := 0

  bcdNum := ((_data/10)<<4) + (_data // 10)

PUB getRST
  return RST

PUB getSCLK
  return SCLK

PUB getIO
  return IO


PUB getSec : Sec | _readData
  start
  write(rSEC | cREAD)
  _readData := read
  stop

  Sec := ((_readData & $70)>>4)*10 + (_readData & $0F)
  Return Sec

PUB getMin : Minute | _readData
  start
  write(rMIN | cREAD)
  _readData := read
  stop

  Minute := ((_readData & $F0)>>4)*10 + (_readData & $0F)
  Return Minute

PUB getHour : Hour | _readData
  start
  write(rHOUR | cREAD)
  _readData := read
  stop

  IF _readData & $80 == 1
    Hour := ((_readData & $10)>>4)*10 + (_readData & $0F)
  ELSE
    Hour := ((_readData & $30)>>4)*10 + (_readData & $0F)

  Return Hour

PUB getAMPM : AMPM | _readData
  start
  write(rHOUR | cREAD)
  _readData := read
  stop

  IF _readData & $80 == $80
    AMPM := (_readData & $20)>>6

  ELSE
    AMPM := 0

  Return AMPM

PUB getDate : Date | _readData
  start
  write(rDate | cREAD)
  _readData := read
  stop

  Date := ((_readData & $F0)>>4)*10 + (_readData & $0F)

  Return Date

PUB getMonth : Month | _readData    
  start
  write(rMonth | cREAD)
  _readData := read
  stop

  Month := ((_readData & $10)>>4)*10 + (_readData & $0F)

  Return Month

PUB getDay : Day | _readData
  start
  write(rDay | cREAD)
  _readData := read
  stop

  Day := _readData

  Return Day

PUB getYear : Year | _readData
  start
  write(rYear | cREAD)
  _readData := read
  stop

  Year := ((_readData & $F0)>>4)*10 + (_readData & $0F)

  Return Year

PUB getCharge : Charge | _readData
  start
  write(rCharge | cREAD)
  _readData := read
  stop

  Charge := _readData

  Return Charge

PUB setSec(ClkHalt,_data)
  'ClkHalt: 1=stopped, 0=running

  IF _data > 59 | _data < 0
    _data := 0

  _data := bin2bcd(_data)

  IF ClkHalt > 1 | ClkHalt < 0
    'ClkHalt := 0
    _data |= $80

  start
  write(rSEC | cWRITE)
  write(_data)
  stop

PUB setMin(_data)
  IF _data > 59 | _data < 0
    _data := 0

  _data := bin2bcd(_data)

  start
  write(rMIN | cWRITE)
  write(_data)
  stop

PUB setHour(Military, AMPM, _data)
  IF Military > 1 | Military < 0
    Military := 0

  IF Military == 1
    IF _data > 23 | _data < 0
      _data := 0

    _data := bin2bcd(_data)

  IF Military == 0
    IF _data > 12 | _data < 1
      _data := 12

    _data := bin2bcd(_data)
    IF AMPM > 1 | AMPM < 0
      AMPM := 0
    IF AMPM == 1
      _data |= $A0

  start
  write(rHOUR | cWRITE)
  write(_data)
  stop


' Set Date, Month, Day  broken = enters the IF statement even when not true
PUB setDate(_data)

  IF _data > 31 | _data < 1
    _data := 21

  _data := bin2bcd(_data)
  
  start
  write(rDATE | cWRITE)
  write(_data)
  stop

PUB setMonth( _data )

  IF (_data > 12 | _data < 1)
    _data := 3

  _data := bin2bcd(_data)

  start
  write(rMONTH | cWRITE)
  write(_data)
  stop

PUB setDay(_data)

  IF (_data > 7 | _data < 1)
    _data := 3

  _data := bin2bcd(_data)

  start
  write(rDAY | cWRITE)
  write(_data)
  stop

PUB setYear(_data)
  IF (_data > 99 | _data < 0)
    _data := 14

  _data := bin2bcd(_data)

  start
  write(rYEAR | cWRITE)
  write(_data)
  stop

PUB setWP(_data)
  IF _data <> 0
    _data := $80

  start
  write(rCTRL | cWRITE)
  write(_data)
  stop



    