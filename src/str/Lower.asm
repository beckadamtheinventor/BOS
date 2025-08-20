_strlower:
.loop:
	ld (hl),a
.next:
	inc hl
;@DOES convert a string to lowercase
;@INPUT HL pointer to string
;@OUTPUT HL HL+strlen(HL)
;@DESTROYS AF
strlower:
	ld a,(hl)
	or a,a
	ret z
	sub a,'A'
	cp a,26
	jr nc,_strlower.next
	add a,'a'
	jr _strlower.loop

