;@DOES Allocate and add an entry to a Symbol list.
;@INPUT symbol *util_AppendSymList(symlist *list, const char *name, unsigned int value, uint8_t flags);
;@OUTPUT Pointer to new Symbol. 0 if failed.
util_AppendSymList:
	call ti._frameset0
	ld hl,symbol.entry_size
	call sys_Malloc.entryhl
	jr c,.fail
	push hl
	ld hl,(ix+6)
	inc hl
	inc hl
	inc hl
	ld de,(hl) ; grab pointer to last symbol in list
	ex hl,de
	add hl,de
	or a,a
	sbc hl,de
	pop de
	jr nz,.not_first_added
	ld hl,(ix+6)
.not_first_added:
	ld (hl),de ; set last symbol's next symbol to the new symbol
	ex hl,de
	push hl,de
	ld de,symbol.end
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld de,(ix+9)
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld a,(ix+15)
	ld (hl),a
	inc hl
	ld de,(ix+12)
	ld (hl),de
	pop de
	ld hl,(ix+6)
	inc hl
	inc hl
	inc hl
	ld (hl),de ; set new last symbol
	pop hl
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
	; ld sp,ix
	pop ix
	ret
