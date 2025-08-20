_strupper:
.loop:
	ld (hl),a
.next:
	inc hl
;@DOES convert a string to uppercase
;@INPUT HL pointer to string
;@OUTPUT HL HL+strlen(HL)
;@DESTROYS AF
strupper:
	ld a,(hl)
	or a,a
	ret z
	sub a,'a'
	cp a,26
	jr nc,_strupper.next
	add a,'A'
	jr _strupper.loop

