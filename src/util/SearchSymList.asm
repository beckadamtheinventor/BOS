;@DOES Search a Symbol list for a given symbol.
;@INPUT symbol *util_SearchSymList(symlist *list, const char *name);
;@OUTPUT Pointer to Symbol. 0 if failed. Returns pointer to symbol preceeding the found symbol in de.
util_SearchSymList:
	call ti._frameset0
	push iy
	ld iy,(ix+6)
.loop:
	ld hl,(iy)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail ; fail if at end of list (next symbol is null)
	lea de,iy
	ld iy,(iy)
	ld hl,(iy+symbol.name)
	ld bc,(ix+9)
.nameloop: ; compare names
	ld a,(bc)
	or a,a
	jr z,.nameloopmaybeend ; target name ended, check if symbol name ended
	cp a,(hl)
	jr nz,.loop ; jump if names don't match
	inc hl
	inc bc
	jr .nameloop ; continue searching
.nameloopmaybeend:
	cp a,(hl)
	jr nz,.nameloop ; jump back to main search loop if symbol name didn't end but target name did
	lea hl,iy ; otherwise return iy
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
	pop iy
	pop ix
	ret
