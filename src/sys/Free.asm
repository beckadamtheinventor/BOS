;@DOES Free a block of memory returned by sys_Malloc
;@INPUT HL = memory to free
;@DESTROYS AF,DE
sys_Free:
	dec hl
	dec hl
	dec hl
	ld de,(hl)
	push de
	ld de,0
	ld (hl),de
	pop de
	inc hl
	inc hl
	inc hl
	ld (hl),de
	ret

