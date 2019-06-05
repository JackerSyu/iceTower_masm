WinCheck_ALL proc
	
		mov eax, box1_X
		cmp eax, goalX
		jne WinCheck2
		mov eax, box1_Y
		cmp eax, goalY
		jne WinCheck2
		call Win

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