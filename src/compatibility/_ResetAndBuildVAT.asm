;@DOES reset VAT pointers and rebuild the VAT.
_ResetAndBuildVAT:
	ld hl,ti.symTable
	ld (ti.pTemp),hl
	ld (ti.progPtr),hl
	call _BuildVAT
	ld hl,(ti.pTemp)
	push hl
	ld hl,'A' shl 8 ; letter variables
	ld (ti.OP1),hl
.realvariableloop:
	ld hl,9
	call _CreateVar.entryOP1
	ld a,(ti.OP1+1)
	cp a,'Z'+1 ; create up until theta (letter after Z in TI-BASIC tokens)
	jr z,.donereals
	inc a
	ld (ti.OP1+1),a
	jr .realvariableloop
.donereals:
	ld hl,$72 shl 8 ; Ans
	ld (ti.OP1),hl
	ld hl,9
	call _CreateVar.entryOP1 ; create Ans variable
	ld hl,(ti.pTemp)
	ld (ti.OPBase),hl
	pop hl
	ld (ti.pTemp),hl
	ret
