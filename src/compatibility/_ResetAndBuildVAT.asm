;@DOES reset VAT pointers and rebuild the VAT.
_ResetAndBuildVAT:
	ld hl,ti.symTable
	ld (ti.pTemp),hl
	ld (ti.progPtr),hl
	call _BuildVAT
	ld hl,'A' shl 8
	ld (ti.OP1),hl
.realvariableloop:
	ld hl,5
	call _CreateVar.entryOP1
	ld a,(ti.OP1+1)
	cp a,'Z'
	ret z
	inc a
	ld (ti.OP1+1),a
	jr .realvariableloop
