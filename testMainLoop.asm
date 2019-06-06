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
			; push
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

				COMMENT @
				PushBox2_W:
				mov eax, box2_X
				cmp eax, gameBoardSize ; Make sure that box within the board size
				je BoxBorder_W
				mov ebx, gameBoardSize ;計算推到底
				sub ebx, playerX
				add eax, ebx
				mov box2_X, eax
				jmp MoveDown
				@

			; box border (box撞到墻壁)
			BoxBorder_W:
				mov eax, playerX
				sub eax, 1			; 減回去
				mov playerX, eax