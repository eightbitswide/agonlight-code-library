   10 REM SET AGON CLOCK FROM TIME ON ZIMODEM ON MOD-WIFI-ESP8266
   20 REM SERIAL ROUTINES BY RICHARD TURNNIDGE 2023 - THANK YOU RICHARD!
   30 REM This version is for 16-bit basic but you could adapt
   40 REM Check if we are running in 24-bit BASIC
   50 :
   60 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
   70 :
   80 REM ---------------------------------------------------------
   90 REM This is the uart assembly code 
  100 REM ---------------------------------------------------------
  110 :
  120 REM allocate plenty of memory spaces for the three machine code commands, could be smaller
  130 :
  140 DIM openuart% 64
  150 DIM closeuart% 64
  160 DIM senduart% 64
  170 DIM readuart% 128
  180 :
  190 REM This routine is for opening the uart
  200 :
  210 FOR I%=0 TO 3 STEP 3
  220   P%=openuart%
  230   [
  240   OPT 0
  250   :
  260   LD IX, uartstruct               ; Address of the uart struct
  270   ld a, &15
  280   RST &08                         ; mos_uopen
  290   RET
  300   .uartstruct
  310   DEFB &80                        ; LONG (3 bytes) to store baud rate (9600)
  320   DEFB &25
  330   DEFB &00
  340   DEFB 8                          ; data bits
  350   DEFB 1                          ; stop bits
  360   DEFB 0                          ; parity bits
  370   DEFB 0                          ; flow control
  380   DEFB 0                          ; interrupt bits
  390   ]
  400 NEXT
  410 :
  420 REM This routine is to close the uart
  430 :
  440 FOR I%=0 TO 3 STEP 3
  450   P%=closeuart%
  460   [
  470   OPT 0
  480   :
  490   ld a, &16
  500   RST &08                         ; mos_uclose
  510   RET
  520   ]
  530 NEXT
  540 :
  550 REM This routine is to send uart data
  560 :
  570 FOR I%=0 TO 3 STEP 3
  580   P%=senduart%
  590   [
  600   OPT 0
  610   :
  620   ld c, 65                        ; char to send is stored here
  630   ld a, &18
  640   RST &08                         ; mos_uputc
  650   RET
  660   ]
  670 NEXT
  680 :
  690 :
  700 REM ---------------------------------------------------------
  710 REM This is the user Basic program
  720 REM ---------------------------------------------------------
  730 :
  740 A = senduart% +1 : REM this is second byte into the routine, store char to send here
  750 CALL openuart%
  760 GOTO 990
  770 :
  780 INP$=""
  790 REM *** READ DATA FROM SERIAL ***
  800 A% = GET(&D5) : REM  flag for new data D5
  810 A% = A% AND 1
  820 IF A% = 0 THEN GOTO 790
  830 B% = GET(&D0)
  840 IF B% = 13 THEN RETURN
  850 IF B% > 0 THEN INP$=INP$+CHR$(B%)
  860 REM PRINT CHR$(B%);
  870 GOTO 800
  880 :
  890 CALL closeuart%
  900 REM *** SEND DATA TO SERIAL ***
  910 FOR X = 1 TO LEN(OUT$)
  920   SC$=MID$(OUT$,X,1)
  930   REM PRINT SC$;
  940   N=ASC(SC$)
  950   ?A=N
  960   CALL senduart%
  970 NEXT X
  980 RETURN
  990 OUT$="AT"+CHR$(13):GOSUB 910
 1000 GOSUB 780 : REM GET ECHOED TEXT
 1010 GOSUB 780 : REM GET OK
 1020 OUT$="AT&T"+CHR$(34)+"EST"+CHR$(34)+CHR$(13):GOSUB 910
 1030 GOSUB 780 : REM GET ECHOED TEXT
 1040 GOSUB 780 : REM GET OK
 1050 OUT$="ATI7"+CHR$(13) : GOSUB 910
 1060 GOSUB 780 : REM GET ECHOED TEXT
 1070 GOSUB 780 : REM GET TIME AND DATE
 1080 TI$=TI$+INP$
 1090 REM
 1100 REM EXTRACT MONTH
 1110 X=0
 1120 X=X+1
 1130 MO$=MID$(TI$,X,1)
 1140 IF MO$="/" THEN GOTO 1170
 1150 MONTH$=MONTH$+MO$
 1160 GOTO 1120
 1170 X=X+1 : REM EXTRACT DAY
 1180 DA$=MID$(TI$,X,1)
 1190 IF DA$="/" THEN GOTO 1220
 1200 DAY$=DAY$+DA$
 1210 GOTO 1170
 1220 REM EXTRACT YEAR
 1230 FOR C = 1 TO 4
 1240   X=X+1
 1250   YR$=MID$(TI$,X,1)
 1260   YEAR$=YEAR$+YR$
 1270 NEXT C
 1280 X=X+1
 1290 REM EXTRACT HOUR
 1300 X=X+1
 1310 HR$=MID$(TI$,X,1)
 1320 IF HR$=":" THEN GOTO 1350
 1330 HOUR$=HOUR$+HR$
 1340 GOTO 1300
 1350 REM EXTRACT MINUTES
 1360 X=X+1
 1370 MN$=MID$(TI$,X,1)
 1380 IF MN$=":" THEN GOTO 1410
 1390 MINUTE$=MINUTE$+MN$
 1400 GOTO 1360
 1410 REM EXTRACT SECONDS
 1420 X=X+1
 1430 SE$=MID$(TI$,X,1)
 1440 IF SE$="a" OR SE$="p" THEN GOTO 1470
 1450 SECONDS$=SECONDS$+SE$
 1460 GOTO 1420
 1470 REM SET THE CLOCK
 1480 CLS
 1490 c$=c$+"TIME "+YEAR$+" "+MONTH$+" "+DAY$+" "+HOUR$+" "+MINUTE$+" "+SECONDS$
 1500 OSCLI c$
 1510 *BYE
