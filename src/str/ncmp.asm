;@DOES compare two strings, stopping at the maximum length
;@INPUT HL pointer to string
;@INPUT DE pointer to string
;@INPUT BC maximum string length
;@OUTPUT return z if the strings are equal, else nz
;@DESTROYS AF
strncmp:
	ld a,(de)
	or a,a
	ret z
	inc de
	cpi
	jp po,.fail
	jr z,strncmp
	ret
.fail:
	xor a,a
	inc a
	ret

