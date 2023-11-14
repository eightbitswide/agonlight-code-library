   10 REM SIMPLE SPRITE DEMO
   20 REM Using VDU Documentation from:
   30 REM http://agonconsole8.github.io/agon-docs/VDP.html
   40 :
   70 MB%=&40000
  110 DIM graphics 1024
  900 :
  910 REM Load the sprites in
  920 :
  930 PROCloadSprite("lander0.rgb",0,16,16)
  940 PROCloadSprite("lander1.rgb",1,16,16)
  950 MODE 8
  960 :
  980 REM Set up some sprites
  990 :
 1100 VDU 23,27,4,0 : REM Select sprite 
 1110 VDU 23,27,5   : REM Clear frames for current sprite
 1120 VDU 23,27,6,0 : REM Add bitmap 0 as frame 0 of sprite
 1130 VDU 23,27,6,1 : REM Add bitmap 1 as frame 1 of sprite
 1140 VDU 23,27,11  : REM Show the sprite
 1150 :
 1160 VDU 23,27,7,1 : REM Activate sprite 1
 1170 :
 1180 :
 1190 REM MOVE THE SPRITE * GAME LOOP
 1200 FOR X = 1 TO 200
 1220   VDU 23,27,13,X;X;  : REM MOVE CURRENT SPRITE TO POS X,Y
 1221   VDU 23,27,15       : REM UPDATE THE SPRITES IN THE GPU
 1230   FOR C = 1 TO 500 : NEXT C  : REM SMALL DELAY
 1240 NEXT X
 1260 STOP
 1270 :
 1280 REM Load a bitmap into VDP RAM
 1290 REM F$ - Filename of bitmap
 1300 DEF PROCloadSprite(F$,N%,W%,H%)
 1310 OSCLI("LOAD " + F$ + " " + STR$(MB%+graphics))
 1320 VDU 23,27,0,N%
 1330 VDU 23,27,1,W%;H%;
 1340 FOR I%=0 TO (W%*H%*3)-1 STEP 3
 1350   r% = ?(graphics+I%+0)
 1360   g% = ?(graphics+I%+1)
 1370   b% = ?(graphics+I%+2)
 1380   a% = r% OR g% OR b%
 1390   VDU r%, g%, b%, a%
 1400 NEXT
 1410 ENDPROC
