;@DOES Check if a file is currently being stored in RAM
;@INPUT bool fsd_InRam(void** fd);
fsd_InRam:
	pop bc,hl
	push hl,bc
.entryhl:
assert fsd_DataPtr = 3
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a,(hl) ; high byte of data pointer
	cp a,$D0  ; sets carry flag if a<$D0
	sbc a,a   ; 0xff if carry set, otherwise 0
	inc a     ; 0xff->0x00, 0x00->0x01
	ret
