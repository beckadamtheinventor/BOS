
;@DOES store data to flash, surpassing flash AND logic using the swap sector.
;@OUTPUT uint8_t sys_WriteFlashFull(void *dest, void *src, int len);
;@NOTE erases swap sector, copies dest sector to swap sector excluding the data write area, writes data, erases dest sector, copies swap sector to dest sector.
;@NOTE source and destination cannot be within the same sector.
sys_WriteFlashFull:
	call ti._frameset0
	ld a,(ix+8) ;high byte of destination
	cp a,4
	jq c,.fail
	cp a,$3F
	jq nc,.fail

	ld de,(ix+6)
	ex.s hl,de
	ld de,(ix+12)
	add hl,de
	ld de,$010000
	or a,a
	sbc hl,de
	jq nc,.two_writes

	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,(ix+12)
	push bc,hl,de
	call .write_flash_full
	pop bc,bc,bc
	pop ix
	ret

.write_flash_full:
	call ti._frameset0
	ld a,(ix+8) ;high byte of destination
	cp a,4
	jq c,.fail
	cp a,$3F
	jq nc,.fail

	call sys_FlashUnlock
.main:
	ld a,$3F
	call sys_EraseFlashSector
	ld hl,(ix+6)
	ex.s hl,de
	push de
	pop bc
	ld de,$3F0000
	ld hl,(ix+6)
	ld l,e
	ld h,l
	ld a,c
	or a,b
	push de,bc
	call nz,sys_WriteFlash
	pop bc,hl
	add hl,bc

	ex hl,de
	ld hl,(ix+9)
	ld bc,(ix+12)
	ld a,c
	or a,b
	push de,bc
	call nz,sys_WriteFlash
	pop bc,hl
	add hl,bc

	ld de,(ix+6)
	ld e,l
	ld d,h
	push hl,hl
	pop bc
	ld hl,$3FFFFF
	or a,a
	sbc hl,bc
	push hl
	pop bc
	pop hl
	ld a,b
	or a,c
	ex hl,de
	call nz,sys_WriteFlash

	ld a,(ix+8)
	call sys_EraseFlashSector
	ld de,(ix+6)
	ld e,0
	ld d,e
	ld hl,$3F0000
.write_dest_sector_and_finish:
	ld bc,$010000
	call sys_WriteFlash
	call sys_FlashLock

.success:
	db $3E ;ld a,... ;a will be non-zero because "xor a,a" is not zero
.fail:
	xor a,a
	pop ix
	ret

.two_writes:

;write first sector
	ld hl,(ix+6)
	ex.s hl,de
	ld a,e
	or a,d
	jq z,.full_sector
	ld hl,$00FFFF
	sbc hl,de ;length until sector boundary
	ld de,(ix+6)
	ld bc,(ix+9)
	push hl,bc,de
	call .write_flash_full
	pop de,hl,bc
	or a,a
	jq z,.fail
	inc bc

;write next sector(s)
	add hl,bc ;src is now at next sector boundary
	ex hl,de
	add hl,bc ;dest is now at next sector boundary
	ex hl,de
	push hl
	ld hl,(ix+12)
	or a,a
	sbc hl,bc
	push hl
	pop bc ;bc is now len - prev write len
	pop hl
	push bc,hl,de
	call nz,.write_flash_full
	pop bc,bc,bc
	or a,a
	jq z,.fail
	jq .success

;write an entire sector
.full_sector:
	call flash_unlock
	ld a,(ix+8) ;upper byte of destination
	call sys_EraseFlashSector
	ld hl,(ix+9)
	ld de,(ix+6)
	jq .write_dest_sector_and_finish


