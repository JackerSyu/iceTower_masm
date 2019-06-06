; checking proc for A (left)
Check_A PROC
	
	mov edx ,eax
	cmp eax, 1 ;如果不是1 則是2 則到 box2迴圈
	jne loop2

    loop1:
        inc box1_Y
		call WinCheck_ALL
		call CheckBox_A ; box1 撞 box2
		call CheckObs_A ; box1 撞 obs1
        loop loop1
		ret
	loop2:
	    inc box2_Y
		call WinCheck_ALL
		call CheckBox_A ; box2 撞 box1
		call CheckObs_A ; box2 撞 obs1
        loop loop2
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