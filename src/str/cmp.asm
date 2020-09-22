;@DOES compare two strings
;@INPUT HL pointer to string
;@INPUT DE pointer to string
;@OUTPUT return z if the strings are equal, else nz
;@OUTPUT BC BC-min(strlen(HL),strlen(DE))
strcmp:
	ld a,(de)
	or a,a
	ret z
	inc de
	cpi
	jr z,strcmp
	ret

