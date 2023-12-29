   10 REM MOD-WIFI-ESP8266 BASIC WEBSERVER BY EIGHTBITSWIDE
   20 REM SERIAL ROUTINES BY RICHARD TURNNIDGE 2023 - THANK YOU RICHARD!
   30 REM REQUIRES MOD-WIFI-ESP8266 TO BE SET TO 9600 BAUD
   40 REM USE TESTER.BIN (SNAIL PROJECT) TO SET BAUD RATE.
   50 REM AT+UART_CUR=9600,8,1,0,0
   60 :
   70 REM This version is for 16-bit basic but you could adapt
   80 REM Check if we are running in 24-bit BASIC
   90 :
  100 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
  110 E=0 : VISTOR=192 : HIT=0
  120 REM ---------------------------------------------------------
  130 REM This is the uart assembly code 
  140 REM ---------------------------------------------------------
  150 :
  160 REM allocate plenty of memory spaces for the three machine code commands, could be smaller
  170 :
  180 DIM openuart% 64
  190 DIM closeuart% 64
  200 DIM senduart% 64
  210 DIM readuart% 128
  220 :
  230 REM This routine is for opening the uart
  240 :
  250 FOR I%=0 TO 3 STEP 3
  260   P%=openuart%
  270   [
  280   OPT I%
  290   :
  300   LD IX, uartstruct               ; Address of the uart struct
  310   ld a, &15
  320   RST &08                         ; mos_uopen
  330   RET
  340   .uartstruct
  350   DEFB &80                        ; LONG (3 bytes) to store baud rate (9600)
  360   DEFB &25
  370   DEFB &00
  380   DEFB 8                          ; data bits
  390   DEFB 1                          ; stop bits
  400   DEFB 0                          ; parity bits
  410   DEFB 0                          ; flow control
  420   DEFB 0                          ; interrupt bits
  430   ]
  440 NEXT
  450 :
  460 REM This routine is to close the uart
  470 :
  480 FOR I%=0 TO 3 STEP 3
  490   P%=closeuart%
  500   [
  510   OPT I%
  520   :
  530   ld a, &16
  540   RST &08                         ; mos_uclose
  550   RET
  560   ]
  570 NEXT
  580 :
  590 REM This routine is to send uart data
  600 :
  610 FOR I%=0 TO 3 STEP 3
  620   P%=senduart%
  630   [
  640   OPT I%
  650   :
  660   ld c, 65                        ; char to send is stored here
  670   ld a, &18
  680   RST &08                         ; mos_uputc
  690   RET
  700   ]
  710 NEXT
  720 :
  730 :
  740 REM ---------------------------------------------------------
  750 REM This is the user Basic program
  760 REM ---------------------------------------------------------
  770 :
  780 CLS
  790 PRINT "WEBSERVER ONLINE:"
  800 PRINT "Hit ESC to exit"
  810 A = senduart% +1 : REM this is second byte into the routine, store char to send here
  820 CALL openuart%
  830 :
  840 REM CONFIGURE ESP8266 TO ACCESS REQUESTS ON PORT 80
  850 :
  860 PROC_SEND("AT+CIPMUX=1")
  870 FOR X = 1 TO 1000 : NEXT X
  880 PROC_SEND("AT+CIPSERVER=1,80")
  890 :
  900 REM this routine sends key presses out the uart
  910 :
  920 N = INKEY(0) : REM wait for a key press
  930 IF N = -1 THEN N=0
  940 IF N = 0 THEN GOTO 1010
  950 IF N = 27 THEN GOTO 1120 : REM ESC TO EXIT TERMINAL
  960 IF N = 13 THEN ?A=N : CALL senduart% : N=10
  970 ?A = N : REM poke the char we want to send into this memory byte
  980 CALL senduart% : REM send the data byte
  990 GOTO 920
 1000 :
 1010 REM This section is to READ data from uart and print to the screen
 1020 :
 1030 A% = GET(&D5) : REM  flag for new data D5
 1040 A% = A% AND 1
 1050 IF TIME > 50 AND E=43 THEN E=0 : GOSUB 1390 : REM WAIT A MOMENT, SEND PAGE
 1060 IF A% = 0 THEN GOTO 920
 1070 B% = GET(&D0)
 1080 PRINT CHR$(B%);
 1090 IF B%=43 THEN TIME=0: E=43 : REM + SIGN DETECTED, LOOKS LIKE A REQUEST.
 1100 GOTO 1010
 1110 :
 1120 CALL closeuart%
 1130 END
 1140 :
 1150 REM SEND STRING TO ESP8266 FOLLOWED BY 13,10
 1160 :
 1170 DEF PROC_SEND(A$)
 1180 FOR C= 1 TO LEN(A$)
 1190   B$=MID$(A$,C,1)
 1200   ?A=ASC(B$): CALL senduart%
 1210 NEXT C
 1220 ?A=13 : CALL senduart%
 1230 ?A=10 : CALL senduart%
 1240 ENDPROC
 1250 :
 1260 REM SEND LINE OF HTTP DATA
 1270 :
 1280 DEF PROC_SENDHTTP(AA$)
 1290 D=LEN(AA$)
 1300 D$=STR$(D)
 1310 PROC_SEND("AT+CIPSENDBUF=0,"+D$)
 1320 FOR X = 1 TO 1000 : NEXT X
 1330 PROC_SEND(AA$)
 1340 FOR X = 1 TO 1000 : NEXT X
 1350 ENDPROC
 1360 :
 1370 REM SEND WEBPAGE TO REQUESTING CLIENT
 1380 :
 1390 PROC_SENDHTTP("<!DOCTYPE HTML>")
 1400 PROC_SENDHTTP("<CENTER>")
 1410 IF HIT=2 THEN VISTOR=VISTOR+1 : HIT=0
 1420 HIT=HIT+1 : REM SKIP COUNTING REQUEST FOR FAVORITE ICON
 1430 PROC_SENDHTTP("<BR><BR>")
 1440 PROC_SENDHTTP("VISTOR #")
 1450 VISTOR$=STR$(VISTOR)
 1460 PROC_SENDHTTP(VISTOR$)
 1470 PROC_SENDHTTP("<BR>")
 1480 PROC_SENDHTTP("<BR>")
 1490 PROC_SENDHTTP("THIS PAGE WAS SENT FROM AN AGONLIGHT2 USING A MOD-WIFI-ESP8266.")
 1500 PROC_SENDHTTP("<BR>")
 1510 PROC_SENDHTTP("<BR>THE SERVER IS A SIMPLE PROGRAM WRITTEN IN BBC BASIC.<BR>")
 1520 PROC_SENDHTTP("<BR>")
 1530 PROC_SENDHTTP("THE VISTOR COUNTER IS A BASIC VARIABLE.<BR>")
 1540 FOR X = 1 TO 1000 : NEXT
 1550 PROC_SEND("AT+CIPCLOSE=0")
 1560 RETURN
