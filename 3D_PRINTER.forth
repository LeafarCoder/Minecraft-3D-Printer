
	// Variables define

	VARIABLE $XA+
	VARIABLE $XA-
	VARIABLE $YA+
	VARIABLE $YA-
	VARIABLE $ZA+
	VARIABLE $ZA-
	VARIABLE $GX
	VARIABLE $GY
	VARIABLE $GZ
	VARIABLE $ATX
	VARIABLE $ATY
	VARIABLE $ATZ
	VARIABLE $ST
	VARIABLE $KEYH
	VARIABLE $COLOR
	VARIABLE $A
	VARIABLE $B
	VARIABLE $C
	VARIABLE $A1
	VARIABLE $B1
	VARIABLE $C1
	VARIABLE $X1
	VARIABLE $X2
	VARIABLE $Y1
	VARIABLE $Y2
	VARIABLE $Z1
	VARIABLE $Z2
	VARIABLE $DR_L
	VARIABLE $BV1
	VARIABLE $BV2
	VARIABLE $TBN
	VARIABLE $BTG
	VARIABLE $3D_OBJ 15750 ALLOT DROP

	: INITIALIZATION
		1 $XA+ !
		2 $XA- !
		4 $YA+ !
		8 $YA- !
		16 $ZA+ !
		32 $ZA- !
		1 $GX !
		1 $GY !
		1 $GZ !
		1 $ATX !
		1 $ATY !
		1 $ATZ !
		8 $ST !
		0 $KEYH !
		0 $COLOR !
		0 $A !
		0 $B !
		0 $C !
		0 $A1 !
		0 $B1 !
		0 $C1 !
		0 $X1 !
		0 $X2 !
		0 $Y1 !
		0 $Y2 !
		0 $Z1 !
		0 $Z2 !
		1 $DR_L !
		0 $BV1 !
		0 $BV2 !
		0 $TBN !
		0 $BTG !
	;

	// Single move procedures

	: SM
		IOX!
		$ST @ DUP TICKS
		0 IOX!
		TICKS
	;


	: X+
		$XA+ @ SM
	;

	: X-
		$XA- @ SM
	;

	: Y+
		$YA+ @ SM
	;

	: Y-
		$YA- @ SM
	;

	: Z+
		$ZA+ @ SM
	;

	: Z-
		$ZA- @ SM
	;


	: GOTO
		3 IOXADDR !
		$GY @ – DUP 0<> IF DUP 0 < IF NEGATE 0 DO Y- 1 $GY -! LOOP 
		ELSE 0 DO Y+ 1 $GYntg +! LOOP THEN ELSE DROP THEN
		$GX @ – DUP 0<> IF DUP 0 < IF NEGATE 0 DO X- 1 $GX -! LOOP 
		ELSE 0 DO X+ 1 $GX +! LOOP THEN ELSE DROP THEN
	;
	: OBJ_READ

		DUP 2 MOD $3D_OBJ + C@ SWAP 2 / 0= IF0
		240 AND 4 U>> ELSE	//240(DEC) = 11110000(BIN)
		15 AND THEN 		//15(DEC) = 00001111(BIN)
	;	

	: OBJ_WRITE
		DUP 2 MOD $3D_OBJ + DUP C@ ROT 2 / 0= IF
		15 AND ROT 4 << OR SWAP C! ELSE		//15(DEC) = 00001111(BIN)
		240 AND ROT OR SWAP C! THEN			//240(DEC) = 11110000(BIN)
	;

	: OBJ_RST
		$3D_OBJ 15750 0 FILL 
	;

	: IX_C
		DUP DUP
		30 / 1+ SWAP			// X
		900 / 30 MOD 1+ ROT		// Y
		900 MOD 1+ 				// Z
	;

	: IX_CXY
		DUP
		30 / 1+ SWAP			// X
		900 / 30 MOD 1+			// Y
	;

	C_IX
		1- 900 * -ROT
		1- 30 * SWAP
		1- + +
	;

	: GUI_RECT
		$Y2 !
		$X2 !
		$Y1 !
		$X1 !

		$X2 @ 1+ $X1 @ DO
		I $Y1 @ AT-XY 0 EMIT
		I $Y2 @ AT-XY 0 EMIT
		LOOP

		$Y2 @ 1+ $Y1 @ DO
		$X1 @ I AT-XY 124 EMIT
		$X2 @ I AT-XY 124 EMIT
		LOOP

		$X1 @ $Y1 @ AT-XY 16 EMIT
		$X2 @ $Y1 @ AT-XY 14 EMIT
		$X1 @ $Y2 @ AT-XY 13 EMIT
		$X2 @ $Y2 @ AT-XY 29 EMIT
	;


	: GUI_ANS
		2DUP 2DUP
		AT-XY 5 0 DO 15 EMIT LOOP
		1+ AT-XY 5 EMIT ." >  " 10 EMIT
		2 + AT-XY 5 0 DO 23 EMIT LOOP
	;


	: GUI_HL
		-ROT OVER 3 PICK 2OVER
		DO DUP I SWAP AT-XY 0 EMIT LOOP
		AT-XY 11 EMIT
		AT-XY 19 EMIT
	;


	// PRINTING PROCEDURES

	: PRINT_SCREEN_UPDATE
		10 23 AT-XY $BTG @ . ." of " $TBN @ .
		3 26 AT-XY 74 $BTG @ * $TBN @ MOD DUP 0= IF 1+ THEN
		0 DO 9 EMIT LOOP
	;

	: PAINT_BL
		4 IOXADDR !
		1 SWAP 1- << IOX!
		4 TICKS
		0 IOX!
	;

	: PRINT_B_N
		30 20 AT-XY ." Calculating number of blocks..."
		0 $TBN !
		31500 0 DO
		I OBJ_READ 0<> IF  1 $TBN +! THEN
		LOOP
		20 TICKS
		30 20 AT-XY ."                                                            "
	;

	: PRINT
		PRINT_B_N
		2 23 AT-XY ." Blocks:"
		2 25 77 27 GUI_RECT
		0 $BTG !
		PRINT_SCREEN_UPDATE
		1 $A !
		36 1 DO
		31 1 DO
		31 1 DO
		J 2 / 0= IF
		31 I - J $A @ C_IX OBJ_READ DUP 0<> IF 31 I - J $A @ GOTO PAINT_BL
		1 $BTG +! ELSE DROP THEN
		ELSE
		I J $A @ C_IX OBJ_READ 0<> IF I J $A @ GOTO PAINT_BL
		1 $BTG +! ELSE DROP THEN
		THEN
		PRINT_SCREEN_UPDATE
		LOOP
		LOOP
		1 $A +!
		LOOP
	;

	// OTHER FUNCTIONAL SUBROUTINES

	: KEYH_RST
		-1 $KEYH !
	;

	: LOAD_AREA
		1- 900 * $A !
		30 0 DO
			$A @ I 1- + $C !
			31 1 DO
				$C @ J 30 * + OBJ_READ $B !
				$B @ 0<> IF I 30 J - AT-XY $B @ 48 + EMIT THEN
			LOOP
		LOOP
	;

	: ATXY_CHK	
		$ATX @ 1 < IF 1 $ATX ! THEN
		$ATX @ 30 > IF 30 $ATX ! THEN
		$ATY @ 1 < IF 1 $ATY ! THEN
		$ATY @ 30 > IF 30 $ATY ! THEN
	;

	: ATXY_WRT
		$ATX @ 31 $ATY @ - AT-XY
	;

	: CLR_T_INFO
		32 33 AT-XY ."                                              "
		45 36 DO
		32 I AT-XY ."                                                "
		LOOP
	;

	: TOOL_WRT
		2DUP DUP 1 >= SWAP 30 <= AND SWAP DUP 1 >= SWAP 30 <= AND AND IF
			2DUP $DR_L @ C_IX $COLOR @ SWAP OBJ_WRITE
			$BV1 @ IF
				31 SWAP - AT-XY $COLOR @ 48 + EMIT ELSE 2DROP
			THEN
		ELSE
			2DROP
		THEN
	;

	: EDIT_IN
		DUP 3 ACCEPT
		ATOI SWAP !
	;

	: CIRCLE_SUBRT
		$A1 !
		1 $A1 @ - $B1 !	
		0 $C1 !

		$BV2 @ IF
			BEGIN
				$A1 @ NEGATE $X1 @ + $A1 @ $X1 @ +
				$C1 @ $Y1 @ + 1+ $C1 @ NEGATE $Y1 @ + DO
					2DUP
					I TOOL_WRT
					I TOOL_WRT
				LOOP
				2DROP
				
				$C1 @ NEGATE $X1 @ + $C1 @ $X1 @ +
				$A1 @ $Y1 @ + 1+ $A1 @ NEGATE $Y1 @ + DO
					2DUP
					I TOOL_WRT
					I TOOL_WRT
				LOOP
				2DROP
				
				1 $C1 +!
				
				$B1 @ 0 <= IF 
					2 $C1 @ * 1+ $B1 +! 
				ELSE 
					1 $A1 -!
					$C1 @ $A1 @ - 1+ 2 * $B1 +!
				THEN
			$A1 @ $C1 @ < UNTIL
		ELSE
			BEGIN
				$A1 @ $X1 @ + $C1 @ $Y1 @ +
				TOOL_WRT
				$C1 @ $X1 @ + $A1 @ $Y1 @ +
				TOOL_WRT
				$A1 @ NEGATE $X1 @ + $C1 @ $Y1 @ +
				TOOL_WRT
				$C1 @ NEGATE $X1 @ + $A1 @ $Y1 @ +
				TOOL_WRT
				$A1 @ NEGATE $X1 @ + $C1 @ NEGATE $Y1 @ +
				TOOL_WRT
				$C1 @ NEGATE $X1 @ + $A1 @ NEGATE $Y1 @ +
				TOOL_WRT
				$A1 @ $X1 @ + $C1 @ NEGATE $Y1 @ +
				TOOL_WRT
				$C1 @ $X1 @ + $A1 @ NEGATE $Y1 @ +
				TOOL_WRT
				
				1 $C1 +!
				
				$B1 @ 0 <= IF 
					2 $C1 @ * 1+ $B1 +! 
				ELSE 
					1 $A1 -!
					$C1 @ $A1 @ - 1+ 2 * $B1 +!
				THEN
			$A1 @ $C1 @ < UNTIL
		THEN
	;


	// 3D OBJ EDIT TOOLS

	: LAYER_JUMP
		50 33 AT-XY ." Jump to Layer"
		35 37 AT-XY ." This tool allows you to directly jump to a"
		33 38 AT-XY ." certain layer."
		33 41 AT-XY ." Insert layer: "
		BEGIN
		47 41 2DUP AT-XY
		."                     "
		47 41 AT-XY
		$A EDIT_IN
		$A @ 1 >= $A @ 35 <= AND UNTIL
		CLR_T_INFO
		$A @ DUP $ATZ !
		7 32 AT-XY ."     " 8 32 AT-XY DUP .
		LOAD_AREA
	;



	: OBJ_RESET
		50 33 AT-XY ." Reset Object"
		35 37 AT-XY ." Are you sure you want to reset the object?"
		33 41 AT-XY ." Answer (Y/N):"
		BEGIN		
		47 41 2DUP AT-XY
		."                     "
		AT-XY
		KEY $KEYH !
		$KEYH @ 78 = $KEYH @ 89 = OR UNTIL
		$KEYH @ 89 = IF OBJ_RST $ATZ @ LOAD_AREA THEN
		CLR_T_INFO
	;


	: CSET_IN
		50 33 AT-XY ." Draw Circle"
		35 37 AT-XY ." This tool allows you to draw a circle with"
		33 38 AT-XY ." a certain radius and center point."
		33 41 AT-XY ." Insert radius:"
		BEGIN
		48 41 2DUP AT-XY ."                     "
		AT-XY
		$A EDIT_IN
		$A @ 1 >= $A @ 50 <= AND UNTIL
		57 41 AT-XY ." Insert coord: X ="
		71 43 AT-XY ." Y ="
		BEGIN
		75 41 2DUP AT-XY
		."     "
		AT-XY
		$X1 EDIT_IN
		$X1 @ 1 >= $X1 @ 30 <= AND UNTIL
		BEGIN
		75 43 2DUP AT-XY
		."     "
		AT-XY
		$Y1 EDIT_IN
		$Y1 @ 1 >= $Y1 @ 30 <= AND UNTIL
		33 43 AT-XY ." Fill? (Y/N):"
		BEGIN							
		46 43 2DUP AT-XY
		."     "
		AT-XY
		KEY $KEYH !
		$KEYH @ 78 = $KEYH @ 89 = OR UNTIL
		$KEYH @ 89 = IF -1 $BV2 ! ELSE 0 $BV2 ! THEN
	;

	: CSET 
		CSET_IN
		-1 $BV1 !
		$ATZ @ $DR_L !
		$A @ CIRCLE_SUBRT
		CLR_T_INFO
	;

	: RSET_IN
		48 33 AT-XY ." Draw Rectangle"
		35 37 AT-XY ." This tool allows you to draw a rectangle"
		33 38 AT-XY ." with two opposite corner points."
		33 39 AT-XY ." Coord (1) is the lower left corner!"
		33 41 AT-XY ." Coord (1): X1 ="
		44 42 AT-XY ." Y1 ="
		BEGIN
		49 41 2DUP AT-XY
		."     " AT-XY
		$X1 EDIT_IN
		$X1 @ 1 >= $X1 @ 30 <= AND UNTIL
		BEGIN
		49 42 2DUP AT-XY
		."     "
		AT-XY
		$Y1 EDIT_IN
		$Y1 @ 1 >= $Y1 @ 30 <= AND UNTIL
		58 41 AT-XY ." Coord (2): X2 ="
		69 42 AT-XY ." Y2 ="
		BEGIN
		74 41 2DUP AT-XY
		."     " AT-XY
		$X2 EDIT_IN
		$X2 @ 1 >= $X2 @ 30 <= AND $X2 @ $X1 @ > AND UNTIL
		BEGIN
		74 42 2DUP AT-XY
		."     "
		AT-XY
		$Y2 EDIT_IN
		$Y2 @ 1 >= $Y2 @ 30 <= AND $Y2 @ $Y1 @ > AND UNTIL
		33 44 AT-XY ." Fill? (Y/N):"
		BEGIN							
		46 44 2DUP AT-XY
		."     "
		AT-XY
		KEY $KEYH !
		$KEYH @ 78 = $KEYH @ 89 = OR UNTIL
		$KEYH @ 89 = IF -1 $BV2 ! ELSE 0 $BV2 ! THEN
	;

	: RSET
		RSET_IN
		-1 $BV1 !
		$ATZ @ $DR_L !
		$BV2 @ IF
		$X2 @ 1+ $X1 @ DO
			$Y2 @ 1+ $Y1 @ DO
				J I TOOL_WRT
			LOOP
		LOOP
		ELSE
		$X2 @ 1+ $X1 @ DO
			I $Y1 @ TOOL_WRT
			I $Y2 @ TOOL_WRT
		LOOP
		$Y2 @ 1+ $Y1 @ DO
			$X1 @ I TOOL_WRT
			$X2 @ I TOOL_WRT
		LOOP
		THEN
		CLR_T_INFO
	;

	: SSET_IN
		50 33 AT-XY ." Draw Sphere"
		35 37 AT-XY ." This tool allows you to draw a sphere with"
		33 38 AT-XY ." a certain radius and center point."
		33 41 AT-XY ." Insert radius:"
		BEGIN
		48 41 2DUP AT-XY ."                     "
		AT-XY
		$A EDIT_IN
		$A @ 1 >= $A @ 50 <= AND UNTIL
		57 41 AT-XY ." Insert coord: X ="
		71 42 AT-XY ." Y ="
		71 43 AT-XY ." Z ="
		BEGIN
		75 41 2DUP AT-XY
		."     " AT-XY
		$X1 EDIT_IN
		$X1 @ 1 >= $X1 @ 30 <= AND UNTIL
		BEGIN
		75 42 2DUP AT-XY
		."     "
		AT-XY
		$Y1 EDIT_IN
		$Y1 @ 1 >= $Y1 @ 30 <= AND UNTIL
		BEGIN
		75 43 2DUP AT-XY
		."     "
		AT-XY
		$Z1 EDIT_IN
		$Z1 @ 1 >= $Z1 @ 35 <= AND UNTIL
	;

	: SSET_D_CHK
		DUP $DR_L ! $ATZ @ = IF -1 $BV1 ! ELSE 0 $BV1 ! THEN
		CIRCLE_SUBRT
	;

	: SSET
		SSET_IN
		1 $A @ - $B !
		0 $C !
		BEGIN
		$A @ $C @ $Z1 @ +
		SSET_D_CHK
		$C @ $A @ $Z1 @ +
		SSET_D_CHK 
		$A @ $C @ NEGATE $Z1 @ +
		SSET_D_CHK
		$C @ $A @ NEGATE $Z1 @ +
		SSET_D_CHK 
		1 $C +!
		$B @ 0 < IF 
		2 $C @ * 1+ $B +! 
		ELSE 
		1 $A -! $C @ $A @ - 1+ 2 * $B +! THEN
		$A @ $C @ < UNTIL
		CLR_T_INFO
	;


	: PSET_IN
		47 33 AT-XY ." Draw Parallelepiped"
		35 37 AT-XY ." This tool allows you to draw a parallelepiped"
		33 38 AT-XY ." with two opposite corner points."
		33 39 AT-XY ." Coord (1) is the closest to origin!"
		33 41 AT-XY ." Coord (1): X1 ="
		44 42 AT-XY ." Y1 ="
		44 43 AT-XY ." Z1 ="
		BEGIN
		49 41 2DUP AT-XY
		."     " AT-XY
		$X1 EDIT_IN
		$X1 @ 1 >= $X1 @ 30 <= AND UNTIL
		BEGIN
		49 42 2DUP AT-XY
		."     "
		AT-XY
		$Y1 EDIT_IN
		$Y1 @ 1 >= $Y1 @ 30 <= AND UNTIL
		BEGIN
		49 43 2DUP AT-XY
		."     "
		AT-XY
		$Z1 EDIT_IN
		$Z1 @ 1 >= $Z1 @ 30 <= AND UNTIL
		60 41 AT-XY ." Coord (2): X2 ="
		71 42 AT-XY ." Y2 ="
		71 43 AT-XY ." Z2 ="
		BEGIN
		76 41 2DUP AT-XY
		."     " AT-XY
		$X2 EDIT_IN
		$X2 @ 1 >= $X2 @ 30 <= AND $X2 @ $X1 @ > AND UNTIL
		BEGIN
		76 42 2DUP AT-XY
		."     "
		AT-XY
		$Y2 EDIT_IN
		$Y2 @ 1 >= $Y2 @ 30 <= AND $Y2 @ $Y1 @ > AND UNTIL
		BEGIN
		76 43 2DUP AT-XY
		."     "
		AT-XY
		$Z2 EDIT_IN
		$Z2 @ 1 >= $Z2 @ 35 <= AND $Z2 @ $Z1 @ > AND UNTIL
	;


	: EDIT_EXTR
		35 37 AT-XY ." This tool allows you to extrude the current"
		33 38 AT-XY ." layer into another one. Insert one at the time."
		33 39 AT-XY ." Insert F to finish."
		33 39 AT-XY ." Extrude to layer:"
		( BEGIN)
		49 41 2DUP AT-XY
		."     " AT-XY
		$A 3 ACCEPT DROP
		" F" $A STRCMP 1 = WHILE
		$A ATOI $A !
		$A @ DUP DUP 1 >= SWAP 30 <= AND SWAP $ATZ @ <> AND IF
			899 0 DO
				$ATZ @ 1- 900 * I + OBJ_READ DUP 0<> IF
				$A @ 1- 900 * I + OBJ_WRITE ELSE DROP THEN
			LOOP
		THEN
		REPEAT
		CLR_T_INFO
	;

	// GUI PROCEDURES

	: EDIT_STRUCT
		0 0 79 48 GUI_RECT
		45 0 79 GUI_HL
		31 0 79 GUI_HL
		45 0 DO
		31 I AT-XY 124 EMIT
		LOOP
		31 0 AT-XY 18 EMIT
		31 45 AT-XY 17 EMIT
		31 31 AT-XY 18 EMIT
		4 31 79 GUI_HL
		17 15 DO
		0 I AT-XY 11 EMIT 31 I AT-XY 19 EMIT 
		I 0 AT-XY 18 EMIT I 31 AT-XY 17 EMIT
		LOOP
		33 0 31 GUI_HL
		35 31 79 GUI_HL
		11 32 AT-XY 124 EMIT
		11 31 AT-XY 18 EMIT
		11 33 AT-XY 17 EMIT
	;

	: EDIT_COL_INFO
		1 32 AT-XY ." Layer:" 7 32 AT-XY ."     " 8 32 AT-XY $ATZ @ .
		13 32 AT-XY ." Coord:"
		20 32 AT-XY ."           " 20 32 AT-XY ." (" $ATX @ . ." ," $ATY @ . ." )"
		2 34 AT-XY ." COLOR KEYS    MOVEMENT KEYS"
		2 36 AT-XY ." 1: White      W: Up"
		2 37 AT-XY ." 2: Orange     S: Down"
		2 38 AT-XY ." 3: Purple     A: Left"
		2 39 AT-XY ." 4: Blue       D: Right"
		2 40 AT-XY ." 5: Yellow"
		2 41 AT-XY ." 6: Green"
		2 42 AT-XY ." 7: Red"
		2 43 AT-XY ." 8: Gray"
		2 44 AT-XY ." 9: Black"
	;

	: EDIT_TOOLS_INFO	
		50 2 AT-XY ." EDIT TOOLS"
		35 6 AT-XY ." +: Next Layer"
		35 8 AT-XY ." -: Previous Layer"
		35 10 AT-XY ." Z: Jump to Layer"
		35 12 AT-XY ." R: Reset Object"
		35 14 AT-XY ." C: Draw Circle"
		35 16 AT-XY ." V: Draw Sphere"
		35 18 AT-XY ." T: Draw Rectangle"
		35 20 AT-XY ." P: Draw Parallelepiped"
		35 22 AT-XY ." E: Extrude Layer"
		35 24 AT-XY ." Backspace: Clear Pixel"
		35 26 AT-XY ." Space: Paint Pixel"
		35 28 AT-XY ." L: Leave Edit Area"
	;

	: EDIT_KEY_CTRL
		BEGIN
		ATXY_CHK
		ATXY_WRT	
		KEY $KEYH !

		$KEYH @ 49 >= $KEYH @ 57 <= AND IF $KEYH @ 48 - $COLOR ! KEYH_RST THEN

		$KEYH @ 43 = $ATZ @ 35 < AND IF 1 $ATZ +! 7 32 AT-XY ."     " 8 32 AT-XY $ATZ @ DUP . $ATZ @ LOAD_AREA KEYH_RST THEN
		$KEYH @ 45 = $ATZ @ 1 >  AND IF 1 $ATZ -! 7 32 AT-XY ."     " 8 32 AT-XY $ATZ @ DUP . $ATZ @ LOAD_AREA KEYH_RST THEN
		$KEYH @ 90 = IF LAYER_JUMP KEYH_RST THEN

		$KEYH @ 65 = $KEYH @ 83 = $KEYH @ 68 = $KEYH @ 87 = OR OR OR IF
		$KEYH @ 65 = IF 1 $ATX -! KEYH_RST THEN
		$KEYH @ 83 = IF 1 $ATY -! KEYH_RST THEN
		$KEYH @ 68 = IF 1 $ATX +! KEYH_RST THEN
		$KEYH @ 87 = IF 1 $ATY +! KEYH_RST THEN
		ATXY_CHK
		20 32 AT-XY ."           " 20 32 AT-XY ." (" $ATX @ . ." ," $ATY @ . ." )"
		THEN

		$KEYH @ 67 = IF CSET KEYH_RST THEN
		$KEYH @ 86 = IF SSET KEYH_RST THEN
		$KEYH @ 84 = IF RSET KEYH_RST THEN
		( $KEYH @ 80 = IF PSET KEYH_RST THEN)
		( $KEYH @ 82 = IF EDIT_RESET KEYH_RST THEN)
		( $KEYH @ 72 = IF EDIT_SELECT KEYH_RST THEN)
		( $KEYH @ 69 = IF EDIT_EXTR KEYH_RST THEN)

		$KEYH @ 8 = IF 9 EMIT ATXY_WRT
		0 $ATX @ $ATY @ $ATZ @ C_IX OBJ_WRITE KEYH_RST THEN

		$KEYH @ 32 = IF $COLOR @ 48 + EMIT ATXY_WRT
		$COLOR @ $ATX @ $ATY @ $ATZ @ C_IX OBJ_WRITE KEYH_RST THEN

		$KEYH @ 76 = UNTIL
	;

	: EDIT_OBJ
		PAGE
		EDIT_STRUCT
		EDIT_COL_INFO 
		EDIT_TOOLS_INFO
		1 LOAD_AREA
		EDIT_KEY_CTRL
	;

	: PRINT_OBJ
		0 0 79 48 GUI_RECT
		4 0 79 GUI_HL
		35 2 AT-XY ." PRINTING"
		PRINT
	;

	: 3D_IMG
		2DUP 2DUP 2DUP 2DUP 2DUP 2DUP 2DUP 2DUP 2DUP
		AT-XY     ." _____/\\\\\\\\\\____/\\\\\\\\\\\\____"
		1+ AT-XY  ."  ___/\\\///////\\\__\/\\\////////\\\__"
		2 + AT-XY ."   __\///______/\\\___\/\\\______\//\\\_"
		3 + AT-XY ."    _________/\\\//____\/\\\_______\/\\\_"
		4 + AT-XY ."     ________\////\\\___\/\\\_______\/\\\_"
		5 + AT-XY ."      ___________\//\\\__\/\\\_______\/\\\_"
		6 + AT-XY ."       __/\\\______/\\\___\/\\\_______/\\\__"
		7 + AT-XY ."        _\///\\\\\\\\\/____\/\\\\\\\\\\\\/___"
		8 + AT-XY ."         ___\/////////______\////////////_____"
		9 + AT-XY ."          _____________________________________"
	;

	// MAIN MENU

	: MAIN_MENU
		BEGIN
			PAGE
			0 0 79 48 GUI_RECT
			4 0 79 GUI_HL
			36 2 AT-XY ." MAIN MENU" 
			5 7 AT-XY ." 1) Print 3D Object"
			5 9 AT-XY ." 2) Edit 3D Object"
			5 11 AT-XY ." 3) Credits" 
			5 13 AT-XY ." 4) Exit"
			18 30 3D_IMG
			17 29 63 40 GUI_RECT
			5 18 GUI_ANS
			BEGIN 
				8 19 AT-XY
				KEY $KEYH !
				$KEYH @ 49 = $KEYH @ 50 = $KEYH @ 51 = 
				$KEYH @ 52 =
				OR OR OR
			UNTIL

			$KEYH @ 49 = IF PRINT_OBJ KEYH_RST THEN
			$KEYH @ 50 = IF EDIT_OBJ KEYH_RST THEN
			( $KEYH @ 51 = IF CREDITS KEYH_RST THEN)
		$KEYH @ 52 = UNTIL
		PAGE
	;


	: 3D_PRINTER.EXE
		INITIALIZATION
		MAIN_MENU
	;
