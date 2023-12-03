  100 REM 1602 LCD MODULE CONTROL
  110 REM
  120 REM   G      P G P  P P P P P P P P
  130 REM   n 5    D n D  C C C C C C C C
  140 REM   d +    4 d 5  0 1 2 3 4 5 6 7
  150 REM +-------------------------------+
  160 REM : V V V  R R E  1 2 3 4 5 6 7 8 :
  170 REM : s d o  S /    D D D D D D D D :
  180 REM : s d      W                    :
  190 REM :             1602 LCD MODULE   :
  200 REM +-------------------------------+
  210 REM NOTE: CONNECT Vo TO 10K VARIABLE RESISTOR TO GND
  220 REM
  230 REM CONVERTED FROM GPIO EXAMPLE
  240 REM BY EIGHTBITSWIDE
  250 :
  260 REM GPIO Setup
  270 :
  280 PC_DR% = &9E    : REM 158
  290 PC_DDR% = &9F   : REM 159
  300 PC_ALT1% = &A0  : REM 160
  310 PC_ALT2% = &A1  : REM 161
  320 :
  330 PD_DR% = &A2    : REM 162
  340 PD_DDR% = &A3   : REM 163
  350 PD_ALT1% = &A4  : REM 164
  360 PD_ALT2% = &A5  : REM 165
  370 : 
  380 REM Set all GPIO on Port C to output  
  390 :
  400 PROCres_gpio(PC_DDR%, 255)
  410 PROCres_gpio(PC_ALT1%, 255)
  420 PROCres_gpio(PC_ALT2%, 255)
  430 :
  440 REM Set last 4 bits of Port D to output
  450 :
  460 PROCres_gpio(PD_DDR%, 240)
  470 PROCres_gpio(PD_ALT1%, 240)
  480 PROCres_gpio(PD_ALT2%, 240)
  490 :
  520 PUT 158,0 : REM SET ALL DATA LINES TO ZERO
  530 PUT 162,0 : REM SEND ALL CONTROL LINES TO ZERO
  540 :
  550 PUT 158,15 : PUT 162,16: PUT 162,0 : REM SET FLASHING CURSOR
  560 PUT 158,1  : PUT 162,16: PUT 162,0 : REM CLEAR LCD SCREEN
  570 TIME=0: REPEAT UNTIL TIME > 10 : REM WAIT A MOMENT AFTER COMMANDS
  580 PUT 158,72 : PUT 162,50: PUT 162,0 : REM SEND H
  590 PUT 158,69 : PUT 162,50: PUT 162,0 : REM SEND E
  600 PUT 158,76 : PUT 162,50: PUT 162,0 : REM SEND L
  610 PUT 158,76 : PUT 162,50: PUT 162,0 : REM SEND L
  620 PUT 158,79 : PUT 162,50: PUT 162,0 : REM SEND O
  630 :
  640 STOP
  650 :
  660 REM Reset bits V% in GPIO port R%
  670 :
  680 DEF PROCres_gpio(R%, V%)
  690 LOCAL A%
  700 A% = GET(R%)
  710 A% = A% AND (V% EOR &FF)
  720 PUT R%, A%
  730 ENDPROC
