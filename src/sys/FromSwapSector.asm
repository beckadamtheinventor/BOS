;@DOES Write the swap sector to a given sector
;@INPUT void sys_FromSwapSector(uint8_t sector);
sys_FromSwapSector:
	ld a,'B'
	call fs_PartitionDescriptor
	ld bc,8
	add hl,bc
	ld hl,(hl)
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	pop bc
	pop de
	push de
	push bc
	ld a,e
	cp a,4
	ret c
	push hl
	push af
	call sys_EraseFlashSector
	pop af
	ld (ScrapMem+2),a
	ld de,(ScrapMem)
	ld d,0
	ld e,d
	pop hl
	ld bc,65536
	jp sys_WriteFlash

