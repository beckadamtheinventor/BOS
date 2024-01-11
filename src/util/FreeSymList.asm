;@DOES Free a Symbol list.
;@INPUT void util_FreeSymList(symlist *list);
;@NOTE symlist pointer passed should be freed manually if it was malloc'd or initialized from util_InitAllocSymList.
util_FreeSymList:
	pop bc,hl
	push hl,bc
	ld hl,(hl)
	jr .entry
.loop:
	ld de,(hl) ; grab pointer to next entry before freeing this one
	push de
	call sys_Free.entryhl
	pop hl
.entry:
	add hl,bc ; check if next entry is the end
	or a,a
	sbc hl,bc
	jr nz,.loop ; keep freeing if it isn't
	ret
