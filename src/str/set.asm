;@DOES set the bytes of null-terminated string
;@INPUT HL pointer to string
;@INPUT C value to set bytes to
;@OUTPUT HL HL+strlen(HL)
;@DESTROYS AF
strset:
	xor a,a
.loop:
	cp a,(hl)
	ret z
	ld (hl),c
	inc hl
	jr .loop

