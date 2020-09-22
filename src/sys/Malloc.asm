;@DOES Allocate memory
;@INPUT HL = number of bytes to malloc
;@OUTPUT DE = malloc'd bytes
;@OUTPUT C flag set if failed
;@DESTROYS AF,DE
sys_Malloc:
	ld de,(remaining_free_RAM)
	or a,a
	ex hl,de
	sbc hl,de
	ret c
	ld (remaining_free_RAM),hl
	ld hl,(free_RAM_ptr)
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ex hl,de
	add hl,de
	ld (free_RAM_ptr),hl
	or a,a
	ret

