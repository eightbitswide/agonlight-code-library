  100 X=0 :TS=0: CO=0
  110 VER$="2.3b"
  120 RE$="ATDT GLASSTTY.COM:6502"+CHR$(13)
  130 RS$="ATZ"+CHR$(13) : HU$="ATH"+CHR$(13)
  140 REM TELSTAR TERMINAL BY EIGHTBITSWIDE
  150 REM SERIAL ROUTINES BY RICHARD TURNNIDGE 2023 - THANK YOU RICHARD!
  160 REM This version is for 16-bit basic but you could adapt
  170 REM Check if we are running in 24-bit BASIC
  180 :
  190 REM REQUIRES MOD-WIFI-ESP32 LOADED WITH ZIMODEM FIRMWARE @ 9600 BAUD.
  200 REM INSTRUCTIONS ON GOPHER://AGON.GUNSTAR.ONE:70   AGON/BBS
  210 PRINT " SERIAL BY RICHARD TURNNIDGE"
  220 :
  230 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
  240 :
  250 REM ---------------------------------------------------------
  260 REM This is the uart assembly code 
  270 REM ---------------------------------------------------------
  280 :
  290 REM allocate plenty of memory spaces for the three machine code commands, could be smaller
  300 :
  310 DIM openuart% 64
  320 DIM closeuart% 64
  330 DIM senduart% 64
  340 DIM readuart% 128
  350 :
  360 REM This routine is for opening the uart
  370 :
  380 FOR I%=0 TO 3 STEP 3
  390   P%=openuart%
  400   [
  410   OPT I%
  420   :
  430   LD IX, uartstruct               ; Address of the uart struct
  440   ld a, &15
  450   RST &08                         ; mos_uopen
  460   RET
  470   .uartstruct
  480   DEFB &80                        ; LONG (3 bytes) to store baud rate (9600)
  490   DEFB &25
  500   DEFB &00
  510   DEFB 8                          ; data bits
  520   DEFB 1                          ; stop bits
  530   DEFB 0                          ; parity bits
  540   DEFB 0                          ; flow control
  550   DEFB 0                          ; interrupt bits
  560   ]
  570 NEXT
  580 :
  590 REM This routine is to close the uart
  600 :
  610 FOR I%=0 TO 3 STEP 3
  620   P%=closeuart%
  630   [
  640   OPT I%
  650   :
  660   ld a, &16
  670   RST &08                         ; mos_uclose
  680   RET
  690   ]
  700 NEXT
  710 :
  720 REM This routine is to send uart data
  730 :
  740 FOR I%=0 TO 3 STEP 3
  750   P%=senduart%
  760   [
  770   OPT I%
  780   :
  790   ld c, 65                        ; char to send is stored here
  800   ld a, &18
  810   RST &08                         ; mos_uputc
  820   RET
  830   ]
  840 NEXT
  850 :
  860 :
  870 REM ---------------------------------------------------------
  880 REM This is the user Basic program
  890 REM ---------------------------------------------------------
  900 MODE 7 
  910 CLS
  920 PRINT CHR$(133)+"     GLASSTTY TERMINAL: VER "+VER$
  930 PRINT CHR$(134)+"          BY EIGHTBITSWIDE"
  940 PRINT CHR$(134)+"     SERIAL BY RICHARD TURNNIDGE" :PRINT
  950 PRINT CHR$(135);"        PRESS"+CHR$(131)+"TAB"+CHR$(135)+"TO CONNECT"
  960 PRINT : PRINT " USE"+CHR$(130)+"*page#"+CHR$(135)+"TO MOVE ABOUT THE SERVICE."
  970 PRINT " USE"+CHR$(130)+"*90#"+CHR$(135)+"TO REQUEST DISCONNECT."
  980 PRINT " USE"+CHR$(130)+"*09"+CHR$(135)+"TO REQUEST NEXT FRAME."
  990 PRINT " USE"+CHR$(130)+"*0#"+CHR$(135)+"TO SELECT MAIN FRAME."
 1000 PRINT : PRINT CHR$(134)+"NOTE:"+CHR$(130)+"ENTER"+CHR$(135)+"IS MAPPED TO"+CHR$(130)+"#"+CHR$(135)+"AT CONNECT."
 1010 PRINT : PRINT "Resetting Zimodem..."
 1020 A = senduart% +1 : REM this is second byte into the routine, store char to send here
 1030 CALL openuart%
 1040 :
 1050 FOR XX = 1 TO 3: TX$="+" :GOSUB 1340: FOR CC=1 TO 500: NEXT CC: NEXT XX
 1060 TX$=HU$: GOSUB 1340 : FOR XX= 1 TO 1000: NEXT XX
 1070 TX$=RS$: GOSUB 1340: FOR XX = 1 TO 1000: NEXT XX
 1080 TX$=RE$
 1090 REM this routine sends key presses out the uart
 1100 :
 1110 N = INKEY(0) : REM wait for a key press
 1120 IF N = -1 THEN N=0
 1130 IF N = 0 THEN GOTO 1200
 1140 IF ASC$(N) = 207 THEN GOSUB 1340 : N=0 : CO=1
 1150 IF CO=1 AND N=13 OR N=35 THEN N=95
 1160 ?A = N : REM poke the char we want to send into this memory byte
 1170 CALL senduart% : REM send the data byte
 1180 GOTO 1110
 1190 :
 1200 REM This section is to READ data from uart and print to the screen
 1210 :
 1220 A% = GET(&D5) : REM  flag for new data D5
 1230 A% = A% AND 1
 1240 IF A% = 0 THEN GOTO 1110
 1250 B% = GET(&D0)
 1260 IF B%=27 THEN TS=1 : GOTO 1220
 1270 IF TS=1 THEN B%=B%+64 : TS=0
 1280 IF B%=141 THEN B%=32
 1290 IF B%=>32 AND B%=<127 THEN B%=B%+128
 1300 PRINT CHR$(B%);
 1310 REM VDU27,B%
 1320 GOTO 1220
 1330 CALL closeuart%
 1340 REM TRANSMIT CONNECT
 1350 FOR W = 1 TO LEN(TX$)
 1360   N$=(MID$(TX$,W,1))
 1370   N=ASC(N$)
 1380   ?A=N
 1390   CALL senduart%
 1400   PRINT CHR$(N);
 1410 NEXT W
 1420 RETURN
