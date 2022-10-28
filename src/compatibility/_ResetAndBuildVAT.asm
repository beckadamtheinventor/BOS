;@DOES reset VAT pointers and rebuild the VAT.
_ResetAndBuildVAT:
	ld hl,ti.symTable
	ld (ti.pTemp),hl
	ld (ti.progPtr),hl
	call _BuildVAT
	ld hl,(ti.pTemp)
	push hl
	ld hl,'A' shl 8
	ld (ti.OP1),hl
.realvariableloop:
	ld hl,9
	call _CreateVar.entryOP1
	ld a,(ti.OP1+1)
	cp a,'Z'
	jr z,.donereals
	inc a
	ld (ti.OP1+1),a
	jr .realvariableloop
.donereals:
	ld hl,(ti.pTemp)
	ld (ti.OPBase),hl
	pop hl
	ld (ti.pTemp),hl
	ret
