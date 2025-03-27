
;@DOES store data to flash, surpassing flash AND logic using the first half of VRAM for swap if needed.
;@OUTPUT uint8_t sys_WriteFlashFullRam(void *dest, void *src, int len);
;@NOTE Assume maximum write length is 65536.
sys_WriteFlashFullRam:
	call ti._frameset0
	ld a,(ix+8) ;high byte of destination
	cp a,4
	jq c,.fail
	cp a,$40
	jq nc,.fail
	ld bc,(ix+12)
	ld a,c
	or a,b
	jq z,.success ;if there's no data to write, there's nothing to change

	ld de,(ix+6)
	ld hl,(ix+9)
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
	jq nc,.two_writes ; write crosses sector boundary

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
	cp a,$04
	jq c,.fail
	cp a,$40
	jq nc,.fail

    call sys_ReadSectorCache.only_handle_vram
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
	ldir
.zero_len_write:

	ld hl,(ix+9)
	ld bc,(ix+12)
	ld a,c
	or a,b
	jq z,.zero_len_write_2
	ldir
.zero_len_write_2:

	ld hl,(ix+6)
	ld l,e
	ld h,d
	push hl
	ld hl,LCD_VRAM+$010000
	or a,a
	sbc hl,de
	ld c,l
	ld b,h
	pop hl
	ld a,b
	or a,c
	jq z,.zero_len_write_3
	ldir
.zero_len_write_3:

	ld a,(ix+8)
    call sys_WriteSectorCache.entry

.success:
	db $3E ;ld a,... ;a will be non-zero because the opcode for "xor a,a" is not zero
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
    ld bc,(ix+12)
    ld hl,(ix+9)
    ld de,(ix+6)
    push bc,hl,de
    call .write_flash_full
    pop bc,bc,bc
    jq .success


