;@DOES Remove a symbol by name from a Symbol list.
;@INPUT symbol *util_RemoveFromSymList(symlist *list, const char *name);
;@OUTPUT Pointer to unlinked symbol. 0 if failed.
;@NOTE Unlinked symbol should be freed manually if not needed.
util_RemoveFromSymList:
	call ti._frameset0
	ld hl,(ix+6)
	ld de,(ix+9)
	push de,hl
	call util_SearchSymList
	pop bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail
	push hl
	ld hl,(hl) ; grab pointer to next symbol from found symbol
	ex hl,de
	ld (hl),de ; set previous symbol's next symbol to the found symbol's next symbol
	ex hl,de
	add hl,bc
	or a,a
	sbc hl,bc
	jr nz,.not_removing_final
	ld hl,(ix+6) ; set new final symbol to the previous symbol if we're removing the final symbol
	inc hl
	inc hl
	inc hl
	ld (hl),de
.not_removing_final:
	pop hl
.fail:
	pop ix
	ret
