; 冰塔遊戲
; 新增功能： 1. 主角、箱子有邊界限制 
;           2. 推到底 
;           3. 按r重新開始


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

	box1_X DD 4
	box1_Y DD 5
	obstacle1Char DD 04Fh ; O

	obstacle2X DD 6
	obstacle2Y DD 6
	obstacle2Char DD 058h ; X

	goalX DD 10
	goalY DD 10
	goalChar DD 47h ; G

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
			je Restart
			COMMENT @
			; Check that player
			; within the game board boundry
			LockUp:
				mov eax, playerX
				cmp eax, gameBoardSize
				jne LockDown
				mov eax, gameBoardSize
				mov playerX, eax

			LockDown:
				mov eax, playerX
				cmp eax, 1
				jne MoveUp
				mov playerX, 1
			@

			; Check for move UP -------------------------------------------------------------
			MoveUp:
				cmp edi, 77h ; w
				jne MoveDown
				mov eax, playerX
				cmp eax, gameBoardSize ; Make sure that player within the board size
				je MoveDown
				add eax, 1
				mov playerX, eax

			; check push from bottom
				mov eax, box1_X
				cmp eax , playerX
				jne MoveDown
				mov eax, box1_Y
				cmp eax, playerY
				jne MoveDown 

			; push
				mov eax, box1_X
				cmp eax, gameBoardSize ; Make sure that box within the board size
				je BoxBorder_W
				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerX
				add eax, ebx
				mov box1_X, eax
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
				mov eax, playerX
				cmp eax, 1			; Make sure that player within the board size
				je MoveLeft
				sub eax, 1
				mov playerX, eax

			; check push from top
				mov eax, box1_X
				cmp eax , playerX
				jne MoveLeft
				mov eax, box1_Y
				cmp eax, playerY
				jne MoveLeft 

			; push
				mov eax, box1_X
				cmp eax, 1			; Make sure that box within the board size
				je BoxBorder_S
				mov ebx, playerX ;計算推到底
				sub ebx, 1
				sub eax, ebx
				mov box1_X, eax
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
				mov eax, playerY
				cmp eax, gameBoardSize ; Make sure that player within the board size
				je MoveRight
				add eax, 1
				mov playerY, eax

			; check push from left
				mov eax, box1_Y
				cmp eax , playerY
				jne MoveRight
				mov eax, box1_X
				cmp eax, playerX
				jne MoveRight 

			; push
				mov eax, box1_Y
				cmp eax, gameBoardSize ; Make sure that box within the board size
				je BoxBorder_A
				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerY
				add eax, ebx
				mov box1_Y, eax
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
				mov eax, playerY
				cmp eax, 1 ; Make sure that player within the board size
				je CollisionCheck1
				sub eax, 1
				mov playerY, eax

			; check push from bottom
				mov eax, box1_Y
				cmp eax , playerY
				jne CollisionCheck1
				mov eax, box1_X
				cmp eax, playerX
				jne CollisionCheck1 

			; push
				mov eax, box1_Y
				cmp eax, 1 ; Make sure that box within the board size
				je BoxBorder_D
				mov ebx, playerY ;計算推到底
				sub ebx, 1
				sub eax, ebx
				mov box1_Y, eax
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
				;jne CollisionCheck2
				jne WinCheck
				mov eax, playerY
				cmp eax, box1_Y
				;jne CollisionCheck2
				jne WinCheck

				;jmp GameOver
COMMENT @
		CollisionCheck2:
				mov eax, playerX
				cmp eax, obstacle2X
				jne WinCheck
				mov eax, playerY
				cmp eax, obstacle2Y
				jne WinCheck

				jmp GameOver
@
			; Check if player reach the goal
			WinCheck:
				mov eax, box1_X
				cmp eax, goalX
				jne Render
				mov eax, box1_Y
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
	Restart:
		popa
		; initial position
		mov playerX ,1
		mov playerY ,1
		mov	box1_X , 4
		mov box1_Y , 5

		jmp Start
	WinState:
		; This state is reach when
		; the player reach the goal object
		push offset winMsg
		call printf
		add esp, 4

		mov eax, 0

   		mov esp,ebp
   		pop ebp

   		ret

	GameOver:
		; This state is reach when
		; the player hit one of the enemies
		push offset gameOverMsg
		call printf
		add esp, 4

		mov eax, 0

   		mov esp,ebp
   		pop ebp

   		ret

main ENDP


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
	jne jumpToLable ; jump to next check

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
			; SetCurrentCharacter curX, curY, playerChar, Obstacles1

			; Check for player position
			mov eax, curX
			cmp eax, playerX
			jne Obstacles1

			mov eax, curY
			cmp eax, playerY
			jne Obstacles1
			; If you here that's mean it's
			; our player position
			mov eax, playerChar
			mov currentChar, eax

			Obstacles1:
				; Check for obstacles position
				mov eax, curX
				cmp eax, box1_X
				;jne Obstacles2
				jne Goal

				mov eax, curY
				cmp eax, box1_Y
				;jne Obstacles2
				jne Goal

				mov eax, obstacle1Char
				mov currentChar, eax

COMMENT @	Obstacles2:
				; Check for obstacles position
				mov eax, curX
				cmp eax, obstacle2X
				jne Goal

				mov eax, curY
				cmp eax, obstacle2Y
				jne Goal

				mov eax, obstacle1Char
				mov currentChar, eax
@
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


END