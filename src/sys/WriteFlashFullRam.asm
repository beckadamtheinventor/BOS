
;@DOES store data to flash, surpassing flash AND logic using the first half of VRAM for swap if needed.
;@OUTPUT uint8_t sys_WriteFlashFullRam(void *dest, void *src, int len);
sys_WriteFlashFullRam:
	call ti._frameset0
	ld a,(ix+8) ;high byte of destination
	cp a,4
	jq c,.fail
	cp a,$40
	jq nc,.fail

	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,(ix+12)
.check_write_needs_swap_loop:
	ld a,(de)
	inc de
	and a,(hl)
	cpi
	jq nz,.write_needs_swap
	jp pe,.check_write_needs_swap_loop

; no need to use swap sector if there aren't any 0 bits needing to be turned into 1 bits (flash AND logic)
	call sys_FlashUnlock
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,(ix+12)
	call sys_WriteFlash
	call sys_FlashLock
	xor a,a
	inc a
	pop ix
	ret

.write_needs_swap:
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

	ld hl,(ti.mpLcdUpbase)
	push hl
	ld de,LCD_BUFFER
	or a,a
	sbc hl,de
	add hl,de
	jq z,.no_blit_screen
	ld bc,ti.lcdWidth*ti.lcdHeight ;blit lcd to buffer
	ld (ti.mpLcdUpbase),de
	ldir
.no_blit_screen:

	ld a,(ix+8) ;high byte of destination
	cp a,4
	jq c,.fail
	cp a,$3F
	jq nc,.fail

	call sys_FlashUnlock
.main:
	ld hl,(ix+6)
	ex.s hl,de
	push de
	pop bc
	ld de,ti.vRam
	ld hl,(ix+6)
	ld l,e
	ld h,l
	ld a,c
	or a,b
	jq z,.zero_len_write
	push de,bc
	ldir
	pop bc,hl
	add hl,bc
.zero_len_write:

	ex hl,de
	ld hl,(ix+9)
	ld bc,(ix+12)
	ld a,c
	or a,b
	jq z,.zero_len_write_2
	push de,bc
	ldir
	pop bc,hl
	add hl,bc
.zero_len_write_2:

	ld de,(ix+6)
	ld e,l
	ld d,h
	push hl,hl
	pop bc
	ld hl,LCD_VRAM+$FFFF
	or a,a
	sbc hl,bc
	push hl
	pop bc
	pop hl
	ld a,b
	or a,c
	jq z,.zero_len_write_3
	ex hl,de
	ldir
.zero_len_write_3:

	ld a,(ix+8)
	call sys_EraseFlashSector
	ld de,(ix+6)
	ld e,0
	ld d,e
	ld hl,ti.vRam
.write_dest_sector_and_finish:
	ld bc,$010000
	call sys_WriteFlash
	call sys_FlashLock

	pop hl
	ld de,LCD_BUFFER
	or a,a
	sbc hl,de
	add hl,de
	jq z,.success
	ex hl,de
	ld bc,ti.lcdWidth*ti.lcdHeight ;blit buffer back to lcd
	push de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de
.success:
	db $3E ;ld a,... ;a will be non-zero because "xor a,a" is not zero
.fail:
	xor a,a
	or a,a
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


