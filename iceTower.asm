; 冰塔遊戲
; 新增功能：  1. 主角、箱子有邊界限制 
;            2. 推到底 
;            3. 按r重新開始
;			 4. 新增箱子
;            5. 新增障礙物;
;			 6. 完成所有方向移动
;			 7. 新增 level 2


.586
.model  flat, stdcall
option casemap:none

; Link in the CRT.
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

; Export system std functions
extern printf:NEAR
extern scanf:NEAR
extern _getch:NEAR
extern system:NEAR

.data
	; General global variables
	gameBoardSize DD 10
	singleChar DB "%c", 0
	boardLine DB "%c", 0Ah, 0
	playerPosition DB 0, 0
	grassChar DD 02Eh ; .
	currentChar DD 02Eh ; .
	clearConsoleArg DD "slc"

	; Possition of the currently
	; drawn character
	; It used to determin which object
	; to place in a cell as well as
	; player collisions
	curX DD 0
	curY DD 0

	; Game objects positions
	playerX DD 1
	playerY DD 1
	playerChar DD 050h ; P

	box1_X DD 3
	box1_Y DD 7
	box1Char DD 04Fh ; O

	box2_X DD 3
	box2_Y DD 5
	box2Char DD 06Fh ; o

	obs1_X DD 9
	obs1_Y DD 8
	obs1Char DD 023h ; #

	obs2_X DD 3
	obs2_Y DD 2
	obs2Char DD 024h ; $

	obs3_X DD 10
	obs3_Y DD 10
	obs3Char DD 023h ; #

	obs4_X DD 10
	obs4_Y DD 10
	obs4Char DD 023h ; #

	obs5_X DD 10
	obs5_Y DD 10
	obs5Char DD 023h ; #

	goalX DD 7
	goalY DD 3
	goalChar DD 47h ; G

	level DD 1

	; Game messages
	startMsg DB "Welcome to the game. Use W, S, A, D to move around. Try to reach G. Avoid X. Press any key to start.", 0Ah, 0
	winMsg DB "Congratulations! You won the game.", 0Ah, 0
    gameOverMsg DB "Game Over!", 0Ah, 0

.code

main PROC C
Start:
		push ebp
     	mov ebp,esp

		; int 3
		; Clear system console
		push offset clearConsoleArg
		call system
		add esp, 4

		push offset startMsg
		call printf
		add esp, 4

 MainLoop:	call _getch
 			mov edi, eax
			
			; Clear system console on every update
			push offset clearConsoleArg
			call system
			add esp, 4

 			; Check for quit
 			cmp edi, 71h  ; 'q' key
 			je Quit

			cmp edi, 72h ; 'r' restart
			je NextLevel

			; Check for move UP -------------------------------------------------------------
			MoveUp:
				cmp edi, 77h ; w
				jne MoveDown
				call CheckPlayerHit_W ; check player 是否可動
				cmp eax, 1
				je MoveDown			; 1 代表不可move 否則可move 即往下執行
				
				mov eax, playerX ; P可以往上移動
				add eax, 1
				mov playerX, eax

			; Check push from bottom (box1)
				mov eax, box1_X
				cmp eax , playerX
				jne PushCheckBox2_W
				mov eax, box1_Y    ; 表示同X軸
				cmp eax, playerY   
				jne PushCheckBox2_W 
				jmp PushBox1_W     ; 表示同Y軸 判斷是推box1

			; Check push from bottom (box2)
			PushCheckBox2_W:
				mov eax, box2_X
				cmp eax , playerX
				jne MoveDown		; 都不是 前往下個方向
				mov eax, box2_Y
				cmp eax, playerY
				jne MoveDown				
				jmp PushBox2_W

			PushBox1_W:
				mov eax, 1 ;表示 box1
				call CheckPushBoxHit_W
				cmp eax, 1
				je BoxBorder_W
				
				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerX
				mov ecx, ebx
				mov eax, 1 ; 表示 box1
				call Check_W
				jmp MoveDown

			PushBox2_W:
				mov eax, 2 ;  stand for box2
				call CheckPushBoxHit_W
				cmp eax, 1
				je BoxBorder_W

				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerX
				mov ecx, ebx
				mov eax, 2 ; 表示 box2
				call Check_W
				jmp MoveDown


			; box border (box撞到墻壁)
			BoxBorder_W:
				mov eax, playerX
				sub eax, 1			; 減回去
				mov playerX, eax

			; Check for move DOWN ------------------------------------------------------------------
			MoveDown:
				cmp edi, 73h ; s
				jne MoveLeft
				call CheckPlayerHit_S ; check player 是否可動
				cmp eax, 1			; Make sure that player within the board size
				je MoveLeft			; 1 代表不可move 否則可move 即往下執行

				mov eax, playerX ; P可以往上移動
				sub eax, 1
				mov playerX, eax

			; Check push from top (box1)
				mov eax, box1_X
				cmp eax , playerX
				jne PushCheckBox2_S
				mov eax, box1_Y
				cmp eax, playerY
				jne PushCheckBox2_S
				jmp PushBox1_S 

			; Check push from top (box2)
			PushCheckBox2_S:
				mov eax, box2_X
				cmp eax , playerX
				jne MoveLeft
				mov eax, box2_Y
				cmp eax, playerY
				jne MoveLeft
				jmp PushBox2_S 
			
			; push
			PushBox1_S:
				mov eax, 1			;表示 box1
				call CheckPushBoxHit_S ;; Make sure that box within the board size
				cmp eax, 1			
				je BoxBorder_S

				mov ebx, playerX ;計算推到底
				sub ebx, 1
				mov ecx, ebx
				mov eax, 1 ; 表示 box1
				call Check_S
				jmp MoveLeft

			PushBox2_S:
				mov eax, 2 ;  stand	for box2
				call CheckPushBoxHit_S
				cmp eax, 1			; Make sure that box within the board size
				je BoxBorder_S

				mov ebx, playerX ;計算推到底
				sub ebx, 1
				mov ecx, ebx
				mov eax, 2 ; 表示 box2
				call Check_S
				jmp MoveLeft

			; box border (box撞到墻壁)
			BoxBorder_S:
				mov eax, playerX
				add eax, 1			; 加回去
				mov playerX, eax

			; Check for move LEFT --------------------------------------------------------------------
			MoveLeft:
				cmp edi, 61h ; a
				jne MoveRight
				call CheckPlayerHit_A ; check player 是否可動
				cmp eax, 1
				je MoveRight		 ;	1 代表不可move 否則可move 即往下執行

				mov eax, playerY	; P可以往left移動
				add eax, 1
				mov playerY, eax

			; Check push from left (box1)
				mov eax, box1_Y
				cmp eax , playerY
				jne PushCheckBox2_A
				mov eax, box1_X
				cmp eax, playerX
				jne PushCheckBox2_A 
				jmp PushBox1_A

			; Check push from left (box2)
			PushCheckBox2_A:
				mov eax, box2_Y
				cmp eax , playerY
				jne MoveRight
				mov eax, box2_X
				cmp eax, playerX
				jne MoveRight 
				jmp PushBox2_A

			; push
			PushBox1_A:
				mov eax, 1				;表示 box1
				call CheckPushBoxHit_A
				cmp eax, 1
				je BoxBorder_A

				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerY
				mov ecx, ebx
				mov eax, 1			; 表示 box1
				call Check_A
				jmp MoveRight

			PushBox2_A:
				mov eax, 2				;表示 box2
				call CheckPushBoxHit_A
				cmp eax, 1
				je BoxBorder_A

				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerY
				mov ecx, ebx
				mov eax, 2			; 表示 box2
				call Check_A
				jmp MoveRight

			; box border (box撞到墻壁)
			BoxBorder_A:
				mov eax, playerY
				sub eax, 1			; 加回去
				mov playerY, eax


			; Check for move RIGHT -----------------------------------------------------------------
			MoveRight:
				cmp edi, 64h ; d
				jne CollisionCheck1
				call CheckPlayerHit_D ; check player 是否可動
				cmp eax, 1 ; Make sure that player within the board size
				je CollisionCheck1

				mov eax, playerY	; P可以往right移動
				sub eax, 1
				mov playerY, eax

			; Check push from right (box1)
				mov eax, box1_Y
				cmp eax , playerY
				jne PushCheckBox2_D
				mov eax, box1_X
				cmp eax, playerX
				jne PushCheckBox2_D
				jmp PushBox1_D

			; Check push from right (box2)
			PushCheckBox2_D:
				mov eax, box2_Y
				cmp eax , playerY
				jne CollisionCheck1
				mov eax, box2_X
				cmp eax, playerX
				jne CollisionCheck1
				jmp PushBox2_D

			; push
			PushBox1_D:
				mov eax, 1			;表示 box1
				call CheckPushBoxHit_D
				cmp eax, 1 ; Make sure that box within the board size
				je BoxBorder_D

				mov ebx, playerY ;計算推到底
				sub ebx, 1
				mov ecx, ebx
				mov eax, 1			; 表示 box1
				call Check_D
				jmp CollisionCheck1

			PushBox2_D:
				mov eax, 2	;表示 box1
				call CheckPushBoxHit_D
				cmp eax, 1 ; Make sure that box within the board size
				je BoxBorder_D

				mov ebx, playerY ;計算推到底
				sub ebx, 1
				mov ecx, ebx
				mov eax, 2		; 表示 box1
				call Check_D
				jmp CollisionCheck1

			; box border (box撞到墻壁)
			BoxBorder_D:
				mov eax, playerY
				add eax, 1			; 加回去
				mov playerY, eax

			; Check player and enemies collisions
			CollisionCheck1:
				mov eax, playerX
				cmp eax, box1_X
				jne CollisionCheck2
				;jne WinCheck
				mov eax, playerY
				cmp eax, box1_Y
				jne CollisionCheck2
				;jmp WinCheck

				;jmp GameOver
			CollisionCheck2:
				mov eax, playerX
				cmp eax, box2_X
				jne WinCheck
				mov eax, playerY
				cmp eax, box2_Y
				jne WinCheck
				
				
			; Check if player reach the goal
			WinCheck:
				mov eax, box1_X
				cmp eax, goalX
				jne WinCheck2
				mov eax, box1_Y
				cmp eax, goalY
				jne WinCheck2

				jmp WinState

			WinCheck2:
				mov eax, box2_X
				cmp eax, goalX
				jne Render
				mov eax, box2_Y
				cmp eax, goalY
				jne Render

				jmp WinState
 			Render:
				; Rerender entire game board
				call RenderGameBoard

 			jmp MainLoop

 	Quit:
 		mov eax, 0

		mov esp,ebp
		pop ebp

		ret
	NextLevel:
		popa
		; initial position
		mov playerX ,1
		mov playerY ,1
		mov	box1_X , 4
		mov box1_Y , 5
		mov box2_X, 5
		mov box2_Y, 5
		mov obs1_X, 3
		mov obs1_Y, 5
		mov obs2_X, 1
		mov obs2_Y, 9
		mov goalX, 2
		mov goalY, 8
		mov level, 3

		jmp Start

	WinState:
		; This state is reach when
		; the player reach the goal object
		COMMENT @
		push offset winMsg
		call printf
		add esp, 4

		mov eax, 0

   		mov esp,ebp
   		pop ebp

   		ret
		@
		;call Win
		jmp NextLevel
		ret
	GameOver:
		; This state is reach when
		; the player Hit one of the enemies
		push offset gameOverMsg
		call printf
		add esp, 4

		mov eax, 0

   		mov esp,ebp
   		pop ebp

   		ret

main ENDP

; checking proc for w (up)
Check_W PROC
	
	mov edx ,eax
	cmp eax, 1 ;如果不是1 則是2 則到 box2迴圈
	jne loop2

    loop1:
        inc box1_X
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_W ; box1 撞 box2
		call CheckObs_W ; box1 撞 obs1
        loop loop1
		ret
	loop2:
	    inc box2_X
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_W ; box2 撞 box1
		call CheckObs_W ; box2 撞 obs1
        loop loop2
		ret

	NextLevel:
		ret
Check_W endp

CheckPlayerHit_W proc ; 判player 本身是否可前進(（障礙：1. border 2. obstacles 3.box）)

	; determine border 
	mov eax, playerX
	cmp eax, gameBoardSize ; Make sure that player within the board size
	je CanNotMove

	; determine obstacles 
	COMMENT @
	mov eax, playerY ; check player 撞 obs1
	cmp eax, obs1_Y  ;
	jne CanMove      ;
	mov eax, playerX ;
	mov ebx, obs1_X  ;
	sub ebx, 1       ; 
	cmp eax, ebx	 ; 判上方有障礙物
	je CanNotMove
@
	mov eax, playerY ; check player 撞 obs1
	cmp eax, obs1_Y  ;
	jne obs2_label   ;
	mov eax, playerX ;
	mov ebx, obs1_X  ;
	sub ebx, 1       ; 
	cmp eax, ebx	 ; 判上方有障礙物
	je CanNotMove	
	jmp obs2_label

	obs2_label:
		mov eax, playerY
		cmp eax, obs2_Y  ;
		jne CanMove
		mov eax, playerX ;
		mov ebx, obs2_X  ;
		sub ebx, 1       ; 
		cmp eax, ebx	 ; 判上方有障礙物
		je CanNotMove	
		jmp CanMove

	CanMove:		; Can move
		mov eax, 2
		ret

	CanNotMove: 
		mov eax, 1 ; 代表調到moveDown (can't move)
		ret

CheckPlayerHit_W endp

CheckPushBoxHit_W proc ;判 帶著box的player是否可以移動（障礙：1. border 2. obstacles 3. box）

	cmp eax, 1; 表示 box1
	jne Box2_lab

	Box1_lab:
		; 判border
		mov eax, box1_X
		cmp eax, gameBoardSize ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles
		mov eax, box1_Y
		cmp eax, obs1_Y
		jne Obs2_lab1				;不在同Y軸
		mov eax, box1_X
		mov ebx, obs1_X
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab1

		Obs2_lab1:
		mov eax, box1_Y
		cmp eax, obs2_Y
		jne Lab1				;不在同Y軸
		mov eax, box1_X
		mov ebx, obs2_X
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab1

		; determine box
		Lab1:
		mov eax, box1_Y
		cmp eax, box2_Y
		jne CanMove				;不在同Y軸
		mov eax, box1_X
		mov ebx, box2_X
		sub ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	Box2_lab:
		; 判border
		mov eax, box2_X
		cmp eax, gameBoardSize ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles1
		mov eax, box2_Y
		cmp eax, obs1_Y
		jne Obs2_lab2		;不在同Y軸
		mov eax, box2_X
		mov ebx, obs1_X
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab2


		; determine obstacles2
		Obs2_lab2:
		mov eax, box2_Y
		cmp eax, obs2_Y
		jne Lab2			;不在同Y軸
		mov eax, box2_X
		mov ebx, obs2_X
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab2 

		; determine box
		Lab2:
		mov eax, box2_Y
		cmp eax, box1_Y
		jne CanMove				;不在同Y軸
		mov eax, box2_X
		mov ebx, box1_X
		sub ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	CanMove:
		mov eax, 2
		ret
	CanNotMove:
		mov eax, 1
		ret

CheckPushBoxHit_W endp


CheckBox_W proc
	mov eax, box1_Y
	cmp eax, box2_Y ;same y
	je SameY
	ret
	SameY:
		mov eax, box1_X
		cmp eax, box2_X
		je Hit
		ret
	Hit:
		cmp edx, 1 ;1 是 box1
		jne Hit2
		dec box1_X
		ret
	Hit2:
		dec box2_X
	ret
CheckBox_W endp

CheckObs_W proc  ; 每次動一步檢查obs

	cmp edx, 1 ; box1
	jne Box2_label

	; check box1
	mov eax, box1_Y
	cmp eax, obs1_Y
	je SameY_obs1
	jmp Label1				; not the same then check obs2
	SameY_obs1:
		mov eax, box1_X
		cmp eax, obs1_X
		je Hit				; check obs 是否撞 否則繼續檢查下個obs
Label1:	mov eax, box1_Y 
		cmp eax, obs2_Y
		je sameY_obs2
		ret
	sameY_obs2:
		mov eax, box1_X
		cmp eax, obs2_X
		je Hit
		ret		
	Hit:
		dec box1_X
		ret

	; check box2
	Box2_label:
	mov eax, box2_Y
	cmp eax, obs1_Y
	je SameY2_obs1
	jmp Label2

	SameY2_obs1:
		mov eax, box2_X
		cmp eax, obs1_X
		je Hit2
Label2: mov eax, box2_Y
		cmp eax, obs2_Y
		je SameY2_obs2
		ret
	SameY2_obs2:
		mov eax, box2_X
		cmp eax, obs2_X
		je Hit2
		ret
	Hit2:
		dec box2_X
		ret
CheckObs_W endp



; checking proc for s (down)
Check_S PROC
	
	mov edx ,eax
	cmp eax, 1 ;如果不是1 則是2 則到 box2迴圈
	jne loop2

    loop1:
        dec box1_X
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_S ; box1 撞 box2
		call CheckObs_S ; box1 撞 obs1
        loop loop1
		ret
	loop2:
	    dec box2_X
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_S ; box2 撞 box1
		call CheckObs_S ; box2 撞 obs1
        loop loop2
NextLevel:		
		ret


Check_S endp

CheckPlayerHit_S proc ; 判player 本身是否可前進(（障礙：1. border 2. obstacles 3.box）)

	; determine border 
	mov eax, playerX
	cmp eax, 1 ; Make sure that player within the board size
	je CanNotMove

	; determine obstacles 
	mov eax, playerY ; check player 撞 obs1
	cmp eax, obs1_Y  ;
	jne obs2_label   ;
	mov eax, playerX ;
	mov ebx, obs1_X  ;
	add ebx, 1       ; 
	cmp eax, ebx	 ; 判下方有障礙物
	je CanNotMove	
	jmp obs2_label

	obs2_label:
		mov eax, playerY
		cmp eax, obs2_Y  ;
		jne CanMove
		mov eax, playerX ;
		mov ebx, obs2_X  ;
		add ebx, 1       ; 
		cmp eax, ebx	 ; 判上方有障礙物
		je CanNotMove	
		jmp CanMove

	CanMove:		; Can move
		mov eax, 2
		ret

	CanNotMove: 
		mov eax, 1 ; 代表調到moveDown (can't move)
		ret

CheckPlayerHit_S endp

CheckPushBoxHit_S proc ;判 帶著box的player是否可以移動（障礙：1. border 2. obstacles 3. box）

	cmp eax, 1; 表示 box1
	jne Box2_lab

	Box1_lab:
		; 判border
		mov eax, box1_X
		cmp eax, 1 ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles
		mov eax, box1_Y
		cmp eax, obs1_Y
		jne Obs2_lab1				;不在同Y軸
		mov eax, box1_X
		mov ebx, obs1_X
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab1

		Obs2_lab1:
		mov eax, box1_Y
		cmp eax, obs2_Y
		jne Lab1				;不在同Y軸
		mov eax, box1_X
		mov ebx, obs2_X
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab1

		; determine box
		Lab1:
		mov eax, box1_Y
		cmp eax, box2_Y
		jne CanMove				;不在同Y軸
		mov eax, box1_X
		mov ebx, box2_X
		add ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	Box2_lab:
		; 判border
		mov eax, box2_X
		cmp eax, 1 ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles1
		mov eax, box2_Y
		cmp eax, obs1_Y
		jne Obs2_lab2		;不在同Y軸
		mov eax, box2_X
		mov ebx, obs1_X
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab2


		; determine obstacles2
		Obs2_lab2:
		mov eax, box2_Y
		cmp eax, obs2_Y
		jne Lab2			;不在同Y軸
		mov eax, box2_X
		mov ebx, obs2_X
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab2 

		; determine box
		Lab2:
		mov eax, box2_Y
		cmp eax, box1_Y
		jne CanMove				;不在同Y軸
		mov eax, box2_X
		mov ebx, box1_X
		add ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	CanMove:
		mov eax, 2
		ret
	CanNotMove:
		mov eax, 1
		ret

CheckPushBoxHit_S endp


CheckBox_S proc
	mov eax, box1_Y
	cmp eax, box2_Y ;same y
	je SameY
	ret
	SameY:
		mov eax, box1_X
		cmp eax, box2_X
		je Hit
		ret
	Hit:
		cmp edx, 1 ;1 是 box1
		jne Hit2
		inc box1_X
		ret
	Hit2:
		inc box2_X
	ret
CheckBox_S endp

CheckObs_S proc  ; 每次動一步檢查obs

	cmp edx, 1 ; box1
	jne Box2_label

	; check box1
	mov eax, box1_Y
	cmp eax, obs1_Y
	je SameY_obs1
	jmp Label1
	SameY_obs1:
		mov eax, box1_X
		cmp eax, obs1_X
		je Hit				; check obs 是否撞 否則繼續檢查下個obs
Label1:	mov eax, box1_Y 
		cmp eax, obs2_Y
		je sameY_obs2
		ret
	sameY_obs2:
		mov eax, box1_X
		cmp eax, obs2_X
		je Hit
		ret		
	Hit:
		inc box1_X
		ret

	; check box2
	Box2_label:
	mov eax, box2_Y
	cmp eax, obs1_Y
	je SameY2_obs1
	jmp Label2

	SameY2_obs1:
		mov eax, box2_X
		cmp eax, obs1_X
		je Hit2
Label2: mov eax, box2_Y
		cmp eax, obs2_Y
		je SameY2_obs2
		ret
	SameY2_obs2:
		mov eax, box2_X
		cmp eax, obs2_X
		je Hit2
		ret
	Hit2:
		inc box2_X
		ret
CheckObs_S endp



; checking proc for A (left)
Check_A PROC
	
	mov edx ,eax
	cmp eax, 1 ;如果不是1 則是2 則到 box2迴圈
	jne loop2

    loop1:
        inc box1_Y
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_A ; box1 撞 box2
		call CheckObs_A ; box1 撞 obs1
        loop loop1
		ret
	loop2:
	    inc box2_Y
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_A ; box2 撞 box1
		call CheckObs_A ; box2 撞 obs1
        loop loop2
NextLevel:
		ret

Check_A endp

CheckPlayerHit_A proc ; 判player 本身是否可前進(（障礙：1. border 2. obstacles 3.box）)

	; determine border 
	mov eax, playerY
	cmp eax, gameBoardSize ; Make sure that player within the board size
	je CanNotMove

	; determine obstacles 
	mov eax, playerX ; check player 撞 obs1
	cmp eax, obs1_X  ;
	jne obs2_label   ;
	mov eax, playerY ;
	mov ebx, obs1_Y ;
	sub ebx, 1       ; 
	cmp eax, ebx	 ; 判上方有障礙物
	je CanNotMove	
	jmp obs2_label

	obs2_label:
		mov eax, playerX
		cmp eax, obs2_X  ;
		jne CanMove
		mov eax, playerY ;
		mov ebx, obs2_Y  ;
		sub ebx, 1       ; 
		cmp eax, ebx	 ; 判上方有障礙物
		je CanNotMove	
		jmp CanMove

	CanMove:		; Can move
		mov eax, 2
		ret

	CanNotMove: 
		mov eax, 1 ; 代表調到moveDown (can't move)
		ret

CheckPlayerHit_A endp

CheckPushBoxHit_A proc ;判 帶著box的player是否可以移動（障礙：1. border 2. obstacles 3. box）

	cmp eax, 1; 表示 box1
	jne Box2_lab

	Box1_lab:
		; 判border
		mov eax, box1_Y
		cmp eax, gameBoardSize ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles
		mov eax, box1_X
		cmp eax, obs1_X
		jne Obs2_lab1				;不在同Y軸
		mov eax, box1_Y
		mov ebx, obs1_Y
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab1

		Obs2_lab1:
		mov eax, box1_X
		cmp eax, obs2_X
		jne Lab1				;不在同Y軸
		mov eax, box1_Y
		mov ebx, obs2_Y
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab1

		; determine box
		Lab1:
		mov eax, box1_X
		cmp eax, box2_X
		jne CanMove				;不在同Y軸
		mov eax, box1_Y
		mov ebx, box2_Y
		sub ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	Box2_lab:
		; 判border
		mov eax, box2_Y
		cmp eax, gameBoardSize ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles1
		mov eax, box2_X
		cmp eax, obs1_X
		jne Obs2_lab2		;不在同Y軸
		mov eax, box2_Y
		mov ebx, obs1_Y
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab2


		; determine obstacles2
		Obs2_lab2:
		mov eax, box2_X
		cmp eax, obs2_X
		jne Lab2			;不在同Y軸
		mov eax, box2_Y
		mov ebx, obs2_Y
		sub ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab2 

		; determine box
		Lab2:
		mov eax, box2_X
		cmp eax, box1_X
		jne CanMove				;不在同Y軸
		mov eax, box2_Y
		mov ebx, box1_Y
		sub ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	CanMove:
		mov eax, 2
		ret
	CanNotMove:
		mov eax, 1
		ret

CheckPushBoxHit_A endp


CheckBox_A proc
	mov eax, box1_X
	cmp eax, box2_X ;same y
	je SameY
	ret
	SameY:
		mov eax, box1_Y
		cmp eax, box2_Y
		je Hit
		ret
	Hit:
		cmp edx, 1 ;1 是 box1
		jne Hit2
		dec box1_Y
		ret
	Hit2:
		dec box2_Y
	ret
CheckBox_A endp

CheckObs_A proc  ; 每次動一步檢查obs

	cmp edx, 1 ; box1
	jne Box2_label

	; check box1
	mov eax, box1_X
	cmp eax, obs1_X
	je SameY_obs1
	jmp Label1
	SameY_obs1:
		mov eax, box1_Y
		cmp eax, obs1_Y
		je Hit				; check obs 是否撞 否則繼續檢查下個obs
Label1:	mov eax, box1_X 
		cmp eax, obs2_X
		je sameY_obs2
		ret
	sameY_obs2:
		mov eax, box1_Y
		cmp eax, obs2_Y
		je Hit
		ret		
	Hit:
		dec box1_Y
		ret

	; check box2
	Box2_label:
	mov eax, box2_X
	cmp eax, obs1_X
	je SameY2_obs1
	jmp Label2

	SameY2_obs1:
		mov eax, box2_Y
		cmp eax, obs1_Y
		je Hit2
Label2: mov eax, box2_X
		cmp eax, obs2_X
		je SameY2_obs2
		ret
	SameY2_obs2:
		mov eax, box2_Y
		cmp eax, obs2_Y
		je Hit2
		ret
	Hit2:
		dec box2_Y
		ret
CheckObs_A endp

; checking proc for D (right)
Check_D PROC
	
	mov edx ,eax
	cmp eax, 1 ;如果不是1 則是2 則到 box2迴圈
	jne loop2

    loop1:
        dec box1_Y
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_D ; box1 撞 box2
		call CheckObs_D ; box1 撞 obs1
        loop loop1
		ret
	loop2:
	    dec box2_Y
		call WinCheck_ALL
		cmp level, 2
		je NextLevel
		call CheckBox_D ; box2 撞 box1
		call CheckObs_D ; box2 撞 obs1
        loop loop2
		ret

NextLevel:
	ret
Check_D endp

CheckPlayerHit_D proc ; 判player 本身是否可前進(（障礙：1. border 2. obstacles 3.box）)

	; determine border 
	mov eax, playerY
	cmp eax, 1 ; Make sure that player within the board size
	je CanNotMove

	; determine obstacles 
	mov eax, playerX ; check player 撞 obs1
	cmp eax, obs1_X  ;
	jne obs2_label   ;
	mov eax, playerY ;
	mov ebx, obs1_Y ;
	add ebx, 1       ; 
	cmp eax, ebx	 ; 判上方有障礙物
	je CanNotMove	
	jmp obs2_label

	obs2_label:
		mov eax, playerX
		cmp eax, obs2_X  ;
		jne CanMove
		mov eax, playerY ;
		mov ebx, obs2_Y  ;
		add ebx, 1       ; 
		cmp eax, ebx	 ; 判上方有障礙物
		je CanNotMove	
		jmp CanMove

	CanMove:		; Can move
		mov eax, 2
		ret

	CanNotMove: 
		mov eax, 1 ; 代表調到moveDown (can't move)
		ret

CheckPlayerHit_D endp

CheckPushBoxHit_D proc ;判 帶著box的player是否可以移動（障礙：1. border 2. obstacles 3. box）

	cmp eax, 1; 表示 box1
	jne Box2_lab

	Box1_lab:
		; 判border
		mov eax, box1_Y
		cmp eax, 1 ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles
		mov eax, box1_X
		cmp eax, obs1_X
		jne Obs2_lab1				;不在同Y軸
		mov eax, box1_Y
		mov ebx, obs1_Y
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab1

		Obs2_lab1:
		mov eax, box1_X
		cmp eax, obs2_X
		jne Lab1				;不在同Y軸
		mov eax, box1_Y
		mov ebx, obs2_Y
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab1

		; determine box
		Lab1:
		mov eax, box1_X
		cmp eax, box2_X
		jne CanMove				;不在同Y軸
		mov eax, box1_Y
		mov ebx, box2_Y
		add ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	Box2_lab:
		; 判border
		mov eax, box2_Y
		cmp eax, 1 ; Make sure that box within the board size
		je CanNotMove	; 撞到
	
		; determine obstacles1
		mov eax, box2_X
		cmp eax, obs1_X
		jne Obs2_lab2		;不在同Y軸
		mov eax, box2_Y
		mov ebx, obs1_Y
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Obs2_lab2


		; determine obstacles2
		Obs2_lab2:
		mov eax, box2_X
		cmp eax, obs2_X
		jne Lab2			;不在同Y軸
		mov eax, box2_Y
		mov ebx, obs2_Y
		add ebx, 1
		cmp eax, ebx			; 判box前面有obs
		je CanNotMove
		jmp Lab2 

		; determine box
		Lab2:
		mov eax, box2_X
		cmp eax, box1_X
		jne CanMove				;不在同Y軸
		mov eax, box2_Y
		mov ebx, box1_Y
		add ebx, 1
		cmp eax, ebx			; 判box前面有box
		je CanNotMove
		jmp CanMove

	CanMove:
		mov eax, 2
		ret
	CanNotMove:
		mov eax, 1
		ret

CheckPushBoxHit_D endp


CheckBox_D proc
	mov eax, box1_X
	cmp eax, box2_X ;same y
	je SameY
	ret
	SameY:
		mov eax, box1_Y
		cmp eax, box2_Y
		je Hit
		ret
	Hit:
		cmp edx, 1 ;1 是 box1
		jne Hit2
		inc box1_Y
		ret
	Hit2:
		inc box2_Y
	ret
CheckBox_D endp

CheckObs_D proc  ; 每次動一步檢查obs

	cmp edx, 1 ; box1
	jne Box2_label

	; check box1
	mov eax, box1_X
	cmp eax, obs1_X
	je SameY_obs1
	jmp Label1
	SameY_obs1:
		mov eax, box1_Y
		cmp eax, obs1_Y
		je Hit				; check obs 是否撞 否則繼續檢查下個obs
Label1:	mov eax, box1_X 
		cmp eax, obs2_X
		je sameY_obs2
		ret
	sameY_obs2:
		mov eax, box1_Y
		cmp eax, obs2_Y
		je Hit
		ret		
	Hit:
		inc box1_Y
		ret

	; check box2
	Box2_label:
	mov eax, box2_X
	cmp eax, obs1_X
	je SameY2_obs1
	jmp Label2

	SameY2_obs1:
		mov eax, box2_Y
		cmp eax, obs1_Y
		je Hit2
Label2: mov eax, box2_X
		cmp eax, obs2_X
		je SameY2_obs2
		ret
	SameY2_obs2:
		mov eax, box2_Y
		cmp eax, obs2_Y
		je Hit2
		ret
	Hit2:
		inc box2_Y
		ret
CheckObs_D endp




RenderGameBoard PROC
		COMMENT @
		Render intire game board
		Gloabal variables:
		 	- gameBoardSize
		 	- curX
		 	- curY
		@

		push ebp
     	mov ebp,esp

		mov ecx, gameBoardSize
		lineLoop:

			; Update  current X coordinate
			mov curX, ecx

			push gameBoardSize
			call RenderLine
			add esp, 4

			sub ecx, 1
		jnz lineLoop

		mov esp,ebp
     	pop ebp

		ret
RenderGameBoard ENDP

SetCurrentCharacter MACRO xPos, yPos, charRepr, jumpToLable
	COMMENT @
	xPos - Item X position
	yPos - Item Y position
	charRepr - Item character representation
	jumpToLable -  Next procedure to jump to
	@

	; Check for item position
	mov eax, curX
	cmp eax, xPos
	jne jumpToLable ; jump to next Check

	mov eax, curY
	cmp eax, yPos
	jne jumpToLable
	; If you here that's means it's
	; our player position
	mov eax, charRepr
	mov currentChar, eax
endm

RenderLine PROC
		COMMENT @
		:param gridSizeParam: Determine the width of the grid to draw
		@

		push ebp
     	mov ebp,esp

		; Function parameters
		gridSizeParam EQU [ebp + 8]

		pusha ; Push general-purpose registers onto stack

		mov ecx, gridSizeParam ; Start counter
		mainLoop:

			mov curY, ecx ; Store  current Y coordinate

			; TODO(kirill): Doesn't work. Find out why.
			; SetCurrentCharacter curX, curY, playerChar, Boxes1

			; Check for player position
			mov eax, curX
			cmp eax, playerX
			jne Boxes1

			mov eax, curY
			cmp eax, playerY
			jne Boxes1
			; If you here that's mean it's
			; our player position
			mov eax, playerChar
			mov currentChar, eax

			Boxes1:
				; Check for boxes position
				mov eax, curX
				cmp eax, box1_X
				jne Boxes2
				;jne Goal

				mov eax, curY
				cmp eax, box1_Y
				jne Boxes2
				;jne Goal

				mov eax, box1Char
				mov currentChar, eax

			Boxes2:
				; Check for obstacles position
				mov eax, curX
				cmp eax, box2_X
				jne Obs1

				mov eax, curY
				cmp eax, box2_Y
				jne Obs1

				mov eax, box2Char
				mov currentChar, eax

			Obs1:
				; Check for boxes position
				mov eax, curX
				cmp eax, obs1_X
				;jne Boxes2
				jne Obs2

				mov eax, curY
				cmp eax, obs1_Y
				;jne Boxes2
				jne Obs2

				mov eax, obs1Char
				mov currentChar, eax

			Obs2:
				; Check for boxes position
				mov eax, curX
				cmp eax, obs2_X
				;jne Boxes2
				jne Obs3

				mov eax, curY
				cmp eax, obs2_Y
				;jne Boxes2
				jne Obs3

				mov eax, obs2Char
				mov currentChar, eax

			Obs3:
				; Check for boxes position
				mov eax, curX
				cmp eax, obs3_X
				;jne Boxes2
				jne Obs4

				mov eax, curY
				cmp eax, obs3_Y
				;jne Boxes2
				jne Obs4

				mov eax, obs3Char
				mov currentChar, eax

			Obs4:
				; Check for boxes position
				mov eax, curX
				cmp eax, obs4_X
				;jne Boxes2
				jne Obs5

				mov eax, curY
				cmp eax, obs4_Y
				;jne Boxes2
				jne Obs5

				mov eax, obs4Char
				mov currentChar, eax

			Obs5:
				; Check for boxes position
				mov eax, curX
				cmp eax, obs5_X
				;jne Boxes2
				jne Goal

				mov eax, curY
				cmp eax, obs5_Y
				;jne Boxes2
				jne Goal

				mov eax, obs5Char
				mov currentChar, eax

			Goal:
				; Check for goal position
				mov eax, curX
				cmp eax, goalX
				jne PrintCurrentCharacter

				mov eax, curY
				cmp eax, goalY
				jne PrintCurrentCharacter

				mov eax, goalChar
				mov currentChar, eax

			PrintCurrentCharacter:
				push [currentChar]
				call PrintChar

				; Set current draw char back to grass
				mov eax, [grassChar]
				mov currentChar, eax

			sub ecx, 1 ; Decrement counter
		jnz mainLoop

		; Go to a new line
		push 0Ah
		call PrintChar

		popa ; Pop general-purpose registers from stack

		mov esp,ebp
     	pop ebp

		ret
RenderLine ENDP


PrintChar PROC
		COMMENT @
		:param character: Determine current character to draw on the board
		@

		push ebp
     	mov ebp,esp

		; Function parameters
		character EQU [ebp + 8]

		pusha

		push character
		push offset singleChar
		call printf
		add esp, 8

		popa

		mov esp,ebp
     	pop ebp

		ret 4
PrintChar ENDP

WinCheck_ALL proc ; check win or not
	
		mov eax, box1_X
		cmp eax, goalX
		jne WinCheck2
		mov eax, box1_Y
		cmp eax, goalY
		jne WinCheck2
		call Win
		ret
	WinCheck2:
		mov eax, box2_X
		cmp eax, goalX
		jne NotWin
		mov eax, box2_Y
		cmp eax, goalY
		jne NotWin
		call Win
	NotWin:
		ret

WinCheck_ALL endp 

Win proc ; win state page 
	
	cmp level, 1
	je NextLevel

	push offset winMsg
	call printf
	add esp, 4
	mov eax, 0
   	mov esp,ebp
   	pop ebp

   	ret

NextLevel: 
	mov level, 2
	ret

Win endp 
END