   10 REM SIMPLE SERIAL TERMINAL BY EIGHTBITSWIDE
   20 REM SERIAL ROUTINES BY RICHARD TURNNIDGE 2023 - THANK YOU RICHARD!
   21 REM This version is for 16-bit basic but you could adapt
   22 REM Check if we are running in 24-bit BASIC
   24 :
   25 IF HIMEM > &FFFF PRINT "This code will only run on BBC BASIC for Z80": STOP
   30 :
   31 REM ---------------------------------------------------------
   32 REM This is the uart assembly code 
   33 REM ---------------------------------------------------------
   36 :
   38 REM allocate plenty of memory spaces for the three machine code commands, could be smaller
   39 :
   40 DIM openuart% 64
   50 DIM closeuart% 64
   60 DIM senduart% 64
   70 DIM readuart% 128
   80 :
   90 REM This routine is for opening the uart
   91 :
  100 FOR I%=0 TO 3 STEP 3
  110   P%=openuart%
  120   [
  130   OPT I%
  140   :
  150   LD IX, uartstruct               ; Address of the uart struct
  160   ld a, &15
  170   RST &08                         ; mos_uopen
  180   RET
  190   .uartstruct
  200   DEFB &80                        ; LONG (3 bytes) to store baud rate (9600)
  210   DEFB &25
  220   DEFB &00
  230   DEFB 8                          ; data bits
  240   DEFB 1                          ; stop bits
  250   DEFB 0                          ; parity bits
  260   DEFB 0                          ; flow control
  270   DEFB 0                          ; interrupt bits
  280   ]
  290 NEXT
 1000 :
 1010 REM This routine is to close the uart
 1011 :
 1080 FOR I%=0 TO 3 STEP 3
 1090   P%=closeuart%
 1100   [
 1110   OPT I%
 1120   :
 1210   ld a, &16
 1220   RST &08                         ; mos_uclose
 1330   RET
 1370   ]
 1480 NEXT
 1500 :
 2000 REM This routine is to send uart data
 2001 :
 2080 FOR I%=0 TO 3 STEP 3
 2090   P%=senduart%
 2100   [
 2110   OPT I%
 2120   :
 2210   ld c, 65                        ; char to send is stored here
 2215   ld a, &18
 2220   RST &08                         ; mos_uputc
 2330   RET
 2370   ]
 2480 NEXT
 2499 :
 2999 :
 3000 REM ---------------------------------------------------------
 3001 REM This is the user Basic program
 3002 REM ---------------------------------------------------------
 3003 :
 3005 CLS
 3010 PRINT "SIMPLE TERMINAL PROGRAM:"
 3020 PRINT "Hit ESC to exit"
 3040 A = senduart% +1 : REM this is second byte into the routine, store char to send here
 3050 CALL openuart%
 3900 :
 3910 REM this routine sends key presses out the uart
 3920 :
 4000 N = INKEY(0) : REM wait for a key press
 4005 IF N = -1 THEN N=0
 4010 IF N = 0 THEN GOTO 5000
 4020 IF N = 27 THEN GOTO 6000 : REM ESC TO EXIT TERMINAL
 4030 ?A = N : REM poke the char we want to send into this memory byte
 4040 CALL senduart% : REM send the data byte
 4110 GOTO 4000
 4990 :
 5000 REM This section is to READ data from uart and print to the screen
 5001 :
 5005 A% = GET(&D5) : REM  flag for new data D5
 5010 A% = A% AND 1
 5015 IF A% = 0 THEN GOTO 4000
 5020 B% = GET(&D0)
 5025 PRINT CHR$(B%);
 5030 GOTO 5000
 5999 :
 6000 CALL closeuart%
