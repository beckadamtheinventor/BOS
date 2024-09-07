
_DelAppVar:
	ld a,ti.AppVarObj
	jq _DelVarA

_DelVarA:
	ld (fsOP1),a
	jq _DelVar

;@DOES delete a variable in ram from the VAT
;@INPUT OP1 = type byte, 8 byte name of var to delete
;@OUTPUT Cf set if failed
;DESTROYS All
_DelVar:
	call _SearchSymTable
	push hl
	ex hl,de
	mlt de
	ld e,(hl)
	inc hl
	ld d,(hl)
	dec hl
	inc de
	inc de
	call _DelMem ; delete the data from usermem
	pop hl
	push hl
	ld bc,-6
	add hl,bc
	ld b,(hl)
.bypassname:
	dec hl
	djnz .bypassname
	pop de
	push hl
	or a,a
	sbc hl,de ; hl = length of VAT entry to delete
	ex (sp),hl
	pop bc
	
	; TODO
		
	; push hl,bc,de
	; call ti._memmove ; shift the VAT upwards if needed, overwriting the desired entry
	; pop bc,bc,bc
	; ret
; .move_last_entry:
	; ld (ti.pTemp),bc
	ret


