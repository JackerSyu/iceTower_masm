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