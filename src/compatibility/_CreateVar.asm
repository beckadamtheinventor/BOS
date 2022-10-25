_CreateString:
	ld a,ti.StrngObj
	jr _CreateVar

_CreateProg:
	ld a,ti.ProgObj
	jr _CreateVar

_CreateProtProg:
	ld a,ti.ProtProgObj
	jr _CreateVar

_CreateAppVar:
	ld a,ti.AppVarObj
	jr _CreateVar

_CreateCplx:
	ld a,ti.CplxObj
	jr _CreateVar

_CreateStrng:
	ld a,ti.StrngObj
	jr _CreateVar

_CreateReal:
	xor a,a
assert $ = _CreateVar


;@DOES create a ram file in the /tivars/ directory
;@INPUT OP1+1 = 8 byte name of var to create
;@INPUT A = var type
;@INPUT hl = length to allocate for file
;@OUTPUT hl = pointer to (VAT entry) 2 byte file length, de = pointer to file data
;@OUTPUT Cf set and HL = -1 if failed
;DESTROYS All
_CreateVar:
	ld (fsOP1),a
.entryOP1:
	ex hl,de
	ld hl,ti.userMem
	ld bc,(ti.asm_prgm_size)
	add hl,bc
	ex hl,de
	push hl
	call _InsertMem ; insert mem following the currently running assembly program
	pop bc
	push de
	call _AddVATEntry
	pop de
	ret nc
	sbc hl,hl
	ret
