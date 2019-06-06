	
    ; first 分開撞obstacles
	playerX DD 1
	playerY DD 1
	playerChar DD 050h ; P

	box1_X DD 5
	box1_Y DD 3
	box1Char DD 04Fh ; O

	box2_X DD 7
	box2_Y DD 2
	box2Char DD 06Fh ; o

	obs1_X DD 3
	obs1_Y DD 3
	obs1Char DD 023h ; #

	obs2_X DD 4
	obs2_Y DD 2
	obs2Char DD 024h ; $
    
      ; second 分開撞wall
	playerX DD 1
	playerY DD 1
	playerChar DD 050h ; P

	box1_X DD 5
	box1_Y DD 3
	box1Char DD 04Fh ; O

	box2_X DD 7
	box2_Y DD 2
	box2Char DD 06Fh ; o

	obs1_X DD 3
	obs1_Y DD 7
	obs1Char DD 023h ; #

	obs2_X DD 4
	obs2_Y DD 8
	obs2Char DD 024h ; $
	
	; 2-1 撞wall box 重疊 2->1
	playerX DD 1
	playerY DD 1
	playerChar DD 050h ; P

	box1_X DD 5
	box1_Y DD 3
	box1Char DD 04Fh ; O

	box2_X DD 7
	box2_Y DD 3
	box2Char DD 06Fh ; o

	obs1_X DD 3
	obs1_Y DD 7
	obs1Char DD 023h ; #

	obs2_X DD 4
	obs2_Y DD 8
	obs2Char DD 024h ; $

	; 2-2 撞wall box 重疊 1->2
	playerX DD 1
	playerY DD 1
	playerChar DD 050h ; P

	box1_X DD 7
	box1_Y DD 3
	box1Char DD 04Fh ; O

	box2_X DD 5
	box2_Y DD 3
	box2Char DD 06Fh ; o

	obs1_X DD 3
	obs1_Y DD 7
	obs1Char DD 023h ; #

	obs2_X DD 4
	obs2_Y DD 8
	obs2Char DD 024h ; $

	; 3 撞obs box重疊 1->2
	playerX DD 1
	playerY DD 1
	playerChar DD 050h ; P

	box1_X DD 9
	box1_Y DD 3
	box1Char DD 04Fh ; O

	box2_X DD 3
	box2_Y DD 3
	box2Char DD 06Fh ; o

	obs1_X DD 1
	obs1_Y DD 3
	obs1Char DD 023h ; #

	obs2_X DD 5
	obs2_Y DD 4
	obs2Char DD 024h ; $