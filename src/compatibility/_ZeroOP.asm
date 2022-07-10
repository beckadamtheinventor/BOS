
_ZeroOP3:
	ld hl,fsOP3
	jq _ZeroOP
_ZeroOP2:
	ld hl,fsOP2
	jq _ZeroOP
_ZeroOP1:
	ld hl,fsOP1
_ZeroOP:
	push bc
	xor a,a
	ld b,11
.clrloop:
	ld (hl),a
	inc hl
	djnz .clrloop
	pop bc
	ret
